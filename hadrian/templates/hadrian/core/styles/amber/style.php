<?php
/**
 * Style preset manifest -- Amber.
 *
 * The amber palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="amber"] block in apple-client-area/css/apple-layout.css,
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
 * measures 2.52 against white -- which is both what white ink scores ON it and
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
 *     the Amber preset" button is for.
 */
return [
    'name'        => 'Amber',
    'description' => 'The amber palette on the stock light chrome. Moves the colour, leaves the layout alone.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-amber',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#f08a00',
            '--color-accent-hover' => '#d97a00',
            '--color-accent-light' => 'rgba(240,138,0,0.10)',
            '--color-link'         => '#d97a00',
            '--color-link-hover'   => '#f08a00',
            '--color-blue-text'    => '#d97a00',
            '--color-blue-bg'      => 'rgba(240,138,0,0.10)',
            '--color-avatar-from'  => '#f08a00',
            '--color-avatar-to'    => '#ffb547',
        ],
        /* Amber takes only the +2.1 FLOOR, not the +10.6 cap. It is the
           lightest accent in the set (OKLCH L 72.8) and already measured
           6.76:1 on #1c1c1e -- brighter on the dark page than the shipped dark
           blue itself. #f3932d (L 74.8) reads 7.31:1 there and 5.99:1 on
           #2c2c2e, in the same band as the shipped dark orange-text (8.28:1).

           Taking the default's +10.6 literally would have landed #ffb777 at
           9.96:1: a pale peach, no longer amber, and glare on near-black. That
           is why the rule targets the CONTRAST the default reaches rather than
           the delta it travels -- a lift sized for a saturated blue, which is
           intrinsically dark in sRGB, over-corrects every warm hue.

           avatar-to keeps the monogram gradient's own spread rather than being
           lifted independently: the light pair is 9.7 OKLCH L apart, and the
           dark pair is too. */
        'dark'  => [
            '--color-accent'       => '#f3932d',
            '--color-accent-hover' => '#f8a14e',
            '--color-accent-light' => 'rgba(243,147,45,0.16)',
            '--color-link'         => '#f3932d',
            '--color-link-hover'   => '#f8a14e',
            '--color-blue-text'    => '#f3932d',
            '--color-blue-bg'      => 'rgba(243,147,45,0.16)',
            '--color-avatar-from'  => '#f3932d',
            '--color-avatar-to'    => '#ffbe64',
        ],
    ],
];
