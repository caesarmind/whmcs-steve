<?php
/**
 * Style preset manifest -- Laurel.
 *
 * Soft green on a cool-tinted page. The quietest of the set.
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
    'name'        => 'Laurel',
    'description' => 'Soft green on a cool-tinted page. The quietest of the set.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-laurel',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'            => '#2f7d4f',
            '--color-accent-hover'      => '#2b7449',
            '--color-accent-light'      => 'rgba(47,125,79,0.08)',
            '--color-link'              => '#296c43',
            '--color-link-hover'        => '#2f7d4f',
            '--color-blue-text'         => '#296c43',
            '--color-blue-bg'           => 'rgba(47,125,79,0.08)',
            '--color-bg'                => '#f7faf8',
            '--color-surface-secondary' => '#eef4f0',
            '--sidebar-bg'              => 'rgba(242,247,244,0.85)',
            '--sidebar-field-bg'        => '#eef4f0',
        ],
        'dark'  => [
            '--color-accent'       => '#5fd08a',
            '--color-accent-hover' => '#74d799',
            '--color-accent-light' => 'rgba(95,208,138,0.14)',
            '--color-link'         => '#5fd08a',
            '--color-link-hover'   => '#74d799',
            '--color-blue-text'    => '#5fd08a',
            '--color-blue-bg'      => 'rgba(95,208,138,0.14)',
        ],
    ],
];
