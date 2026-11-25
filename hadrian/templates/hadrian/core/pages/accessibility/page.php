<?php
/**
 * Page-level metadata for the accessibility statement.
 *
 * The European Accessibility Act (Directive 2019/882, Article 13 and
 * Annex V) asks a service that sells to consumers to publish how it meets the
 * accessibility requirements. This page is that statement, wrapped in the
 * theme's header and footer. Its wording ships in core/lang/english.php
 * (group a11yStatement); the parts only the site owner knows are this page's
 * options in the admin Pages tab.
 *
 * Not reachable until the site owner creates the entry file: copy
 * custom-page.php in the WHMCS root to accessibility.php and change
 * setTemplate('custom-page') to setTemplate('accessibility'). Hadrian does
 * not ship that file, so a statement with default answers never goes live by
 * itself. See hadrian-documentation/content/client-theme/12-accessibility.md.
 */
return [
    'display_name' => 'Accessibility statement',
    'group'        => 'Public',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Your accessibility statement: how the site meets WCAG 2.2 AA, its known limitations and how to contact you. Fill in the options before you publish it.',
    'seoDefaults'  => [
        'indexing'    => 'allow',
        'title'       => 'Accessibility statement',
        'description' => 'How accessible this website is, its known limitations, and how to contact us about accessibility.',
    ],
];
