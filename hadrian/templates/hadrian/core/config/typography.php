<?php
/**
 * Typography schema + defaults — single source of truth for the admin
 * Typography panel (StylesController) and the render-time token emitter
 * (Hooks::buildTypographyHead).
 *
 * IMPORTANT: the `default` values MUST mirror the :root tokens in
 * assets/css/core-theme.css. The admin form shows these as the baseline and
 * only values the buyer CHANGES from default are persisted + emitted. If you
 * change a token default in the CSS, change it here too or the "is this an
 * override?" comparison desyncs.
 */
return [
    'fontFamily' => [
        'var'      => '--font-family',
        'default'  => "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', 'Inter', 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', Helvetica, Arial, sans-serif",
        // Appended after a chosen Google/bundled/uploaded font so glyph coverage
        // degrades gracefully. Short + clean: `system-ui` (the visitor's OS font)
        // then the generic family. No BlinkMacSystemFont.
        'fallback' => "system-ui, sans-serif",
        // "System fonts" mode: each visitor's OWN OS font, no webfont loaded
        // (Segoe UI on Windows, San Francisco on Apple, system default on Linux).
        // Uses the modern `system-ui` keyword (the OS UI font) rather than the
        // legacy `-apple-system, BlinkMacSystemFont` incantation; `-apple-system`
        // stays only as a Safari backstop. No BlinkMacSystemFont.
        'system'   => "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        // "Apple-first mix": prepended to a chosen font so San Francisco wins on
        // Apple while the font loads only on the other platforms. This is exactly
        // what 'default' does (SF on Apple, bundled Inter elsewhere), generalized
        // to any Google/bundled/uploaded font via the per-source "apple" flag.
        'applePrefix' => "-apple-system, BlinkMacSystemFont",
    ],

    // Font-size tokens (px), grouped for the admin form. var === the CSS custom property.
    'sizeGroups' => [
        'Body' => [
            ['var' => '--text-xs',   'label' => 'Extra Small', 'default' => 11],
            ['var' => '--text-sm',   'label' => 'Small',       'default' => 12],
            ['var' => '--text-base', 'label' => 'Base',        'default' => 13],
            ['var' => '--text-md',   'label' => 'Medium',      'default' => 14],
            ['var' => '--text-lg',   'label' => 'Large',       'default' => 15],
            ['var' => '--text-xl',   'label' => 'Extra Large', 'default' => 17],
            ['var' => '--text-2xl',  'label' => 'Super Large', 'default' => 20],
            ['var' => '--text-3xl',  'label' => '3XL',         'default' => 24],
        ],
        'Headings' => [
            ['var' => '--text-h6', 'label' => 'Heading h6', 'default' => 18],
            ['var' => '--text-h5', 'label' => 'Heading h5', 'default' => 20],
            ['var' => '--text-h4', 'label' => 'Heading h4', 'default' => 26],
            ['var' => '--text-h3', 'label' => 'Heading h3', 'default' => 36],
            ['var' => '--text-h2', 'label' => 'Heading h2', 'default' => 40],
            ['var' => '--text-h1', 'label' => 'Heading h1', 'default' => 48],
        ],
        'Display' => [
            ['var' => '--text-display-sm', 'label' => 'Display Small', 'default' => 56],
            ['var' => '--text-display',    'label' => 'Display',       'default' => 72],
            ['var' => '--text-display-lg', 'label' => 'Display Large', 'default' => 96],
            ['var' => '--text-display-xl', 'label' => 'Display XL',    'default' => 120],
        ],
    ],

    // Font-weight tokens.
    'weights' => [
        ['var' => '--fw-light',    'label' => 'Light',    'default' => 300],
        ['var' => '--fw-normal',   'label' => 'Base',     'default' => 400],
        ['var' => '--fw-medium',   'label' => 'Medium',   'default' => 500],
        ['var' => '--fw-semibold', 'label' => 'Semibold', 'default' => 600],
        ['var' => '--fw-bold',     'label' => 'Bold',     'default' => 700],
        ['var' => '--fw-black',    'label' => 'Black',    'default' => 900],
    ],

    // Validation bounds.
    'sizeMin'       => 8,
    'sizeMax'       => 160,
    'weightOptions' => [100, 200, 300, 400, 500, 600, 700, 800, 900],

    // The full Google Fonts library, generated into google-fonts.json by
    // scripts/fetch-google-fonts.mjs from https://fonts.google.com/metadata/fonts.
    // StylesController reads it for the picker AND allowlists the saved family
    // against it; nothing fetches from Google at runtime. Re-run the script to
    // pick up families Google has added since.
    'googleFontsFile' => 'google-fonts.json',

    // Pinned to the top of the picker under "Popular". These are the twelve that
    // used to BE the whole list — UI-grade sans faces that suit a client area —
    // so an admin who just wants a safe choice never has to scroll 1,900 rows.
    // Every name here must also exist in google-fonts.json.
    'googleFontsPopular' => [
        'Inter', 'Roboto', 'Open Sans', 'Lato', 'Poppins', 'Montserrat',
        'Nunito Sans', 'Work Sans', 'Manrope', 'DM Sans', 'Source Sans 3', 'Plus Jakarta Sans',
    ],

    // Weights requested from fonts.googleapis.com, intersected with what the
    // chosen family actually ships. Mirrors the --fw-* token scale above, so a
    // font arrives with exactly the weights the theme asks it to render.
    'googleWeights' => [300, 400, 500, 600, 700],

    // Theme-shipped, self-hosted fonts (zero external request) the configurator
    // can offer alongside buyer uploads. Combined with the "apple" flag this
    // reproduces 'default' exactly: Bundled Inter + Apple-first === SF on Apple,
    // bundled Inter elsewhere. 'face' = emit an @font-face at render; Inter's is
    // already declared in core-theme.css, so it stays false (no duplicate).
    'bundledFonts' => [
        ['file' => 'InterVariable.woff2', 'family' => 'Inter', 'label' => 'Inter (bundled)', 'weight' => '100 900', 'face' => false],
    ],
];
