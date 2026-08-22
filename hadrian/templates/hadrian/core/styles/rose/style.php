<?php
/**
 * Style preset manifest -- Rose.
 *
 * The rose palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="rose"] block in its layout stylesheet,
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
 * measures 3.60 against white -- which is both what white ink scores ON it and
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
 *     the Rose preset" button is for.
 */
return [
    'name'        => 'Rose',
    'description' => 'The rose palette on the stock light chrome. Moves the colour, leaves the layout alone.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-rose',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#ff2d6b',
            '--color-accent-hover' => '#e61f5b',
            '--color-accent-light' => 'rgba(255,45,107,0.10)',
            '--color-link'         => '#e61f5b',
            '--color-link-hover'   => '#ff2d6b',
            '--color-blue-text'    => '#e61f5b',
            '--color-blue-bg'      => 'rgba(255,45,107,0.10)',
            '--color-avatar-from'  => '#ff2d6b',
            '--color-avatar-to'    => '#ff7fa8',
        ],
        /* Accent #ff2d6b (OKLCH L 65.4) lifts +4.0 to #ff597d (L 69.4): 5.65:1
           on #1c1c1e and 4.63:1 on #2c2c2e, up from 4.73:1. A saturated red is
           not an intrinsically dark hue the way blue is, so it needs a third of
           the lift the default blue takes -- which is the point of targeting
           the contrast rather than copying the delta. Chroma comes off harder
           here than elsewhere (0.239 -> 0.202) because red at this lightness
           runs out of sRGB gamut first.

           avatar-to keeps the monogram gradient's own spread rather than being
           lifted independently: the light pair is 9.9 OKLCH L apart, and the
           dark pair is too. */
        'dark'  => [
            '--color-accent'       => '#ff597d',
            '--color-accent-hover' => '#ff718b',
            '--color-accent-light' => 'rgba(255,89,125,0.16)',
            '--color-link'         => '#ff597d',
            '--color-link-hover'   => '#ff718b',
            '--color-blue-text'    => '#ff597d',
            '--color-blue-bg'      => 'rgba(255,89,125,0.16)',
            '--color-avatar-from'  => '#ff597d',
            '--color-avatar-to'    => '#ff97b6',
        ],
    ],
];
