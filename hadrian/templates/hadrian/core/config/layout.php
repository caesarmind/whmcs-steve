<?php
/**
 * Layout schema — page-structure DIMENSIONS for the admin Layouts page
 * (LayoutsController::buildSizeRows) and the render-time emitter
 * (Hooks::buildLayoutHead). Mirrors core/config/buttons.php but px-only:
 * layout widths/heights have no "scale", so plain pixel inputs are the natural
 * control (this is geometry, not typography). Distinct from the Colors panel
 * (colours only) — no overlap.
 *
 * NAVIGATION GEOMETRY NO LONGER LIVES HERE. The ten nav tokens this file used
 * to carry (--nav-logo-height, --nav-icon-size, --nav-icon-glyph,
 * --sidebar-width, --topbar-height, --rail-width, --rail-panel-width,
 * --topnav-height, --topnav-icon-size, --tbm-bar-height) MOVED to
 * core/config/navigation.php, which backs the Styles > Navigation panel and
 * stores under its own `<tpl>_navigation_vars` row. That file's header carries
 * the full reasoning; the short version is that ten controls about the main
 * menu were outgrowing a page-structure schema, and the Layouts page they
 * rendered on is about CHOOSING a layout, not measuring one.
 *
 * It was a MOVE, not a copy, and it has to stay one. Hadrian files controls BY
 * TYPE and each token is editable in exactly ONE panel — the lesson of ee9b6ef,
 * which deleted an earlier Navigation panel precisely because it re-edited rows
 * Colors and Layout already owned. Before adding a row here, check the var
 * against navigation.php, colors.php, typography.php, general.php, buttons.php,
 * forms.php and elements.php — if it is editable there, it does not go here at
 * any price.
 *
 * What is LEFT is the content column itself, which is page structure by any
 * reading: how wide the column is and how much gutter it keeps. Both apply to
 * every layout, so neither carries an "Applies to" caption, and neither is
 * named in any layout manifest's `sizes` array.
 *
 * The group name below is for READING this file. The admin does not render it:
 * LayoutsController derives each row's "Applies to the Sidebar and Icon Rail
 * layouts" caption from which manifests declare the var in their `sizes` array
 * (core/layouts/main-menu/<name>/layout.php), so a row only appears once some
 * layout claims it, and the caption cannot go stale when a layout is added.
 * That mechanism is intact and still the extension point a dropped-in layout
 * uses — it simply has nothing to draw today, because the only vars declared
 * here are the two the Containers section renders with hand-written rows.
 *
 * GLOBAL (site-wide); emitted into :root. Every `default` MUST mirror the
 * matching token in assets/css/core-theme.css.
 */
return [
    'sizeMin' => 0,
    'sizeMax' => 4000,
    /* ONE group now. It was three; two of them were "Navigation - shared" and
       "Navigation - per layout" and both moved wholesale to navigation.php.
       Scope per row is carried by its own "Applies to the X layout(s)" caption,
       derived from the layout manifests, so a group only needs to answer "what
       KIND of dimension is this". */
    'sizeGroups' => [
        'Content' => [
            ['var' => '--content-max-width', 'label' => 'Max width', 'type' => 'px', 'default' => 1120],
            ['var' => '--content-pad-x',     'label' => 'Padding X', 'type' => 'px', 'default' => 48],
        ],
    ],
];
