<?php
/**
 * The newest WHMCS announcements as a dated list: the day and month in a
 * rail on the left, then the date, title and opening lines, each linking to
 * the full announcement. The heading and the links are written here.
 * Markup and classes: the theme's hp-announce-list block.
 */
return [
    'label'  => 'Latest announcements, list',
    'hint'   => 'Your newest WHMCS announcements as a dated list',
    'group'  => 'Announcements',
    'order'  => 940,
    'data'   => ['announcements'],
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'News and notices']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'What has changed, and what is planned.']],
        ['key' => 'count', 'type' => 'number', 'label' => 'Announcements to show', 'min' => 1, 'max' => 12, 'default' => 4,
            'help' => 'The newest published announcements.'],
        ['key' => 'months', 'type' => 'lines', 'label' => 'Month names', 'translatable' => true,
            'default' => ['_' => "Jan\nFeb\nMar\nApr\nMay\nJun\nJul\nAug\nSep\nOct\nNov\nDec"],
            'help' => 'Twelve short names, January first, one per line. Shown under the day of each announcement. Leave empty to show the day alone.'],
        ['key' => 'readLabel', 'type' => 'text', 'label' => 'Link under each announcement', 'translatable' => true, 'default' => ['_' => 'Read more'],
            'help' => 'Leave empty to make the title the link.'],
        ['key' => 'viewAllLabel', 'type' => 'text', 'label' => 'Button to all announcements, text', 'translatable' => true, 'default' => ['_' => 'All announcements']],
        ['key' => 'viewAllLink', 'type' => 'link', 'label' => 'Button to all announcements', 'default' => 'announcements.php'],
    ],
];
