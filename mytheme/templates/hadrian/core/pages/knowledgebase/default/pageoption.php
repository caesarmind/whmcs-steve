<?php
return [
    'display_name' => 'Default',
    'description'  => 'Knowledgebase landing — hero search + category grid + popular articles sidebar.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showPopular' => [
            'type'    => 'checkbox',
            'name'    => 'showPopular',
            'label'   => 'Show popular articles in sidebar',
            'default' => true,
            'tooltip' => 'Renders the "Most popular" list of up to 5 articles in the left aside.',
        ],
        'gridCols' => [
            'type'    => 'select',
            'name'    => 'gridCols',
            'label'   => 'Category grid columns',
            'default' => '3',
            'options' => ['2', '3', '4'],
            'tooltip' => 'Number of category tile columns at desktop width.',
        ],
    ],
];
