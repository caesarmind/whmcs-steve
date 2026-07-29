<?php
/**
 * Style preset manifest -- Porphyry.
 *
 * Imperial purple at the highest contrast in the set.
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
    'name'        => 'Porphyry',
    'description' => 'Imperial purple at the highest contrast in the set.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-porphyry',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#6b21a8',
            '--color-accent-hover' => '#621e9b',
            '--color-accent-light' => 'rgba(107,33,168,0.08)',
            '--color-link'         => '#5c1c91',
            '--color-link-hover'   => '#6b21a8',
            '--color-blue-text'    => '#5c1c91',
            '--color-blue-bg'      => 'rgba(107,33,168,0.08)',
        ],
        'dark'  => [
            '--color-accent'       => '#c084fc',
            '--color-accent-hover' => '#cb9bfd',
            '--color-accent-light' => 'rgba(192,132,252,0.14)',
            '--color-link'         => '#c084fc',
            '--color-link-hover'   => '#cb9bfd',
            '--color-blue-text'    => '#c084fc',
            '--color-blue-bg'      => 'rgba(192,132,252,0.14)',
        ],
    ],
];
