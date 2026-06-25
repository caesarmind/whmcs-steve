<?php
return [
    'display_name' => 'Default',
    'description'  => 'Two-column invoice view: line items + totals (left) and actions/payment methods sidebar (right).',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showActionsSidebar' => [
            'type' => 'checkbox', 'name' => 'showActionsSidebar',
            'label' => 'Show actions sidebar', 'default' => true,
            'tooltip' => 'Renders the right aside with Download PDF / Print / Pay actions and payment-methods card.',
        ],
        'showAddresses' => [
            'type' => 'checkbox', 'name' => 'showAddresses',
            'label' => 'Show billing addresses', 'default' => true,
            'tooltip' => 'Renders the "Bill to" / "Pay to" address blocks above the line items.',
        ],
        'showTransactionHistory' => [
            'type' => 'checkbox', 'name' => 'showTransactionHistory',
            'label' => 'Show transaction history', 'default' => true,
            'tooltip' => 'Renders the past-payments / refunds history at the bottom of the invoice.',
        ],
    ],
];
