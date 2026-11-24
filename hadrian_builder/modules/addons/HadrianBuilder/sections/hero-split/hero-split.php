<?php
/**
 * Hero with the headline on one side and an image on the other.
 * Markup and classes: the theme's hp-hero-split block.
 */
return [
    'label'  => 'Hero, split',
    'hint'   => 'Headline and buttons beside an image',
    'group'  => 'Hero',
    'order'  => 105,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Web hosting'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Hosting that stays out of your way']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Fast servers, daily backups and people who answer when you write. Set up in minutes.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => '#pricing',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Talk to us']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => 'contact.php'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
        ['key' => 'flip', 'type' => 'toggle', 'label' => 'Image on the left', 'default' => false],
    ],
];
