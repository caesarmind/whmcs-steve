<?php
return [
    'display_name' => 'Default',
    'description'  => 'Ticket table with status filter, DataTables instant sort and unread-reply banner.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type' => 'checkbox', 'name' => 'showSubnav',
            'label' => 'Show support sub-nav', 'default' => true,
            'tooltip' => 'Renders the right aside with Tickets / Open Ticket / Announcements / Knowledgebase links.',
        ],
        'showFilters' => [
            'type' => 'checkbox', 'name' => 'showFilters',
            'label' => 'Show status filter tabs', 'default' => true,
            'tooltip' => 'Renders the All / Open / Answered / Customer-reply / Closed filter tabs above the table.',
        ],
        'unreadBanner' => [
            'type' => 'checkbox', 'name' => 'unreadBanner',
            'label' => 'Show unread-reply banner', 'default' => true,
            'tooltip' => 'Renders the callout banner when one or more tickets have a new staff reply.',
        ],
    ],
];
