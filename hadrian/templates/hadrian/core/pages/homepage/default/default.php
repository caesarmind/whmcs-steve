<?php
/**
 * Variant metadata for homepage/default -- displayed as "Modern", the full
 * marketing landing that ships as the active homepage. The DIRECTORY stays
 * `default`: the name is only a label, and renaming the dir would orphan every
 * stored `variant = 'default'` row.
 *
 * Read by Template::getPageVariants() (admin variant cards) and by
 * Hooks::resolveCurrentPage() at render time, both of which look for
 * core/pages/{page}/{variant}/{variant}.php -- NOT pageoption.php, which
 * nothing in the addon reads. Page options live in ../page.php
 * 'supportedOptions'.
 *
 * The description is fact-checked against default.tpl's actual sections:
 * hp-hero (+ domain search), hp-stats-strip, the iso* grid, the wl* white-label
 * duo, hp-feature-columns (col1-3), hp-pricing-segmented (+ hp-cat-rows, live
 * product groups), hp-announce-grid (newsTitle -- ANNOUNCEMENTS, not reviews:
 * the old text claimed a reviews section this template has never had), and
 * hp-cta-immersive.
 *
 * default.tpl reads its options as $hadrian.pages.homepage.options.*.
 * resolveCurrentPage builds no 'config' member, so a .config.* read always
 * returns null and its |default: wins (bug 8 in tests/FEATURES.md).
 */
return [
    'name'        => 'Modern',
    'description' => 'The full marketing landing: hero with domain search, trust stats, the isolation grid, white-label tools, audience columns, live product-group pricing, latest announcements and a closing call to action.',
    'fullPage'    => false,
];
