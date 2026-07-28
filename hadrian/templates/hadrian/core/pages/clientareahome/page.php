<?php
/**
 * Page-level metadata for clientareahome.
 *
 * Read by:
 *   - PageController (admin UI for selecting variants and editing pageoptions)
 *   - Hooks::resolveCurrentPage at render time
 */
return [
    'display_name' => 'Dashboard',
    'group'        => 'Client Area',
    'type'         => 'client-portal',
    'listDisplay'  => true,
    'description'  => 'Logged-in client home page with widgets, alerts, and quick links.',

    // Page-scoped options: the editor shows all of these whichever variant is
    // selected. Read at render time as
    // $hadrian.pages.clientareahome.options.<key> - NOT .config.<key>, which
    // resolveCurrentPage never builds (every .config. read silently returns
    // null). The stored array is taken raw, so each template read must carry
    // its own |default: matching the value declared here.
    //
    // Consumed today by core/pages/clientareahome/minimal/minimal.tpl. The
    // 'default' variant hardcodes its own layout switches inline and reads none
    // of these.
    //
    // Do NOT add a key named full_page: resolveCurrentPage treats that name
    // specially and would suppress the nav, sidebar, breadcrumb and footer.
    'supportedOptions' => [
        'min_section_titles' => [
            'type'    => 'select',
            'label'   => 'Section titles (Minimal)',
            'default' => 'outside',
            'options' => ['outside', 'inside'],
            'tooltip' => 'Outside floats each section label on the page background above its list. Inside turns the label row into a card header joined to the list below it.',
        ],
        'min_visible_rows' => [
            'type'    => 'int',
            'label'   => 'Rows before "Show more" (Minimal)',
            'default' => 5,
            'tooltip' => 'How many rows each dashboard list shows before the rest collapse behind a Show more control. The lists themselves hold at most 8 rows; the full set lives on each section\'s own page.',
        ],
        'min_show_actions' => [
            'type'    => 'bool',
            'label'   => 'Show quick actions (Minimal)',
            'default' => true,
            'tooltip' => 'The Order a service / Register a domain / Open a ticket row under the summary tiles. Shown on empty accounts too, which need it most.',
        ],

        // Which sections appear, in what order, and how wide.
        //
        // Type 'sections' is unknown to both the editor view and the save path,
        // and that is deliberate: edit.tpl falls through to its catch-all text
        // input, and PagesController stores it via the match()'s default arm
        // (substr($raw, 0, 500)). So no admin-addon PHP had to change. The
        // Pages editor then progressively enhances that one text input into a
        // drag-to-reorder builder; with JS off the raw string is still editable.
        //
        // BLANK MEANS "built-in arrangement", not "no sections" -- see
        // SectionLayout::parse. That is what keeps every existing install on
        // the classic layout until someone deliberately changes it.
        //
        // 'sections' is the catalogue: admin label + factory width, in factory
        // order. A key added here also needs an arm in minimal/rows.tpl and in
        // the whitelist in minimal.tpl, or it renders as an empty card.
        'min_sections' => [
            'type'    => 'sections',
            'label'   => 'Dashboard sections (Minimal)',
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
