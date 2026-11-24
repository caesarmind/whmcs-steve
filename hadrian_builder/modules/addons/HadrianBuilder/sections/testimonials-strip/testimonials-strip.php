<?php
/**
 * A dark band with customer quotes in a row the visitor drags or moves with
 * two arrows. The theme's own script handles the arrows and the dragging.
 * Markup and classes: the theme's hp-testimonials-scroll block.
 */
return [
    'label'  => 'Quote strip, dark',
    'hint'   => 'Quotes in a dark band you can drag',
    'group'  => 'Testimonials',
    'order'  => 520,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'From people who run servers here']],
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
                ['quote' => ['_' => 'I ordered a server on my lunch break and was logged in before I had finished eating.'],
                    'name' => ['_' => 'Developer'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5],
                ['quote' => ['_' => 'Our test servers live here now. The bill is smaller and questions get answered the same day.'],
                    'name' => ['_' => 'Technical lead'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5],
                ['quote' => ['_' => 'I broke a server with a bad update on a Friday. Rolling back to the morning snapshot took two minutes.'],
                    'name' => ['_' => 'Freelance developer'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5],
                ['quote' => ['_' => 'We run nine servers here. Adding a tenth takes less time than writing the purchase request.'],
                    'name' => ['_' => 'Operations manager'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5],
            ]],
        ['key' => 'prevLabel', 'type' => 'text', 'label' => 'Name of the back arrow', 'translatable' => true, 'default' => ['_' => 'Previous'],
            'help' => 'Read aloud by screen readers.'],
        ['key' => 'nextLabel', 'type' => 'text', 'label' => 'Name of the forward arrow', 'translatable' => true, 'default' => ['_' => 'Next'],
            'help' => 'Read aloud by screen readers.'],
    ],
];
