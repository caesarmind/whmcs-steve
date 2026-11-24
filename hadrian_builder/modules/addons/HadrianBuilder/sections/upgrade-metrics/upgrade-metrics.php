<?php
/**
 * A heading over a two-column grid of short metrics, each with a title and a
 * line of text.
 * Markup and classes: the theme's hp-upgrade-section block.
 */
return [
    'label'  => 'Metric highlights',
    'hint'   => 'A two-column grid of short metrics',
    'group'  => 'Features',
    'order'  => 365,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What a bigger plan gets you']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'The difference you notice once a site outgrows shared hosting.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Metrics', 'max' => 8, 'itemLabel' => 'title', 'addLabel' => 'Add metric',
            'help' => 'Two to a row. An even number keeps the dividing lines tidy.',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Metric', 'translatable' => true, 'default' => ['_' => '2x'],
                    'help' => 'A number or one short word.'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Metric title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['value' => ['_' => '2x'], 'title' => ['_' => 'More memory'], 'text' => ['_' => 'Double the RAM of the starter plan, kept for your sites alone.']],
                ['value' => ['_' => 'NVMe'], 'title' => ['_' => 'Faster disks'], 'text' => ['_' => 'Database queries and page builds finish sooner.']],
                ['value' => ['_' => 'Root'], 'title' => ['_' => 'Full access'], 'text' => ['_' => 'Install your own software and tune the server your way.']],
                ['value' => ['_' => '30 days'], 'title' => ['_' => 'Of backups'], 'text' => ['_' => 'Go back a month when something breaks.']],
            ]],
    ],
];
