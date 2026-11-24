<?php
/**
 * Hero on a black band with a very large headline set to the left and a
 * paragraph under it. Bold words in the paragraph stand out in white.
 * Markup and classes: the theme's hp-silicon-hero block.
 */
return [
    'label'  => 'Hero, large headline',
    'hint'   => 'Black band with a very large headline',
    'group'  => 'Hero',
    'order'  => 140,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Managed hosting'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Your site, looked after.'],
            'help' => 'A few words. The headline is very large.'],
        ['key' => 'text', 'type' => 'rich', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => '<p>We patch the servers, watch the uptime and keep the backups. <strong>You get on with running your business.</strong> When something needs a person, one of ours picks it up.</p>'],
            'help' => 'Make a phrase bold to pick it out in white.'],
    ],
];
