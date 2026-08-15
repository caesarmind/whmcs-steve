<?php
/**
 * Variant meta for login/split.
 *
 * Read by:
 *   - Template::getPageVariants  → label + description in the admin Pages picker
 *   - Hooks::resolveCurrentPage  → `fullPage` toggles the header/footer chrome off
 *
 * `fullPage => true` makes the theme render this variant edge-to-edge: the
 * portal nav, sidebar/rail, breadcrumb and footer are suppressed so the
 * split sign-in screen owns the whole viewport.
 */
return [
    'name'        => 'Split + Announcements',
    'description' => 'Full-bleed two-column sign-in — brand and the latest announcements on one side, the login form on the other. Hides the portal nav and footer.',
    'fullPage'    => true,

    /* OPTIONS ARE VARIANT-SCOPED, stored as `<key>__split`. The `spl_` prefix is
       load-bearing rather than decorative: Hooks falls back to the un-namespaced
       bare key for options that used to be page-scoped, so sharing a key with
       another login variant would let one inherit the other's choice. */
    'supportedOptions' => [
        /* The info panel's fill. Same four words the dashboard's Welcome band
           and the Beacon variant's field use for the same idea, so a buyer who
           has met one already knows this one.
           Light is the default because it is what Split has always rendered --
           a neutral panel that asks nothing of the buyer's palette. */
        'spl_panel_style' => [
            'type'    => 'select',
            'label'   => 'Panel style',
            'default' => 'light',
            'options' => ['light', 'soft', 'gradient', 'solid'],
            'tooltip' => 'Which fill the brand + announcements panel carries. Light is the shipped look: the page surface with a hairline divider. Soft is a pale tint of the accent. Gradient sweeps the accent down the panel, deepened at one end. Solid is a flat accent panel. Gradient and Solid carry light text; Light and Soft keep the page ink.',
        ],
    ],
];
