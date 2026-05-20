<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;

/**
 * Admin: pick a layout per kind (main-menu, footer), per audience
 * (guest_client, existing_client). Mirrors Lagom's Layout Manager:
 * each layout has TWO independent pointers, one for each audience,
 * with per-row "Activate" buttons (no global Save).
 *
 * Settings keys:
 *   mytheme_active_layout_<kind>_guest    — guest-audience pointer
 *   mytheme_active_layout_<kind>_client   — logged-in-client pointer
 *   mytheme_active_layout_<kind>          — LEGACY single pointer
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

        return $this->view('layouts/index', [
            'groups'     => $groups,
            'activeKind' => $activeKind,
            'template'   => $template->getName(),
        ]);
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
        $this->redirect('?module=MyTheme&action=layouts&kind=' . urlencode($kind));
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
