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
        'panelLayout' => [
            'type'    => 'select',
            'name'    => 'panelLayout',
            'label'   => 'Panel layout',
            'default' => 'grid',
            'options' => ['grid', 'list', 'compact'],
            'tooltip' => 'Choose how dashboard panels are arranged.',
        ],
    ],
];
