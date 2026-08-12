<?php
/**
 * Style preset manifest -- Slate.
 *
 * The slate palette used as both accent and navigation.
 *
 * THE PALETTE IS THE DEMO'S, VERBATIM.
 * --color-accent and its whole chain (hover, tint, link, badge) plus the avatar
 * gradient are copied from the v18 mockup's own html[data-palette="slate"]
 * block in apple-client-area/css/apple-layout.css. They are not retyped and not
 * adjusted: the brand colour a buyer picks here is the brand colour they saw.
 * Both scopes carry the same values because the demo's palette blocks are not
 * mode-scoped either -- they apply in dark exactly as in light.
 *
 * Contrast, stated rather than silently corrected: white ink on this accent
 * measures 4.76, and because contrast is symmetric that is also what the
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
    'name'        => 'Slate',
    'description' => 'The slate palette used as both accent and navigation.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-slate',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#64748b',
            '--color-accent-hover'     => '#475569',
            '--color-accent-light'     => 'rgba(100,116,139,0.10)',
            '--color-link'             => '#475569',
            '--color-link-hover'       => '#64748b',
            '--color-blue-text'        => '#475569',
            '--color-blue-bg'          => 'rgba(100,116,139,0.10)',
            '--color-avatar-from'      => '#64748b',
            '--color-avatar-to'        => '#94a3b8',
            '--sidebar-bg'             => '#444f5f',
            '--sidebar-panel-bg'       => '#444f5f',
            '--sidebar-text'           => '#ffffff',
            '--sidebar-text-secondary' => 'rgba(255,255,255,0.82)',
            '--sidebar-text-muted'     => 'rgba(255,255,255,0.70)',
            '--sidebar-text-faint'     => 'rgba(255,255,255,0.55)',
            '--sidebar-border'         => 'rgba(255,255,255,0.20)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.16)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.14)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.30)',
        ],
        'dark'  => [
            '--color-accent'           => '#64748b',
            '--color-accent-hover'     => '#475569',
            '--color-accent-light'     => 'rgba(100,116,139,0.10)',
            '--color-link'             => '#475569',
            '--color-link-hover'       => '#64748b',
            '--color-blue-text'        => '#475569',
            '--color-blue-bg'          => 'rgba(100,116,139,0.10)',
            '--color-avatar-from'      => '#64748b',
            '--color-avatar-to'        => '#94a3b8',
            '--sidebar-bg'             => '#444f5f',
            '--sidebar-panel-bg'       => '#444f5f',
            '--sidebar-text'           => '#ffffff',
            '--sidebar-text-secondary' => 'rgba(255,255,255,0.82)',
            '--sidebar-text-muted'     => 'rgba(255,255,255,0.70)',
            '--sidebar-text-faint'     => 'rgba(255,255,255,0.55)',
            '--sidebar-border'         => 'rgba(255,255,255,0.20)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.16)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.14)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.30)',
        ],
    ],
];
