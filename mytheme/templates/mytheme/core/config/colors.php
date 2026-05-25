<?php
/**
 * Color schema + per-mode defaults — single source of truth for the admin
 * Colors panel (StylesController) and the render-time emitter
 * (Hooks::buildColorsHead).
 *
 * Each token's `light` / `dark` default MUST mirror the :root and
 * [data-theme="dark"] blocks in assets/css/apple-theme.css. The admin form
 * shows the per-style default as the baseline and only persists/emits the
 * tokens the buyer CHANGES — so if you change a default in the CSS, change it
 * here too or the "is this an override?" comparison desyncs.
 *
 * Editing the `default` style edits the light (:root) values; editing the
 * `dark` style edits the [data-theme="dark"] values (resolved by colorMode).
 */
return [
    // Quick accent presets for the scheme chips. Clicking one cascades the
    // brand-token fields in the form (accent + hover + tint + link); JS only.
    'presets' => [
        ['name' => 'Default', 'accent' => '#0071e3'],
        ['name' => 'Emerald', 'accent' => '#14b17d'],
        ['name' => 'Violet',  'accent' => '#8c5cff'],
        ['name' => 'Rose',    'accent' => '#ff2d6b'],
        ['name' => 'Amber',   'accent' => '#f08a00'],
        ['name' => 'Slate',   'accent' => '#64748b'],
    ],

    // Editable tokens, grouped for the form. Each: var, label, light, dark.
    'groups' => [
        'Brand' => [
            ['var' => '--color-accent',       'label' => 'Accent',       'light' => '#0071e3',              'dark' => '#2997ff'],
            ['var' => '--color-accent-hover', 'label' => 'Accent hover', 'light' => '#0077ed',              'dark' => '#40a3ff'],
            ['var' => '--color-accent-light', 'label' => 'Accent tint',  'light' => 'rgba(0,113,227,0.08)', 'dark' => 'rgba(41,151,255,0.12)'],
            ['var' => '--color-link',         'label' => 'Link',         'light' => '#0066cc',              'dark' => '#2997ff'],
            ['var' => '--color-link-hover',   'label' => 'Link hover',   'light' => '#0071e3',              'dark' => '#40a3ff'],
        ],
        'Backgrounds' => [
            ['var' => '--color-bg',                'label' => 'Page',      'light' => '#fbfbfd', 'dark' => '#1c1c1e'],
            ['var' => '--color-surface',           'label' => 'Surface',   'light' => '#ffffff', 'dark' => '#2c2c2e'],
            ['var' => '--color-surface-secondary', 'label' => 'Surface 2', 'light' => '#f5f5f7', 'dark' => '#3a3a3c'],
            ['var' => '--color-surface-tertiary',  'label' => 'Surface 3', 'light' => '#fafafa', 'dark' => '#252527'],
        ],
        'Text' => [
            ['var' => '--color-text-primary',    'label' => 'Primary',    'light' => '#1d1d1f', 'dark' => '#f5f5f7'],
            ['var' => '--color-text-secondary',  'label' => 'Secondary',  'light' => '#6e6e73', 'dark' => '#a1a1a6'],
            ['var' => '--color-text-tertiary',   'label' => 'Tertiary',   'light' => '#86868b', 'dark' => '#8e8e93'],
            ['var' => '--color-text-quaternary', 'label' => 'Quaternary', 'light' => '#aeaeb2', 'dark' => '#636366'],
        ],
        'Borders' => [
            ['var' => '--color-border',       'label' => 'Border',       'light' => '#e8e8ed',          'dark' => '#3a3a3c'],
            ['var' => '--color-border-light', 'label' => 'Border light', 'light' => '#f0f0f5',          'dark' => '#2c2c2e'],
            ['var' => '--color-border-card',  'label' => 'Card border',  'light' => 'rgba(0,0,0,0.04)', 'dark' => 'rgba(255,255,255,0.06)'],
        ],
        'Status' => [
            ['var' => '--color-green',       'label' => 'Success',      'light' => '#30d158', 'dark' => '#30d158'],
            ['var' => '--color-green-text',  'label' => 'Success text', 'light' => '#248a3d', 'dark' => '#30d158'],
            ['var' => '--color-orange',      'label' => 'Warning',      'light' => '#ff9f0a', 'dark' => '#ff9f0a'],
            ['var' => '--color-orange-text', 'label' => 'Warning text', 'light' => '#c27400', 'dark' => '#ff9f0a'],
            ['var' => '--color-red',         'label' => 'Danger',       'light' => '#ff3b30', 'dark' => '#ff453a'],
            ['var' => '--color-red-text',    'label' => 'Danger text',  'light' => '#d70015', 'dark' => '#ff453a'],
        ],
        'Sidebar' => [
            ['var' => '--sidebar-bg',          'label' => 'Background',  'light' => 'rgba(246,246,248,0.80)', 'dark' => 'rgba(28,28,30,0.80)'],
            ['var' => '--sidebar-item-hover',  'label' => 'Item hover',  'light' => 'rgba(0,0,0,0.04)',       'dark' => 'rgba(255,255,255,0.05)'],
            ['var' => '--sidebar-item-active', 'label' => 'Item active', 'light' => 'rgba(0,0,0,0.06)',       'dark' => 'rgba(255,255,255,0.08)'],
            ['var' => '--sidebar-icon-bg',     'label' => 'Icon tile',   'light' => '#e8e8ed',                'dark' => '#3a3a3c'],
        ],
        'Topbar' => [
            ['var' => '--topbar-bg', 'label' => 'Background', 'light' => 'rgba(251,251,253,0.72)', 'dark' => 'rgba(44,44,46,0.72)'],
        ],
    ],
];
