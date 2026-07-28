<?php
/**
 * Page-level metadata for homepage.
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Homepage',
    'group'        => 'Public',
    'type'         => 'public',
    'listDisplay'  => true,
    'description'  => 'Public landing rendered when /index.php is hit (logged-in users go to dashboard).',

    // Page options are PAGE-scoped, not variant-scoped: the editor shows all of
    // these whichever variant is selected. Names are kept generic so the other
    // variants can adopt them once their dead $hadrian.pages.homepage.config.*
    // reads are corrected to the real .options.* path.
    //
    // Consumed today by core/pages/homepage/default/default.tpl. Read at render
    // time as $hadrian.pages.homepage.options.<key>; the stored array is taken
    // raw (Hooks.php resolveCurrentPage), so every template read must carry its
    // own |default: matching the value declared here.
    //
    // Do NOT name an option full_page: Hooks::resolveCurrentPage treats that
    // key specially and would suppress the nav, sidebar, breadcrumb and footer.
    'supportedOptions' => [
        'heroTitle' => [
            'type'    => 'text',
            'label'   => 'Hero title',
            'default' => '',
            'tooltip' => 'Override the big hero heading. Leave blank to use the theme default ("Hosting, redesigned.").',
        ],
        'heroSubtitle' => [
            'type'    => 'text',
            'label'   => 'Hero subtitle',
            'default' => '',
            'tooltip' => 'Override the tagline under the hero heading. Leave blank to use the theme default.',
        ],
        'show_domain_search' => [
            'type'    => 'bool',
            'label'   => 'Show domain search',
            'default' => true,
            'tooltip' => 'Shows the domain search box and the live TLD price strip inside the hero. The headline and tagline always render. The form is additionally hidden when domain registration is switched off in WHMCS, so it can never render as a dead control.',
        ],
        'show_products' => [
            'type'    => 'bool',
            'label'   => 'Show product groups',
            'default' => true,
            'tooltip' => 'Lists your real WHMCS product groups with their tagline and cheapest starting price. When the catalogue returns nothing, the section shows a short explanation and a link to the store instead.',
        ],
        'show_features' => [
            'type'    => 'bool',
            'label'   => 'Show capability tiles',
            'default' => true,
            'tooltip' => 'Four tiles describing what the platform provides (isolated MySQL, per-site PHP versions, private Redis, capped CPU and RAM). Static copy from the theme language file.',
        ],
        'show_news' => [
            'type'    => 'bool',
            'label'   => 'Show latest announcements',
            'default' => true,
            'tooltip' => 'Shows up to three of your latest WHMCS announcements. The section is skipped entirely when there are none, so it never renders as an empty shell.',
        ],
        'show_cta' => [
            'type'    => 'bool',
            'label'   => 'Show closing call to action',
            'default' => true,
            'tooltip' => 'The full-bleed gradient band that closes the page, with one heading, one line of copy and a single button into the cart.',
        ],
    ],
];
