<?php
/**
 * Price cards for WHMCS products. The name, tagline, features and price of
 * each card come from the product itself, in the visitor's currency.
 * Markup and classes: the theme's hp-pricing-section block.
 */
return [
    'label'  => 'Pricing cards',
    'hint'   => 'WHMCS products with live prices',
    'group'  => 'Pricing',
    'order'  => 40,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Pick a plan']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Change or cancel whenever you like.']],
        ['key' => 'plans', 'type' => 'list', 'label' => 'Plans', 'max' => 6, 'itemLabel' => 'product', 'addLabel' => 'Add plan',
            'fields' => [
                ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
                    'help' => 'The card takes its name, features and price from this product.'],
                ['key' => 'highlight', 'type' => 'toggle', 'label' => 'Highlight this plan', 'default' => false],
                ['key' => 'badge', 'type' => 'text', 'label' => 'Badge', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Shown after the plan name, for example "Most popular".'],
            ],
            'default' => []],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Order now']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
