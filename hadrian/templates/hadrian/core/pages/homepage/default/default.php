<?php
/**
 * Variant metadata for homepage/default -- the Apple-style marketing landing
 * that has shipped as the active homepage all along. Unchanged.
 *
 * Read by Template::getPageVariants() (admin variant cards) and by
 * Hooks::resolveCurrentPage() at render time, both of which look for
 * core/pages/{page}/{variant}/{variant}.php -- NOT pageoption.php, which
 * nothing in the addon reads. Page options live in ../page.php
 * 'supportedOptions'. (The old default/pageoption.php was dropped for exactly
 * that reason: its declared settings never reached the admin UI. 'portal' still
 * has one and therefore still shows a bare, description-less admin card.)
 *
 * NOTE for whoever edits default.tpl next: it reads its toggles as
 * $hadrian.pages.homepage.config.*, and resolveCurrentPage builds no 'config'
 * member at all -- so those reads return null and the |default: always wins.
 * The real path is .options.*, as core/pages/homepage/simple/simple.tpl uses.
 */
return [
    'name'        => 'Marketing landing',
    'description' => 'The full Apple-style landing: hero + domain search, trust stats, isolation grid, white-label tools, audience columns, pricing, reviews and a closing CTA.',
    'fullPage'    => false,
];
