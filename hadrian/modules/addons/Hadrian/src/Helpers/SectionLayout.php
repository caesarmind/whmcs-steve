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
 *   entry  := key ':' width [':' flags [':' colour [':' rows]]]
 *   width  := '1/1' | '2/3' | '1/2' | '1/3' | 'off'
 *   flags  := one or more single letters; unknown letters are ignored
 *             'e' = hide this section entirely when it has no items, instead
 *                   of rendering its empty state
 *             'l' = drop this section's row list, leaving whatever summary the
 *                   section renders above it. Only sections that declare a
 *                   `listToggle` offer it -- for most, a list with no rows is
 *                   just an empty box.
 *   colour := paint | paint '_' fill | paint '_' fill '_' memo
 *   paint  := a palette KEY (tracks Styles > Colors), or 'hex' + rrggbb for a
 *             one-off colour that deliberately does NOT track it
 *   fill   := solid | tint | grad
 *   memo   := the paint of the mode that is NOT active, remembered so the
 *             admin's Theme/Custom switch flips back without losing it.
 *             Parsed past and DISCARDED here -- see the note in parse().
 *   rows   := 1-99, how many items this section shows; 0/absent = page default
 *
 * The fields are POSITIONAL, so a later one needs the earlier ones present as
 * empty placeholders: "profile:1/3:::6" is rows=6 with no flags and no colour.
 *
 * e.g. "services:1/1,domains:1/2:e,invoices:1/2::accent_tint,tickets:1/3:::3"
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
     *
     * strspn wants EVERY character in the set, which is what keeps this safe as
     * letters are added: no catalogue key is spelled from 'e' and 'l' alone, so
     * a key landing in this slot still fails whole.
     */
    private const FLAG_LETTERS = 'el';

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
     *                    hideEmpty:bool, hideList:bool, paint:string, fill:string,
     *                    rows:int, custom:string}>
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
            $rowsIn = trim($parts[4] ?? '');

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

            // Colour: "<paint>", "<paint>_<fill>", or "<paint>_<fill>_<memo>".
            //
            // Segment 1 is the ACTIVE paint and alone decides the mode: a
            // palette KEY follows Styles > Colors, 'hex' + rrggbb deliberately
            // does not. The two vocabularies are disjoint, so the mode is
            // DERIVED rather than stored -- a stored mode could contradict its
            // own paint ("theme, hexaabbcc") with no non-arbitrary way to
            // resolve it. A derived mode cannot disagree with itself. This is
            // why no palette key may ever match /^hex[0-9a-f]{6}$/; the
            // APPEND ONLY note on each variant's `paints` list says so too.
            //
            // Segment 2 is the fill, shared by both modes: it says how a paint
            // is applied, which is orthogonal to which paint.
            //
            // Segment 3 is the MEMO -- the last value of the mode that is NOT
            // active, kept so the admin's Theme/Custom switch can flip back
            // without losing it. It is skipped past and DISCARDED: it records a
            // choice the admin switched AWAY from, so rendering it would put a
            // colour on the page that was explicitly deselected. It is also why
            // this method's return shape did not change when the memo was added
            // -- nothing downstream has any business knowing it exists.
            //
            // Third, not second, because segments 1 and 2 are spoken for by
            // every layout ever saved. The field grows the way the paint
            // vocabulary does: by appending. The limit of 3 (rather than none)
            // documents that a fourth segment is not ours; without raising it
            // from 2, "accent_tint_hexaabbcc" would put "tint_hexaabbcc" in the
            // fill slot and drop the colour entirely.
            //
            // An unrecognised paint is dropped to ''. That is not tidiness: the
            // CSS sets `background: var(--blk-base)` and `color: var(--blk-ink)`,
            // and if no rule matched, --blk-base would be unset while --blk-ink
            // still resolved -- white text on the page background, i.e. an
            // invisible block. This whitelist is the actual guard.
            $paint  = '';
            $fill   = '';
            $custom = '';
            if ($colour !== '') {
                $bits = explode('_', $colour, 3);
                $p    = $bits[0];
                $f    = $bits[1] ?? 'solid';
                if (in_array($f, self::FILLS, true)) {
                    if (in_array($p, $paints, true)) {
                        // A palette KEY. The CSS resolves it through a var(),
                        // so this block follows Styles > Colors for free --
                        // recolour the palette and the block recolours with it.
                        $paint = $p;
                        $fill  = $f;
                    } elseif (preg_match('/^hex([0-9a-f]{6})$/', $p, $m) === 1) {
                        // A one-off colour, deliberately NOT connected to the
                        // palette: stored as the literal value and emitted as
                        // an inline custom property, so changing Styles >
                        // Colors leaves it exactly where the admin put it.
                        //
                        // Stored WITHOUT the '#'. The layout string's charset
                        // is [a-z0-9_:,/] precisely so it survives WHMCS's
                        // POST-time encoding and the admin field's |escape
                        // byte-identically across repeated saves; '#' is
                        // outside that set and is not worth the risk when a
                        // three-letter prefix avoids it.
                        $paint  = 'custom';
                        $fill   = $f;
                        $custom = '#' . $m[1];
                    }
                }
            }

            // How many items this section shows. 0 means "not set" -- the
            // template falls back to the page-level default, which is also what
            // a malformed value yields. ctype_digit rather than (int) because
            // (int)'abc' is 0 and (int)'3x' is 3: both would be accepted
            // silently, one of them wrongly.
            $rows = ($rowsIn !== '' && ctype_digit($rowsIn)) ? (int)$rowsIn : 0;
            if ($rows < 1 || $rows > 99) {
                $rows = 0;
            }

            $seen[$key] = true;
            $out[] = [
                'key'       => $key,
                'width'     => $width,
                'span'      => self::SPANS[$width] ?? 6,
                'visible'   => $width !== 'off',
                'hideEmpty' => str_contains($flags, 'e'),
                'hideList'  => str_contains($flags, 'l'),
                'paint'     => $paint,
                'fill'      => $fill,
                'custom'    => $custom,
                'rows'      => $rows,
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
                'hideList'  => false,
                'paint'     => '',
                'fill'      => '',
                'custom'    => '',
                'rows'      => 0,
            ];
        }

        return $out;
    }

}
