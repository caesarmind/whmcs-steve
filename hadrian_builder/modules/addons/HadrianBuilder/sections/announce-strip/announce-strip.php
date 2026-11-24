<?php
/**
 * A thin bar across the page: a small tag, one line of text and a link.
 * Written here, not taken from WHMCS announcements.
 * Markup and classes: the theme's hp-announce-strip block.
 */
return [
    'label'  => 'Announcement bar',
    'hint'   => 'A thin bar with a line of text and a link',
    'group'  => 'Announcements',
    'order'  => 900,
    'fields' => [
        ['key' => 'tag', 'type' => 'text', 'label' => 'Tag', 'translatable' => true, 'default' => ['_' => 'New'],
            'help' => 'The small pill before the text. Leave empty to hide it.'],
        ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'We move your existing site for free with every yearly hosting plan.']],
        ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
    ],
];
