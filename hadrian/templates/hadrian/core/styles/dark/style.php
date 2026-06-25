<?php
return [
    'name'        => 'Dark',
    'description' => 'Dark surfaces, light text. Toggleable via display_mode_switcher.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-dark',
        'colorMode' => 'dark',
    ],
    'settings'    => [
        'group' => [
            'navigation' => [
                'name'   => 'Navigation',
                'styles' => [
                    'topNav' => [
                        'variableName' => 'topNavStyle',
                        'name'         => 'Top Navigation Style',
                        'default'      => 'neutral',
                        'options'      => ['primary', 'secondary', 'neutral'],
                    ],
                ],
            ],
        ],
    ],
];
