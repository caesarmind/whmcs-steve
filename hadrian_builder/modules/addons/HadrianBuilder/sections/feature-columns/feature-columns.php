<?php
/**
 * Three plain columns separated by thin lines. Each has a small numbered
 * label, a title, a paragraph and a link.
 * Markup and classes: the theme's hp-feature-columns block.
 */
return [
    'label'  => 'Columns with dividers',
    'hint'   => 'Three text columns split by thin lines',
    'group'  => 'Features',
    'order'  => 345,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Three things we get right']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'The basics, done properly.']],
        ['key' => 'numbered', 'type' => 'toggle', 'label' => 'Number the columns', 'default' => true],
        ['key' => 'items', 'type' => 'list', 'label' => 'Columns', 'max' => 3, 'itemLabel' => 'title', 'addLabel' => 'Add column',
            'help' => 'The row is three columns wide.',
            'fields' => [
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The small line above the title, shown in capitals.'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Column title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => '',
                    'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
            ],
            'default' => [
                ['label' => ['_' => 'Speed'], 'title' => ['_' => 'Quick on every page'],
                    'text' => ['_' => 'NVMe storage and caching are on from the start, so visitors are not left waiting for a page to appear.'],
                    'linkLabel' => ['_' => 'See hosting plans'], 'link' => 'cart.php'],
                ['label' => ['_' => 'Security'], 'title' => ['_' => 'Safe without the homework'],
                    'text' => ['_' => 'A certificate, a firewall and nightly malware scans come with every plan. You do not have to set any of it up.'],
                    'linkLabel' => ['_' => 'Browse the guides'], 'link' => 'knowledgebase.php'],
                ['label' => ['_' => 'Support'], 'title' => ['_' => 'Someone to ask'],
                    'text' => ['_' => 'Send a ticket at any hour. The reply comes from a person who can look at your account and fix things.'],
                    'linkLabel' => ['_' => 'Contact support'], 'link' => 'contact.php'],
            ]],
    ],
];
