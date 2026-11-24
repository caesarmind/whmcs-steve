<?php
/**
 * One large statement whose opening words are coloured, with a paragraph
 * under it and a picture or an icon panel beside it.
 * Markup and classes: the theme's hp-stat-callout block. The theme has no
 * rules of its own for it, so the layout borrows hp-alternating (row, text
 * column, visual box) and the headline carries its own size.
 */
return [
    'label'  => 'Single big number',
    'hint'   => 'One large statement beside a picture',
    'group'  => 'Features',
    'order'  => 390,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Backups'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'highlight', 'type' => 'text', 'label' => 'Headline, coloured part', 'translatable' => true, 'default' => ['_' => '30 days'],
            'help' => 'The number or the few words that open the headline.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline, the rest', 'translatable' => true, 'default' => ['_' => 'of backups, kept for every site we host.']],
        ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'blue',
            'options' => ['blue' => 'Blue', 'green' => 'Green', 'orange' => 'Orange', 'red' => 'Red']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'If an update goes wrong or a file goes missing, pick a day and restore it from your control panel.']],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
        ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon when there is no image', 'default' => 'refresh'],
    ],
];
