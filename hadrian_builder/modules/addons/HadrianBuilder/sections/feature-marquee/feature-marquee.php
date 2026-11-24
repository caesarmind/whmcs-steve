<?php
/**
 * A heading over a row of short tags that scrolls sideways without stopping.
 * Markup and classes: the theme's hp-feature-marquee block.
 */
return [
    'label'  => 'Scrolling tags',
    'hint'   => 'A moving row of short feature tags',
    'group'  => 'Features',
    'order'  => 355,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Part of every plan']],
        ['key' => 'tags', 'type' => 'lines', 'label' => 'Tags', 'translatable' => true,
            'default' => ['_' => "SSL certificates\nNightly backups\nNVMe storage\nOne-click installs\nEmail on your domain\nSite migration\nMalware scanning\nDNS management\nStaging sites\nSupport by ticket and chat"],
            'help' => 'One tag per line. Keep each to a few words. Eight or more fill the row best.'],
    ],
];
