<?php
/**
 * Up to four WHMCS products as joined columns in one bar. The name, tagline,
 * features, price and order link of each column come from the product.
 * Markup and classes: the theme's hp-pricing-segmented block.
 */
return [
    'label'  => 'Pricing, tiers in a row',
    'hint'   => 'Up to four products in one joined bar',
    'group'  => 'Pricing',
    'order'  => 240,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Plans side by side']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Start small and move up when your site needs more.']],
        ['key' => 'plans', 'type' => 'list', 'label' => 'Plans', 'max' => 4, 'itemLabel' => 'product', 'addLabel' => 'Add plan',
            'fields' => [
                ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
                    'help' => 'The column takes its name, tagline, features and price from this product.'],
                ['key' => 'highlight', 'type' => 'toggle', 'label' => 'Highlight this plan', 'default' => false,
                    'help' => 'The theme tints the column and marks it as the popular one.'],
            ],
            'default' => []],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Choose']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
