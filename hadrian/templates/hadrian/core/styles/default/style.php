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
     * OPTIONAL: a preset's palette. Deliberately absent here -- Default IS the
     * baseline, so it ships no overrides and the schema defaults stand.
     *
     *   'colors' => [
     *       'light' => ['--color-accent' => '#1b4fd8', ...],
     *       'dark'  => ['--color-accent' => '#7aa5ff', ...],
     *   ],
     *
     * StylesController::seedStyleColors writes this into the style's stored
     * colours the FIRST time it is activated; after that the rows belong to the
     * buyer and are never overwritten, so a preset is a starting point they can
     * edit in Styles > Colors rather than a locked skin.
     *
     * Three rules, each of which fails SILENTLY if broken:
     *   - a token must exist in core/config/colors.php, or it is dropped;
     *   - a value must satisfy Hooks::isColorValue -- hex, or COMMA-form
     *     rgb()/rgba()/hsl()/hsla(). var(), color-mix() and oklch() are dropped;
     *   - a value equal to the schema default is not stored at all.
     * See scripts against these rules before shipping a preset.
     */

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
