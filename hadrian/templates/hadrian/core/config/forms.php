<?php
/**
 * Form schema — single source of truth for the admin Forms panel
 * (StylesController::buildFormsViewModel) and the render-time emitter
 * (Hooks::buildFormsHead). Mirrors core/config/buttons.php.
 *
 * Lagom-parity: three sections (Field / Label / Checkbox & radio). Sizes are
 * px or SCALE references (font / radius / border-width via `scales`); colours
 * are select-colors REFERENCES — each slot stores a `colorOptions` KEY and the
 * emitter turns it into the option's `css` (a var(), hex, or rgba()). The
 * referenced tokens are mode-aware in core-theme.css, so one GLOBAL mapping
 * styles both light + dark — this panel is site-wide, not per-style.
 *
 * Every `default` MUST mirror the matching --input-* / --icheck-* token in
 * assets/css/core-theme.css, or the "is this an override?" comparison desyncs.
 */
return [
    /* select-colors palette (focused subset of the theme colours that make
       sense for form fields). key = stored; css = emitted value; swatch =
       light-mode preview for the dropdown; group buckets the <optgroup>s. */
    'colorOptions' => [
        ['key' => 'primary',      'group' => 'Primary', 'label' => 'Primary',       'css' => 'var(--color-accent)',          'swatch' => '#0071e3'],
        ['key' => 'primary-hover','group' => 'Primary', 'label' => 'Primary hover',  'css' => 'var(--color-accent-hover)',    'swatch' => '#0077ed'],
        ['key' => 'accent-tint',  'group' => 'Primary', 'label' => 'Accent tint',    'css' => 'var(--color-accent-light)',    'swatch' => '#eaf1fc'],
        ['key' => 'success',      'group' => 'Status',  'label' => 'Success',        'css' => 'var(--color-green)',           'swatch' => '#30d158'],
        ['key' => 'warning',      'group' => 'Status',  'label' => 'Warning',        'css' => 'var(--color-orange)',          'swatch' => '#ff9f0a'],
        ['key' => 'danger',       'group' => 'Status',  'label' => 'Danger',         'css' => 'var(--color-red)',             'swatch' => '#ff3b30'],
        ['key' => 'info',         'group' => 'Status',  'label' => 'Info',           'css' => 'var(--brand-info)',            'swatch' => '#0a84ff'],
        ['key' => 'text',         'group' => 'Neutral', 'label' => 'Text',           'css' => 'var(--color-text-primary)',    'swatch' => '#1d1d1f'],
        ['key' => 'text-2',       'group' => 'Neutral', 'label' => 'Text secondary', 'css' => 'var(--color-text-secondary)',  'swatch' => '#6e6e73'],
        ['key' => 'text-3',       'group' => 'Neutral', 'label' => 'Text tertiary',  'css' => 'var(--color-text-tertiary)',   'swatch' => '#86868b'],
        ['key' => 'text-4',       'group' => 'Neutral', 'label' => 'Text muted',     'css' => 'var(--color-text-quaternary)', 'swatch' => '#aeaeb2'],
        ['key' => 'surface',      'group' => 'Neutral', 'label' => 'Surface',        'css' => 'var(--color-surface)',         'swatch' => '#ffffff'],
        ['key' => 'surface-2',    'group' => 'Neutral', 'label' => 'Surface 2',      'css' => 'var(--color-surface-secondary)','swatch' => '#f5f5f7'],
        ['key' => 'border',       'group' => 'Neutral', 'label' => 'Border',         'css' => 'var(--color-border)',          'swatch' => '#e8e8ed'],
        ['key' => 'border-light', 'group' => 'Neutral', 'label' => 'Border light',   'css' => 'var(--color-border-light)',    'swatch' => '#f0f0f5'],
        ['key' => 'white',        'group' => 'Basic',   'label' => 'White',          'css' => '#ffffff',                      'swatch' => '#ffffff'],
        ['key' => 'transparent',  'group' => 'Basic',   'label' => 'Transparent',    'css' => 'transparent',                  'swatch' => 'transparent'],
    ],

    'scales' => [
        'font' => [
            ['key' => 'xs',   'label' => 'Extra Small', 'css' => 'var(--text-xs)'],
            ['key' => 'sm',   'label' => 'Small',       'css' => 'var(--text-sm)'],
            ['key' => 'base', 'label' => 'Base',        'css' => 'var(--text-base)'],
            ['key' => 'md',   'label' => 'Medium',      'css' => 'var(--text-md)'],
            ['key' => 'lg',   'label' => 'Large',       'css' => 'var(--text-lg)'],
            ['key' => 'xl',   'label' => 'Extra Large', 'css' => 'var(--text-xl)'],
        ],
        'weight' => [
            ['key' => 'light',    'label' => 'Light',    'css' => 'var(--fw-light)'],
            ['key' => 'normal',   'label' => 'Regular',  'css' => 'var(--fw-normal)'],
            ['key' => 'medium',   'label' => 'Medium',   'css' => 'var(--fw-medium)'],
            ['key' => 'semibold', 'label' => 'Semibold', 'css' => 'var(--fw-semibold)'],
            ['key' => 'bold',     'label' => 'Bold',     'css' => 'var(--fw-bold)'],
        ],
        'radius' => [
            ['key' => 'none', 'label' => 'None',   'css' => '0'],
            ['key' => 'sm',   'label' => 'Small',  'css' => 'var(--radius-sm)'],
            ['key' => 'md',   'label' => 'Medium', 'css' => 'var(--radius-md)'],
            ['key' => 'lg',   'label' => 'Large',  'css' => 'var(--radius-lg)'],
            ['key' => 'pill', 'label' => 'Pill',   'css' => 'var(--radius-pill)'],
        ],
        'borderWidth' => [
            ['key' => 'hairline', 'label' => 'Hairline (0.5px)', 'css' => '0.5px'],
            ['key' => 'thin',     'label' => 'Thin (1px)',       'css' => '1px'],
            ['key' => 'medium',   'label' => 'Medium (2px)',     'css' => '2px'],
        ],
    ],
    'sizeMin' => 0,
    'sizeMax' => 999,

    /* Size fields, grouped by section. type: px | scale (with `scale` key). */
    'sizeGroups' => [
        'Field' => [
            ['var' => '--input-font-size',    'label' => 'Font size',    'type' => 'scale', 'scale' => 'font',        'default' => 'lg'],
            ['var' => '--input-radius',       'label' => 'Radius',       'type' => 'scale', 'scale' => 'radius',      'default' => 'sm'],
            ['var' => '--input-border-width', 'label' => 'Border width', 'type' => 'scale', 'scale' => 'borderWidth', 'default' => 'hairline'],
        ],
        'Label' => [
            ['var' => '--input-label-font-size',   'label' => 'Font size',   'type' => 'scale', 'scale' => 'font',   'default' => 'base'],
            ['var' => '--input-label-font-weight', 'label' => 'Font weight', 'type' => 'scale', 'scale' => 'weight', 'default' => 'medium'],
        ],
        'Checkbox & radio' => [
            ['var' => '--icheck-size', 'label' => 'Size', 'type' => 'px', 'default' => 18],
        ],
    ],

    /* Colour fields, grouped by section. Each value is a colorOptions key
       (the per-mode default) and MUST mirror core-theme.css. */
    'colorGroups' => [
        'Field' => [
            ['var' => '--input-bg',                  'label' => 'Background',    'default' => 'surface'],
            ['var' => '--input-border-color',        'label' => 'Border',        'default' => 'border'],
            ['var' => '--input-color',               'label' => 'Text',          'default' => 'text'],
            ['var' => '--input-placeholder-color',   'label' => 'Placeholder',   'default' => 'text-4'],
            ['var' => '--input-focus-border-color',  'label' => 'Focus border',  'default' => 'primary'],
            ['var' => '--input-focus-ring',          'label' => 'Focus ring',    'default' => 'accent-tint'],
            ['var' => '--input-disabled-bg',         'label' => 'Disabled bg',   'default' => 'surface-2'],
        ],
        'Label' => [
            ['var' => '--input-label-color', 'label' => 'Text', 'default' => 'text'],
        ],
        'Checkbox & radio' => [
            ['var' => '--icheck-accent', 'label' => 'Accent', 'default' => 'primary'],
        ],
    ],
];
