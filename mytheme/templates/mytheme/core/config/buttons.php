<?php
/**
 * Button schema — single source of truth for the admin Buttons panel
 * (StylesController::buildButtonsViewModel) and the render-time emitter
 * (Hooks::buildButtonsHead). Mirrors core/config/colors.php in spirit.
 *
 * Lagom-parity: a "Sizes" block (height / padding / radius / font per S-M-L)
 * plus a per-variant COLOUR MATRIX. Matrix values are select-colors REFERENCES
 * — each slot stores a `colorOptions` KEY, and the emitter turns it into the
 * option's `css` (a var(), a literal hex, transparent, or rgba()). Because the
 * referenced ramp/base tokens are themselves mode-aware (defined in :root AND
 * [data-theme="dark"] in apple-theme.css), one GLOBAL mapping styles both light
 * and dark automatically — so this panel is site-wide, not per-style.
 *
 * Every `default` below MUST mirror the matching --btn-* default in
 * assets/css/apple-theme.css, or the "is this an override?" comparison desyncs.
 */
return [
    /* select-colors palette. key = stored token; css = emitted property value;
       swatch = light-mode preview for the admin dropdown (cosmetic only).
       `group` buckets them into <optgroup>s. */
    'colorOptions' => [
        // Primary ramp
        ['key' => 'primary',           'group' => 'Primary',   'label' => 'Primary',          'css' => 'var(--brand-primary)',           'swatch' => '#0071e3'],
        ['key' => 'primary-hover',     'group' => 'Primary',   'label' => 'Primary hover',    'css' => 'var(--color-accent-hover)',      'swatch' => '#0077ed'],
        ['key' => 'primary-darker',    'group' => 'Primary',   'label' => 'Primary darker',   'css' => 'var(--brand-primary-darker)',    'swatch' => '#0058b1'],
        ['key' => 'primary-lighter-2', 'group' => 'Primary',   'label' => 'Primary tint 70%', 'css' => 'var(--brand-primary-lighter-2)', 'swatch' => '#b3d5f7'],
        ['key' => 'primary-lighter-3', 'group' => 'Primary',   'label' => 'Primary tint 84%', 'css' => 'var(--brand-primary-lighter-3)', 'swatch' => '#d6e2fa'],
        ['key' => 'primary-lighter-4', 'group' => 'Primary',   'label' => 'Primary tint 92%', 'css' => 'var(--brand-primary-lighter-4)', 'swatch' => '#eaf1fc'],
        // Slate / secondary brand ramp
        ['key' => 'slate',             'group' => 'Slate',     'label' => 'Slate',            'css' => 'var(--brand-secondary)',         'swatch' => '#64748b'],
        ['key' => 'slate-darker',      'group' => 'Slate',     'label' => 'Slate darker',     'css' => 'var(--brand-secondary-darker)',  'swatch' => '#4e5a6c'],
        ['key' => 'slate-lighter-3',   'group' => 'Slate',     'label' => 'Slate tint 84%',   'css' => 'var(--brand-secondary-lighter-3)','swatch' => '#dfe2e8'],
        // Info
        ['key' => 'info',              'group' => 'Status',    'label' => 'Info',             'css' => 'var(--brand-info)',              'swatch' => '#0a84ff'],
        ['key' => 'info-darker',       'group' => 'Status',    'label' => 'Info darker',      'css' => 'var(--brand-info-darker)',       'swatch' => '#0867c6'],
        // Success
        ['key' => 'success',           'group' => 'Status',    'label' => 'Success',          'css' => 'var(--brand-success)',           'swatch' => '#30d158'],
        ['key' => 'success-darker',    'group' => 'Status',    'label' => 'Success darker',   'css' => 'var(--brand-success-darker)',    'swatch' => '#25a345'],
        ['key' => 'success-fill',      'group' => 'Status',    'label' => 'Success fill',     'css' => 'var(--color-green-bg)',          'swatch' => '#e8f9ed'],
        ['key' => 'success-text',      'group' => 'Status',    'label' => 'Success text',     'css' => 'var(--color-green-text)',        'swatch' => '#248a3d'],
        // Warning
        ['key' => 'warning',           'group' => 'Status',    'label' => 'Warning',          'css' => 'var(--brand-warning)',           'swatch' => '#ff9f0a'],
        ['key' => 'warning-darker',    'group' => 'Status',    'label' => 'Warning darker',   'css' => 'var(--brand-warning-darker)',    'swatch' => '#c77c08'],
        ['key' => 'warning-fill',      'group' => 'Status',    'label' => 'Warning fill',     'css' => 'var(--color-orange-bg)',         'swatch' => '#fff3e0'],
        ['key' => 'warning-text',      'group' => 'Status',    'label' => 'Warning text',     'css' => 'var(--color-orange-text)',       'swatch' => '#c27400'],
        // Danger
        ['key' => 'danger',            'group' => 'Status',    'label' => 'Danger',           'css' => 'var(--brand-danger)',            'swatch' => '#ff3b30'],
        ['key' => 'danger-darker',     'group' => 'Status',    'label' => 'Danger darker',    'css' => 'var(--brand-danger-darker)',     'swatch' => '#c62e26'],
        ['key' => 'danger-fill',       'group' => 'Status',    'label' => 'Danger fill',      'css' => 'var(--color-red-bg)',            'swatch' => '#ffe6e5'],
        ['key' => 'danger-text',       'group' => 'Status',    'label' => 'Danger text',      'css' => 'var(--color-red-text)',          'swatch' => '#d70015'],
        // Neutrals / surfaces
        ['key' => 'text',              'group' => 'Neutral',   'label' => 'Text',             'css' => 'var(--color-text-primary)',      'swatch' => '#1d1d1f'],
        ['key' => 'text-2',            'group' => 'Neutral',   'label' => 'Text secondary',   'css' => 'var(--color-text-secondary)',    'swatch' => '#6e6e73'],
        ['key' => 'surface',           'group' => 'Neutral',   'label' => 'Surface',          'css' => 'var(--color-surface)',           'swatch' => '#ffffff'],
        ['key' => 'surface-2',         'group' => 'Neutral',   'label' => 'Surface 2',        'css' => 'var(--color-surface-secondary)', 'swatch' => '#f5f5f7'],
        ['key' => 'border',            'group' => 'Neutral',   'label' => 'Border',           'css' => 'var(--color-border)',            'swatch' => '#e8e8ed'],
        // Literals / overlays
        ['key' => 'white',             'group' => 'Basic',     'label' => 'White',            'css' => '#ffffff',                        'swatch' => '#ffffff'],
        ['key' => 'black',             'group' => 'Basic',     'label' => 'Black',            'css' => '#000000',                        'swatch' => '#000000'],
        ['key' => 'transparent',       'group' => 'Basic',     'label' => 'Transparent',      'css' => 'transparent',                    'swatch' => 'transparent'],
        ['key' => 'white-08',          'group' => 'Basic',     'label' => 'White 8%',         'css' => 'rgba(255,255,255,0.08)',         'swatch' => '#1f1f1f'],
        ['key' => 'white-16',          'group' => 'Basic',     'label' => 'White 16%',        'css' => 'rgba(255,255,255,0.16)',         'swatch' => '#333333'],
        ['key' => 'white-24',          'group' => 'Basic',     'label' => 'White 24%',        'css' => 'rgba(255,255,255,0.24)',         'swatch' => '#4d4d4d'],
    ],

    /* Size tiers (Small / Base / Large -> .btn-sm / .btn / .btn-lg). Geometry
       (height + padding) stays px so the Apple pill keeps its exact dimensions;
       font / weight / line-height / radius are SCALE references (Lagom-style),
       resolved through `scales` below — so they track the design system and
       default to the Apple look (radius -> Pill). For scale fields `default`
       is a scale KEY; for px fields it's the numeric baseline. Defaults MUST
       mirror the --btn-* tokens in apple-theme.css. */
    'sizeMin' => 0,
    'sizeMax' => 999,
    'scales'  => [
        'font' => [
            ['key' => 'xs',   'label' => 'Extra Small', 'css' => 'var(--text-xs)'],
            ['key' => 'sm',   'label' => 'Small',       'css' => 'var(--text-sm)'],
            ['key' => 'base', 'label' => 'Base',        'css' => 'var(--text-base)'],
            ['key' => 'md',   'label' => 'Medium',      'css' => 'var(--text-md)'],
            ['key' => 'lg',   'label' => 'Large',       'css' => 'var(--text-lg)'],
            ['key' => 'xl',   'label' => 'Extra Large', 'css' => 'var(--text-xl)'],
            ['key' => '2xl',  'label' => '2X Large',    'css' => 'var(--text-2xl)'],
        ],
        'weight' => [
            ['key' => 'light',    'label' => 'Light',    'css' => 'var(--fw-light)'],
            ['key' => 'normal',   'label' => 'Regular',  'css' => 'var(--fw-normal)'],
            ['key' => 'medium',   'label' => 'Medium',   'css' => 'var(--fw-medium)'],
            ['key' => 'semibold', 'label' => 'Semibold', 'css' => 'var(--fw-semibold)'],
            ['key' => 'bold',     'label' => 'Bold',     'css' => 'var(--fw-bold)'],
        ],
        'lineHeight' => [
            ['key' => 'tight',   'label' => 'Tight (1.0)',    'css' => '1'],
            ['key' => 'snug',    'label' => 'Snug (1.1)',     'css' => '1.1'],
            ['key' => 'normal',  'label' => 'Normal (1.2)',   'css' => '1.2'],
            ['key' => 'relaxed', 'label' => 'Relaxed (1.35)', 'css' => '1.35'],
        ],
        'radius' => [
            ['key' => 'none', 'label' => 'None',   'css' => '0'],
            ['key' => 'sm',   'label' => 'Small',  'css' => 'var(--radius-sm)'],
            ['key' => 'md',   'label' => 'Medium', 'css' => 'var(--radius-md)'],
            ['key' => 'lg',   'label' => 'Large',  'css' => 'var(--radius-lg)'],
            ['key' => 'pill', 'label' => 'Pill',   'css' => 'var(--radius-pill)'],
        ],
    ],
    'sizeTiers' => [
        'Small' => [
            ['var' => '--btn-sm-height',      'label' => 'Height',      'type' => 'px',    'default' => 30],
            ['var' => '--btn-sm-padding-x',   'label' => 'Padding X',   'type' => 'px',    'default' => 14],
            ['var' => '--btn-sm-font-size',   'label' => 'Font size',   'type' => 'scale', 'scale' => 'font',       'default' => 'sm'],
            ['var' => '--btn-sm-font-weight', 'label' => 'Font weight', 'type' => 'scale', 'scale' => 'weight',     'default' => 'medium'],
            ['var' => '--btn-sm-line-height', 'label' => 'Line height', 'type' => 'scale', 'scale' => 'lineHeight', 'default' => 'normal'],
            ['var' => '--btn-sm-radius',      'label' => 'Radius',      'type' => 'scale', 'scale' => 'radius',     'default' => 'pill'],
        ],
        'Base' => [
            ['var' => '--btn-height',      'label' => 'Height',      'type' => 'px',    'default' => 36],
            ['var' => '--btn-padding-x',   'label' => 'Padding X',   'type' => 'px',    'default' => 20],
            ['var' => '--btn-font-size',   'label' => 'Font size',   'type' => 'scale', 'scale' => 'font',       'default' => 'md'],
            ['var' => '--btn-font-weight', 'label' => 'Font weight', 'type' => 'scale', 'scale' => 'weight',     'default' => 'medium'],
            ['var' => '--btn-line-height', 'label' => 'Line height', 'type' => 'scale', 'scale' => 'lineHeight', 'default' => 'normal'],
            ['var' => '--btn-radius',      'label' => 'Radius',      'type' => 'scale', 'scale' => 'radius',     'default' => 'pill'],
        ],
        'Large' => [
            ['var' => '--btn-lg-height',      'label' => 'Height',      'type' => 'px',    'default' => 44],
            ['var' => '--btn-lg-padding-x',   'label' => 'Padding X',   'type' => 'px',    'default' => 28],
            ['var' => '--btn-lg-font-size',   'label' => 'Font size',   'type' => 'scale', 'scale' => 'font',       'default' => 'xl'],
            ['var' => '--btn-lg-font-weight', 'label' => 'Font weight', 'type' => 'scale', 'scale' => 'weight',     'default' => 'medium'],
            ['var' => '--btn-lg-line-height', 'label' => 'Line height', 'type' => 'scale', 'scale' => 'lineHeight', 'default' => 'normal'],
            ['var' => '--btn-lg-radius',      'label' => 'Radius',      'type' => 'scale', 'scale' => 'radius',     'default' => 'pill'],
        ],
    ],

    /* The 8 colour slots every variant exposes, in --btn-<variant>-<slot> order. */
    'slots' => [
        ['key' => 'bg',            'label' => 'Background'],
        ['key' => 'border',        'label' => 'Border'],
        ['key' => 'color',         'label' => 'Text'],
        ['key' => 'hover-bg',      'label' => 'Hover bg'],
        ['key' => 'hover-border',  'label' => 'Hover border'],
        ['key' => 'hover-color',   'label' => 'Hover text'],
        ['key' => 'active-bg',     'label' => 'Active bg'],
        ['key' => 'active-border', 'label' => 'Active border'],
    ],

    /* The variant matrix. Each `slots` value is a colorOptions key; these are
       the per-mode defaults and MUST mirror apple-theme.css --btn-* tokens. */
    'variants' => [
        ['key' => 'default', 'label' => 'Default', 'slots' => [
            'bg' => 'transparent', 'border' => 'border', 'color' => 'text',
            'hover-bg' => 'surface-2', 'hover-border' => 'border', 'hover-color' => 'text',
            'active-bg' => 'surface-2', 'active-border' => 'transparent',
        ]],
        ['key' => 'primary', 'label' => 'Primary', 'slots' => [
            'bg' => 'primary', 'border' => 'primary', 'color' => 'white',
            'hover-bg' => 'primary-hover', 'hover-border' => 'primary-hover', 'hover-color' => 'white',
            'active-bg' => 'primary-hover', 'active-border' => 'primary-hover',
        ]],
        ['key' => 'primary-faded', 'label' => 'Primary faded', 'slots' => [
            'bg' => 'primary-lighter-3', 'border' => 'primary-lighter-3', 'color' => 'primary',
            'hover-bg' => 'primary-lighter-2', 'hover-border' => 'primary-lighter-2', 'hover-color' => 'primary',
            'active-bg' => 'primary-lighter-2', 'active-border' => 'primary-lighter-2',
        ]],
        ['key' => 'secondary', 'label' => 'Secondary', 'slots' => [
            'bg' => 'surface-2', 'border' => 'border', 'color' => 'text',
            'hover-bg' => 'surface', 'hover-border' => 'border', 'hover-color' => 'text',
            'active-bg' => 'surface-2', 'active-border' => 'border',
        ]],
        ['key' => 'success', 'label' => 'Success', 'slots' => [
            'bg' => 'success', 'border' => 'success', 'color' => 'white',
            'hover-bg' => 'success-darker', 'hover-border' => 'success-darker', 'hover-color' => 'white',
            'active-bg' => 'success-darker', 'active-border' => 'success-darker',
        ]],
        ['key' => 'info', 'label' => 'Info', 'slots' => [
            'bg' => 'info', 'border' => 'info', 'color' => 'white',
            'hover-bg' => 'info-darker', 'hover-border' => 'info-darker', 'hover-color' => 'white',
            'active-bg' => 'info-darker', 'active-border' => 'info-darker',
        ]],
        ['key' => 'warning', 'label' => 'Warning', 'slots' => [
            'bg' => 'warning', 'border' => 'warning', 'color' => 'white',
            'hover-bg' => 'warning-darker', 'hover-border' => 'warning-darker', 'hover-color' => 'white',
            'active-bg' => 'warning-darker', 'active-border' => 'warning-darker',
        ]],
        ['key' => 'danger', 'label' => 'Danger', 'slots' => [
            'bg' => 'danger-fill', 'border' => 'transparent', 'color' => 'danger-text',
            'hover-bg' => 'danger', 'hover-border' => 'danger', 'hover-color' => 'white',
            'active-bg' => 'danger', 'active-border' => 'danger',
        ]],
        ['key' => 'light', 'label' => 'Light (on dark)', 'slots' => [
            'bg' => 'white-08', 'border' => 'white-16', 'color' => 'white',
            'hover-bg' => 'white-16', 'hover-border' => 'white-24', 'hover-color' => 'white',
            'active-bg' => 'white-24', 'active-border' => 'white-24',
        ]],
    ],
];
