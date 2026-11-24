<?php
/**
 * A quiet row of technology names, set as words where the design showed
 * marks.
 * Markup and classes: the theme's hp-logo-bar block.
 */
return [
    'label'  => 'Technology names',
    'hint'   => 'A muted row of technology names',
    'group'  => 'Trust and numbers',
    'order'  => 720,
    'fields' => [
        ['key' => 'names', 'type' => 'lines', 'label' => 'Names', 'translatable' => true,
            'default' => ['_' => "NVMe storage\nHTTP/3\nDaily backups\nIPv6\nDDoS filtering"],
            'help' => 'One name per line. Five or six fit on a row.'],
    ],
];
