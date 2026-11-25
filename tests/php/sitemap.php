<?php
/**
 * Test helper for Hadrian's sitemap.xml and robots.txt. Used by
 * tests/e2e/sitemap.spec.mjs.
 *
 *   php tests/php/sitemap.php check
 *       Runs the generator against rows made for the purpose and prints JSON:
 *       a list of {name, ok, detail}. Covers what a browser cannot set up:
 *       a hidden product group, a translated and a private knowledgebase
 *       article, a module's page, and when the files are (and are not)
 *       rewritten.
 *   php tests/php/sitemap.php backup
 *       Remember sitemap.xml, robots.txt and the sitemap settings.
 *   php tests/php/sitemap.php restore
 *       Put them back as `backup` found them.
 *   php tests/php/sitemap.php begin
 *       Save the default settings and write both files, as pressing Save on
 *       the Sitemap tab does. JSON: the pages the sitemap lists.
 *   php tests/php/sitemap.php files
 *       JSON: {urls: [...], disallow: [...], mtime: n} read from the files.
 *
 * Every row and file it touches is put back. Refuses unless SystemURL is
 * localhost.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\ExtensionPages;
use Hadrian\Models\Page;
use Hadrian\Service\PageRegistry;
use Hadrian\Service\SitemapGenerator;
use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}
require_once $whmcsRoot . '/modules/addons/Hadrian/autoload.php';

const SETTING = 'sitemap_settings';
$backupFile = sys_get_temp_dir() . '/hadrian-sitemap-test-backup.json';
$template   = AddonHelper::getTemplate();
if ($template === null) {
    fwrite(STDERR, "The Hadrian theme is not the active template.\n");
    exit(3);
}
$tpl     = $template->getName();
$sitemap = ROOTDIR . '/sitemap.xml';
$robots  = ROOTDIR . '/robots.txt';

$read = static fn(string $f): ?string => is_file($f) ? (string) file_get_contents($f) : null;
$put  = static function (string $f, ?string $content): void {
    if ($content === null) {
        @unlink($f);
    } else {
        file_put_contents($f, $content);
    }
};
$snapshot = static function () use ($read, $sitemap, $robots): array {
    $row = DB::table('hadrian_settings')->where('setting', SETTING)->first();
    return ['sitemap' => $read($sitemap), 'robots' => $read($robots), 'row' => $row ? (array) $row : null];
};
$restore = static function (array $state) use ($put, $sitemap, $robots): void {
    $put($sitemap, $state['sitemap']);
    $put($robots, $state['robots']);
    DB::table('hadrian_settings')->where('setting', SETTING)->delete();
    if ($state['row'] !== null) {
        unset($state['row']['id']);
        DB::table('hadrian_settings')->insert($state['row']);
    }
};
$urls = static function (?string $xml): array {
    preg_match_all('#<loc>([^<]+)</loc>#', (string) $xml, $m);
    return array_map(static fn(string $u): string => html_entity_decode($u, ENT_QUOTES | ENT_XML1, 'UTF-8'), $m[1]);
};
$has = static function (array $urls, string $needle): bool {
    foreach ($urls as $u) {
        if (str_contains($u, $needle)) {
            return true;
        }
    }
    return false;
};

$command = $argv[1] ?? 'check';

switch ($command) {
    case 'backup':
        file_put_contents($backupFile, json_encode($snapshot()));
        echo json_encode(true);
        break;

    case 'restore':
        if (is_file($backupFile)) {
            $restore((array) json_decode((string) file_get_contents($backupFile), true));
            @unlink($backupFile);
        }
        echo json_encode(true);
        break;

    case 'begin':
        SitemapGenerator::saveConfig(SitemapGenerator::defaults());
        (new SitemapGenerator())->write($tpl);
        echo json_encode(array_map(
            static fn(array $r): array => ['page' => $r['page'], 'url' => $r['url']],
            Page::forSitemap($tpl)
        ));
        break;

    case 'files':
        $txt = (string) $read($robots);
        preg_match_all('/^Disallow:\s*(\S+)/m', $txt, $d);
        clearstatcache();
        echo json_encode(['urls' => $urls($read($sitemap)), 'disallow' => $d[1], 'mtime' => is_file($sitemap) ? filemtime($sitemap) : 0]);
        break;

    case 'check':
        $out   = [];
        $check = static function (string $name, bool $ok, string $detail = '') use (&$out): void {
            $out[] = ['name' => $name, 'ok' => $ok, 'detail' => $detail];
        };
        $state = $snapshot();
        $made  = ['groups' => [], 'kb' => []];
        $page  = null;
        $pageBefore = null;
        try {
            // ---- what is listed ------------------------------------------
            $now = date('Y-m-d H:i:s');
            $group = static fn(string $name, string $slug, int $hidden): int => (int) DB::table('tblproductgroups')->insertGetId([
                'name' => $name, 'slug' => $slug, 'headline' => '', 'tagline' => '', 'orderfrmtpl' => '', 'disabledgateways' => '',
                'hidden' => $hidden, 'order' => 9000, 'created_at' => $now, 'updated_at' => $now,
            ]);
            $made['groups'][] = $group('E2E Sitemap Shown', 'e2e-sitemap-shown', 0);
            $made['groups'][] = $group('E2E Sitemap Hidden', 'e2e-sitemap-hidden', 1);
            $article = static fn(string $title, string $private, int $parent, string $lang): int => (int) DB::table('tblknowledgebase')->insertGetId([
                'title' => $title, 'article' => 'Test.', 'views' => 0, 'useful' => 0, 'votes' => 0,
                'private' => $private, 'order' => 0, 'parentid' => $parent, 'language' => $lang,
            ]);
            $main        = $article('E2E Sitemap Article', '', 0, '');
            $translation = $article('E2E Sitemap Traduction', '', $main, 'french');
            $private     = $article('E2E Sitemap Private', 'on', 0, '');
            $made['kb']  = [$main, $translation, $private];
            $kbCat = static fn(string $name, string $hidden, int $of, string $lang): int => (int) DB::table('tblknowledgebasecats')->insertGetId([
                'parentid' => 0, 'name' => $name, 'description' => '', 'hidden' => $hidden, 'catid' => $of, 'language' => $lang,
            ]);
            $catShown = $kbCat('E2E Sitemap Topic', '', 0, '');
            $made['kbcats'] = [$catShown, $kbCat('E2E Sitemap Sujet', '', $catShown, 'french'), $kbCat('E2E Sitemap Secret Topic', 'on', 0, '')];
            $dlCat = static fn(string $name, int $hidden): int => (int) DB::table('tbldownloadcats')->insertGetId([
                'parentid' => 0, 'name' => $name, 'description' => '', 'hidden' => $hidden, 'created_at' => $now, 'updated_at' => $now,
            ]);
            $made['dlcats'] = [$dlCat('E2E Sitemap Files', 0), $dlCat('E2E Sitemap Secret Files', 1)];

            // An address is found by the name in it: ids repeat across kinds.
            $slug = static fn(string $title): string => (string) getModRewriteFriendlyString($title);
            $gen    = new SitemapGenerator();
            $listed = $urls($gen->buildSitemap($tpl, ['downloads' => true] + SitemapGenerator::defaults()));
            $check('a product group the store lists is in the sitemap', $has($listed, 'e2e-sitemap-shown'));
            $check('a hidden product group is not', !$has($listed, 'e2e-sitemap-hidden'));
            $check('a knowledgebase article is in the sitemap', $has($listed, $slug('E2E Sitemap Article')));
            $check('its translation row is not listed as a page of its own', !$has($listed, $slug('E2E Sitemap Traduction')));
            $check('a private article is not listed', !$has($listed, $slug('E2E Sitemap Private')));
            $check('a knowledgebase category is in the sitemap', $has($listed, $slug('E2E Sitemap Topic')));
            $check('its translation row is not listed', !$has($listed, $slug('E2E Sitemap Sujet')));
            $check('a hidden knowledgebase category is not listed', !$has($listed, $slug('E2E Sitemap Secret Topic')));
            $check('a download category is in the sitemap when downloads are on', $has($listed, $slug('E2E Sitemap Files')));
            $check('a hidden download category is not', !$has($listed, $slug('E2E Sitemap Secret Files')));
            $check('no address is listed twice', count($listed) === count(array_unique($listed)));

            // ---- when the files are written --------------------------------
            // A site that never set the sitemap up, with a sitemap.xml of its own.
            $foreign = '<?xml version="1.0" encoding="UTF-8"?>' . "\n"
                . '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' . "\n"
                . '  <url><loc>https://example.test/kept-by-hand</loc></url>' . "\n" . '</urlset>' . "\n";
            DB::table('hadrian_settings')->where('setting', SETTING)->delete();
            $put($sitemap, $foreign);
            $put($robots, null);
            $check('nothing is written before the sitemap is set up', SitemapGenerator::refresh($tpl) === false
                && $read($sitemap) === $foreign && $read($robots) === null);

            // Set up: Save on the Sitemap tab.
            SitemapGenerator::saveConfig(SitemapGenerator::defaults());
            $check('once set up, a refresh writes the files', SitemapGenerator::refresh($tpl) === true);
            $first = (string) $read($sitemap);
            $check('entries that were already in sitemap.xml are kept', $has($urls($first), 'kept-by-hand'));
            $check('robots.txt points at the sitemap', str_contains((string) $read($robots), 'Sitemap: '));
            $again = [SitemapGenerator::refresh($tpl), SitemapGenerator::refresh($tpl)];
            $check('with nothing changed, a refresh writes nothing', $again === [false, false] && $read($sitemap) === $first,
                json_encode($again) . ' ' . strlen($first) . ' -> ' . strlen((string) $read($sitemap)));

            // A page switched to "do not index", as saving it in Pages does.
            foreach (Page::forSitemap($tpl) as $row) {
                if ((string) $row['url'] !== '' && !ExtensionPages::owns((string) $row['page'])) {
                    $page = $row;
                    break;
                }
            }
            if ($page === null) {
                $check('a theme page with an address exists to test with', false);
            } else {
                $pageBefore = (string) $page['indexing'];
                $path = ltrim((string) $page['url'], '/');
                Page::upsert($tpl, (string) $page['page'], ['indexing' => 'disallow']);
                $check('a page set to "do not index" triggers a rewrite', SitemapGenerator::refresh($tpl) === true, $path);
                $check('it leaves the sitemap', !in_array(rtrim($systemUrl, '/') . '/' . $path, $urls($read($sitemap)), true), $path);
                $check('and robots.txt disallows it', (bool) preg_match('#^Disallow: /' . preg_quote($path, '#') . '$#m', (string) $read($robots)), $path);
                Page::upsert($tpl, (string) $page['page'], ['indexing' => $pageBefore]);
                SitemapGenerator::refresh($tpl);
                $check('allowed again, it is back', in_array(rtrim($systemUrl, '/') . '/' . $path, $urls($read($sitemap)), true), $path);
            }

            // A module's page, as Hadrian Page Builder reports its pages.
            $live = true;
            $rows = [['id' => 987001, 'name' => 'E2E Sitemap Module Page', 'url' => 'e2e-sitemap-module-page', 'live' => true]];
            ExtensionPages::register(['id' => 'sitemaptest', 'prefix' => 'smtest', 'label' => 'Sitemap test', 'provider' => static function () use (&$rows, &$live): array {
                return array_map(static fn(array $r): array => ['live' => $live] + $r, $rows);
            }]);
            $sync = static function () use ($template): void {
                ExtensionPages::refresh();
                PageRegistry::syncExtensionPages($template);
            };
            $sync();
            $check('a module publishing a page puts it in the sitemap', $has($urls($read($sitemap)), 'e2e-sitemap-module-page'));
            clearstatcache();
            $stamp = (string) $read($sitemap);
            $sync();
            $check('syncing again with nothing changed leaves the file alone', $read($sitemap) === $stamp);
            $live = false;
            $sync();
            $check('unpublished, it leaves the sitemap', !$has($urls($read($sitemap)), 'e2e-sitemap-module-page'));
            $live = true;
            $sync();
            $rows = [];
            $sync();
            $check('deleted, it leaves the sitemap and the registry', !$has($urls($read($sitemap)), 'e2e-sitemap-module-page') && Page::get($tpl, 'smtest-987001') === null);

            // WHMCS content: an announcement saved in WHMCS's own admin screen.
            $annId = (int) DB::table('tblannouncements')->insertGetId([
                'date' => $now, 'title' => 'E2E Sitemap News', 'announcement' => 'Test.', 'published' => 1,
                'parentid' => 0, 'language' => '', 'created_at' => $now, 'updated_at' => $now,
            ]);
            $made['ann'] = [$annId];
            $check('a new announcement is not in the file until WHMCS says it was saved', !$has($urls($read($sitemap)), $slug('E2E Sitemap News')));
            run_hook('AnnouncementAdd', ['announcementid' => $annId, 'title' => 'E2E Sitemap News', 'announcement' => 'Test.', 'published' => 1]);
            $check('saving an announcement puts it in the sitemap', $has($urls($read($sitemap)), $slug('E2E Sitemap News')));
            // The daily cron picks up what WHMCS has no hook for. Running every
            // module's cron hook here would do far more than this test should,
            // and WHMCS does not expose its hook list, so this reads the
            // source: the cron is handed the very callback proven just above.
            $source = (string) file_get_contents(ROOTDIR . '/modules/addons/Hadrian/hooks.php');
            $check('the daily cron is given the same refresh as an announcement',
                str_contains($source, "add_hook('AnnouncementAdd', 1, \$hadrianSitemapRefresh);")
                && str_contains($source, "add_hook('DailyCronJob', 1, \$hadrianSitemapRefresh);"));

            // Switched off: our block goes, the rest stays.
            SitemapGenerator::saveConfig(['enabled' => false] + SitemapGenerator::defaults());
            SitemapGenerator::refresh($tpl);
            $off = $urls($read($sitemap));
            $check('switched off, only the entries kept by hand remain', $off === ['https://example.test/kept-by-hand'], json_encode(array_slice($off, 0, 4)));
            $check('and robots.txt stops pointing at the sitemap', !str_contains((string) $read($robots), 'Sitemap: '));
        } catch (\Throwable $e) {
            $check('the checks ran to the end', false, $e->getMessage() . ' at ' . basename($e->getFile()) . ':' . $e->getLine());
        } finally {
            if ($page !== null && $pageBefore !== null) {
                Page::upsert($tpl, (string) $page['page'], ['indexing' => $pageBefore]);
            }
            Page::delete($tpl, 'smtest-987001');
            if ($made['groups'] !== []) {
                DB::table('tblproductgroups')->whereIn('id', $made['groups'])->delete();
            }
            if ($made['kb'] !== []) {
                DB::table('tblknowledgebase')->whereIn('id', $made['kb'])->delete();
            }
            if (!empty($made['ann'])) {
                DB::table('tblannouncements')->whereIn('id', $made['ann'])->delete();
            }
            if (!empty($made['kbcats'])) {
                DB::table('tblknowledgebasecats')->whereIn('id', $made['kbcats'])->delete();
            }
            if (!empty($made['dlcats'])) {
                DB::table('tbldownloadcats')->whereIn('id', $made['dlcats'])->delete();
            }
            $restore($state);
        }
        echo json_encode($out);
        break;

    default:
        fwrite(STDERR, "Unknown command: {$command}\n");
        exit(1);
}
