<?php
/**
 * Style preset manifest -- Slate.
 *
 * The slate palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="slate"] block in apple-client-area/css/apple-layout.css,
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
 * measures 4.76 against white -- which is both what white ink scores ON it and
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
 *     the Slate preset" button is for.
 */
return [
    'name'        => 'Slate',
    'description' => 'The slate palette on the stock light chrome. Moves the colour, leaves the layout alone.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-slate',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#64748b',
            '--color-accent-hover' => '#475569',
            '--color-accent-light' => 'rgba(100,116,139,0.10)',
            '--color-link'         => '#475569',
            '--color-link-hover'   => '#64748b',
            '--color-blue-text'    => '#475569',
            '--color-blue-bg'      => 'rgba(100,116,139,0.10)',
            '--color-avatar-from'  => '#64748b',
            '--color-avatar-to'    => '#94a3b8',
        ],
        /* The biggest lift of the five, and the one that most needed it: slate
           is the only accent here that was UNDER 4:1 on the dark page. Accent
           #64748b (OKLCH L 55.4) takes the full +10.6 cap to #8494aa (L 66.1),
           reaching 5.51:1 on #1c1c1e and 4.51:1 on #2c2c2e, up from 3.58:1.
           It stops a fraction short of the 5.6 target because the cap binds
           first -- lifting further would start bleaching a hue whose whole
           character is that it is muted.

           The old dark link was worse than the old dark accent: #475569 is a
           deep desaturated blue-grey that measured 2.25:1 on #1c1c1e, well
           under even the 3:1 floor for UI. That is the value copying light
           into dark actually shipped for every link on the page.

           avatar-to keeps the monogram gradient's own spread rather than being
           lifted independently: the light pair is 15.6 OKLCH L apart, and the
           dark pair is too. */
        'dark'  => [
            '--color-accent'       => '#8494aa',
            '--color-accent-hover' => '#8f9eb2',
            '--color-accent-light' => 'rgba(132,148,170,0.16)',
            '--color-link'         => '#8494aa',
            '--color-link-hover'   => '#8f9eb2',
            '--color-blue-text'    => '#8494aa',
            '--color-blue-bg'      => 'rgba(132,148,170,0.16)',
            '--color-avatar-from'  => '#8494aa',
            '--color-avatar-to'    => '#b5c5db',
        ],
    ],
];
