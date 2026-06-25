<?php
/**
 * Per-variant settings for viewticket/default.
 *
 * Read at runtime as $hadrian.pages.viewticket.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Conversation thread + reply composer (left) and ticket info sidebar (right).',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSidebar' => [
            'type'    => 'checkbox',
            'name'    => 'showSidebar',
            'label'   => 'Show ticket info sidebar',
            'default' => true,
            'tooltip' => 'Renders the right aside with status / requestor / department / submitted / last-updated / priority rows.',
        ],
        'showCloseButton' => [
            'type'    => 'checkbox',
            'name'    => 'showCloseButton',
            'label'   => 'Show close-ticket button',
            'default' => true,
            'tooltip' => 'Renders the "Close Ticket" pill button in the header when the ticket is not already closed.',
        ],
        'allowAttachments' => [
            'type'    => 'checkbox',
            'name'    => 'allowAttachments',
            'label'   => 'Allow attachment uploads',
            'default' => true,
            'tooltip' => 'Renders the file-drop zone and multipart form encoding on the reply composer.',
        ],
    ],
];
