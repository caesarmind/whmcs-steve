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
        'bnt_attention' => [
            'type'    => 'bool',
            'label'   => 'Attention strip',
            'default' => true,
            'tooltip' => 'A row of chips above the grid summarising what needs action: invoices outstanding, with the amount, and domains expiring in the next 45 days. Each chip is dropped when its count is zero, and the whole strip disappears when there is nothing to act on. The counts are account totals, not a count of the rows on this page, so they are exact.',
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
            'tooltip' => 'Drag to reorder, switch a tile off to hide it, and set each one to full, two thirds, one half or one third width. Widths run on a six-column grid, so a row fills up when its widths add to a whole. Leave blank for the built-in arrangement. Note that tiles holding a list always show their colour as a soft wash, so the status badges on each row stay readable; Register a domain and Profile can take a solid or gradient fill.',
            'sections' => [
                'services'      => ['label' => 'Services',          'w' => '2/3', 'paintable' => true, 'fills' => ['tint']],
                'domains'       => ['label' => 'Domains',           'w' => '1/3', 'paintable' => true, 'fills' => ['tint']],
                'invoices'      => ['label' => 'Billing',           'w' => '1/3', 'paintable' => true, 'fills' => ['tint']],
                'tickets'       => ['label' => 'Support',           'w' => '2/3', 'paintable' => true, 'fills' => ['tint']],
                'announcements' => ['label' => 'Announcements',     'w' => '2/3', 'paintable' => true, 'fills' => ['tint']],
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
            // Every tile is paintable here, unlike minimal -- but a LIST tile
            // only ever renders the colour as a wash, whatever fill is stored.
            // Its rows carry status pills, and a pill is a 10%-alpha background
            // over whatever is behind it, so a saturated fill turns an Active
            // badge into 1.05:1 contrast. cell.tpl coerces it; see the note
            // there. Register and Profile have no pills and take all three.
            // 'var' is the CSS token each key resolves to at render time --
            // the same mapping the .min-section[data-blk-paint="..."] rules use.
            // Declared here so the admin can draw a real swatch: PagesController
            // resolves the token through core/config/colors.php plus whatever
            // the buyer overrode on Styles > Colors, so the chip in the picker
            // is the colour the block will actually be, not a hardcoded guess
            // that drifts the moment someone changes the palette.
            'paints' => [
                'accent' => ['label' => 'Accent',          'var' => '--color-accent'],
                'indigo' => ['label' => 'Indigo',          'var' => '--color-icon-indigo'],
                'purple' => ['label' => 'Purple',          'var' => '--color-icon-purple'],
                'green'  => ['label' => 'Green',           'var' => '--color-icon-green'],
                'teal'   => ['label' => 'Teal',            'var' => '--color-icon-teal'],
                'orange' => ['label' => 'Orange',          'var' => '--color-icon-orange'],
                'red'    => ['label' => 'Red',             'var' => '--color-icon-red'],
                'gray'   => ['label' => 'Gray',            'var' => '--color-icon-gray'],
                'block1' => ['label' => 'Block accent 1',  'var' => '--color-block-1'],
                'block2' => ['label' => 'Block accent 2',  'var' => '--color-block-2'],
                'block3' => ['label' => 'Block accent 3',  'var' => '--color-block-3'],
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
