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
