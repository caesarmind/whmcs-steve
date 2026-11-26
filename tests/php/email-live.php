<?php
/**
 * Hadrian Email Templates against the live local WHMCS: the takeover, the
 * send hook, publishing and restoring, with real emails read back from
 * Mailpit. Run by tests/e2e/email.spec.mjs; also runnable on its own:
 *
 *   php tests/php/email-live.php
 *
 * These are the checks that cannot be made without WHMCS itself, because they
 * are about how WHMCS treats what the module writes: whether a guarded
 * placeholder falls through, whether a published body compiles, whether a
 * restore is byte for byte.
 *
 * Leaves WHMCS's mail settings and templates exactly as it found them, and
 * says so in its last three lines. Refuses unless SystemURL is localhost.
 */

declare(strict_types=1);

// Not while another test run holds the local site (tests/php/site-lock.php).
require_once __DIR__ . '/site-lock.php';
hadrian_site_lock_guard('email-live.php');

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;
use HadrianEmail\{Blocks, Design, Merge, Presets, Publisher, Renderer, Schema, SendHook, Store, Takeover, Theme};

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}
if (!class_exists('HadrianEmail\\Takeover')) {
    fwrite(STDERR, "Hadrian Email Templates is not active on this install.\n");
    exit(3);
}

$MAILPIT = rtrim(getenv('HADRIAN_MAILPIT_URL') ?: 'http://localhost:8025', '/');
$http = static function (string $url): array {
    $raw = @file_get_contents($url);
    return $raw === false ? [] : (json_decode($raw, true) ?: []);
};
$newest = static fn(): string => (string) ($http($MAILPIT . '/api/v1/messages?limit=1')['messages'][0]['ID'] ?? '');
/** The HTML of the first message to arrive after $before, or '' on timeout. */
$arrived = static function (string $before) use ($http, $newest, $MAILPIT): string {
    $end = microtime(true) + 10;
    while (microtime(true) < $end) {
        $id = $newest();
        if ($id !== '' && $id !== $before) {
            return (string) ($http($MAILPIT . '/api/v1/message/' . $id)['HTML'] ?? '');
        }
        usleep(300000);
    }
    return '';
};

$ok = 0;
$bad = 0;
$check = static function (string $label, bool $cond, string $detail = '') use (&$ok, &$bad): void {
    if ($cond) {
        $ok++;
        echo "  ok   {$label}\n";
    } else {
        $bad++;
        echo "  FAIL {$label}" . ($detail !== '' ? "  -> {$detail}" : '') . "\n";
    }
};

$admin    = (string) DB::table('tbladmins')->orderBy('id')->value('username');
$fixtures = json_decode((string) @file_get_contents(dirname(__DIR__) . '/.local/fixtures.json'), true) ?: [];
$clientId = (int) ($fixtures['personas']['full']['clientId'] ?? 0);
$invoice  = DB::table('tblinvoices')->where('userid', $clientId)->orderBy('id')->first();
if ($clientId === 0 || !$invoice) {
    fwrite(STDERR, "fixtures missing: php tests/php/fixtures.php\n");
    exit(4);
}
$send = static fn(string $template, int $id): array => (array) localAPI('SendEmail', ['messagename' => $template, 'id' => $id], $admin);

$KEYS = ['EmailGlobalHeader', 'EmailGlobalFooter', 'EmailCSS'];
$orig = [];
foreach ($KEYS as $k) {
    $orig[$k] = DB::table('tblconfiguration')->where('setting', $k)->value('value');
}
$TEMPLATE    = 'Invoice Created';
$origRow     = DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '')->first();
$hadLayout   = Store::get(Design::ACTIVE_LAYOUT_KEY, null);
$wasEnabled  = Takeover::isEnabled();
// Every email sent below lands in the test client's email history; the rows
// newer than this are removed at the end.
$mailMark    = (int) DB::table('tblemails')->max('id');
if ($wasEnabled) {
    fwrite(STDERR, "The takeover is already on; run `php tests/php/email.php reset` first.\n");
    exit(5);
}

Schema::ensure();
$theme    = Theme::load();
$layout   = Blocks::normalize(Presets::layout([['label' => ['_' => 'Terms'], 'url' => 'https://example.com/terms']]), Blocks::KIND_LAYOUT);
$message  = Blocks::normalize(Presets::message($TEMPLATE), Blocks::KIND_MESSAGE);
$layoutId = 0;
$designId = 0;

try {
    echo "== takeover\n";
    $layoutId = Design::create(['kind' => Blocks::KIND_LAYOUT, 'name' => 'Live test layout', 'doc' => $layout]);
    Store::set(Design::ACTIVE_LAYOUT_KEY, $layoutId);
    Takeover::enable();
    $st = Takeover::status();
    $check('on, nothing edited outside, originals held', $st['enabled'] && $st['drift'] === [] && $st['hasBackup']);
    $stored = (string) DB::table('tblconfiguration')->where('setting', 'EmailGlobalHeader')->value('value');
    $check('header is a guarded placeholder, stored entity-encoded like WHMCS stores its own',
        str_starts_with($stored, '{if $' . Takeover::HEADER_FIELD . '}') && str_contains($stored, '&lt;!DOCTYPE html&gt;'));

    echo "== a stock email, through the send hook\n";
    $before = $newest();
    $api = $send('Client Signup Email', $clientId);
    $h = $arrived($before);
    $check('WHMCS sent it', ($api['result'] ?? '') === 'success' && $h !== '', json_encode($api));
    $check('wrapped in the layout', str_contains($h, 'class="hx-container"') && str_contains($h, 'hx-content'));
    $check('stock body untouched inside it', str_contains($h, 'Dear '));
    $check('footer merge fields filled in by the hook', str_contains($h, date('Y') . ' ') && !str_contains($h, '{$hx_year}') && !str_contains($h, '{$companyname}'));
    $check('no markers, guards or raw Smarty reach the inbox', !str_contains($h, 'hx-if') && !str_contains($h, '{if ') && !str_contains($h, '{/if}') && !str_contains($h, '{literal}'));
    $check('wrapper stays well under Gmail\'s 102 KB clip', strlen($h) < 30000, strlen($h) . ' bytes');

    echo "== the same email with the hook silent (static fallback)\n";
    Store::set(Takeover::ENABLED_KEY, false);     // the hook answers [], WHMCS still holds the guard
    $before = $newest();
    $api = $send('Client Signup Email', $clientId);
    $f = $arrived($before);
    Store::set(Takeover::ENABLED_KEY, true);
    $check('still sent', ($api['result'] ?? '') === 'success' && $f !== '', json_encode($api));
    $check('still the Hadrian layout, not a bare email', str_contains($f, 'class="hx-container"') && str_contains($f, 'Dear '));
    $check('fallback leaves no raw Smarty', !str_contains($f, '{literal}') && !str_contains($f, '{if ') && !str_contains($f, '{$'));

    echo "== publish a design\n";
    $designId = Design::create(['kind' => Blocks::KIND_MESSAGE, 'name' => $TEMPLATE, 'target' => $TEMPLATE, 'doc' => $message]);
    $res = Publisher::publish($designId);
    $check('published', $res['ok'], implode(' | ', $res['errors']));
    $check('not reported as edited outside right after', Publisher::drift(Design::find($designId)) === []);
    SendHook::reset();
    $before = $newest();
    $api = $send($TEMPLATE, (int) $invoice->id);
    $i = $arrived($before);
    $check('WHMCS compiled and sent the designed body', ($api['result'] ?? '') === 'success' && $i !== '', json_encode($api));
    $check('design blocks present', str_contains($i, 'hx-btn') && str_contains($i, 'Invoice #'));
    $check('merge fields evaluated by WHMCS', !str_contains($i, '{$invoice_num}') && !str_contains($i, '{$'));
    $check('preview text comes from the design, amounts included',
        (bool) preg_match('/mso-hide:all[^>]*>[^<]*\d[^<]*due on/', $i), substr($i, (int) strpos($i, 'mso-hide:all'), 160));

    echo "== translations become per-language WHMCS templates\n";
    $langRows = static fn(): array => DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '!=', '')->pluck('message', 'language')->all();
    $hadLangRows = $langRows();
    $translated  = (array) Design::find($designId)['doc'];
    $translated['blocks'][0]['props']['text']['french'] = 'Facture {$invoice_num}';
    $translated['blocks'][0]['props']['text']['arabic'] = 'Invoice-AR {$invoice_num}';
    Design::update($designId, ['doc' => $translated]);
    $res = Publisher::publish($designId);
    $rows = $langRows();
    $check('published in every language that has a translation', $res['ok'] && isset($rows['french'], $rows['arabic']), json_encode([$res['languages'], array_keys($rows)]));
    $check('the French template carries the French text', str_contains((string) ($rows['french'] ?? ''), 'Facture {$invoice_num}'));
    $check('...and falls back to the default for what was not translated', str_contains((string) ($rows['french'] ?? ''), 'View and pay invoice'));
    $check('the Arabic template is written right to left', str_contains((string) ($rows['arabic'] ?? ''), 'text-align:right'));
    $defaultRow = (string) DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '')->value('message');
    $check('the default template is untouched by the translations', !str_contains($defaultRow, 'Facture') && str_contains($defaultRow, 'text-align:left'));
    unset($translated['blocks'][0]['props']['text']['arabic']);
    Design::update($designId, ['doc' => $translated]);
    Publisher::publish($designId);
    $check('a language that lost its translation loses its template again', !isset($langRows()['arabic']) && isset($langRows()['french']));

    echo "== the Banner design puts each email's own subject in the header\n";
    Design::update($layoutId, ['doc' => Blocks::normalize(\HadrianEmail\Designs::apply($layout, 'banner'), Blocks::KIND_LAYOUT)]);
    Takeover::refresh();
    SendHook::reset();
    $before = $newest();
    $api = $send('Support Ticket Opened', (int) DB::table('tbltickets')->where('userid', $clientId)->orderBy('id')->value('id'));
    $t = $arrived($before);
    $subject = (string) DB::table('tblemailtemplates')->where('name', 'Support Ticket Opened')->where('language', '')->value('subject');
    $check('sent with the Banner layout', ($api['result'] ?? '') === 'success' && str_contains($t, 'class="hx-band"'), json_encode($api));
    $check('the band carries this email\'s WHMCS subject', $subject !== '' && (bool) preg_match('/class="hx-title[^"]*"[^>]*>' . preg_quote(htmlspecialchars($subject, ENT_QUOTES, 'UTF-8'), '/') . '</', $t),
        $subject . ' | ' . substr($t, (int) strpos($t, 'hx-title'), 140));
    Store::set(Takeover::ENABLED_KEY, false);    // the hook answers [], WHMCS uses the guarded static copy
    $before = $newest();
    $send('Support Ticket Opened', (int) DB::table('tbltickets')->where('userid', $clientId)->orderBy('id')->value('id'));
    $tf = $arrived($before);
    Store::set(Takeover::ENABLED_KEY, true);
    $check('without the hook: still the band, no title and no placeholder', str_contains($tf, 'class="hx-band"') && !str_contains($tf, 'class="hx-title') && !str_contains($tf, 'hx_subject') && !str_contains($tf, '{$'),
        'band=' . (int) str_contains($tf, 'class="hx-band"') . ' title=' . (int) str_contains($tf, 'class="hx-title') . ' field=' . (int) str_contains($tf, 'hx_subject') . ' brace=' . (int) str_contains($tf, '{$'));
    Design::update($layoutId, ['doc' => $layout]);
    Takeover::refresh();
    SendHook::reset();

    echo "== every starter compiles\n";
    $broken = [];
    foreach (Presets::names() as $name) {
        $doc = Blocks::normalize(Presets::message($name), Blocks::KIND_MESSAGE);
        if (Merge::lint(Renderer::compileMessage($theme, $doc, 'english')) !== []) {
            $broken[] = $name;
        }
    }
    $check('all ' . count(Presets::names()) . ' starters lint clean', $broken === [], implode(', ', $broken));

    echo "== edits made outside are noticed, not overwritten\n";
    DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '')->update(['message' => '<p>edited in WHMCS</p>']);
    $check('a template edited in WHMCS is detected', Publisher::drift(Design::find($designId)) !== []);
    $check('a theme change does not republish over that edit', Publisher::republishAll() === 0
        && DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '')->value('message') === '<p>edited in WHMCS</p>');
    Publisher::restore($designId);
    $now = DB::table('tblemailtemplates')->where('name', $TEMPLATE)->where('language', '')->first();
    $check('restore puts the original template back exactly', (string) $now->message === (string) $origRow->message && (string) $now->subject === (string) $origRow->subject);
    $check('...and removes the language templates the publish created', $langRows() === $hadLangRows, json_encode(array_keys($langRows())));

    DB::table('tblconfiguration')->where('setting', 'EmailGlobalFooter')->update(['value' => 'someone edited this']);
    $check('a Mail-tab edit is detected', Takeover::drift() === ['EmailGlobalFooter']);
    $check('a background refresh leaves that edit alone', !in_array('EmailGlobalFooter', Takeover::refresh(), true)
        && DB::table('tblconfiguration')->where('setting', 'EmailGlobalFooter')->value('value') === 'someone edited this');
    Takeover::refresh(true);
    $check('"use the Hadrian layout again" clears it', Takeover::drift() === []);
} catch (\Throwable $e) {
    $check('no exception', false, get_class($e) . ': ' . $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine());
} finally {
    echo "== left as found\n";
    try {
        if ($designId) {
            Publisher::restore($designId);
            Design::delete($designId);
        }
    } catch (\Throwable $e) {
        echo '  cleanup design: ' . $e->getMessage() . "\n";
    }
    try {
        Takeover::disable();
    } catch (\Throwable $e) {
        echo '  cleanup takeover: ' . $e->getMessage() . "\n";
    }
    try {
        if ($layoutId) {
            Design::delete($layoutId);
        }
        if ($hadLayout === null) {
            Store::forget(Design::ACTIVE_LAYOUT_KEY);
        } else {
            Store::set(Design::ACTIVE_LAYOUT_KEY, $hadLayout);
        }
    } catch (\Throwable $e) {
        echo '  cleanup layout: ' . $e->getMessage() . "\n";
    }
    DB::table('tblemails')->where('id', '>', $mailMark)->delete();
    DB::table('tblemailtemplates')->where('id', $origRow->id)
        ->update(['message' => $origRow->message, 'subject' => $origRow->subject, 'plaintext' => $origRow->plaintext]);
    foreach ($KEYS as $k) {
        $nowV = DB::table('tblconfiguration')->where('setting', $k)->value('value');
        $check("turning it off restored {$k} byte for byte", $nowV === $orig[$k]);
        if ($nowV !== $orig[$k]) {
            // The check above already failed the run; do not also leave the
            // local install with someone else's mail header.
            DB::table('tblconfiguration')->updateOrInsert(['setting' => $k], ['value' => (string) $orig[$k]]);
        }
    }
}

echo "\n{$ok} ok, {$bad} failed\n";
exit($bad === 0 ? 0 : 1);
