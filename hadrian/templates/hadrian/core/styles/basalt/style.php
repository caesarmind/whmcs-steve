<?php
/**
 * Style preset manifest -- Basalt.
 *
 * Near-monochrome graphite with a dark nav. Lets your content carry the colour.
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
    'name'        => 'Basalt',
    'description' => 'Near-monochrome graphite with a dark nav. Lets your content carry the colour.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-basalt',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#3f3f46',
            '--color-accent-hover'     => '#35353b',
            '--color-accent-light'     => 'rgba(63,63,70,0.08)',
            '--color-link'             => '#2f2f35',
            '--color-link-hover'       => '#3f3f46',
            '--color-blue-text'        => '#2f2f35',
            '--color-blue-bg'          => 'rgba(63,63,70,0.08)',
            '--sidebar-bg'             => 'rgba(24,24,27,0.95)',
            '--sidebar-panel-bg'       => '#18181b',
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
            '--color-accent'           => '#c4c4cc',
            '--color-accent-hover'     => '#d2d2d9',
            '--color-accent-light'     => 'rgba(196,196,204,0.14)',
            '--color-link'             => '#c4c4cc',
            '--color-link-hover'       => '#d2d2d9',
            '--color-blue-text'        => '#c4c4cc',
            '--color-blue-bg'          => 'rgba(196,196,204,0.14)',
            '--sidebar-bg'             => 'rgba(24,24,27,0.95)',
            '--sidebar-panel-bg'       => '#18181b',
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
