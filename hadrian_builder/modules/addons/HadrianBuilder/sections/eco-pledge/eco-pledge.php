<?php
/**
 * A sustainability statement: a green globe (or a picture) beside a heading,
 * a paragraph, a few figures and a link. The defaults are placeholders, as
 * every claim here has to be one the site can back up.
 * Markup and classes: the theme's hp-eco-section block.
 */
return [
    'label'  => 'Sustainability pledge',
    'hint'   => 'An environmental statement with figures',
    'group'  => 'Trust and numbers',
    'order'  => 760,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Our approach to energy use']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Servers need power, and we would like ours to need less of it. Use this space to say what you measure, what you have changed so far and what you plan to do next.'],
            'help' => 'State only what your company can show evidence for.'],
        ['key' => 'stats', 'type' => 'list', 'label' => 'Figures', 'max' => 4, 'itemLabel' => 'label', 'addLabel' => 'Add figure',
            'help' => 'Figures sit two to a row. Remove the placeholders you do not replace.',
            'fields' => [
                ['key' => 'value', 'type' => 'text', 'label' => 'Figure', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'label', 'type' => 'text', 'label' => 'Label', 'translatable' => true, 'default' => ['_' => 'New figure']],
            ],
            'default' => [
                ['value' => ['_' => 'Measured'], 'label' => ['_' => 'Add a figure you publish']],
                ['value' => ['_' => 'Planned'], 'label' => ['_' => 'Add a goal you have set']],
            ]],
        ['key' => 'linkLabel', 'type' => 'text', 'label' => 'Link text', 'translatable' => true, 'default' => ['_' => 'Read the details']],
        ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => '',
            'help' => 'For example a page or a report with your figures. The link is shown only when it has both a text and an address.'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => '',
            'help' => 'Shown in place of the green globe.'],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
    ],
];
