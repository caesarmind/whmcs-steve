<?php
/**
 * Navigation schema — the GEOMETRY of the main menu, for the admin
 * Styles > Navigation panel (StylesController::buildNavigationViewModel) and
 * the render-time emitter (Hooks::buildNavigationHead). Mirrors
 * core/config/general.php in shape: px-only fields under named groups, only
 * values that differ from default are stored.
 *
 * WHY THIS IS ITS OWN PANEL (and not a group inside layout.php, where these
 * ten tokens used to live).
 *
 * A Navigation panel existed once before and was deleted in ee9b6ef, for a
 * reason worth quoting because it constrains this file:
 *
 *     "NAVIGATION: removed. Pure duplication -- its colours are the 11
 *      --sidebar-* tokens plus --topbar-bg in Colors, its geometry is
 *      --sidebar-width and --topbar-height in Layout. A third panel writing
 *      --sidebar-bg into the same row the Colors panel edits is a double-edit
 *      bug, not a feature."
 *
 * That verdict was about DUPLICATION, not about the subject. It is still
 * binding, and this file obeys it: nav COLOUR stays in colors.php
 * ("Navigation & bars", 16 rows), nav TYPE stays in typography.php, and not
 * one var listed below appears in any other core/config/*.php. The rule is
 * "a token is editable in exactly one panel", not "navigation may never have
 * a panel".
 *
 * What changed since ee9b6ef is the size of the subject. Then it was two
 * tokens; today it is ten -- four layouts' worth of widths, heights, logo and
 * icon sizing (commit 89bb019 made the last eight editable). Ten controls is
 * no longer a footnote inside a page-structure panel, and the page it was
 * borrowing (Layouts) is about CHOOSING a layout, so its Containers section
 * was answering two unrelated questions at once. layout.php keeps exactly the
 * two tokens that are genuinely page structure -- --content-max-width and
 * --content-pad-x -- and everything below moved here.
 *
 * STORAGE IS SEPARATE TOO, and that is not cosmetic. layout.php's values live
 * in `<tpl>_layout_vars`, which two writers touch:
 *   LayoutsController::saveLayoutVar  -- reads, merges ONE var, writes back
 *   (the retired) saveLayoutAction    -- rebuilt the whole blob and replaced it
 * A wholesale writer and a merging writer sharing one row is a data-loss bug
 * waiting for the second panel to be saved. This panel therefore writes
 * `<tpl>_navigation_vars`, its own row, with its own emitter -- so the two
 * panels physically cannot clobber each other no matter which order they are
 * saved in. StylesController::migrateNavigationVars folds any of these ten
 * keys found in the legacy `_layout_vars` blob across on first read, so an
 * install that already stored a sidebar width keeps it.
 *
 * GLOBAL (site-wide); emitted into :root. Every `default` MUST mirror the
 * matching token in assets/css/core-theme.css -- the admin shows the default
 * as the baseline and only persists values that DIFFER, so a drifted default
 * here makes the "is this an override?" test wrong in both directions. The one
 * exception is --tbm-bar-height, declared in
 * core/layouts/main-menu/topbar-minimal/layout.css so that the example layout
 * stays deletable without leaving a dangling core token.
 *
 * Group names below ARE rendered (as the panel's group headings, the way
 * general.php's are). The per-field "Applies to the Sidebar and Icon Rail
 * layouts" caption is NOT written here: it is derived from which layout
 * manifests name the var in their `sizes` array
 * (core/layouts/main-menu/<name>/layout.php), so it cannot go stale when a
 * layout is added, removed or dropped in by a buyer.
 */
return [
    'sizeMin' => 0,
    'sizeMax' => 4000,

    'groups' => [
        /* Cross-layout navigation dimensions.

           Logo height is shared by all four main-menu layouts: four separate
           CSS rules shipped the same 28px (sidebar brand, rail mark, top-nav
           logo, minimal bar), so this is one control rather than four that
           drift apart.

           The icon pair is the coloured tile behind a menu icon and the glyph
           inside it. The sidebar's rule lives in core-theme.css and the rail's
           in core-layout.css with identical literals -- one token each, wired
           in both files. The top layout's inline icon has no tile (its own row
           below); Topbar Minimal renders no icons at all. */
        'Shared' => [
            ['var' => '--nav-logo-height', 'label' => 'Logo height',     'type' => 'px', 'default' => 28],
            ['var' => '--nav-icon-size',   'label' => 'Menu icon tile',  'type' => 'px', 'default' => 26],
            ['var' => '--nav-icon-glyph',  'label' => 'Menu icon glyph', 'type' => 'px', 'default' => 15],
        ],

        /* Dimensions belonging to one layout each. Kept in one group because
           only the layout you actually run is relevant, and the per-field
           caption already says which that is.

           --sidebar-width sizes the sidebar. --topbar-height sizes
           .ph-side-topbar-inner, the bar header.tpl renders for every layout
           EXCEPT `top` -- so it belongs to Sidebar and Icon Rail, the opposite
           of the obvious guess. It used to reach only core-theme.css's .topbar,
           which no template emits, so the field moved nothing until
           core-layout.css was wired to it.

           --rail-width has FIVE consumers: the rail, both content gutters and
           the flyout's leading edge. They are wired together on purpose -- the
           flyout must stay edge-adjacent or initRail()'s hover bridge breaks.

           --topnav-height is deliberately NOT --topbar-height: the top layout
           renders no inner topbar, and .homepage-nav-inner has always been its
           own 44px literal. The product subnav and mega-menu hang off it, so
           all three move together.

           --tbm-bar-height is one number with two consumers: the fixed bar and
           the page's top padding, which must stay equal or content slides under
           the bar. Its default mirrors that layout's own layout.css, not
           core-theme.css -- see the header note. */
        'Per layout' => [
            ['var' => '--sidebar-width',    'label' => 'Sidebar width',      'type' => 'px', 'default' => 260],
            ['var' => '--topbar-height',    'label' => 'Topbar height',      'type' => 'px', 'default' => 44],
            ['var' => '--rail-width',       'label' => 'Rail width',         'type' => 'px', 'default' => 80],
            ['var' => '--rail-panel-width', 'label' => 'Rail flyout width',  'type' => 'px', 'default' => 240],
            ['var' => '--topnav-height',    'label' => 'Top nav height',     'type' => 'px', 'default' => 44],
            ['var' => '--topnav-icon-size', 'label' => 'Top nav icon',       'type' => 'px', 'default' => 14],
            ['var' => '--tbm-bar-height',   'label' => 'Minimal bar height', 'type' => 'px', 'default' => 52],
        ],
    ],
];
