<?php
/**
 * Hero with a headline over a line of short phrases that scrolls sideways
 * without stopping.
 * Markup and classes: the theme's hp-hero-ticker block.
 */
return [
    'label'  => 'Hero with ticker',
    'hint'   => 'Headline over a scrolling line of phrases',
    'group'  => 'Hero',
    'order'  => 130,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Everything a site needs']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Part of every plan, with nothing extra to buy.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Phrases', 'max' => 16, 'itemLabel' => 'text', 'addLabel' => 'Add phrase',
            'fields' => [
                ['key' => 'text', 'type' => 'text', 'label' => 'Phrase', 'translatable' => true, 'default' => ['_' => 'New phrase'],
                    'help' => 'Two or three words read best.'],
                ['key' => 'accent', 'type' => 'toggle', 'label' => 'Highlight', 'default' => false,
                    'help' => 'Highlighted phrases take the accent colour. The others are faded.'],
            ],
            'default' => [
                ['text' => ['_' => 'NVMe storage'], 'accent' => false],
                ['text' => ['_' => 'Free SSL'], 'accent' => true],
                ['text' => ['_' => 'Daily backups'], 'accent' => false],
                ['text' => ['_' => 'Email on your domain'], 'accent' => true],
                ['text' => ['_' => 'One-click installs'], 'accent' => false],
                ['text' => ['_' => 'Help from real people'], 'accent' => true],
            ]],
    ],
];
