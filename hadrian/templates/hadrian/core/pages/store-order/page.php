<?php
return [
    'display_name'   => 'Shop — Order summary',
    'group'          => 'Shop',
    // The other Shop pages are landing pages and belong to the website. This
    // one is a step of placing an order.
    'area'           => 'order',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'Default landing for /store/order — order completion / cart summary view.',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing'    => 'disallow',
        'title'       => 'Order summary',
    ],
];
