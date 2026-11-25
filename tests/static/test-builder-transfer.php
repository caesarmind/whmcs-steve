<?php
/**
 * Hadrian Page Builder: moving pages between sites, with no WHMCS and no
 * database.
 *
 * Covers the file a page travels in (PageFile), the walk that finds every
 * image and product on a page (Document::walk) and the part of an import that
 * is a pure function of the file (Importer::review, ::products, ::document).
 * Two stand-in sites play "where the pages came from" and "where they go".
 *
 * A pages file is something a stranger can make, so half of this is files
 * that lie: wrong format, a newer version, entries that walk out of the
 * folder, a script named like an image, sizes over the limits.
 *
 * What needs a real WHMCS (the upload, the review screen, pages written to
 * the database, images stored by Hadrian's media library) is in
 * tests/e2e/builder.spec.mjs; the library's own checks on a file that
 * arrives this way are in test-media.php.
 *
 *   php tests/static/test-builder-transfer.php
 */

declare(strict_types=1);

$root = dirname(__DIR__, 2);
require $root . '/hadrian_builder/modules/addons/HadrianBuilder/autoload.php';

use HadrianBuilder\Document;
use HadrianBuilder\Importer;
use HadrianBuilder\PageFile;
use HadrianBuilder\Replace;
use HadrianBuilder\Sections;
use HadrianBuilder\Site;

$ok = 0;
$fails = 0;
$section = '';
function check(string $label, bool $cond, string $detail = ''): void
{
    global $ok, $fails, $section;
    if ($cond) {
        $ok++;
        return;
    }
    $fails++;
    echo "FAIL  [{$section}] {$label}" . ($detail !== '' ? "\n      {$detail}" : '') . "\n";
}
function same(string $label, mixed $got, mixed $want): void
{
    check($label, $got === $want, 'got:  ' . json_encode($got) . "\n      want: " . json_encode($want));
}

if (!class_exists(ZipArchive::class) || !function_exists('imagecreatetruecolor')) {
    echo "SKIPPED: needs PHP's zip and gd extensions\n";
    exit(0);
}

// ------------------------------------------------------------ the fixture
$tmp = rtrim(str_replace('\\', '/', sys_get_temp_dir()), '/') . '/hadrian-transfer-test-' . bin2hex(random_bytes(4));
mkdir($tmp . '/sections/card', 0777, true);
mkdir($tmp . '/from', 0777, true);
mkdir($tmp . '/to', 0777, true);

// One section type with every kind of value that matters to a move.
file_put_contents($tmp . '/sections/card/card.php', '<?php return ' . var_export([
    'label'  => 'Card',
    'group'  => 'Test',
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'translatable' => true],
        ['key' => 'body', 'type' => 'rich', 'translatable' => true],
        ['key' => 'image', 'type' => 'image'],
        ['key' => 'plan', 'type' => 'product'],
        ['key' => 'cta', 'type' => 'link'],
        ['key' => 'items', 'type' => 'list', 'fields' => [
            ['key' => 'label', 'type' => 'text', 'translatable' => true],
            ['key' => 'photo', 'type' => 'image'],
            ['key' => 'plan', 'type' => 'product'],
        ]],
    ],
], true) . ';');
file_put_contents($tmp . '/sections/card/card.tpl', '<section></section>');
Sections::setDirs([$tmp . '/sections']);

$picture = static function (string $path, int $w, int $h): void {
    $im = imagecreatetruecolor($w, $h);
    imagefilledrectangle($im, 0, 0, $w, $h, (int)imagecolorallocate($im, $w % 255, $h % 255, 120));
    imagepng($im, $path);
};
$hero = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.png';
$team = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.png';
$gone = 'cccccccccccccccccccccccccccccccc.png';
$picture($tmp . '/from/' . $hero, 40, 30);
$picture($tmp . '/from/' . $team, 50, 20);

/** A site with a folder for a media library and a fixed product list. */
final class FakeSite extends Site
{
    /** @var list<string> every label an image was added under */
    public array $added = [];

    public function __construct(
        private string $dir,
        private string $web,
        private array $products,
        private array $languages = ['english', 'french'],
        private bool $media = true,
    ) {
    }

    public function languages(): array
    {
        return $this->languages;
    }

    public function products(): array
    {
        return $this->products;
    }

    public function movesMedia(): bool
    {
        return $this->media;
    }

    public function mediaNameIn(string $address): string
    {
        return preg_match('~/img/media/([A-Za-z0-9._-]+\.(?:png|jpe?g|gif|webp))$~', $address, $m) ? $m[1] : '';
    }

    public function mediaFile(string $name): ?array
    {
        return is_file($this->dir . '/' . $name) ? ['path' => $this->dir . '/' . $name, 'label' => 'Label of ' . $name, 'w' => 0, 'h' => 0] : null;
    }

    public function mediaUrl(string $name): string
    {
        return $this->web . '/img/media/' . $name;
    }

    public function mediaAdd(string $path, string $label): array
    {
        if (@getimagesize($path) === false) {
            return ['ok' => false, 'error' => 'File does not appear to be a real image.'];
        }
        $name = md5_file($path) . '.png';
        copy($path, $this->dir . '/' . $name);
        $this->added[] = $label;
        return ['ok' => true, 'name' => $name, 'url' => $this->mediaUrl($name), 'reused' => false];
    }
}

$from = new FakeSite($tmp . '/from', '/billing', [
    ['id' => 7, 'name' => 'Starter', 'group' => 'Shared hosting'],
    ['id' => 8, 'name' => 'Pro', 'group' => 'Shared hosting'],
    ['id' => 9, 'name' => 'Only there', 'group' => 'VPS'],
], ['english', 'french', 'german']);
$to = new FakeSite($tmp . '/to', '', [
    ['id' => 7, 'name' => 'Something else', 'group' => 'Domains'],
    ['id' => 21, 'name' => 'starter', 'group' => 'Shared Hosting'],
    ['id' => 22, 'name' => 'Pro', 'group' => 'Shared hosting'],
    ['id' => 23, 'name' => 'Pro', 'group' => 'Reseller'],
]);

$lib = static fn(string $name): string => '/billing/templates/hadrian/assets/img/media/' . $name;
$draft = Document::normalize(['sections' => [
    ['type' => 'card', 'props' => [
        'title' => ['_' => 'Fast hosting', 'french' => 'Rapide', 'german' => 'Schnell'],
        'body'  => ['_' => '<p>Hello</p>'],
        'image' => $lib($hero),
        'plan'  => 7,
        'cta'   => 'cart.php?gid=2',
        'items' => [
            ['label' => 'One', 'photo' => $lib($team), 'plan' => 8],
            ['label' => 'Two', 'photo' => 'https://cdn.example.com/x.png', 'plan' => 9],
            ['label' => 'Three', 'photo' => $lib($gone), 'plan' => 0],
        ],
    ]],
    ['type' => 'card', 'props' => ['title' => 'Second', 'image' => $lib($hero)]],
]]);
$target = (string)array_key_first(Replace::TARGETS);
$pages = [
    ['id' => 3, 'name' => 'Hosting', 'slug' => 'hosting', 'status' => 'published', 'replaces' => $target,
        'meta' => ['title' => ['_' => 'Hosting', 'german' => 'Hosting DE'], 'description' => 'Plans'], 'draft' => $draft],
    ['id' => 4, 'name' => 'About us', 'slug' => '', 'status' => 'draft', 'replaces' => '', 'meta' => [], 'draft' => Document::blank()],
];

// ------------------------------------------------------------------- walk
$section = 'walk';
$seen = [];
$walked = Document::walk($draft, static function (array $f, mixed $v, string $type) use (&$seen): mixed {
    $seen[] = $f['key'] . ':' . $f['type'];
    return $f['type'] === 'product' ? 99 : $v;
});
same('every value of a section is visited, list items one by one', array_slice($seen, 0, 14), [
    'title:text', 'body:rich', 'image:image', 'plan:product', 'cta:link',
    'label:text', 'photo:image', 'plan:product',
    'label:text', 'photo:image', 'plan:product',
    'label:text', 'photo:image', 'plan:product',
]);
same('what the visitor returns is put back, also inside a list', [$walked['sections'][0]['props']['plan'], $walked['sections'][0]['props']['items'][1]['plan']], [99, 99]);
same('everything else is as it was', $walked['sections'][0]['props']['title'], $draft['sections'][0]['props']['title']);
$odd = ['sections' => [['type' => 'no-such-type', 'props' => ['x' => 1]], 'not a section', ['type' => 'card', 'props' => 'not props'], ['type' => 'card', 'props' => ['items' => 'not a list', 'plan' => 5]]]];
$calls = 0;
$oddOut = Document::walk($odd, static function (array $f, mixed $v) use (&$calls): mixed {
    $calls++;
    return $v;
});
same('a document that is not well formed is walked without complaint', [$oddOut, $calls], [$odd, 1]);
same('one with no sections comes back as it was', Document::walk(['v' => 1], static fn($f, $v) => $v), ['v' => 1]);

// ------------------------------------------------------------------ build
$section = 'build';
$bundle = PageFile::build($pages, $from);
$m = json_decode(PageFile::json($bundle['manifest']), true);
same('it says what it is', [$m['format'], $m['version']], ['hadrian-pages', 1]);
same('both pages are in it, with their names and addresses', array_map(static fn($p) => [$p['name'], $p['slug'], $p['status']], $m['pages']), [['Hosting', 'hosting', 'published'], ['About us', '', 'draft']]);
same('what a page replaced is noted', $m['pages'][0]['replaces'], $target);
$props = $m['pages'][0]['doc']['sections'][0]['props'];
same('a library image is written by name', [$props['image'], $props['items'][0]['photo']], ['media:' . $hero, 'media:' . $team]);
same('a web address stays as typed', $props['items'][1]['photo'], 'https://cdn.example.com/x.png');
same('an image that is gone from the library stays as the address it had', $props['items'][2]['photo'], $lib($gone));
same('each image is listed once, with its label and hash', [array_keys($m['media']), $m['media'][$hero]['label'], $m['media'][$hero]['sha256']], [[$hero, $team], 'Label of ' . $hero, hash_file('sha256', $tmp . '/from/' . $hero)]);
same('and its file is named for the zip', $bundle['files'], [$hero => $tmp . '/from/' . $hero, $team => $tmp . '/from/' . $team]);
same('products keep their ids and say what they were called', [$props['plan'], $m['products']], [7, ['7' => ['name' => 'Starter', 'group' => 'Shared hosting'], '8' => ['name' => 'Pro', 'group' => 'Shared hosting'], '9' => ['name' => 'Only there', 'group' => 'VPS']]]);
same('every language the page holds goes along', $props['title'], ['_' => 'Fast hosting', 'french' => 'Rapide', 'german' => 'Schnell']);
same('a link is left alone', $props['cta'], 'cart.php?gid=2');
$plain = PageFile::build($pages, $from, false);
same('without a zip the images stay addresses and no files are listed', [$plain['manifest']['pages'][0]['doc']['sections'][0]['props']['image'], $plain['files'], (array)$plain['manifest']['media']], [$lib($hero), [], []]);
same('an empty media list is still an object in the file', str_contains(PageFile::json($plain['manifest']), '"media": {}'), true);
same('the download is named after the one page', PageFile::fileName([$pages[0]], true), 'hosting.hadrian-pages.zip');
same('or the date for several', PageFile::fileName($pages, false), 'pages-' . date('Y-m-d') . '.hadrian-pages.json');
same('a page with no address uses its name', PageFile::fileName([$pages[1]], true), 'about-us.hadrian-pages.zip');

// ---------------------------------------------------------- write and read
$section = 'zip round trip';
$zipPath = $tmp . '/pages.zip';
same('the zip is written', PageFile::writeZip($bundle, $zipPath), true);
$read = PageFile::read($zipPath);
same('and read back', [$read['ok'], $read['kind'], $read['error']], [true, 'zip', '']);
$manifest = $read['manifest'];
same('with the same pages', array_column($manifest['pages'], 'name'), ['Hosting', 'About us']);
same('the same document', $manifest['pages'][0]['doc'], $m['pages'][0]['doc']);
same('the images it lists', array_keys($manifest['media']), [$hero, $team]);
same('and the products, by id', array_keys($manifest['products']), [7, 8, 9]);
same('the zip holds the files it lists', PageFile::mediaIn($zipPath, array_keys($manifest['media'])), [$hero => true, $team => true]);
same('an image comes out as the bytes that went in', [PageFile::extractMedia($zipPath, $hero, $tmp . '/out.png'), hash_file('sha256', $tmp . '/out.png')], ['', $manifest['media'][$hero]['sha256']]);
same('one that is not in it says so', PageFile::extractMedia($zipPath, $gone, $tmp . '/out2.png'), 'it is not in the file');
same('(and writes nothing)', is_file($tmp . '/out2.png'), false);

$jsonPath = $tmp . '/pages.json';
file_put_contents($jsonPath, "\xEF\xBB\xBF" . PageFile::json($plain['manifest']));
$readJson = PageFile::read($jsonPath);
same('the description alone is a pages file too, byte order mark and all', [$readJson['ok'], $readJson['kind'], count($readJson['manifest']['pages'])], [true, 'json', 2]);

// -------------------------------------------------------------- bad files
$section = 'files that are not what they say';
$make = static function (string $name, array $entries) use ($tmp): string {
    $path = $tmp . '/' . $name;
    $zip = new ZipArchive();
    $zip->open($path, ZipArchive::CREATE | ZipArchive::OVERWRITE);
    foreach ($entries as $entry => $content) {
        $zip->addFromString($entry, $content);
    }
    $zip->close();
    return $path;
};
$good = static fn(array $over = []): string => json_encode($over + [
    'format' => 'hadrian-pages', 'version' => 1,
    'pages'  => [['name' => 'P', 'slug' => 'p', 'doc' => ['sections' => []]]],
]);
$error = static fn(string $path): string => PageFile::read($path)['error'];

same('a zip with no description', $error($make('none.zip', ['readme.txt' => 'hi'])), 'This is not a Hadrian pages file: it has no manifest.json.');
same('a description that is not JSON', $error($make('junk.zip', ['manifest.json' => '{not json'])), 'The description inside the file is not valid JSON.');
same('JSON of some other kind', $error($make('other.zip', ['manifest.json' => '{"format":"something-else","version":1}'])), 'This is not a Hadrian pages file. Choose a file exported from Pages.');
check('a file from a newer version is refused, and says to update', str_contains($error($make('newer.zip', ['manifest.json' => $good(['version' => 2])])), 'newer Hadrian Page Builder'));
same('a version that is not a number', $error($make('nover.zip', ['manifest.json' => $good(['version' => 'one'])])), 'This is not a Hadrian pages file. Choose a file exported from Pages.');
same('no pages', $error($make('empty.zip', ['manifest.json' => $good(['pages' => []])])), 'There are no pages in this file.');
same('pages that are not pages', $error($make('nopages.zip', ['manifest.json' => $good(['pages' => ['x', ['name' => 'no doc'], 7]])])), 'There are no pages in this file.');
file_put_contents($tmp . '/photo.zip', file_get_contents($tmp . '/from/' . $hero));
check('a picture renamed .zip', !PageFile::read($tmp . '/photo.zip')['ok']);
file_put_contents($tmp . '/blank.json', '');
same('an empty file', $error($tmp . '/blank.json'), 'The file is empty.');
same('a file that is not there', $error($tmp . '/nowhere.zip'), 'The file could not be read.');
file_put_contents($tmp . '/cut.zip', substr((string)file_get_contents($zipPath), 0, 200));
check('a zip cut short', !PageFile::read($tmp . '/cut.zip')['ok']);

$many = ['manifest.json' => $good()];
for ($i = 0; $i < 1300; $i++) {
    $many['media/f' . $i . '.png'] = 'x';
}
same('more entries than a pages file can have', $error($make('many.zip', $many)), 'The zip holds more files than a pages file can.');

// What the description says is cut down to what is known.
$hostile = $make('hostile.zip', [
    'manifest.json' => $good([
        'pages' => [[
            'name' => "Evil\x00 <script>\npage" . str_repeat('x', 300), 'slug' => '../../etc/passwd', 'status' => 'serving',
            'replaces' => '<img>', 'meta' => 'nope', 'doc' => ['sections' => []], 'published' => ['sections' => []], 'id' => 1,
        ]],
        'media' => [
            '../../evil.png' => [], 'shell.php' => [], '.htaccess' => [], 'a/b.png' => [], 'ok.png' => ['label' => ['x'], 'sha256' => 'nothex', 'bytes' => -4],
            'big.png' => ['label' => 'Big', 'sha256' => str_repeat('A', 64)], 'script.png' => [],
        ],
        'products' => ['0' => ['name' => 'zero'], '-3' => ['name' => 'neg'], 'abc' => ['name' => 'x'], '5' => 'not a product', '6' => ['name' => ['x'], 'group' => "G\nH"]],
        'settings' => ['admin' => true],
    ]),
    'media/../../evil.png' => 'x',
    '../outside.php'       => '<?php',
    'media/ok.png'         => (string)file_get_contents($tmp . '/from/' . $hero),
    'media/big.png'        => str_repeat("\0", 7 * 1024 * 1024),
    'media/script.png'     => '<?php echo "x";',
]);
$h = PageFile::read($hostile);
same('it opens: nothing in it is trusted, so nothing in it is fatal', $h['ok'], true);
$hp = $h['manifest']['pages'][0];
same('a page keeps only the keys a page has', array_keys($hp), ['name', 'slug', 'status', 'replaces', 'meta', 'doc']);
same('its name is one clean line of bounded length', [str_starts_with($hp['name'], 'Evil <script> page'), mb_strlen($hp['name'])], [true, 120]);
same('an address that walks is no address', $hp['slug'], '');
same('a status it could not have is a draft; a target that is not one is none; meta that is not a map is empty', [$hp['status'], $hp['replaces'], $hp['meta']], ['draft', '', []]);
same('only names shaped like a library image are listed', array_keys($h['manifest']['media']), ['ok.png', 'big.png', 'script.png']);
same('with a label, hash and size of the right kind', $h['manifest']['media']['ok.png'], ['label' => '', 'sha256' => '', 'bytes' => 0]);
same('(a hash is compared in lower case)', $h['manifest']['media']['big.png']['sha256'], str_repeat('a', 64));
same('only real product ids are kept', $h['manifest']['products'], [6 => ['name' => '', 'group' => 'G H']]);
same('keys it does not know are gone', array_keys($h['manifest']), ['version', 'builder', 'exported', 'pages', 'media', 'products']);
same('an entry is only ever asked for by a checked name', [
    PageFile::extractMedia($hostile, '../../evil.png', $tmp . '/x1'),
    PageFile::extractMedia($hostile, '../outside.php', $tmp . '/x2'),
    PageFile::extractMedia($hostile, 'shell.php', $tmp . '/x3'),
    PageFile::extractMedia($hostile, 'a/ok.png', $tmp . '/x4'),
], array_fill(0, 4, 'not an image name'));
same('an image over the size limit is not unpacked', [PageFile::extractMedia($hostile, 'big.png', $tmp . '/big.out'), is_file($tmp . '/big.out')], ['it is too large', false]);
same('the zip is asked what it holds, not what it claims', PageFile::mediaIn($hostile, ['ok.png', 'big.png', 'missing.png', '../../evil.png']), ['ok.png' => true, 'big.png' => true]);
foreach (['x1', 'x2', 'x3', 'x4'] as $x) {
    check('nothing was written for a refused name (' . $x . ')', !file_exists($tmp . '/' . $x));
}
check('nothing was written outside the folder', !file_exists(dirname($tmp) . '/outside.php') && !file_exists(dirname($tmp, 2) . '/evil.png'));

// --------------------------------------------------------------- products
$section = 'matching products';
$map = Importer::products($manifest, $to);
same('the same number is not the same product: it goes by name', $map[7], 21);
same('a name two products share is settled by the group', $map[8], 22);
same('a product this site does not sell is no product', $map[9], 0);
$same = Importer::products(['products' => [22 => ['name' => 'PRO ', 'group' => 'whatever']]], $to);
same('the same id with the same name is kept (a file from this site)', $same[22], 22);
$ambiguous = Importer::products(['products' => [50 => ['name' => 'Pro', 'group' => 'Nowhere'], 51 => ['name' => '', 'group' => '']]], $to);
same('a shared name with no matching group, or no name at all, is no product', $ambiguous, [50 => 0, 51 => 0]);

// ----------------------------------------------------------------- review
$section = 'review';
$existing = [['id' => 30, 'name' => 'hosting ', 'slug' => 'plans'], ['id' => 31, 'name' => 'Other', 'slug' => 'hosting'], ['id' => 32, 'name' => 'Unrelated', 'slug' => 'x']];
$review = Importer::review($manifest, $existing, PageFile::mediaIn($zipPath, array_keys($manifest['media'])), $to);
same('one report per page', array_column($review, 'name'), ['Hosting', 'About us']);
$r = $review[0];
same('its sections and images are counted', [$r['sections'], $r['images'], $r['missing'], $r['linked']], [2, 2, 0, 2]);
same('a product with no match is named', $r['products'], ['Only there']);
same('a language this site lacks is named, once', $r['languages'], ['german']);
same('what it replaced is told in words', $r['replaces'], Replace::TARGETS[$target]);
same('pages here it could be mistaken for: the one at its address first', array_map(static fn($x) => [$x['id'], $x['why']], $r['matches']), [[31, 'address'], [30, 'name']]);
same('a page that resembles nothing has no matches', $review[1]['matches'], []);

$strange = PageFile::clean(json_decode($good(['pages' => [['name' => 'S', 'slug' => 's', 'doc' => ['sections' => array_merge(
    [['type' => 'pricing-xl'], ['type' => 'pricing-xl'], ['type' => '<b>'], 'junk',
        ['type' => 'card', 'props' => ['image' => 'media:nowhere.png', 'plan' => 4, 'items' => [['photo' => 'media:../x.png']]]]],
    array_fill(0, Document::maxSections() + 9, ['type' => 'card'])
)]]]]), true))['manifest'];
$sr = Importer::review($strange, [], [], $to)[0];
same('section types this site lacks are counted by name', $sr['unknown'], ['pricing-xl' => 2, 'b' => 1, 'unnamed' => 1]);
same('sections past the limit of a page are counted', [$sr['sections'], $sr['over']], [Document::maxSections(), 10]);
same('images the file names but does not hold are counted as missing', [$sr['images'], $sr['missing']], [0, 2]);
same('a product the file says nothing about is unmatched', $sr['products'], ['a product with no name in the file']);

// --------------------------------------------------------------- document
$section = 'the document that is stored';
$urls = [$hero => '/img/media/new-hero.png', $team => ''];
$doc = Importer::document($manifest['pages'][0]['doc'], $urls, $map, $to->languages());
$p = $doc['sections'][0]['props'];
same('an image points at this site\'s copy', $p['image'], '/img/media/new-hero.png');
same('one that could not be brought in leaves its field empty', $p['items'][0]['photo'], '');
same('a web address is kept', $p['items'][1]['photo'], 'https://cdn.example.com/x.png');
same('products are this site\'s', [$p['plan'], $p['items'][0]['plan'], $p['items'][1]['plan'], $p['items'][2]['plan']], [21, 22, 0, 0]);
same('text in a language this site lacks is left out', $p['title'], ['_' => 'Fast hosting', 'french' => 'Rapide']);
same('the second section uses the same copy of the image', $doc['sections'][1]['props']['image'], '/img/media/new-hero.png');

$dirty = Importer::document(['sections' => [
    ['type' => 'card', 'id' => 'not-an-id', 'hidden' => 'yes', 'style' => ['spacing' => 'huge', 'anchor' => '"><script>'], 'props' => [
        'title' => "Hi\x00 there", 'body' => '<p onclick="x()">Text<script>alert(1)</script><img src=x onerror=y></p>',
        'image' => 'javascript:alert(1)', 'plan' => '7; DROP TABLE', 'cta' => 'javascript:alert(1)', 'extra' => 'dropped',
        'items' => [['label' => ['_' => 'A', 'klingon' => 'B'], 'photo' => 'media:' . $hero . '/../../x', 'plan' => 7]],
    ]],
    ['type' => 'card', 'props' => ['plan' => 22]],
    ['type' => 'gone'],
]], $urls, $map, $to->languages());
$d = $dirty['sections'][0];
same('a section type this site lacks is left out', count($dirty['sections']), 2);
same('markup is cleaned the way a save cleans it', $d['props']['body'], ['_' => '<p>Text</p>']);
same('an image or a link that would run script is emptied', [$d['props']['image'], $d['props']['cta']], ['', '']);
same('a product id is a number that was matched, or nothing', [$d['props']['plan'], $d['props']['items'][0]['plan']], [0, 21]);
same('an id the file gives no name for is never trusted', $dirty['sections'][1]['props']['plan'], 0);
same('a media value that is not a plain file name is no image', $d['props']['items'][0]['photo'], '');
same('fields the section does not have are gone', array_key_exists('extra', $d['props']), false);
same('style and id are the section\'s own again', [$d['style'], (bool)preg_match('/^s[a-f0-9]{10}$/', $d['id'])], [['spacing' => 'regular', 'anchor' => ''], true]);

// ---------------------------------------------------------------- cleanup
$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($tmp, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
foreach ($it as $f) {
    $f->isDir() ? @rmdir($f->getPathname()) : @unlink($f->getPathname());
}
@rmdir($tmp);

echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
exit($fails ? 1 : 0);
