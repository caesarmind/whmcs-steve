<?php
/**
 * A slim bordered bar of short facts: a word or figure above a small label.
 * Markup and classes: the theme's hp-trust-bar block.
 */
return [
    'label'  => 'Trust bar',
    'hint'   => 'A slim bar of short facts',
    'group'  => 'Trust and numbers',
    'order'  => 710,
    'fields' => [
        ['key' => 'items', 'type' => 'list', 'label' => 'Facts', 'max' => 8, 'itemLabel' => 'label', 'addLabel' => 'Add fact',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Word or figure', 'translatable' => true, 'default' => ['_' => '0'],
                    'help' => 'Keep it short: a number or one word.'],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New fact']],
            ],
            'default' => [
                ['value' => ['_' => 'Free'], 'label' => ['_' => 'SSL on every plan']],
                ['value' => ['_' => 'Daily'], 'label' => ['_' => 'Backups included']],
                ['value' => ['_' => '1 click'], 'label' => ['_' => 'App installer']],
                ['value' => ['_' => 'None'], 'label' => ['_' => 'Setup fees']],
            ]],
    ],
];
