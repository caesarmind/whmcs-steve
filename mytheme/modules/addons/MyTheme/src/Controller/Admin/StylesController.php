<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;

final class StylesController extends AbstractController
{
    /**
     * Built-in accent presets for the Color Scheme picker. Each carries a single
     * accent hex; the render-time emitter (Hooks::buildColorsHead) derives the
     * hover / tint / link / dark-mode variants from it. Index [0] is the theme
     * default (no override is stored while it's selected).
     */
    private const COLOR_PRESETS = [
        ['name' => 'Default', 'accent' => '#0071e3'],
        ['name' => 'Emerald', 'accent' => '#14b17d'],
        ['name' => 'Violet',  'accent' => '#8c5cff'],
        ['name' => 'Rose',    'accent' => '#ff2d6b'],
        ['name' => 'Amber',   'accent' => '#f08a00'],
        ['name' => 'Slate',   'accent' => '#64748b'],
    ];

    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['style'])) {
            return $this->saveAction($template);
        }

        $available = $template->getStyles();
        $current   = Settings::getValue($template->getName() . '_active_style', 'default');

        $list = [];
        foreach ($available as $name) {
            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . "/core/styles/{$name}/style.php"
            );
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

        $style  = (string)($_GET['style'] ?? 'default');
        $subcat = (string)($_GET['subcat'] ?? 'colors');
        $tab    = (string)($_GET['tab'] ?? 'variables');
        if (!in_array($tab, ['variables', 'settings', 'custom-css'], true)) {
            $tab = 'variables';
        }

        return $this->view('styles/edit', [
            'template'    => $template->getName(),
            'style'       => $style,
            'styleName'   => ucfirst($style),
            'subcat'      => $subcat,
            'tab'         => $tab,
            // Built only for the Variables tab (the only one that renders them),
            // so the other tabs skip the folder scan + view-model work.
            'colors'      => $tab === 'variables' ? $this->buildColorsViewModel($template) : null,
            'typography'  => $tab === 'variables' ? $this->buildTypographyViewModel($template) : null,
            'saved'       => isset($_GET['saved']),
            'colorsSaved' => isset($_GET['colors_saved']),
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

        return [
            'sizeGroups'    => $sizeGroups,
            'weights'       => $weights,
            'weightOptions' => $cfg['weightOptions'] ?? [300, 400, 500, 600, 700, 900],
            'googleFonts'   => $cfg['googleFonts'] ?? [],
            'sizeMin'       => (int)($cfg['sizeMin'] ?? 8),
            'sizeMax'       => (int)($cfg['sizeMax'] ?? 160),
            'folderFonts'   => $folderFonts,
            'fontFamily'    => [
                'mode'   => (string)($ff['mode']   ?? 'default'),
                'google' => (string)($ff['google'] ?? ''),
                'custom' => (string)($ff['custom'] ?? ''),
                'folder' => (string)($ff['folder'] ?? ''),
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

        // Font family
        $mode = (string)($_POST['ff_mode'] ?? 'default');
        if ($mode === 'google' && trim((string)($_POST['ff_google'] ?? '')) !== '') {
            $out['fontFamily'] = ['mode' => 'google', 'google' => trim((string)$_POST['ff_google'])];
        } elseif ($mode === 'custom' && trim((string)($_POST['ff_custom'] ?? '')) !== '') {
            $out['fontFamily'] = ['mode' => 'custom', 'custom' => trim((string)$_POST['ff_custom'])];
        } elseif ($mode === 'folder' && trim((string)($_POST['ff_folder'] ?? '')) !== '') {
            // Only accept a filename that's actually present in the scanned folder.
            $file = basename(trim((string)$_POST['ff_folder']));
            foreach ($this->scanFontFolder($template) as $f) {
                if ($f['file'] === $file) {
                    $out['fontFamily'] = ['mode' => 'folder', 'folder' => $file];
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

    /** Normalize a #rgb or #rrggbb string to a lowercase #rrggbb, or null if invalid. */
    private function normalizeHex(string $hex): ?string
    {
        $hex = trim($hex);
        if (preg_match('/^#?([0-9a-fA-F]{6})$/', $hex, $m)) {
            return '#' . strtolower($m[1]);
        }
        if (preg_match('/^#?([0-9a-fA-F]{3})$/', $hex, $m)) {
            $c = $m[1];
            return '#' . strtolower($c[0] . $c[0] . $c[1] . $c[1] . $c[2] . $c[2]);
        }
        return null;
    }

    /**
     * View-model for the Colors subcat: the preset list (flagging which one
     * matches the stored accent), the current effective accent, the resolved
     * active scheme name, and the theme default.
     */
    private function buildColorsViewModel($template): array
    {
        $stored = Settings::getValue($template->getName() . '_colors', []);
        if (!is_array($stored)) {
            $stored = [];
        }
        $accent = $this->normalizeHex((string)($stored['accent'] ?? '')) ?? self::COLOR_PRESETS[0]['accent'];

        $activeScheme = 'custom';
        $presets = [];
        foreach (self::COLOR_PRESETS as $p) {
            $isActive = strcasecmp($p['accent'], $accent) === 0;
            if ($isActive) {
                $activeScheme = $p['name'];
            }
            $presets[] = $p + ['active' => $isActive];
        }

        return [
            'presets'       => $presets,
            'accent'        => $accent,
            'activeScheme'  => $activeScheme,
            'defaultAccent' => self::COLOR_PRESETS[0]['accent'],
        ];
    }

    /**
     * Validate + persist the Color Scheme form. Stores only a non-default accent
     * (keeps the override set empty while on Default, mirroring Typography). The
     * render-time emitter (Hooks::buildColorsHead) derives the full token chain.
     * PRG redirect back to the Colors subcat.
     */
    private function saveColorsAction($template): string
    {
        $accent = $this->normalizeHex((string)($_POST['accent'] ?? ''));

        $out = [];
        if ($accent !== null && strcasecmp($accent, self::COLOR_PRESETS[0]['accent']) !== 0) {
            $scheme = 'custom';
            foreach (self::COLOR_PRESETS as $p) {
                if (strcasecmp($p['accent'], $accent) === 0) {
                    $scheme = $p['name'];
                    break;
                }
            }
            $out = ['scheme' => $scheme, 'accent' => $accent];
        }

        Settings::setValue($template->getName() . '_colors', $out, 'json');

        $style = (string)($_POST['style'] ?? 'default');
        $this->redirect('?module=MyTheme&action=editStyle&style=' . urlencode($style) . '&subcat=colors&colors_saved=1');
    }
}
