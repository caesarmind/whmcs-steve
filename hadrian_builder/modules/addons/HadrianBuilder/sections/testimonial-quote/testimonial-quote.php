<?php
/**
 * One large customer quote, centred, with who said it underneath.
 * Markup and classes: the theme's hp-testimonial-hero block.
 */
return [
    'label'  => 'Single quote',
    'hint'   => 'One large customer quote',
    'group'  => 'Testimonials',
    'order'  => 500,
    'fields' => [
        ['key' => 'quote', 'type' => 'textarea', 'label' => 'Quote', 'translatable' => true,
            'default' => ['_' => 'I look after about forty small-business sites. Since moving them here I spend my mornings on client work, not on server problems.'],
            'help' => 'Replace this example with words from one of your own customers.'],
        ['key' => 'name', 'type' => 'text', 'label' => 'Who said it', 'translatable' => true, 'default' => ['_' => 'Agency owner']],
        ['key' => 'role', 'type' => 'text', 'label' => 'Second line', 'translatable' => true, 'default' => ['_' => 'Hosting customer'],
            'help' => 'A job title, a company or what they use. Leave empty to hide it.'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Photo', 'default' => '',
            'help' => 'Shown as a small circle. Without a photo the circle holds the first letter of the name.'],
    ],
];
