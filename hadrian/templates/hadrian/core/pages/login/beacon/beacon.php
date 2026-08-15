<?php
/**
 * Variant meta for login/beacon.
 *
 * Read by:
 *   - Template::getPageVariants  -> label + description in the admin Pages picker
 *   - Template::getVariantMeta   -> this variant's own 'supportedOptions'
 *   - Hooks::resolveCurrentPage  -> `fullPage` toggles the header/footer chrome off
 *
 * The filename MUST match the directory name (beacon/beacon.php beside
 * beacon/beacon.tpl) or the variant is silently skipped -- no admin card, no
 * error anywhere.
 *
 * WHAT THIS VARIANT IS. One centred column on a full-page colour field: a brand
 * bar pinned top-left, a line of copy, the sign-in card, and the latest
 * announcements as cards BELOW it rather than beside it. That is the difference
 * from Split, which puts the announcements in a second column and leaves the
 * page neutral -- here the colour runs the whole scroll length and the posts sit
 * on it. Built from apple-client-area/login-v4.html.
 *
 * OPTIONS ARE VARIANT-SCOPED, stored as `<key>__beacon` (PagesController's
 * declaredOptions namespaces them, Hooks flattens the active variant's values
 * back onto the bare key so the template never sees the suffix). The `bcn_`
 * prefix is load-bearing rather than decorative: Hooks falls back to the
 * un-namespaced bare key for options that used to be page-scoped, so reusing
 * split's key here would let one variant inherit the other's choice.
 */
return [
    'name'        => 'Beacon',
    'description' => 'Full-bleed sign-in on a colour field: brand bar, a centred card, and the latest announcements as cards below it. Hides the portal nav and footer.',
    'fullPage'    => true,

    'supportedOptions' => [
        /* The field's fill. Same four words the dashboard's Welcome band uses
           for the same idea, so a buyer who has met one already knows this one.
           Gradient is the default because it IS this variant -- a neutral
           Beacon is just the Default variant with the posts moved. */
        'bcn_field_style' => [
            'type'    => 'select',
            'label'   => 'Field style',
            'default' => 'gradient',
            'options' => ['gradient', 'solid', 'soft', 'light'],
            'tooltip' => 'Gradient is the shipped look: the accent swept across the whole page, deepened at one corner. Solid is a flat accent field. Soft is a pale tint of the accent with dark text, for a quieter page. Light drops the colour altogether and puts the card on the page surface.',
        ],
        'bcn_field_colour' => [
            'type'    => 'colour',
            'label'   => 'Field colour',
            'help'    => 'Which colour the field is built from. Theme follows Styles > Colors, so the sign-in page moves with a preset change; Custom is fixed. None falls back to the accent.',
            'default' => '',
            // The same palette the dashboard blocks offer, from one file so the
            // two cannot drift.
            'paints'  => require __DIR__ . '/../../../config/paints.php',
            // None is withheld while the style is one BUILT from a colour:
            // gradient, solid and soft have no uncoloured rendering -- the CSS
            // falls back to the accent -- so offering None described a state
            // the page does not have.
            'stylePeer'     => 'bcn_field_style',
            'needsColourOn' => ['gradient', 'solid', 'soft'],
        ],
        'bcn_news' => [
            'type'    => 'bool',
            'label'   => 'Show announcements',
            'help'    => 'The three most recent published announcements, as cards under the sign-in card. Off leaves the card alone on the field.',
            'default' => true,
        ],
    ],
];
