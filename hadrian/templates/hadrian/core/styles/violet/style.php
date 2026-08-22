<?php
/**
 * Style preset manifest -- Violet.
 *
 * The violet palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="violet"] block in its layout stylesheet,
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
 * active state is the lighter one. Both washes go to 0.18 alpha, matching
 * --color-gray-bg, the shipped 0.12 light fill that becomes 0.18 in dark.
 *
 * NO SIDEBAR TOKENS, deliberately. An earlier pass paired each hue with a
 * navigation tone -- tinted, graphite, near-black, brand -- which conflated two
 * things the demo keeps on separate axes: its palette chips and its five-way
 * sidebar tone chip are independent, and 6x5 combinations do not belong in a
 * list of six cards. Colour is what a style is here; the navigation treatment
 * stays stock.
 *
 * In the light scope, contrast is stated, not silently corrected. This accent
 * measures 4.13 against white -- which is both what white ink scores ON it and
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
 *     the Violet preset" button is for.
 */
return [
    'name'        => 'Violet',
    'description' => 'The violet palette on the stock light chrome. Moves the colour, leaves the layout alone.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-violet',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#8c5cff',
            '--color-accent-hover' => '#7a46ff',
            '--color-accent-light' => 'rgba(140,92,255,0.12)',
            '--color-link'         => '#7a46ff',
            '--color-link-hover'   => '#8c5cff',
            '--color-blue-text'    => '#7a46ff',
            '--color-blue-bg'      => 'rgba(140,92,255,0.12)',
            '--color-avatar-from'  => '#8c5cff',
            '--color-avatar-to'    => '#c28cff',
        ],
        /* Accent #8c5cff (OKLCH L 61.3) lifts +7.2 to #9e80ff (L 68.5): 5.66:1
           on #1c1c1e and 4.64:1 on --color-surface dark (#2c2c2e), within a
           hundredth of the shipped dark blue's 5.64 and 4.62. The light value
           managed only 4.12:1 there, which is the whole complaint -- a violet
           mixed for white paper, laid on near-black.

           Chroma falls furthest of the five, 0.229 -> 0.181 against the x0.94
           the rule asks for. Not a choice: violet at this lightness is off the
           edge of sRGB, so the value is gamut-mapped down until it fits. Rose
           loses chroma the same way, every other preset lands on x0.94.

           avatar-to keeps the monogram gradient's own spread rather than being
           lifted independently: the light pair is 12.5 OKLCH L apart, and the
           dark pair is too. */
        'dark'  => [
            '--color-accent'       => '#9e80ff',
            '--color-accent-hover' => '#a78eff',
            '--color-accent-light' => 'rgba(158,128,255,0.18)',
            '--color-link'         => '#9e80ff',
            '--color-link-hover'   => '#a78eff',
            '--color-blue-text'    => '#9e80ff',
            '--color-blue-bg'      => 'rgba(158,128,255,0.18)',
            '--color-avatar-from'  => '#9e80ff',
            '--color-avatar-to'    => '#d2aeff',
        ],
    ],
];
