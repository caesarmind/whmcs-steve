<?php
declare(strict_types=1);

namespace MyTheme\Service;

use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\LocaleHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Helpers\Uploader;
use MyTheme\Models\Settings;
use MyTheme\Template\Template;

/**
 * Front-of-house hook service.
 *
 * Replaces "6 separate ClientAreaPage hook registrations + 200-line god-function"
 * with a single registration that calls dispatch(), routing by hook name to a
 * method here. One hook → one method → easy to read, easy to test, easy to extend.
 */
final class Hooks
{
    private static ?self $instance = null;

    public static function instance(): self
    {
        return self::$instance ??= new self();
    }

    public function dispatch(string $hookName, mixed $hookArg): mixed
    {
        $template = AddonHelper::getTemplate();
        // Don't gate the dispatch on canActivate(). The theme renders
        // the license-required error screen via the template-level
        // $mtLicenseGateEnabled flag in header.tpl / footer.tpl — that's
        // the right place to enforce licensing UX, not the data-assembly
        // hook. Suppressing the entire $myTheme payload here means a
        // licence-fail install loses layout dispatch, addon settings,
        // and pages metadata even when the gate flag is off, so the
        // public site renders with stale defaults and the admin's
        // Layouts choices have no effect on output.
        //
        // The clientAreaPage method still receives $template so it can
        // skip license-sensitive enrichment if we ever need to; for
        // now everything in $myTheme is license-neutral metadata.
        if ($template === null) {
            return null;
        }

        $method = lcfirst($hookName);
        if (!method_exists($this, $method)) {
            return null;
        }
        return $this->{$method}($hookArg, $template);
    }

    // ------------------------------------------------------------------ hooks

    /** Runs LAST among ClientAreaPage hooks (priority -1). Assembles $myTheme. */
    private function clientAreaPage(array $vars, Template $template): array
    {
        $pages    = $this->resolveCurrentPage($vars, $template);
        $layouts  = [
            'main-menu' => $this->resolveActiveLayout($template, 'main-menu'),
            'footer'    => $this->resolveActiveLayout($template, 'footer'),
        ];

        // Per-page layout override (set in admin Pages editor). When a page
        // pins a specific main-menu or footer layout, swap the global pick
        // before exposing $myTheme.layouts to Smarty — templates don't have
        // to know about overrides; they just see the effective layout.
        $currentPage = (string)($vars['templatefile'] ?? '');
        if ($currentPage !== '' && isset($pages[$currentPage]['layout_overrides'])) {
            foreach (['main-menu', 'footer'] as $kind) {
                $override = $pages[$currentPage]['layout_overrides'][$kind] ?? null;
                if (is_string($override) && $override !== ''
                    && in_array($override, $template->getLayouts($kind), true)) {
                    $layouts[$kind] = $this->buildLayoutMeta($template, $kind, $override);
                }
            }
        }

        $branding = $this->resolveBranding();

        return [
            'myTheme' => [
                'name'          => $template->getName(),
                'version'       => $template->getVersion(),
                'manifest'      => $template->getManifest(),
                'styles'        => $this->resolveActiveStyle($template),
                'layouts'       => $layouts,
                'pages'         => $pages,
                'subnav'        => $this->resolveSubnav($template, $vars, $pages),
                'svcLayout'     => $this->resolveSvcLayout($template, $vars, $pages),
                'license'       => [
                    'canRender' => true,
                    'devMode'   => $template->license()->isDevMode(),
                ],
                'addonSettings' => Settings::all(),
                'branding'      => $branding,
                // Effective language list for the locale chooser. Respects the
                // admin's "Custom Language List" toggle + curated codes from
                // the Settings tab; otherwise falls back to every language
                // installed in WHMCS root /lang/.
                'locales'       => [
                    'languages' => LocaleHelper::effectiveList(),
                ],
            ],
            'hadrianLang' => $this->loadLanguage($template, $vars['language'] ?? 'english'),
            // Convenience root alias — templates that just want "the logo"
            // can read $mtLogo directly without walking $myTheme.branding.
            // Resolves to the light-surface logo (best default for the
            // legacy WHMCS $logo variable that some included tpls expect).
            'mtLogo'    => $branding['logo']['light'] ?? '',
            'mtFavicon' => $branding['favicon'] ?? '',
        ];
    }

    /**
     * Login page (priority 1 ClientAreaPageLogin). Surfaces the latest
     * published announcements as $loginAnnouncements for the "split" login
     * variant's featured panel. Other variants ignore the var.
     *
     * @return array{loginAnnouncements: list<array{id:int,title:string,date:string}>}
     */
    private function clientAreaPageLogin(array $vars, Template $template): array
    {
        return ['loginAnnouncements' => $this->fetchRecentAnnouncements(3)];
    }

    /**
     * Latest published, past-dated announcements. Defensive: any DB failure
     * returns an empty list so the login page can never break.
     *
     * @return list<array{id:int,title:string,date:string,excerpt:string}>
     */
    private function fetchRecentAnnouncements(int $limit): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table('tblannouncements')
                ->where('published', 1)
                ->where('date', '<=', date('Y-m-d H:i:s'))
                ->orderBy('date', 'desc')
                ->limit($limit)
                ->get(['id', 'title', 'date', 'announcement']);
        } catch (\Throwable $e) {
            return [];
        }

        $out = [];
        foreach ($rows as $row) {
            $ts = strtotime((string)($row->date ?? ''));
            $out[] = [
                'id'      => (int)($row->id ?? 0),
                'title'   => (string)($row->title ?? ''),
                'date'    => $ts ? date('M j, Y', $ts) : '',
                'excerpt' => $this->announcementExcerpt((string)($row->announcement ?? '')),
            ];
        }
        return $out;
    }

    /** First ~160 chars of an announcement body — tags stripped, cut on a word boundary. */
    private function announcementExcerpt(string $body): string
    {
        $text = trim((string)preg_replace('/\s+/', ' ', strip_tags($body)));
        if (mb_strlen($text) <= 160) {
            return $text;
        }
        return (string)preg_replace('/\s+\S*$/', '', mb_substr($text, 0, 160)) . '…';
    }

    /**
     * Build the $myTheme.branding payload — resolved web URLs, ready for
     * the template to drop into <img src="..."> / <link rel="icon"> without
     * any further work.
     *
     * @return array{
     *   logo:    array{light:string, dark:string},
     *   square:  array{light:string, dark:string},
     *   favicon: string,
     *   has:     array{anyLogo:bool, anySquare:bool, favicon:bool},
     * }
     */
    private function resolveBranding(): array
    {
        $uploader = new Uploader();
        $resolve  = static function (Uploader $u, string $key): string {
            $stored = $u->normalizeStored((string)Settings::getValue($key, ''));
            return $stored === '' ? '' : $u->webUrlFor($stored);
        };

        $logoLight       = $resolve($uploader, 'logo_light');
        $logoDark        = $resolve($uploader, 'logo_dark');
        $logoSquareLight = $resolve($uploader, 'logo_square_light');
        $logoSquareDark  = $resolve($uploader, 'logo_square_dark');
        $favicon         = $resolve($uploader, 'favicon');

        return [
            'logo' => [
                // Each variant falls back to the other so a single upload
                // works on both surfaces — admin doesn't have to upload
                // both to get a usable result.
                'light' => $logoLight !== '' ? $logoLight : $logoDark,
                'dark'  => $logoDark  !== '' ? $logoDark  : $logoLight,
            ],
            'square' => [
                'light' => $logoSquareLight !== '' ? $logoSquareLight : $logoSquareDark,
                'dark'  => $logoSquareDark  !== '' ? $logoSquareDark  : $logoSquareLight,
            ],
            'favicon' => $favicon,
            'has' => [
                'anyLogo'   => $logoLight !== '' || $logoDark !== '',
                'anySquare' => $logoSquareLight !== '' || $logoSquareDark !== '',
                'favicon'   => $favicon !== '',
            ],
        ];
    }

    private function clientAreaHeadOutput(array $vars, Template $template): ?string
    {
        $colors  = $this->buildColorsHead($template);
        $typo    = $this->buildTypographyHead($template);
        $buttons = $this->buildButtonsHead($template);
        $forms   = $this->buildFormsHead($template);
        $layout  = $this->buildLayoutHead($template);
        $elements = $this->buildElementsHead($template);
        $ext     = (string)$this->extensionOutput($template, $vars, slot: 'headOutput');
        $custom  = $this->buildCustomCss($template);
        // Custom CSS goes LAST so it can override the theme + token overrides.
        $out     = $colors . $typo . $buttons . $forms . $layout . $elements . $ext . $custom;
        return $out !== '' ? $out : null;
    }

    /**
     * Emit a small inline <style> overriding ONLY the typography tokens the
     * admin changed from default (Styles → Typography). Defaults stay in the
     * cacheable static apple-theme.css; this block lands in {$headoutput},
     * which header.tpl renders AFTER the stylesheet links, so it wins on
     * source order. Returns '' when nothing is overridden.
     *
     * Values are sanitized (var-name allowlist, int sizes/weights, font-stack
     * char allowlist, Google font name allowlist) to avoid CSS injection.
     */
    private function buildTypographyHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_typography', null);
        if (!is_array($stored)) {
            return '';
        }

        $cfg      = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/typography.php');
        $fallback = (string)($cfg['fontFamily']['fallback'] ?? 'sans-serif');

        $decls    = [];
        $links    = '';
        $fontFace = '';

        // Font family
        $ff   = is_array($stored['fontFamily'] ?? null) ? $stored['fontFamily'] : [];
        $mode = (string)($ff['mode'] ?? 'default');
        if ($mode === 'google' && !empty($ff['google'])) {
            $name = trim((string)preg_replace('/[^A-Za-z0-9 ]/', '', (string)$ff['google']));
            if ($name !== '') {
                $href  = 'https://fonts.googleapis.com/css2?family=' . rawurlencode($name)
                       . ':wght@300;400;500;600;700&display=swap';
                $links = '<link rel="preconnect" href="https://fonts.googleapis.com">'
                       . '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
                       . '<link rel="stylesheet" href="' . htmlspecialchars($href, ENT_QUOTES) . '">';
                $decls['--font-family'] = "'{$name}', {$fallback}";
            }
        } elseif ($mode === 'custom' && !empty($ff['custom'])) {
            $custom = trim((string)preg_replace('/[^A-Za-z0-9 ,\'"\-]/', '', (string)$ff['custom']));
            if ($custom !== '') {
                $decls['--font-family'] = $custom;
            }
        } elseif ($mode === 'folder' && !empty($ff['folder'])) {
            // A font dropped into assets/fonts/custom (scanned by StylesController).
            // Sanitize hard: basename + extension allowlist + must exist on disk.
            $file = basename((string)$ff['folder']);
            if (preg_match('/^[A-Za-z0-9._-]+\.(woff2|woff|ttf|otf)$/i', $file)
                && is_file($template->getFullPath() . '/assets/fonts/custom/' . $file)) {
                $famName  = pathinfo($file, PATHINFO_FILENAME);
                $ext      = strtolower((string)pathinfo($file, PATHINFO_EXTENSION));
                $fmt      = ['woff2' => 'woff2', 'woff' => 'woff', 'ttf' => 'truetype', 'otf' => 'opentype'][$ext] ?? 'woff2';
                $webRoot  = defined('WEB_ROOT') ? rtrim((string)WEB_ROOT, '/') : '';
                $url      = $webRoot . '/templates/' . $template->getName() . '/assets/fonts/custom/' . $file;
                $fontFace = '@font-face{font-family:"' . $famName . '";font-style:normal;font-weight:100 900;'
                          . 'font-display:swap;src:url("' . $url . '") format("' . $fmt . '");}';
                $decls['--font-family'] = '"' . $famName . '", ' . $fallback;
            }
        }

        // Sizes (px) + weights (numeric). Each stored bucket holds only overrides.
        foreach (['sizes' => 'px', 'weights' => ''] as $bucket => $unit) {
            if (!is_array($stored[$bucket] ?? null)) {
                continue;
            }
            foreach ($stored[$bucket] as $var => $val) {
                if (!preg_match('/^--[a-z0-9-]+$/', (string)$var)) {
                    continue;
                }
                $num = (int)$val;
                if ($num <= 0) {
                    continue;
                }
                $decls[(string)$var] = $num . $unit;
            }
        }

        if ($decls === []) {
            return $links;
        }

        $css = $fontFace . ':root{';
        foreach ($decls as $var => $val) {
            $css .= $var . ':' . $val . ';';
        }
        $css .= '}';

        return $links . '<style id="mytheme-typography">' . $css . '</style>';
    }

    /**
     * Emit the admin's global Custom CSS (Styles → Custom CSS), LAST in head
     * output so it overrides everything. Admin-entered (trusted), but strip any
     * </style> as defense-in-depth so it can't break out of the tag.
     */
    private function buildCustomCss(Template $template): string
    {
        $css = trim((string)Settings::getValue($template->getName() . '_custom_css', ''));
        if ($css === '') {
            return '';
        }
        $css = (string)preg_replace('#</\s*style#i', '', $css);
        return '<style id="mytheme-custom-css">' . $css . '</style>';
    }

    /**
     * Emit an inline <style> applying the admin's per-token Color overrides
     * (Styles -> Colors). Mirrors buildTypographyHead: defaults stay in the
     * cacheable apple-theme.css; this block lands after the stylesheet links so
     * it wins on source order. Overrides are stored per style; each style emits
     * into the selector matching its colorMode (light => :root, dark =>
     * [data-theme="dark"]). Var names + color values are re-validated on the way
     * out. Returns '' when nothing is overridden.
     */
    private function buildColorsHead(Template $template): string
    {
        $name   = $template->getName();
        $active = (string)Settings::getValue($name . '_active_style', 'default');
        if ($active === 'dark' || $active === '') {
            $active = 'default'; // legacy dark/empty pointer -> base style
        }

        // Each style now carries BOTH scopes: light -> :root, dark ->
        // [data-theme="dark"]. Read the per-scope keys, falling back to the
        // pre-refactor keys (_colors_<active> for light, _colors_dark for dark)
        // so saved colors keep applying before the admin-side migration runs.
        $scopes = [
            ':root'               => ['_colors_' . $active . '_light', '_colors_' . $active],
            '[data-theme="dark"]' => ['_colors_' . $active . '_dark',  '_colors_dark'],
        ];

        $blocks = '';
        foreach ($scopes as $selector => $keys) {
            $stored = null;
            foreach ($keys as $k) {
                $v = Settings::getValue($name . $k, null);
                if (is_array($v) && $v !== []) { $stored = $v; break; }
            }
            if (!is_array($stored) || $stored === []) {
                continue;
            }
            $decls = '';
            foreach ($stored as $var => $val) {
                if (!preg_match('/^--[a-z0-9-]+$/', (string)$var)) {
                    continue;
                }
                if (!$this->isColorValue((string)$val)) {
                    continue;
                }
                $decls .= (string)$var . ':' . trim((string)$val) . ';';
            }
            if ($decls !== '') {
                $blocks .= $selector . '{' . $decls . '}';
            }
        }

        return $blocks !== '' ? '<style id="mytheme-colors">' . $blocks . '</style>' : '';
    }

    /**
     * Emit an inline <style> applying the admin's Buttons overrides (Styles ->
     * Buttons). GLOBAL (one mapping styles both modes), so it always targets
     * :root — the referenced ramp/base tokens are themselves mode-aware, so the
     * same var() resolves correctly under [data-theme="dark"]. Mirrors
     * buildColorsHead: defaults stay in the cacheable apple-theme.css; this block
     * lands after the stylesheet links so it wins on source order.
     *
     * Stored shape (only changed values): ['sizes' => ['--btn-...'=>int, ...],
     * 'variants' => ['<variant>' => ['<slot>'=>'<optionKey>', ...], ...]]. Size
     * vars + variant/slot keys are re-validated against core/config/buttons.php,
     * and each option key is mapped through the config's own css strings (authored
     * here, never user input) — so there's no injection surface. Returns '' when
     * nothing is overridden.
     */
    private function buildButtonsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_buttons', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/buttons.php');

        // option key -> emitted css value (var()/hex/rgba()/transparent)
        $cssByKey = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $cssByKey[(string)$o['key']] = (string)$o['css'];
        }
        // size var -> field meta (type + scale) from the tiers; + scales + bounds
        $sizeMeta = [];
        foreach (($cfg['sizeTiers'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);
        // valid variant + slot keys
        $validVariant = [];
        foreach (($cfg['variants'] ?? []) as $v) {
            $validVariant[(string)$v['key']] = true;
        }
        $validSlot = [];
        foreach (($cfg['slots'] ?? []) as $s) {
            $validSlot[(string)$s['key']] = true;
        }

        $decls = '';

        if (is_array($stored['sizes'] ?? null)) {
            foreach ($stored['sizes'] as $var => $val) {
                $var = (string)$var;
                if (!isset($sizeMeta[$var])) {
                    continue;
                }
                $f = $sizeMeta[$var];
                if (($f['type'] ?? 'px') === 'scale') {
                    // map the stored scale key back to its css value
                    $css = null;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === (string)$val) {
                            $css = (string)$o['css'];
                            break;
                        }
                    }
                    if ($css === null) {
                        continue;
                    }
                    $decls .= $var . ':' . $css . ';';
                } else {
                    $num = (int)$val;
                    if ($num < $min || $num > $max) {
                        continue;
                    }
                    $decls .= $var . ':' . $num . 'px;';
                }
            }
        }

        if (is_array($stored['variants'] ?? null)) {
            foreach ($stored['variants'] as $vk => $slots) {
                $vk = (string)$vk;
                if (!isset($validVariant[$vk]) || !is_array($slots)) {
                    continue;
                }
                foreach ($slots as $sk => $optKey) {
                    $sk = (string)$sk;
                    if (!isset($validSlot[$sk])) {
                        continue;
                    }
                    $optKey = (string)$optKey;
                    if (!isset($cssByKey[$optKey])) {
                        continue;
                    }
                    $decls .= '--btn-' . $vk . '-' . $sk . ':' . $cssByKey[$optKey] . ';';
                }
            }
        }

        return $decls !== '' ? '<style id="mytheme-buttons">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Emit the admin's Forms overrides (Styles -> Forms). GLOBAL, always into
     * :root (referenced tokens are mode-aware). Sizes: px -> Npx, scale -> the
     * scale option's css. Colours: option key -> css. Var names + keys are
     * re-validated against core/config/forms.php; option css is authored here
     * (never user input), so no injection surface. Mirrors buildButtonsHead.
     */
    private function buildFormsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_forms', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/forms.php');

        $cssByKey = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $cssByKey[(string)$o['key']] = (string)$o['css'];
        }
        $sizeMeta = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $colorVars = [];
        foreach (($cfg['colorGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $colorVars[(string)$f['var']] = true;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);

        $decls = '';

        if (is_array($stored['sizes'] ?? null)) {
            foreach ($stored['sizes'] as $var => $val) {
                $var = (string)$var;
                if (!isset($sizeMeta[$var])) {
                    continue;
                }
                $f = $sizeMeta[$var];
                if (($f['type'] ?? 'px') === 'scale') {
                    $css = null;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === (string)$val) {
                            $css = (string)$o['css'];
                            break;
                        }
                    }
                    if ($css === null) {
                        continue;
                    }
                    $decls .= $var . ':' . $css . ';';
                } else {
                    $num = (int)$val;
                    if ($num < $min || $num > $max) {
                        continue;
                    }
                    $decls .= $var . ':' . $num . 'px;';
                }
            }
        }

        if (is_array($stored['colors'] ?? null)) {
            foreach ($stored['colors'] as $var => $key) {
                $var = (string)$var;
                if (!isset($colorVars[$var]) || !isset($cssByKey[(string)$key])) {
                    continue;
                }
                $decls .= $var . ':' . $cssByKey[(string)$key] . ';';
            }
        }

        return $decls !== '' ? '<style id="mytheme-forms">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Emit the admin's Layout overrides (Styles -> Layout) — page-structure
     * dimensions, px only, into :root. Var names re-validated against
     * core/config/layout.php; values are ints. Returns '' when nothing changed.
     */
    private function buildLayoutHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_layout_vars', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg   = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        $min   = (int)($cfg['sizeMin'] ?? 0);
        $max   = (int)($cfg['sizeMax'] ?? 4000);
        $valid = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $valid[(string)$f['var']] = true;
            }
        }

        $decls = '';
        foreach ($stored as $var => $val) {
            $var = (string)$var;
            if (!isset($valid[$var])) {
                continue;
            }
            $num = (int)$val;
            if ($num < $min || $num > $max) {
                continue;
            }
            $decls .= $var . ':' . $num . 'px;';
        }

        return $decls !== '' ? '<style id="mytheme-layout">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Emit the admin's Elements overrides (Styles -> Elements) — component shape
     * tokens, into :root. Sizes: px -> Npx, scale -> the scale option's css. Var
     * names + keys re-validated against core/config/elements.php; option css is
     * authored there. Mirrors the size half of buildFormsHead.
     */
    private function buildElementsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_elements', null);
        if (!is_array($stored) || $stored === [] || !is_array($stored['sizes'] ?? null)) {
            return '';
        }

        $cfg      = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/elements.php');
        $sizeMeta = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);

        $decls = '';
        foreach ($stored['sizes'] as $var => $val) {
            $var = (string)$var;
            if (!isset($sizeMeta[$var])) {
                continue;
            }
            $f = $sizeMeta[$var];
            if (($f['type'] ?? 'px') === 'scale') {
                $css = null;
                foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                    if ((string)$o['key'] === (string)$val) {
                        $css = (string)$o['css'];
                        break;
                    }
                }
                if ($css === null) {
                    continue;
                }
                $decls .= $var . ':' . $css . ';';
            } else {
                $num = (int)$val;
                if ($num < $min || $num > $max) {
                    continue;
                }
                $decls .= $var . ':' . $num . 'px;';
            }
        }

        return $decls !== '' ? '<style id="mytheme-elements">:root{' . $decls . '}</style>' : '';
    }

    /** Re-validate a stored color before emitting (defense-in-depth vs CSS injection). */
    private function isColorValue(string $v): bool
    {
        $v = trim($v);
        return (bool)(
            preg_match('/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/', $v)
            || preg_match('/^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
            || preg_match('/^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
        );
    }

    private function clientAreaFooterOutput(array $vars, Template $template): ?string
    {
        return $this->extensionOutput($template, $vars, slot: 'footerOutput');
    }

    private function clientAreaHomepagePanels(mixed $panels, Template $template): void
    {
        $this->normalizeRecentTicketPanel($panels);
    }

    /**
     * Populate $dashboard.{activeServices, recentInvoices, openTickets} for clientareahome.
     * Uses WHMCS localAPI so we don't have to hardcode the schema.
     */
    private function clientAreaPageHome(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) {
            return ['dashboard' => ['activeServices' => [], 'recentInvoices' => [], 'openTickets' => []]];
        }

        return [
            'dashboard' => [
                'activeServices' => $this->fetchActiveServices($clientId),
                'recentInvoices' => $this->fetchRecentInvoices($clientId),
                'openTickets'    => $this->fetchOpenTickets($clientId),
            ],
        ];
    }

    private function fetchActiveServices(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsProducts', [
                'clientid'  => $clientId,
                'stats'     => false,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $services = [];
            foreach (($response['products']['product'] ?? []) as $p) {
                if (!in_array($p['status'] ?? '', ['Active', 'Suspended'], true)) continue;
                $services[] = [
                    'id'           => (int)($p['id'] ?? 0),
                    'name'         => (string)($p['name'] ?? $p['groupname'] ?? 'Service'),
                    'domain'       => (string)($p['domain'] ?? ''),
                    'status'       => (string)($p['status'] ?? 'Active'),
                    'nextDueDate'  => !empty($p['nextduedate']) ? date('M j, Y', strtotime((string)$p['nextduedate'])) : '',
                    'manageUrl'    => '/clientarea.php?action=productdetails&id=' . (int)($p['id'] ?? 0),
                ];
                if (count($services) >= 5) break;
            }
            return $services;
        } catch (\Throwable) {
            return [];
        }
    }

    /**
     * Populate $products on /clientarea.php?action=services when WHMCS's
     * native variable isn't available or is empty. Mirrors the standard
     * keys the legacy clientareaproducts.tpl expects: id, productname,
     * groupname, name, domain, firstpaymentamount, recurringamount,
     * billingcycle, paymentmethod, paymentmethodname, nextduedate, status,
     * statusClass.
     */
    private function clientAreaPageProductsServices(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) {
            return [];
        }
        $list = $this->fetchAllProducts($clientId);
        return ['mtProducts' => $list];
    }

    /** Tickets list — populates $mtTickets on /supporttickets.php. */
    private function clientAreaPageSupportTickets(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtTickets' => $this->fetchAllTickets($clientId)];
    }

    /** Invoices list — populates $mtInvoices on /clientarea.php?action=invoices. */
    private function clientAreaPageInvoices(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtInvoices' => $this->fetchAllInvoices($clientId)];
    }

    /** Domains list — populates $mtDomains on /clientarea.php?action=domains. */
    private function clientAreaPageDomains(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtDomains' => $this->fetchAllDomains($clientId)];
    }

    /** Quotes list — populates $mtQuotes on /clientarea.php?action=quotes. */
    private function clientAreaPageQuotes(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtQuotes' => $this->fetchAllQuotes($clientId)];
    }

    private function fetchAllTickets(int $clientId): array
    {
        try {
            $response = localAPI('GetTickets', [
                'clientid' => $clientId,
                'limitnum' => 100,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['tickets']['ticket'] ?? []) as $t) {
                $status      = (string)($t['status'] ?? 'Open');
                $statusClass = strtolower(str_replace([' ', '_'], '-', $status));
                $lastReplyRaw = (string)($t['lastreply'] ?? '');
                $out[] = [
                    'id'         => (int)($t['id'] ?? 0),
                    'tid'        => (string)($t['tid'] ?? ''),
                    'c'          => (string)($t['c'] ?? ''),
                    'subject'    => (string)($t['subject'] ?? ''),
                    'department' => (string)($t['deptname'] ?? $t['department'] ?? ''),
                    'priority'   => (string)($t['priority'] ?? $t['urgency'] ?? 'Medium'),
                    'status'     => $status,
                    'statusClass'=> $statusClass,
                    'statusclass'=> $statusClass,
                    'unread'     => !empty($t['unread']),
                    'lastreply'  => !empty($lastReplyRaw) && $lastReplyRaw !== '0000-00-00 00:00:00'
                        ? date('M j, Y', strtotime($lastReplyRaw))
                        : '',
                    'date'       => !empty($t['date']) ? date('M j, Y', strtotime((string)$t['date'])) : '',
                    // Raw sort value for DataTables data-order attribute. ISO-ish so
                    // localeCompare() in JS sorts chronologically.
                    '_sort_lastreply_raw' => $lastReplyRaw,
                ];
            }

            // URL-driven sort — mirrors fetchAllInvoices for initial render + no-JS fallback.
            $orderby = (string)($_GET['orderby'] ?? 'updated');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'subject'    => fn($a, $b) => strcasecmp($a['subject'], $b['subject']),
                'department' => fn($a, $b) => strcasecmp($a['department'], $b['department']),
                'status'     => fn($a, $b) => strcasecmp($a['status'], $b['status']),
                default      => fn($a, $b) => strcmp($a['_sort_lastreply_raw'], $b['_sort_lastreply_raw']),
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllInvoices(int $clientId): array
    {
        try {
            $response = localAPI('GetInvoices', [
                'userid'   => $clientId,
                'limitnum' => 100,
                'orderby'  => 'date',
                'order'    => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['invoices']['invoice'] ?? []) as $inv) {
                $status = strip_tags((string)($inv['status'] ?? 'Unpaid'));
                $out[] = [
                    'id'             => (int)($inv['id'] ?? 0),
                    'invoicenum'     => (string)($inv['invoicenum'] ?? $inv['id'] ?? ''),
                    'invoiceid'      => (int)($inv['id'] ?? 0),
                    'datecreated'    => !empty($inv['date']) && $inv['date'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$inv['date']))
                        : '',
                    'duedate'        => !empty($inv['duedate']) && $inv['duedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$inv['duedate']))
                        : '',
                    'datepaid'       => !empty($inv['datepaid']) && $inv['datepaid'] !== '0000-00-00 00:00:00'
                        ? date('M j, Y', strtotime((string)$inv['datepaid']))
                        : '',
                    'total'          => (string)($inv['total'] ?? ''),
                    'status'         => $status,
                    'statusLower'    => strtolower($status),
                    // Raw values kept for sorting (the display values above are
                    // formatted strings that don't compare meaningfully).
                    '_sort_date_raw' => (string)($inv['date'] ?? ''),
                    '_sort_due_raw'  => (string)($inv['duedate'] ?? ''),
                    '_sort_amount'   => (float)preg_replace('/[^0-9.\-]/', '', (string)($inv['total'] ?? '0')),
                ];
            }

            // URL-driven sort: /clientarea.php?action=invoices&orderby=KEY&sort=ASC|DESC
            // Honor only known keys + directions; bail to default otherwise.
            $orderby = (string)($_GET['orderby'] ?? 'id');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'date'   => fn($a, $b) => strcmp($a['_sort_date_raw'], $b['_sort_date_raw']),
                'due'    => fn($a, $b) => strcmp($a['_sort_due_raw'], $b['_sort_due_raw']),
                'amount' => fn($a, $b) => $a['_sort_amount'] <=> $b['_sort_amount'],
                'status' => fn($a, $b) => strcasecmp($a['status'], $b['status']),
                default  => fn($a, $b) => $a['id'] <=> $b['id'],   // 'id'
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllQuotes(int $clientId): array
    {
        try {
            $response = localAPI('GetQuotes', [
                'userid'   => $clientId,
                'limitnum' => 100,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['quotes']['quote'] ?? []) as $q) {
                $stage = strip_tags((string)($q['stage'] ?? 'Draft'));
                $out[] = [
                    'id'             => (int)($q['id'] ?? 0),
                    'subject'        => (string)($q['subject'] ?? ''),
                    'datecreated'    => !empty($q['datecreated']) && $q['datecreated'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$q['datecreated']))
                        : '',
                    'validuntil'     => !empty($q['validuntil']) && $q['validuntil'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$q['validuntil']))
                        : '',
                    'total'          => (string)($q['total'] ?? ''),
                    'stage'          => $stage,
                    'stageLower'     => strtolower(str_replace([' ', '_'], '-', $stage)),
                    // Raw sort values for DataTables data-order attributes.
                    '_sort_date_raw'  => (string)($q['datecreated'] ?? ''),
                    '_sort_valid_raw' => (string)($q['validuntil'] ?? ''),
                    '_sort_amount'    => (float)preg_replace('/[^0-9.\-]/', '', (string)($q['total'] ?? '0')),
                ];
            }

            // URL-driven sort — mirrors fetchAllInvoices.
            $orderby = (string)($_GET['orderby'] ?? 'id');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'date'   => fn($a, $b) => strcmp($a['_sort_date_raw'], $b['_sort_date_raw']),
                'valid'  => fn($a, $b) => strcmp($a['_sort_valid_raw'], $b['_sort_valid_raw']),
                'amount' => fn($a, $b) => $a['_sort_amount'] <=> $b['_sort_amount'],
                'status' => fn($a, $b) => strcasecmp($a['stage'], $b['stage']),
                default  => fn($a, $b) => $a['id'] <=> $b['id'],
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            // Optional stage filter — ?stage=Draft|Delivered|Accepted|Lost|Dead|On Hold
            $stageFilter = (string)($_GET['stage'] ?? '');
            if ($stageFilter !== '') {
                $out = array_values(array_filter(
                    $out,
                    fn($row) => strcasecmp($row['stage'], $stageFilter) === 0
                ));
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllDomains(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsDomains', [
                'clientid' => $clientId,
                'limitnum' => 100,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['domains']['domain'] ?? []) as $d) {
                $status = (string)($d['status'] ?? 'Active');
                $out[] = [
                    'id'         => (int)($d['id'] ?? 0),
                    'domain'     => (string)($d['domainname'] ?? ''),
                    'domainname' => (string)($d['domainname'] ?? ''),
                    'regdate'    => !empty($d['regdate']) && $d['regdate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['regdate']))
                        : '',
                    'nextduedate'=> !empty($d['nextduedate']) && $d['nextduedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['nextduedate']))
                        : '',
                    'expirydate' => !empty($d['expirydate']) && $d['expirydate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['expirydate']))
                        : '',
                    'status'     => $status,
                    'statusLower'=> strtolower($status),
                    'autorenew'  => !empty($d['donotrenew']) ? false : true,
                    'registrar'  => (string)($d['registrar'] ?? ''),
                ];
            }
            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    /** Full product list (all statuses) shaped for clientareaproducts.tpl. */
    private function fetchAllProducts(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsProducts', [
                'clientid' => $clientId,
                'stats'    => false,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $out = [];
            foreach (($response['products']['product'] ?? []) as $p) {
                $status = (string)($p['status'] ?? 'Active');
                $statusClass = match ($status) {
                    'Active'                                  => 'active',
                    'Pending'                                 => 'pending',
                    'Suspended'                               => 'suspended',
                    'Terminated', 'Cancelled', 'Fraud'        => 'terminated',
                    default                                   => 'active',
                };
                $out[] = [
                    'id'                 => (int)($p['id'] ?? 0),
                    'productname'        => (string)($p['name'] ?? ''),
                    'groupname'          => (string)($p['groupname'] ?? 'Service'),
                    'name'               => (string)($p['name'] ?? ''),
                    'domain'             => (string)($p['domain'] ?? ''),
                    'firstpaymentamount' => (string)($p['firstpaymentamount'] ?? ''),
                    'recurringamount'    => (string)($p['recurringamount'] ?? ''),
                    'billingcycle'       => (string)($p['billingcycle'] ?? ''),
                    'paymentmethod'      => (string)($p['paymentmethod'] ?? ''),
                    'paymentmethodname'  => (string)($p['paymentmethodname'] ?? ''),
                    'nextduedate'        => !empty($p['nextduedate']) && $p['nextduedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$p['nextduedate']))
                        : '',
                    'status'             => $status,
                    'statusClass'        => $statusClass,
                ];
            }
            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchRecentInvoices(int $clientId): array
    {
        try {
            $response = localAPI('GetInvoices', [
                'userid'    => $clientId,
                'limitnum'  => 5,
                'orderby'   => 'date',
                'order'     => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $invoices = [];
            foreach (($response['invoices']['invoice'] ?? []) as $inv) {
                $invoices[] = [
                    'id'     => (int)($inv['id'] ?? 0),
                    'date'   => !empty($inv['date']) ? date('M j, Y', strtotime((string)$inv['date'])) : '',
                    'total'  => (string)($inv['total'] ?? ''),
                    'status' => (string)($inv['status'] ?? ''),
                ];
            }
            return $invoices;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchOpenTickets(int $clientId): array
    {
        try {
            $response = localAPI('GetTickets', [
                'clientid'  => $clientId,
                'limitnum'  => 25,
                'orderby'   => 'lastreply',
                'order'     => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $tickets = [];
            foreach (($response['tickets']['ticket'] ?? []) as $tkt) {
                $status = (string)($tkt['status'] ?? '');
                if (strcasecmp($status, 'Closed') === 0) continue;

                $dateRaw = (string)($tkt['date'] ?? '');
                $dateTimestamp = $dateRaw !== '' ? strtotime($dateRaw) : false;
                $lastReplyRaw = (string)($tkt['lastreply'] ?? '');
                $lastReplyTimestamp = $lastReplyRaw !== '' ? strtotime($lastReplyRaw) : false;

                $tickets[] = [
                    'tid'      => (string)($tkt['tid'] ?? ''),
                    'c'        => (string)($tkt['c'] ?? ''),
                    'subject'  => (string)($tkt['subject'] ?? ''),
                    'status'   => $status,
                    'priority' => (string)($tkt['priority'] ?? 'Medium'),
                    'date'     => $dateTimestamp ? date('M j, Y', $dateTimestamp) : $dateRaw,
                    'lastreply' => $lastReplyTimestamp ? date('M j, Y', $lastReplyTimestamp) : $lastReplyRaw,
                ];
                if (count($tickets) >= 5) break;
            }
            return $tickets;
        } catch (\Throwable) {
            return [];
        }
    }

    // ---------------------------------------------------------------- helpers

    private function normalizeRecentTicketPanel(mixed $panels): void
    {
        $ticketPanel = $this->findPanel($panels, 'Recent Support Tickets');
        if ($ticketPanel === null || !method_exists($ticketPanel, 'hasChildren') || !$ticketPanel->hasChildren()) {
            return;
        }

        foreach ($ticketPanel->getChildren() as $ticketItem) {
            if (!method_exists($ticketItem, 'getLabel') || !method_exists($ticketItem, 'setLabel')) {
                continue;
            }

            $currentBadge = method_exists($ticketItem, 'hasBadge') && $ticketItem->hasBadge()
                ? (string)$ticketItem->getBadge()
                : '';
            $normalized = $this->parseTicketPanelLabel((string)$ticketItem->getLabel(), $currentBadge);

            if ($normalized['subject'] !== '') {
                $ticketItem->setLabel($normalized['subject']);
            }
            if ($normalized['status'] !== '' && method_exists($ticketItem, 'setBadge')) {
                $ticketItem->setBadge($normalized['status']);
            }
            if ($normalized['tid'] !== '' && method_exists($ticketItem, 'setExtra')) {
                $ticketItem->setExtra('tid', $normalized['tid']);
            }
            if ($normalized['lastreply'] !== '' && method_exists($ticketItem, 'setExtra')) {
                $ticketItem->setExtra('lastreply', $normalized['lastreply']);
            }
        }
    }

    private function findPanel(mixed $panels, string $name): mixed
    {
        if (method_exists($panels, 'getChild')) {
            $child = $panels->getChild($name);
            if ($child !== null) {
                return $child;
            }
        }

        if (!method_exists($panels, 'getChildren')) {
            return null;
        }

        foreach ($panels->getChildren() as $panel) {
            $panelName = method_exists($panel, 'getName') ? (string)$panel->getName() : '';
            $panelLabel = method_exists($panel, 'getLabel') ? trim(strip_tags((string)$panel->getLabel())) : '';
            if ($panelName === $name || $panelLabel === $name) {
                return $panel;
            }
        }

        return null;
    }

    /** @return array{subject: string, tid: string, lastreply: string, status: string} */
    private function parseTicketPanelLabel(string $label, string $currentBadge): array
    {
        $withBreaks = preg_replace('/<br\s*\/?>/i', "\n", $label) ?? $label;
        $text = preg_replace('/<[^>]+>/', ' ', $withBreaks) ?? $withBreaks;
        $text = html_entity_decode($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = preg_replace('/[ \t]+/', ' ', $text) ?? $text;
        $text = preg_replace('/\s*\n\s*/', "\n", trim($text)) ?? trim($text);

        $lines = array_values(array_filter(array_map('trim', preg_split('/\R+/', $text) ?: [])));
        $firstLine = $lines[0] ?? $text;
        $lastReply = '';
        foreach ($lines as $line) {
            if (preg_match('/^Last\s+Updated:\s*(.+)$/i', $line, $matches)) {
                $lastReply = trim($matches[1]);
                break;
            }
        }

        $status = trim($currentBadge);
        $knownStatuses = [
            'Awaiting Reply',
            'Customer Reply',
            'Customer-Reply',
            'In Progress',
            'On Hold',
            'Answered',
            'Pending',
            'Closed',
            'Open',
        ];

        foreach ($knownStatuses as $knownStatus) {
            if (preg_match('/\b' . preg_quote($knownStatus, '/') . '\b\s*$/i', $firstLine)) {
                if ($status === '') {
                    $status = str_replace('-', ' ', $knownStatus);
                }
                $firstLine = trim((string)preg_replace('/\b' . preg_quote($knownStatus, '/') . '\b\s*$/i', '', $firstLine));
                break;
            }
        }

        $ticketId = '';
        $subject = $firstLine;
        if (preg_match('/^(#?[A-Z0-9]+-\d+)\s+-\s+(.+)$/i', $firstLine, $matches)) {
            $ticketId = ltrim($matches[1], '#');
            $subject = trim($matches[2]);
        }

        return [
            'subject'   => $subject,
            'tid'       => $ticketId,
            'lastreply' => $lastReply,
            'status'    => $status,
        ];
    }

    private function extensionOutput(Template $template, array $vars, string $slot): ?string
    {
        $output = '';
        foreach ($template->getExtensions() as $name) {
            $extPath = $template->getFullPath() . "/core/extensions/{$name}/{$name}.php";
            if (!file_exists($extPath)) {
                continue;
            }
            $extConfig = require $extPath;
            $callable  = $extConfig[$slot] ?? null;
            if (is_callable($callable)) {
                $output .= (string)$callable($vars);
            }
        }
        return $output !== '' ? $output : null;
    }

    private function resolveActiveStyle(Template $template): array
    {
        $active   = (string)Settings::getValue($template->getName() . '_active_style', 'default');
        $metaPath = $template->getFullPath() . "/core/styles/{$active}/style.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);
        return [
            'name' => $active,
            'meta' => $meta,
            'vars' => $meta['variables'] ?? [],
        ];
    }

    /**
     * Effective sub-nav visibility for the current page, per scope.
     * Precedence (most specific wins): per-page editor field (on/off) >
     * Settings exception-list picker (a listed page flips the global) >
     * global toggle. Exposed as $myTheme.subnav.{order,website}.
     *
     * @param array<string,mixed> $pages resolveCurrentPage() output
     * @return array{order:bool, website:bool}
     */
    private function resolveSubnav(Template $template, array $vars, array $pages): array
    {
        $tf     = (string)($vars['templatefile'] ?? '');
        $editor = (string)($pages[$tf]['subnav'] ?? 'inherit');

        $orderList = Settings::getValue('subnav_pages_order', []);
        $webList   = Settings::getValue('subnav_pages_website', []);
        if (!is_array($orderList)) { $orderList = []; }
        if (!is_array($webList))   { $webList   = []; }

        $eff = static function (string $editor, bool $inList, bool $global): bool {
            if ($editor === 'on')  { return true; }
            if ($editor === 'off') { return false; }
            return $inList ? !$global : $global; // exception list flips the global
        };

        return [
            'order'   => $eff($editor, in_array($tf, $orderList, true), $this->settingFlag('cart_subnav')),
            'website' => $eff($editor, in_array($tf, $webList, true), $this->settingFlag('website_subnav')),
        ];
    }

    /**
     * Effective service-list controls placement ('inside'|'outside') for the
     * current page. Precedence mirrors resolveSubnav: per-page editor field
     * (inside/outside) > Settings exception-list (a listed page flips the
     * global) > global toggle. Exposed as $myTheme.svcLayout.
     *
     * The global is read directly (default '0' = inside) rather than via
     * settingFlag(), which defaults UNSET to true — that would flip the live
     * default to 'outside' before the admin ever saves the Settings screen.
     *
     * @param array<string,mixed> $pages resolveCurrentPage() output
     */
    private function resolveSvcLayout(Template $template, array $vars, array $pages): string
    {
        $tf     = (string)($vars['templatefile'] ?? '');
        $editor = (string)($pages[$tf]['svclayout'] ?? 'inherit');
        if ($editor === 'inside')  { return 'inside'; }
        if ($editor === 'outside') { return 'outside'; }

        $list = Settings::getValue('svc_layout_pages', []);
        if (!is_array($list)) { $list = []; }

        $raw           = Settings::getValue('service_controls_outside', '0');
        $globalOutside = $raw === '1' || $raw === 1 || $raw === true;
        $inList        = in_array($tf, $list, true);
        $effOutside    = $inList ? !$globalOutside : $globalOutside; // exception list flips the global

        return $effOutside ? 'outside' : 'inside';
    }

    /** A boolean addon flag — defaults to true (shown) when unset. */
    private function settingFlag(string $key): bool
    {
        $v = Settings::getValue($key, '1');
        return $v !== '0' && $v !== 0 && $v !== false && $v !== '';
    }

    private function resolveActiveLayout(Template $template, string $kind): array
    {
        // Lagom-style per-audience pointers. The admin Layouts manager
        // writes one row per (kind, audience): guest-audience visitors
        // get one layout, logged-in clients get another. Fallback chain:
        //   1. per-audience key  mytheme_active_layout_<kind>_<aud>
        //   2. legacy single key mytheme_active_layout_<kind>
        //      (backwards-compat for installs migrated from the
        //      pre-dual-pointer Settings shape)
        //   3. default-by-kind (`main-menu`→`sidebar`, `footer`→`extended`)
        //
        // Keep this default-by-kind table in sync with
        // LayoutsController::DEFAULT_BY_KIND — otherwise the admin's
        // "Active" badge will disagree with the live render.
        $defaultByKind = ['main-menu' => 'sidebar', 'footer' => 'extended'];
        $default       = $defaultByKind[$kind] ?? 'default';

        $audience    = \MyTheme\Menu\Audience::current();
        $audienceKey = $audience === \MyTheme\Menu\Audience::CLIENT ? 'client' : 'guest';

        $newKey = $template->getName() . '_active_layout_' . $kind . '_' . $audienceKey;
        $active = (string)Settings::getValue($newKey, '');

        if ($active === '') {
            $legacyKey = $template->getName() . '_active_layout_' . $kind;
            $active    = (string)Settings::getValue($legacyKey, $default);
        }

        return $this->buildLayoutMeta($template, $kind, $active);
    }

    /** Build a layout metadata struct for a known $name. Shared between the
     *  global resolver and the per-page override path. */
    private function buildLayoutMeta(Template $template, string $kind, string $name): array
    {
        $metaPath = $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);

        // Resolve the layout's saved options (e.g. content alignment); each
        // stored value falls back to the option's declared default. The admin
        // writes these in the Layouts cards (see LayoutsController).
        $supported  = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];
        $storedOpts = Settings::getValue($template->getName() . "_layout_opts_{$kind}_{$name}", []);
        if (!is_array($storedOpts)) { $storedOpts = []; }
        $options = [];
        foreach ($supported as $okey => $ospec) {
            $options[$okey] = (string)($storedOpts[$okey] ?? ($ospec['default'] ?? ''));
        }

        return [
            'name'       => $name,
            'meta'       => $meta,
            'vars'       => $meta['variables'] ?? [],
            'options'    => $options,
            'mediumPath' => "{$template->getName()}/core/layouts/{$kind}/{$name}/default.tpl",
        ];
    }

    /**
     * Resolve the active variant + per-page overrides for the current request.
     *
     * Returned shape (keyed by templatefile, so root tpls can read e.g.
     * $myTheme.pages.login.fullPath):
     *   [
     *     'meta'             => array,    // from core/pages/<page>/page.php
     *     'variant'          => string,   // active variant name
     *     'fullPath'         => ?string,  // include path for root-tpl dispatch
     *     'seo'              => ['title','description','social_image'],
     *     'options'          => array<string,mixed>,
     *     'indexing'         => 'allow'|'disallow'|'inherit',
     *     'visibility'       => 'public'|'auth'|'disabled',
     *     'layout_overrides' => ['main-menu'=>?string,'footer'=>?string],
     *   ]
     */
    private function resolveCurrentPage(array $vars, Template $template): array
    {
        $page = (string)($vars['templatefile'] ?? '');
        if ($page === '') {
            return [];
        }

        // Normalize Nexus-style store templatefile paths to our flat naming
        // convention. WHMCS routes /store/<slug> through a templatefile like
        // 'store/<slug>/index' (or 'store/<slug>/<sub>' for sub-products such
        // as ssl/dv, ssl/ev). Our discovery + admin Pages tab keep them as
        // 'store-<slug>' or 'store-<slug>-<sub>' so they slot into the flat
        // core/pages/ scheme alongside every other page.
        if (preg_match('#^store/([^/]+)(?:/(\w+))?$#', $page, $m)) {
            $slug = $m[1];
            $sub  = $m[2] ?? '';
            $page = ($sub !== '' && $sub !== 'index')
                ? 'store-' . $slug . '-' . $sub
                : 'store-' . $slug;
        }

        $pageMeta = $template->getPageMeta($page);
        $variant  = (string)Settings::getValue(
            $template->getName() . '_page_variant_' . $page,
            (string)($pageMeta['defaultVariant'] ?? 'default')
        );

        // Overwrites escape hatch — Lagom-style buyer override. If a customer
        // dropped core/pages/<page>/overwrites/overwrites.tpl in their theme,
        // that wins over BOTH the admin-selected variant and the default. Lets
        // buyers fully replace a page's body without forking the vendor file,
        // safe across theme updates. Lagom uses the same pattern at
        // templates/lagom2/<page>/overwrites/index.tpl; we keep it inside
        // core/pages/ so it lives next to the variants it overrides.
        $overwritesTpl = $template->getFullPath() . "/core/pages/{$page}/overwrites/overwrites.tpl";
        if (file_exists($overwritesTpl)) {
            $fullPath = "{$template->getName()}/core/pages/{$page}/overwrites/overwrites.tpl";
            $variant  = 'overwrites'; // surface in $myTheme.pages so admin can see it
        } else {
            $variantTpl = $template->getFullPath() . "/core/pages/{$page}/{$variant}/{$variant}.tpl";
            $fullPath   = file_exists($variantTpl)
                ? "{$template->getName()}/core/pages/{$page}/{$variant}/{$variant}.tpl"
                : null;
        }

        $stored = Settings::getValue($template->getName() . '_page_options_' . $page, null);
        if (!is_array($stored)) {
            $stored = [];
        }
        $seoDefaults = is_array($pageMeta['seoDefaults'] ?? null) ? $pageMeta['seoDefaults'] : [];

        // Full-bleed flag — a variant can declare `fullPage => true` in its
        // <variant>.php meta (e.g. login/split), or an admin can enable the
        // page-level `full_page` option. Either makes header.tpl/footer.tpl
        // suppress the portal nav, sidebar/rail, breadcrumb and footer.
        $variantMeta  = ThemeManifest::loadVariantMeta(
            $template->getFullPath() . "/core/pages/{$page}/{$variant}/{$variant}.php"
        );
        $fullPageFlag = (bool)($variantMeta['fullPage'] ?? false)
            || (isset($stored['options']['full_page']) && (bool)$stored['options']['full_page']);

        $entry = [
            'meta'       => $pageMeta,
            'variant'    => $variant,
            'fullPage'   => $fullPageFlag,
            'fullPath'   => $fullPath,
            'indexing'   => (string)($stored['indexing']   ?? $seoDefaults['indexing'] ?? 'inherit'),
            'visibility' => (string)($stored['visibility'] ?? 'public'),
            'seo' => [
                'title'        => (string)($stored['seo']['title']        ?? $seoDefaults['title']        ?? ''),
                'description'  => (string)($stored['seo']['description']  ?? $seoDefaults['description']  ?? ''),
                'social_image' => (string)($stored['seo']['social_image'] ?? ''),
            ],
            'options' => is_array($stored['options'] ?? null) ? $stored['options'] : [],
            'subnav'  => in_array((string)($stored['subnav'] ?? 'inherit'), ['inherit', 'on', 'off'], true)
                ? (string)($stored['subnav'] ?? 'inherit') : 'inherit',
            'svclayout' => in_array((string)($stored['svclayout'] ?? 'inherit'), ['inherit', 'inside', 'outside'], true)
                ? (string)($stored['svclayout'] ?? 'inherit') : 'inherit',
            'layout_overrides' => [
                'main-menu' => isset($stored['layout_overrides']['main-menu']) && is_string($stored['layout_overrides']['main-menu'])
                    ? $stored['layout_overrides']['main-menu'] : null,
                'footer'    => isset($stored['layout_overrides']['footer']) && is_string($stored['layout_overrides']['footer'])
                    ? $stored['layout_overrides']['footer'] : null,
            ],
        ];

        // Expose under the normalized key (admin Pages tab, dispatcher hardcoded keys)
        // AND under the original templatefile when WHMCS used a Nexus-style nested
        // path — so header.tpl's $myTheme.pages[$templatefile] SEO lookup still works.
        $original = (string)($vars['templatefile'] ?? '');
        $out = [$page => $entry];
        if ($original !== '' && $original !== $page) {
            $out[$original] = $entry;
        }
        return $out;
    }

    private function loadLanguage(Template $template, string $lang): array
    {
        $candidate = $template->getFullPath() . "/core/lang/{$lang}.php";
        $path      = file_exists($candidate)
            ? $candidate
            : $template->getFullPath() . '/core/lang/english.php';
        return ThemeManifest::loadVariantMeta($path);
    }
}
