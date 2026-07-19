<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\ThemeManifest;
use Hadrian\Models\Settings;

/**
 * Admin: pick a layout per kind (main-menu, footer), per audience
 * (guest_client, existing_client). Mirrors Lagom's Layout Manager:
 * each layout has TWO independent pointers, one for each audience,
 * with per-row "Activate" buttons (no global Save).
 *
 * Settings keys:
 *   hadrian_active_layout_<kind>_guest    — guest-audience pointer
 *   hadrian_active_layout_<kind>_client   — logged-in-client pointer
 *   hadrian_active_layout_<kind>          — LEGACY single pointer
 *                                            (falls back to this when
 *                                            per-audience is unset)
 *
 * Defaults (when both per-audience and legacy keys are unset):
 *   main-menu → sidebar
 *   footer    → extended
 *
 * Audiences the UI exposes:
 *   guest   — Audience::current() returns 'guest' for unauthenticated visitors
 *   client  — Audience::current() returns 'client' for logged-in clients/admins
 */
final class LayoutsController extends AbstractController
{
    /** Audience values valid in POST payloads + Settings key suffixes. */
    private const AUDIENCES = ['guest', 'client'];

    /** Per-kind default layout — kept in sync with Hooks::resolveActiveLayout. */
    private const DEFAULT_BY_KIND = ['main-menu' => 'sidebar', 'footer' => 'extended'];

    /**
     * Content width. Not a FLAGS entry because those are booleans — this is an
     * enum, stored under 'content_width' and read by header.tpl, which emits
     * body[data-content-width]. 'boxed' is the default and emits nothing, so an
     * install that never touches this keeps exactly today's rendering.
     *
     * The width itself is the --content-max-width custom property
     * (apple-theme.css), so the CSS override is two rules rather than a hunt
     * through every layout.
     */
    public const CONTENT_WIDTHS = [
        'boxed' => 'Boxed — centered, max 1120px',
        'full'  => 'Full width — use the whole viewport',
        'fluid' => 'Fluid — padded but unbounded',
    ];

    /**
     * Controls drawn in the design file that have no backing yet. They render
     * DISABLED and badged so the shape of the finished page is visible without
     * anyone believing a dead switch did something — a toggle that silently
     * does nothing is the exact failure the flag audit cleaned up.
     *
     * To wire one: add a real entry to SettingsController::FLAGS, name it in
     * LAYOUT_FLAGS, gate the feature in the theme, then delete it from here.
     *
     * Two notes for whoever picks this up:
     *  - 'Language switcher' and 'Currency selector' are ONE control in the
     *    theme (includes/partials/locale-btn.tpl opens a combined modal, and the
     *    currency segment already self-gates on multi-currency). They are drawn
     *    separately here only because the design file draws them that way.
     *  - 'Social links' already renders in the extended footer layouts from
     *    $mtBrand.socials and self-gates on those being set, so its flag would be
     *    a master override rather than new behaviour.
     *
     * Shape: section => [ [label, help, type, choices?], ... ]
     */
    private const PLANNED_CONTROLS = [
        'main-menu' => [
            'Sidebar' => [
                ['Position',       'Which side a sidebar-based menu sits on.',              'select', ['Left', 'Right']],
                ['Sticky sidebar', 'Pin the sidebar in view while the page scrolls.',       'bool',   []],
            ],
        ],
        'footer' => [
            'Footer options' => [
                ['Back-to-top button', 'Show a floating button to scroll back to the top.', 'bool',   []],
                ['Newsletter signup',  'Include an email-capture field in the footer.',     'bool',   []],
                ['Social links',       'Render social icons from your Branding settings.',  'bool',   []],
            ],
        ],
    ];

    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        // POST = activation OR an option change. The form carries its own `kind`
        // because the Main-menu/Footer tabs are client-side (no page reload), so
        // `kind` can't be read from the URL.
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['layout'])) {
            $postKind = (string)($_POST['kind'] ?? 'main-menu');
            if (!in_array($postKind, ['main-menu', 'footer'], true)) {
                $postKind = 'main-menu';
            }
            return $this->saveAction($template, $postKind);
        }

        // A Header-section flag toggle. These are declared in
        // SettingsController::FLAGS but render here instead of on Settings, so
        // the storage key and everything reading it on the front end are
        // unchanged — only the admin surface moved.
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['layout_flag'])) {
            return $this->saveFlagAction((string)$_POST['layout_flag'], (string)($_POST['value'] ?? '0'));
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['content_width'])) {
            $width = (string)$_POST['content_width'];
            if (isset(self::CONTENT_WIDTHS[$width])) {
                Settings::setValue('content_width', $width, 'string');
            }
            $this->redirect('?module=Hadrian&action=layouts&kind=main-menu&flag=1');
        }

        // Which tab opens first — preserved across save-redirects via ?kind.
        $activeKind = (string)($_GET['kind'] ?? 'main-menu');
        if (!in_array($activeKind, ['main-menu', 'footer'], true)) {
            $activeKind = 'main-menu';
        }

        // Build BOTH kinds so the tabs are pure client-side toggles.
        $groups = [];
        foreach (['main-menu', 'footer'] as $kind) {
            $default       = self::DEFAULT_BY_KIND[$kind] ?? 'default';
            $currentGuest  = $this->resolvePointer($template, $kind, 'guest',  $default);
            $currentClient = $this->resolvePointer($template, $kind, 'client', $default);

            $list = [];
            foreach ($template->getLayouts($kind) as $name) {
                $meta = ThemeManifest::loadVariantMeta(
                    $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php"
                );

                // Supported options + current values (stored value → declared default).
                $supported  = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];
                $storedOpts = Settings::getValue($template->getName() . "_layout_opts_{$kind}_{$name}", []);
                if (!is_array($storedOpts)) { $storedOpts = []; }
                $options = [];
                foreach ($supported as $okey => $ospec) {
                    $options[$okey] = [
                        'label'   => (string)($ospec['label'] ?? ucfirst($okey)),
                        'choices' => is_array($ospec['choices'] ?? null) ? $ospec['choices'] : [],
                        'value'   => (string)($storedOpts[$okey] ?? ($ospec['default'] ?? '')),
                    ];
                }

                $list[] = [
                    'name'           => $name,
                    'displayName'    => $meta['displayName'] ?? ucfirst($name),
                    'description'    => $meta['description'] ?? '',
                    'isActiveGuest'  => $name === $currentGuest,
                    'isActiveClient' => $name === $currentClient,
                    'options'        => $options,
                ];
            }
            $groups[$kind] = $list;
        }

        // Header-section flags, read straight from the SettingsController
        // registry so label/help/default stay defined in exactly one place.
        $layoutFlags = [];
        foreach (SettingsController::LAYOUT_FLAGS as $flagKey) {
            if (!isset(SettingsController::FLAGS[$flagKey])) { continue; }
            [$label, $help, $default] = SettingsController::FLAGS[$flagKey];
            $layoutFlags[$flagKey] = [
                'label' => $label,
                'help'  => $help,
                'value' => (bool)Settings::getValue($flagKey, $default),
            ];
        }

        return $this->view('layouts/index', [
            'groups'      => $groups,
            'activeKind'  => $activeKind,
            'template'    => $template->getName(),
            'layoutFlags' => $layoutFlags,
            'flagSaved'   => isset($_GET['flag']),
            'planned'     => self::PLANNED_CONTROLS,
            'contentWidths'  => self::CONTENT_WIDTHS,
            'contentWidth'   => (string)Settings::getValue('content_width', 'boxed'),
        ]);
    }

    /** Persist one Header-section flag, then PRG back to the Main menu tab. */
    private function saveFlagAction(string $key, string $value): string
    {
        if (in_array($key, SettingsController::LAYOUT_FLAGS, true)
            && isset(SettingsController::FLAGS[$key])
        ) {
            $type = SettingsController::FLAGS[$key][3];
            Settings::setValue($key, $value === '1' ? '1' : '0', $type);
        }

        $this->redirect('?module=Hadrian&action=layouts&kind=main-menu&flag=1');
    }

    /**
     * Resolve the active layout for one (kind, audience) pointer.
     * Falls back: per-audience key → legacy single key → default.
     * Kept identical to the read path in Hooks::resolveActiveLayout so
     * the "Active" badge always tracks what the front-end renders.
     */
    private function resolvePointer($template, string $kind, string $audience, string $default): string
    {
        $newKey = $template->getName() . '_active_layout_' . $kind . '_' . $audience;
        $value  = (string)Settings::getValue($newKey, '');
        if ($value !== '') {
            return $value;
        }
        $legacyKey = $template->getName() . '_active_layout_' . $kind;
        return (string)Settings::getValue($legacyKey, $default);
    }

    private function saveAction($template, string $kind): string
    {
        $layout      = (string)$_POST['layout'];
        $validLayout = in_array($layout, $template->getLayouts($kind), true);

        if ($validLayout) {
            if (isset($_POST['audience'])) {
                // ── Activation (per-audience pointer) ──
                $audience = (string)$_POST['audience'];
                if (in_array($audience, self::AUDIENCES, true)) {
                    $key = $template->getName() . '_active_layout_' . $kind . '_' . $audience;
                    Settings::setValue($key, $layout);
                } else {
                    // Legacy single-pointer fallback (old cached UI) — mirror to
                    // both per-audience keys so the resolver picks it up at once.
                    $legacyKey = $template->getName() . '_active_layout_' . $kind;
                    Settings::setValue($legacyKey, $layout);
                    foreach (self::AUDIENCES as $aud) {
                        Settings::setValue($template->getName() . '_active_layout_' . $kind . '_' . $aud, $layout);
                    }
                }
            } elseif (isset($_POST['option'])) {
                // ── Set a per-layout option (e.g. content alignment) ──
                $this->saveLayoutOption($template, $kind, $layout, (string)$_POST['option'], (string)($_POST['value'] ?? ''));
            }
        }

        // PRG redirect — calling indexAction() directly would re-enter the POST
        // branch and recurse. ?kind keeps the user on the tab they acted in.
        $this->redirect('?module=Hadrian&action=layouts&kind=' . urlencode($kind));
    }

    /** Persist one layout option, validated against the layout's supportedOptions. */
    private function saveLayoutOption($template, string $kind, string $layout, string $option, string $value): void
    {
        $meta = ThemeManifest::loadVariantMeta(
            $template->getFullPath() . "/core/layouts/{$kind}/{$layout}/layout.php"
        );
        $spec = $meta['supportedOptions'][$option] ?? null;
        if (!is_array($spec)) { return; }
        $choices = is_array($spec['choices'] ?? null) ? $spec['choices'] : [];
        if ($choices !== [] && !isset($choices[$value])) { return; } // reject unknown value

        $key    = $template->getName() . "_layout_opts_{$kind}_{$layout}";
        $stored = Settings::getValue($key, []);
        if (!is_array($stored)) { $stored = []; }
        $stored[$option] = $value;
        Settings::setValue($key, $stored, 'json');
    }
}
