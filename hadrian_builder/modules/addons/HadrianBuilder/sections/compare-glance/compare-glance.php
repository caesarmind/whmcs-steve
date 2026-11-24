<?php
/**
 * Up to three WHMCS products side by side with a few spec rows. The name,
 * price and order link of each card come from the product; the spec rows are
 * written here, one value per card.
 * Markup and classes: the theme's hp-compare-glance block.
 */
return [
    'label'  => 'Comparison at a glance',
    'hint'   => 'Three products with a few spec rows',
    'group'  => 'Pricing',
    'order'  => 260,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'The plans at a glance']],
        ['key' => 'plans', 'type' => 'list', 'label' => 'Products', 'max' => 3, 'itemLabel' => 'product', 'addLabel' => 'Add product',
            'fields' => [
                ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
                    'help' => 'The card takes its name, price and order link from this product.'],
                ['key' => 'highlight', 'type' => 'toggle', 'label' => 'Highlight this card', 'default' => false],
                ['key' => 'badge', 'type' => 'text', 'label' => 'Label above the name', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A few words, for example "Most popular" or "For agencies".'],
            ],
            'default' => []],
        ['key' => 'specs', 'type' => 'list', 'label' => 'Spec rows', 'max' => 10, 'itemLabel' => 'label', 'addLabel' => 'Add row',
            'fields' => [
                ['key' => 'label', 'type' => 'text', 'label' => 'Spec', 'translatable' => true, 'default' => ['_' => 'New spec']],
                ['key' => 'values', 'type' => 'lines', 'label' => 'Values', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'One line per product, in the order of the products above.'],
            ],
            'default' => [
                ['label' => ['_' => 'Storage'], 'values' => ['_' => "10 GB\n50 GB\n100 GB"]],
                ['label' => ['_' => 'Websites'], 'values' => ['_' => "1\n10\nUnlimited"]],
                ['label' => ['_' => 'Email accounts'], 'values' => ['_' => "5\n50\nUnlimited"]],
                ['label' => ['_' => 'Backups'], 'values' => ['_' => "Weekly\nDaily\nDaily"]],
            ]],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Order link text', 'translatable' => true, 'default' => ['_' => 'Order now'],
            'help' => 'Leave empty to show the cards without an order link.'],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
    ],
];
