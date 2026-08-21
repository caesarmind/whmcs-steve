<?php
/**
 * Main-menu layout manifest.
 *
 * Only three things here are read at runtime:
 *   displayName / description  -> admin Layouts list (LayoutsController)
 *   variables.dataLayout       -> body[data-layout] (header.tpl), which is what
 *                                 every layout-scoped CSS rule keys off
 *   supportedOptions           -> admin picker, validated on save and re-read
 *                                 by Hooks into body[data-align]
 *
 * Deliberately absent: 'preview' (the admin draws inline SVG thumbnails and no
 * thumb.png exists), 'order' (Template::getLayouts returns theme.json's
 * provides.layouts verbatim and unsorted -- that sequence is canonical),
 * 'bodyClass' (body[data-layout] already does this job) and 'sidebarPresent'.
 * All four were declared and read by nothing.
 */
return [
    'displayName' => 'Top Navigation',
    'description' => 'Horizontal navbar at the top, full-width content below.',
    'variables'   => [
        'dataLayout' => 'top',
    ],
    /* Page-structure dimensions this layout shapes, rendered as Container rows
       on the admin Layouts page. Declared here (not hardcoded in the admin) so
       each row's "Applies to..." caption is derived from the layouts that
       actually claim the token. Defaults + labels live in core/config/layout.php.

       Note --topbar-height is deliberately absent: header.tpl renders the inner
       topbar for every layout EXCEPT this one, so that field shapes nothing
       here. This layout's bar is .homepage-nav-inner, sized by --topnav-height,
       which the product subnav and mega-menu also hang off. The logo height is
       shared with all three other layouts.

       The icon pair IS claimed here even though .homepage-nav draws its own
       glyphs at --topnav-icon-size: header.tpl:430 renders
       includes/partials/sidebar.tpl for this layout too, as the mobile
       slide-in drawer behind the hamburger, and those rows are .sidebar-item
       sized by --nav-icon-size / --nav-icon-glyph. Omitting them made the
       admin caption under-report which layouts a change touches. */
    'sizes' => ['--nav-logo-height', '--topnav-height', '--topnav-icon-size',
                '--nav-icon-size', '--nav-icon-glyph'],
];
