<?php
/**
 * Style preset manifest -- Forum.
 *
 * Warm terracotta on paper-warm surfaces. Softer than the default.
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
    'name'        => 'Forum',
    'description' => 'Warm terracotta on paper-warm surfaces. Softer than the default.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-forum',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'            => '#b04a2b',
            '--color-accent-hover'      => '#a24428',
            '--color-accent-light'      => 'rgba(176,74,43,0.08)',
            '--color-link'              => '#9b4126',
            '--color-link-hover'        => '#b04a2b',
            '--color-blue-text'         => '#9b4126',
            '--color-blue-bg'           => 'rgba(176,74,43,0.08)',
            '--color-bg'                => '#faf7f2',
            '--color-surface-secondary' => '#f4efe7',
            '--sidebar-bg'              => 'rgba(247,243,236,0.85)',
            '--sidebar-field-bg'        => '#f4efe7',
        ],
        'dark'  => [
            '--color-accent'       => '#ff8a63',
            '--color-accent-hover' => '#ff9876',
            '--color-accent-light' => 'rgba(255,138,99,0.14)',
            '--color-link'         => '#ff8a63',
            '--color-link-hover'   => '#ff9876',
            '--color-blue-text'    => '#ff8a63',
            '--color-blue-bg'      => 'rgba(255,138,99,0.14)',
        ],
    ],
];
