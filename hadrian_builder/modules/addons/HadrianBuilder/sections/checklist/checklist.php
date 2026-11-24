<?php
/**
 * A two-column list of ticked items, each a short title and a line.
 * Markup and classes: the theme's hp-features-checklist block.
 */
return [
    'label'  => 'Checklist',
    'hint'   => 'Ticked items in two columns',
    'group'  => 'Features',
    'order'  => 320,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Included with every plan']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'None of this costs extra.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Items', 'max' => 20, 'itemLabel' => 'title', 'addLabel' => 'Add item',
            'fields' => [
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Item title']],
                ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['title' => ['_' => 'Free SSL certificate'], 'text' => ['_' => 'Issued and renewed for you.']],
                ['title' => ['_' => 'Daily backups'], 'text' => ['_' => 'Restore from your control panel.']],
                ['title' => ['_' => 'Email accounts'], 'text' => ['_' => 'Mailboxes on your own domain.']],
                ['title' => ['_' => 'One-click installs'], 'text' => ['_' => 'Popular apps, ready in a minute.']],
                ['title' => ['_' => 'Malware scanning'], 'text' => ['_' => 'Your files are checked every night.']],
                ['title' => ['_' => 'Help from our team'], 'text' => ['_' => 'Ask by ticket or live chat.']],
            ]],
    ],
];
