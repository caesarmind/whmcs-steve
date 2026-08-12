<?php
/**
 * Style preset manifest -- Amber.
 *
 * Warm bronze against a cool graphite navigation. High contrast, low glare.
 *
 * A cool blue-grey panel under a warm accent -- the widest temperature split in the set.
 * Sidebar tone: Graphite-- fixed cool near-black panel (mockup: data-sidebar="graphite").
 *
 * WHERE THE COLOURS COME FROM
 * The hue is the amber entry of the palette in core/config/colors.php
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
    'name'        => 'Amber',
    'description' => 'Warm bronze against a cool graphite navigation. High contrast, low glare.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-amber',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#ac6300',
            '--color-accent-hover'     => '#c37000',
            '--color-accent-light'     => 'rgba(172,99,0,0.08)',
            '--color-link'             => '#9a5900',
            '--color-link-hover'       => '#ac6300',
            '--color-blue-text'        => '#9a5900',
            '--color-blue-bg'          => 'rgba(172,99,0,0.08)',
            '--sidebar-bg'             => 'rgba(33,37,46,0.94)',
            '--sidebar-panel-bg'       => '#21252e',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b8c0cc',
            '--sidebar-text-muted'     => '#9aa3b2',
            '--sidebar-text-faint'     => '#798294',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#d97d00',
            '--color-accent-hover'     => '#f58d00',
            '--color-accent-light'     => 'rgba(217,125,0,0.14)',
            '--color-link'             => '#d97d00',
            '--color-link-hover'       => '#f58d00',
            '--color-blue-text'        => '#f18b00',
            '--color-blue-bg'          => 'rgba(217,125,0,0.14)',
            '--sidebar-bg'             => 'rgba(33,37,46,0.94)',
            '--sidebar-panel-bg'       => '#21252e',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b8c0cc',
            '--sidebar-text-muted'     => '#9aa3b2',
            '--sidebar-text-faint'     => '#798294',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
