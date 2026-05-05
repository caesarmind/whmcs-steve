<?php
/**
 * Per-variant settings for login/default.
 *
 * Read at runtime as $myTheme.pages.login.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Centered Apple-style login card with email/password + Remember me.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showEyebrow' => [
            'type'    => 'checkbox',
            'name'    => 'showEyebrow',
            'label'   => 'Show "ACCOUNT" eyebrow',
            'default' => true,
            'tooltip' => 'Renders the small uppercase "ACCOUNT" label above the page heading.',
        ],
        'allowRemember' => [
            'type'    => 'checkbox',
            'name'    => 'allowRemember',
            'label'   => 'Show "Remember me" checkbox',
            'default' => true,
            'tooltip' => 'Lets the visitor keep their session for the duration WHMCS allows.',
        ],
        'showCreateLink' => [
            'type'    => 'checkbox',
            'name'    => 'showCreateLink',
            'label'   => 'Show "Create account" link',
            'default' => true,
            'tooltip' => 'Adds the "Don\'t have an account? Create one" footer below the form.',
        ],
        'showForgotLink' => [
            'type'    => 'checkbox',
            'name'    => 'showForgotLink',
            'label'   => 'Show "Forgot password" link',
            'default' => true,
            'tooltip' => 'Renders the password-reset link under the Sign In button.',
        ],
    ],
];
