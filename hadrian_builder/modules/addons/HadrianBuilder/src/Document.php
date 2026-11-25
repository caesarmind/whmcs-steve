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
