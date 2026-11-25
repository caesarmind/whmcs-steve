<?php
/**
 * The accessibility statement's one design. Read in default.tpl as
 * $hadrian.pages.accessibility.options.<key>; every read carries its own
 * |default: matching the value here.
 */
return [
    'name'        => 'Statement',
    'description' => 'Conformance status, what the site does, known limitations, how it was checked, contact and enforcement, dates.',
    'fullPage'    => false,

    'supportedOptions' => [
        'stmt_status' => [
            'type'    => 'select',
            'label'   => 'Conformance status',
            'default' => 'partial',
            'options' => ['full', 'partial', 'none'],
            'tooltip' => 'Full only if every page, including content you added and modules you installed, meets WCAG 2.2 AA. Partial is the honest default for most sites.',
        ],
        'stmt_limitations' => [
            'type'    => 'text',
            'label'   => 'Known limitations',
            'default' => '',
            'tooltip' => 'What does not meet the standard yet and what you are doing about it. Leave empty to show the default paragraph about payment providers, third-party content and PDF invoices.',
        ],
        'stmt_method' => [
            'type'    => 'select',
            'label'   => 'How it was checked',
            'default' => 'self',
            'options' => ['self', 'third-party'],
            'tooltip' => 'Self-assessment, or an independent audit.',
        ],
        'stmt_email' => [
            'type'    => 'text',
            'label'   => 'Accessibility contact email',
            'default' => '',
            'tooltip' => 'Where people can report a barrier. The contact form and support tickets are always listed too.',
        ],
        'stmt_enforcement' => [
            'type'    => 'text',
            'label'   => 'Enforcement body',
            'default' => '',
            'tooltip' => 'The national authority people can complain to if your answer does not satisfy them, for example the market surveillance authority of your EU country. Leave empty to hide the section.',
        ],
        'stmt_prepared' => [
            'type'    => 'text',
            'label'   => 'Date prepared',
            'default' => '',
            'tooltip' => 'Written as you want it shown, for example 26 November 2026.',
        ],
        'stmt_reviewed' => [
            'type'    => 'text',
            'label'   => 'Date last reviewed',
            'default' => '',
            'tooltip' => 'Review the statement at least once a year and whenever the site changes a lot.',
        ],
    ],
];
