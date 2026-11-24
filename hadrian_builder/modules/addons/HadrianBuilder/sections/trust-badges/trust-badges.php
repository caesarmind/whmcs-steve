<?php
/**
 * A grid of small badges, each a short code above a label, for the security
 * and care commitments a site makes.
 * Markup and classes: the theme's hp-trust-badges block.
 */
return [
    'label'  => 'Compliance badges',
    'hint'   => 'A grid of small badges with labels',
    'group'  => 'Trust and numbers',
    'order'  => 730,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Protection that is already switched on']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'What every account gets from the first day.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Badges', 'max' => 12, 'itemLabel' => 'label', 'addLabel' => 'Add badge',
            'help' => 'Badges sit six to a row. List only what your company really provides or holds.',
            'fields' => [
                ['key' => 'code', 'type' => 'text', 'label' => 'Short code', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A few characters shown large, such as "2FA". Leave empty to show the label alone.'],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New badge']],
            ],
            'default' => [
                ['code' => ['_' => '24h'], 'label' => ['_' => 'Daily backups']],
                ['code' => ['_' => '2FA'], 'label' => ['_' => 'Two-step sign-in']],
                ['code' => ['_' => 'SSL'], 'label' => ['_' => 'Certificate on every site']],
                ['code' => ['_' => 'Disk'], 'label' => ['_' => 'Encrypted at rest']],
                ['code' => ['_' => 'DDoS'], 'label' => ['_' => 'Attack filtering']],
                ['code' => ['_' => '24/7'], 'label' => ['_' => 'Monitoring']],
            ]],
    ],
];
