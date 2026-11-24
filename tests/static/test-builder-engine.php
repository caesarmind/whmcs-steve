<?php
/**
 * Hadrian Page Builder: the engine, with no WHMCS and no database.
 *
 * The module lives in hadrian_builder/ (a separate addon). Everything here is
 * a pure function of its input: text and link cleaning, the rich-text
 * sanitiser, the section catalogue, document validation and the renderer
 * (with a stand-in product catalogue). What needs a real WHMCS (routing,
 * saving, publishing, live prices) is in tests/e2e/builder.spec.mjs.
 *
 *   php tests/static/test-builder-engine.php
 */

declare(strict_types=1);

$root = dirname(__DIR__, 2);
require __DIR__ . '/vendor/autoload.php';       // Smarty, as the other static checkers use it
require $root . '/hadrian_builder/modules/addons/HadrianBuilder/autoload.php';

use HadrianBuilder\Catalog;
use HadrianBuilder\Document;
use HadrianBuilder\Icons;
use HadrianBuilder\Renderer;
use HadrianBuilder\Sanitizer;
use HadrianBuilder\Sections;
use HadrianBuilder\Text;

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

$sectionsDir = $root . '/hadrian_builder/modules/addons/HadrianBuilder/sections';
Sections::setDirs([$sectionsDir]);

$compileDir = sys_get_temp_dir() . '/hadrian-builder-test-' . getmypid();
$langs = ['english', 'french', 'arabic'];

/** A catalogue that never touches WHMCS. */
$catalog = new class {
    public int $calls = 0;
    public function products(array $ids): array
    {
        $this->calls++;
        $all = [
            7 => ['id' => 7, 'name' => 'Starter <b>', 'tagline' => 'For one site', 'features' => ['10 GB storage', 'Free SSL'],
                'free' => false, 'price' => '$4.00', 'per' => '/mo', 'orderUrl' => 'cart.php?a=add&pid=7'],
            8 => ['id' => 8, 'name' => 'Free tier', 'tagline' => '', 'features' => [], 'free' => true, 'price' => '', 'per' => '',
                'orderUrl' => 'cart.php?a=add&pid=8'],
        ];
        return array_intersect_key($all, array_flip($ids));
    }
};
$ctx = ['lang' => 'english', 'webRoot' => '/billing', 'languages' => $langs, 'catalog' => $catalog, 'compileDir' => $compileDir];

// ------------------------------------------------------------------- Text
$section = 'text';
same('a default is used when the language has no text', Text::pick(['_' => 'Hello', 'french' => ''], 'french'), 'Hello');
same('a translation wins over the default', Text::pick(['_' => 'Hello', 'french' => 'Bonjour'], 'french'), 'Bonjour');
same('a plain string is its own value', Text::pick('Hi', 'french'), 'Hi');
same('slug: spaces and case are cleaned', Text::slug('  About Us '), 'about-us');
same('slug: nested paths are allowed', Text::slug('/hosting/wordpress/'), 'hosting/wordpress');
same('slug: a file name is refused', Text::slug('index.php'), '');
same('slug: traversal is refused', Text::slug('../admin'), '');
same('slug: too deep is refused', Text::slug('a/b/c/d'), '');
same('link: a script URL is refused', Text::link('javascript:alert(1)'), '');
same('link: a data URL is refused', Text::link(' data:text/html,x'), '');
same('link: a protocol-relative URL is refused', Text::link('//evil.example/x'), '');
same('link: a WHMCS path is kept as typed', Text::link('cart.php?a=add&pid=3'), 'cart.php?a=add&pid=3');
same('link: an anchor is kept', Text::link('#pricing'), '#pricing');
same('link: a bare domain becomes a web address', Text::link('example.com/pricing'), 'https://example.com/pricing');
same('link: a quote cannot break out of the attribute', Text::link('x" onmouseover="y'), '');
same('image: only web or root paths', [Text::image('/img/a.png'), Text::image('https://x.test/a.png'), Text::image('a.png'), Text::image('//x/a.png')],
    ['/img/a.png', 'https://x.test/a.png', '', '']);
same('anchor: a leading # is dropped', Text::anchor('#Pricing'), 'pricing');
same('anchor: something that is not an id is refused', Text::anchor('1 2'), '');
same('href: a WHMCS path gets the install folder', Renderer::href('cart.php?gid=2', '/billing'), '/billing/cart.php?gid=2');
same('href: at a domain root it gets a slash', Renderer::href('contact.php', ''), '/contact.php');
same('href: anchors and absolute links are left alone', [Renderer::href('#x', '/b'), Renderer::href('https://a.test', '/b'), Renderer::href('/x', '/b')], ['#x', 'https://a.test', '/x']);

// -------------------------------------------------------------- Sanitizer
$section = 'sanitizer';
$dirty = '<p onclick="x()">Hi <b>there</b><script>alert(1)</script> <a href="javascript:x">bad</a> <a href="https://a.test" style="color:red">ok</a></p><img src=x onerror=y><iframe src="z"></iframe>';
$clean = Sanitizer::rich($dirty);
check('script and iframe are gone with their content', !str_contains($clean, 'script') && !str_contains($clean, 'iframe') && !str_contains($clean, 'alert'));
check('event handlers and styles are gone', !str_contains($clean, 'onclick') && !str_contains($clean, 'onerror') && !str_contains($clean, 'style='));
check('a script link loses its href but keeps its text', !str_contains($clean, 'javascript') && str_contains($clean, 'bad'));
check('a web link survives', str_contains($clean, '<a href="https://a.test" rel="noopener">ok</a>'), $clean);
check('bold is normalised', str_contains($clean, '<strong>there</strong>'));
same('loose text becomes a paragraph', Sanitizer::rich('just text'), '<p>just text</p>');
same('a heading too large for a section body is demoted to a paragraph', Sanitizer::rich('<h1>Big</h1>'), '<p>Big</p>');
same('empty stays empty', Sanitizer::rich('   '), '');

// ------------------------------------------------------------------ Icons
$section = 'icons';
foreach (Icons::all() as $name => $svg) {
    check("{$name}: is one svg element with no script", str_starts_with($svg, '<svg ') && str_ends_with($svg, '</svg>') && substr_count($svg, '<svg') === 1 && !preg_match('/script|on[a-z]+=/i', $svg));
    check("{$name}: ASCII only", !preg_match('/[^\x20-\x7E]/', $svg));
}
same('an unknown icon prints nothing', Icons::svg('nope'), '');

// --------------------------------------------------------------- Catalogue
$section = 'catalogue';
$types = Sections::types();
same('the six first sections are found', array_keys($types), ['hero-split', 'feature-cards', 'alternating', 'pricing-cards', 'faq', 'final-cta']);
foreach ($types as $name => $def) {
    check("{$name}: has a label, a group and a template", $def['label'] !== '' && $def['group'] !== '' && is_file($def['template']));
    check("{$name}: has fields", count($def['fields']) > 0);
    foreach ($def['fields'] as $f) {
        check("{$name}.{$f['key']}: has a label and a default", $f['label'] !== '' && array_key_exists('default', $f));
        if ($f['type'] === 'list') {
            check("{$name}.{$f['key']}: its item label names one of its fields", in_array($f['itemLabel'], array_column($f['fields'], 'key'), true));
        }
    }
    // Every folder holds exactly the pair the contract names.
    $files = array_map('basename', glob(dirname($def['template']) . '/*') ?: []);
    sort($files);
    same("{$name}: folder holds its .php and .tpl and nothing else", $files, ["{$name}.php", "{$name}.tpl"]);
}
check('the editor copy does not leak server paths', !str_contains(json_encode(Sections::forEditor()), 'template'));

// A theme folder can replace markup, or add a section of its own.
$themeDir = $compileDir . '-theme';
@mkdir($themeDir . '/faq', 0777, true);
@mkdir($themeDir . '/theme-only', 0777, true);
@mkdir($themeDir . '/Bad_Name', 0777, true);
file_put_contents($themeDir . '/faq/faq.tpl', '<section class="custom-faq">{$s.title|escape}</section>');
file_put_contents($themeDir . '/theme-only/theme-only.php', '<?php return ["label" => "Mine", "fields" => [["key" => "t", "type" => "text", "label" => "T", "default" => "x"]]];');
file_put_contents($themeDir . '/theme-only/theme-only.tpl', '<p>{$s.t|escape}</p>');
file_put_contents($themeDir . '/Bad_Name/Bad_Name.php', '<?php return ["label" => "No", "fields" => []];');
Sections::setDirs([$sectionsDir, $themeDir]);
Renderer::reset();
same('a theme template replaces the module one', Sections::type('faq')['template'], $themeDir . '/faq/faq.tpl');
check('a theme can add a section', Sections::type('theme-only') !== null && Sections::type('theme-only')['label'] === 'Mine');
check('a folder with a bad name is ignored', Sections::type('Bad_Name') === null);
check('the replaced markup is what renders', str_contains(Renderer::page(['sections' => [['type' => 'faq']]], $ctx), 'custom-faq'));
Sections::setDirs([$sectionsDir]);
Renderer::reset();

// --------------------------------------------------------------- Document
$section = 'document';
$doc = Document::normalize([
    'sections' => [
        ['id' => 'sabc123def0', 'type' => 'hero-split', 'props' => [
            'title' => ['_' => "Line one\nLine two", 'french' => 'Titre', 'klingon' => 'nuqneH', 'BAD KEY' => 'x'],
            'primaryLink' => 'javascript:alert(1)',
            'image' => 'not-a-url',
            'flip' => 'on',
            'invented' => 'dropped',
        ], 'style' => ['spacing' => 'huge', 'anchor' => '#Top'], 'hidden' => '1'],
        ['id' => 'sabc123def0', 'type' => 'feature-cards', 'props' => ['columns' => '9', 'items' => array_fill(0, 40, ['icon' => 'nope', 'colour' => 'pink', 'title' => 'T'])]],
        ['type' => 'does-not-exist', 'props' => []],
        'not an array',
    ],
    'extra' => 'dropped',
], $langs);
same('only known keys survive at the top', array_keys($doc), ['v', 'sections']);
same('an unknown section type and a non-section are dropped', count($doc['sections']), 2);
$hero = $doc['sections'][0];
same('a title is one line', $hero['props']['title']['_'], 'Line one Line two');
same('a language that is not installed is dropped', array_keys($hero['props']['title']), ['_', 'french']);
same('a script link is emptied', $hero['props']['primaryLink'], '');
same('a bad image address is emptied', $hero['props']['image'], '');
same('a toggle is a bool', $hero['props']['flip'], true);
check('a prop the schema does not name is dropped', !array_key_exists('invented', $hero['props']));
check('a missing prop gets its default', $hero['props']['eyebrow']['_'] === 'Web hosting');
same('an unknown spacing falls back', $hero['style']['spacing'], 'regular');
same('an anchor is cleaned', $hero['style']['anchor'], 'top');
same('hidden is a bool', $hero['hidden'], true);
$cards = $doc['sections'][1];
check('a duplicate id is replaced', $cards['id'] !== $hero['id'] && preg_match('/^s[a-f0-9]{10}$/', $cards['id']) === 1);
same('a select outside its options falls back', $cards['props']['columns'], '3');
same('a list is cut to its maximum', count($cards['props']['items']), 12);
same('an unknown icon is emptied, an unknown colour falls back', [$cards['props']['items'][0]['icon'], $cards['props']['items'][0]['colour']], ['', 'blue']);
same('a plain string given to a translatable field becomes a map', $cards['props']['items'][0]['title'], ['_' => 'T']);
same('normalising twice changes nothing', Document::normalize($doc, $langs), $doc);
same('a new section carries its defaults', Document::make('final-cta', $langs)['props']['primaryLink'], 'cart.php');
same('an unknown type cannot be made', Document::make('nope'), null);
same('meta: texts are maps, cut to length', Document::normalizeMeta(['title' => str_repeat('a', 300), 'description' => ['_' => 'D', 'french' => 'F']], $langs),
    ['title' => ['_' => str_repeat('a', 120)], 'description' => ['_' => 'D', 'french' => 'F']]);

// --------------------------------------------------------------- Renderer
$section = 'renderer';
$expect = [
    'hero-split' => 'hp-hero-split', 'feature-cards' => 'hp-feature-card', 'alternating' => 'hp-alt-row',
    'faq' => 'hp-faq-item', 'final-cta' => 'hp-final-cta',
];
foreach ($expect as $type => $class) {
    $html = Renderer::page(['sections' => [['type' => $type]]], $ctx);
    check("{$type}: its default content renders with the theme's class", str_contains($html, $class), substr($html, 0, 300));
    check("{$type}: nothing unresolved is left in the output", !preg_match('/\{\$|\{if |\{foreach/', $html));
    check("{$type}: tags balance", substr_count($html, '<section') === substr_count($html, '</section>') && substr_count($html, '<div') === substr_count($html, '</div>'));
}

$evil = '<script>alert(1)</script>{$smarty.now}{php}x{/php}';
$html = Renderer::page(['sections' => [
    ['type' => 'hero-split', 'props' => ['title' => $evil, 'eyebrow' => $evil, 'text' => $evil, 'primaryLabel' => $evil, 'imageAlt' => $evil, 'image' => '/a.png']],
    ['type' => 'faq', 'props' => ['items' => [['question' => $evil, 'answer' => '<p>{$smarty.now} {include file="/etc/passwd"}</p>']]]],
]], $ctx);
check('markup typed into a text field is shown as text', !str_contains($html, '<script>') && str_contains($html, '&lt;script&gt;'));
check('template syntax typed into a field is never run', str_contains($html, '{$smarty.now}') && str_contains($html, '{include file='));

$french = Renderer::page(['sections' => [['type' => 'final-cta', 'props' => ['title' => ['_' => 'Ready', 'french' => 'Pret'], 'text' => ['_' => 'Default text']]]]], ['lang' => 'french'] + $ctx);
check('the visitor\'s language is used where there is a translation', str_contains($french, '<h2>Pret</h2>'));
check('and the default where there is not', str_contains($french, 'Default text'));
check('a WHMCS path is printed under the install folder', str_contains($french, 'href="/billing/cart.php"'));

$two = ['sections' => [
    ['id' => 's1111111111', 'type' => 'final-cta', 'hidden' => true],
    ['id' => 's2222222222', 'type' => 'faq', 'style' => ['spacing' => 'compact', 'anchor' => 'questions']],
]];
$live = Renderer::page($two, $ctx);
check('a hidden section is not on the live page', !str_contains($live, 'hp-final-cta'));
check('the live page carries no editor markers', !str_contains($live, 'data-hb-id'));
check('spacing and anchor reach the wrapper', str_contains($live, 'class="hb-section hb-space-compact"') && str_contains($live, 'id="questions"'));
$edit = Renderer::page($two, ['annotate' => true] + $ctx);
check('the editor sees a hidden section, marked', str_contains($edit, 'hp-final-cta') && str_contains($edit, 'data-hb-id="s1111111111"') && str_contains($edit, 'hb-is-hidden'));
check('an empty page explains itself to the editor only', str_contains(Renderer::page(Document::blank(), ['annotate' => true] + $ctx), 'class="hb-note"')
    && !str_contains(Renderer::page(Document::blank(), $ctx), 'class="hb-note"'));

// Pricing: names and prices come from the catalogue, never from the document.
$pricing = ['sections' => [['type' => 'pricing-cards', 'props' => ['plans' => [
    ['product' => 7, 'highlight' => true, 'badge' => 'Most popular'],
    ['product' => 8],
    ['product' => 999],
    ['product' => 7, 'name' => 'Forged', 'price' => '$0.01'],
]]]]];
$catalog->calls = 0;
$html = Renderer::page($pricing, $ctx);
same('one catalogue call for the whole section', $catalog->calls, 1);
same('a product that does not exist gets no card', substr_count($html, 'hp-price-card'), 3);
check('the grid is sized for the cards shown', str_contains($html, 'hp-pricing-grid"') || str_contains($html, 'hp-pricing-grid cols'), $html);
check('the product name is escaped', str_contains($html, 'Starter &lt;b&gt; - Most popular'));
check('price, period and features come from the product', str_contains($html, '<span class="price">$4.00</span><span class="per">/mo</span>') && str_contains($html, '<li>Free SSL</li>'));
check('a free product shows the free label and no period', str_contains($html, '<span class="price">Free</span>') && substr_count($html, 'class="per"') === 2);
check('the order link is the product\'s, under the install folder', str_contains($html, 'href="/billing/cart.php?a=add&amp;pid=7"'));
check('a price typed into the document is ignored', !str_contains($html, 'Forged') && !str_contains($html, '$0.01'));
check('the highlighted plan is marked', str_contains($html, 'hp-price-card highlight') && str_contains($html, 'hp-price-card dim'));
same('with no usable product the section prints nothing', str_contains(Renderer::page(['sections' => [['type' => 'pricing-cards', 'props' => ['plans' => [['product' => 999]]]]]], $ctx), 'hp-pricing'), false);
check('and tells the editor why', str_contains(Renderer::page(['sections' => [['type' => 'pricing-cards']]], ['annotate' => true] + $ctx), 'nothing to show yet'));

// ---------------------------------------------------- product descriptions
$section = 'product description';
same('an intro line and a list', Catalog::splitDescription("Everything you need.\n<ul>\n<li><strong>10 GB</strong> storage</li>\n<li>Free &amp; fast SSL</li>\n</ul>"),
    ['Everything you need.', ['10 GB storage', 'Free & fast SSL']]);
same('plain lines', Catalog::splitDescription("For one site\n10 GB storage<br>Free SSL"), ['For one site', ['10 GB storage', 'Free SSL']]);
same('nothing at all', Catalog::splitDescription(''), ['', []]);

// Clean up the compiled templates and the stand-in theme folder.
foreach ([$compileDir, $compileDir . '-cache', $themeDir] as $dir) {
    if (is_dir($dir)) {
        $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
        foreach ($it as $f) {
            $f->isDir() ? @rmdir($f->getPathname()) : @unlink($f->getPathname());
        }
        @rmdir($dir);
    }
}

echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
exit($fails ? 1 : 0);
