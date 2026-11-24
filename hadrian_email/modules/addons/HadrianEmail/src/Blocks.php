<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The block catalogue, and the only place a design document is validated.
 *
 * One schema drives three things, so they cannot drift apart:
 *   - the builder's inspector is generated from `fields` (no per-block UI code)
 *   - normalize() casts and bounds every posted value against the same list
 *   - the Renderer reads props knowing each one exists and has the right type
 *
 * A design is one of two kinds:
 *   layout   the wrapper around every email: blocks above and below one fixed
 *            "content" slot. There is one active layout.
 *   message  the body of one WHMCS email template.
 *
 * A translatable value is a map keyed by WHMCS language name with "_" holding
 * the default: {"_": "Pay now", "french": "Payer"}.
 */
final class Blocks
{
    public const KIND_LAYOUT  = 'layout';
    public const KIND_MESSAGE = 'message';

    private const MAX_BLOCKS = 60;

    private const ALIGN = ['start' => 'Start', 'center' => 'Centre', 'end' => 'End'];

    /** @return array<string, array<string,mixed>> */
    public static function types(): array
    {
        static $types = null;
        if ($types !== null) {
            return $types;
        }
        $types = [
            'header' => [
                'label' => 'Header',
                'hint'  => 'Logo and optional links',
                'scope' => self::KIND_LAYOUT,
                'fields' => [
                    ['key' => 'logo', 'type' => 'toggle', 'label' => 'Show logo', 'default' => true],
                    ['key' => 'logoWidth', 'type' => 'number', 'label' => 'Logo width', 'unit' => 'px', 'min' => 60, 'max' => 280, 'default' => 140],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => ['start' => 'Start', 'center' => 'Centre'], 'default' => 'start'],
                    ['key' => 'tagline', 'type' => 'text', 'label' => 'Tagline', 'translatable' => true, 'default' => ''],
                    ['key' => 'subject', 'type' => 'toggle', 'label' => 'Show the email subject', 'help' => 'Each email\'s subject as a title under your logo. The Banner design puts it on the band.', 'default' => false],
                    ['key' => 'nav', 'type' => 'links', 'label' => 'Links', 'max' => 4, 'default' => [
                        ['label' => ['_' => 'Client Area'], 'url' => '{$whmcs_url}'],
                    ]],
                ],
            ],
            'content' => [
                'label' => 'Email content',
                'hint'  => 'Where each email\'s own message goes',
                'scope' => self::KIND_LAYOUT,
                'fixed' => true,
                'fields' => [
                    ['key' => 'card', 'type' => 'toggle', 'label' => 'Show as a card', 'default' => true],
                    ['key' => 'padding', 'type' => 'select', 'label' => 'Padding', 'options' => ['compact' => 'Compact', 'regular' => 'Regular', 'roomy' => 'Roomy'], 'default' => 'regular'],
                ],
            ],
            'footer' => [
                'label' => 'Footer',
                'hint'  => 'Company details, links and unsubscribe',
                'scope' => self::KIND_LAYOUT,
                'fields' => [
                    ['key' => 'text', 'type' => 'rich', 'label' => 'Text', 'translatable' => true,
                        'default' => ['_' => "<p>\u{00A9} {\$hx_year} {\$companyname}. All rights reserved.</p>"]],
                    ['key' => 'links', 'type' => 'links', 'label' => 'Links', 'max' => 8, 'default' => []],
                    ['key' => 'social', 'type' => 'toggle', 'label' => 'Show social links', 'help' => 'Uses the profiles set on the Branding page.', 'default' => true],
                    ['key' => 'unsubscribe', 'type' => 'toggle', 'label' => 'Show unsubscribe link', 'help' => 'Only appears on emails WHMCS gives an unsubscribe link to.', 'default' => true],
                    ['key' => 'unsubscribeLabel', 'type' => 'text', 'label' => 'Unsubscribe text', 'translatable' => true, 'default' => ['_' => 'Unsubscribe']],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => ['start' => 'Start', 'center' => 'Centre'], 'default' => 'center'],
                ],
            ],
            'heading' => [
                'label' => 'Heading',
                'hint'  => 'A title line',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => 'Heading']],
                    ['key' => 'level', 'type' => 'select', 'label' => 'Size', 'options' => ['1' => 'Large', '2' => 'Medium', '3' => 'Small'], 'default' => '1'],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => self::ALIGN, 'default' => 'start'],
                ],
            ],
            'text' => [
                'label' => 'Text',
                'hint'  => 'Paragraphs with merge fields',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'html', 'type' => 'rich', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '<p>Write your message here.</p>']],
                    ['key' => 'size', 'type' => 'select', 'label' => 'Size', 'options' => ['small' => 'Small', 'normal' => 'Normal', 'large' => 'Large'], 'default' => 'normal'],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => self::ALIGN, 'default' => 'start'],
                    ['key' => 'muted', 'type' => 'toggle', 'label' => 'Secondary colour', 'default' => false],
                ],
            ],
            'button' => [
                'label' => 'Button',
                'hint'  => 'One primary action',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'Open client area']],
                    ['key' => 'url', 'type' => 'url', 'label' => 'Link', 'default' => '{$whmcs_url}'],
                    ['key' => 'style', 'type' => 'select', 'label' => 'Style', 'options' => ['primary' => 'Filled', 'secondary' => 'Tinted'], 'default' => 'primary'],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => self::ALIGN, 'default' => 'start'],
                    ['key' => 'full', 'type' => 'toggle', 'label' => 'Full width', 'default' => false],
                ],
            ],
            'details' => [
                'label' => 'Details',
                'hint'  => 'Label and value rows',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'rows', 'type' => 'rows', 'label' => 'Rows', 'max' => 20, 'default' => [
                        ['label' => ['_' => 'Label'], 'value' => 'Value'],
                    ]],
                    ['key' => 'boxed', 'type' => 'toggle', 'label' => 'Tinted box', 'default' => true],
                ],
            ],
            'callout' => [
                'label' => 'Callout',
                'hint'  => 'A highlighted note',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'html', 'type' => 'rich', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '<p>Something worth noticing.</p>']],
                    ['key' => 'tone', 'type' => 'select', 'label' => 'Tone', 'options' => ['info' => 'Info', 'success' => 'Success', 'warning' => 'Warning', 'danger' => 'Danger'], 'default' => 'info'],
                ],
            ],
            'image' => [
                'label' => 'Image',
                'hint'  => 'PNG or JPG, with an optional link',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'src', 'type' => 'image', 'label' => 'Image', 'default' => ''],
                    ['key' => 'alt', 'type' => 'text', 'label' => 'Alt text', 'translatable' => true, 'default' => ''],
                    ['key' => 'width', 'type' => 'number', 'label' => 'Width', 'unit' => 'px', 'min' => 40, 'max' => 600, 'default' => 536],
                    ['key' => 'href', 'type' => 'url', 'label' => 'Link', 'default' => ''],
                    ['key' => 'align', 'type' => 'select', 'label' => 'Alignment', 'options' => self::ALIGN, 'default' => 'center'],
                    ['key' => 'rounded', 'type' => 'toggle', 'label' => 'Rounded corners', 'default' => true],
                ],
            ],
            'divider' => [
                'label' => 'Divider',
                'hint'  => 'A thin rule',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'space', 'type' => 'select', 'label' => 'Spacing', 'options' => ['small' => 'Small', 'medium' => 'Medium', 'large' => 'Large'], 'default' => 'medium'],
                ],
            ],
            'spacer' => [
                'label' => 'Spacer',
                'hint'  => 'Empty vertical space',
                'scope' => 'both',
                'fields' => [
                    ['key' => 'height', 'type' => 'number', 'label' => 'Height', 'unit' => 'px', 'min' => 4, 'max' => 96, 'default' => 24],
                ],
            ],
            'html' => [
                'label' => 'HTML',
                'hint'  => 'Raw HTML or Smarty, for loops and tables',
                'scope' => self::KIND_MESSAGE,
                'fields' => [
                    ['key' => 'code', 'type' => 'code', 'label' => 'Code', 'help' => 'Sent as written. Use it for {foreach} loops and merge fields that return HTML, such as {$invoice_html_contents}.', 'default' => ''],
                ],
            ],
        ];
        return $types;
    }

    /** Block types a design of this kind may contain, in palette order. */
    public static function typesFor(string $kind): array
    {
        $out = [];
        foreach (self::types() as $type => $def) {
            if ($def['scope'] === 'both' || $def['scope'] === $kind) {
                $out[$type] = $def;
            }
        }
        return $out;
    }

    public static function newId(): string
    {
        return 'b' . bin2hex(random_bytes(5));
    }

    /** @return array{id:string,type:string,props:array<string,mixed>} */
    public static function make(string $type, array $props = []): array
    {
        return self::normalizeBlock(['id' => self::newId(), 'type' => $type, 'props' => $props], [])
            ?? ['id' => self::newId(), 'type' => 'spacer', 'props' => ['height' => 24]];
    }

    /**
     * Validate a whole document. Anything not in the schema is dropped, every
     * value is cast and bounded, and a layout always ends up with exactly one
     * content slot.
     *
     * @param array<string,mixed> $doc
     * @param list<string> $languages  installed WHMCS languages (translation keys allowed)
     * @return array{v:int,settings:array<string,mixed>,blocks:list<array<string,mixed>>}
     */
    public static function normalize(array $doc, string $kind, array $languages = []): array
    {
        $kind    = $kind === self::KIND_LAYOUT ? self::KIND_LAYOUT : self::KIND_MESSAGE;
        $allowed = self::typesFor($kind);
        $blocks  = [];
        $seen    = [];
        $slot    = false;

        foreach ((array)($doc['blocks'] ?? []) as $raw) {
            if (count($blocks) >= self::MAX_BLOCKS || !is_array($raw)) {
                continue;
            }
            $type = (string)($raw['type'] ?? '');
            if (!isset($allowed[$type])) {
                continue;
            }
            if ($type === 'content') {
                if ($slot) {
                    continue;
                }
                $slot = true;
            }
            $block = self::normalizeBlock($raw, $languages);
            if ($block === null) {
                continue;
            }
            if (isset($seen[$block['id']])) {
                $block['id'] = self::newId();
            }
            $seen[$block['id']] = true;
            $blocks[] = $block;
        }

        if ($kind === self::KIND_LAYOUT && !$slot) {
            // Put the slot after the header if there is one, else first.
            $at = 0;
            foreach ($blocks as $i => $b) {
                if ($b['type'] === 'header') {
                    $at = $i + 1;
                }
            }
            array_splice($blocks, $at, 0, [self::make('content')]);
        }

        $settings = is_array($doc['settings'] ?? null) ? $doc['settings'] : [];
        $out = [
            'subject'   => self::l10n($settings['subject'] ?? '', $languages, 250, false),
            'preheader' => self::l10n($settings['preheader'] ?? '', $languages, 250, false),
        ];
        if ($kind === self::KIND_LAYOUT) {
            $out['design'] = Designs::valid(is_scalar($settings['design'] ?? null) ? (string)$settings['design'] : '');
        }
        return [
            'v'        => 1,
            'settings' => $out,
            'blocks'   => $blocks,
        ];
    }

    /**
     * @param array<string,mixed> $raw
     * @param list<string> $languages
     * @return array{id:string,type:string,props:array<string,mixed>}|null
     */
    private static function normalizeBlock(array $raw, array $languages): ?array
    {
        $type = (string)($raw['type'] ?? '');
        $def  = self::types()[$type] ?? null;
        if ($def === null) {
            return null;
        }
        $id = (string)($raw['id'] ?? '');
        if (!preg_match('/^b[a-f0-9]{6,16}$/', $id)) {
            $id = self::newId();
        }
        $in    = is_array($raw['props'] ?? null) ? $raw['props'] : [];
        $props = [];
        foreach ($def['fields'] as $f) {
            $key   = (string)$f['key'];
            $value = array_key_exists($key, $in) ? $in[$key] : $f['default'];
            $props[$key] = self::cast($f, $value, $languages);
        }
        return ['id' => $id, 'type' => $type, 'props' => $props];
    }

    /**
     * @param array<string,mixed> $f
     * @param list<string> $languages
     */
    private static function cast(array $f, mixed $value, array $languages): mixed
    {
        $translatable = !empty($f['translatable']);
        switch ($f['type']) {
            case 'toggle':
                return $value === true || $value === 1 || $value === '1' || $value === 'true' || $value === 'on';

            case 'number':
                $n = is_numeric($value) ? (int)round((float)$value) : (int)$f['default'];
                return max((int)$f['min'], min((int)$f['max'], $n));

            case 'select':
                $v = is_scalar($value) ? (string)$value : '';
                return array_key_exists($v, (array)$f['options']) ? $v : (string)$f['default'];

            case 'text':
                return $translatable
                    ? self::l10n($value, $languages, 500, false)
                    : self::line(is_scalar($value) ? (string)$value : '', 500);

            case 'rich':
                return $translatable
                    ? self::l10n($value, $languages, 20000, true)
                    : Sanitizer::rich(is_scalar($value) ? (string)$value : '');

            case 'url':
                return self::url(is_scalar($value) ? (string)$value : '');

            case 'image':
                return self::imageUrl(is_scalar($value) ? (string)$value : '');

            case 'code':
                $v = is_scalar($value) ? (string)$value : '';
                return strlen($v) > 60000 ? substr($v, 0, 60000) : $v;

            case 'links':
            case 'rows':
                $second = $f['type'] === 'links' ? 'url' : 'value';
                $out = [];
                foreach ((array)$value as $item) {
                    if (count($out) >= (int)($f['max'] ?? 10) || !is_array($item)) {
                        continue;
                    }
                    $raw2 = is_scalar($item[$second] ?? null) ? (string)$item[$second] : '';
                    $out[] = [
                        'label'  => self::l10n($item['label'] ?? '', $languages, 200, false),
                        $second  => $second === 'url' ? self::url($raw2) : self::line($raw2, 500),
                    ];
                }
                return $out;
        }
        return $f['default'];
    }

    /**
     * Normalise a translatable value to its map form.
     *
     * @param list<string> $languages
     * @return array<string,string>
     */
    private static function l10n(mixed $value, array $languages, int $max, bool $rich): array
    {
        $clean = static fn(string $s): string => $rich ? Sanitizer::rich($s, $max) : self::line($s, $max);
        if (is_scalar($value)) {
            return ['_' => $clean((string)$value)];
        }
        if (!is_array($value)) {
            return ['_' => ''];
        }
        $out = ['_' => $clean(is_scalar($value['_'] ?? null) ? (string)$value['_'] : '')];
        foreach ($value as $lang => $text) {
            $lang = strtolower((string)$lang);
            if ($lang === '_' || !is_scalar($text) || !preg_match('/^[a-z][a-z0-9_-]{1,40}$/', $lang)) {
                continue;
            }
            // Unknown languages are dropped when the caller knows the list;
            // with no list (tests, CLI) the shape check above is the gate.
            if ($languages !== [] && !in_array($lang, $languages, true)) {
                continue;
            }
            $t = $clean((string)$text);
            if ($t !== '') {
                $out[$lang] = $t;
            }
        }
        return $out;
    }

    private static function line(string $s, int $max): string
    {
        $s = trim((string)preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F]/', '', $s));
        $s = (string)preg_replace('/\s*[\r\n]+\s*/', ' ', $s);
        return function_exists('mb_substr') ? mb_substr($s, 0, $max) : substr($s, 0, $max);
    }

    /** A link: web, mail, phone, or something built from merge fields. */
    private static function url(string $s): string
    {
        $s = self::line($s, 2000);
        if ($s === '') {
            return '';
        }
        if (preg_match('/^\s*(javascript|data|vbscript|file):/i', $s)) {
            return '';
        }
        if (preg_match('/^(https?:\/\/|mailto:|tel:|\{)/i', $s)) {
            return $s;
        }
        // A bare domain or path: assume the admin meant a web address.
        return preg_match('/^[a-z0-9.-]+\.[a-z]{2,}(\/|$)/i', $s) ? 'https://' . $s : '';
    }

    /** An image an email client can fetch: absolute http(s), or a site-root path we make absolute later. */
    private static function imageUrl(string $s): string
    {
        $s = self::line($s, 2000);
        if ($s === '') {
            return '';
        }
        if (preg_match('/^https?:\/\//i', $s) || (str_starts_with($s, '/') && !str_starts_with($s, '//'))) {
            return $s;
        }
        return '';
    }
}
