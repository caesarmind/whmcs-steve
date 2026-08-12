<?php
/**
 * Style preset manifest -- Emerald.
 *
 * The emerald palette on the stock light chrome. Moves the colour, leaves the layout alone.
 *
 * WHAT A STYLE IS, IN THIS SET
 * A palette and nothing more. Every value below comes from the v18 mockup's own
 * html[data-palette="emerald"] block in apple-client-area/css/apple-layout.css,
 * read by the generator rather than retyped, so the brand colour a buyer picks
 * here is exactly the one they saw in the demo. Both scopes carry the same
 * values because the demo's palette blocks are not mode-scoped either.
 *
 * NO SIDEBAR TOKENS, deliberately. An earlier pass paired each hue with a
 * navigation tone -- tinted, graphite, near-black, brand -- which conflated two
 * things the demo keeps on separate axes: its palette chips and its five-way
 * sidebar tone chip are independent, and 6x5 combinations do not belong in a
 * list of six cards. Colour is what a style is here; the navigation treatment
 * stays stock.
 *
 * Contrast is stated, not silently corrected. This accent measures
 * 2.76 against white -- which is both what white ink scores ON it and
 * what it scores AS TEXT on a light surface, contrast being symmetric, and the
 * theme writes color: var(--color-accent) in roughly 400 places. Deepening the
 * hues to clear 4.5 was tried and reverted: matching the palette is the
 * requirement, and any single token can be raised in Styles > Colors.
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
        'dark'  => [
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
    ],
];
