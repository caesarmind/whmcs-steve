<?php
/**
 * Hadrian Email Templates: the engine, with no WHMCS and no database.
 *
 * The module lives in hadrian_email/ (a separate addon). Everything here is a
 * pure function of its input: merge-field handling, the rich-text sanitiser,
 * document validation, colour resolution and the renderer. What needs a real
 * WHMCS (the takeover, publishing, the send hook) is in tests/php/email-live.php.
 *
 *   php tests/static/test-email-engine.php
 */

declare(strict_types=1);

$root = dirname(__DIR__, 2);
// The module finds Hadrian under ROOTDIR/modules/addons/Hadrian. In this
// checkout that is the hadrian/ container folder, so the bridge loads the
// real Hadrian classes (language codes, the colour schema) without WHMCS.
define('ROOTDIR', $root . DIRECTORY_SEPARATOR . 'hadrian');
require $root . '/hadrian_email/modules/addons/HadrianEmail/autoload.php';

use HadrianEmail\Blocks;
use HadrianEmail\Bridge;
use HadrianEmail\Merge;
use HadrianEmail\Palette;
use HadrianEmail\Presets;
use HadrianEmail\Renderer;
use HadrianEmail\Sanitizer;
use HadrianEmail\Theme;

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

// ------------------------------------------------------------------ Merge
$section = 'merge';
same('a stray brace becomes an entity, a merge field does not',
    Merge::protect('Use {curly} with {$client_name}'), 'Use &#123;curly&#125; with {$client_name}');
same('conditions and loops survive',
    Merge::protect('{if $a > 1}x{else}y{/if} {foreach $items as $i}{$i.name}{/foreach}'),
    '{if $a > 1}x{else}y{/if} {foreach $items as $i}{$i.name}{/foreach}');
same('a literal block is passed over whole', Merge::protect('{literal}a{b}c{/literal} {d}'), '{literal}a{b}c{/literal} &#123;d&#125;');
same('tags WHMCS\'s mail policy would refuse are neutralised, not passed through',
    Merge::protect('{include file="x"} {php}evil(){/php} {"id"|system}'),
    '&#123;include file="x"&#125; &#123;php&#125;evil()&#123;/php&#125; &#123;"id"|system&#125;');
same('escape() escapes text but not the inside of a tag',
    Merge::escape('a < b & {if $x > 1}"q"{/if}'), 'a &lt; b &amp; {if $x > 1}&quot;q&quot;{/if}');
same('substitute fills known fields', Merge::substitute('Hi {$name}, {$missing}!', ['name' => 'Mara'], false), 'Hi Mara, !');
same('substitute can leave unknown fields visible (preview)',
    Merge::substitute('Hi {$name}, {$missing}!', ['name' => 'Mara'], true), 'Hi Mara, {$missing}!');
same('a field value is inserted once, never re-read as a template',
    Merge::substitute('{$a}', ['a' => '{$b}', 'b' => 'LEAK'], false), '{$b}');
same('an object with __toString is a value (WHMCS amounts are Price objects)',
    Merge::substitute('{$total}', ['total' => new class { public function __toString(): string { return '$49.00'; } }], false), '$49.00');
same('an array is not', Merge::substitute('[{$list}]', ['list' => [1, 2]], false), '[]');
same('stripLogic keeps the first branch', Merge::stripLogic('{if $paid}Thanks{else}Please pay{/if}.'), 'Thanks.');
same('stripLogic keeps one pass of a loop', Merge::stripLogic('{foreach $i as $x}<li>{$x}</li>{/foreach}'), '<li>{$x}</li>');
same('conditional marker kept when the field has a value',
    Merge::conditionals('a<!--hx-if:unsubscribe_url-->U<!--/hx-if-->b', ['unsubscribe_url' => 'https://x']), 'aUb');
same('conditional marker dropped when it is empty',
    Merge::conditionals('a<!--hx-if:unsubscribe_url-->U<!--/hx-if-->b', ['unsubscribe_url' => '']), 'ab');
same('conditional marker becomes Smarty for the static fallback',
    Merge::conditionals('a<!--hx-if:unsubscribe_url-->U<!--/hx-if-->b', null), 'a{if $unsubscribe_url}U{/if}b');
same('lint passes balanced logic', Merge::lint('{if $a}{foreach $b as $c}x{/foreach}{/if}'), []);
check('lint catches an unclosed block', Merge::lint('{if $a}x') !== []);
check('lint catches a crossed close', Merge::lint('{if $a}{foreach $b as $c}x{/if}{/foreach}') !== []);
same('pick falls back to the default when a translation is empty', Merge::pick(['_' => 'Pay', 'french' => ' '], 'french'), 'Pay');
same('pick returns the translation when there is one', Merge::pick(['_' => 'Pay', 'french' => 'Payer'], 'french'), 'Payer');

// -------------------------------------------------------------- Sanitizer
$section = 'sanitizer';
$clean = Sanitizer::rich('<p onclick="x()">Hi <b>there</b><script>alert(1)</script> <a href="javascript:alert(1)">bad</a> <a href="https://ok.test/?a=1&b=2" target="_blank">good</a></p><style>p{}</style>');
check('scripts and styles are removed with their content', !str_contains($clean, 'alert') && !str_contains($clean, 'p{}'), $clean);
check('attributes are dropped', !str_contains($clean, 'onclick') && !str_contains($clean, 'target'), $clean);
check('a javascript: link loses its href and keeps its text', str_contains($clean, 'bad') && !str_contains($clean, 'javascript'), $clean);
check('a web link survives', str_contains($clean, '<a href="https://ok.test/?a=1&amp;b=2">good</a>'), $clean);
check('<b> is normalised to <strong>', str_contains($clean, '<strong>there</strong>'), $clean);
same('merge fields and conditions pass through, operators intact',
    Sanitizer::rich('<p>{if $invoice_total > 10}Dear {$client_name}{/if}</p>'), '<p>{if $invoice_total > 10}Dear {$client_name}{/if}</p>');
same('a link to a merge field is allowed', Sanitizer::rich('<p><a href="{$invoice_url}">Pay</a></p>'), '<p><a href="{$invoice_url}">Pay</a></p>');
same('loose text becomes a paragraph', Sanitizer::rich('Just text'), '<p>Just text</p>');
same('tables are unwrapped, text kept', Sanitizer::rich('<table><tr><td>Cell</td></tr></table>'), '<p>Cell</p>');
same('non-ASCII text is not mangled', Sanitizer::rich("<p>Gr\u{00FC}\u{00DF}e \u{0645}\u{0631}\u{062D}\u{0628}\u{0627}</p>"), "<p>Gr\u{00FC}\u{00DF}e \u{0645}\u{0631}\u{062D}\u{0628}\u{0627}</p>");

// ----------------------------------------------------------------- Blocks
$section = 'blocks';
$doc = Blocks::normalize(['blocks' => [
    ['type' => 'header'],
    ['type' => 'nope', 'props' => ['x' => 1]],
    ['type' => 'html', 'props' => ['code' => '<b>x</b>']],
    ['type' => 'footer', 'props' => ['bogus' => 1, 'align' => 'sideways']],
]], 'layout');
same('unknown and out-of-scope blocks are dropped; a layout always gets its content slot',
    array_column($doc['blocks'], 'type'), ['header', 'content', 'footer']);
check('unknown props are dropped', !array_key_exists('bogus', $doc['blocks'][2]['props']));
same('an invalid option falls back to the default', $doc['blocks'][2]['props']['align'], 'center');
$msg = Blocks::normalize(['blocks' => [
    ['id' => 'not-an-id', 'type' => 'spacer', 'props' => ['height' => 9999]],
    ['type' => 'content'],
    ['type' => 'button', 'props' => ['label' => ['_' => 'Go', 'klingon' => 'jIH', 'french' => 'Aller'], 'url' => 'javascript:alert(1)']],
    ['type' => 'button', 'props' => ['url' => 'example.com/pay']],
    ['type' => 'image', 'props' => ['src' => 'data:image/png;base64,AAAA']],
]], 'message', ['english', 'french']);
same('a layout-only block is refused in a message', array_column($msg['blocks'], 'type'), ['spacer', 'button', 'button', 'image']);
same('numbers are clamped to the field\'s range', $msg['blocks'][0]['props']['height'], 96);
check('a bad id is replaced', (bool)preg_match('/^b[a-f0-9]{10}$/', $msg['blocks'][0]['id']));
same('translations for languages the install lacks are dropped', $msg['blocks'][1]['props']['label'], ['_' => 'Go', 'french' => 'Aller']);
same('a javascript: URL is refused', $msg['blocks'][1]['props']['url'], '');
same('a bare domain is taken as https', $msg['blocks'][2]['props']['url'], 'https://example.com/pay');
same('a data: image is refused', $msg['blocks'][3]['props']['src'], '');
same('settings always have their shape', $msg['settings'], ['subject' => ['_' => ''], 'preheader' => ['_' => '']]);

// ---------------------------------------------------------------- Palette
$section = 'palette';
$cfg      = Bridge::colorsConfig('hadrian');
$defaults = Palette::defaultsFrom($cfg);
check('the theme\'s colour schema was found through the bridge', isset($defaults['--color-accent']), 'ROOTDIR=' . ROOTDIR);
$p = Palette::compute($defaults, [], []);
same('light accent is the theme default', $p['light']['accent'], strtolower($defaults['--color-accent'][0]));
same('dark accent is the theme default', $p['dark']['accent'], strtolower($defaults['--color-accent'][1]));
// The fallback is what an email uses when the active template is not Hadrian.
// It has to say the same thing as the schema, or the two drift apart silently.
$fallback = Palette::compute([], [], []);
same('built-in fallback matches the theme schema (light)', $fallback['light'], $p['light']);
same('built-in fallback matches the theme schema (dark)', $fallback['dark'], $p['dark']);
foreach (['light', 'dark'] as $mode) {
    foreach ($p[$mode] as $role => $hex) {
        check("{$mode}.{$role} is opaque hex", (bool)preg_match('/^#[0-9a-f]{6}$/', $hex), $hex);
    }
}
$green = Palette::compute($defaults, ['--color-accent' => '#14b17d'], []);
same('a stored accent wins', $green['light']['accent'], '#14b17d');
check('the link follows a changed accent', $green['light']['link'] !== $p['light']['link'], $green['light']['link']);
check('...and is darker than it in light mode', hexdec(substr($green['light']['link'], 3, 2)) < 0xb1, $green['light']['link']);
check('the tint follows it too', $green['light']['accentTint'] !== $p['light']['accentTint']);
same('a light override does not leak into dark', $green['dark']['accent'], $p['dark']['accent']);
$both = Palette::compute($defaults, ['--color-accent' => '#14b17d', '--color-link' => '#aa0000'], []);
same('a link the buyer chose is kept', $both['light']['link'], '#aa0000');
same('rgba is flattened onto the surface', Palette::toHex('rgba(0,0,0,0.5)', '#ffffff'), '#808080');
same('unreadable notations return null instead of a guess', Palette::toHex('color-mix(in srgb, red, blue)', '#ffffff'), null);
same('lightness shift matches CSS hsl(from c h s calc(l - 4.51)) for the stock accent', Palette::shiftLightness('#0071e3', -4.51), '#0066cc');

// --------------------------------------------------------------- Renderer
$section = 'renderer';
$theme = [
    'palette'   => $p,
    'font'      => "'Inter', -apple-system, Arial, sans-serif",
    'company'   => 'Acme & Sons',
    'systemUrl' => 'https://billing.example.test/',
    'origin'    => 'https://billing.example.test',
    'logo'      => ['light' => 'https://billing.example.test/logo.png', 'dark' => 'https://billing.example.test/logo-dark.png'],
    'logoIssue' => '',
    'social'    => [['label' => 'X', 'url' => 'https://x.com/acme']],
    'settings'  => Theme::normalizeSettings([], 'auto'),
    'language'  => 'english',
];
$layout = Blocks::normalize(Presets::layout([['label' => ['_' => 'Terms', 'french' => 'Conditions'], 'url' => 'https://example.test/terms']]), 'layout');
[$head, $foot] = (new Renderer($theme, 'english'))->layout($layout);
check('header opens a document and the content cell', str_starts_with($head, '<!DOCTYPE html>') && str_contains($head, 'class="hx-content'));
check('footer closes them', str_ends_with(trim($foot), '</html>') && str_starts_with($foot, '</td></tr>'));
check('company name is escaped', str_contains($head, 'Acme &amp; Sons') && !str_contains($head, 'Acme & Sons'));
check('auto mode ships dark rules and both logos', str_contains($head, 'prefers-color-scheme:dark') && str_contains($head, 'hx-logo-d'));
check('viewport meta is well formed', str_contains($head, 'content="width=device-width, initial-scale=1"'));
check('no web font or other remote stylesheet is requested', !str_contains($head, '<link') && !str_contains($head, '@import'));
check('no translucent colours reach Outlook', !preg_match('/rgba?\(/', $head . $foot));
check('wrapper is small', strlen($head . $foot) < 16000, strlen($head . $foot) . ' bytes');

$lightOnly = $theme;
$lightOnly['settings'] = Theme::normalizeSettings(['mode' => 'light'], 'auto');
[$lh] = (new Renderer($lightOnly, 'english'))->layout($layout);
check('"always light" ships no dark rules', !str_contains($lh, 'prefers-color-scheme') && str_contains($lh, 'content="light"'));
$darkOnly = $theme;
$darkOnly['settings'] = Theme::normalizeSettings(['mode' => 'dark'], 'auto');
[$dh] = (new Renderer($darkOnly, 'english'))->layout($layout);
check('"always dark" writes the dark palette inline', str_contains($dh, 'background-color:' . $p['dark']['bg']) && !str_contains($dh, 'prefers-color-scheme'));

[$ah, $af] = (new Renderer($theme, 'arabic'))->layout($layout);
check('a right-to-left language sets lang and dir', str_contains($ah, '<html lang="ar" dir="rtl"'), substr($ah, 16, 80));
check('...and mirrors start-aligned text', str_contains($ah, 'text-align:right'));
[, $ff] = (new Renderer($theme, 'french'))->layout($layout);
check('footer links use the recipient\'s language', str_contains($ff, '>Conditions</a>') && !str_contains($ff, '>Terms</a>'));

[$sh, $sf] = Renderer::forSend($theme, $layout, 'english', ['companyname' => 'Acme', 'unsubscribe_url' => 'https://u.test/x', 'whmcs_url' => 'https://b.test/'], 'Due <soon>');
check('send: every field and marker is resolved', !preg_match('/\{\$|\{if |hx-if/', $sh . $sf), substr($sf, 0, 200));
check('send: the unsubscribe link appears when WHMCS supplies one', str_contains($sf, 'href="https://u.test/x"'));
check('send: the preview text is escaped', str_contains($sh, 'Due &lt;soon&gt;'));
[, $nf] = Renderer::forSend($theme, $layout, 'english', ['companyname' => 'Acme'], '');
check('send: no unsubscribe link without one', !str_contains($nf, 'Unsubscribe'));

[$fh, $ffb] = Renderer::fallback($theme, $layout);
check('fallback: the stylesheet is wrapped in {literal}', (bool)preg_match('/<style>\{literal\}.*\{\/literal\}<\/style>/s', $fh));
check('fallback: merge fields are left for WHMCS', str_contains($ffb, '{$companyname}') && str_contains($ffb, '{if $unsubscribe_url}'));
check('fallback: nothing of ours is left unresolved', !str_contains($fh . $ffb, 'hx_year') && !str_contains($fh . $ffb, 'hx_preheader') && !str_contains($fh . $ffb, 'hx-if'));
same('fallback: is valid Smarty as far as block balance goes', Merge::lint($fh . 'BODY' . $ffb), []);

$message = Blocks::normalize(['blocks' => [
    ['type' => 'heading', 'props' => ['text' => ['_' => 'Invoice {$invoice_num} {not a tag}']]],
    ['type' => 'button', 'props' => ['label' => ['_' => 'Pay <now>'], 'url' => '{if isset($invoice_url)}{$invoice_url}{/if}']],
    ['type' => 'html', 'props' => ['code' => '{foreach $items as $i}<li>{$i}</li>{/foreach}']],
]], 'message');
$body = Renderer::compileMessage($theme, $message, 'english');
check('compiled body keeps real merge fields', str_contains($body, '{$invoice_num}') && str_contains($body, 'href="{if isset($invoice_url)}{$invoice_url}{/if}"'));
check('...neutralises a stray brace the admin typed', str_contains($body, '&#123;not a tag&#125;'));
check('...escapes text', str_contains($body, 'Pay &lt;now&gt;'));
check('...passes an HTML block through untouched', str_contains($body, '{foreach $items as $i}<li>{$i}</li>{/foreach}'));
same('...and lints clean', Merge::lint($body), []);

$preview = Renderer::preview($theme, $layout, $message, ['annotate' => 'message']);
check('preview marks the message\'s blocks, not the layout\'s',
    substr_count($preview, 'data-hx-block=') === 3 && str_contains($preview, 'data-hx-slot'), (string)substr_count($preview, 'data-hx-block='));
check('preview shows sample data', str_contains($preview, 'Invoice 3187') && str_contains($preview, 'viewinvoice.php'));

foreach (Presets::names() as $name) {
    $d = Blocks::normalize(Presets::message($name), 'message');
    check("starter \"{$name}\" has blocks", count($d['blocks']) >= 3);
    same("starter \"{$name}\" compiles to balanced Smarty", Merge::lint(Renderer::compileMessage($theme, $d, 'english')), []);
}
same('import: a simple body becomes an editable text block',
    Presets::import('<p>Dear {$client_name},</p><p>Thanks.</p>')['blocks'][0]['type'], 'text');
same('import: a body with a table is kept verbatim in an HTML block',
    Presets::import('<table><tr><td>{$x}</td></tr></table>')['blocks'][0], ['type' => 'html', 'props' => ['code' => '<table><tr><td>{$x}</td></tr></table>']]);

// ---------------------------------------------------------------- Designs
$section = 'designs';
same('three designs, Card first', array_keys(\HadrianEmail\Designs::all()), ['card', 'banner', 'letter']);
$mine = Blocks::normalize(['blocks' => [
    ['type' => 'header', 'props' => ['tagline' => ['_' => 'Hosting that answers'], 'align' => 'center', 'nav' => [['label' => ['_' => 'Status'], 'url' => 'https://status.test']]]],
    ['type' => 'text', 'props' => ['html' => ['_' => '<p>Line on every email</p>']]],
    ['type' => 'content', 'props' => ['card' => false]],
    ['type' => 'footer', 'props' => ['text' => ['_' => '<p>Acme footer</p>'], 'links' => [['label' => ['_' => 'Terms'], 'url' => 'https://t.test']]]],
]], 'layout');
$banner = Blocks::normalize(\HadrianEmail\Designs::apply($mine, 'banner'), 'layout');
same('apply sets the design', $banner['settings']['design'], 'banner');
same('apply sets the design\'s presets', [$banner['blocks'][0]['props']['subject'], $banner['blocks'][0]['props']['align'], $banner['blocks'][2]['props']['card']], [true, 'start', true]);
same('apply keeps the tagline', $banner['blocks'][0]['props']['tagline'], ['_' => 'Hosting that answers']);
same('apply keeps the header links', $banner['blocks'][0]['props']['nav'][0]['url'], 'https://status.test');
same('apply keeps extra blocks and their order', array_column($banner['blocks'], 'type'), ['header', 'text', 'content', 'footer']);
same('apply keeps the footer text and links', [$banner['blocks'][3]['props']['text'], $banner['blocks'][3]['props']['links'][0]['url']], [['_' => '<p>Acme footer</p>'], 'https://t.test']);
same('an unknown design falls back to Card', Blocks::normalize(['settings' => ['design' => 'nope'], 'blocks' => []], 'layout')['settings']['design'], 'card');
same('a message document has no design', array_key_exists('design', Blocks::normalize(['settings' => ['design' => 'banner']], 'message')['settings']), false);

$designDoc = static fn(string $id): array => Blocks::normalize(\HadrianEmail\Designs::apply(Presets::layout(), $id), 'layout');
$render = static fn(array $theme, string $id, array $fields = [], string $lang = 'english'): array
    => Renderer::forSend($theme, $designDoc($id), $lang, $fields + ['companyname' => 'Acme'], '');

[$ch] = $render($theme, 'card');
[$bh, $bf] = $render($theme, 'banner', ['hx_subject' => 'Invoice #3187 &amp; more']);
[$lh, $lf] = $render($theme, 'letter');
check('card: the page is the soft grey', str_contains($ch, '<body class="hx-bg"') && str_contains($ch, 'background-color:' . $p['light']['bg']));
check('card: no band', !str_contains($ch, 'class="hx-band') && !str_contains($ch, '.hx-band{'));
check('banner: an accent band', (bool)preg_match('/class="hx-band"[^>]*bgcolor="' . preg_quote($p['light']['accent'], '/') . '"/', $bh), substr($bh, (int)strpos($bh, 'hx-band') - 20, 160));
check('banner: the subject is the title, as given (already escaped)', str_contains($bh, 'Invoice #3187 &amp; more'));
check('banner: the band uses the light-coloured logo, not the normal one', str_contains($bh, 'logo-dark.png') && !str_contains(substr($bh, 0, (int)strpos($bh, 'hx-content')), 'logo.png"'));
check('banner: the card is joined to the band (square top corners)', (bool)preg_match('/class="hx-content hx-surface[^"]*"[^>]*border-radius:0 0 \d+px \d+px/', $bh));
$darkBand = \HadrianEmail\Palette::readableUnder($p['dark']['accent'], $p['dark']['onAccent']);
check('banner: dark mode recolours the band', str_contains($bh, '.hx-band{background-color:' . $darkBand . '!important}'));
check('banner: text on the band reaches 4.5:1 in both modes',
    \HadrianEmail\Palette::contrast(\HadrianEmail\Palette::readableUnder($p['light']['accent'], $p['light']['onAccent']), $p['light']['onAccent']) >= 4.5
    && \HadrianEmail\Palette::contrast($darkBand, $p['dark']['onAccent']) >= 4.5);
same('the band deepens a pale accent rather than keep unreadable white text', \HadrianEmail\Palette::contrast(\HadrianEmail\Palette::readableUnder('#ffcc00', '#ffffff'), '#ffffff') >= 4.5, true);
[$bnh] = $render($theme, 'banner', ['hx_subject' => '']);
check('banner: no subject, no empty title element', !str_contains($bnh, 'class="hx-title'));
$noDark = $theme;
$noDark['logo'] = ['light' => 'https://billing.example.test/logo.png', 'dark' => ''];
[$wh] = Renderer::forSend($noDark, $designDoc('banner'), 'english', ['companyname' => 'Acme', 'hx_subject' => 'S'], '');
check('banner without a light logo sets the company name instead', !str_contains(substr($wh, 0, (int)strpos($wh, 'hx-content')), 'logo.png') && str_contains($wh, 'Acme &amp; Sons'));
check('letter: the page is the surface colour, no card', str_contains($lh, '<body class="hx-surface"') && !preg_match('/class="hx-content hx-surface/', $lh));
check('letter: a fine rule under the header and over the footer', substr_count($lh . $lf, 'border-bottom:1px solid ' . $p['light']['border']) >= 1 && str_contains($lf, 'border-top:1px solid ' . $p['light']['border']));
[$arb] = $render($theme, 'banner', ['hx_subject' => 'S'], 'arabic');
check('banner mirrors for right to left', str_contains($arb, 'dir="rtl"') && str_contains(substr($arb, (int)strpos($arb, 'hx-band')), 'text-align:right'));
foreach (['card', 'banner', 'letter'] as $id) {
    [$fh, $ff] = Renderer::fallback($theme, $designDoc($id));
    same("{$id}: static fallback is balanced Smarty", Merge::lint($fh . 'BODY' . $ff), []);
    check("{$id}: static fallback never asks WHMCS for our own fields", !str_contains($fh . $ff, 'hx_subject') && !str_contains($fh . $ff, 'hx-if'));
    $both = implode('', Renderer::forSend($theme, $designDoc($id), 'english', ['companyname' => 'Acme', 'hx_subject' => 'S', 'unsubscribe_url' => 'https://u'], 'P'));
    check("{$id}: send output has nothing unresolved", !preg_match('/\{\$|\{if |hx-if/', $both));
    check("{$id}: stays small", strlen($both) < 18000, strlen($both) . ' bytes');
}

echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
exit($fails ? 1 : 0);
