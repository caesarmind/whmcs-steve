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
    'displayName' => 'Icon Rail',
    'description' => 'Compact 80px icon rail with flyout panels on hover.',
    'variables'   => [
        'dataLayout' => 'rail',
    ],
    /* The rail's own width is fixed in CSS with no token, so the only
       dimension it exposes is the inner topbar it shares with the sidebar
       layout. */
    'sizes' => ['--topbar-height'],
    'supportedOptions' => [
        'align' => [
            'label'   => 'Content alignment',
            'default' => 'center',
            'choices' => ['center' => 'Center', 'left' => 'Left'],
        ],
        // Flipping the rail's edge is safe (unlike unpinning it, which would
        // strand the only nav on this layout). Stored per-layout, so the rail's
        // side is independent of the sidebar's.
        'side' => [
            'label'   => 'Rail position',
            'default' => 'left',
            'choices' => ['left' => 'Left', 'right' => 'Right'],
        ],
        // The foot of the rail in BOTH auth states: the avatar and the account
        // menu it opens when signed in, the Login item when signed out. Stored
        // per layout like `side`, so hiding it on the rail says nothing about
        // the sidebar. Safe to turn off for the same reason: this layout also
        // renders the inner topbar, which carries the same menu when signed in
        // and a Sign in link when signed out.
        //
        // Key stays 'profile' though the label widened -- it is the stored
        // settings key.
        //
        // 'show' is the default and emits no attribute.
        'profile' => [
            'label'   => 'Account block',
            'default' => 'show',
            'choices' => ['show' => 'Show', 'hide' => 'Hide'],
        ],
    ],
];
