<?php
/**
 * Test helper for Hadrian Page Builder (a separate addon module, mounted from
 * hadrian_builder/). Used by tests/e2e/builder.spec.mjs.
 *
 *   php tests/php/builder.php state
 *       JSON: every built page (id, slug, name, status).
 *   php tests/php/builder.php clean
 *       Delete the pages the tests made: any whose name starts with "E2E ".
 *       JSON: how many were removed.
 *   php tests/php/builder.php products
 *       JSON: the first three products an admin can pick, with the price a
 *       price card should show for each.
 *
 * Refuses unless SystemURL is localhost: `clean` deletes rows.
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

$autoload = $whmcsRoot . '/modules/addons/HadrianBuilder/autoload.php';
if (!is_file($autoload)) {
    fwrite(STDERR, "Hadrian Page Builder is not mounted at {$autoload}.\n");
    exit(3);
}
require_once $autoload;

const TABLE = 'hadrian_builder_pages';

$command = $argv[1] ?? 'state';

switch ($command) {
    case 'state':
        $rows = DB::schema()->hasTable(TABLE)
            ? DB::table(TABLE)->orderBy('id')->get(['id', 'slug', 'name', 'status'])->all()
            : [];
        echo json_encode(array_map(static fn($r) => (array) $r, $rows));
        break;

    case 'clean':
        $n = DB::schema()->hasTable(TABLE) ? DB::table(TABLE)->where('name', 'like', 'E2E %')->delete() : 0;
        echo json_encode(['removed' => $n]);
        break;

    case 'products':
        $out = [];
        foreach (array_slice(HadrianBuilder\Catalog::options(), 0, 3) as $option) {
            $data  = (new HadrianBuilder\Catalog())->products([$option['id']])[$option['id']] ?? null;
            $out[] = ['id' => $option['id'], 'name' => $option['name'], 'price' => $data['price'] ?? '', 'free' => $data['free'] ?? false];
        }
        echo json_encode($out);
        break;

    default:
        fwrite(STDERR, "Unknown command: {$command}\n");
        exit(1);
}
