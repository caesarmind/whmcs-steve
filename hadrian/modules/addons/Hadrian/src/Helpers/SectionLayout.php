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
 *   entry  := key ':' width [':' flags]
 *   width  := '1/1' | '2/3' | '1/2' | '1/3' | 'off'
 *   flags  := one or more single letters; unknown letters are ignored
 *             'e' = hide this section entirely when it has no items, instead
 *                   of rendering its empty state
 *
 * e.g. "services:1/1,domains:1/2:e,invoices:1/2,tickets:1/3,announcements:off"
 *
 * List order IS render order. 'off' hides a section but REMEMBERS its position,
 * so switching it back on restores it where it was rather than at the end.
 *
 * Flags are a THIRD field rather than a second option key so that one string
 * still describes the whole arrangement: one thing to store, to validate, and
 * to reason about when it round-trips through the editor.
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
     * Every letter the flags field may contain. The field is WHITELISTED
     * against this rather than substring-searched, because a single mistyped
     * comma puts a section key in the flags slot -- and four of the five
     * dashboard keys (services, invoices, tickets, announcements) contain an
     * 'e'. "domains:1/2:invoices:1/2" would otherwise silently grant Domains a
     * setting nobody asked for. Unrecognised content yields NO flags, which
     * matches the rest of this parser: malformed input loses information, it
     * never invents behaviour.
     */
    private const FLAG_LETTERS = 'e';

    /** How a paint is applied. Bare paint (no suffix) means solid. */
    private const FILLS = ['solid', 'tint', 'grad'];

    /**
     * @param string $raw       the stored option value
     * @param array<string, array{label?:string, w?:string}> $catalogue
     *        the sections this page offers, in factory order, with factory widths
     * @param list<string> $paints
     *        palette keys a block may be painted with. Passed in rather than
     *        hardcoded so the vocabulary has ONE home (the variant's own
     *        <variant>.php) instead of being retyped here and in the admin JS.
     *        A paint not on this list is dropped -- see the note below on why
     *        that matters more than it looks.
     * @return list<array{key:string, width:string, span:int, visible:bool,
     *                    hideEmpty:bool, paint:string, fill:string}>
     */
    public static function parse(string $raw, array $catalogue, array $paints = []): array
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
            $parts  = explode(':', $entry);
            $key    = strtolower(trim($parts[0]));
            $width  = strtolower(trim($parts[1] ?? ''));
            $flags  = strtolower(trim($parts[2] ?? ''));
            $colour = strtolower(trim($parts[3] ?? ''));

            if (!isset($catalogue[$key]) || isset($seen[$key])) {
                continue; // unknown section, or a duplicate -- first wins
            }
            if ($width !== 'off' && !isset(self::SPANS[$width])) {
                continue; // unknown width token
            }

            // Anything outside the whitelist means this is not a flags field at
            // all (most likely a comma typed as a colon) -- drop it wholesale.
            if ($flags !== '' && strspn($flags, self::FLAG_LETTERS) !== strlen($flags)) {
                $flags = '';
            }

            // Colour: "<paint>" or "<paint>_<fill>". The paint is a palette KEY,
            // never a value -- a hex could not survive the option pipeline and
            // could not carry a separate dark-mode variant.
            //
            // An unrecognised paint is dropped to ''. That is not tidiness: the
            // CSS sets `background: var(--blk-base)` and `color: var(--blk-ink)`,
            // and if no rule matched, --blk-base would be unset while --blk-ink
            // still resolved -- white text on the page background, i.e. an
            // invisible block. This whitelist is the actual guard.
            $paint = '';
            $fill  = '';
            if ($colour !== '') {
                $bits = explode('_', $colour, 2);
                $p    = $bits[0];
                $f    = $bits[1] ?? 'solid';
                if (in_array($p, $paints, true) && in_array($f, self::FILLS, true)) {
                    $paint = $p;
                    $fill  = $f;
                }
            }

            $seen[$key] = true;
            $out[] = [
                'key'       => $key,
                'width'     => $width,
                'span'      => self::SPANS[$width] ?? 6,
                'visible'   => $width !== 'off',
                'hideEmpty' => str_contains($flags, 'e'),
                'paint'     => $paint,
                'fill'      => $fill,
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
        //
        // A section marked `optIn` is appended SWITCHED OFF instead. Sections
        // added after this feature shipped are new capabilities, not corrections
        // to the original set: appending them visible would silently add blocks
        // to a dashboard an admin had already arranged and saved. They still
        // appear in the builder, so turning one on is one click -- it is just
        // never done on the admin's behalf.
        foreach ($catalogue as $key => $spec) {
            if (isset($seen[$key])) {
                continue;
            }
            $width = (string)($spec['w'] ?? '1/1');
            if (!isset(self::SPANS[$width])) {
                $width = '1/1';
            }
            $optIn = !empty($spec['optIn']);
            $out[] = [
                'key'       => (string)$key,
                'width'     => $optIn ? 'off' : $width,
                'span'      => self::SPANS[$width],
                'visible'   => !$optIn,
                'hideEmpty' => false,
                'paint'     => '',
                'fill'      => '',
            ];
        }

        return $out;
    }
}
