<?php
/**
 * Test helper for Hadrian Email Templates (a separate addon module, mounted
 * from hadrian_email/). Used by tests/e2e/email.spec.mjs.
 *
 *   php tests/php/email.php state
 *       JSON: is the takeover on, what WHMCS's three mail settings hold, and
 *       the designs that exist.
 *   php tests/php/email.php snapshot
 *       Remember WHMCS's three mail settings and one template row, so `reset`
 *       can prove they came back byte for byte.
 *   php tests/php/email.php reset
 *       The clean slate every test starts from and the suite ends on: restore
 *       every published design, delete all designs, turn the takeover off.
 *       JSON: whether the snapshot was matched.
 *   php tests/php/email.php mail-mark  /  mail-clean <mark>
 *       Remember the newest row in WHMCS's sent-email log, and later delete
 *       everything newer: the emails the tests sent.
 *   php tests/php/email.php enable
 *       Turn the takeover on (saving the default layout first if there is none).
 *   php tests/php/email.php send <template name> <related id>
 *       Send one templated email through WHMCS's own API, hooks and all.
 *   php tests/php/email.php seed-published <template name>
 *       Create and publish that template's starter design without the UI.
 *
 * Refuses unless SystemURL is localhost: `reset` rewrites mail settings.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}
if (!class_exists('HadrianEmail\\Takeover')) {
    fwrite(STDERR, "Hadrian Email Templates is not active on this install (php scripts/local-stack/post-install.php).\n");
    exit(3);
}

use HadrianEmail\Blocks;
use HadrianEmail\Bridge;
use HadrianEmail\Design;
use HadrianEmail\Presets;
use HadrianEmail\Publisher;
use HadrianEmail\Schema;
use HadrianEmail\Store;
use HadrianEmail\Takeover;

const MAIL_KEYS = ['EmailGlobalHeader', 'EmailGlobalFooter', 'EmailCSS'];
const SNAPSHOT_TEMPLATE = 'Invoice Created';
$snapshotFile = dirname(__DIR__) . '/.local/email-snapshot.json';

$mail = static function (): array {
    $out = [];
    foreach (MAIL_KEYS as $k) {
        $out[$k] = (string) DB::table('tblconfiguration')->where('setting', $k)->value('value');
    }
    return $out;
};
$row = static function (string $name): array {
    $r = DB::table('tblemailtemplates')->where('name', $name)->where('language', '')->first();
    return $r ? ['subject' => (string) $r->subject, 'message' => (string) $r->message, 'plaintext' => (int) $r->plaintext] : [];
};
$out = static function (array $data): void {
    echo json_encode($data, JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE), "\n";
};

Schema::ensure();
[$cmd, $a, $b] = [$argv[1] ?? '', $argv[2] ?? '', $argv[3] ?? ''];

switch ($cmd) {
    case 'state':
        $m = $mail();
        $designs = [];
        foreach (DB::table(Schema::DESIGNS)->get(['id', 'kind', 'target', 'status']) as $d) {
            $designs[] = (array) $d;
        }
        $out([
            'enabled'      => Takeover::isEnabled(),
            'available'    => Bridge::available(),
            'drift'        => Takeover::drift(),
            'headerGuard'  => str_starts_with($m['EmailGlobalHeader'], '{if $' . Takeover::HEADER_FIELD . '}'),
            'footerGuard'  => str_starts_with($m['EmailGlobalFooter'], '{if $' . Takeover::FOOTER_FIELD . '}'),
            'headerBytes'  => strlen($m['EmailGlobalHeader']),
            'designs'      => $designs,
            'templateHash' => sha1(json_encode($row(SNAPSHOT_TEMPLATE))),
            'activeAddons' => (string) DB::table('tblconfiguration')->where('setting', 'ActiveAddonModules')->value('value'),
        ]);
        break;

    case 'snapshot':
        // Only from a clean state: a snapshot taken while the takeover is on
        // would record the placeholders as "the originals".
        if (Takeover::isEnabled()) {
            fwrite(STDERR, "snapshot refused: the takeover is on. Run `reset` first.\n");
            exit(4);
        }
        @mkdir(dirname($snapshotFile), 0777, true);
        file_put_contents($snapshotFile, json_encode(['mail' => $mail(), 'row' => $row(SNAPSHOT_TEMPLATE)]));
        echo "snapshot\n";
        break;

    case 'reset':
        foreach (Design::published() as $d) {
            Publisher::restore((int) $d['id']);
        }
        DB::table(Schema::DESIGNS)->delete();
        if (Takeover::isEnabled()) {
            Takeover::disable();
        }
        foreach ([Takeover::BACKUP_KEY, Takeover::WRITTEN_KEY, Takeover::SIGNATURE_KEY, Design::ACTIVE_LAYOUT_KEY, HadrianEmail\Theme::SETTINGS_KEY] as $k) {
            Store::forget($k);
        }
        $snap = is_file($snapshotFile) ? json_decode((string) file_get_contents($snapshotFile), true) : null;
        $out([
            'ok'        => true,
            'hadSnap'   => is_array($snap),
            'mailSame'  => is_array($snap) ? $snap['mail'] === $mail() : null,
            'rowSame'   => is_array($snap) ? $snap['row'] === $row(SNAPSHOT_TEMPLATE) : null,
        ]);
        break;

    case 'enable':
        // What the "Turn on" button does, for tests that are about something else.
        if (Design::layout() === null) {
            $doc = Blocks::normalize(Presets::layout(Bridge::footerLinks()), Blocks::KIND_LAYOUT, Bridge::languages());
            Store::set(Design::ACTIVE_LAYOUT_KEY, Design::create(['kind' => Blocks::KIND_LAYOUT, 'name' => 'Layout', 'doc' => $doc]));
        }
        Takeover::enable();
        $out(['enabled' => Takeover::isEnabled()]);
        break;

    case 'mail-mark':
        // The newest row in WHMCS's sent-email log. Pair with mail-clean.
        echo (int) DB::table('tblemails')->max('id'), "\n";
        break;

    case 'mail-clean':
        // Remove the log rows added since `mail-mark`. Every email a test
        // sends lands in the test client's email history, where the smoke
        // crawl would later open it and follow the links inside (one of which
        // is an unsubscribe link).
        if (!ctype_digit($a)) {
            fwrite(STDERR, "mail-clean needs the number mail-mark printed\n");
            exit(1);
        }
        $out(['removed' => DB::table('tblemails')->where('id', '>', (int) $a)->delete()]);
        break;

    case 'send':
        $admin = (string) DB::table('tbladmins')->orderBy('id')->value('username');
        $out((array) localAPI('SendEmail', ['messagename' => $a, 'id' => (int) $b], $admin));
        break;

    case 'seed-published':
        $source = Presets::message($a);
        if ($source === null || Publisher::template($a) === null) {
            fwrite(STDERR, "no starter design or no WHMCS template called '{$a}'\n");
            exit(1);
        }
        $doc = Blocks::normalize($source, Blocks::KIND_MESSAGE, Bridge::languages());
        $id  = Design::create(['kind' => Blocks::KIND_MESSAGE, 'name' => $a, 'target' => $a, 'doc' => $doc]);
        $out(Publisher::publish($id) + ['id' => $id]);
        break;

    default:
        fwrite(STDERR, "usage: email.php state | snapshot | reset | mail-mark | mail-clean <mark> | enable | send <template> <relid> | seed-published <template>\n");
        exit(1);
}
