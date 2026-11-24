<?php
/**
 * A small pill a visitor can close: a tag, a line of text and a button.
 * Written here, not taken from WHMCS announcements.
 * Markup and classes: the theme's hp-announce-notice block. The theme script
 * handles the close button.
 */
return [
    'label'  => 'Inline notice',
    'hint'   => 'A small pill a visitor can close',
    'group'  => 'Announcements',
    'order'  => 920,
    'fields' => [
        ['key' => 'tag', 'type' => 'text', 'label' => 'Tag', 'translatable' => true, 'default' => ['_' => 'Notice'],
            'help' => 'The small pill before the text. Leave empty to hide it.'],
        ['key' => 'lead', 'type' => 'text', 'label' => 'Opening words, in bold', 'translatable' => true, 'default' => ['_' => 'Planned maintenance:'],
            'help' => 'Optional. Printed in bold before the text.'],
        ['key' => 'text', 'type' => 'text', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Sunday, 02:00 to 04:00 UTC. Your sites stay online.']],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Details']],
        ['key' => 'buttonLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'announcements.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as announcements.php.'],
        ['key' => 'dismissible', 'type' => 'toggle', 'label' => 'Let visitors close it', 'default' => true,
            'help' => 'The notice comes back the next time the page loads.'],
        ['key' => 'closeLabel', 'type' => 'text', 'label' => 'Name of the close button', 'translatable' => true, 'default' => ['_' => 'Dismiss'],
            'help' => 'Not shown on the page. Read aloud by screen readers.'],
    ],
];
