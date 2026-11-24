<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\AdminAjax;
use Hadrian\Helpers\ColorTokens;
use Hadrian\Helpers\CustomizePreview;
use Hadrian\Helpers\LayoutPointers;
use Hadrian\Helpers\PageArea;
use Hadrian\Helpers\ThemeManifest;
use Hadrian\Models\Settings;
use Hadrian\Template\Template;

/**
 * The customizer: scheme, layouts and colours, tried out on the real site in
 * a frame before anything is saved.
 *
 *   ?action=customize                     the screen
 *   ?action=customize&sub=preview-ajax    POST: hold the unsaved state for the frame
 *   ?action=customize&sub=save-ajax       POST: write it to the settings
 *
 * It owns no settings of its own. Save writes the rows the Styles and Layouts
 * pages already read and write (<tpl>_active_style, <tpl>_colors_<style>_<scope>,
 * the LayoutPointers keys), so those pages show what was saved here and the
 * other way round.
 *
 * The frame is the live site with a preview token in the URL; see
 * Helpers\CustomizePreview for why only this admin sees the unsaved state.
 */
final class CustomizeController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        $known = $this->known($template);
        $saved = $this->savedState($template, $known);

        // The frame opens on what is saved. A state left over from an earlier
        // visit is dropped: reopening the screen and finding colours nobody
        // remembers picking is worse than starting clean.
        CustomizePreview::put($saved);

        $schemes = [];
        foreach ($known['styles'] as $name) {
            $meta = $this->styleMeta($template, $name);
            $shipped = [];
            $stored  = [];
            foreach (['light', 'dark'] as $scope) {
                $shipped[$scope] = (object)$this->shippedColors($meta, $known['colors'], $scope);
                $stored[$scope]  = (object)$this->storedColors($template, $name, $meta, $known['colors'], $scope);
            }
            $schemes[$name] = [
                'name'        => $name,
                'label'       => (string)($meta['name'] ?? ucfirst($name)),
                'description' => (string)($meta['description'] ?? ''),
                'shipped'     => $shipped,
                'colors'      => $stored,
            ];
        }

        $layouts = [];
        foreach (CustomizePreview::KINDS as $kind) {
            foreach ($known['layouts'][$kind] as $name) {
                $meta = ThemeManifest::loadVariantMeta(
                    $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php"
                );
                $layouts[$kind][] = ['name' => $name, 'label' => (string)($meta['displayName'] ?? ucfirst($name))];
            }
        }

        $groups = [];
        foreach (ColorTokens::schema($known['colors']) as $token) {
            $groups[$token['group']][] = $token;
        }

        $data = [
            'param'    => CustomizePreview::PARAM,
            'token'    => CustomizePreview::token(),
            'csrf'     => \Hadrian\Helpers\AdminCsrf::token(),
            'endpoint' => 'addonmodules.php?module=Hadrian&action=customize',
            // The admin folder sits one level under the site root, whatever it is called.
            'siteRoot' => '../',
            'saved'    => $saved,
            'schemes'  => $schemes,
            'layouts'  => $layouts,
            'groups'   => $groups,
            'pages'    => $this->previewPages(),
            'slots'    => [
                'audience' => ['guest' => 'Guests', 'client' => 'Signed-in clients'],
                'area'     => PageArea::LABELS,
            ],
            'kindLabels' => ['main-menu' => 'Navigation', 'footer' => 'Footer'],
            'darkMode'   => (bool)Settings::getValue('enable_dark_mode', true),
            'selectors'  => ['light' => ColorTokens::SELECTOR_LIGHT, 'dark' => ColorTokens::SELECTOR_DARK],
        ];

        $script = (string)@file_get_contents(dirname(__DIR__, 3) . '/views/adminarea/assets/js/customize.js');

        return $this->view('customize/index', [
            // The screen is reached from Styles and has no tab of its own;
            // includes/header.tpl lights the Styles tab for this value.
            'currentAction' => 'editStyle',
            'template'     => $template->getName(),
            'schemes'      => $schemes,
            // Printed inside <script> blocks. HEX_TAG keeps "</script>" out of
            // the JSON; the script file is ours and is checked by the tests.
            'customizeJson' => json_encode($data, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES),
            'customizeJs'   => $script,
            'clientSignedIn' => !empty($_SESSION['uid']),
        ]);
    }

    /** Hold the state the admin is trying out, for the preview frame to draw. */
    public function previewAjaxAction(): string
    {
        AdminAjax::guard();
        $template = $this->templateOrRefuse();
        $known    = $this->known($template);
        $state    = CustomizePreview::normalise($this->postedState(), $known, $this->savedState($template, $known));
        CustomizePreview::put($state);
        $this->json(['ok' => true, 'state' => $state]);
    }

    /** Write the state to the settings the Styles and Layouts pages use. */
    public function saveAjaxAction(): string
    {
        AdminAjax::guard();
        $template = $this->templateOrRefuse();
        $known    = $this->known($template);
        $state    = CustomizePreview::normalise($this->postedState(), $known, $this->savedState($template, $known));
        $tpl      = $template->getName();

        // The scheme, and its colours for both modes. Writing the colour rows
        // is also what marks the scheme as owned by this site: the Styles page
        // seeds a scheme's shipped palette only while it has no rows.
        Settings::setValue($tpl . '_active_style', $state['style']);
        foreach (['light', 'dark'] as $scope) {
            Settings::setValue($tpl . '_colors_' . $state['style'] . '_' . $scope, $state['colors'][$scope], 'json');
        }

        // Layouts. The visitor picks are always written. The area picks are
        // written only in area mode, so a site that never chose layouts by
        // area gains no rows for it; setMode() seeds them on the first switch
        // and the loop below then applies what was picked here.
        if ($state['layouts']['mode'] !== LayoutPointers::mode($tpl)) {
            LayoutPointers::setMode($tpl, $state['layouts']['mode'], $known['layouts']);
        }
        foreach (CustomizePreview::KINDS as $kind) {
            foreach (LayoutPointers::AUDIENCES as $audience) {
                LayoutPointers::setForAudience($tpl, $kind, $audience, $state['layouts']['audience'][$kind][$audience]);
            }
            if ($state['layouts']['mode'] === LayoutPointers::MODE_AREA) {
                foreach (array_keys(PageArea::LABELS) as $area) {
                    LayoutPointers::setForArea($tpl, $kind, $area, $state['layouts']['area'][$kind][$area]);
                }
            }
        }

        // What is saved is now what the frame should keep drawing.
        $saved = $this->savedState($template, $known);
        $saved['theme'] = $state['theme'];
        CustomizePreview::put($saved);
        $this->json(['ok' => true, 'state' => $saved]);
    }

    // ---------------------------------------------------------------- state

    /**
     * What exists: the schemes that can be activated, the layouts of each
     * kind, and the colour schema.
     *
     * @return array{styles: list<string>, layouts: array<string, list<string>>, colors: array<string,mixed>}
     */
    private function known(Template $template): array
    {
        $styles = [];
        foreach ($template->getStyles() as $name) {
            // Dark is a mode on top of a scheme, not a scheme (see StylesController).
            if ((($this->styleMeta($template, $name)['variables']['colorMode'] ?? 'light')) !== 'dark') {
                $styles[] = (string)$name;
            }
        }
        $layouts = [];
        foreach (CustomizePreview::KINDS as $kind) {
            $layouts[$kind] = array_values(array_map('strval', $template->getLayouts($kind)));
        }
        return [
            'styles'  => $styles,
            'layouts' => $layouts,
            'colors'  => ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/colors.php'),
        ];
    }

    /**
     * The state the site is drawing now, in the shape normalise() returns.
     *
     * @param array{styles: list<string>, layouts: array<string, list<string>>, colors: array<string,mixed>} $known
     * @return array<string,mixed>
     */
    private function savedState(Template $template, array $known): array
    {
        $tpl   = $template->getName();
        $style = $template->resolveStyleName((string)Settings::getValue($tpl . '_active_style', 'default'));
        if (!in_array($style, $known['styles'], true)) {
            $style = $known['styles'][0] ?? 'default';
        }
        $meta = $this->styleMeta($template, $style);

        $colors = [];
        foreach (['light', 'dark'] as $scope) {
            $colors[$scope] = $this->storedColors($template, $style, $meta, $known['colors'], $scope);
        }

        $layouts = ['mode' => LayoutPointers::mode($tpl)];
        foreach (CustomizePreview::KINDS as $kind) {
            $valid = $known['layouts'][$kind];
            foreach (LayoutPointers::AUDIENCES as $audience) {
                $layouts['audience'][$kind][$audience] = LayoutPointers::forAudience($tpl, $kind, $audience, $valid);
            }
            foreach (array_keys(PageArea::LABELS) as $area) {
                // An area never picked for shows what LayoutPointers::setMode()
                // would start it from: the pick most of its visitors see today.
                $layouts['area'][$kind][$area] =
                    (string)Settings::getValue(LayoutPointers::areaKey($tpl, $kind, $area), '') !== ''
                        ? LayoutPointers::forArea($tpl, $kind, $area, $valid)
                        : LayoutPointers::forAudience($tpl, $kind, $area === PageArea::CLIENT ? 'client' : 'guest', $valid);
            }
        }

        $darkOn = (bool)Settings::getValue('enable_dark_mode', true);
        return [
            'style'   => $style,
            'theme'   => $darkOn && (string)Settings::getValue('dark_mode_default', 'light') === 'dark' ? 'dark' : 'light',
            'colors'  => $colors,
            'layouts' => $layouts,
        ];
    }

    /** @return array<string,mixed> a scheme's style.php */
    private function styleMeta(Template $template, string $style): array
    {
        return ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/styles/' . $style . '/style.php');
    }

    /**
     * The palette a scheme ships, as overrides of the schema.
     *
     * @param array<string,mixed> $meta
     * @param array<string,mixed> $cfg
     * @return array<string,string>
     */
    private function shippedColors(array $meta, array $cfg, string $scope): array
    {
        $declared = $meta['colors'][$scope] ?? null;
        return is_array($declared) ? ColorTokens::diff($declared, $cfg, $scope) : [];
    }

    /**
     * The colours the site draws for a scheme, or would draw once it is
     * activated. Same read order as Service\Hooks::buildColorsHead (the
     * per-scope row, then the pre-refactor keys); a scheme with no row yet
     * gets the palette it ships, which is what activating it writes.
     *
     * @param array<string,mixed> $meta
     * @param array<string,mixed> $cfg
     * @return array<string,string>
     */
    private function storedColors(Template $template, string $style, array $meta, array $cfg, string $scope): array
    {
        $tpl  = $template->getName();
        $keys = $scope === 'dark'
            ? ['_colors_' . $style . '_dark', '_colors_dark']
            : ['_colors_' . $style . '_light', '_colors_' . $style];
        foreach ($keys as $key) {
            $rows = Settings::getValue($tpl . $key, null);
            if (is_array($rows) && $rows !== []) {
                return ColorTokens::diff($rows, $cfg, $scope);
            }
        }
        // A row that exists but is empty is the site's own choice (every
        // colour reset), not a scheme that was never set up.
        if (Settings::getValue($tpl . $keys[0], null) !== null) {
            return [];
        }
        return $this->shippedColors($meta, $cfg, $scope);
    }

    // -------------------------------------------------------------- helpers

    /**
     * Pages offered in the preview's page list, by area. Paths are relative
     * to the site root and use the forms that work with and without friendly
     * URLs. Client-area pages are offered only while this browser also holds
     * a client session (Login as Client): without one WHMCS answers them with
     * the sign-in page.
     *
     * @return list<array{area:string, label:string, path:string}>
     */
    private function previewPages(): array
    {
        $pages = [
            ['area' => PageArea::WEBSITE, 'label' => 'Homepage',        'path' => 'index.php'],
            ['area' => PageArea::WEBSITE, 'label' => 'Sign in',         'path' => 'index.php?rp=/login'],
            ['area' => PageArea::WEBSITE, 'label' => 'Knowledgebase',   'path' => 'index.php?rp=/knowledgebase'],
            ['area' => PageArea::WEBSITE, 'label' => 'Announcements',   'path' => 'index.php?rp=/announcements'],
            ['area' => PageArea::WEBSITE, 'label' => 'Contact',         'path' => 'contact.php'],
            ['area' => PageArea::ORDER,   'label' => 'Products',        'path' => 'cart.php'],
            ['area' => PageArea::ORDER,   'label' => 'Domain search',   'path' => 'cart.php?a=add&domain=register'],
            ['area' => PageArea::ORDER,   'label' => 'Cart',            'path' => 'cart.php?a=view'],
            ['area' => PageArea::CLIENT,  'label' => 'Open a ticket',   'path' => 'submitticket.php'],
        ];
        if (!empty($_SESSION['uid'])) {
            array_push(
                $pages,
                ['area' => PageArea::CLIENT, 'label' => 'Dashboard', 'path' => 'clientarea.php'],
                ['area' => PageArea::CLIENT, 'label' => 'Services',  'path' => 'clientarea.php?action=services'],
                ['area' => PageArea::CLIENT, 'label' => 'Invoices',  'path' => 'clientarea.php?action=invoices'],
                ['area' => PageArea::CLIENT, 'label' => 'Tickets',   'path' => 'supporttickets.php']
            );
        }
        foreach ($pages as &$page) {
            $page['areaLabel'] = PageArea::LABELS[$page['area']];
        }
        return $pages;
    }

    /** @return array<string,mixed> the `state` field of the request, decoded */
    private function postedState(): array
    {
        // WHMCS escapes every POST value on the way in; undo that before
        // decoding, as MenuController does for its items_json.
        $raw   = html_entity_decode((string)($_POST['state'] ?? ''), ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $state = json_decode($raw, true);
        if (!is_array($state)) {
            AdminAjax::refuse('The request carried no state.', 400);
        }
        return $state;
    }

    private function templateOrRefuse(): Template
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            AdminAjax::refuse('No active template.', 409);
        }
        return $template;
    }

    /** @param array<string,mixed> $payload */
    private function json(array $payload): never
    {
        while (ob_get_level() > 0) {
            @ob_end_clean();
        }
        if (!headers_sent()) {
            header('Content-Type: application/json; charset=utf-8');
            header('X-Content-Type-Options: nosniff');
            header('Cache-Control: no-store');
        }
        echo (string)json_encode($payload, JSON_UNESCAPED_SLASHES);
        exit;
    }
}
