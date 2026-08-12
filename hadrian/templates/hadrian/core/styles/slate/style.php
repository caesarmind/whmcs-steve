<?php
/**
 * Style preset manifest -- Slate.
 *
 * Muted blue-grey used as both accent and navigation. Lets your content carry the colour.
 *
 * Brand tone: the menu IS the accent, deepened until white ink clears AA.
 * Sidebar tone: Brand   -- the accent itself, deepened (mockup: data-sidebar="brand").
 *
 * WHERE THE COLOURS COME FROM
 * The hue is the slate entry of the palette in core/config/colors.php
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
    'name'        => 'Slate',
    'description' => 'Muted blue-grey used as both accent and navigation. Lets your content carry the colour.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-slate',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#64748b',
            '--color-accent-hover'     => '#6f7f97',
            '--color-accent-light'     => 'rgba(100,116,139,0.08)',
            '--color-link'             => '#5d6b81',
            '--color-link-hover'       => '#64748b',
            '--color-blue-text'        => '#5d6b81',
            '--color-blue-bg'          => 'rgba(100,116,139,0.08)',
            '--sidebar-bg'             => '#444f5f',
            '--sidebar-panel-bg'       => '#444f5f',
            '--sidebar-text'           => '#ffffff',
            '--sidebar-text-secondary' => 'rgba(255,255,255,0.82)',
            '--sidebar-text-muted'     => 'rgba(255,255,255,0.70)',
            '--sidebar-text-faint'     => 'rgba(255,255,255,0.55)',
            '--sidebar-border'         => 'rgba(255,255,255,0.20)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.16)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.14)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.30)',
        ],
        'dark'  => [
            '--color-accent'           => '#8795a9',
            '--color-accent-hover'     => '#97a3b5',
            '--color-accent-light'     => 'rgba(135,149,169,0.14)',
            '--color-link'             => '#8795a9',
            '--color-link-hover'       => '#97a3b5',
            '--color-blue-text'        => '#9ca7b8',
            '--color-blue-bg'          => 'rgba(135,149,169,0.14)',
            '--sidebar-bg'             => '#474e59',
            '--sidebar-panel-bg'       => '#474e59',
            '--sidebar-text'           => '#ffffff',
            '--sidebar-text-secondary' => 'rgba(255,255,255,0.82)',
            '--sidebar-text-muted'     => 'rgba(255,255,255,0.70)',
            '--sidebar-text-faint'     => 'rgba(255,255,255,0.55)',
            '--sidebar-border'         => 'rgba(255,255,255,0.20)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.16)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.14)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.30)',
        ],
    ],
];
