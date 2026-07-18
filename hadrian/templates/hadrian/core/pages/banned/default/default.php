<?php
/**
 * Variant meta for banned/default.
 *
 * Read by Hooks::resolveCurrentPage via ThemeManifest::loadVariantMeta(), which
 * looks for `core/pages/{page}/{variant}/{variant}.php` — NOT pageoption.php.
 *
 * `fullPage => true` suppresses the portal nav, sidebar/rail, breadcrumb and
 * footer. That matters here more than anywhere else in the theme: an IP ban
 * blocks every route on the domain, so the shell rendered ~60 navigation links
 * that all redirect straight back to this page. A lockout screen offering a
 * fully populated but entirely dead menu reads as "the site is broken" rather
 * than "you are blocked".
 */
return [
    'name'        => 'Default',
    'description' => 'Full-bleed IP-block notice. Hides the portal nav and footer, since every link on the site is unreachable while the ban is active.',
    'fullPage'    => true,
];
