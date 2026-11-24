<?php
/**
 * Numbered cards that walk a visitor through getting started: a number, an
 * icon, a title and a line of text each.
 * Markup and classes: the theme's hp-onboarding-steps block. The theme only
 * styles its row, so the heading and cards borrow hp-features-section and
 * hp-feature-card; the number on each card carries its own styles.
 */
return [
    'label'  => 'Getting started steps',
    'hint'   => 'Numbered cards, one per step',
    'group'  => 'Features',
    'order'  => 385,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Online in three steps']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => '']],
        ['key' => 'steps', 'type' => 'list', 'label' => 'Steps', 'max' => 6, 'itemLabel' => 'title', 'addLabel' => 'Add step',
            'help' => 'Three to a row. The numbers are added for you.',
            'fields' => [
                ['key' => 'icon', 'type' => 'icon', 'label' => 'Icon', 'default' => 'check'],
                ['key' => 'colour', 'type' => 'select', 'label' => 'Icon colour', 'default' => 'blue',
                    'options' => ['blue' => 'Blue', 'green' => 'Green', 'purple' => 'Purple', 'orange' => 'Orange', 'teal' => 'Teal', 'red' => 'Red']],
                ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Step title']],
                ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['icon' => 'tag', 'colour' => 'blue', 'title' => ['_' => 'Pick a plan'], 'text' => ['_' => 'Choose the one that fits your site. You can change it later.']],
                ['icon' => 'globe', 'colour' => 'green', 'title' => ['_' => 'Add your domain'], 'text' => ['_' => 'Register a new name or connect one you already own.']],
                ['icon' => 'rocket', 'colour' => 'purple', 'title' => ['_' => 'Go live'], 'text' => ['_' => 'Install your site, or ask us to move it over, and publish.']],
            ]],
    ],
];
