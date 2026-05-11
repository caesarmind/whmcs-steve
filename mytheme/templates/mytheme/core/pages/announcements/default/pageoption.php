<?php
/**
 * Per-variant settings for announcements/default.
 *
 * Read at runtime as $myTheme.pages.announcements.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Two-column layout: Support sub-nav (left) + announcement cards stacked (right).',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show support sub-nav',
            'default' => true,
            'tooltip' => 'Renders the left aside with My Tickets, Announcements, Knowledgebase, Downloads, Network Status, Open Ticket, RSS Feed.',
        ],
        'excerptLength' => [
            'type'    => 'select',
            'name'    => 'excerptLength',
            'label'   => 'Excerpt length',
            'default' => '240',
            'options' => ['160', '240', '320'],
            'tooltip' => 'How many characters of the announcement body to show in the list card (before truncating to …).',
        ],
    ],
];
