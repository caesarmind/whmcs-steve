<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Parser for the dashboard section-layout option.
 *
 * Page options can only ever hold a SCALAR: PagesController::saveAction runs
 * every declared option through a match() whose arms all return bool|int|string,
 * so an array POSTed as option[k][] stringifies to the literal "Array". The
 * layout is therefore stored as one short string and parsed here, in PHP, so no
 * parsing logic has to live in Smarty.
 *
 * GRAMMAR
 *   layout := '' | entry (',' entry)*
 *   entry  := key ':' width
 *   width  := '1/1' | '2/3' | '1/2' | '1/3' | 'off'
 *
 * e.g. "services:1/1,domains:1/2,invoices:1/2,tickets:1/3,announcements:off"
 *
 * List order IS render order. 'off' hides a section but REMEMBERS its position,
 * so switching it back on restores it where it was rather than at the end.
 *
 * The charset is [a-z0-9_:,/] -- none of the five characters htmlspecialchars
 * touches -- so the value survives WHMCS's POST-time encoding and the admin
 * field's |escape byte-identically across repeated saves.
 *
 * This parser is TOTAL: the stored string is never validated on save (it rides
 * the editor's catch-all text input), so anything unrecognised is dropped
 * silently rather than thrown. A malformed entry loses its placement; it never
 * breaks the page.
 */
final class SectionLayout
{
    /** width token => grid span out of 6 columns. */
    private const SPANS = ['1/1' => 6, '2/3' => 4, '1/2' => 3, '1/3' => 2];

    /**
     * @param string $raw       the stored option value
     * @param array<string, array{label?:string, w?:string}> $catalogue
     *        the sections this page offers, in factory order, with factory widths
     * @return list<array{key:string, width:string, span:int, visible:bool}>
     */
    public static function parse(string $raw, array $catalogue): array
    {
        $raw = trim($raw);

        // THE LOAD-BEARING ASYMMETRY: an empty option means "no admin layout",
        // NOT "every section at its factory width". It must return [] so the
        // template picks its classic hand-packed shell. Expanding '' to the full
        // catalogue here would flip every existing install onto the grid the
        // moment this code deployed, with nobody having asked for it.
        if ($raw === '' || $catalogue === []) {
            return [];
        }

        $out  = [];
        $seen = [];
        foreach (explode(',', $raw) as $entry) {
            $entry = trim($entry);
            if ($entry === '' || !str_contains($entry, ':')) {
                continue;
            }
            [$key, $width] = explode(':', $entry, 2);
            $key   = strtolower(trim($key));
            $width = strtolower(trim($width));

            if (!isset($catalogue[$key]) || isset($seen[$key])) {
                continue; // unknown section, or a duplicate -- first wins
            }
            if ($width !== 'off' && !isset(self::SPANS[$width])) {
                continue; // unknown width token
            }

            $seen[$key] = true;
            $out[] = [
                'key'     => $key,
                'width'   => $width,
                'span'    => self::SPANS[$width] ?? 6,
                'visible' => $width !== 'off',
            ];
        }

        // Nothing recognised at all (e.g. the admin typed gibberish): fall back
        // to the classic shell rather than rendering an empty dashboard.
        if ($out === []) {
            return [];
        }

        // Append any catalogue section the stored string never mentioned, at its
        // factory width. This is what makes a section added in a later release
        // show up in layouts admins saved before it existed, instead of
        // silently vanishing from their dashboard.
        foreach ($catalogue as $key => $spec) {
            if (isset($seen[$key])) {
                continue;
            }
            $width = (string)($spec['w'] ?? '1/1');
            if (!isset(self::SPANS[$width])) {
                $width = '1/1';
            }
            $out[] = [
                'key'     => (string)$key,
                'width'   => $width,
                'span'    => self::SPANS[$width],
                'visible' => true,
            ];
        }

        return $out;
    }
}
