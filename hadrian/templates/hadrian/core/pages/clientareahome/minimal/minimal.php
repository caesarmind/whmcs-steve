<?php
/**
 * Variant meta for clientareahome/minimal.
 *
 * Read by:
 *   - Template::getPageVariants  -> label + description in the admin Pages picker
 *   - Hooks::resolveCurrentPage  -> `fullPage` (false here: this variant keeps
 *                                   the portal nav, sidebar/rail and footer)
 *
 * The filename MUST match the directory name (minimal/minimal.php beside
 * minimal/minimal.tpl) or the variant is silently skipped with no admin card
 * and no error. There is deliberately no pageoption.php: nothing in the addon
 * reads that file. Per-page options live in ../page.php 'supportedOptions'.
 */
return [
    'name'        => 'Minimal',
    'description' => 'A quieter dashboard: greeting, four summary tiles, quick actions, then services, domains, invoices, tickets and announcements as plain rows on one surface. No panel grid or account sub-nav aside.',
    'fullPage'    => false,
];
