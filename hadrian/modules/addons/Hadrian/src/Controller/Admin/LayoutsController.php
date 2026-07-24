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
     *
     * 'fluid' was RETIRED (2026-07-24). It differed from 'full' by gutter alone
     * -- full hardcoded --content-pad-x:24px, fluid inherited 48px -- so two
     * options existed whose entire visible difference was 24px of padding. The
     * gutter is now its own "Side padding" field, which is both clearer and more
     * capable than a mode. Stored 'fluid' values normalise to 'full' on read
     * (contentWidthMode) and the CSS keeps matching both, so nothing breaks.
     */
    public const CONTENT_WIDTHS = [
        'boxed' => 'Boxed — centered, fixed maximum width',
        'full'  => 'Full width — use the whole viewport',
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
        // Emptied: every control that lived here is now wired.
        //   Position       -> per-layout 'side' option on the sidebar/rail cards
        //   Sticky sidebar -> unpin_sidebar flag (inverted; the sidebar is pinned
        //                     by default, so the flag turns pinning OFF)
        //   Back-to-top    -> back_to_top flag, Footer options
        //   Newsletter     -> dropped
        'main-menu' => [],
        // The 'footer' => 'Footer options' key MUST stay even while empty:
        // layouts/index.tpl draws the Footer options <section> from INSIDE
        // {foreach $planned['footer']}, so removing it would take the wired
        // $footerFlags rows down with it.
        'footer' => [
            'Footer options' => [],
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

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['content_max_width'])) {
            $this->saveLayoutVar('--content-max-width', (string)$_POST['content_max_width']);
            $this->redirect('?module=Hadrian&action=layouts&kind=main-menu&flag=1');
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['content_pad_x'])) {
            $this->saveLayoutVar('--content-pad-x', (string)$_POST['content_pad_x']);
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
                    // Feeds the "Live preview" link. header.tpl honours
                    // ?preview=1&layout=<side|top|rail> and that value is this
                    // manifest's dataLayout, NOT the folder name -- the sidebar
                    // layout emits data-layout="side". Footer layouts declare no
                    // dataLayout, so the view drops the link for them rather
                    // than building a URL that previews nothing.
                    //
                    // Nested under 'variables', NOT top level. Reading
                    // $meta['dataLayout'] returns null for every layout, so the
                    // view's {if $layout.dataLayout} was false everywhere and no
                    // button rendered at all. header.tpl reaches the same value
                    // as .vars.dataLayout because Hooks renames the key on the
                    // way out; the manifest itself says 'variables'.
                    'dataLayout'     => (string)($meta['variables']['dataLayout'] ?? ''),
                ];
            }
            $groups[$kind] = $list;
        }

        // Header-section flags, read straight from the SettingsController
        // registry so label/help/default stay defined in exactly one place.
        // Split by which tab they render under; unlisted flags default to the
        // Main menu tab's Header section.
        $layoutFlags = [];
        $footerFlags = [];
        foreach (SettingsController::LAYOUT_FLAGS as $flagKey) {
            if (!isset(SettingsController::FLAGS[$flagKey])) { continue; }
            [$label, $help, $default] = SettingsController::FLAGS[$flagKey];
            $row = [
                'label' => $label,
                'help'  => $help,
                'value' => (bool)Settings::getValue($flagKey, $default),
            ];
            if ((SettingsController::LAYOUT_FLAG_SECTION[$flagKey] ?? 'main-menu') === 'footer') {
                $footerFlags[$flagKey] = $row;
            } else {
                $layoutFlags[$flagKey] = $row;
            }
        }

        return $this->view('layouts/index', [
            'groups'      => $groups,
            'activeKind'  => $activeKind,
            'template'    => $template->getName(),
            'layoutFlags' => $layoutFlags,
            'footerFlags' => $footerFlags,
            'flagSaved'   => isset($_GET['flag']),
            'planned'     => self::PLANNED_CONTROLS,
            'contentWidths'  => self::CONTENT_WIDTHS,
            'contentWidth'   => $this->contentWidthMode(),
            'contentMaxWidth'        => $this->layoutVar('--content-max-width'),
            'contentMaxWidthDefault' => $this->layoutVarDefault('--content-max-width'),
            'contentPadX'            => $this->layoutVar('--content-pad-x'),
            'contentPadXDefault'     => $this->layoutVarDefault('--content-pad-x'),
            // Client-area root for the "Live preview" links. WEB_ROOT is the
            // same source ViewHelper::assetUrl() uses, so it is present in the
            // admin area and already respects a subdirectory install; the empty
            // fallback yields a root-relative URL rather than a broken absolute.
            'previewBase'    => defined('WEB_ROOT') ? rtrim((string)WEB_ROOT, '/') : '',
        ]);
    }

    /**
     * Read/write one px entry of the layout-vars blob.
     *
     * Deliberately NOT new settings. These read and write the exact
     * '--content-max-width' / '--content-pad-x' entries of the
     * '<template>_layout_vars' blob that Styles > Layout > Content already
     * edits, so the two panels are two doors onto one value instead of
     * competing sources of truth. Hooks::buildLayoutHead() emits them as
     * :root{--content-max-width:Npx;--content-pad-x:Npx}.
     *
     * Generic over the var name so Padding X reuses the merge + clamp logic
     * rather than duplicating it -- the duplicated version is exactly where a
     * second field would forget to merge and start dropping the first.
     */
    private function layoutVarDefault(string $var): int
    {
        $template = AddonHelper::getTemplate();
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                if ((string)($f['var'] ?? '') === $var) {
                    return (int)($f['default'] ?? 0);
                }
            }
        }
        return 0;
    }

    private function layoutVar(string $var): int
    {
        $template = AddonHelper::getTemplate();
        $stored   = Settings::getValue($template->getName() . '_layout_vars', []);
        return (is_array($stored) && isset($stored[$var]))
            ? (int)$stored[$var]
            : $this->layoutVarDefault($var);
    }

    /**
     * MERGES into the layout-vars blob rather than replacing it. That blob also
     * carries --sidebar-width and --topbar-height, and
     * StylesController::saveLayoutAction rebuilds it wholesale from its own
     * form; a blind setValue() from this panel would silently drop the others.
     * Storing nothing when the value equals the default matches that panel's
     * convention, so an untouched install still emits no <style> block.
     */
    private function saveLayoutVar(string $var, string $raw): void
    {
        $template = AddonHelper::getTemplate();
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        $min = (int)($cfg['sizeMin'] ?? 0);
        $max = (int)($cfg['sizeMax'] ?? 4000);

        $stored = Settings::getValue($template->getName() . '_layout_vars', []);
        if (!is_array($stored)) {
            $stored = [];
        }

        $val = (int)$raw;
        if ($val < $min || $val > $max || $val === $this->layoutVarDefault($var)) {
            unset($stored[$var]);
        } else {
            $stored[$var] = $val;
        }

        Settings::setValue($template->getName() . '_layout_vars', $stored, 'json');
    }

    /**
     * Stored content_width, with the retired 'fluid' folded onto 'full'.
     *
     * 'fluid' differed from 'full' by gutter alone (24px vs 48px), which is now
     * the Padding X field, so the option was removed. Normalising on READ means
     * an install still holding 'fluid' shows "Full width" selected instead of
     * an empty select, and is migrated the next time the admin saves -- no
     * migration script, and the CSS keeps matching 'fluid' meanwhile.
     */
    private function contentWidthMode(): string
    {
        $stored = (string)Settings::getValue('content_width', 'boxed');
        if ($stored === 'fluid') {
            return 'full';
        }
        return isset(self::CONTENT_WIDTHS[$stored]) ? $stored : 'boxed';
    }

    /**
     * Persist one relocated flag, then PRG back to the tab it lives on — a
     * footer toggle bouncing the admin to the Main menu tab reads as the click
     * having gone somewhere unexpected.
     */
    private function saveFlagAction(string $key, string $value): string
    {
        if (in_array($key, SettingsController::LAYOUT_FLAGS, true)
            && isset(SettingsController::FLAGS[$key])
        ) {
            $type = SettingsController::FLAGS[$key][3];
            Settings::setValue($key, $value === '1' ? '1' : '0', $type);
        }

        $kind = SettingsController::LAYOUT_FLAG_SECTION[$key] ?? 'main-menu';
        $this->redirect('?module=Hadrian&action=layouts&kind=' . urlencode($kind) . '&flag=1');
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
