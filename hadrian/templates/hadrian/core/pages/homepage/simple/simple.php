<?php
/**
 * Variant metadata for homepage/simple -- a leaner alternative landing.
 *
 * Added ALONGSIDE 'default', which keeps its place as the active homepage.
 * Selecting this one is an explicit admin choice in Hadrian > Pages > Homepage.
 *
 * Read by Template::getPageVariants() (admin variant cards) and by
 * Hooks::resolveCurrentPage() at render time, both of which look for
 * core/pages/{page}/{variant}/{variant}.php -- NOT pageoption.php, which
 * nothing in the addon reads (its only hits are comments in PagesController).
 * Page options live in ../page.php 'supportedOptions' and are read here as
 * $hadrian.pages.homepage.options.* -- the .config.* path that default.tpl
 * still uses does not exist and silently returns null.
 *
 * The filename must match the directory name (simple/simple.php beside
 * simple/simple.tpl) or the variant is skipped silently, with no admin card
 * and no error. Without this file the card falls back to the ucfirst()
 * directory name with no description -- which is what 'portal' still does,
 * having no portal.php.
 */
return [
    'name'        => 'Simple',
    'description' => 'Lean five-section landing: hero + domain search, real product groups, four capability tiles, latest announcements, one closing CTA. Roughly half the length of the marketing landing, with no invented metrics and no new CSS.',
    'fullPage'    => false,
];
