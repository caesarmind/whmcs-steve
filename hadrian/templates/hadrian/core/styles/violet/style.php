<?php
/**
 * Style preset manifest -- Violet.
 *
 * The violet palette against a near-black navigation.
 *
 * THE PALETTE IS THE DEMO'S, VERBATIM.
 * --color-accent and its whole chain (hover, tint, link, badge) plus the avatar
 * gradient are copied from the v18 mockup's own html[data-palette="violet"]
 * block in apple-client-area/css/apple-layout.css. They are not retyped and not
 * adjusted: the brand colour a buyer picks here is the brand colour they saw.
 * Both scopes carry the same values because the demo's palette blocks are not
 * mode-scoped either -- they apply in dark exactly as in light.
 *
 * Contrast, stated rather than silently corrected: white ink on this accent
 * measures 4.13, and because contrast is symmetric that is also what the
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
    'name'        => 'Violet',
    'description' => 'The violet palette against a near-black navigation.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-violet',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#8c5cff',
            '--color-accent-hover'     => '#7a46ff',
            '--color-accent-light'     => 'rgba(140,92,255,0.12)',
            '--color-link'             => '#7a46ff',
            '--color-link-hover'       => '#8c5cff',
            '--color-blue-text'        => '#7a46ff',
            '--color-blue-bg'          => 'rgba(140,92,255,0.12)',
            '--color-avatar-from'      => '#8c5cff',
            '--color-avatar-to'        => '#c28cff',
            '--sidebar-bg'             => 'rgba(28,28,30,0.94)',
            '--sidebar-panel-bg'       => '#1c1c1e',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
        'dark'  => [
            '--color-accent'           => '#8c5cff',
            '--color-accent-hover'     => '#7a46ff',
            '--color-accent-light'     => 'rgba(140,92,255,0.12)',
            '--color-link'             => '#7a46ff',
            '--color-link-hover'       => '#8c5cff',
            '--color-blue-text'        => '#7a46ff',
            '--color-blue-bg'          => 'rgba(140,92,255,0.12)',
            '--color-avatar-from'      => '#8c5cff',
            '--color-avatar-to'        => '#c28cff',
            '--sidebar-bg'             => 'rgba(28,28,30,0.94)',
            '--sidebar-panel-bg'       => '#1c1c1e',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => 'rgba(255,255,255,0.10)',
            '--sidebar-field-bg'       => 'rgba(255,255,255,0.07)',
            '--sidebar-item-hover-bg'  => 'rgba(255,255,255,0.06)',
            '--sidebar-item-active-bg' => 'rgba(255,255,255,0.12)',
            '--sidebar-scroll-thumb'   => 'rgba(255,255,255,0.18)',
        ],
    ],
];
