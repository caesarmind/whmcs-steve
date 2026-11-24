<?php
/**
 * The closing call to action: a dark band with a headline and a button.
 * Markup and classes: the theme's hp-final-cta block.
 */
return [
    'label'  => 'Closing call to action',
    'hint'   => 'A dark band with a headline and a button',
    'group'  => 'Call to action',
    'order'  => 60,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Ready when you are']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => 'Order in a few minutes. Move in whenever it suits you.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Get started']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Ask a question']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => 'contact.php'],
    ],
];
