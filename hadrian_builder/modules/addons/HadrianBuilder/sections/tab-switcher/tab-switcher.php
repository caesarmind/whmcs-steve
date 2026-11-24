<?php
/**
 * A row of tabs over a grid of icon cards. Clicking a tab shows the cards
 * filed under it.
 * Markup and classes: the theme's hp-tab-switcher block. The theme has no
 * rules of its own for it, so the heading borrows hp-features-section, the
 * tabs hp-ft-tabs and the cards hp-feature-cards. The section's own script
 * switches the tabs.
 */
return [
    'label'  => 'Tabbed content',
    'hint'   => 'Tabs that switch between sets of cards',
    'group'  => 'Features',
    'order'  => 395,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What you get to work with']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Pick a topic to see what is included.']],
        ['key' => 'cards', 'type' => 'list', 'label' => 'Cards', 'max' => 24, 'itemLabel' => 'title', 'addLabel' => 'Add card',
            'help' => 'Cards that share a tab name appear together. Tabs are shown in the order their names first appear.',
            'fields' => [
                ['key' => 'tab', 'type' => 'text', 'label' => 'Tab', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The name of the tab this card belongs to. Leave empty to show the card under every tab.'],
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'colour', 'type' => 'select', 'label' => 'Icon colour', 'default' => 'blue',
                    'options' => ['blue' => 'Blue', 'green' => 'Green', 'purple' => 'Purple', 'orange' => 'Orange', 'teal' => 'Teal', 'red' => 'Red']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Card title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['tab' => ['_' => 'Build'], 'icon' => 'download', 'colour' => 'blue', 'title' => ['_' => 'One-click installs'], 'text' => ['_' => 'WordPress and other apps, ready in a minute.']],
                ['tab' => ['_' => 'Build'], 'icon' => 'layers', 'colour' => 'purple', 'title' => ['_' => 'Staging sites'], 'text' => ['_' => 'Try changes on a copy before visitors see them.']],
                ['tab' => ['_' => 'Build'], 'icon' => 'terminal', 'colour' => 'orange', 'title' => ['_' => 'SSH and Git'], 'text' => ['_' => 'Deploy the way you already work.']],
                ['tab' => ['_' => 'Run'], 'icon' => 'bolt', 'colour' => 'orange', 'title' => ['_' => 'Built-in caching'], 'text' => ['_' => 'Pages come from memory instead of being rebuilt on each visit.']],
                ['tab' => ['_' => 'Run'], 'icon' => 'chart', 'colour' => 'blue', 'title' => ['_' => 'Usage graphs'], 'text' => ['_' => 'See CPU, memory and traffic at a glance.']],
                ['tab' => ['_' => 'Run'], 'icon' => 'sliders', 'colour' => 'teal', 'title' => ['_' => 'PHP settings'], 'text' => ['_' => 'Pick a version and set the limits for each site.']],
                ['tab' => ['_' => 'Protect'], 'icon' => 'shield', 'colour' => 'green', 'title' => ['_' => 'SSL certificates'], 'text' => ['_' => 'Issued and renewed for every domain.']],
                ['tab' => ['_' => 'Protect'], 'icon' => 'database', 'colour' => 'purple', 'title' => ['_' => 'Nightly backups'], 'text' => ['_' => 'Restore one file or the whole site yourself.']],
                ['tab' => ['_' => 'Protect'], 'icon' => 'eye', 'colour' => 'red', 'title' => ['_' => 'Malware scans'], 'text' => ['_' => 'We check your files every day and tell you what we find.']],
            ]],
    ],
];
