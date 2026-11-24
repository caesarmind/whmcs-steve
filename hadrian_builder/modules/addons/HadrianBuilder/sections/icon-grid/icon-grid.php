<?php
/**
 * Large coloured icons in a grid, each with a title and a short line, under
 * a centred heading.
 * Markup and classes: the theme's hp-icon-grid block.
 */
return [
    'label'  => 'Icon grid',
    'hint'   => 'Large icons with a title and a line',
    'group'  => 'Features',
    'order'  => 325,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Why host with us']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'What you get on every plan.']],
        ['key' => 'columns', 'type' => 'select', 'label' => 'Icons per row', 'options' => ['2' => 'Two', '3' => 'Three', '4' => 'Four'], 'default' => '3'],
        ['key' => 'items', 'type' => 'list', 'label' => 'Icons', 'max' => 12, 'itemLabel' => 'title', 'addLabel' => 'Add icon',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'colour', 'type' => 'select', 'label' => 'Icon colour', 'default' => 'blue',
                    'options' => ['blue' => 'Blue', 'green' => 'Green', 'purple' => 'Purple', 'orange' => 'Orange', 'teal' => 'Teal', 'red' => 'Red']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Title']],
                ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['icon' => 'bolt', 'colour' => 'blue', 'title' => ['_' => 'Quick to load'], 'text' => ['_' => 'Fast disks and caching.']],
                ['icon' => 'shield', 'colour' => 'green', 'title' => ['_' => 'Kept safe'], 'text' => ['_' => 'SSL and a firewall included.']],
                ['icon' => 'database', 'colour' => 'purple', 'title' => ['_' => 'Backed up'], 'text' => ['_' => 'A fresh copy every day.']],
                ['icon' => 'globe', 'colour' => 'orange', 'title' => ['_' => 'Your own domain'], 'text' => ['_' => 'Register or transfer a name.']],
                ['icon' => 'mail', 'colour' => 'teal', 'title' => ['_' => 'Email'], 'text' => ['_' => 'Mailboxes on your domain.']],
                ['icon' => 'support', 'colour' => 'red', 'title' => ['_' => 'Real help'], 'text' => ['_' => 'People answer your tickets.']],
            ]],
    ],
];
