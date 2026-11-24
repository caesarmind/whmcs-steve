<?php
/**
 * A review score in large type under a row of stars, with a smaller score
 * for each place the reviews come from.
 * Markup and classes: the theme's hp-testi-reviews block.
 */
return [
    'label'  => 'Star ratings',
    'hint'   => 'A review score with a breakdown',
    'group'  => 'Testimonials',
    'order'  => 540,
    'fields' => [
        ['key' => 'rating', 'type' => 'number', 'label' => 'Stars', 'min' => 1, 'max' => 5, 'default' => 5],
        ['key' => 'score', 'type' => 'text', 'label' => 'Score', 'translatable' => true, 'default' => ['_' => '4.8'],
            'help' => 'The figures here are examples. Put in your own.'],
        ['key' => 'caption', 'type' => 'text', 'label' => 'Line under the score', 'translatable' => true,
            'default' => ['_' => 'out of 5, from customer reviews']],
        ['key' => 'sources', 'type' => 'list', 'label' => 'Breakdown', 'max' => 6, 'itemLabel' => 'name', 'addLabel' => 'Add row',
            'help' => 'One entry for each place or product the reviews are about.',
            'fields' => [
                ['key' => 'name', 'type' => 'text', 'label' => 'Name', 'translatable' => true, 'default' => ['_' => 'Name']],
                ['key' => 'rating', 'type' => 'number', 'label' => 'Stars', 'min' => 1, 'max' => 5, 'default' => 5],
                ['key' => 'count', 'type' => 'text', 'label' => 'Line under the name', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'For example the number of reviews.'],
            ],
            'default' => [
                ['name' => ['_' => 'Web hosting'], 'rating' => 5, 'count' => ['_' => '320 reviews']],
                ['name' => ['_' => 'Domains'], 'rating' => 5, 'count' => ['_' => '210 reviews']],
                ['name' => ['_' => 'Servers'], 'rating' => 4, 'count' => ['_' => '95 reviews']],
                ['name' => ['_' => 'Support'], 'rating' => 5, 'count' => ['_' => '480 reviews']],
            ]],
    ],
];
