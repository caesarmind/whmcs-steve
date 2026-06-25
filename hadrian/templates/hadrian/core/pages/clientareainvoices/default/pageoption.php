<?php
return [
    'display_name' => 'Default',
    'description'  => 'Invoice table with DataTables instant sort, status filter tabs and unpaid banner.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type' => 'checkbox', 'name' => 'showSubnav',
            'label' => 'Show billing sub-nav', 'default' => true,
            'tooltip' => 'Renders the right aside with Invoices / Quotes / Mass Payment / Add Funds / Payment Methods links.',
        ],
        'showFilters' => [
            'type' => 'checkbox', 'name' => 'showFilters',
            'label' => 'Show status filter tabs', 'default' => true,
            'tooltip' => 'Renders the All / Unpaid / Paid / Cancelled filter tabs above the table.',
        ],
        'unpaidBanner' => [
            'type' => 'checkbox', 'name' => 'unpaidBanner',
            'label' => 'Show unpaid banner', 'default' => true,
            'tooltip' => 'Renders the callout banner with count of unpaid invoices and a "Pay all" CTA.',
        ],
    ],
];
