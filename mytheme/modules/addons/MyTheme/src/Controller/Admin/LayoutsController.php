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

        $kind = $_GET['kind'] ?? 'main-menu';
        if (!in_array($kind, ['main-menu', 'footer'], true)) {
            $kind = 'main-menu';
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST'
            && isset($_POST['layout'], $_POST['audience'])) {
            return $this->saveAction($template, $kind);
        }

        $available     = $template->getLayouts($kind);
        $default       = self::DEFAULT_BY_KIND[$kind] ?? 'default';
        $currentGuest  = $this->resolvePointer($template, $kind, 'guest',  $default);
        $currentClient = $this->resolvePointer($template, $kind, 'client', $default);

        $list = [];
        foreach ($available as $name) {
            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php"
            );
            $list[] = [
                'name'              => $name,
                'displayName'       => $meta['displayName'] ?? ucfirst($name),
                'description'       => $meta['description'] ?? '',
                'preview'           => $meta['preview'] ?? 'thumb.png',
                'isActiveGuest'     => $name === $currentGuest,
                'isActiveClient'    => $name === $currentClient,
            ];
        }

        return $this->view('layouts/index', [
            'layouts'  => $list,
            'kind'     => $kind,
            'template' => $template->getName(),
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
        $layout   = (string)$_POST['layout'];
        $audience = (string)$_POST['audience'];
        $accepted = in_array($layout, $template->getLayouts($kind), true)
                 && in_array($audience, self::AUDIENCES, true);

        // Sentinel writes — let the front-end diagnostic comment confirm
        // the click reached PHP, what was POSTed, and whether the
        // manifest accepted it. Strip once the path is trusted.
        Settings::setValue('mytheme_layout_save_attempts',
            (int)Settings::getValue('mytheme_layout_save_attempts', 0) + 1);
        Settings::setValue('mytheme_layout_save_last_kind',     $kind);
        Settings::setValue('mytheme_layout_save_last_audience', $audience);
        Settings::setValue('mytheme_layout_save_last_value',    $layout);
        Settings::setValue('mytheme_layout_save_last_accepted', $accepted ? '1' : '0');

        if ($accepted) {
            $key = $template->getName() . '_active_layout_' . $kind . '_' . $audience;
            Settings::setValue($key, $layout);
        }

        // PRG redirect — calling indexAction() directly would re-enter
        // the POST branch (REQUEST_METHOD is still POST) and recurse
        // until PHP bails out, which WHMCS surfaces as a 404.
        $this->redirect('?module=MyTheme&action=layouts&kind=' . urlencode($kind));
    }
}
