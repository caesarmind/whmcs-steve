<?php
/**
 * A wide card that announces something: a short line, a headline, a
 * paragraph and two buttons beside a picture. Written here, not taken from
 * WHMCS announcements.
 * Markup and classes: the theme's hp-announce-card block.
 */
return [
    'label'  => 'Launch announcement',
    'hint'   => 'A card with a headline, text and two buttons',
    'group'  => 'Announcements',
    'order'  => 910,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Badge', 'translatable' => true, 'default' => ['_' => 'Just launched'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'A new data centre in Frankfurt']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Host your site closer to your visitors in Europe. Pick the new location when you order, or ask us to move an account you already have.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Read the news']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => 'announcements.php'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
            'help' => 'Leave empty to show the drawing that comes with the theme.'],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
    ],
];
