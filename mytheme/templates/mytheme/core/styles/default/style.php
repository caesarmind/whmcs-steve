<?php
/**
 * Style preset manifest — DEFAULT.
 *
 * Read by:
 *   - StylesController (admin UI)
 *   - Hooks::resolveActiveStyle (sets $myTheme.styles.vars at render time)
 */
return [
    'name'        => 'Default',
    'description' => 'Light, clean, neutral. The default look.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',

    /**
     * Smarty variables surfaced as $myTheme.styles.vars.* at render time.
     * Use these in tpls/SCSS as a body class / data-attribute / CSS var.
     */
    'variables'   => [
        'bodyClass'  => 'theme-default',
        'colorMode'  => 'light',
    ],

    /**
     * Sub-style customizations the admin can pick per-component.
     * Each one becomes a Smarty var like $siteBannerStyle.
     * (Lagom-style cascade — we kept this; it's actually useful.)
     */
    'settings'    => [
        'group' => [
            'navigation' => [
                'name'   => 'Navigation',
                'styles' => [
                    'topNav' => [
                        'variableName' => 'topNavStyle',
                        'name'         => 'Top Navigation Style',
                        'default'      => 'primary',
                        'options'      => ['primary', 'secondary', 'neutral'],
                    ],
                ],
            ],
            'banner' => [
                'name'   => 'Banner',
                'styles' => [
                    'siteBanner' => [
                        'variableName' => 'siteBannerStyle',
                        'name'         => 'Site Banner Style',
                        'default'      => 'primary',
                        'options'      => ['primary', 'secondary', 'gradient'],
                    ],
                ],
            ],
        ],
    ],
];
