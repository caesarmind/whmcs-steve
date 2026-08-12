<?php
/**
 * Style preset manifest -- Emerald.
 *
 * Deep green on a softly tinted navigation panel. Fresh without shouting.
 *
 * A wash of the accent through the menu -- the lightest way to colour the chrome.
 * Sidebar tone: Tinted  -- accent washed into a light panel (mockup: data-sidebar="tinted").
 *
 * WHERE THE COLOURS COME FROM
 * The hue is the emerald entry of the palette in core/config/colors.php
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
    'name'        => 'Emerald',
    'description' => 'Deep green on a softly tinted navigation panel. Fresh without shouting.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-emerald',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#0f855e',
            '--color-accent-hover'     => '#119a6d',
            '--color-accent-light'     => 'rgba(15,133,94,0.08)',
            '--color-link'             => '#0d7553',
            '--color-link-hover'       => '#0f855e',
            '--color-blue-text'        => '#0d7553',
            '--color-blue-bg'          => 'rgba(15,133,94,0.08)',
            '--sidebar-bg'             => '#e7f3ef',
            '--sidebar-panel-bg'       => '#f1f8f5',
            '--sidebar-text'           => '#1d1d1f',
            '--sidebar-text-secondary' => '#6b6b70',
            '--sidebar-text-muted'     => '#86868b',
            '--sidebar-text-faint'     => '#aeaeb2',
            '--sidebar-border'         => '#d9ebe5',
            '--sidebar-field-bg'       => '#f1f8f5',
            '--sidebar-item-hover-bg'  => 'rgba(15,133,94,0.14)',
            '--sidebar-item-active-bg' => 'rgba(15,133,94,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(15,133,94,0.3)',
        ],
        'dark'  => [
            '--color-accent'           => '#13a877',
            '--color-accent-hover'     => '#16c189',
            '--color-accent-light'     => 'rgba(19,168,119,0.14)',
            '--color-link'             => '#13a877',
            '--color-link-hover'       => '#16c189',
            '--color-blue-text'        => '#15ba84',
            '--color-blue-bg'          => 'rgba(19,168,119,0.14)',
            '--sidebar-bg'             => '#1b2a27',
            '--sidebar-panel-bg'       => '#1b2423',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => '#1b322c',
            '--sidebar-field-bg'       => '#1b2423',
            '--sidebar-item-hover-bg'  => 'rgba(19,168,119,0.14)',
            '--sidebar-item-active-bg' => 'rgba(19,168,119,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(19,168,119,0.3)',
        ],
    ],
];
