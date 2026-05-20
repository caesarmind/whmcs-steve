<?php
return [
    'displayName'    => 'Icon Rail',
    'description'    => 'Compact 80px icon rail with flyout panels on hover.',
    'preview'        => 'thumb.png',
    'order'          => 3,
    'variables'      => [
        'dataLayout'     => 'rail',
        'bodyClass'      => 'layout-rail',
        'sidebarPresent' => true,
    ],
    'supportedOptions' => [
        'align' => [
            'label'   => 'Content alignment',
            'default' => 'center',
            'choices' => ['center' => 'Center', 'left' => 'Left'],
        ],
    ],
];
