<?php
/**
 * Per-variant settings for clientareadetails/default.
 *
 * Read at runtime as $hadrian.pages.clientareadetails.config.<key>
 */
return [
    'display_name' => 'Default',
    'description'  => 'Account form with sub-nav aside and stacked cards (personal info, billing, email prefs).',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showSubnav' => [
            'type'    => 'checkbox',
            'name'    => 'showSubnav',
            'label'   => 'Show account sub-nav',
            'default' => true,
            'tooltip' => 'Renders the left aside with links to Account Details, User Management, Payment Methods, Contacts, Email History.',
        ],
        'showEmailPrefs' => [
            'type'    => 'checkbox',
            'name'    => 'showEmailPrefs',
            'label'   => 'Show email preferences card',
            'default' => true,
            'tooltip' => 'Renders the "Email preferences" card with checkboxes for general/invoice/support/product/domain/affiliate notification opt-in.',
        ],
        'languageSelect' => [
            'type'    => 'checkbox',
            'name'    => 'languageSelect',
            'label'   => 'Show language selector',
            'default' => true,
            'tooltip' => 'Renders the Language dropdown inside the Personal information card (only appears if $languages is populated).',
        ],
    ],
];
