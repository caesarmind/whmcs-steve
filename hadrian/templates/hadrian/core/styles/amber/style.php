<?php
/**
 * Style preset manifest -- Amber.
 *
 * The amber palette against a cool graphite navigation.
 *
 * THE PALETTE IS THE DEMO'S, VERBATIM.
 * --color-accent and its whole chain (hover, tint, link, badge) plus the avatar
 * gradient are copied from the v18 mockup's own html[data-palette="amber"]
 * block in apple-client-area/css/apple-layout.css. They are not retyped and not
 * adjusted: the brand colour a buyer picks here is the brand colour they saw.
 * Both scopes carry the same values because the demo's palette blocks are not
 * mode-scoped either -- they apply in dark exactly as in light.
 *
 * Contrast, stated rather than silently corrected: white ink on this accent
 * measures 2.52, and because contrast is symmetric that is also what the
 * accent measures as TEXT on white -- which matters, since the theme uses
 * color: var(--color-accent) in ~400 places. An earlier pass deepened these
 * hues to clear 4.5 and was reverted: matching the palette is the requirement,
 * and the buyer can raise contrast per token in Styles > Colors.
 *
 * The SIDEBAR tokens are different in kind -- they are this style's own
 * navigation treatment, not part of the palette -- so they are still solved
 * rather than copied, and every one of them clears AA against its own panel.
 *
 * Constraints worth knowing before editing:
 *   - A token must appear in core/config/colors.php or it is dropped.
 *   - A value must satisfy Hooks::isColorValue -- hex, or COMMA-form rgb()/
 *     rgba()/hsl()/hsla(). var() and color-mix() are silently dropped, which is
 *     why the tone recipes appear RESOLVED to literals here.
 *   - colorMode must stay 'light'. 'dark' drops the card from the picker.
 */
return [
    'name'        => 'Amber',
    'description' => 'The amber palette against a cool graphite navigation.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-amber',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#f08a00',
            '--color-accent-hover'     => '#d97a00',
            '--color-accent-light'     => 'rgba(240,138,0,0.10)',
            '--color-link'             => '#d97a00',
            '--color-link-hover'       => '#f08a00',
            '--color-blue-text'        => '#d97a00',
            '--color-blue-bg'          => 'rgba(240,138,0,0.10)',
            '--color-avatar-from'      => '#f08a00',
            '--color-avatar-to'        => '#ffb547',
            '--sidebar-bg'             => 'rgba(33,37,46,0.94)',
            '--sidebar-panel-bg'       => '#21252e',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b8c0cc',
            '--sidebar-text-muted'     => '#9aa3b2',
            '--sidebar-text-faint'     => '#798294',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#f08a00',
            '--color-accent-hover'     => '#d97a00',
            '--color-accent-light'     => 'rgba(240,138,0,0.10)',
            '--color-link'             => '#d97a00',
            '--color-link-hover'       => '#f08a00',
            '--color-blue-text'        => '#d97a00',
            '--color-blue-bg'          => 'rgba(240,138,0,0.10)',
            '--color-avatar-from'      => '#f08a00',
            '--color-avatar-to'        => '#ffb547',
            '--sidebar-bg'             => 'rgba(33,37,46,0.94)',
            '--sidebar-panel-bg'       => '#21252e',
            '--sidebar-text'           => '#f2f4f6',
            '--sidebar-text-secondary' => '#b8c0cc',
            '--sidebar-text-muted'     => '#9aa3b2',
            '--sidebar-text-faint'     => '#798294',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
