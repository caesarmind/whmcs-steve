<?php
/**
 * Variant meta for clientareahome/atrium.
 *
 * Read by:
 *   - Template::getPageVariants  -> label + description in the admin Pages picker
 *   - Template::getVariantMeta   -> this variant's own 'supportedOptions'
 *   - Hooks::resolveCurrentPage  -> `fullPage` (false: keeps nav, sidebar, footer)
 *
 * The filename MUST match the directory name (atrium/atrium.php beside
 * atrium/atrium.tpl) or the variant is silently skipped -- no admin card, no
 * error anywhere. There is deliberately no pageoption.php: nothing reads it.
 *
 * OPTIONS ARE VARIANT-SCOPED, stored as `<key>__atrium`. The `atr_` prefix is
 * load-bearing rather than decorative: Hooks falls back to the un-namespaced
 * bare key for options that used to be page-scoped, so reusing `bnt_sections`
 * here would let an install that saved the pre-namespacing key inherit bento's
 * arrangement into atrium.
 *
 * WHAT THIS VARIANT IS. A hero band, a four-figure summary strip, then an
 * asymmetric two-column body. That last part is the reason it is a separate
 * variant rather than a bento layout: bento flows tiles across one six-column
 * grid, which interleaves rows and cannot produce two independent stacks of
 * unequal height. Here a section's WIDTH reads as a column assignment --
 * full-width band, main column, or side column -- which is why the width labels
 * differ from bento's.
 */
return [
    'name'        => 'Atrium',
    'description' => 'A welcome band over four summary figures, then an asymmetric two-column body: the collections you read down the wide side, the things you act on down the narrow one. Width assigns a block to a column rather than sizing it on a grid, so reordering moves a block within its column.',
    'fullPage'    => false,

    // Read in atrium.tpl as $hadrian.pages.clientareahome.options.<key>.
    // Hooks flattens the active variant's namespaced values onto the bare key,
    // so the template never sees the namespace. The stored array is taken raw
    // with no default merge, so every template read carries its own |default:
    // matching the value declared here.
    'supportedOptions' => [
        'atr_hero' => [
            'type'    => 'bool',
            'label'   => 'Welcome band',
            'default' => true,
            'tooltip' => 'The greeting, the date and the actions across the top. Switching it off starts the page at the summary figures.',
        ],

        // The four summary tiles, each independently switchable. They are ONE
        // section rather than four because the layout DSL has no 1/4 token and
        // six columns cannot express quarters -- four 1/3 entries would span 8
        // and wrap 3+1. So the strip is a single full-width section that draws
        // its own four-up grid, and these decide which tiles it draws.
        'atr_stat_services' => [
            'type'    => 'bool',
            'label'   => 'Figure: active services',
            'default' => true,
            'tooltip' => 'Counts active services on the account, not the rows listed below.',
        ],
        'atr_stat_domains' => [
            'type'    => 'bool',
            'label'   => 'Figure: domains',
            'default' => true,
            'tooltip' => 'Counts active domains, with a sub-line for any expiring within 45 days.',
        ],
        'atr_stat_billing' => [
            'type'    => 'bool',
            'label'   => 'Figure: balance due',
            'default' => true,
            'tooltip' => 'The unpaid total and how many invoices make it up. Shows how overdue the worst one is only when something actually is.',
        ],
        'atr_stat_tickets' => [
            'type'    => 'bool',
            'label'   => 'Figure: open tickets',
            'default' => true,
            'tooltip' => 'Open tickets, with a sub-line for any where staff have replied and are waiting on the client.',
        ],
    ],
];
