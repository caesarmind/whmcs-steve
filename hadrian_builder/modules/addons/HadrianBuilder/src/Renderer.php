<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Turns a page document into HTML.
 *
 * Each section's template is fetched with a Smarty instance of this module's
 * own, and the result is one string the theme prints inside its header and
 * footer. The live page and the editor's preview both come through here, so
 * they cannot differ.
 *
 * What a section template receives:
 *   $s      the section's props, resolved for the visitor's language:
 *           translatable maps are plain strings, links are ready to print,
 *           an icon field `x` also gives `xSvg`, a product field `x` also
 *           gives `xData` (name, price, features, order link) or null
 *           and a lines field `x` also gives `xLines`, a list
 *   $data   WHMCS data the schema asked for (see Sections), e.g. announcements
 *   $id     the section's id
 *   $style  spacing and anchor
 *   $ctx    lang, webRoot, loggedIn
 *
 * Admin content only ever reaches a template as a value. It is never compiled
 * as template source.
 */
final class Renderer
{
    private static ?object $smarty = null;

    /** Rules for the wrappers this class prints. Theme tokens only, ASCII only. */
    private const CSS = '.hb-space-compact > * { padding-block: 40px; }'
        . ' .hb-space-roomy > * { padding-block: 140px; }'
        . ' .hb-section[id] { scroll-margin-top: 90px; }'
        . ' .hb-media { display: block; max-width: 100%; height: auto; border-radius: 18px; }'
        . ' .hb-note { max-width: var(--w-narrow); margin: 24px auto; padding: 14px 18px; border: 1px dashed var(--color-border);'
        . ' border-radius: var(--radius-md); color: var(--color-text-secondary); font-size: var(--text-md); text-align: center; }';

    /**
     * @param array<string,mixed> $doc
     * @param array<string,mixed> $ctx
     *        lang       WHMCS language name of the visitor
     *        webRoot    path WHMCS is installed under ("" at a domain root)
     *        loggedIn   bool
     *        annotate   bool: mark each section for the editor and explain empty ones
     *        languages  installed languages, for validation
     *        catalog    object with products(list<int>): array, defaults to Catalog
     *        compileDir where Smarty writes compiled templates
     */
    public static function page(array $doc, array $ctx = []): string
    {
        $ctx  = self::context($ctx);
        $doc  = Document::normalize($doc, $ctx['languages']);
        $html = '';
        foreach ($doc['sections'] as $section) {
            if ($section['hidden'] && !$ctx['annotate']) {
                continue;
            }
            $html .= self::section($section, $ctx);
        }
        if ($html === '' && $ctx['annotate']) {
            $html = '<div class="hb-note">This page has no sections yet. Add one from the list on the left.</div>';
        }
        return '<style>' . self::CSS . '</style><div class="hb-page">' . $html . '</div>';
    }

    /**
     * One section, wrapped. $section must already be normalised.
     *
     * @param array<string,mixed> $section
     * @param array<string,mixed> $ctx
     */
    public static function section(array $section, array $ctx): string
    {
        $ctx = self::context($ctx);
        $def = Sections::type((string)$section['type']);
        if ($def === null) {
            return '';
        }
        $e    = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $body = '';
        try {
            $smarty = self::smarty($ctx);
            $smarty->clearAllAssign();
            $smarty->assign([
                's'     => self::resolve($def['fields'], $section['props'], $ctx),
                'data'  => self::data($def, $section['props'], $ctx),
                'id'    => $section['id'],
                'style' => $section['style'],
                'ctx'   => ['lang' => $ctx['lang'], 'webRoot' => $ctx['webRoot'], 'loggedIn' => $ctx['loggedIn']],
            ]);
            $body = (string)$smarty->fetch('file:' . $def['template']);
        } catch (\Throwable $ex) {
            // One broken section must not take the page down with it.
            error_log('Hadrian Page Builder: section "' . $section['type'] . '" failed to render: ' . $ex->getMessage());
            if (!$ctx['annotate']) {
                return '';
            }
            $body = '<div class="hb-note">The "' . $e($def['label']) . '" section could not be drawn: ' . $e($ex->getMessage()) . '</div>';
        }
        if (trim($body) === '') {
            if (!$ctx['annotate']) {
                return '';
            }
            $body = '<div class="hb-note">' . $e($def['label']) . ': nothing to show yet. Fill in its fields on the right.</div>';
        }

        $attrs = ' class="hb-section hb-space-' . $e($section['style']['spacing']) . ($section['hidden'] ? ' hb-is-hidden' : '') . '"'
            . ' data-hb-type="' . $e($section['type']) . '"';
        if ($section['style']['anchor'] !== '') {
            $attrs .= ' id="' . $e($section['style']['anchor']) . '"';
        }
        if ($ctx['annotate']) {
            $attrs .= ' data-hb-id="' . $e($section['id']) . '"';
            if ($section['hidden']) {
                $attrs .= ' style="opacity:.35"';
            }
        }
        return '<div' . $attrs . '>' . $body . '</div>';
    }

    /**
     * Props as a template wants them: one language, links resolved, icon and
     * product data attached.
     *
     * @param list<array<string,mixed>> $fields
     * @param array<string,mixed> $props
     * @param array<string,mixed> $ctx
     * @return array<string,mixed>
     */
    public static function resolve(array $fields, array $props, array $ctx): array
    {
        $ctx = self::context($ctx);

        // Every product any field of this section names, in one catalogue call.
        $ids = [];
        foreach ($fields as $f) {
            if ($f['type'] === 'product') {
                $ids[] = (int)($props[$f['key']] ?? 0);
            } elseif ($f['type'] === 'list') {
                foreach ($f['fields'] as $sub) {
                    if ($sub['type'] === 'product') {
                        foreach ((array)($props[$f['key']] ?? []) as $item) {
                            $ids[] = (int)($item[$sub['key']] ?? 0);
                        }
                    }
                }
            }
        }
        $products = array_filter($ids) !== [] ? $ctx['catalog']->products(array_values(array_filter($ids))) : [];

        return self::resolveFields($fields, $props, $ctx, $products);
    }

    /**
     * @param list<array<string,mixed>> $fields
     * @param array<string,mixed> $props
     * @param array<string,mixed> $ctx
     * @param array<int, array<string,mixed>> $products
     * @return array<string,mixed>
     */
    private static function resolveFields(array $fields, array $props, array $ctx, array $products): array
    {
        $out = [];
        foreach ($fields as $f) {
            $key   = $f['key'];
            $value = $props[$key] ?? $f['default'];
            switch ($f['type']) {
                case 'text':
                case 'textarea':
                case 'rich':
                    $out[$key] = Text::pick($value, $ctx['lang']);
                    break;
                case 'lines':
                    $out[$key] = Text::pick($value, $ctx['lang']);
                    $out[$key . 'Lines'] = array_values(array_filter(
                        array_map('trim', explode("\n", $out[$key])),
                        static fn(string $line): bool => $line !== ''
                    ));
                    break;
                case 'link':
                    $out[$key] = self::href(is_scalar($value) ? (string)$value : '', $ctx['webRoot']);
                    break;
                case 'icon':
                    $out[$key]         = is_scalar($value) ? (string)$value : '';
                    $out[$key . 'Svg'] = Icons::svg($out[$key]);
                    break;
                case 'product':
                    $out[$key] = (int)$value;
                    $data      = $products[(int)$value] ?? null;
                    if ($data !== null) {
                        $data['orderUrl'] = self::href((string)$data['orderUrl'], $ctx['webRoot']);
                    }
                    $out[$key . 'Data'] = $data;
                    break;
                case 'list':
                    $rows = [];
                    foreach (is_array($value) ? $value : [] as $item) {
                        $rows[] = self::resolveFields($f['fields'], is_array($item) ? $item : [], $ctx, $products);
                    }
                    $out[$key] = $rows;
                    break;
                default:
                    $out[$key] = $value;
            }
        }
        return $out;
    }

    /**
     * The WHMCS data a section's schema asked for.
     *
     * @param array<string,mixed> $def
     * @param array<string,mixed> $props
     * @param array<string,mixed> $ctx
     * @return array<string,mixed>
     */
    private static function data(array $def, array $props, array $ctx): array
    {
        $out = [];
        if (in_array('announcements', $def['data'] ?? [], true)) {
            $limit = max(1, min(24, (int)($props['count'] ?? 6)));
            $items = method_exists($ctx['catalog'], 'announcements') ? $ctx['catalog']->announcements($limit, $ctx['lang']) : [];
            foreach ($items as &$item) {
                $item['url'] = self::href((string)($item['url'] ?? ''), $ctx['webRoot']);
            }
            unset($item);
            $out['announcements'] = $items;
        }
        return $out;
    }

    /** A stored link as an href: a WHMCS-relative path gets the WHMCS address in front. */
    public static function href(string $link, string $webRoot): string
    {
        if ($link === '' || preg_match('/^(https?:\/\/|mailto:|tel:|#|\/)/i', $link)) {
            return $link;
        }
        return rtrim($webRoot, '/') . '/' . $link;
    }

    /**
     * @param array<string,mixed> $ctx
     * @return array<string,mixed>
     */
    private static function context(array $ctx): array
    {
        if (!empty($ctx['_ready'])) {
            return $ctx;
        }
        $catalog = $ctx['catalog'] ?? null;
        return [
            '_ready'     => true,
            'lang'       => strtolower((string)($ctx['lang'] ?? '_')),
            'webRoot'    => rtrim((string)($ctx['webRoot'] ?? ''), '/'),
            'loggedIn'   => !empty($ctx['loggedIn']),
            'annotate'   => !empty($ctx['annotate']),
            'languages'  => is_array($ctx['languages'] ?? null) ? array_values($ctx['languages']) : [],
            'catalog'    => is_object($catalog) && method_exists($catalog, 'products') ? $catalog : new Catalog(),
            'compileDir' => (string)($ctx['compileDir'] ?? (sys_get_temp_dir() . '/hadrian-builder-smarty')),
        ];
    }

    /** @param array<string,mixed> $ctx */
    private static function smarty(array $ctx): object
    {
        if (self::$smarty === null) {
            $class  = Bridge::smartyClass();
            $smarty = new $class();
            $smarty->setCompileDir($ctx['compileDir']);
            $smarty->setCacheDir($ctx['compileDir'] . '-cache');
            $smarty->setCaching(false);
            // Section folders are the only place a template may include from.
            $smarty->setTemplateDir(Sections::dirs());
            self::$smarty = $smarty;
        }
        return self::$smarty;
    }

    /** Forget the engine (tests switch section folders between cases). */
    public static function reset(): void
    {
        self::$smarty = null;
    }
}
