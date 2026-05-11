<?php
/**
 * Per-variant settings for clientareasecurity/default.
 *
 * Read at runtime as $myTheme.pages.clientareasecurity.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Three-card security view: 2FA status + methods, login alerts toggles, active sessions.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show profile sub-nav',
            'default' => true,
            'tooltip' => 'Renders the left aside with links to Profile, Change Password, Security Settings, Logout.',
        ],
        'showTfaMethods' => [
            'type'    => 'checkbox',
            'name'    => 'showTfaMethods',
            'label'   => 'Show 2FA methods row',
            'default' => true,
            'tooltip' => 'Renders the 3-method grid (Authenticator / Email / Security key) under the 2FA status card.',
        ],
        'showLoginAlerts' => [
            'type'    => 'checkbox',
            'name'    => 'showLoginAlerts',
            'label'   => 'Show login alerts card',
            'default' => true,
            'tooltip' => 'Renders the "Login alerts" card with toggles for new-device, password-change, payment-method notifications.',
        ],
        'showActiveSessions' => [
            'type'    => 'checkbox',
            'name'    => 'showActiveSessions',
            'label'   => 'Show active sessions card',
            'default' => true,
            'tooltip' => 'Renders the "Active sessions" card listing currently signed-in devices with sign-out controls.',
        ],
    ],
];
