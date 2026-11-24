<?php
/**
 * Two calls to action side by side in one rounded block: a dark panel and
 * a light one, each with a heading, a line of text and a button.
 * Markup and classes: the theme's hp-split-cta block.
 */
return [
    'label'  => 'Two-way call to action',
    'hint'   => 'A dark and a light panel, each with a button',
    'group'  => 'Call to action',
    'order'  => 810,
    'fields' => [
        ['key' => 'firstTitle', 'type' => 'text', 'label' => 'Dark panel: heading', 'translatable' => true, 'default' => ['_' => 'Start a new site']],
        ['key' => 'firstText', 'type' => 'textarea', 'label' => 'Dark panel: text', 'translatable' => true, 'default' => ['_' => 'Pick a plan and be online today.']],
        ['key' => 'firstLabel', 'type' => 'text', 'label' => 'Dark panel: button text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'firstLink', 'type' => 'link', 'label' => 'Dark panel: button link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondTitle', 'type' => 'text', 'label' => 'Light panel: heading', 'translatable' => true, 'default' => ['_' => 'Moving from another host?']],
        ['key' => 'secondText', 'type' => 'textarea', 'label' => 'Light panel: text', 'translatable' => true, 'default' => ['_' => 'We bring your site over for you.']],
        ['key' => 'secondLabel', 'type' => 'text', 'label' => 'Light panel: button text', 'translatable' => true, 'default' => ['_' => 'Ask about a move']],
        ['key' => 'secondLink', 'type' => 'link', 'label' => 'Light panel: button link', 'default' => 'contact.php',
            'help' => 'Leave a whole panel empty to show only the other one.'],
    ],
];
