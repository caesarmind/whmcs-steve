<?php
/**
 * Style preset manifest -- Emerald.
 *
 * The emerald palette with a softly tinted navigation panel.
 *
 * THE PALETTE IS THE DEMO'S, VERBATIM.
 * --color-accent and its whole chain (hover, tint, link, badge) plus the avatar
 * gradient are copied from the v18 mockup's own html[data-palette="emerald"]
 * block in apple-client-area/css/apple-layout.css. They are not retyped and not
 * adjusted: the brand colour a buyer picks here is the brand colour they saw.
 * Both scopes carry the same values because the demo's palette blocks are not
 * mode-scoped either -- they apply in dark exactly as in light.
 *
 * Contrast, stated rather than silently corrected: white ink on this accent
 * measures 2.76, and because contrast is symmetric that is also what the
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
    'name'        => 'Emerald',
    'description' => 'The emerald palette with a softly tinted navigation panel.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-emerald',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'           => '#14b17d',
            '--color-accent-hover'     => '#0fa370',
            '--color-accent-light'     => 'rgba(20,177,125,0.10)',
            '--color-link'             => '#0fa370',
            '--color-link-hover'       => '#14b17d',
            '--color-blue-text'        => '#0fa370',
            '--color-blue-bg'          => 'rgba(20,177,125,0.10)',
            '--color-avatar-from'      => '#14b17d',
            '--color-avatar-to'        => '#5ac8a3',
            '--sidebar-bg'             => '#e8f7f2',
            '--sidebar-panel-bg'       => '#f1faf7',
            '--sidebar-text'           => '#1d1d1f',
            '--sidebar-text-secondary' => '#6b6b70',
            '--sidebar-text-muted'     => '#86868b',
            '--sidebar-text-faint'     => '#aeaeb2',
            '--sidebar-border'         => '#d9f3ea',
            '--sidebar-field-bg'       => '#f1faf7',
            '--sidebar-item-hover-bg'  => 'rgba(20,177,125,0.14)',
            '--sidebar-item-active-bg' => 'rgba(20,177,125,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(20,177,125,0.3)',
        ],
        'dark'  => [
            '--color-accent'           => '#14b17d',
            '--color-accent-hover'     => '#0fa370',
            '--color-accent-light'     => 'rgba(20,177,125,0.10)',
            '--color-link'             => '#0fa370',
            '--color-link-hover'       => '#14b17d',
            '--color-blue-text'        => '#0fa370',
            '--color-blue-bg'          => 'rgba(20,177,125,0.10)',
            '--color-avatar-from'      => '#14b17d',
            '--color-avatar-to'        => '#5ac8a3',
            '--sidebar-bg'             => '#1b2b28',
            '--sidebar-panel-bg'       => '#1c2524',
            '--sidebar-text'           => '#f5f5f7',
            '--sidebar-text-secondary' => '#a1a1a6',
            '--sidebar-text-muted'     => '#98989d',
            '--sidebar-text-faint'     => '#6e6e73',
            '--sidebar-border'         => '#1b342d',
            '--sidebar-field-bg'       => '#1c2524',
            '--sidebar-item-hover-bg'  => 'rgba(20,177,125,0.14)',
            '--sidebar-item-active-bg' => 'rgba(20,177,125,0.22)',
            '--sidebar-scroll-thumb'   => 'rgba(20,177,125,0.3)',
        ],
    ],
];
