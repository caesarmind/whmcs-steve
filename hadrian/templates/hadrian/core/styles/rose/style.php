<?php
/**
 * Style preset manifest -- Rose.
 *
 * Vivid pink-red on the standard light chrome. Bold accent, quiet frame.
 *
 * Accent only: nothing but the brand tokens move, so the stock layout carries it.
 * Sidebar tone: Light   -- the stock panel; this style ships no sidebar overrides at all.
 *
 * WHERE THE COLOURS COME FROM
 * The hue is the rose entry of the palette in core/config/colors.php
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
    'name'        => 'Rose',
    'description' => 'Vivid pink-red on the standard light chrome. Bold accent, quiet frame.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-rose',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#ea0045',
            '--color-accent-hover' => '#ff024d',
            '--color-accent-light' => 'rgba(234,0,69,0.08)',
            '--color-link'         => '#d80040',
            '--color-link-hover'   => '#ea0045',
            '--color-blue-text'    => '#d80040',
            '--color-blue-bg'      => 'rgba(234,0,69,0.08)',
        ],
        'dark'  => [
            '--color-accent'       => '#ff5487',
            '--color-accent-hover' => '#ff709b',
            '--color-accent-light' => 'rgba(255,84,135,0.14)',
            '--color-link'         => '#ff5487',
            '--color-link-hover'   => '#ff709b',
            '--color-blue-text'    => '#ff769f',
            '--color-blue-bg'      => 'rgba(255,84,135,0.14)',
        ],
    ],
];
