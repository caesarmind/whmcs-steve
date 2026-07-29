<?php
/**
 * Style preset manifest -- Imperial.
 *
 * Deep cobalt on the standard light chrome. Crisp and editorial.
 *
 * The `colors` block is the payload: StylesController::seedStyleColors writes
 * it into this style's stored colours the FIRST time the style is activated,
 * after which the rows belong to the buyer and are never overwritten. That is
 * what makes a preset a starting point rather than a locked skin -- every value
 * below shows up in Styles > Colors as the live value and can be edited there.
 *
 * Constraints worth knowing before editing:
 *   - A token must appear in core/config/colors.php or it is dropped.
 *   - A value must satisfy Hooks::isColorValue -- hex, or COMMA-form rgb()/
 *     rgba()/hsl()/hsla(). var(), color-mix(), oklch() and modern slash syntax
 *     are silently dropped.
 *   - colorMode must stay 'light'. 'dark' makes StylesController drop the card
 *     from the picker -- dark is a MODE, not a preset.
 *   - The first letter of `name` is the tile glyph on the Styles page, so the
 *     shipped presets deliberately start with distinct letters.
 */
return [
    'name'        => 'Imperial',
    'description' => 'Deep cobalt on the standard light chrome. Crisp and editorial.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-imperial',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#1b4fd8',
            '--color-accent-hover' => '#1949c7',
            '--color-accent-light' => 'rgba(27,79,216,0.08)',
            '--color-link'         => '#1846be',
            '--color-link-hover'   => '#1b4fd8',
            '--color-blue-text'    => '#1846be',
            '--color-blue-bg'      => 'rgba(27,79,216,0.08)',
        ],
        'dark'  => [
            '--color-accent'       => '#7aa5ff',
            '--color-accent-hover' => '#8ab0ff',
            '--color-accent-light' => 'rgba(122,165,255,0.14)',
            '--color-link'         => '#7aa5ff',
            '--color-link-hover'   => '#8ab0ff',
            '--color-blue-text'    => '#7aa5ff',
            '--color-blue-bg'      => 'rgba(122,165,255,0.14)',
        ],
    ],
];
