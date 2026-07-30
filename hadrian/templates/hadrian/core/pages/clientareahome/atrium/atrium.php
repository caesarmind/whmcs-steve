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

        // Which blocks appear, in what order, and in which COLUMN.
        //
        // Width means something different here than in bento. Bento flows tiles
        // across one six-column grid; atrium has a full-width band over two
        // independent column stacks, which widths alone cannot express. So the
        // template BUCKETS by the width token the parser already returns
        // alongside the span: 1/1 goes in the band, 2/3 and 1/2 in the main
        // column, 1/3 in the side column. Ordering, visibility, hide-when-empty,
        // per-block rows and colour all behave exactly as bento's do; only the
        // meaning of width changes, which is why the labels below are rewritten
        // rather than reused.
        'atr_sections' => [
            'type'    => 'sections',
            'title'   => 'Dashboard tiles',
            'label'   => 'Dashboard tiles',
            'default' => '',
            'tooltip' => 'Drag to reorder, switch a block off to hide it, and choose which column it sits in. Full width spans the page above the split; Main column is the wide left stack and Side column the narrow right one. Reordering moves a block within its own column. Leave blank for the built-in arrangement. Every block can be coloured and takes a solid, wash or gradient fill.',
            'sections' => [
                'services'      => ['label' => 'Services',          'w' => '2/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass.',
                                    ]],
                'domains'       => ['label' => 'Domains',           'w' => '2/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass.',
                                    ]],
                // listToggle only on Billing, for bento's reason: it is the one
                // collection whose headline is an ACCOUNT TOTAL rather than a
                // count of the rows beneath it, so it still says something true
                // with nothing listed. A Services block with no rows is a number.
                'invoices'      => ['label' => 'Recent invoices',   'w' => '2/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'listToggle' => [
                                        'label' => 'Show the invoice list',
                                        'hint'  => 'Off, the block stays an aggregate: what is owed and how overdue the worst of it is. The full history is a click away either way.',
                                    ],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Number, date and amount only, with no second line.',
                                    ]],
                'announcements' => ['label' => 'Announcements',     'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Title only, with no date line.',
                                    ]],
                // A panel, not a collection: it renders NOTHING when nothing is
                // due, so its hide-when-empty switch is inert by design. Same
                // precedent as bento's attention strip.
                'unpaid'        => ['label' => 'Amount due',        'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'credit'        => ['label' => 'Account credit',    'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'tickets'       => ['label' => 'Support',           'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Subject and status only, with no ticket number line.',
                                    ]],
                'actions'       => ['label' => 'Quick actions',     'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
            ],

            'paints' => [
                // ROLE colours, first because they are the ones that answer
                // "make this block follow the style". A preset writes accent,
                // accent hover, accent tint and link -- so these two are the
                // pair that moves when a preset is switched: the ACTIVE one and
                // its quiet counterpart. Neutral is the style's own muted
                // surface, which also flips with dark mode.
                'accent' => ['label' => 'Accent (active)',   'var' => '--color-accent',            'track' => 'preset'],
                // Passive is DERIVED from the accent rather than pointing at
                // --color-accent-light: that token is an 8%-alpha tint meant to
                // sit behind text, so as a block fill it is barely a colour and,
                // being translucent, would let the page show through a solid.
                // 'mix' is the same figure the CSS uses, declared here so the
                // admin swatch can compute the identical value.
                'quiet'  => ['label' => 'Accent (passive)',  'var' => '--color-accent', 'track' => 'preset',
                             'mix'   => 45, 'mixWith' => '--color-surface'],
                'neutral'=> ['label' => 'Neutral',           'var' => '--color-surface-secondary', 'track' => 'token'],
                'indigo' => ['label' => 'Indigo',          'var' => '--color-icon-indigo', 'track' => 'token'],
                'purple' => ['label' => 'Purple',          'var' => '--color-icon-purple', 'track' => 'token'],
                'green'  => ['label' => 'Green',           'var' => '--color-icon-green', 'track' => 'token'],
                'teal'   => ['label' => 'Teal',            'var' => '--color-icon-teal', 'track' => 'token'],
                'orange' => ['label' => 'Orange',          'var' => '--color-icon-orange', 'track' => 'token'],
                'red'    => ['label' => 'Red',             'var' => '--color-icon-red', 'track' => 'token'],
                'gray'   => ['label' => 'Gray',            'var' => '--color-icon-gray', 'track' => 'token'],
                'block1' => ['label' => 'Block accent 1',  'var' => '--color-block-1', 'track' => 'token'],
                'block2' => ['label' => 'Block accent 2',  'var' => '--color-block-2', 'track' => 'token'],
                'block3' => ['label' => 'Block accent 3',  'var' => '--color-block-3', 'track' => 'token'],
                    ],

            'rowsControl' => [
                'label' => 'Items shown',
                'hint'  => 'How many rows this block lists before its View all link takes over. Leave blank to use the page default. A block in the narrow column can be given fewer so the two stacks stay even.',
                'min'   => 1,
                'max'   => 8,
                'def'   => 4,
            ],

            // Relabelled from bento's grid fractions: in atrium a width picks a
            // COLUMN, and calling it "Two thirds" would suggest a size.
            'widths' => [
                '1/1' => 'Full width',
                '2/3' => 'Main column',
                '1/3' => 'Side column',
            ],
        ],
    ],
];
