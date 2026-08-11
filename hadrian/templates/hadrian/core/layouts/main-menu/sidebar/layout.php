<?php
/**
 * Main-menu layout manifest.
 *
 * Only three things here are read at runtime:
 *   displayName / description  -> admin Layouts list (LayoutsController)
 *   variables.dataLayout       -> body[data-layout] (header.tpl), which is what
 *                                 every layout-scoped CSS rule keys off
 *   supportedOptions           -> admin picker, validated on save and re-read
 *                                 by Hooks into body[data-align]
 *
 * Deliberately absent: 'preview' (the admin draws inline SVG thumbnails and no
 * thumb.png exists), 'order' (Template::getLayouts returns theme.json's
 * provides.layouts verbatim and unsorted -- that sequence is canonical),
 * 'bodyClass' (body[data-layout] already does this job) and 'sidebarPresent'.
 * All four were declared and read by nothing.
 */
return [
    'displayName' => 'Sidebar',
    'description' => 'Fixed 260px sidebar on the left, content shifts right.',
    'variables'   => [
        'dataLayout' => 'side',
    ],
    /* Page-structure dimensions this layout actually shapes, rendered on its
       card in the admin Layouts page. Only ONE main-menu layout is active at
       a time, so these still live in the global _layout_vars blob and
       Hooks::buildLayoutHead is unchanged -- declaring them here is a UI
       grouping, not a second storage. Sidebar width is this layout's alone;
       the topbar is shared with the rail (header.tpl renders inner-topbar
       whenever the layout is not 'top'). */
    'sizes' => ['--sidebar-width', '--topbar-height'],
    'supportedOptions' => [
        'align' => [
            'label'   => 'Content alignment',
            'default' => 'center',
            'choices' => ['center' => 'Center', 'left' => 'Left'],
        ],
        // Which edge the fixed 260px column sits on. 'left' is the default and
        // header.tpl emits NO attribute for it, so an install that never touches
        // this renders byte-identically to today.
        'side' => [
            'label'   => 'Sidebar position',
            'default' => 'left',
            'choices' => ['left' => 'Left', 'right' => 'Right'],
        ],
        // The footer of the sidebar, in BOTH auth states: avatar, name, email
        // and the menu they open when signed in; the Login and Create-account
        // buttons when signed out. One region, one switch -- an admin turning
        // it off means the region, not one of its two faces.
        //
        // Off is a reasonable choice here because this layout ALSO renders the
        // inner topbar -- header.tpl includes inner-topbar.tpl for every layout
        // that is not `top` -- and that topbar carries the same account menu
        // when signed in and a Sign in link when signed out. So neither state
        // loses its last route.
        //
        // Key stays 'profile' though the label widened: it is the stored
        // settings key, and renaming it would silently reset every install that
        // had already set it.
        //
        // 'show' is the default and emits no attribute, so an install that
        // never touches this renders byte-identically to before.
        'profile' => [
            'label'   => 'Account block',
            'default' => 'show',
            'choices' => ['show' => 'Show', 'hide' => 'Hide'],
        ],
    ],
];
