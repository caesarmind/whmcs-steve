<?php
/**
 * Variant metadata for homepage/portal -- displayed as "Classic", the original
 * portal-style homepage kept as a switchable alternative when the marketing
 * landing became the default. The DIRECTORY stays `portal`: the name is only a
 * label, and renaming the dir would orphan every stored `variant = 'portal'`
 * row.
 *
 * Read by Template::getPageVariants() (admin variant cards) and by
 * Hooks::resolveCurrentPage() at render time. The filename must match the
 * directory (portal/portal.php beside portal/portal.tpl) or the variant is
 * skipped silently -- this file is what replaced the bare, description-less
 * admin card this variant showed while it only had a pageoption.php, which
 * nothing reads.
 *
 * Description fact-checked against portal.tpl: a ph-hero with the working
 * domain-search form, then three ph-section grids -- product categories,
 * self-service shortcuts ("How can we help"), and account links.
 */
return [
    'name'        => 'Classic',
    'description' => 'The original portal homepage: a domain-search hero over three quick-link grids - product categories, self-service shortcuts and account tools. Light on marketing copy, quick to scan.',
    'fullPage'    => false,
];
