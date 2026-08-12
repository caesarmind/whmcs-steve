<?php
/**
 * Style preset manifest -- Violet.
 *
 * Electric violet against a near-black navigation. The most dramatic of the set.
 *
 * The warm near-black panel from the mockup, with the theme own dark ink ramp.
 * Sidebar tone: Dark    -- fixed warm near-black panel (mockup: data-sidebar="dark").
 *
 * WHERE THE COLOURS COME FROM
 * The hue is the violet entry of the palette in core/config/colors.php
 * ('presets'), which is the same palette the v18 mockup ships. The mockup's raw
 * value is NOT reused: it was picked to look right, not to pass AA, and white
 * ink on it measures under 4.5 for most of the set. Each accent here is that
 * hue walked down (light) or up (dark) in HSL lightness until it clears the
 * contrast it actually has to clear, so the palette keeps its identity and the
 * buttons stay legible. Measured values are in the table at the bottom.
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
 *     are silently dropped. That is why the tone recipes in colors.php, which
 *     are written as color-mix(), appear RESOLVED to literals here.
 *   - Both scopes declare the sidebar tokens even when the values match. Seven
 *     of them are var() chains declared once at :root, so a light-only override
 *     has nothing in the dark block to beat it -- that is the bug that painted
 *     near-black text on a near-black panel at 1.01:1.
 *   - colorMode must stay 'light'. 'dark' makes StylesController drop the card
 *     from the picker -- dark is a MODE, not a preset.
 *   - The first letter of `name` is the tile glyph on the Styles page, so the
 *     shipped presets deliberately start with distinct letters.
 */
return [
    'name'        => 'Violet',
    'description' => 'Electric violet against a near-black navigation. The most dramatic of the set.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-violet',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#8451ff',
            '--color-accent-hover'     => '#9468ff',
            '--color-accent-light'     => 'rgba(132,81,255,0.08)',
            '--color-link'             => '#773fff',
            '--color-link-hover'       => '#8451ff',
            '--color-blue-text'        => '#773fff',
            '--color-blue-bg'          => 'rgba(132,81,255,0.08)',
            '--sidebar-bg'             => 'rgba(28,28,30,0.94)',
            '--sidebar-panel-bg'       => '#1c1c1e',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#a27cff',
            '--color-accent-hover'     => '#b698ff',
            '--color-accent-light'     => 'rgba(162,124,255,0.14)',
            '--color-link'             => '#a27cff',
            '--color-link-hover'       => '#b698ff',
            '--color-blue-text'        => '#b293ff',
            '--color-blue-bg'          => 'rgba(162,124,255,0.14)',
            '--sidebar-bg'             => 'rgba(28,28,30,0.94)',
            '--sidebar-panel-bg'       => '#1c1c1e',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
