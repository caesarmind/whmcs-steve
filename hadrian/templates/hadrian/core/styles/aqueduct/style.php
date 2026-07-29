<?php
/**
 * Style preset manifest -- Aqueduct.
 *
 * Cool teal with a slate navigation panel. Architectural and calm.
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
    'name'        => 'Aqueduct',
    'description' => 'Cool teal with a slate navigation panel. Architectural and calm.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-aqueduct',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#0e7490',
            '--color-accent-hover'     => '#0d6b84',
            '--color-accent-light'     => 'rgba(14,116,144,0.08)',
            '--color-link'             => '#0c667f',
            '--color-link-hover'       => '#0e7490',
            '--color-blue-text'        => '#0c667f',
            '--color-blue-bg'          => 'rgba(14,116,144,0.08)',
            '--sidebar-bg'             => 'rgba(22,36,43,0.94)',
            '--sidebar-panel-bg'       => '#16232a',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b6c0c8',
            '--sidebar-text-muted'     => '#98a4ad',
            '--sidebar-text-faint'     => '#77838c',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#3fc0dd',
            '--color-accent-hover'     => '#56c8e1',
            '--color-accent-light'     => 'rgba(63,192,221,0.14)',
            '--color-link'             => '#3fc0dd',
            '--color-link-hover'       => '#56c8e1',
            '--color-blue-text'        => '#3fc0dd',
            '--color-blue-bg'          => 'rgba(63,192,221,0.14)',
            '--sidebar-bg'             => 'rgba(22,36,43,0.94)',
            '--sidebar-panel-bg'       => '#16232a',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b6c0c8',
            '--sidebar-text-muted'     => '#98a4ad',
            '--sidebar-text-faint'     => '#77838c',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
