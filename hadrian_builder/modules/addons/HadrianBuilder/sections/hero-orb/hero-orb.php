<?php
/**
 * Hero with a large glowing orb pulsing behind a centered headline, text
 * and buttons.
 * Markup and classes: the theme's hp-hero-orb block.
 */
return [
    'label'  => 'Hero, orb',
    'hint'   => 'A glowing orb behind the headline',
    'group'  => 'Hero',
    'order'  => 150,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Cloud servers'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Online in a minute']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Pick a size, choose a location and your server is running before the kettle boils.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Build a server']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Compare sizes']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => '#pricing'],
    ],
];
