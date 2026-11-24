<?php
/**
 * Price cards with a monthly / annual switch. The name, tagline, features and
 * both prices of each card come from the WHMCS product, in the visitor's
 * currency.
 * Markup and classes: the theme's hp-pricing-toggle-section block, with the
 * hp-billing-toggle switch the theme script drives.
 */
return [
    'label'  => 'Pricing with billing switch',
    'hint'   => 'Price cards with a monthly and annual switch',
    'group'  => 'Pricing',
    'order'  => 210,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Pay monthly or yearly']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Switch between the two to compare prices.']],
        ['key' => 'monthlyLabel', 'type' => 'text', 'label' => 'Switch text, monthly', 'translatable' => true, 'default' => ['_' => 'Monthly']],
        ['key' => 'annualLabel', 'type' => 'text', 'label' => 'Switch text, annual', 'translatable' => true, 'default' => ['_' => 'Annual'],
            'help' => 'The switch shows when at least one product has both a monthly and an annual price.'],
        ['key' => 'startAnnual', 'type' => 'toggle', 'label' => 'Start on the annual price', 'default' => false],
        ['key' => 'annualPerMonth', 'type' => 'toggle', 'label' => 'Show the annual price per month', 'default' => false,
            'help' => 'On: the annual side shows what a year costs per month. Off: it shows the price of the whole year.'],
        ['key' => 'plans', 'type' => 'list', 'label' => 'Plans', 'max' => 6, 'itemLabel' => 'product', 'addLabel' => 'Add plan',
            'fields' => [
                ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
                    'help' => 'The card takes its name, features and prices from this product. A product with only one of the two cycles shows that price on both sides of the switch.'],
                ['key' => 'highlight', 'type' => 'toggle', 'label' => 'Highlight this plan', 'default' => false],
                ['key' => 'badge', 'type' => 'text', 'label' => 'Badge', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Shown after the plan name, for example "Most popular".'],
            ],
            'default' => []],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Order now']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
