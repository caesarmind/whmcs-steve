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
 *   php tests/php/builder.php registry <id>
 *       JSON: the built page's row in Hadrian's page registry (the Pages
 *       screen), and whether the sitemap would list it. null when it has none.
 *   php tests/php/builder.php mode [theme|builder]
 *       JSON: the "Website served by" setting. With a value, set it first.
 *   php tests/php/builder.php products
 *       JSON: the first three products an admin can pick, with the price a
 *       price card should show for each.
 *   php tests/php/builder.php seed <name> [slug]
 *       Make a draft page holding one library image and one product. JSON:
 *       its id, the image's file name and address, the product id.
 *   php tests/php/builder.php doc <id>
 *       JSON: one page as stored (status, draft, published).
 *   php tests/php/builder.php file <path>
 *       JSON: what a pages file holds, as the importer reads it.
 *   php tests/php/builder.php media <name> [drop]
 *       JSON: whether that library image is on disk. With "drop", remove it
 *       first (only an image labelled "E2E ...").
 *
 * Refuses unless SystemURL is localhost: `clean` deletes rows and the library
 * images labelled "E2E ...".
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
        $ids = DB::schema()->hasTable(TABLE) ? DB::table(TABLE)->where('name', 'like', 'E2E %')->pluck('id')->all() : [];
        $n   = $ids === [] ? 0 : DB::table(TABLE)->whereIn('id', $ids)->delete();
        // Their rows in Hadrian's page registry go with them. Deleting a page
        // in the admin does this itself; this helper goes round the admin.
        if ($ids !== [] && DB::schema()->hasTable('hadrian_pages')) {
            DB::table('hadrian_pages')->whereIn('page', array_map(static fn($id) => 'built-' . (int) $id, $ids))->delete();
        }
        // And the library images the tests brought with them.
        $images = 0;
        foreach (Hadrian\Helpers\MediaLibrary::manifest('library') as $stored => $entry) {
            if (is_array($entry) && str_starts_with((string) ($entry['label'] ?? ''), 'E2E ')) {
                $file = Hadrian\Helpers\MediaLibrary::file((string) $stored);
                if ($file !== null) {
                    unlink($file['path']);
                }
                Hadrian\Helpers\MediaLibrary::forget('library', (string) $stored);
                $images++;
            }
        }
        echo json_encode(['removed' => $n, 'images' => $images]);
        break;

    case 'registry':
        $key = 'built-' . (int) ($argv[2] ?? 0);
        $row = DB::schema()->hasTable('hadrian_pages')
            ? DB::table('hadrian_pages')->where('page', $key)->first(['template', 'page', 'url', 'page_group', 'published', 'visibility', 'indexing'])
            : null;
        if ($row === null) {
            echo json_encode(null);
            break;
        }
        // The sitemap's own row source. Its rows carry the address, not the
        // page key, and a built page's address is its own.
        $listed = array_column(Hadrian\Models\Page::forSitemap((string) $row->template), 'url');
        echo json_encode([
            'page'       => $row->page,
            'url'        => $row->url,
            'group'      => $row->page_group,
            'published'  => (bool) $row->published,
            'visibility' => $row->visibility,
            'inSitemap'  => $row->url !== null && in_array((string) $row->url, $listed, true),
        ]);
        break;

    case 'mode':
        if (isset($argv[2])) {
            HadrianBuilder\Replace::setMode((string) $argv[2]);
        }
        echo json_encode(['mode' => HadrianBuilder\Replace::mode()]);
        break;

    case 'products':
        $out = [];
        foreach (array_slice(HadrianBuilder\Catalog::options(), 0, 3) as $option) {
            $data  = (new HadrianBuilder\Catalog())->products([$option['id']])[$option['id']] ?? null;
            $out[] = ['id' => $option['id'], 'name' => $option['name'], 'price' => $data['price'] ?? '', 'free' => $data['free'] ?? false];
        }
        echo json_encode($out);
        break;

    case 'seed':
        // A draft page with one library image and one product on it, made
        // without the editor: the starting point for export and import.
        $name = (string) ($argv[2] ?? 'E2E Seeded');
        $slug = (string) ($argv[3] ?? '');
        $png  = tempnam(sys_get_temp_dir(), 'hbt');
        $im   = imagecreatetruecolor(64, 48);
        // Different pixels every run, so the library never already has it.
        imagefilledrectangle($im, 0, 0, 64, 48, (int) imagecolorallocate($im, random_int(0, 255), random_int(0, 255), random_int(0, 255)));
        imagesetpixel($im, random_int(0, 63), random_int(0, 47), (int) imagecolorallocate($im, random_int(0, 255), random_int(0, 255), random_int(0, 255)));
        imagepng($im, $png);
        $image = Hadrian\Helpers\MediaLibrary::add($png, 'E2E seeded image');
        unlink($png);
        if (empty($image['ok'])) {
            fwrite(STDERR, 'Could not store the image: ' . ($image['error'] ?? '?') . "\n");
            exit(4);
        }
        $product  = HadrianBuilder\Catalog::options()[0]['id'] ?? 0;
        $sections = [];
        $used     = ['image' => '', 'product' => ''];
        foreach (HadrianBuilder\Sections::types() as $type => $def) {
            foreach ($def['fields'] as $f) {
                if (isset($used[$f['type']]) && $used[$f['type']] === '') {
                    $used[$f['type']] = $type . '.' . $f['key'];
                    $section = HadrianBuilder\Document::make($type);
                    $section['props'][$f['key']] = $f['type'] === 'image' ? $image['url'] : $product;
                    $sections[] = $section;
                    break;
                }
            }
        }
        $id = HadrianBuilder\Page::create([
            'name'  => $name,
            'slug'  => $slug,
            'meta'  => HadrianBuilder\Document::normalizeMeta(['title' => $name]),
            'draft' => HadrianBuilder\Document::normalize(['sections' => $sections]),
        ]);
        HadrianBuilder\Bridge::pagesChanged();
        echo json_encode(['id' => $id, 'image' => $image['name'], 'imageUrl' => $image['url'], 'product' => $product, 'fields' => $used]);
        break;

    case 'doc':
        // JSON: one page as stored (status, draft, published).
        $page = HadrianBuilder\Page::find((int) ($argv[2] ?? 0));
        echo json_encode($page === null ? null : [
            'name' => $page['name'], 'slug' => $page['slug'], 'status' => $page['status'],
            'replaces' => $page['replaces'] ?? '', 'draft' => $page['draft'], 'published' => $page['published'],
        ]);
        break;

    case 'file':
        // JSON: what a pages file holds, as the importer reads it.
        $read = HadrianBuilder\PageFile::read((string) ($argv[2] ?? ''));
        echo json_encode($read['ok'] ? [
            'ok'    => true,
            'kind'  => $read['kind'],
            'pages' => array_map(static fn($p) => ['name' => $p['name'], 'slug' => $p['slug'], 'sections' => count($p['doc']['sections'] ?? [])], $read['manifest']['pages']),
            'media' => array_keys($read['manifest']['media']),
            'inZip' => array_keys(HadrianBuilder\PageFile::mediaIn((string) $argv[2], array_keys($read['manifest']['media']))),
            'products' => $read['manifest']['products'],
            'text'  => json_encode($read['manifest']['pages']),
        ] : ['ok' => false, 'error' => $read['error']]);
        break;

    case 'media':
        // media <name>          JSON: is this library image on disk?
        // media <name> drop     remove it first (only an image these tests made)
        $name = (string) ($argv[2] ?? '');
        $file = Hadrian\Helpers\MediaLibrary::file($name);
        if (($argv[3] ?? '') === 'drop' && $file !== null && str_starts_with($file['label'], 'E2E ')) {
            unlink($file['path']);
            Hadrian\Helpers\MediaLibrary::forget('library', $name);
            $file = null;
        }
        echo json_encode(['exists' => $file !== null, 'label' => $file['label'] ?? '']);
        break;

    default:
        fwrite(STDERR, "Unknown command: {$command}\n");
        exit(1);
}
