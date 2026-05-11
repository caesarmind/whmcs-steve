<?php
/**
 * Per-variant settings for viewannouncement/default.
 *
 * Read at runtime as $myTheme.pages.viewannouncement.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Article view: category chip + title + meta header, body, back / share footer.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show support sub-nav',
            'default' => true,
            'tooltip' => 'Renders the left aside with My Tickets, Announcements, Knowledgebase, Downloads, Network Status, Open Ticket, RSS Feed.',
        ],
        'showShareButtons' => [
            'type'    => 'checkbox',
            'name'    => 'showShareButtons',
            'label'   => 'Show share buttons',
            'default' => true,
            'tooltip' => 'Renders the share buttons (copy link) in the footer alongside the back-to-list action.',
        ],
    ],
];
