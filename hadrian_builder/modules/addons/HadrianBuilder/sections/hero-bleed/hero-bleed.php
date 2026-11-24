<?php
/**
 * Hero on a black band that runs the full width of the page, with a soft
 * glow behind a centered headline, text and buttons.
 * Markup and classes: the theme's hp-hero-bleed block.
 */
return [
    'label'  => 'Hero, full width',
    'hint'   => 'Black band with a glow behind the headline',
    'group'  => 'Hero',
    'order'  => 135,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Hosting, domains and email'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'One account for everything online']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Register the name, host the site and run the mailboxes from a single place.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Get started']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'See what is included']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => '#features'],
    ],
];
