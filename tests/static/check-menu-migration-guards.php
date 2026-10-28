<?php
/**
 * Guard tests for Seeder::migrateCustomLinksToWhmcsPages().
 *
 * Runs the REAL method against stubbed Eloquent models, so the conditions
 * under test are the shipped ones -- not a paraphrase of them. WhmcsDefaults
 * and MenuPages are the real files too, which is the point: the "is this page
 * offered by the picker" guard reads MenuPages::ELIGIBLE, so adding a page to
 * the picker automatically changes what this test expects, and a mismatch
 * shows up here rather than in a buyer's menu.
 *
 *   php tests/static/check-menu-migration-guards.php
 */

/* ------------------------------------------------------- stubbed models --
   Braced namespaces, so no statement may precede the first one. */
namespace Hadrian\Models {
    class Menu {}

    class MenuItem
    {
        /** @var self[] */
        public static array $rows = [];
        public static array $saved = [];

        public string $item_type   = 'custom_link';
        public string $config_json = '{}';
        public $id = 1;

        public static function where(string $col, string $val): self
        {
            // The real query filters by item_type; mirror that so a stale row
            // left behind by a previous pass is not silently re-offered.
            $q = new self();
            $q->item_type = $val;
            return $q;
        }

        public function get(): array
        {
            return array_values(array_filter(self::$rows, fn ($r) => $r->item_type === $this->item_type));
        }

        public function config(): array
        {
            $raw = json_decode($this->config_json, true);
            return is_array($raw) ? $raw : [];
        }

        public function save(): bool
        {
            self::$saved[] = $this->id;
            return true;
        }
    }
}

namespace {

use Hadrian\Models\MenuItem;

$SRC = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src';
require $SRC . '/Menu/WhmcsDefaults.php';
require $SRC . '/Menu/MenuPages.php';
require $SRC . '/Menu/Seeder.php';

function row(int $id, array $config): MenuItem
{
    $r = new MenuItem();
    $r->id = $id;
    $r->item_type = 'custom_link';
    $r->config_json = json_encode($config, JSON_FORCE_OBJECT);
    return $r;
}

/** case => [config, should convert?, why] */
$cases = [
    'eligible page, plain'        => [['url' => 'clientarea.php?action=services'], true,  'the whole point'],
    'eligible page, tickets'      => [['url' => 'supporttickets.php'],             true,  'alias page, first-wins'],
    'store page (not in picker)'  => [['url' => 'store/ssl-certificates'],         false, 'drawer could not re-point it'],
    // Three pages declare this URL -- user-password, changepassword, changepw --
    // and first-wins picks user-password, which IS in the picker. So it
    // converts, and correctly. Kept as a case precisely because it looks like
    // it should be skipped: two of its three claimants are unpickable.
    'changepw -> user-password'   => [['url' => 'clientarea.php?action=changepw'], true, 'first-wins lands on a pickable page'],
    'opens in new tab'            => [['url' => 'clientarea.php?action=services', 'target' => '_blank'], false, 'no control left to turn it off'],
    'cart deeplink'               => [['url' => 'cart.php?gid=vps'],               false, 'not a WHMCS page'],
    'masspay with extra param'    => [['url' => 'clientarea.php?action=masspay&all=true'], false, 'not an exact match'],
    'site root'                   => [['url' => '/'],                              false, "'/' excluded from the lookup"],
    'external'                    => [['url' => 'https://example.com'],            false, 'not a WHMCS page'],
    'empty url'                   => [['url' => ''],                               false, 'nothing to match'],
    'no url key'                  => [['icon' => 'server'],                        false, 'nothing to match'],
    'whitespace around a match'   => [['url' => '  clientarea.php?action=domains  '], true, 'trim() is deliberate'],
];

$rows = [];
$i = 0;
foreach ($cases as $name => [$config, , ]) { $rows[$name] = row(++$i, $config); }
MenuItem::$rows = array_values($rows);

$converted = (new Hadrian\Menu\Seeder())->migrateCustomLinksToWhmcsPages();

$fails = 0;
foreach ($cases as $name => [$config, $expect, $why]) {
    $r   = $rows[$name];
    $got = $r->item_type === 'whmcs_page';
    $ok  = $got === $expect;
    if (!$ok) { $fails++; }
    printf("%-5s %-28s %-9s %s\n", $ok ? 'ok' : 'FAIL', $name,
        $got ? 'converted' : 'left', $ok ? $why : "EXPECTED " . ($expect ? 'converted' : 'left'));
}

/* The promise the drawer makes: "Existing label / icon / URL values are kept
   in case you switch back." A converted item must still carry its url. */
$c = $rows['eligible page, plain']->config();
$urlKept  = ($c['url'] ?? null) === 'clientarea.php?action=services';
$pageSet  = ($c['page'] ?? null) === 'clientareaproducts';
printf("\n%-5s converted item keeps config.url  (%s)\n", $urlKept ? 'ok' : 'FAIL', var_export($c['url'] ?? null, true));
printf("%-5s converted item gains config.page (%s)\n",  $pageSet ? 'ok' : 'FAIL', var_export($c['page'] ?? null, true));
if (!$urlKept) { $fails++; }
if (!$pageSet) { $fails++; }

/* Idempotency: a second pass must convert nothing more. */
$second = (new Hadrian\Menu\Seeder())->migrateCustomLinksToWhmcsPages();
printf("%-5s second pass converts 0 (got %d)\n", $second === 0 ? 'ok' : 'FAIL', $second);
if ($second !== 0) { $fails++; }

$expectedConverted = count(array_filter($cases, fn ($c) => $c[1]));
printf("\nfirst pass converted %d (expected %d), %d failing\n", $converted, $expectedConverted, $fails);
exit($fails || $converted !== $expectedConverted ? 1 : 0);

}
