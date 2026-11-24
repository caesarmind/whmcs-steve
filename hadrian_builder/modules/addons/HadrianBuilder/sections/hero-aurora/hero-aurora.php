<?php
/**
 * Hero over slowly drifting patches of soft colour, with a centered
 * headline, text and buttons.
 * Markup and classes: the theme's hp-hero-aurora block.
 */
return [
    'label'  => 'Hero, aurora',
    'hint'   => 'Soft colours drifting behind the headline',
    'group'  => 'Hero',
    'order'  => 145,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'New: cloud servers'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Hosting that keeps up with you']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Start small, add resources when traffic grows, and pay only for what you run.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => '#pricing',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Talk to us']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => 'contact.php'],
    ],
];
