<?php
/**
 * The per-block / per-surface colour palette -- the swatches behind the
 * "Colour source > Theme" control in the Pages editor.
 *
 * ONE COPY. This list was declared identically in atrium.php, bento.php and
 * minimal.php, and the login variants needed it too; a fifth hand-kept copy of
 * thirteen tokens is a drift waiting to happen, so it lives here and manifests
 * require it:
 *
 *     'paints' => require __DIR__ . '/../../../config/paints.php',
 *
 * Read by PagesController::resolvePaintSwatches, which turns each entry into a
 * chip by resolving its `var` against core/config/colors.php AND the active
 * style's stored overrides -- so the swatch shows the colour the site actually
 * renders, not the shipped default.
 *
 * `track` is the caption split in the control, and it is the genuinely
 * surprising part the mode switch does not express:
 *   preset  moves when you switch style preset
 *   token   has its own row on Styles > Colors and does not
 */
return [
    // ROLE colours, first because they are the ones that answer "make this
    // follow the style". A preset writes accent, accent hover, accent tint and
    // link -- so these two are the pair that moves when a preset is switched:
    // the ACTIVE one and its quiet counterpart. Neutral is the style's own
    // muted surface, which also flips with dark mode.
    'accent' => ['label' => 'Accent (active)',   'var' => '--color-accent',            'track' => 'preset'],
    // Passive is DERIVED from the accent rather than pointing at
    // --color-accent-light: that token is an 8%-alpha tint meant to sit behind
    // text, so as a fill it is barely a colour and, being translucent, would
    // let the page show through a solid. 'mix' is the same figure the CSS uses,
    // declared here so the admin swatch can compute the identical value.
    'quiet'  => ['label' => 'Accent (passive)',  'var' => '--color-accent', 'track' => 'preset',
                 'mix'   => 45, 'mixWith' => '--color-surface'],
    'neutral'=> ['label' => 'Neutral',           'var' => '--color-surface-secondary', 'track' => 'token'],
    'indigo' => ['label' => 'Indigo',            'var' => '--color-icon-indigo',       'track' => 'token'],
    'purple' => ['label' => 'Purple',            'var' => '--color-icon-purple',       'track' => 'token'],
    'green'  => ['label' => 'Green',             'var' => '--color-icon-green',        'track' => 'token'],
    'teal'   => ['label' => 'Teal',              'var' => '--color-icon-teal',         'track' => 'token'],
    'orange' => ['label' => 'Orange',            'var' => '--color-icon-orange',       'track' => 'token'],
    'red'    => ['label' => 'Red',               'var' => '--color-icon-red',          'track' => 'token'],
    'gray'   => ['label' => 'Gray',              'var' => '--color-icon-gray',         'track' => 'token'],
    'block1' => ['label' => 'Block accent 1',    'var' => '--color-block-1',           'track' => 'token'],
    'block2' => ['label' => 'Block accent 2',    'var' => '--color-block-2',           'track' => 'token'],
    'block3' => ['label' => 'Block accent 3',    'var' => '--color-block-3',           'track' => 'token'],
];
