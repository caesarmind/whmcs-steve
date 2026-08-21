<?php
/**
 * Layout schema — page-structure DIMENSIONS for the admin Layouts page
 * (LayoutsController::buildSizeRows) and the render-time emitter
 * (Hooks::buildLayoutHead). Mirrors core/config/buttons.php but px-only:
 * layout widths/heights have no "scale", so plain pixel inputs are the natural
 * control (this is geometry, not typography). Distinct from the Colors panel
 * (colours only) — no overlap.
 *
 * NAVIGATION GEOMETRY LIVES HERE, and that is not an arbitrary filing choice.
 * A standalone Navigation panel existed once and was deleted in ee9b6ef:
 *
 *     "NAVIGATION: removed. Pure duplication -- its colours are the 11
 *      --sidebar-* tokens plus --topbar-bg in Colors, its geometry is
 *      --sidebar-width and --topbar-height in Layout. A third panel writing
 *      --sidebar-bg into the same row the Colors panel edits is a double-edit
 *      bug, not a feature."
 *
 * So Hadrian files controls BY TYPE, never by page area: every nav height,
 * width, icon size and logo size belongs in this file; nav COLOUR belongs in
 * colors.php ("Navigation & bars", 16 rows); nav TYPE belongs in
 * typography.php. Before adding a row here, check the var against colors.php,
 * typography.php, general.php, buttons.php, forms.php and elements.php — if it
 * is editable there, it does not go here at any price.
 *
 * Group names below are for READING this file. The admin does not render them:
 * LayoutsController derives each row's "Applies to the Sidebar and Icon Rail
 * layouts" caption from which manifests declare the var in their `sizes` array
 * (core/layouts/main-menu/<name>/layout.php), so a row only appears once some
 * layout claims it, and the caption cannot go stale when a layout is added.
 *
 * GLOBAL (site-wide); emitted into :root. Every `default` MUST mirror the
 * matching token in assets/css/core-theme.css — except --tbm-bar-height, which
 * is declared in core/layouts/main-menu/topbar-minimal/layout.css so that the
 * example layout stays deletable without leaving a dangling core token.
 */
return [
    'sizeMin' => 0,
    'sizeMax' => 4000,
    'sizeGroups' => [
        'Content' => [
            ['var' => '--content-max-width', 'label' => 'Max width', 'type' => 'px', 'default' => 1120],
            ['var' => '--content-pad-x',     'label' => 'Padding X', 'type' => 'px', 'default' => 48],
        ],
        'Sidebar & topbar' => [
            ['var' => '--sidebar-width', 'label' => 'Sidebar width', 'type' => 'px', 'default' => 260],
            // Sizes .ph-side-topbar-inner, the bar header.tpl renders for every
            // layout except `top`. It used to reach only core-theme.css's
            // .topbar, which no template emits — so this field moved nothing at
            // all until core-layout.css was wired to it.
            ['var' => '--topbar-height', 'label' => 'Topbar height', 'type' => 'px', 'default' => 44],
        ],

        /* Shared by all four main-menu layouts. Four separate CSS rules shipped
           the same 28px (sidebar brand, rail mark, top-nav logo, minimal bar),
           so this is one control rather than four that drift apart. */
        'Navigation - all layouts' => [
            ['var' => '--nav-logo-height', 'label' => 'Logo height', 'type' => 'px', 'default' => 28],
        ],

        /* The coloured tile behind a menu icon and the glyph inside it. The
           sidebar's rule lives in core-theme.css and the rail's in
           core-layout.css, with identical literals — one token each, wired in
           both files. The top layout's inline icon has no tile and is its own
           row below; Topbar Minimal renders no icons at all, so it declares
           neither. */
        'Menu icons - sidebar and rail' => [
            ['var' => '--nav-icon-size',  'label' => 'Menu icon tile',  'type' => 'px', 'default' => 26],
            ['var' => '--nav-icon-glyph', 'label' => 'Menu icon glyph', 'type' => 'px', 'default' => 15],
        ],

        /* Rail only. --rail-width has FIVE consumers: the rail, both content
           gutters (left and right-hand mount) and the flyout's leading edge.
           They are wired together on purpose — the flyout must stay edge-
           adjacent to the rail or initRail()'s hover bridge breaks. */
        'Icon Rail layout' => [
            ['var' => '--rail-width',       'label' => 'Rail width',        'type' => 'px', 'default' => 80],
            ['var' => '--rail-panel-width', 'label' => 'Rail flyout width', 'type' => 'px', 'default' => 240],
        ],

        /* Top-nav only, and deliberately NOT --topbar-height: this layout does
           not render the inner topbar, and .homepage-nav-inner has always been
           its own 44px literal. The product subnav and the mega-menu both hang
           off this height, so all three move together. */
        'Top Navigation layout' => [
            ['var' => '--topnav-height',    'label' => 'Top nav height', 'type' => 'px', 'default' => 44],
            ['var' => '--topnav-icon-size', 'label' => 'Top nav icon',   'type' => 'px', 'default' => 14],
        ],

        /* Topbar Minimal only. One number, two consumers: the fixed bar and the
           page's top padding, which must stay equal or the content slides under
           the bar. Default mirrors that layout's own layout.css, not
           core-theme.css — see the header note. */
        'Topbar Minimal layout' => [
            ['var' => '--tbm-bar-height', 'label' => 'Minimal bar height', 'type' => 'px', 'default' => 52],
        ],
    ],
];
