<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * A page's content: an ordered list of sections.
 *
 *   {
 *     "v": 1,
 *     "sections": [
 *       {
 *         "id": "s3f9a1c2e7b",
 *         "type": "hero-split",
 *         "props": { ...the section's own fields... },
 *         "style": { "spacing": "regular", "anchor": "" },
 *         "hidden": false
 *       }
 *     ]
 *   }
 *
 * Layout and settings are stored once. Only fields flagged translatable hold
 * a value per language. normalize() is the gate every document passes on its
 * way in (save, preview) and again on its way out (render), so a row edited
 * by hand in the database is cleaned the same way as a posted one.
 */
final class Document
{
    public const VERSION = 1;

    // Room for every section in the library at once, with space to spare.
    private const MAX_SECTIONS = 100;

    public const SPACING = ['regular' => 'Regular', 'compact' => 'Compact', 'roomy' => 'Roomy'];

    public static function newId(): string
    {
        return 's' . bin2hex(random_bytes(5));
    }

    /** @return array{v:int,sections:list<array<string,mixed>>} */
    public static function blank(): array
    {
        return ['v' => self::VERSION, 'sections' => []];
    }

    /**
     * A new section of this type with its default content.
     *
     * @return array<string,mixed>|null null for an unknown type
     */
    public static function make(string $type, array $languages = []): ?array
    {
        return self::normalizeSection(['type' => $type], $languages);
    }

    /**
     * @param array<string,mixed> $doc
     * @param list<string> $languages installed WHMCS languages
     * @return array{v:int,sections:list<array<string,mixed>>}
     */
    public static function normalize(array $doc, array $languages = []): array
    {
        $sections = [];
        $seen     = [];
        foreach ((array)($doc['sections'] ?? []) as $raw) {
            if (count($sections) >= self::MAX_SECTIONS || !is_array($raw)) {
                continue;
            }
            $section = self::normalizeSection($raw, $languages);
            if ($section === null) {
                continue;       // a type that no longer exists
            }
            if (isset($seen[$section['id']])) {
                $section['id'] = self::newId();
            }
            $seen[$section['id']] = true;
            $sections[] = $section;
        }
        return ['v' => self::VERSION, 'sections' => $sections];
    }

    /**
     * @param array<string,mixed> $raw
     * @param list<string> $languages
     * @return array<string,mixed>|null
     */
    private static function normalizeSection(array $raw, array $languages): ?array
    {
        $type = is_scalar($raw['type'] ?? null) ? (string)$raw['type'] : '';
        $def  = Sections::type($type);
        if ($def === null) {
            return null;
        }
        $id = is_scalar($raw['id'] ?? null) ? (string)$raw['id'] : '';
        if (!preg_match('/^s[a-f0-9]{6,16}$/', $id)) {
            $id = self::newId();
        }
        $style   = is_array($raw['style'] ?? null) ? $raw['style'] : [];
        $spacing = is_scalar($style['spacing'] ?? null) ? (string)$style['spacing'] : '';

        return [
            'id'     => $id,
            'type'   => $type,
            'props'  => Sections::normalizeProps($def, is_array($raw['props'] ?? null) ? $raw['props'] : [], $languages),
            'style'  => [
                'spacing' => isset(self::SPACING[$spacing]) ? $spacing : 'regular',
                'anchor'  => Text::anchor(is_scalar($style['anchor'] ?? null) ? (string)$style['anchor'] : ''),
            ],
            'hidden' => !empty($raw['hidden']) && $raw['hidden'] !== 'false' && $raw['hidden'] !== '0',
        ];
    }

    /**
     * Visit every value in a document together with the field it belongs to,
     * and put back what the visitor returns. Fields inside a list are visited
     * one item at a time; the list itself is not.
     *
     * This is how anything that must find "every image" or "every product" on
     * a page does it without knowing a single section: the schema says which
     * value is which. It reads a document as stored or as it arrived in a
     * file, so it is tolerant: a section of an unknown type, props that are
     * not an array and values a section does not carry are left as they are.
     *
     * @param array<string,mixed> $doc
     * @param callable(array<string,mixed> $field, mixed $value, string $sectionType): mixed $visit
     * @return array<string,mixed> the document with the returned values
     */
    public static function walk(array $doc, callable $visit): array
    {
        if (!is_array($doc['sections'] ?? null)) {
            return $doc;
        }
        foreach ($doc['sections'] as $i => $section) {
            $type = is_array($section) && is_scalar($section['type'] ?? null) ? (string)$section['type'] : '';
            $def  = $type !== '' ? Sections::type($type) : null;
            if ($def === null || !is_array($section['props'] ?? null)) {
                continue;
            }
            $doc['sections'][$i]['props'] = self::walkFields($def['fields'], $section['props'], $type, $visit);
        }
        return $doc;
    }

    /**
     * @param list<array<string,mixed>> $fields
     * @param array<string,mixed> $values
     * @return array<string,mixed>
     */
    private static function walkFields(array $fields, array $values, string $type, callable $visit): array
    {
        foreach ($fields as $f) {
            $key = $f['key'];
            if (!array_key_exists($key, $values)) {
                continue;
            }
            if ($f['type'] !== 'list') {
                $values[$key] = $visit($f, $values[$key], $type);
                continue;
            }
            if (!is_array($values[$key])) {
                continue;
            }
            foreach ($values[$key] as $n => $item) {
                if (is_array($item)) {
                    $values[$key][$n] = self::walkFields($f['fields'], $item, $type, $visit);
                }
            }
        }
        return $values;
    }

    /** How many sections a page holds; the ones after that are dropped. */
    public static function maxSections(): int
    {
        return self::MAX_SECTIONS;
    }

    /**
     * Page-level texts: the browser title and the search description.
     *
     * @param array<string,mixed> $meta
     * @param list<string> $languages
     * @return array{title:array<string,string>,description:array<string,string>}
     */
    public static function normalizeMeta(array $meta, array $languages = []): array
    {
        return [
            'title'       => Sections::l10n($meta['title'] ?? '', $languages, static fn(string $s): string => Text::line($s, 120)),
            'description' => Sections::l10n($meta['description'] ?? '', $languages, static fn(string $s): string => Text::line($s, 320)),
        ];
    }

    /** Stable JSON, so two documents can be compared as strings. */
    public static function encode(array $doc): string
    {
        return (string)json_encode($doc, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
    }
}
