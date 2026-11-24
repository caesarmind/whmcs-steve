<?php
/**
 * Hadrian Page Builder: check one section, or all of them, against the
 * section contract. No WHMCS and no database.
 *
 *   php tests/static/check-builder-section.php            every section
 *   php tests/static/check-builder-section.php faq-grid   one section
 *   php tests/static/check-builder-section.php faq-grid --html   also print what it renders
 *
 * What it checks for each section folder:
 *   - the folder holds exactly <name>.php and <name>.tpl
 *   - the schema loads, has a label, hint and group, and no field was dropped
 *     for being malformed
 *   - both files are ASCII only and name no other vendor or product
 *   - the template escapes: every {$...} is |escape'd, or is one of the
 *     values the engine made safe (rich text, icon markup), or is a number
 *   - with its default content (and stand-in products and announcements) the
 *     section renders, prints something, leaves no template syntax behind and
 *     balances its tags
 *   - with every field emptied it still renders without an error
 *   - text typed into every text field comes out escaped
 *
 * Used while writing sections, and by test-builder-engine.php for the suite.
 */

declare(strict_types=1);

$root = dirname(__DIR__, 2);
require __DIR__ . '/vendor/autoload.php';
require $root . '/hadrian_builder/modules/addons/HadrianBuilder/autoload.php';

use HadrianBuilder\Document;
use HadrianBuilder\Renderer;
use HadrianBuilder\Sections;

$sectionsDir = $root . '/hadrian_builder/modules/addons/HadrianBuilder/sections';

/** A catalogue that never touches WHMCS. */
function hbFakeCatalog(): object
{
    return new class {
        public function products(array $ids): array
        {
            $out = [];
            foreach ($ids as $id) {
                $id = (int)$id;
                if ($id < 1 || $id > 900) {
                    continue;
                }
                $out[$id] = [
                    'id' => $id, 'name' => 'Plan ' . $id, 'tagline' => 'For site number ' . $id,
                    'features' => ['10 GB storage', 'Free SSL', 'Daily backups'],
                    'free' => false, 'price' => '$' . (3 + $id) . '.00', 'per' => '/mo', 'cycle' => 'monthly',
                    'cycles' => [
                        'monthly'  => ['price' => '$' . (3 + $id) . '.00', 'per' => '/mo', 'monthly' => '$' . (3 + $id) . '.00'],
                        'annually' => ['price' => '$' . (30 + $id) . '.00', 'per' => '/yr', 'monthly' => '$' . (2 + $id) . '.50'],
                    ],
                    'orderUrl' => 'cart.php?a=add&pid=' . $id,
                ];
            }
            return $out;
        }

        public function announcements(int $limit, string $lang): array
        {
            $all = [];
            for ($i = 1; $i <= 6; $i++) {
                $all[] = ['id' => $i, 'title' => 'Announcement ' . $i, 'date' => '0' . $i . '/11/2026', 'dateIso' => '2026-11-0' . $i,
                    'text' => 'The opening lines of announcement ' . $i . '.', 'url' => 'announcements.php?id=' . $i];
            }
            return array_slice($all, 0, $limit);
        }
    };
}

/**
 * Props that give every product field a product, so a pricing section has
 * something to draw. Everything else keeps its default.
 *
 * @param array<string,mixed> $def
 * @return array<string,mixed>
 */
function hbPropsWithProducts(array $def): array
{
    $props = [];
    $next  = 1;
    foreach ($def['fields'] as $f) {
        if ($f['type'] === 'product') {
            $props[$f['key']] = $next++;
        } elseif ($f['type'] === 'list') {
            $hasProduct = false;
            foreach ($f['fields'] as $sub) {
                $hasProduct = $hasProduct || $sub['type'] === 'product';
            }
            if ($hasProduct) {
                $items = $f['default'] !== [] ? $f['default'] : [[], [], []];
                foreach ($items as &$item) {
                    foreach ($f['fields'] as $sub) {
                        if ($sub['type'] === 'product') {
                            $item[$sub['key']] = $next++;
                        }
                    }
                }
                unset($item);
                $props[$f['key']] = $items;
            }
        }
    }
    return $props;
}

/**
 * Props with every text field set to $text and every list holding one item.
 *
 * @param array<string,mixed> $def
 * @return array<string,mixed>
 */
function hbPropsFilled(array $def, string $text): array
{
    $fill = static function (array $fields) use (&$fill, $text): array {
        $out = [];
        foreach ($fields as $f) {
            switch ($f['type']) {
                case 'text': case 'textarea': case 'lines': case 'rich':
                    $out[$f['key']] = $text;
                    break;
                case 'list':
                    $out[$f['key']] = [$fill($f['fields'])];
                    break;
                case 'product':
                    $out[$f['key']] = 1;
                    break;
            }
        }
        return $out;
    };
    return $fill($def['fields']);
}

/**
 * @return list<string> problems found; empty when the section is sound
 */
function hbCheckSection(string $sectionsDir, string $name, bool $printHtml = false): array
{
    $problems = [];
    $folder   = $sectionsDir . '/' . $name;
    $php      = $folder . '/' . $name . '.php';
    $tpl      = $folder . '/' . $name . '.tpl';

    if (!preg_match('/^[a-z][a-z0-9-]{1,40}$/', $name)) {
        return ['the folder name must be lowercase letters, digits and hyphens'];
    }
    $files = array_map('basename', glob($folder . '/*') ?: []);
    sort($files);
    if ($files !== [$name . '.php', $name . '.tpl']) {
        $problems[] = 'the folder must hold exactly ' . $name . '.php and ' . $name . '.tpl; found: ' . implode(', ', $files);
    }
    if (!is_file($php) || !is_file($tpl)) {
        return $problems;
    }

    $phpSource = (string)file_get_contents($php);
    $tplSource = (string)file_get_contents($tpl);
    foreach ([$name . '.php' => $phpSource, $name . '.tpl' => $tplSource] as $file => $source) {
        if (preg_match('/[^\x09\x0A\x0D\x20-\x7E]/', $source, $m, PREG_OFFSET_CAPTURE)) {
            $problems[] = $file . ': not ASCII, at line ' . (substr_count($source, "\n", 0, $m[0][1]) + 1);
        }
        if (preg_match('/\b(apple|iphone|ipad|macbook|lagom|rsthemes|rs\s?studio|envato)\b/i', $source, $m)) {
            $problems[] = $file . ': names another vendor or product ("' . $m[0] . '")';
        }
    }

    // The raw schema, to see whether the loader dropped anything.
    $raw = require $php;
    $def = Sections::type($name);
    if ($def === null) {
        return array_merge($problems, ['the schema did not load (it must return an array with a `fields` list)']);
    }
    foreach (['label', 'hint', 'group'] as $key) {
        if (trim((string)($raw[$key] ?? '')) === '') {
            $problems[] = 'the schema has no `' . $key . '`';
        }
    }
    if (!isset($raw['order']) || !is_int($raw['order'])) {
        $problems[] = 'the schema has no integer `order`';
    }
    $rawKeys = array_column((array)($raw['fields'] ?? []), 'key');
    $gotKeys = array_column($def['fields'], 'key');
    if ($rawKeys !== $gotKeys) {
        $problems[] = 'fields dropped as malformed: ' . implode(', ', array_diff($rawKeys, $gotKeys));
    }
    if (count($rawKeys) !== count(array_unique($rawKeys))) {
        $problems[] = 'two fields share a key';
    }
    foreach ((array)($raw['fields'] ?? []) as $f) {
        if (($f['type'] ?? '') === 'list') {
            $rawSub = array_column((array)($f['fields'] ?? []), 'key');
            $gotSub = [];
            foreach ($def['fields'] as $d) {
                if ($d['key'] === $f['key']) {
                    $gotSub = array_column($d['fields'], 'key');
                }
            }
            if ($rawSub !== $gotSub) {
                $problems[] = 'list `' . $f['key'] . '`: fields dropped as malformed: ' . implode(', ', array_diff($rawSub, $gotSub));
            }
        }
        foreach (array_merge([$f], (array)($f['fields'] ?? [])) as $one) {
            if (in_array($one['type'] ?? '', ['text', 'textarea', 'lines', 'rich'], true) && empty($one['translatable'])) {
                $problems[] = 'field `' . ($one['key'] ?? '?') . '` holds text a visitor reads but is not translatable';
            }
        }
    }
    foreach ((array)($raw['data'] ?? []) as $source) {
        if (!in_array($source, Sections::DATA_SOURCES, true)) {
            $problems[] = 'unknown data source "' . $source . '"';
        }
    }

    // Every printed variable is escaped, or is one the engine made safe.
    $body = (string)preg_replace('/\{\*.*?\*\}/s', '', $tplSource);
    $body = (string)preg_replace('/\{literal\}.*?\{\/literal\}/s', '', $body);
    preg_match_all('/\{\$[^{}]+\}/', $body, $prints);
    foreach ($prints[0] as $print) {
        if (str_contains($print, '|escape') || preg_match('/\{\$[A-Za-z_.]*(Svg|[a-z]Html)\s+nofilter\}/', $print)) {
            continue;
        }
        if (preg_match('/\snofilter\}$/', $print)) {
            // Allowed for a rich-text value and for markup captured in this template.
            if (preg_match('/\{\$hb[A-Z][A-Za-z]*\s+nofilter\}/', $print)) {
                continue;
            }
            $key  = (string)preg_replace('/^\{\$[A-Za-z_]+\.|\s+nofilter\}$/', '', $print);
            $rich = false;
            foreach ($def['fields'] as $f) {
                $rich = $rich || ($f['key'] === $key && $f['type'] === 'rich');
                foreach ($f['fields'] ?? [] as $sub) {
                    $rich = $rich || ($sub['key'] === $key && $sub['type'] === 'rich');
                }
            }
            if ($rich) {
                continue;
            }
        }
        if (preg_match('/^\{\$[A-Za-z_.@]+(@(iteration|index|first|last|total))\}$/', $print)) {
            continue;       // a loop counter
        }
        $problems[] = 'printed without |escape: ' . $print;
    }
    if (preg_match('/\|(json_encode|strtolower|strtoupper|count|trim|str_replace|substr|ucfirst|strip_tags|number_format|implode|in_array|md5)\b/', $body, $m)) {
        $problems[] = 'uses the PHP function "' . $m[1] . '" as a modifier, which this Smarty version warns about';
    }
    if (preg_match('/\{(include|php|eval|fetch|extends|block|insert)\b/', $body, $m)) {
        $problems[] = 'uses {' . $m[1] . '}, which a section template may not';
    }

    $ctx = ['lang' => 'english', 'webRoot' => '/billing', 'languages' => ['english', 'french'], 'catalog' => hbFakeCatalog(),
        'compileDir' => sys_get_temp_dir() . '/hadrian-builder-check'];
    $render = static function (array $props) use ($name, $ctx): array {
        $doc     = Document::normalize(['sections' => [['id' => 's00000000aa', 'type' => $name, 'props' => $props]]], $ctx['languages']);
        $section = $doc['sections'][0];
        $errors  = [];
        set_error_handler(static function (int $no, string $message) use (&$errors): bool {
            $errors[] = $message;
            return true;
        });
        try {
            // annotate off: an error is a thrown exception here, not a note.
            $html = Renderer::section($section, ['annotate' => false] + $ctx);
            // Renderer swallows a failed section; ask the engine directly why.
            if ($html === '') {
                $class  = \HadrianBuilder\Bridge::smartyClass();
                $smarty = new $class();
                $smarty->setCompileDir($ctx['compileDir']);
                $def    = Sections::type($name);
                $smarty->assign(['s' => Renderer::resolve($def['fields'], $section['props'], $ctx), 'id' => 's00000000aa',
                    'style' => $section['style'], 'ctx' => ['lang' => 'english', 'webRoot' => '/billing', 'loggedIn' => false],
                    'data' => ['announcements' => in_array('announcements', $def['data'], true) ? $ctx['catalog']->announcements(6, 'english') : []]]);
                try {
                    $smarty->fetch('file:' . $def['template']);
                } catch (\Throwable $e) {
                    $errors[] = 'template error: ' . $e->getMessage();
                }
            }
        } finally {
            restore_error_handler();
        }
        return [$html, $errors];
    };

    [$html, $errors] = $render(hbPropsWithProducts($def));
    foreach (array_unique($errors) as $error) {
        $problems[] = 'default content: ' . $error;
    }
    $inner = (string)preg_replace('/^<div[^>]*>|<\/div>$/', '', $html);
    if (trim($inner) === '') {
        $problems[] = 'with its default content the section prints nothing; give it defaults that show something';
    } else {
        // Inline scripts and styles are code, not page text: leave them out of the text checks.
        $text = (string)preg_replace('/<(script|style)\b.*?<\/\1>/is', '', $inner);
        if (preg_match('/\{\$|\{if\b|\{foreach\b|\{\/|\{else/', $text, $m)) {
            $problems[] = 'template syntax left in the output: ' . $m[0];
        }
        foreach (['section', 'div', 'ul', 'ol', 'li', 'a', 'span', 'p', 'h1', 'h2', 'h3', 'h4', 'table', 'tr', 'td', 'th', 'button', 'details', 'summary', 'svg', 'form', 'label', 'blockquote', 'figure', 'nav'] as $tag) {
            $open  = preg_match_all('/<' . $tag . '(\s[^>]*)?>/i', $inner);
            $close = substr_count(strtolower($inner), '</' . $tag . '>');
            if ($open !== $close) {
                $problems[] = "unbalanced <{$tag}>: {$open} opened, {$close} closed";
            }
        }
        if (substr_count($inner, '<h1') > 1) {
            $problems[] = 'more than one <h1>';
        }
        if (preg_match('/\son[a-z]+\s*=/i', $text, $m)) {
            $problems[] = 'inline event handler in the markup (' . trim($m[0]) . '); use a script block or the theme\'s own script';
        }
        if (preg_match('/href="(#|javascript:[^"]*)"/i', $text, $m)) {
            $problems[] = 'a link that goes nowhere (' . $m[0] . '); print a link only when its field has a value';
        }
    }

    [, $errors] = $render(hbPropsFilled($def, ''));
    foreach (array_unique($errors) as $error) {
        $problems[] = 'with every field empty: ' . $error;
    }

    $probe = '<b>hb&probe</b>"\'';
    [$probed, $errors] = $render(hbPropsFilled($def, $probe));
    foreach (array_unique($errors) as $error) {
        $problems[] = 'with one item per list: ' . $error;
    }
    $probedText = (string)preg_replace('/<(script|style)\b.*?<\/\1>/is', '', $probed);
    if (str_contains($probedText, '<b>hb&probe</b>"') || preg_match('/="[^"]*hb&probe<\/b>"\'/', $probedText)) {
        // Rich fields are sanitised to <strong>, so raw <b> can only come from an unescaped print.
        $problems[] = 'a text value reached the page unescaped';
    }

    if ($printHtml) {
        echo "\n----- {$name}: default content -----\n" . $html . "\n";
    }
    return $problems;
}

// Run directly: check the named section, or every one.
if (isset($argv[0]) && realpath($argv[0]) === realpath(__FILE__)) {
    Sections::setDirs([$sectionsDir]);
    $only  = isset($argv[1]) && $argv[1][0] !== '-' ? $argv[1] : null;
    $html  = in_array('--html', $argv, true);
    $names = $only !== null ? [$only] : array_map('basename', glob($sectionsDir . '/*', GLOB_ONLYDIR) ?: []);
    $bad   = 0;
    foreach ($names as $name) {
        $problems = hbCheckSection($sectionsDir, $name, $html);
        if ($problems === []) {
            echo "ok    {$name}\n";
            continue;
        }
        $bad++;
        echo "FAIL  {$name}\n";
        foreach ($problems as $p) {
            echo "      - {$p}\n";
        }
    }
    echo "\n" . count($names) . " section(s) checked, {$bad} with problems\n";
    exit($bad ? 1 : 0);
}
