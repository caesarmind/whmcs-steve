<?php
/**
 * Variant meta for login/split.
 *
 * Read by:
 *   - Template::getPageVariants  → label + description in the admin Pages picker
 *   - Hooks::resolveCurrentPage  → `fullPage` toggles the header/footer chrome off
 *
 * `fullPage => true` makes the theme render this variant edge-to-edge: the
 * portal nav, sidebar/rail, breadcrumb and footer are suppressed so the
 * split sign-in screen owns the whole viewport.
 */
return [
    'name'        => 'Split + Announcements',
    'description' => 'Full-bleed two-column sign-in — brand and the latest announcements on one side, the login form on the other. Hides the portal nav and footer.',
    'fullPage'    => true,
];
