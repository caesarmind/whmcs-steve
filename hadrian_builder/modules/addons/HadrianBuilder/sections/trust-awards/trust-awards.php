<?php
/**
 * A strip of short recognitions under a small label: each a line of text,
 * who or what it comes from, and optional stars.
 * Markup and classes: the theme's hp-trust-awards block.
 */
return [
    'label'  => 'Awards strip',
    'hint'   => 'A row of ratings or recognitions',
    'group'  => 'Trust and numbers',
    'order'  => 740,
    'fields' => [
        ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'What customers tell us'],
            'help' => 'The small line above the row. Leave empty to hide it.'],
        ['key' => 'items', 'type' => 'list', 'label' => 'Entries', 'max' => 8, 'itemLabel' => 'source', 'addLabel' => 'Add entry',
            'help' => 'Use figures and sources you can show on request.',
            'fields' => [
                ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The rating, result or award, in a few words.'],
                ['key' => 'source', 'type' => 'text', 'label' => 'Attribution', 'translatable' => true, 'default' => ['_' => 'New entry'],
                    'help' => 'Where it comes from, such as a survey or a review site.'],
                ['key' => 'stars', 'type' => 'number', 'label' => 'Stars', 'min' => 0, 'max' => 5, 'default' => 0,
                    'help' => '0 shows no stars.'],
            ],
            'default' => [
                ['text' => ['_' => '4.8 out of 5'], 'source' => ['_' => 'Customer rating'], 'stars' => 5],
                ['text' => ['_' => 'Under 15 minutes'], 'source' => ['_' => 'Support response'], 'stars' => 0],
                ['text' => ['_' => '9 in 10'], 'source' => ['_' => 'Would recommend us'], 'stars' => 0],
            ]],
    ],
];
