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
    ],
];
