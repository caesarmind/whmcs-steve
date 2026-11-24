<?php
/**
 * The newest WHMCS announcements as a row of cards: title, opening lines and
 * date, each linking to the full announcement. The heading and the links
 * around the cards are written here.
 * Markup and classes: the theme's hp-announce-grid block.
 */
return [
    'label'  => 'Latest announcements, cards',
    'hint'   => 'Your newest WHMCS announcements as cards',
    'group'  => 'Announcements',
    'order'  => 930,
    'data'   => ['announcements'],
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Latest news']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Service updates, maintenance and new features.']],
        ['key' => 'count', 'type' => 'number', 'label' => 'Announcements to show', 'min' => 1, 'max' => 12, 'default' => 3,
            'help' => 'The newest published announcements, three to a row.'],
        ['key' => 'readLabel', 'type' => 'text', 'label' => 'Text at the foot of each card', 'translatable' => true, 'default' => ['_' => 'Read']],
        ['key' => 'viewAllLabel', 'type' => 'text', 'label' => 'Link to all announcements, text', 'translatable' => true, 'default' => ['_' => 'View all']],
        ['key' => 'viewAllLink', 'type' => 'link', 'label' => 'Link to all announcements', 'default' => 'announcements.php'],
    ],
];
