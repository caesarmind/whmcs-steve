<?php
/**
 * Hero with everything in the middle: eyebrow, headline, a line of text and
 * buttons. Choosing a product prints its live price beside the button.
 * Markup and classes: the theme's hp-hero block.
 */
return [
    'label'  => 'Hero, centered',
    'hint'   => 'Headline, text and buttons in the middle',
    'group'  => 'Hero',
    'order'  => 100,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Web hosting'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'A good home for your website']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Fast servers, free SSL and a backup every night, run by people you can reach.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'See plans']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => '#pricing',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Second link text', 'translatable' => true, 'default' => ['_' => 'Talk to us']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Second link', 'default' => 'contact.php'],
        ['key' => 'product', 'type' => 'product', 'label' => 'Price of a product', 'default' => 0,
            'help' => 'Optional. Prints the price of this product beside the button, read from WHMCS on every visit.'],
        ['key' => 'pricePrefix', 'type' => 'text', 'label' => 'Word before the price', 'translatable' => true, 'default' => ['_' => 'from'],
            'help' => 'Only shown when a product with a price is chosen.'],
    ],
];
