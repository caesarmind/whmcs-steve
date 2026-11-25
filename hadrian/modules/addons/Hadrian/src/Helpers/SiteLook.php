<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Settings;
use Hadrian\Template\Template;

/**
 * The site's look: its style (colour scheme), its navigation and footer
 * layouts, and light or dark. What exists, what is saved, and a preview of
 * another pick for one admin.
 *
 * Two screens read it:
 *   - the customizer (Controller\Admin\CustomizeController), which tries a
 *     look out and saves it
 *   - add-on modules, through options() and preview(), to draw one of their
 *     pages under a look the site does not use yet. Hadrian Page Builder's
 *     editor does this: "Preview with" above its page. Nothing is saved.
 *
 * The preview goes through CustomizePreview's second slot (hadrian_look), so
 * it never touches unsaved work in the customizer.
 */
final class SiteLook
{
    // ------------------------------------------------------------ what exists

    /**
     * The schemes that can be activated, the layouts of each kind, and the
     * colour schema.
     *
     * @return array{styles: list<string>, layouts: array<string, list<string>>, colors: array<string,mixed>}
     */
    public static function known(Template $template): array
    {
        $styles = [];
        foreach ($template->getStyles() as $name) {
            // Dark is a mode on top of a scheme, not a scheme (see StylesController).
            if (((self::styleMeta($template, (string)$name)['variables']['colorMode'] ?? 'light')) !== 'dark') {
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

    /** @return array<string,mixed> a scheme's style.php */
    public static function styleMeta(Template $template, string $style): array
    {
        return ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/styles/' . $style . '/style.php');
    }

    /** A layout's name as its manifest gives it. */
    public static function layoutLabel(Template $template, string $kind, string $name): string
    {
        $meta = ThemeManifest::loadVariantMeta($template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php");
        return (string)($meta['displayName'] ?? ucfirst($name));
    }

    // ------------------------------------------------------------- what is saved

    /**
     * The state the site is drawing now, in the shape CustomizePreview::normalise()
     * returns.
     *
     * @param array{styles: list<string>, layouts: array<string, list<string>>, colors: array<string,mixed>} $known
     * @return array<string,mixed>
     */
    public static function savedState(Template $template, array $known): array
    {
        $tpl   = $template->getName();
        $style = $template->resolveStyleName((string)Settings::getValue($tpl . '_active_style', 'default'));
        if (!in_array($style, $known['styles'], true)) {
            $style = $known['styles'][0] ?? 'default';
        }

        $colors = [];
        foreach (['light', 'dark'] as $scope) {
            $colors[$scope] = self::storedColors($template, $style, $known['colors'], $scope);
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

    /**
     * The palette a scheme ships, as overrides of the schema.
     *
     * @param array<string,mixed> $meta
     * @param array<string,mixed> $cfg
     * @return array<string,string>
     */
    public static function shippedColors(array $meta, array $cfg, string $scope): array
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
     * @param array<string,mixed> $cfg
     * @return array<string,string>
     */
    public static function storedColors(Template $template, string $style, array $cfg, string $scope): array
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
        return self::shippedColors(self::styleMeta($template, $style), $cfg, $scope);
    }

    // --------------------------------------------- for an add-on's preview

    /**
     * What an add-on needs to offer "Preview with": every style with its
     * accent colour, every layout of each kind, and the pick the site uses.
     * Null when there is no active Hadrian template.
     *
     * `site.nav` and `site.footer` are what a website page draws: the guest
     * pick when layouts go by visitor, the website pick when they go by area.
     *
     * @return array{styles: list<array{name:string,label:string,accent:string}>,
     *               layouts: array<string, list<array{name:string,label:string}>>,
     *               site: array{style:string,nav:string,footer:string,theme:string},
     *               darkMode: bool}|null
     */
    public static function options(): ?array
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return null;
        }
        $known  = self::known($template);
        $saved  = self::savedState($template, $known);
        $schema = ColorTokens::schema($known['colors']);
        $defaultAccent = (string)($schema['--color-accent']['light'] ?? '#0071e3');

        $styles = [];
        foreach ($known['styles'] as $name) {
            $meta = self::styleMeta($template, $name);
            $light = self::storedColors($template, $name, $known['colors'], 'light');
            $styles[] = [
                'name'   => $name,
                'label'  => (string)($meta['name'] ?? ucfirst($name)),
                'accent' => (string)($light['--color-accent'] ?? $defaultAccent),
            ];
        }
        $layouts = [];
        foreach (CustomizePreview::KINDS as $kind) {
            foreach ($known['layouts'][$kind] as $name) {
                $layouts[$kind][] = ['name' => $name, 'label' => self::layoutLabel($template, $kind, $name)];
            }
        }
        $byArea = $saved['layouts']['mode'] === LayoutPointers::MODE_AREA;
        $pick   = static fn(string $kind): string => (string)($byArea
            ? $saved['layouts']['area'][$kind][PageArea::WEBSITE]
            : $saved['layouts']['audience'][$kind]['guest']);

        return [
            'styles'   => $styles,
            'layouts'  => $layouts,
            'site'     => ['style' => $saved['style'], 'nav' => $pick('main-menu'), 'footer' => $pick('footer'), 'theme' => $saved['theme']],
            'darkMode' => (bool)Settings::getValue('enable_dark_mode', true),
        ];
    }

    /**
     * Hold a look for this admin's previews and return the token a preview
     * URL carries as CustomizePreview::LOOK_PARAM. '' when there is nothing to
     * preview: no template, or the pick is what the site already draws (the
     * page is then previewed as it really is, per-page layouts included).
     *
     * @param array<string,mixed> $pick style, nav, footer, theme; anything unknown keeps the saved value
     */
    public static function preview(array $pick): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return '';
        }
        $known = self::known($template);
        $saved = self::savedState($template, $known);
        $site  = self::options()['site'] ?? null;

        $style  = is_string($pick['style'] ?? null) && in_array($pick['style'], $known['styles'], true) ? $pick['style'] : $saved['style'];
        $nav    = is_string($pick['nav'] ?? null) && in_array($pick['nav'], $known['layouts']['main-menu'], true) ? $pick['nav'] : null;
        $footer = is_string($pick['footer'] ?? null) && in_array($pick['footer'], $known['layouts']['footer'], true) ? $pick['footer'] : null;
        $theme  = in_array($pick['theme'] ?? null, ['light', 'dark'], true) ? (string)$pick['theme'] : $saved['theme'];

        if ($site !== null && $style === $site['style'] && ($nav ?? $site['nav']) === $site['nav']
            && ($footer ?? $site['footer']) === $site['footer'] && $theme === $site['theme']) {
            return '';
        }

        $state = $saved;
        $state['style'] = $style;
        $state['theme'] = $theme;
        foreach (['light', 'dark'] as $scope) {
            $state['colors'][$scope] = self::storedColors($template, $style, $known['colors'], $scope);
        }
        // One pick for every visitor and every area, whichever way the site
        // chooses its layouts.
        foreach (['main-menu' => $nav, 'footer' => $footer] as $kind => $name) {
            if ($name === null) {
                continue;
            }
            foreach (array_keys($state['layouts']['audience'][$kind]) as $slot) {
                $state['layouts']['audience'][$kind][$slot] = $name;
            }
            foreach (array_keys($state['layouts']['area'][$kind]) as $slot) {
                $state['layouts']['area'][$kind][$slot] = $name;
            }
        }
        return CustomizePreview::putLook($state);
    }
}
