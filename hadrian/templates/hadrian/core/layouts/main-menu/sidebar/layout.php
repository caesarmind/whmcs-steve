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
    'supportedOptions' => [
        'align' => [
            'label'   => 'Content alignment',
            'default' => 'center',
            'choices' => ['center' => 'Center', 'left' => 'Left'],
        ],
    ],
];
