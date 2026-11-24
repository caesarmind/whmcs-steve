<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The section catalogue, and the only place a section's values are validated.
 *
 * A section is a folder holding two files named after it, the same shape as a
 * Hadrian page variant:
 *
 *   sections/<name>/<name>.php   the schema: label, group and field list
 *   sections/<name>/<name>.tpl   the markup
 *
 * One schema drives three things, so they cannot drift apart:
 *   - the editor's inspector is generated from `fields` (no per-section UI code)
 *   - normalize() casts and bounds every posted value against the same list
 *   - the Renderer reads props knowing each one exists and has the right type
 *
 * Sections ship in this module's sections/ folder. A theme can replace a
 * section's markup, or add a section of its own, under
 * templates/<theme>/core/sections/<name>/.
 *
 * Field types:
 *   text      one line                      textarea  plain text with line breaks
 *   rich      sanitised HTML                select    one of `options`
 *   toggle    bool                          number    int within min..max
 *   link      a URL or WHMCS-relative path  image     an image address
 *   icon      a name from Icons             product   a WHMCS product id
 *   lines     plain text, one entry per line; a template also gets `<key>Lines`
 *   list      repeatable items, each with its own `fields` (no list inside a list)
 *
 * text, textarea, lines and rich may be flagged `translatable`; their value is
 * then a language map (see Text).
 *
 * A schema may also name WHMCS data the section shows, with `'data' => [...]`.
 * The one source so far is 'announcements': the template then gets
 * `$data.announcements`, the newest published announcements (as many as the
 * section's `count` field says, 6 without one).
 */
final class Sections
{
    private const SCALAR_TYPES = ['text', 'textarea', 'lines', 'rich', 'select', 'toggle', 'number', 'link', 'image', 'icon', 'product'];

    /** WHMCS data a schema may ask for with `data`. */
    public const DATA_SOURCES = ['announcements'];

    /** @var list<string>|null directories searched, later ones win */
    private static ?array $dirs = null;

    /** @var array<string, array<string,mixed>>|null */
    private static ?array $types = null;

    /**
     * Point the catalogue at specific folders. For tests and tools; inside
     * WHMCS the default is this module's folder plus the active theme's.
     *
     * @param list<string>|null $dirs
     */
    public static function setDirs(?array $dirs): void
    {
        self::$dirs  = $dirs;
        self::$types = null;
    }

    /** @return list<string> */
    public static function dirs(): array
    {
        if (self::$dirs !== null) {
            return self::$dirs;
        }
        $dirs = [dirname(__DIR__) . '/sections'];
        if (defined('ROOTDIR')) {
            $slug = preg_replace('/[^A-Za-z0-9_-]/', '', Bridge::templateSlug()) ?? '';
            if ($slug !== '') {
                $dirs[] = ROOTDIR . '/templates/' . $slug . '/core/sections';
            }
        }
        return self::$dirs = $dirs;
    }

    /**
     * Every section that has both its files, keyed by name, in palette order.
     *
     * @return array<string, array<string,mixed>>
     */
    public static function types(): array
    {
        if (self::$types !== null) {
            return self::$types;
        }
        $found = [];
        foreach (self::dirs() as $dir) {
            foreach (glob($dir . '/*', GLOB_ONLYDIR) ?: [] as $folder) {
                $name = basename($folder);
                if (!preg_match('/^[a-z][a-z0-9-]{1,40}$/', $name)) {
                    continue;
                }
                $tpl = $folder . '/' . $name . '.tpl';
                $php = $folder . '/' . $name . '.php';
                if (is_file($php)) {
                    $def = self::load($php);
                    if ($def !== null) {
                        $found[$name] = $def + ['template' => $found[$name]['template'] ?? ''];
                    }
                }
                // A folder with only a .tpl replaces the markup of a section
                // an earlier folder defined.
                if (is_file($tpl) && isset($found[$name])) {
                    $found[$name]['template'] = $tpl;
                }
            }
        }
        $types = [];
        foreach ($found as $name => $def) {
            if ($def['template'] !== '') {
                $types[$name] = $def;
            }
        }
        uasort($types, static fn(array $a, array $b): int => [$a['order'], $a['label']] <=> [$b['order'], $b['label']]);
        return self::$types = $types;
    }

    /** @return array<string,mixed>|null */
    public static function type(string $name): ?array
    {
        return self::types()[$name] ?? null;
    }

    /** What the editor needs: every type without its template path. */
    public static function forEditor(): array
    {
        $out = [];
        foreach (self::types() as $name => $def) {
            unset($def['template']);
            $out[$name] = $def;
        }
        return $out;
    }

    /** @return array<string,mixed>|null */
    private static function load(string $file): ?array
    {
        try {
            $raw = require $file;
        } catch (\Throwable $e) {
            error_log('Hadrian Page Builder: section schema failed to load: ' . $file . ': ' . $e->getMessage());
            return null;
        }
        if (!is_array($raw) || !is_array($raw['fields'] ?? null)) {
            return null;
        }
        $fields = [];
        foreach ($raw['fields'] as $f) {
            $field = self::field($f, true);
            if ($field !== null) {
                $fields[] = $field;
            }
        }
        return [
            'label'  => Text::line((string)($raw['label'] ?? ''), 60) ?: basename(dirname($file)),
            'hint'   => Text::line((string)($raw['hint'] ?? ''), 160),
            'group'  => Text::line((string)($raw['group'] ?? ''), 40) ?: 'Other',
            'order'  => (int)($raw['order'] ?? 500),
            'data'   => array_values(array_intersect(array_map('strval', (array)($raw['data'] ?? [])), self::DATA_SOURCES)),
            'fields' => $fields,
        ];
    }

    /**
     * A field definition with every key the engine reads filled in, or null
     * when it cannot be used.
     *
     * @return array<string,mixed>|null
     */
    private static function field(mixed $f, bool $allowList): ?array
    {
        if (!is_array($f) || !preg_match('/^[a-z][A-Za-z0-9]{0,30}$/', (string)($f['key'] ?? ''))) {
            return null;
        }
        $type = (string)($f['type'] ?? '');
        $out  = [
            'key'   => (string)$f['key'],
            'type'  => $type,
            'label' => Text::line((string)($f['label'] ?? $f['key']), 80),
            'help'  => Text::line((string)($f['help'] ?? ''), 240),
        ];

        if ($type === 'list') {
            if (!$allowList || !is_array($f['fields'] ?? null)) {
                return null;
            }
            $sub = [];
            foreach ($f['fields'] as $s) {
                $field = self::field($s, false);
                if ($field !== null) {
                    $sub[] = $field;
                }
            }
            if ($sub === []) {
                return null;
            }
            return $out + [
                'fields'    => $sub,
                'max'       => max(1, min(40, (int)($f['max'] ?? 12))),
                'itemLabel' => (string)($f['itemLabel'] ?? $sub[0]['key']),
                'addLabel'  => Text::line((string)($f['addLabel'] ?? 'Add item'), 40),
                'default'   => is_array($f['default'] ?? null) ? array_values($f['default']) : [],
            ];
        }

        if (!in_array($type, self::SCALAR_TYPES, true)) {
            return null;
        }
        $out['translatable'] = in_array($type, ['text', 'textarea', 'lines', 'rich'], true) && !empty($f['translatable']);
        $out['default']      = $f['default'] ?? self::emptyFor($type);
        if ($type === 'select') {
            $options = is_array($f['options'] ?? null) ? $f['options'] : [];
            if ($options === []) {
                return null;
            }
            $out['options'] = array_map('strval', $options);
            if (!array_key_exists((string)$out['default'], $out['options'])) {
                $out['default'] = (string)array_key_first($out['options']);
            }
        }
        if ($type === 'number') {
            $out['min']  = (int)($f['min'] ?? 0);
            $out['max']  = (int)($f['max'] ?? 1000);
            $out['unit'] = Text::line((string)($f['unit'] ?? ''), 8);
        }
        return $out;
    }

    private static function emptyFor(string $type): mixed
    {
        return match ($type) {
            'toggle'  => false,
            'number', 'product' => 0,
            default   => '',
        };
    }

    // ----------------------------------------------------------- validation

    /**
     * Cast one section's props against its schema. Anything the schema does
     * not name is dropped; anything missing gets its default.
     *
     * @param array<string,mixed> $def
     * @param array<string,mixed> $in
     * @param list<string> $languages installed WHMCS languages (translation keys allowed)
     * @return array<string,mixed>
     */
    public static function normalizeProps(array $def, array $in, array $languages): array
    {
        $props = [];
        foreach ($def['fields'] as $f) {
            $key         = $f['key'];
            $props[$key] = self::cast($f, array_key_exists($key, $in) ? $in[$key] : $f['default'], $languages);
        }
        return $props;
    }

    /**
     * @param array<string,mixed> $f
     * @param list<string> $languages
     */
    private static function cast(array $f, mixed $value, array $languages): mixed
    {
        $str = static fn(mixed $v): string => is_scalar($v) ? (string)$v : '';

        switch ($f['type']) {
            case 'toggle':
                return $value === true || $value === 1 || $value === '1' || $value === 'true' || $value === 'on';

            case 'number':
                $n = is_numeric($value) ? (int)round((float)$value) : (int)$f['default'];
                return max((int)$f['min'], min((int)$f['max'], $n));

            case 'product':
                return is_numeric($value) ? max(0, (int)$value) : 0;

            case 'select':
                $v = $str($value);
                return array_key_exists($v, $f['options']) ? $v : (string)$f['default'];

            case 'icon':
                $v = $str($value);
                return Icons::has($v) ? $v : '';

            case 'text':
                return $f['translatable']
                    ? self::l10n($value, $languages, static fn(string $s): string => Text::line($s, 500))
                    : Text::line($str($value), 500);

            case 'textarea':
            case 'lines':
                return $f['translatable']
                    ? self::l10n($value, $languages, static fn(string $s): string => Text::block($s, 4000))
                    : Text::block($str($value), 4000);

            case 'rich':
                return $f['translatable']
                    ? self::l10n($value, $languages, static fn(string $s): string => Sanitizer::rich($s))
                    : Sanitizer::rich($str($value));

            case 'link':
                return Text::link($str($value));

            case 'image':
                return Text::image($str($value));

            case 'list':
                $out = [];
                foreach (is_array($value) ? $value : [] as $item) {
                    if (count($out) >= (int)$f['max'] || !is_array($item)) {
                        continue;
                    }
                    $row = [];
                    foreach ($f['fields'] as $sub) {
                        $row[$sub['key']] = self::cast(
                            $sub,
                            array_key_exists($sub['key'], $item) ? $item[$sub['key']] : $sub['default'],
                            $languages
                        );
                    }
                    $out[] = $row;
                }
                return $out;
        }
        return $f['default'];
    }

    /**
     * Normalise a translatable value to its map form.
     *
     * @param list<string> $languages
     * @param callable(string):string $clean
     * @return array<string,string>
     */
    public static function l10n(mixed $value, array $languages, callable $clean): array
    {
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
}
