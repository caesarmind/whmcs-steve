<?php
/**
 * Style preset manifest — DEFAULT.
 *
 * Read by:
 *   - StylesController (admin UI)
 *   - Hooks::resolveActiveStyle (sets $hadrian.styles.vars at render time)
 *
 * The preset's colours, typography, buttons, forms, elements and layout are
 * NOT declared here — those are edited in the admin Styles tabs and stored as
 * <theme>_colors_* / _typography / _buttons / _forms / _elements /
 * _layout_vars, which Hooks reads directly.
 */
return [
    'name'        => 'Default',
    'description' => 'Light, clean, neutral. The default look.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',

    /**
     * Surfaced as $hadrian.styles.vars.* at render time (Hooks::resolveActiveStyle).
     *
     * bodyClass  lands on <body> in header.tpl, giving a preset a CSS hook to
     *            scope its own overrides.
     * colorMode  is NOT a template variable — it is a manifest flag read by
     *            StylesController, which drops any preset marked 'dark' from
     *            the activatable style list, because dark is a per-style colour
     *            SCOPE (the Light/Dark toggle in the Colors panel) rather than
     *            a style you switch to. Removing it makes the dark preset
     *            selectable again. It does not decide what the visitor sees:
     *            that is the dark-mode feature (enable_dark_mode +
     *            dark_mode_default -> <html data-theme>), which owns the
     *            toggle and the cookie.
     */
    'variables'   => [
        'bodyClass' => 'theme-default',
        'colorMode' => 'light',
    ],
];
