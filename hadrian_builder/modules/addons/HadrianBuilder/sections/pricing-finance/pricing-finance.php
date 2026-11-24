<?php
/**
 * One WHMCS product with a choice between paying monthly and paying yearly.
 * Both prices and the order link come from the product, in the visitor's
 * currency.
 * Markup and classes: the theme's hp-pricing-finance block, with the
 * hp-finance-opt choices the theme script drives.
 */
return [
    'label'  => 'Pricing, two ways to pay',
    'hint'   => 'One product, monthly or yearly',
    'group'  => 'Pricing',
    'order'  => 230,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Two ways to pay']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'Pay month by month, or pay for the year up front.']],
        ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
            'help' => 'Uses the monthly and annual prices of this product. A product with only one of the two shows a single choice.'],
        ['key' => 'monthlyLabel', 'type' => 'text', 'label' => 'Monthly choice, title', 'translatable' => true, 'default' => ['_' => 'Monthly']],
        ['key' => 'monthlyNote', 'type' => 'text', 'label' => 'Monthly choice, note', 'translatable' => true, 'default' => ['_' => 'Billed every month']],
        ['key' => 'annualLabel', 'type' => 'text', 'label' => 'Yearly choice, title', 'translatable' => true, 'default' => ['_' => 'Yearly']],
        ['key' => 'annualNote', 'type' => 'text', 'label' => 'Yearly choice, note', 'translatable' => true, 'default' => ['_' => 'Works out at [price] a month'],
            'help' => 'Write [price] where the yearly price per month should appear.'],
        ['key' => 'startAnnual', 'type' => 'toggle', 'label' => 'Start on the yearly choice', 'default' => false],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Get started']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
