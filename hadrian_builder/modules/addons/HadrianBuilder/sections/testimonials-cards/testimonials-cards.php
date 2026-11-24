<?php
/**
 * Customer quotes on cards in a row that slides. The dots and arrows under
 * the row are printed here; the theme's own script makes them work and moves
 * the row on by itself every few seconds.
 * Markup and classes: the theme's hp-testimonials-grid block.
 */
return [
    'label'  => 'Quote cards',
    'hint'   => 'Customer quotes on sliding cards',
    'group'  => 'Testimonials',
    'order'  => 510,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What customers say']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Quotes', 'max' => 12, 'itemLabel' => 'name', 'addLabel' => 'Add quote',
            'help' => 'Replace these examples with words from your own customers.',
            'fields' => [
                ['key' => 'quote', 'type' => 'textarea', 'label' => 'Quote', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'name', 'type' => 'text', 'label' => 'Who said it', 'translatable' => true, 'default' => ['_' => 'Customer']],
                ['key' => 'role', 'type' => 'text', 'label' => 'Second line', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A job title, a company or what they use.'],
                ['key' => 'image', 'type' => 'image', 'label' => 'Photo', 'default' => '',
                    'help' => 'Without a photo the circle holds the first letter of the name.'],
                ['key' => 'rating', 'type' => 'number', 'label' => 'Stars', 'min' => 0, 'max' => 5, 'default' => 5,
                    'help' => '0 hides the stars.'],
            ],
            'default' => [
                ['quote' => ['_' => 'All my client domains are in one account now. Renewals happen on their own and I stopped keeping a spreadsheet.'],
                    'name' => ['_' => 'Agency owner'], 'role' => ['_' => 'Domain customer'], 'image' => '', 'rating' => 5],
                ['quote' => ['_' => 'I pointed a new domain at my site without reading a guide. Everything was where I expected it.'],
                    'name' => ['_' => 'Web designer'], 'role' => ['_' => 'Hosting customer'], 'image' => '', 'rating' => 5],
                ['quote' => ['_' => 'I opened my shop on a Sunday night. The domain, the hosting and the certificate were all sorted in one order.'],
                    'name' => ['_' => 'Store owner'], 'role' => ['_' => 'Hosting customer'], 'image' => '', 'rating' => 5],
            ]],
        ['key' => 'prevLabel', 'type' => 'text', 'label' => 'Name of the back arrow', 'translatable' => true, 'default' => ['_' => 'Previous'],
            'help' => 'Read aloud by screen readers.'],
        ['key' => 'nextLabel', 'type' => 'text', 'label' => 'Name of the forward arrow', 'translatable' => true, 'default' => ['_' => 'Next'],
            'help' => 'Read aloud by screen readers.'],
    ],
];
