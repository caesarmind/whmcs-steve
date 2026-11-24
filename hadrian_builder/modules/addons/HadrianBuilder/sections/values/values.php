<?php
/**
 * A large left-aligned heading above three value cards: an icon, a title,
 * a short text and an optional link.
 * Markup and classes: the theme's hp-values-section block.
 */
return [
    'label'  => 'Our values',
    'hint'   => 'Cards for what the company stands for',
    'group'  => 'Trust and numbers',
    'order'  => 750,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What we hold ourselves to']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Values', 'max' => 6, 'itemLabel' => 'title', 'addLabel' => 'Add value',
            'help' => 'Cards sit three to a row.',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'New value']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => '',
                    'help' => 'The link is shown only when it has both a text and an address.'],
            ],
            'default' => [
                ['icon' => 'chat', 'title' => ['_' => 'Straight answers'],
                    'text' => ['_' => 'Ask about your service and a person on our team replies in plain language.'],
                    'linkLabel' => ['_' => 'Contact support'], 'link' => 'contact.php'],
                ['icon' => 'lock', 'title' => ['_' => 'Privacy by default'],
                    'text' => ['_' => 'We keep the details billing needs and leave the rest of your data alone.'],
                    'linkLabel' => ['_' => ''], 'link' => ''],
                ['icon' => 'tag', 'title' => ['_' => 'Prices without surprises'],
                    'text' => ['_' => 'The renewal price is on the order form before you pay anything.'],
                    'linkLabel' => ['_' => 'See plans'], 'link' => 'cart.php'],
            ]],
    ],
];
