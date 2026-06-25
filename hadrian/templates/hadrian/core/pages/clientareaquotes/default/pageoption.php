<?php
/**
 * Per-variant settings for clientareaquotes/default.
 *
 * Read at runtime as $hadrian.pages.clientareaquotes.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Quotes table with stage filter, DataTables instant sort, and Billing sub-nav.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show billing sub-nav',
            'default' => true,
            'tooltip' => 'Renders the right aside with links to Invoices, Quotes, Mass Payment, Add Funds, Payment Methods.',
        ],
        'showFilters' => [
            'type'    => 'checkbox',
            'name'    => 'showFilters',
            'label'   => 'Show stage filter tabs',
            'default' => true,
            'tooltip' => 'Renders the filter tabs (All / Draft / Delivered / Accepted / Lost) above the quotes table.',
        ],
        'pendingBanner' => [
            'type'    => 'checkbox',
            'name'    => 'pendingBanner',
            'label'   => 'Show pending quotes banner',
            'default' => true,
            'tooltip' => 'Renders a callout banner when one or more delivered quotes are waiting for the client to accept.',
        ],
    ],
];
