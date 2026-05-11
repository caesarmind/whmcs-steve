<?php
/**
 * Per-variant settings for supportticketsubmit/default.
 *
 * Read at runtime as $myTheme.pages.supportticketsubmit.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Two-step submit form: department radio cards on step 1, subject/message/attachments on step 2.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show support sub-nav',
            'default' => true,
            'tooltip' => 'Renders the left aside with My Tickets, Announcements, Knowledgebase, Network Status links.',
        ],
        'allowAttachments' => [
            'type'    => 'checkbox',
            'name'    => 'allowAttachments',
            'label'   => 'Allow file attachments',
            'default' => true,
            'tooltip' => 'Renders the attachment drop zone on step 2 and switches the form encoding to multipart/form-data.',
        ],
    ],
];
