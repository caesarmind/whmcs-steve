<?php
/**
 * A row of tall coloured cards the visitor scrolls sideways. Each card has a
 * small tag, a title, a line and a large icon at the bottom.
 * Markup and classes: the theme's hp-strip-section block (hp-strip-scroll).
 */
return [
    'label'  => 'Scrolling cards',
    'hint'   => 'Tall coloured cards in a sideways row',
    'group'  => 'Features',
    'order'  => 330,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Small things we take care of']],
        ['key' => 'cards', 'type' => 'list', 'label' => 'Cards', 'max' => 10, 'itemLabel' => 'title', 'addLabel' => 'Add card',
            'fields' => [
                ['key' => 'tag', 'type' => 'text', 'label' => 'Tag', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The short line above the title. It is shown in capitals.'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Card title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Large icon', 'default' => 'star'],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'a',
                    'options' => ['a' => 'Yellow', 'b' => 'Dark', 'c' => 'Green', 'd' => 'Pink', 'e' => 'Purple']],
            ],
            'default' => [
                ['tag' => ['_' => 'One click'], 'title' => ['_' => 'Install an app in a minute'],
                    'text' => ['_' => 'Blogs, shops and forums, ready from your control panel.'], 'icon' => 'bolt', 'tone' => 'a'],
                ['tag' => ['_' => 'Automatic'], 'title' => ['_' => 'Backups you never have to run'],
                    'text' => ['_' => 'A copy of your site is saved every day.'], 'icon' => 'refresh', 'tone' => 'b'],
                ['tag' => ['_' => 'Built in'], 'title' => ['_' => 'Security from day one'],
                    'text' => ['_' => 'SSL, a firewall and malware scans come with the plan.'], 'icon' => 'lock', 'tone' => 'c'],
                ['tag' => ['_' => 'For developers'], 'title' => ['_' => 'SSH and Git access'],
                    'text' => ['_' => 'Deploy from the command line when that suits you better.'], 'icon' => 'terminal', 'tone' => 'd'],
                ['tag' => ['_' => 'Included'], 'title' => ['_' => 'Email on your domain'],
                    'text' => ['_' => 'Create mailboxes that match your site address.'], 'icon' => 'mail', 'tone' => 'e'],
            ]],
    ],
];
