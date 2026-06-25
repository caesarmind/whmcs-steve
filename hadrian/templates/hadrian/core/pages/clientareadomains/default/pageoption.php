<?php
return [
    'display_name' => 'Default',
    'description'  => 'Domains table with DataTables instant sort, status filter tabs and registrar columns.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type' => 'checkbox', 'name' => 'showSubnav',
            'label' => 'Show domains sub-nav', 'default' => true,
            'tooltip' => 'Renders the right aside with related actions (register, transfer).',
        ],
        'showFilters' => [
            'type' => 'checkbox', 'name' => 'showFilters',
            'label' => 'Show status filter tabs', 'default' => true,
            'tooltip' => 'Renders the All / Active / Pending / Expired filter tabs above the table.',
        ],
    ],
];
