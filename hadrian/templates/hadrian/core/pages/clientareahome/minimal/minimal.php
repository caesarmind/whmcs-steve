<?php
/**
 * Variant meta for clientareahome/minimal.
 *
 * Read by:
 *   - Template::getPageVariants  -> label + description in the admin Pages picker
 *   - Template::getVariantMeta   -> this variant's own 'supportedOptions'
 *   - Hooks::resolveCurrentPage  -> `fullPage` (false here: this variant keeps
 *                                   the portal nav, sidebar/rail and footer)
 *
 * The filename MUST match the directory name (minimal/minimal.php beside
 * minimal/minimal.tpl) or the variant is silently skipped with no admin card
 * and no error. There is deliberately no pageoption.php: nothing in the addon
 * reads that file.
 *
 * OPTIONS ARE VARIANT-SCOPED. The sections below are this template's blocks --
 * they only mean anything to minimal.tpl, which renders them. A sibling
 * template has a different design and a different running order, so it
 * declares its own set (or none) and the editor shows only the selected
 * template's. Stored namespaced as `<key>@minimal`, so switching template and
 * saving never disturbs another template's arrangement.
 */
return [
    'name'        => 'Minimal',
    'description' => 'A quieter dashboard: greeting, four summary tiles, quick actions, then services, domains, invoices, tickets and announcements as plain rows on one surface. No panel grid or account sub-nav aside.',
    'fullPage'    => false,

    // Read in minimal.tpl as $hadrian.pages.clientareahome.options.<key>.
    // Hooks flattens the active variant's namespaced values onto the bare key,
    // so the template never sees the namespace. The stored array is taken raw
    // with no default merge, so every template read carries its own |default:
    // matching the value declared here.
    'supportedOptions' => [
        'min_section_titles' => [
            'type'    => 'select',
            'label'   => 'Section titles',
            'default' => 'outside',
            'options' => ['outside', 'inside'],
            'tooltip' => 'Outside floats each section label on the page background above its list. Inside turns the label row into a card header joined to the list below it.',
        ],
        'min_visible_rows' => [
            'type'    => 'int',
            'label'   => 'Rows before "Show more"',
            'default' => 5,
            'tooltip' => 'How many rows each list shows before the rest collapse behind a Show more control. The lists hold at most 8 rows; the full set lives on each section\'s own page.',
        ],
        'min_search_at' => [
            'type'    => 'int',
            'label'   => 'Search box after N rows',
            'default' => 8,
            'tooltip' => 'Services and Domains grow their own filter box once they reach this many rows. Only those two: the other lists are read newest-first, where a filter is noise. Every dashboard list holds at most 8 rows, so useful values are 1 to 8 and anything higher never triggers. Set to 0 to switch the filter off.',
        ],
        'min_profile_inline' => [
            'type'    => 'bool',
            'label'   => 'Profile beside the title',
            'default' => false,
            'tooltip' => 'Shows a compact profile strip in line with the page heading: avatar, name, location, and shortcuts to account details and security. Independent of the Profile block, which is a full panel in the grid below.',
        ],
        'min_show_actions' => [
            'type'    => 'bool',
            'label'   => 'Show quick actions',
            'default' => true,
            'tooltip' => 'The Order a service / Register a domain / Open a ticket row under the summary tiles. Shown on empty accounts too, which need it most.',
        ],

        // Which sections appear, in what order, and how wide.
        //
        // Type 'sections' is unknown to both the editor view and the save path,
        // and that is deliberate: edit.tpl falls through to its catch-all text
        // input and the save path stores it via the match()'s default arm, so
        // no admin-addon PHP had to change to add it. The editor then
        // progressively enhances that input into a drag-to-reorder builder;
        // with JS off the raw string stays editable.
        //
        // BLANK MEANS "built-in arrangement", not "no sections" -- see
        // SectionLayout::parse. That keeps every install on the classic layout
        // until someone deliberately changes it.
        //
        // 'sections' is the catalogue: admin label + factory width, in factory
        // order. A key added here also needs an arm in minimal/rows.tpl and in
        // the whitelist in minimal.tpl, or it renders as an empty card.
        'min_sections' => [
            'type'    => 'sections',
            'title'   => 'Dashboard sections',
            'label'   => 'Dashboard sections',
            'default' => '',
            'tooltip' => 'Drag to reorder, switch a section off to hide it, and set each one to full, two thirds, one half or one third width. Widths run on a six-column grid, so a row fills up when its widths add to a whole. Leave blank for the built-in arrangement.',
            'sections' => [
                'services'      => ['label' => 'Services',        'w' => '1/1'],
                'domains'       => ['label' => 'Domains',         'w' => '1/1'],
                'invoices'      => ['label' => 'Recent invoices', 'w' => '1/2'],
                'tickets'       => ['label' => 'Support',         'w' => '1/2'],
                'announcements' => ['label' => 'Announcements',   'w' => '1/2'],
                // optIn: appended SWITCHED OFF to layouts saved before these
                // existed, so an arranged dashboard never gains blocks on its
                // own. They show in the builder ready to be turned on.
                // paintable: offers the colour control in the settings drawer.
                // The list sections do not -- their rows carry status pills and
                // token-coloured text that a saturated fill would wreck.
                'domainreg'     => ['label' => 'Register a domain', 'w' => '1/2', 'optIn' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
                'profile'       => ['label' => 'Profile',           'w' => '1/2', 'optIn' => true, 'paintable' => true, 'fills' => ['solid', 'tint', 'grad']],
            ],

            // Colours a block may be painted with: the palette keys the theme
            // already ships, plus the three free slots a buyer sets on
            // Styles > Colors. Keys are matched against this list in
            // SectionLayout::parse -- an unlisted one is dropped rather than
            // reaching the CSS. APPEND ONLY: removing a key silently strips
            // that colour from any layout using it on the next save.
            //
            // RESERVED: no key here may ever match /^hex[0-9a-f]{6}$/. That
            // pattern is the OTHER colour vocabulary -- a one-off value that
            // deliberately does not follow Styles > Colors -- and the admin's
            // Theme/Custom switch derives which mode a block is in by testing
            // the stored paint against exactly these two vocabularies. A key
            // that matched both would make the mode ambiguous.
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
            'widths' => [
                '1/1' => 'Full width',
                '2/3' => 'Two thirds',
                '1/2' => 'One half',
                '1/3' => 'One third',
            ],
        ],
    ],
];
