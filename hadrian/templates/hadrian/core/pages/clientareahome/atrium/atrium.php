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
        // The band's three appearance controls. DECLARED here so the page form
        // stores them the ordinary way, and marked inBlock so that row is
        // hidden and the control re-presented in the Welcome band's drawer --
        // where an admin looks for something that describes the band. One
        // control, one stored value, shown where it belongs.
        'atr_hero_style' => [
            'type'    => 'select',
            'label'   => 'Band style',
            'default' => 'gradient',
            'options' => ['gradient', 'solid', 'soft', 'plain'],
            'inBlock' => 'hero',
            // Files this control under Colour & style in the block drawer rather
            // than Content & behaviour, which is where an inBlock option lands
            // by default. It describes how the panel is FILLED, so it belongs
            // beside the colour source and the fill.
            'group'   => 'colour',
            'tooltip' => 'Gradient is the shipped look: the accent deepened at one end and lightened at the other. Solid is a flat accent panel. Soft is a pale tint with dark text, for a lighter page. Plain drops the panel and sets the greeting on the page background.',
        ],
        'atr_hero_width' => [
            'type'    => 'select',
            'label'   => 'Band width',
            'default' => 'boxed',
            'options' => ['boxed', 'edge'],
            'inBlock' => 'hero',
            'tooltip' => 'Boxed keeps the band inside the content column. Edge runs it to the full width of the content area with the text still aligned to the column, which reads as a header rather than a card.',
        ],
        'atr_hero_actions' => [
            'type'    => 'select',
            'label'   => 'Band buttons',
            'default' => 'right',
            'options' => ['right', 'below', 'off'],
            'inBlock' => 'hero',
            'tooltip' => 'Right places Pay balance and Order a service opposite the greeting. Below stacks them under it, for a narrow content column. Off hides them; the same actions are reachable from the blocks underneath.',
        ],

        'atr_hero_size' => [
            'type'    => 'select',
            'label'   => 'Band height',
            'default' => 'full',
            'options' => ['full', 'slim'],
            'inBlock' => 'hero',
            'tooltip' => 'Full is the shipped band: date, greeting and a line of copy. Slim drops the copy line and tightens the padding to a one-line bar -- the date and greeting on the left, buttons or the avatar on the right. Useful when the figures and blocks below are what the page is really for.',
        ],

        'atr_hero_profile' => [
            'type'    => 'select',
            'label'   => 'Band profile',
            'default' => 'off',
            'options' => ['off', 'avatar'],
            'inBlock' => 'hero',
            'tooltip' => 'Avatar puts the account monogram at the right of the band, opening the same account menu the topbar and sidebar use -- details, users, payment methods, contacts, security and log out. It sits after the buttons, so set Band buttons to off if you want the profile alone.',
        ],

        'atr_section_titles' => [
            'type'    => 'select',
            'label'   => 'Block titles',
            'default' => 'inside',
            'options' => ['inside', 'outside'],
            'tooltip' => 'Inside keeps each block self-contained: its label sits on the card, which is how the dashboard was drawn. Outside floats the label on the page background above the card, so a column reads as a set of labelled groups rather than a set of boxes.',
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
            // Tells the admin builder to draw its preview as a BAND over two
            // COLUMNS rather than bento's six-column grid. Without it the
            // preview shows Announcements beside Domains -- a row that can
            // never happen here, because 2/3 and 1/3 land in different stacks
            // rather than sharing a row. A preview that lies is worse than none.
            'preview' => 'columns',
            'tooltip' => 'Drag to reorder, switch a block off to hide it, and choose which column it sits in. Full width spans the page above the split; Main column is the wide left stack and Side column the narrow right one. Reordering moves a block within its own column. Leave blank for the built-in arrangement. Every block can be coloured and takes a solid, wash or gradient fill.',
            'sections' => [
                // The band and the figure strip are blocks like any other, so
                // they reorder, hide, resize and paint from the same place.
                // Both are 1/1: neither makes sense in a column, and the
                // template only reads 1/1 as "the band above the split".
                //
                // prepend puts them at the TOP of a layout saved before they
                // moved here -- they used to render unconditionally above the
                // body, so appending them last would read as a regression
                // rather than as new blocks. Same reason bento's attention
                // strip carries it.
                // The band's appearance belongs to the band, so its three
                // controls live in its own drawer beside its width and colour.
                // They are 'selects' rather than switches: a flag letter is a
                // boolean, and these each pick one of three or four looks.
                'hero'          => ['label' => 'Welcome band',    'w' => '1/1', 'prepend' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
],
                // The four figures are switches on THIS block rather than page
                // options: they describe the strip, the way its width and its
                // order do, so they belong in its own drawer. Stored as flag
                // letters, which is why the labels are positive while the flag
                // is negative -- a flag is absent by default, and a control
                // labelled for what it turns ON is the one an admin can
                // predict. The strip is one block rather than four because the
                // layout DSL has no 1/4 token and six columns cannot express
                // quarters: four 1/3 entries would span 8 and wrap 3+1.
                'stats'         => ['label' => 'Summary figures', 'w' => '1/1', 'prepend' => true,
                                    'switches' => [
                                        's' => ['label' => 'Figure: active services', 'invert' => true,
                                                'hint'  => 'Counts active services on the account, not the rows listed below.'],
                                        'd' => ['label' => 'Figure: domains', 'invert' => true,
                                                'hint'  => 'Counts active domains, with a sub-line for any expiring within 45 days.'],
                                        'b' => ['label' => 'Figure: unpaid invoices', 'invert' => true,
                                                'hint'  => 'How many invoices are unpaid, counted like the figures beside it. The total owed sits on its sub-line, and how overdue the worst one is replaces that whenever something actually is overdue.'],
                                        't' => ['label' => 'Figure: open tickets', 'invert' => true,
                                                'hint'  => 'Open tickets, with a sub-line for any where staff have replied and are waiting on the client.'],
                                        // NOT inverted, unlike the four above. The strip ships
                                        // compact -- label and number only -- so this flag turns
                                        // detail ON. Absent by default, which is what makes
                                        // compact the default for layouts saved before it existed.
                                        'f' => ['label' => 'Sub-lines under each figure',
                                                'hint'  => 'Adds the second line under a figure when there is something to say: domains expiring within 45 days, how overdue the worst invoice is, tickets awaiting a reply. Off keeps every tile to a label and a number, which is the shorter strip the dashboard was drawn with.'],
                                    ]],
                'services'      => ['label' => 'Services',          'w' => '2/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass.',
                                    ]],
                'domains'       => ['label' => 'Domains',           'w' => '2/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass.',
                                    ]],
                // listToggle only on Billing, for bento's reason: it is the one
                // collection whose headline is an ACCOUNT TOTAL rather than a
                // count of the rows beneath it, so it still says something true
                // with nothing listed. A Services block with no rows is a number.
                'invoices'      => ['label' => 'Recent invoices',   'w' => '2/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'listToggle' => [
                                        'label' => 'Show the invoice list',
                                        'hint'  => 'Off, the block stays an aggregate: what is owed and how overdue the worst of it is. The full history is a click away either way.',
                                    ],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Number, date and amount only, with no second line.',
                                    ]],
                'announcements' => ['label' => 'Announcements',     'w' => '1/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Title only, with no date line.',
                                    ]],
                // A panel, not a collection: it renders NOTHING when nothing is
                // due, so its hide-when-empty switch is inert by design. Same
                // precedent as bento's attention strip.
                'unpaid'        => ['label' => 'Amount due',        'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'credit'        => ['label' => 'Account credit',    'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                // A real WHMCS feature, not a dashboard invention: these are the
                // saved methods from Billing -> Payment Methods, and the reason
                // to surface them is the expiry -- a card that lapses is a failed
                // renewal nobody sees coming.
                'payments'      => ['label' => 'Payment methods',   'w' => '1/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Drops the second line, leaving the card name and whether it is the default or has expired.',
                                    ]],
                'tickets'       => ['label' => 'Support',           'w' => '1/3', 'list' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Subject and status only, with no ticket number line.',
                                    ]],
                // The four links are switchable, same as the summary figures:
                // labelled for what they turn ON and inverted for storage, so
                // all four ship on and a layout saved before this existed keeps
                // showing them. Turning every one off leaves the card with its
                // heading and nothing under it, which the template guards.
                'actions'       => ['label' => 'Quick actions',     'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'switches' => [
                                        'o' => ['label' => 'Link: order a service', 'invert' => true,
                                                'hint'  => 'Opens the order form at the product catalogue.'],
                                        'r' => ['label' => 'Link: register a domain', 'invert' => true,
                                                'hint'  => 'Opens the order form at domain registration. Worth turning off on an install that does not sell domains.'],
                                        'k' => ['label' => 'Link: open a ticket', 'invert' => true,
                                                'hint'  => 'Goes to the support ticket form.'],
                                        'p' => ['label' => 'Link: account details', 'invert' => true,
                                                'hint'  => 'Goes to the profile page, where contact details and billing address are edited.'],
                                    ]],
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
