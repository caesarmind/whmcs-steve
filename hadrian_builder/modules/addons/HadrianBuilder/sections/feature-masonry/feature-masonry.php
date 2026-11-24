<?php
/**
 * Feature cards of two heights packed into a three-column grid. A tall card
 * has room for a longer text and a large icon at the bottom.
 * Markup and classes: the theme's hp-feature-masonry block.
 */
return [
    'label'  => 'Masonry grid',
    'hint'   => 'Feature cards of two heights',
    'group'  => 'Features',
    'order'  => 350,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'A lot in one plan']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'The parts you would otherwise buy one by one.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Cards', 'max' => 12, 'itemLabel' => 'title', 'addLabel' => 'Add card',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Card title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A standard card has room for about one line. Make the card tall for more.'],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'plain',
                    'options' => ['plain' => 'Light', 'accent' => 'Blue', 'dark' => 'Dark', 'cream' => 'Cream']],
                ['key' => 'tall', 'type' => 'toggle', 'label' => 'Tall card', 'default' => false],
                ['key' => 'visual', 'type' => 'icon', 'label' => 'Large icon at the bottom', 'default' => '',
                    'help' => 'Shown on a tall card only.'],
            ],
            'default' => [
                ['icon' => 'bolt', 'title' => ['_' => 'Fast disks'],
                    'text' => ['_' => 'Your files and databases sit on NVMe drives. You notice it most on busy pages.'],
                    'tone' => 'accent', 'tall' => true, 'visual' => 'server'],
                ['icon' => 'globe', 'title' => ['_' => 'Domains'], 'text' => ['_' => 'Register or transfer a name.'],
                    'tone' => 'plain', 'tall' => false, 'visual' => ''],
                ['icon' => 'lock', 'title' => ['_' => 'Free SSL'], 'text' => ['_' => 'A certificate for every site.'],
                    'tone' => 'dark', 'tall' => false, 'visual' => ''],
                ['icon' => 'chart', 'title' => ['_' => 'Usage stats'], 'text' => ['_' => 'See traffic, disk and email use.'],
                    'tone' => 'cream', 'tall' => false, 'visual' => ''],
                ['icon' => 'shield', 'title' => ['_' => 'Malware scans'],
                    'text' => ['_' => 'Every night we check your files for anything that should not be there.'],
                    'tone' => 'dark', 'tall' => true, 'visual' => 'shield'],
                ['icon' => 'mail', 'title' => ['_' => 'Email'], 'text' => ['_' => 'Mailboxes on your own domain.'],
                    'tone' => 'plain', 'tall' => false, 'visual' => ''],
            ]],
    ],
];
