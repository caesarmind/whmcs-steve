<?php
/**
 * A grid of cards, each an icon, a title and a line or two.
 * Markup and classes: the theme's hp-features-section block.
 */
return [
    'label'  => 'Feature cards',
    'hint'   => 'A grid of icon cards',
    'group'  => 'Features',
    'order'  => 300,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Everything included']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'No add-ons to buy before your site works.']],
        ['key' => 'columns', 'type' => 'select', 'label' => 'Cards per row', 'options' => ['2' => 'Two', '3' => 'Three', '4' => 'Four'], 'default' => '3'],
        ['key' => 'items', 'type' => 'list', 'label' => 'Cards', 'max' => 12, 'itemLabel' => 'title', 'addLabel' => 'Add card',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'colour', 'type' => 'select', 'label' => 'Icon colour', 'default' => 'blue',
                    'options' => ['blue' => 'Blue', 'green' => 'Green', 'purple' => 'Purple', 'orange' => 'Orange', 'teal' => 'Teal', 'red' => 'Red']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Card title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Optional. Shown under the text when it has an address too.'],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => ''],
            ],
            'default' => [
                ['icon' => 'bolt', 'colour' => 'blue', 'title' => ['_' => 'Fast by default'], 'text' => ['_' => 'NVMe storage and caching on every plan.']],
                ['icon' => 'shield', 'colour' => 'green', 'title' => ['_' => 'Free SSL'], 'text' => ['_' => 'A certificate for every site, renewed for you.']],
                ['icon' => 'database', 'colour' => 'purple', 'title' => ['_' => 'Daily backups'], 'text' => ['_' => 'Restore a file or a whole site in a few clicks.']],
                ['icon' => 'support', 'colour' => 'orange', 'title' => ['_' => 'Real support'], 'text' => ['_' => 'Answers from people who run the servers.']],
                ['icon' => 'mail', 'colour' => 'teal', 'title' => ['_' => 'Email included'], 'text' => ['_' => 'Mailboxes on your own domain.']],
                ['icon' => 'activity', 'colour' => 'red', 'title' => ['_' => 'Uptime monitoring'], 'text' => ['_' => 'We watch your site so you do not have to.']],
            ]],
    ],
];
