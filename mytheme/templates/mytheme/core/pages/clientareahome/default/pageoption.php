<?php
/**
 * Per-variant settings for clientareahome/default.
 *
 * Each setting becomes a checkbox / textbox in the admin UI under
 * Templates → MyTheme → Pages → Dashboard → Default.
 *
 * Read at runtime as $myTheme.pages.clientareahome.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Standard dashboard with alerts, tiles, and panel grid.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showAlerts' => [
            'type'    => 'checkbox',
            'name'    => 'showAlerts',
            'label'   => 'Show overdue/expiry alerts',
            'default' => true,
            'tooltip' => 'When enabled, shows the alert strip at the top of the dashboard for overdue invoices and expiring services.',
        ],
        'tilesEnabled' => [
            'type'    => 'checkbox',
            'name'    => 'tilesEnabled',
            'label'   => 'Show tile counters',
            'default' => true,
            'tooltip' => 'Shows the four counter tiles (services, domains, invoices, tickets) above the panel grid.',
        ],
        'tilesVariant' => [
            'type'    => 'select',
            'name'    => 'tilesVariant',
            'label'   => 'Tile style',
            'default' => 'a',
            'options' => ['a', 'b', 'c', 'd', 'e', 'f'],
            'tooltip' => 'Pick which tile design renders. A=vertical, B=horizontal, C=tinted iOS-widget, D=stacked list, E=progress rings, F=horizontal list.',
        ],
        'subnavMode' => [
            'type'    => 'select',
            'name'    => 'subnavMode',
            'label'   => 'Account sub-nav',
            'default' => 'right',
            'options' => ['right', 'left', 'outside', 'outside-left', 'off'],
            'tooltip' => 'Position of the account sub-nav. "outside" floats it in the page gutter; "off" hides it.',
        ],
        'cardLayout' => [
            'type'    => 'select',
            'name'    => 'cardLayout',
            'label'   => 'Card layout',
            'default' => 'inside',
            'options' => ['inside', 'outside'],
            'tooltip' => 'Inside = card header lives on the same surface as the body. Outside = headers float on the page background above each card.',
        ],
        'showPromo' => [
            'type'    => 'checkbox',
            'name'    => 'showPromo',
            'label'   => 'Show promo slider',
            'default' => true,
            'tooltip' => 'Renders the rotating store carousel above the tile counters.',
        ],
    ],
];
