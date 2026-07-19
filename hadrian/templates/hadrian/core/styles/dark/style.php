<?php
/**
 * Style preset manifest — DARK. See default/style.php for the full notes on
 * what belongs here and what lives in the admin Styles tabs instead.
 */
return [
    'name'        => 'Dark',
    'description' => 'Dark surfaces, light text. Toggleable via display_mode_switcher.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-dark',
        // Load-bearing: StylesController drops colorMode 'dark' presets from
        // the activatable list. Remove it and this reappears as a selectable
        // style, which it is no longer meant to be. See default/style.php.
        'colorMode' => 'dark',
    ],
];
