<?php
/**
 * Variant meta for clientareahome/bento.
 *
 * Read by:
 *   - Template::getPageVariants  -> label + description in the admin Pages picker
 *   - Template::getVariantMeta   -> this variant's own 'supportedOptions'
 *   - Hooks::resolveCurrentPage  -> `fullPage` (false: keeps nav, sidebar, footer)
 *
 * The filename MUST match the directory name (bento/bento.php beside
 * bento/bento.tpl) or the variant is silently skipped -- no admin card, no
 * error anywhere. There is deliberately no pageoption.php: nothing reads it.
 *
 * OPTIONS ARE VARIANT-SCOPED, stored as `<key>__bento`, so arranging the bento
 * grid never disturbs the minimal one and vice versa. The `bnt_` prefix is not
 * decoration: Hooks falls back to the un-namespaced key for options that used
 * to be page-scoped, so reusing `min_sections` here would let an install that
 * saved the pre-namespacing bare key inherit minimal's arrangement into bento.
 */
return [
    'name'        => 'Bento',
    'description' => 'A bento grid of self-contained cards. Each collection gets its own tile with a count and its rows, arranged two-up on a six-column grid. Adds an attention strip that pulls the few things needing action out of the many rows, and an identity card beside the greeting.',
    'fullPage'    => false,

    // Read in bento.tpl as $hadrian.pages.clientareahome.options.<key>.
    // Hooks flattens the active variant's namespaced values onto the bare key,
    // so the template never sees the namespace. The stored array is taken raw
    // with no default merge, so every template read carries its own |default:
    // matching the value declared here.
    'supportedOptions' => [
        'bnt_section_titles' => [
            'type'    => 'select',
            'label'   => 'Tile titles',
            'default' => 'inside',
            'options' => ['inside', 'outside'],
            'tooltip' => 'Inside keeps each tile self-contained: its label and count sit on the card, which is how the bento grid was drawn. Outside floats them on the page background above the card, so a row of tiles reads as a set of labelled groups rather than a set of boxes.',
        ],
        'bnt_account' => [
            'type'    => 'bool',
            'label'   => 'Identity card beside the greeting',
            'default' => true,
            'tooltip' => 'Surfaces the account name and shortcuts to details, security and payment methods as a small card in line with the page heading. Independent of the Profile block, which is a full tile in the grid below.',
        ],
        'bnt_visible_rows' => [
            'type'    => 'int',
            'label'   => 'Items shown per tile',
            'default' => 4,
            'tooltip' => 'The default number of items a tile lists. Bento has no Show more control -- a tile shows this many and its View all link goes to the full page -- so this is a real cap, not a fold. Each tile can override it in its own settings under Dashboard tiles. Tiles hold at most 8 items.',
        ],
        'bnt_search_at' => [
            'type'    => 'int',
            'label'   => 'Search box after N rows',
            'default' => 8,
            'tooltip' => 'Services and Domains grow their own filter box once they reach this many rows. Only those two: the other collections are read newest-first, where a filter is noise. Every dashboard tile holds at most 8 rows, so useful values are 1 to 8 and anything higher never triggers. Set to 0 to switch the filter off.',
        ],

        // Which tiles appear, in what order, and how wide.
        //
        // BLANK MEANS "built-in arrangement" (see SectionLayout::parse), which
        // for bento is the pairing below: a wide tile beside a narrow one, three
        // rows deep, then the identity tile across the full width.
        //
        // No 'optIn' entries here. Unlike minimal -- where Register and Profile
        // were added to a shipped design after the fact and so had to arrive
        // switched off -- both are part of bento's arrangement from the start.
        // Hooks::dashboardMentions has a matching arm: a bento install with no
        // saved layout is treated as mentioning both, or the Register tile would
        // render with no prices and the Profile tile with no country line.
        'bnt_sections' => [
            'type'    => 'sections',
            'title'   => 'Dashboard tiles',
            'label'   => 'Dashboard tiles',
            'default' => '',
            'tooltip' => 'Drag to reorder, switch a tile off to hide it, and set each one to full, two thirds, one half or one third width. Widths run on a six-column grid, so a row fills up when its widths add to a whole. Leave blank for the built-in arrangement. Every tile can be coloured and takes a solid, wash or gradient fill.',
            'sections' => [
                // A banner, not a collection: no rows, no empty state, and it
                // renders nothing at all when there is nothing to act on. It is
                // in the catalogue so it can be reordered, resized and switched
                // off from the same place as everything else.
                //
                // prepend puts it at the TOP of a layout saved before it moved
                // here. It used to sit above the grid unconditionally, so
                // appending it last would look like a regression rather than a
                // new block.
                'attention'     => ['label' => 'Needs your attention', 'w' => '1/1', 'prepend' => true,
                                    'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'services'      => ['label' => 'Services',          'w' => '2/3', 'rows' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass, for an account with a lot of them or a tile that has to sit in a narrow column.',
                                    ]],
                'domains'       => ['label' => 'Domains',           'w' => '1/3', 'rows' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass, for an account with a lot of them or a tile that has to sit in a narrow column.',
                                    ]],
                // listToggle puts a per-block switch in this section's own
                // settings drawer, stored as the 'l' flag. Only Billing
                // declares it: it is the one collection whose headline is an
                // ACCOUNT TOTAL rather than a count of the rows beneath it, so
                // it still says something true with nothing listed. A Services
                // tile with no rows would just be a number.
                'invoices'      => ['label' => 'Billing',           'w' => '1/3', 'rows' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'listToggle' => [
                                        'label' => 'Show the invoice list',
                                        'hint'  => 'Off, the tile stays an aggregate: what you owe, how much of it is overdue and by how long, one Pay all button, and any credit that comes off first. The full history is a click away on the invoices page either way.',
                                    ],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass, for an account with a lot of them or a tile that has to sit in a narrow column.',
                                    ]],
                'tickets'       => ['label' => 'Support',           'w' => '2/3', 'rows' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass, for an account with a lot of them or a tile that has to sit in a narrow column.',
                                    ]],
                'announcements' => ['label' => 'Announcements',     'w' => '2/3', 'rows' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad'],
                                    'rowsCompact' => [
                                        'label' => 'Compact rows',
                                        'hint'  => 'Name and status only, with no second line. A dense list you can scan in one pass, for an account with a lot of them or a tile that has to sit in a narrow column.',
                                    ]],
                'domainreg'     => ['label' => 'Register a domain', 'w' => '1/3', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'profile'       => ['label' => 'Profile',           'w' => '1/1', 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
            ],

            // Colours a tile may be painted with: the palette keys the theme
            // already ships, plus the three free slots a buyer sets on
            // Styles > Colors. Matched against this list in SectionLayout::parse
            // -- an unlisted one is dropped rather than reaching the CSS.
            // APPEND ONLY: removing a key silently strips that colour from any
            // layout using it on the next save.
            //
            // RESERVED: no key here may ever match /^hex[0-9a-f]{6}$/. That
            // pattern is the OTHER colour vocabulary -- a one-off value that
            // deliberately does not follow Styles > Colors -- and the admin's
            // Theme/Custom switch derives which mode a block is in by testing
            // the stored paint against exactly these two vocabularies. A key
            // that matched both would make the mode ambiguous.
            //
            // Every tile is paintable, and every tile takes all three fills --
            // the attention strip included. Its chips are tinted the same way
            // status pills are, so it needed the same treatment on a saturated
            // fill; see the note beside those rules in the stylesheet.
            // The list tiles were wash-only until the pill treatment landed:
            // a .status-pill is a 10%-alpha background, so on a solid fill an
            // Active badge measured 1.05:1. pages/clientareahome.css now gives
            // pills a near-opaque light chip with authored dark ink whenever
            // the tile is solid or gradient, so the badge stays legible on any
            // colour and the restriction is no longer needed.
            // 'track' says what a key FOLLOWS, which is the whole reason to
            // store a key rather than a value:
            //   preset - the Styles > Colors presets set this token, so picking
            //            a preset recolours every block using it. Only the
            //            accent qualifies: a preset writes accent, accent
            //            hover, accent tint and link, and nothing else.
            //   token  - follows its own token on Styles > Colors. Editing that
            //            row recolours the block; switching preset does not
            //            touch it.
            // A custom colour follows neither, which is what it is for.
            //
            // 'var' is the CSS token each key resolves to at render time --
            // the same mapping the .min-section[data-blk-paint="..."] rules use.
            // Declared here so the admin can draw a real swatch: PagesController
            // resolves the token through core/config/colors.php plus whatever
            // the buyer overrode on Styles > Colors, so the chip in the picker
            // is the colour the block will actually be, not a hardcoded guess
            // that drifts the moment someone changes the palette.
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
            // Turns on the per-section "Items shown" control in the builder's
            // settings drawer, stored as the 5th field of each layout entry.
            // Declared here rather than assumed by the builder because it only
            // makes sense for a variant with no Show more: minimal reveals the
            // rest in place, where a per-section cap would mean something else.
            // Blank leaves a tile on bnt_visible_rows.
            //
            // max is 8 on purpose -- the hook caps every collection at
            // DASHBOARD_ROWS (8), so a larger number could never render.
            'rowsControl' => [
                'label' => 'Items shown',
                'hint'  => 'How many rows this tile lists before its View all link takes over. Leave blank to use the page default. A narrow tile beside a tall one can be given fewer, so a row of tiles stays even.',
                'min'   => 1,
                'max'   => 8,
                'def'   => 4,
            ],

            'widths' => [
                '1/1' => 'Full width',
                '2/3' => 'Two thirds',
                '1/2' => 'One half',
                '1/3' => 'One third',
            ],
        ],
    ],
];
