<?php
/**
 * Page-level metadata for clientareahome.
 *
 * Read by:
 *   - PagesController (admin UI for selecting variants and editing options)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Dashboard',
    'group'        => 'Client Area',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Logged-in client home page with widgets, alerts, and quick links.',

    // NO page-scoped options. Everything this page offers belongs to ONE
    // template and lives in that variant's own <variant>.php 'supportedOptions'
    // -- see minimal/minimal.php. Options declared HERE would render in the
    // editor whichever template is selected, which is how the Minimal-only
    // settings ended up on screen while the Default dashboard (which reads
    // none of them) was active.
    //
    // Declare something here only when it genuinely applies to every variant.
    // Read at render time as $hadrian.pages.clientareahome.options.<key> -
    // NOT .config.<key>, which resolveCurrentPage never builds. Never name a
    // key full_page: that one is special-cased into suppressing the nav,
    // sidebar, breadcrumb and footer.
    'supportedOptions' => [],
];
