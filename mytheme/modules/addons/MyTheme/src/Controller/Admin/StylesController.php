<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;

final class StylesController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['style'])) {
            return $this->saveAction($template);
        }

        $this->migrateColors($template);

        $available = $template->getStyles();
        $current   = Settings::getValue($template->getName() . '_active_style', 'default');
        if ($current === 'dark') { $current = 'default'; }

        $list = [];
        foreach ($available as $name) {
            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . "/core/styles/{$name}/style.php"
            );
            // Dark-colorMode entries are no longer activatable styles: dark is a
            // per-style color SCOPE now (edited via the Light/Dark toggle in the
            // Colors panel), not a standalone style.
            if ((($meta['variables']['colorMode'] ?? 'light') === 'dark')) {
                continue;
            }
            $list[] = [
                'name'        => $name,
                'displayName' => $meta['name'] ?? ucfirst($name),
                'preview'     => $meta['preview'] ?? 'thumb.png',
                'isActive'    => $name === $current,
            ];
        }

        return $this->view('styles/index', [
            'styles'   => $list,
            'template' => $template->getName(),
        ]);
    }

    public function editAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }
        // PRG: Typography form submit (mirrors saveAction — don't re-enter).
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_typography'])) {
            return $this->saveTypographyAction($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_custom_css_save'])) {
            return $this->saveCustomCss($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_colors'])) {
            return $this->saveColorsAction($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_buttons'])) {
            return $this->saveButtonsAction($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_forms'])) {
            return $this->saveFormsAction($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_layout'])) {
            return $this->saveLayoutAction($template);
        }
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['mt_elements'])) {
            return $this->saveElementsAction($template);
        }

        $style  = (string)($_GET['style'] ?? 'default');
        $subcat = (string)($_GET['subcat'] ?? 'colors');
        $tab    = (string)($_GET['tab'] ?? 'variables');
        $scope  = (($_GET['scope'] ?? 'light') === 'dark') ? 'dark' : 'light';
        if (!in_array($tab, ['variables', 'settings', 'custom-css'], true)) {
            $tab = 'variables';
        }
        $this->migrateColors($template);

        return $this->view('styles/edit', [
            'template'    => $template->getName(),
            'style'       => $style,
            'styleName'   => ucfirst($style),
            'subcat'      => $subcat,
            'tab'         => $tab,
            'colorScope'  => $scope,
            // Built only for the Variables tab (the only one that renders them),
            // so the other tabs skip the folder scan + view-model work.
            'colors'      => $tab === 'variables' ? $this->buildColorsViewModel($template, $style, $scope) : null,
            'typography'  => $tab === 'variables' ? $this->buildTypographyViewModel($template) : null,
            'buttons'     => $tab === 'variables' ? $this->buildButtonsViewModel($template) : null,
            'forms'       => $tab === 'variables' ? $this->buildFormsViewModel($template) : null,
            'layoutVars'  => $tab === 'variables' ? $this->buildLayoutViewModel($template) : null,
            'elements'    => $tab === 'variables' ? $this->buildElementsViewModel($template) : null,
            'saved'       => isset($_GET['saved']),
            'colorsSaved' => isset($_GET['colors_saved']),
            'buttonsSaved'=> isset($_GET['buttons_saved']),
            'formsSaved'  => isset($_GET['forms_saved']),
            'layoutSaved' => isset($_GET['layout_saved']),
            'elementsSaved'=> isset($_GET['elements_saved']),
            'customCss'   => (string)Settings::getValue($template->getName() . '_custom_css', ''),
            'cssSaved'    => isset($_GET['css_saved']),
        ]);
    }

    private function saveAction($template): string
    {
        $style = (string)$_POST['style'];
        if (in_array($style, $template->getStyles(), true)) {
            Settings::setValue($template->getName() . '_active_style', $style);
        }
        // PRG — see LayoutsController::saveAction for why we don't
        // re-enter indexAction() directly.
        $this->redirect('?module=MyTheme&action=styles');
    }

    /**
     * Load the typography schema/defaults — single source of truth shared with
     * the render-time emitter (Hooks::buildTypographyHead).
     */
    private function loadTypographyConfig($template): array
    {
        return ThemeManifest::loadVariantMeta(
            $template->getFullPath() . '/core/config/typography.php'
        );
    }

    /**
     * Scan assets/fonts/custom for buyer-dropped web fonts. Each becomes a
     * pickable "Your fonts" option. The regex doubles as a filename allowlist
     * (letters/numbers/._- + a font extension), so stored values can't traverse.
     *
     * @return list<array{file:string, name:string}>
     */
    private function scanFontFolder($template): array
    {
        $dir = $template->getFullPath() . '/assets/fonts/custom';
        if (!is_dir($dir)) {
            return [];
        }
        $out = [];
        foreach ((array)scandir($dir) as $file) {
            if (!preg_match('/^[A-Za-z0-9._-]+\.(?:woff2|woff|ttf|otf)$/i', (string)$file)) {
                continue;
            }
            $out[] = ['file' => $file, 'name' => pathinfo($file, PATHINFO_FILENAME)];
        }
        return $out;
    }

    /**
     * Merge stored overrides onto the schema defaults so the form shows each
     * token's current EFFECTIVE value.
     */
    private function buildTypographyViewModel($template): array
    {
        $cfg    = $this->loadTypographyConfig($template);
        $stored = Settings::getValue($template->getName() . '_typography', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $sizesStored   = is_array($stored['sizes'] ?? null)      ? $stored['sizes']      : [];
        $weightsStored = is_array($stored['weights'] ?? null)    ? $stored['weights']    : [];
        $ff            = is_array($stored['fontFamily'] ?? null) ? $stored['fontFamily'] : [];
        $folderFonts   = $this->scanFontFolder($template);

        $sizeGroups = [];
        foreach (($cfg['sizeGroups'] ?? []) as $group => $items) {
            foreach ($items as $it) {
                $it['value'] = (int)($sizesStored[$it['var']] ?? $it['default']);
                $sizeGroups[$group][] = $it;
            }
        }
        $weights = [];
        foreach (($cfg['weights'] ?? []) as $it) {
            $it['value'] = (int)($weightsStored[$it['var']] ?? $it['default']);
            $weights[] = $it;
        }

        // Effective "how it's written" stack per mode: the stored override for the
        // active mode, else a freshly-derived stack from that mode's pick. The
        // editable field pre-fills with this; on save it becomes the stored value.
        $fallback    = (string)($cfg['fontFamily']['fallback'] ?? 'system-ui, sans-serif');
        $applePrefix = (string)($cfg['fontFamily']['applePrefix'] ?? '-apple-system, BlinkMacSystemFont');
        $ffMode      = (string)($ff['mode'] ?? 'default');
        $storedStack = (string)($ff['stack'] ?? '');
        $bundledFam  = 'Inter';
        foreach (($cfg['bundledFonts'] ?? []) as $bf) {
            if (($bf['file'] ?? '') === (string)($ff['bundled'] ?? '')) {
                $bundledFam = (string)($bf['family'] ?? $bundledFam);
                break;
            }
        }
        $stacks = [
            'system'  => ($ffMode === 'system'  && $storedStack !== '') ? $storedStack : (string)($cfg['fontFamily']['system'] ?? $fallback),
            'google'  => ($ffMode === 'google'  && $storedStack !== '') ? $storedStack : ((string)($ff['google'] ?? '') !== '' ? "'" . (string)$ff['google'] . "', " . $fallback : ''),
            'folder'  => ($ffMode === 'folder'  && $storedStack !== '') ? $storedStack : ((string)($ff['folder'] ?? '') !== '' ? '"' . pathinfo((string)$ff['folder'], PATHINFO_FILENAME) . '", ' . $fallback : ''),
            'bundled' => ($ffMode === 'bundled' && $storedStack !== '') ? $storedStack : '"' . $bundledFam . '", ' . $fallback,
        ];
        $leadsApple = static fn (string $s): bool => (bool)preg_match('/^\s*(-apple-system|BlinkMacSystemFont)/', $s);

        return [
            'sizeGroups'    => $sizeGroups,
            'weights'       => $weights,
            'weightOptions' => $cfg['weightOptions'] ?? [300, 400, 500, 600, 700, 900],
            'googleFonts'   => $cfg['googleFonts'] ?? [],
            'sizeMin'       => (int)($cfg['sizeMin'] ?? 8),
            'sizeMax'       => (int)($cfg['sizeMax'] ?? 160),
            'folderFonts'   => $folderFonts,
            'bundledFonts'  => $cfg['bundledFonts'] ?? [],
            'stacks'        => $stacks,
            'ffFallback'    => $fallback,
            'ffApplePrefix' => $applePrefix,
            'fontFamily'    => [
                'mode'         => $ffMode,
                'google'       => (string)($ff['google']  ?? ''),
                'folder'       => (string)($ff['folder']  ?? ''),
                'bundled'      => (string)($ff['bundled'] ?? ''),
                'folderApple'  => $leadsApple($stacks['folder']),
                'bundledApple' => $leadsApple($stacks['bundled']),
            ],
        ];
    }

    /**
     * Validate + persist the Typography form. Stores ONLY values that differ
     * from default (keeps the override set minimal; the emitter renders exactly
     * what's stored). PRG redirect back to the Typography subcat.
     */
    private function saveTypographyAction($template): string
    {
        $cfg            = $this->loadTypographyConfig($template);
        $min            = (int)($cfg['sizeMin'] ?? 8);
        $max            = (int)($cfg['sizeMax'] ?? 160);
        $allowedWeights = array_map('intval', $cfg['weightOptions'] ?? [300, 400, 500, 600, 700, 900]);

        $out = [];

        // Sizes — keep only values that differ from default and pass bounds.
        $sizes = [];
        foreach (($cfg['sizeGroups'] ?? []) as $items) {
            foreach ($items as $it) {
                $key = 'size_' . str_replace('--', '', $it['var']);
                if (!isset($_POST[$key]) || $_POST[$key] === '') {
                    continue;
                }
                $val = (int)$_POST[$key];
                if ($val < $min || $val > $max || $val === (int)$it['default']) {
                    continue;
                }
                $sizes[$it['var']] = $val;
            }
        }
        if ($sizes !== []) {
            $out['sizes'] = $sizes;
        }

        // Weights
        $weights = [];
        foreach (($cfg['weights'] ?? []) as $it) {
            $key = 'weight_' . str_replace('--', '', $it['var']);
            if (!isset($_POST[$key])) {
                continue;
            }
            $val = (int)$_POST[$key];
            if (!in_array($val, $allowedWeights, true) || $val === (int)$it['default']) {
                continue;
            }
            $weights[$it['var']] = $val;
        }
        if ($weights !== []) {
            $out['weights'] = $weights;
        }

        // Font family. The admin-editable "stack" string (the exact value written to
        // --font-family) is the source of truth for what's EMITTED; the picked font
        // drives what's LOADED. Apple-first is encoded directly in the stack string
        // (a leading -apple-system/BlinkMacSystemFont), so no separate flag is kept.
        $mode      = (string)($_POST['ff_mode'] ?? 'default');
        $stackKey  = ['system' => 'ff_system', 'google' => 'ff_google_stack', 'folder' => 'ff_folder_stack', 'bundled' => 'ff_bundled_stack'][$mode] ?? '';
        $stack     = $stackKey !== '' ? trim((string)($_POST[$stackKey] ?? '')) : '';
        $withStack = static fn (array $base): array => $base + ($stack !== '' ? ['stack' => $stack] : []);
        if ($mode === 'system') {
            $out['fontFamily'] = $withStack(['mode' => 'system']);
        } elseif ($mode === 'google' && trim((string)($_POST['ff_google'] ?? '')) !== '') {
            $out['fontFamily'] = $withStack(['mode' => 'google', 'google' => trim((string)$_POST['ff_google'])]);
        } elseif ($mode === 'folder' && trim((string)($_POST['ff_folder'] ?? '')) !== '') {
            // Self-hosted: the admin types the font-face NAME; Hooks @font-faces a
            // matching file in assets/fonts/custom. Allow letters/digits/space/_/-.
            $name = trim((string)preg_replace('/[^A-Za-z0-9 _-]/', '', (string)$_POST['ff_folder']));
            if ($name !== '') {
                $out['fontFamily'] = $withStack(['mode' => 'folder', 'folder' => $name]);
            }
        } elseif ($mode === 'bundled' && trim((string)($_POST['ff_bundled'] ?? '')) !== '') {
            // Only accept a filename registered in core/config/typography.php.
            $file = basename(trim((string)$_POST['ff_bundled']));
            foreach (($cfg['bundledFonts'] ?? []) as $bf) {
                if (($bf['file'] ?? '') === $file) {
                    $out['fontFamily'] = $withStack(['mode' => 'bundled', 'bundled' => $file]);
                    break;
                }
            }
        }

        Settings::setValue($template->getName() . '_typography', $out, 'json');

        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=typography&saved=1');
    }

    /**
     * Persist the global Custom CSS box (site-wide, all styles). Stored raw so
     * the textarea round-trips exactly; the render-time emitter
     * (Hooks::buildCustomCss) neutralizes any </style> on output.
     */
    private function saveCustomCss($template): string
    {
        Settings::setValue($template->getName() . '_custom_css', (string)($_POST['custom_css'] ?? ''), 'string');
        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&tab=custom-css&css_saved=1');
    }

    /** Accept a hex (#rgb/#rgba/#rrggbb/#rrggbbaa) or rgb()/rgba()/hsl()/hsla() value. */
    private function isColor(string $v): bool
    {
        $v = trim($v);
        return (bool)(
            preg_match('/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/', $v)
            || preg_match('/^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
            || preg_match('/^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
        );
    }

    /** Loose equality for "did the buyer change it?" — case + whitespace insensitive. */
    private function normColor(string $v): string
    {
        return strtolower((string)preg_replace('/\s+/', '', $v));
    }

    /** Best-effort hex for the native <input type="color"> swatch (drops any alpha). */
    private function toHexInput(string $v): string
    {
        $v = trim($v);
        if (preg_match('/^#([0-9a-fA-F]{6})/', $v, $m)) {
            return '#' . strtolower($m[1]);
        }
        if (preg_match('/^#([0-9a-fA-F]{3})$/', $v, $m)) {
            $c = $m[1];
            return '#' . strtolower($c[0] . $c[0] . $c[1] . $c[1] . $c[2] . $c[2]);
        }
        if (preg_match('/rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})/i', $v, $m)) {
            return sprintf('#%02x%02x%02x', min(255, (int)$m[1]), min(255, (int)$m[2]), min(255, (int)$m[3]));
        }
        return '#000000';
    }

    /**
     * One-time migration to per-style-per-mode color storage. Older builds kept
     * a single override set per style (_colors_<style>) plus a separate "dark"
     * style (_colors_dark). The new model gives each (light) style both a light
     * and a dark scope:
     *   _colors_default -> _colors_default_light
     *   _colors_dark    -> _colors_default_dark
     * Idempotent (only copies when the target is empty); also retires a legacy
     * dark _active_style pointer back to the base style.
     */
    private function migrateColors($template): void
    {
        $name = $template->getName();
        $copy = static function (string $from, string $to) use ($name): void {
            $existing = Settings::getValue($name . '_' . $to, null);
            if (is_array($existing) && $existing !== []) {
                return; // already migrated
            }
            $old = Settings::getValue($name . '_' . $from, null);
            if (is_array($old) && $old !== []) {
                Settings::setValue($name . '_' . $to, $old, 'json');
            }
        };
        $copy('colors_default', 'colors_default_light');
        $copy('colors_dark', 'colors_default_dark');
        if ((string)Settings::getValue($name . '_active_style', 'default') === 'dark') {
            Settings::setValue($name . '_active_style', 'default', 'string');
        }
    }

    /**
     * View-model for the Colors subcat. Loads the token schema (core/config/
     * colors.php), resolves the editable scope (light|dark), and merges stored
     * overrides onto the per-mode defaults so every row shows its EFFECTIVE value.
     */
    private function buildColorsViewModel($template, string $style, string $scope = 'light'): array
    {
        $cfg    = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/colors.php');
        // Scope (light|dark) is the editable color mode — a property of THIS
        // edit session, not the style. Each style stores its two scopes under
        // _colors_<style>_light / _colors_<style>_dark.
        $mode   = $scope === 'dark' ? 'dark' : 'light';
        $stored = Settings::getValue($template->getName() . '_colors_' . $style . '_' . $mode, []);
        if (!is_array($stored)) {
            $stored = [];
        }

        $groups = [];
        foreach (($cfg['groups'] ?? []) as $groupName => $tokens) {
            foreach ($tokens as $t) {
                $default      = (string)($t[$mode] ?? $t['light'] ?? '#000000');
                $value        = isset($stored[$t['var']]) ? (string)$stored[$t['var']] : $default;
                $t['default'] = $default;
                $t['value']   = $value;
                $t['hex']     = $this->toHexInput($value);
                $groups[$groupName][] = $t;
            }
        }

        return [
            'groups'  => $groups,
            'presets' => $cfg['presets'] ?? [],
            'mode'    => $mode,
        ];
    }

    /**
     * Validate + persist the Colors form for one style. Stores ONLY tokens that
     * differ from the per-mode default (keeps the override set minimal; the
     * emitter renders exactly what's stored). PRG redirect to the Colors subcat.
     */
    private function saveColorsAction($template): string
    {
        $style = (string)($_POST['style'] ?? 'default');
        if (!in_array($style, $template->getStyles(), true)) {
            $style = 'default';
        }
        $scope = ((string)($_POST['scope'] ?? 'light')) === 'dark' ? 'dark' : 'light';
        $cfg  = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/colors.php');
        $mode = $scope;
        $in   = is_array($_POST['c'] ?? null) ? $_POST['c'] : [];

        $out = [];
        foreach (($cfg['groups'] ?? []) as $tokens) {
            foreach ($tokens as $t) {
                $var = (string)$t['var'];
                if (!isset($in[$var])) {
                    continue;
                }
                $val = trim((string)$in[$var]);
                if ($val === '' || !$this->isColor($val)) {
                    continue;
                }
                $default = (string)($t[$mode] ?? $t['light'] ?? '');
                if ($this->normColor($val) === $this->normColor($default)) {
                    continue;
                }
                $out[$var] = $val;
            }
        }

        Settings::setValue($template->getName() . '_colors_' . $style . '_' . $scope, $out, 'json');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=colors&scope=' . $scope . '&colors_saved=1');
    }

    /**
     * View-model for the Buttons subcat. Loads the button schema (core/config/
     * buttons.php), groups the select-colors options for <optgroup>s, and merges
     * the GLOBAL stored overrides onto the defaults so every size field shows its
     * effective value and every matrix cell shows its current option key + swatch.
     * Unlike Colors, Buttons are site-wide (one mapping styles both modes), so
     * there's no per-style key here.
     */
    private function buildButtonsViewModel($template): array
    {
        $cfg    = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/buttons.php');
        $stored = Settings::getValue($template->getName() . '_buttons', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $sizesStored    = is_array($stored['sizes'] ?? null)    ? $stored['sizes']    : [];
        $variantsStored = is_array($stored['variants'] ?? null) ? $stored['variants'] : [];

        // Group colour options for <optgroup>; build a key->option lookup for swatches.
        $optionGroups = [];
        $optionByKey  = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $optionGroups[(string)($o['group'] ?? 'Other')][] = $o;
            $optionByKey[(string)$o['key']] = $o;
        }

        // Sizes — px fields carry an int 'value'; scale fields carry the current
        // scale 'key' + that scale's 'options' (for the dropdown). Effective
        // value = stored override or default.
        $scales    = $cfg['scales'] ?? [];
        $sizeTiers = [];
        foreach (($cfg['sizeTiers'] ?? []) as $tier => $fields) {
            foreach ($fields as $f) {
                if (($f['type'] ?? 'px') === 'scale') {
                    $opts  = $scales[(string)($f['scale'] ?? '')] ?? [];
                    $cur   = (string)($sizesStored[$f['var']] ?? $f['default']);
                    $valid = false;
                    foreach ($opts as $o) {
                        if ((string)$o['key'] === $cur) { $valid = true; break; }
                    }
                    $f['current'] = $valid ? $cur : (string)$f['default'];
                    $f['options'] = $opts;
                } else {
                    $f['value'] = (int)($sizesStored[$f['var']] ?? $f['default']);
                }
                $sizeTiers[(string)$tier][] = $f;
            }
        }

        // Variant matrix — resolve each slot's current option key + preview swatch.
        $slots    = $cfg['slots'] ?? [];
        $variants = [];
        foreach (($cfg['variants'] ?? []) as $v) {
            $vStored = is_array($variantsStored[$v['key']] ?? null) ? $variantsStored[$v['key']] : [];
            $cells   = [];
            foreach ($slots as $slot) {
                $sk     = (string)$slot['key'];
                $defKey = (string)($v['slots'][$sk] ?? 'transparent');
                $curKey = (string)($vStored[$sk] ?? $defKey);
                if (!isset($optionByKey[$curKey])) {
                    $curKey = $defKey;
                }
                $cells[] = [
                    'slot'    => $sk,
                    'label'   => (string)$slot['label'],
                    'current' => $curKey,
                    'default' => $defKey,
                    'swatch'  => (string)($optionByKey[$curKey]['swatch'] ?? '#000000'),
                ];
            }
            $variants[] = ['key' => $v['key'], 'label' => $v['label'], 'cells' => $cells];
        }

        return [
            'optionGroups' => $optionGroups,
            'sizeTiers'    => $sizeTiers,
            'variants'     => $variants,
            'slots'        => $slots,
        ];
    }

    /**
     * Validate + persist the Buttons form (site-wide). Stores ONLY sizes that
     * differ from default (in-bounds) and matrix slots whose option key differs
     * from default (and is a known option). PRG redirect to the Buttons subcat.
     */
    private function saveButtonsAction($template): string
    {
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/buttons.php');
        $min = (int)($cfg['sizeMin'] ?? 0);
        $max = (int)($cfg['sizeMax'] ?? 999);

        $validKeys = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $validKeys[(string)$o['key']] = true;
        }

        $out = [];

        // Sizes — px fields: in-bounds int differing from default. scale fields:
        // a key present in that field's scale and differing from default.
        $scales  = $cfg['scales'] ?? [];
        $sizesIn = is_array($_POST['size'] ?? null) ? $_POST['size'] : [];
        $sizes   = [];
        foreach (($cfg['sizeTiers'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $var = (string)$f['var'];
                if (!isset($sizesIn[$var]) || $sizesIn[$var] === '') {
                    continue;
                }
                if (($f['type'] ?? 'px') === 'scale') {
                    $key = (string)$sizesIn[$var];
                    $ok  = false;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === $key) { $ok = true; break; }
                    }
                    if (!$ok || $key === (string)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $key;
                } else {
                    $val = (int)$sizesIn[$var];
                    if ($val < $min || $val > $max || $val === (int)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $val;
                }
            }
        }
        if ($sizes !== []) {
            $out['sizes'] = $sizes;
        }

        // Variant matrix — store only slots changed from default to a known key.
        $vIn      = is_array($_POST['v'] ?? null) ? $_POST['v'] : [];
        $variants = [];
        foreach (($cfg['variants'] ?? []) as $v) {
            $vk      = (string)$v['key'];
            $row     = is_array($vIn[$vk] ?? null) ? $vIn[$vk] : [];
            $changed = [];
            foreach (($cfg['slots'] ?? []) as $slot) {
                $sk = (string)$slot['key'];
                if (!isset($row[$sk])) {
                    continue;
                }
                $key = (string)$row[$sk];
                if (!isset($validKeys[$key])) {
                    continue;
                }
                if ($key === (string)($v['slots'][$sk] ?? '')) {
                    continue;
                }
                $changed[$sk] = $key;
            }
            if ($changed !== []) {
                $variants[$vk] = $changed;
            }
        }
        if ($variants !== []) {
            $out['variants'] = $variants;
        }

        Settings::setValue($template->getName() . '_buttons', $out, 'json');
        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=buttons&buttons_saved=1');
    }

    /**
     * View-model for the Forms subcat. Loads core/config/forms.php and merges
     * GLOBAL stored overrides onto the defaults: size fields show their px value
     * or current scale key (+ options); colour fields show their current option
     * key (+ preview swatch). Site-wide, so no per-style key. Mirrors
     * buildButtonsViewModel.
     */
    private function buildFormsViewModel($template): array
    {
        $cfg    = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/forms.php');
        $stored = Settings::getValue($template->getName() . '_forms', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $sizesStored  = is_array($stored['sizes'] ?? null)  ? $stored['sizes']  : [];
        $colorsStored = is_array($stored['colors'] ?? null) ? $stored['colors'] : [];

        // Colour options grouped for <optgroup>; key->option lookup for swatches.
        $optionGroups = [];
        $optionByKey  = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $optionGroups[(string)($o['group'] ?? 'Other')][] = $o;
            $optionByKey[(string)$o['key']] = $o;
        }

        // Size groups — px fields carry int 'value'; scale fields carry the
        // current 'key' + that scale's 'options'.
        $scales     = $cfg['scales'] ?? [];
        $sizeGroups = [];
        foreach (($cfg['sizeGroups'] ?? []) as $group => $fields) {
            foreach ($fields as $f) {
                if (($f['type'] ?? 'px') === 'scale') {
                    $opts  = $scales[(string)($f['scale'] ?? '')] ?? [];
                    $cur   = (string)($sizesStored[$f['var']] ?? $f['default']);
                    $valid = false;
                    foreach ($opts as $o) {
                        if ((string)$o['key'] === $cur) { $valid = true; break; }
                    }
                    $f['current'] = $valid ? $cur : (string)$f['default'];
                    $f['options'] = $opts;
                } else {
                    $f['value'] = (int)($sizesStored[$f['var']] ?? $f['default']);
                }
                $sizeGroups[(string)$group][] = $f;
            }
        }

        // Colour groups — resolve each field's current option key + preview swatch.
        $colorGroups = [];
        foreach (($cfg['colorGroups'] ?? []) as $group => $fields) {
            foreach ($fields as $f) {
                $defKey = (string)$f['default'];
                $curKey = (string)($colorsStored[$f['var']] ?? $defKey);
                if (!isset($optionByKey[$curKey])) {
                    $curKey = $defKey;
                }
                $f['current'] = $curKey;
                $f['swatch']  = (string)($optionByKey[$curKey]['swatch'] ?? '#000000');
                $colorGroups[(string)$group][] = $f;
            }
        }

        return [
            'optionGroups' => $optionGroups,
            'sizeGroups'   => $sizeGroups,
            'colorGroups'  => $colorGroups,
        ];
    }

    /**
     * Validate + persist the Forms form (site-wide). Stores ONLY sizes/colours
     * that differ from default; size scale keys must exist in their scale and
     * colour keys must be known options. PRG redirect to the Forms subcat.
     */
    private function saveFormsAction($template): string
    {
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/forms.php');
        $min = (int)($cfg['sizeMin'] ?? 0);
        $max = (int)($cfg['sizeMax'] ?? 999);

        $validKeys = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $validKeys[(string)$o['key']] = true;
        }

        $out = [];

        // Sizes — px int or scale key, differing from default.
        $scales  = $cfg['scales'] ?? [];
        $sizesIn = is_array($_POST['size'] ?? null) ? $_POST['size'] : [];
        $sizes   = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $var = (string)$f['var'];
                if (!isset($sizesIn[$var]) || $sizesIn[$var] === '') {
                    continue;
                }
                if (($f['type'] ?? 'px') === 'scale') {
                    $key = (string)$sizesIn[$var];
                    $ok  = false;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === $key) { $ok = true; break; }
                    }
                    if (!$ok || $key === (string)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $key;
                } else {
                    $val = (int)$sizesIn[$var];
                    if ($val < $min || $val > $max || $val === (int)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $val;
                }
            }
        }
        if ($sizes !== []) {
            $out['sizes'] = $sizes;
        }

        // Colours — option key differing from default + known.
        $colorsIn = is_array($_POST['c'] ?? null) ? $_POST['c'] : [];
        $colors   = [];
        foreach (($cfg['colorGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $var = (string)$f['var'];
                if (!isset($colorsIn[$var])) {
                    continue;
                }
                $key = (string)$colorsIn[$var];
                if (!isset($validKeys[$key]) || $key === (string)$f['default']) {
                    continue;
                }
                $colors[$var] = $key;
            }
        }
        if ($colors !== []) {
            $out['colors'] = $colors;
        }

        Settings::setValue($template->getName() . '_forms', $out, 'json');
        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=forms&forms_saved=1');
    }

    /**
     * View-model for the Layout subcat — page-structure dimensions (px). Merges
     * GLOBAL stored overrides onto the core/config/layout.php defaults so each
     * field shows its effective value. Site-wide; no per-style key.
     */
    private function buildLayoutViewModel($template): array
    {
        $cfg    = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        $stored = Settings::getValue($template->getName() . '_layout_vars', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $sizeGroups = [];
        foreach (($cfg['sizeGroups'] ?? []) as $group => $fields) {
            foreach ($fields as $f) {
                $f['value'] = (int)($stored[$f['var']] ?? $f['default']);
                $sizeGroups[(string)$group][] = $f;
            }
        }
        return ['sizeGroups' => $sizeGroups];
    }

    /**
     * Validate + persist the Layout form (site-wide). Keeps only in-bounds px
     * values that differ from default. PRG redirect to the Layout subcat. Uses
     * the `_layout_vars` key to avoid colliding with the Layouts manager's
     * `_active_layout_*` / `_layout_opts_*` settings.
     */
    private function saveLayoutAction($template): string
    {
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        $min = (int)($cfg['sizeMin'] ?? 0);
        $max = (int)($cfg['sizeMax'] ?? 4000);
        $in  = is_array($_POST['size'] ?? null) ? $_POST['size'] : [];

        $out = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $var = (string)$f['var'];
                if (!isset($in[$var]) || $in[$var] === '') {
                    continue;
                }
                $val = (int)$in[$var];
                if ($val < $min || $val > $max || $val === (int)$f['default']) {
                    continue;
                }
                $out[$var] = $val;
            }
        }

        Settings::setValue($template->getName() . '_layout_vars', $out, 'json');
        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=layout&layout_saved=1');
    }

    /**
     * View-model for the Elements subcat — component shape (radius/shadow/
     * padding). Px fields carry an int 'value'; scale fields carry 'current' +
     * 'options'. Merges GLOBAL stored overrides onto core/config/elements.php
     * defaults. Site-wide; no per-style key. (Same size shape as Forms.)
     */
    private function buildElementsViewModel($template): array
    {
        $cfg    = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/elements.php');
        $stored = Settings::getValue($template->getName() . '_elements', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $sizesStored = is_array($stored['sizes'] ?? null) ? $stored['sizes'] : [];

        $scales     = $cfg['scales'] ?? [];
        $sizeGroups = [];
        foreach (($cfg['sizeGroups'] ?? []) as $group => $fields) {
            foreach ($fields as $f) {
                if (($f['type'] ?? 'px') === 'scale') {
                    $opts  = $scales[(string)($f['scale'] ?? '')] ?? [];
                    $cur   = (string)($sizesStored[$f['var']] ?? $f['default']);
                    $valid = false;
                    foreach ($opts as $o) {
                        if ((string)$o['key'] === $cur) { $valid = true; break; }
                    }
                    $f['current'] = $valid ? $cur : (string)$f['default'];
                    $f['options'] = $opts;
                } else {
                    $f['value'] = (int)($sizesStored[$f['var']] ?? $f['default']);
                }
                $sizeGroups[(string)$group][] = $f;
            }
        }

        return ['sizeGroups' => $sizeGroups];
    }

    /**
     * Validate + persist the Elements form (site-wide). px int / scale key,
     * differing from default. PRG redirect to the Elements subcat.
     */
    private function saveElementsAction($template): string
    {
        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/elements.php');
        $min = (int)($cfg['sizeMin'] ?? 0);
        $max = (int)($cfg['sizeMax'] ?? 999);

        $scales  = $cfg['scales'] ?? [];
        $sizesIn = is_array($_POST['size'] ?? null) ? $_POST['size'] : [];
        $sizes   = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $var = (string)$f['var'];
                if (!isset($sizesIn[$var]) || $sizesIn[$var] === '') {
                    continue;
                }
                if (($f['type'] ?? 'px') === 'scale') {
                    $key = (string)$sizesIn[$var];
                    $ok  = false;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === $key) { $ok = true; break; }
                    }
                    if (!$ok || $key === (string)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $key;
                } else {
                    $val = (int)$sizesIn[$var];
                    if ($val < $min || $val > $max || $val === (int)$f['default']) {
                        continue;
                    }
                    $sizes[$var] = $val;
                }
            }
        }

        Settings::setValue($template->getName() . '_elements', ($sizes !== [] ? ['sizes' => $sizes] : []), 'json');
        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=elements&elements_saved=1');
    }
}
