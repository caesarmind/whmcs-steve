<?php
/**
 * A row of tabs. Each tab opens a panel with a heading, a paragraph, a list
 * of points and a picture or a large icon. The theme's own script switches
 * the panels.
 * Markup and classes: the theme's hp-feature-tabs block.
 */
return [
    'label'  => 'Feature tabs',
    'hint'   => 'Tabs that each open a panel',
    'group'  => 'Features',
    'order'  => 335,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What comes with your hosting']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Pick a tab to see the details.']],
        ['key' => 'tabs', 'type' => 'list', 'label' => 'Tabs', 'max' => 6, 'itemLabel' => 'label', 'addLabel' => 'Add tab',
            'fields' => [
                ['key' => 'label', 'type' => 'text', 'label' => 'Tab label', 'translatable' => true, 'default' => ['_' => 'New tab'],
                    'help' => 'A tab with no label is left out.'],
                ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'points', 'type' => 'lines', 'label' => 'Points', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'One point per line. Each gets a tick.'],
                ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
                ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon when there is no image', 'default' => 'star'],
            ],
            'default' => [
                ['label' => ['_' => 'Speed'], 'title' => ['_' => 'Fast pages, without tuning'],
                    'text' => ['_' => 'Your site runs on NVMe storage with caching already switched on.'],
                    'points' => ['_' => "NVMe storage on every plan\nServer-side caching\nHTTP/3 and compression\nRecent PHP versions"],
                    'image' => '', 'imageAlt' => ['_' => ''], 'icon' => 'bolt'],
                ['label' => ['_' => 'Security'], 'title' => ['_' => 'Protected from the first day'],
                    'text' => ['_' => 'A certificate, a firewall and nightly scans are part of the plan.'],
                    'points' => ['_' => "Free SSL certificate\nWeb application firewall\nNightly malware scans\nTwo-factor sign-in"],
                    'image' => '', 'imageAlt' => ['_' => ''], 'icon' => 'shield'],
                ['label' => ['_' => 'Tools'], 'title' => ['_' => 'Tools for people who build'],
                    'text' => ['_' => 'Use the control panel, or work from the command line if that is quicker for you.'],
                    'points' => ['_' => "SSH access\nGit deployment\nStaging copies\nScheduled tasks"],
                    'image' => '', 'imageAlt' => ['_' => ''], 'icon' => 'terminal'],
                ['label' => ['_' => 'Support'], 'title' => ['_' => 'Help from people who know the servers'],
                    'text' => ['_' => 'Write to us at any hour. The person who answers can fix the problem.'],
                    'points' => ['_' => "Tickets and live chat\nFree site moves\nSetup help for new accounts\nGuides for common tasks"],
                    'image' => '', 'imageAlt' => ['_' => ''], 'icon' => 'chat'],
            ]],
    ],
];
