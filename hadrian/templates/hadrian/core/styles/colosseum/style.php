<?php
/**
 * Style preset manifest -- Colosseum.
 *
 * Burnt gold against a near-black navigation. The most dramatic of the set.
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
    'name'        => 'Colosseum',
    'description' => 'Burnt gold against a near-black navigation. The most dramatic of the set.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-colosseum',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#a55b12',
            '--color-accent-hover'     => '#985411',
            '--color-accent-light'     => 'rgba(165,91,18,0.08)',
            '--color-link'             => '#915010',
            '--color-link-hover'       => '#a55b12',
            '--color-blue-text'        => '#915010',
            '--color-blue-bg'          => 'rgba(165,91,18,0.08)',
            '--sidebar-bg'             => 'rgba(26,23,20,0.95)',
            '--sidebar-panel-bg'       => '#1a1714',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b6c0c8',
            '--sidebar-text-muted'     => '#98a4ad',
            '--sidebar-text-faint'     => '#77838c',
            '--sidebar-border'         => 'rgba(255,255,255,0.09)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(240,160,60,0.18)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#f0a03c',
            '--color-accent-hover'     => '#f2ab53',
            '--color-accent-light'     => 'rgba(240,160,60,0.14)',
            '--color-link'             => '#f0a03c',
            '--color-link-hover'       => '#f2ab53',
            '--color-blue-text'        => '#f0a03c',
            '--color-blue-bg'          => 'rgba(240,160,60,0.14)',
            '--sidebar-bg'             => 'rgba(26,23,20,0.95)',
            '--sidebar-panel-bg'       => '#1a1714',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b6c0c8',
            '--sidebar-text-muted'     => '#98a4ad',
            '--sidebar-text-faint'     => '#77838c',
            '--sidebar-border'         => 'rgba(255,255,255,0.09)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(240,160,60,0.18)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
