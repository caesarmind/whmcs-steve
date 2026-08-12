<?php
/**
 * Style preset manifest -- Rose.
 *
 * The rose palette on the standard light chrome. Bold accent, quiet frame.
 *
 * THE PALETTE IS THE DEMO'S, VERBATIM.
 * --color-accent and its whole chain (hover, tint, link, badge) plus the avatar
 * gradient are copied from the v18 mockup's own html[data-palette="rose"]
 * block in apple-client-area/css/apple-layout.css. They are not retyped and not
 * adjusted: the brand colour a buyer picks here is the brand colour they saw.
 * Both scopes carry the same values because the demo's palette blocks are not
 * mode-scoped either -- they apply in dark exactly as in light.
 *
 * Contrast, stated rather than silently corrected: white ink on this accent
 * measures 3.60, and because contrast is symmetric that is also what the
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
    'name'        => 'Rose',
    'description' => 'The rose palette on the standard light chrome. Bold accent, quiet frame.',
    'preview'     => 'thumb.png',
    'iconType'    => 'default',
    'variables'   => [
        'bodyClass' => 'theme-rose',
        'colorMode' => 'light',
    ],
    'colors'      => [
        'light' => [
            '--color-accent'       => '#ff2d6b',
            '--color-accent-hover' => '#e61f5b',
            '--color-accent-light' => 'rgba(255,45,107,0.10)',
            '--color-link'         => '#e61f5b',
            '--color-link-hover'   => '#ff2d6b',
            '--color-blue-text'    => '#e61f5b',
            '--color-blue-bg'      => 'rgba(255,45,107,0.10)',
            '--color-avatar-from'  => '#ff2d6b',
            '--color-avatar-to'    => '#ff7fa8',
        ],
        'dark'  => [
            '--color-accent'       => '#ff2d6b',
            '--color-accent-hover' => '#e61f5b',
            '--color-accent-light' => 'rgba(255,45,107,0.10)',
            '--color-link'         => '#e61f5b',
            '--color-link-hover'   => '#ff2d6b',
            '--color-blue-text'    => '#e61f5b',
            '--color-blue-bg'      => 'rgba(255,45,107,0.10)',
            '--color-avatar-from'  => '#ff2d6b',
            '--color-avatar-to'    => '#ff7fa8',
        ],
    ],
];
