<?php
/**
 * Layout schema — page-structure DIMENSIONS for the admin Styles > Layout
 * panel (StylesController::buildLayoutViewModel) and the render-time emitter
 * (Hooks::buildLayoutHead). Mirrors core/config/buttons.php but px-only:
 * layout widths/heights have no "scale", so plain pixel inputs are the natural
 * control (this is geometry, not typography). Distinct from the top-level
 * Layouts manager (which picks sidebar vs top-nav menu layouts) and from the
 * Colors panel (colours only) — no overlap.
 *
 * GLOBAL (site-wide); emitted into :root. Every `default` MUST mirror the
 * matching token in assets/css/apple-theme.css.
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
            ['var' => '--topbar-height', 'label' => 'Topbar height', 'type' => 'px', 'default' => 44],
        ],
    ],
];
