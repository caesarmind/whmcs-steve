<?php
/**
 * One WHMCS product shown as a large "from" price, with its feature lines
 * and an order button. The price, the features and the order link come from
 * the product, in the visitor's currency.
 * Markup and classes: the theme's hp-pricing-hero block.
 */
return [
    'label'  => 'Starting price',
    'hint'   => 'One product as a large "from" price',
    'group'  => 'Pricing',
    'order'  => 220,
    'fields' => [
        ['key' => 'label', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Hosting from'],
            'help' => 'The short line above the price.'],
        ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
            'help' => 'The price, the feature lines and the order link come from this product.'],
        ['key' => 'show', 'type' => 'select', 'label' => 'Price shown', 'default' => 'first',
            'options' => [
                'first'    => 'The first billing cycle of the product',
                'monthly'  => 'Monthly price',
                'annually' => 'Annual price',
                'permonth' => 'Annual price, shown per month',
            ],
            'help' => 'When the product does not have the cycle you pick, its first billing cycle is shown.'],
        ['key' => 'text', 'type' => 'text', 'label' => 'Line under the price', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Leave empty to show the name of the product.'],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Order now']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
