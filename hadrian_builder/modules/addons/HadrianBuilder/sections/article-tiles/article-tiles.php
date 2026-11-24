<?php
/**
 * A hand-edited list of articles as coloured tiles: one or two large ones
 * first, the rest three to a row. WHMCS has no articles of its own, so each
 * tile is typed here and links wherever the admin points it.
 * Markup and classes: the theme's hp-blog-tiles block.
 */
return [
    'label'  => 'Article tiles',
    'hint'   => 'Linked article tiles, large ones first',
    'group'  => 'Articles',
    'order'  => 950,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Guides and notes']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Short reads on running a site, from the people who host it.']],
        ['key' => 'allLabel', 'type' => 'text', 'label' => 'Link beside the heading', 'translatable' => true, 'default' => ['_' => 'All guides']],
        ['key' => 'allLink', 'type' => 'link', 'label' => 'Where that link goes', 'default' => 'knowledgebase.php'],
        ['key' => 'lead', 'type' => 'select', 'label' => 'Large tiles at the top', 'default' => '2',
            'options' => ['2' => 'The first two', '1' => 'The first one', '0' => 'None, all the same size']],
        ['key' => 'readLabel', 'type' => 'text', 'label' => 'Link text on each tile', 'translatable' => true, 'default' => ['_' => 'Read more'],
            'help' => 'Shown on every tile that has a link.'],
        ['key' => 'items', 'type' => 'list', 'label' => 'Articles', 'max' => 14, 'itemLabel' => 'title', 'addLabel' => 'Add article',
            'fields' => [
                ['key' => 'tag', 'type' => 'text', 'label' => 'Tag', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'An optional word above the heading, such as "Guide".'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Article heading']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'date', 'type' => 'text', 'label' => 'Date', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Printed as typed, for example "3 November 2026". Leave empty to hide it.'],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => ''],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'light',
                    'options' => ['light' => 'Light', 'dark' => 'Dark', 'sky' => 'Sky blue', 'cream' => 'Cream', 'plum' => 'Plum']],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['tag' => ['_' => 'Guide'], 'title' => ['_' => 'Moving a site without downtime'],
                    'text' => ['_' => 'The order we follow when we move a site: files, database, mail, and the DNS change last.'],
                    'date' => ['_' => '17 November 2026'], 'link' => 'knowledgebase.php', 'tone' => 'light', 'image' => '', 'imageAlt' => ['_' => '']],
                ['tag' => ['_' => 'Servers'], 'title' => ['_' => 'How much server do you need?'],
                    'text' => ['_' => 'A short way to size memory and cores from the traffic you already have.'],
                    'date' => ['_' => '10 November 2026'], 'link' => 'knowledgebase.php', 'tone' => 'dark', 'image' => '', 'imageAlt' => ['_' => '']],
                ['tag' => ['_' => 'Domains'], 'title' => ['_' => 'What to check before a transfer'],
                    'text' => ['_' => 'Unlock the name, get the code and look at the expiry date first.'],
                    'date' => ['_' => '3 November 2026'], 'link' => 'knowledgebase.php', 'tone' => 'sky', 'image' => '', 'imageAlt' => ['_' => '']],
                ['tag' => ['_' => 'Security'], 'title' => ['_' => 'Turn on two-step sign-in'],
                    'text' => ['_' => 'Five minutes that stop a stolen password from being enough.'],
                    'date' => ['_' => '27 October 2026'], 'link' => 'knowledgebase.php', 'tone' => 'cream', 'image' => '', 'imageAlt' => ['_' => '']],
                ['tag' => ['_' => 'Email'], 'title' => ['_' => 'Why your mail lands in spam'],
                    'text' => ['_' => 'Three DNS records fix most delivery problems. Here is how to set them.'],
                    'date' => ['_' => '20 October 2026'], 'link' => 'knowledgebase.php', 'tone' => 'plum', 'image' => '', 'imageAlt' => ['_' => '']],
            ]],
    ],
];
