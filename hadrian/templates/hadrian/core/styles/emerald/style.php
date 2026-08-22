<?php
/**
 * Style preset manifest -- Emerald.
 *
 * The emerald palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="emerald"] block in its layout stylesheet,
 * read by the generator rather than retyped, so the brand colour a buyer picks
 * here is exactly the one they saw in the demo.
 *
 * LIGHT IS THE DEMO; DARK IS DERIVED. Only the light scope is the mockup's
 * block verbatim. The demo has no dark palette -- its html[data-palette]
 * blocks are not mode-scoped -- and an earlier pass filled the dark scope by
 * copying the light values across, which wrote a light-mode brand colour onto
 * a near-black page. Dark is now built the way the shipped default builds its
 * own pair in core/config/colors.php (#0071e3 -> #2997ff): hue held, chroma
 * taken to 0.94 of the light value, and OKLCH lightness raised just far enough
 * to reach the 5.6:1 that dark accent scores on --color-bg dark (#1c1c1e).
 * The lift is capped at the +10.6 OKLCH L the default's blue takes and floored
 * at the +2.1 its avatar-from takes, so a hue that already reads on near-black
 * moves a little and one that does not moves a lot.
 *
 * The dark scope also collapses the way the default's does: link and blue-text
 * EQUAL the accent there (the schema's own hint reads "darker than it in light
 * mode, equal in dark"), and hover BRIGHTENS off the accent (+3.2 L, chroma
 * x0.90) instead of darkening as it does in light -- on a dark page the more
 * active state is the lighter one. Both washes go to 0.16 alpha, matching the
 * shipped *-bg family, which takes every 0.10 light fill to 0.16 in dark.
 *
 * NO SIDEBAR TOKENS, deliberately. An earlier pass paired each hue with a
 * navigation tone -- tinted, graphite, near-black, brand -- which conflated two
 * things the demo keeps on separate axes: its palette chips and its five-way
 * sidebar tone chip are independent, and 6x5 combinations do not belong in a
 * list of six cards. Colour is what a style is here; the navigation treatment
 * stays stock.
 *
 * In the light scope, contrast is stated, not silently corrected. This accent
 * measures 2.76 against white -- which is both what white ink scores ON it and
 * what it scores AS TEXT on a light surface, contrast being symmetric, and the
 * theme writes color: var(--color-accent) in roughly 400 places. Deepening the
 * hues to clear 4.5 was tried and reverted: matching the palette is the
 * requirement, and any single token can be raised in Styles > Colors. Dark is
 * the exception only because it has no demo value to match -- correcting it
 * overrides nothing.
 *
 * Constraints worth knowing before editing:
 *   - A token must appear in core/config/colors.php or it is dropped.
 *   - A value must satisfy Hooks::isColorValue -- hex, or COMMA-form rgb()/
 *     rgba()/hsl()/hsla(). var() and color-mix() are silently dropped.
 *   - colorMode must stay 'light'. 'dark' drops the card from the picker.
 *   - Seeding is once-only, so editing this file does NOT reach a buyer who has
 *     already activated the style. That is what the Colors panel's "Reset to
 *     the Emerald preset" button is for.
 */
return [
    'name'        => 'Emerald',
    'description' => 'The emerald palette on the stock light chrome. Moves the colour, leaves the layout alone.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-emerald',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#14b17d',
            '--color-accent-hover' => '#0fa370',
            '--color-accent-light' => 'rgba(20,177,125,0.10)',
            '--color-link'         => '#0fa370',
            '--color-link-hover'   => '#14b17d',
            '--color-blue-text'    => '#0fa370',
            '--color-blue-bg'      => 'rgba(20,177,125,0.10)',
            '--color-avatar-from'  => '#14b17d',
            '--color-avatar-to'    => '#5ac8a3',
        ],
        /* Emerald takes only the +2.1 FLOOR, not the +10.6 cap: at OKLCH L 67.4
           the light accent already measured 6.17:1 on #1c1c1e, past the 5.6
           target before any lift. #35b685 (L 69.5) reads 6.63:1 there and
           5.43:1 on #2c2c2e. The floor is not zero because dark mode should
           still look like its own palette -- it is the same minimum gesture the
           default makes on avatar-from (#007aff -> #0a84ff, +2.1).

           So the accent barely moves here. The real repair in this preset is
           the other eight tokens: link and blue-text were carrying #0fa370,
           the DARKER light-mode variant, which is backwards on a dark page.

           avatar-to keeps the monogram gradient's own spread rather than being
           lifted independently: the light pair is 8.4 OKLCH L apart, and the
           dark pair is too. */
        'dark'  => [
            '--color-accent'       => '#35b685',
            '--color-accent-hover' => '#53be91',
            '--color-accent-light' => 'rgba(53,182,133,0.16)',
            '--color-link'         => '#35b685',
            '--color-link-hover'   => '#53be91',
            '--color-blue-text'    => '#35b685',
            '--color-blue-bg'      => 'rgba(53,182,133,0.16)',
            '--color-avatar-from'  => '#35b685',
            '--color-avatar-to'    => '#61cfa9',
        ],
    ],
];
