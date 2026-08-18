<?php
declare(strict_types=1);

namespace Hadrian\Template;

use Hadrian\Helpers\IntegrityHashes;
use Hadrian\Helpers\ThemeManifest;
use Hadrian\Models\Configuration;

/**
 * Represents one installed template (one directory under templates/).
 *
 * Discovery is via theme.json manifest (NOT filesystem-scan-with-Symfony-Finder).
 */
final class Template
{
    public readonly string $slug;
    public readonly string $version;
    public readonly string $displayName;
    public readonly string $fullPath;
    public readonly bool   $devMode;

    private readonly string $secretKey;
    private readonly array $manifest;
    private ?License $license = null;

    public function __construct(string $slug)
    {
        IntegrityHashes::verifyOrDie(__FILE__);

        $this->slug     = $slug;
        $this->fullPath = self::templatesRoot() . DIRECTORY_SEPARATOR . $slug;

        if (!is_dir($this->fullPath)) {
            throw new \InvalidArgumentException("Template '{$slug}' not found at {$this->fullPath}");
        }

        $coreConfigPath = $this->fullPath . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR . $slug . '.php';
        if (!file_exists($coreConfigPath)) {
            throw new \RuntimeException("Template '{$slug}' is missing core/{$slug}.php");
        }

        /** @var array<string, mixed> $coreConfig */
        $coreConfig = require $coreConfigPath;
        if (!is_array($coreConfig) || empty($coreConfig['secret_key'])) {
            throw new \RuntimeException("Template '{$slug}' core config is malformed");
        }

        $this->secretKey   = (string)$coreConfig['secret_key'];
        $this->version     = (string)($coreConfig['version']      ?? 'unknown');
        $this->displayName = (string)($coreConfig['display_name'] ?? ucfirst($slug));
        $this->devMode     = (bool)($coreConfig['dev_mode']       ?? false);

        $this->manifest = ThemeManifest::load($this->fullPath . DIRECTORY_SEPARATOR . 'theme.json');
    }

    /** @return array<string, self> */
    public static function getAll(): array
    {
        $root  = self::templatesRoot();
        $found = [];
        foreach (scandir($root) ?: [] as $entry) {
            if ($entry === '.' || $entry === '..') continue;
            $path = $root . DIRECTORY_SEPARATOR . $entry;
            if (!is_dir($path)) continue;
            if (!file_exists($path . DIRECTORY_SEPARATOR . 'theme.json')) continue;
            try {
                $found[$entry] = new self($entry);
            } catch (\Throwable) {
                continue;
            }
        }
        return $found;
    }

    public function getName(): string        { return $this->slug; }
    public function getDisplayName(): string { return $this->displayName; }
    public function getVersion(): string     { return $this->version; }
    public function getFullPath(): string    { return $this->fullPath; }

    public function isActive(): bool
    {
        return Configuration::getValue('Template') === $this->slug;
    }

    public function license(): License
    {
        return $this->license ??= LicenseHelper::getInstance(
            licenseKeyName: 'Hadrian-' . $this->slug . '-license',
            secretKey: $this->secretKey,
            template: $this,
        );
    }

    public function canActivate(): bool
    {
        // Dev mode short-circuit — see core/<slug>.php `dev_mode` flag.
        // Disable before encoding for production.
        if ($this->devMode) {
            return true;
        }
        return $this->license()->isActive();
    }

    /** @return list<string> */
    public function getStyles(): array
    {
        return $this->manifest['provides']['styles'] ?? [];
    }

    /**
     * The stored active-style pointer, resolved to a style that ACTUALLY EXISTS.
     *
     * The pointer is a plain settings row; nothing constrains it to the styles
     * this version ships. Three ways it goes stale:
     *
     *   - a style is retired between releases (the 1.7.0 palette replaced the
     *     seven Roman presets outright);
     *   - 'dark', the legacy pointer from before dark became a per-style colour
     *     SCOPE rather than a style you switch to;
     *   - empty, on a fresh install.
     *
     * Left unresolved, a dangling pointer does not fail loudly -- it fails
     * QUIETLY and worse. buildColorsHead reads `_colors_<pointer>_light`, and
     * that row survives the style's removal, so the site keeps rendering the
     * palette of a style the Styles page can no longer show or edit. Meanwhile
     * resolveActiveStyle loads a manifest that isn't there and the bodyClass
     * silently empties, taking any Custom CSS scoped to `.theme-<name>` with it.
     *
     * Resolving to 'default' is the honest answer: the buyer sees the stock
     * theme and a Styles page where picking a card fixes it. Their old rows are
     * left in place rather than deleted -- re-adding a style by that name
     * restores its colours, and seedStyleColors treats an existing row as
     * buyer-owned so it will not stamp over them.
     */
    public function resolveStyleName(string $stored): string
    {
        $stored = trim($stored);
        if ($stored === '' || $stored === 'dark') {
            return 'default';
        }
        return in_array($stored, $this->getStyles(), true) ? $stored : 'default';
    }

    /**
     * Only what theme.json declares — the shipped, authored list. Used by
     * LayoutsCache to reserve shipped names/tokens against shadowing, and by
     * the admin to badge non-declared layouts as "Custom".
     *
     * @return list<string>
     */
    public function getDeclaredLayouts(string $kind): array
    {
        return $this->manifest['provides']['layouts'][$kind] ?? [];
    }

    /**
     * Union of declared (theme.json) and discovered (LayoutsCache) layouts —
     * the same declared-first/dedupe contract as getPages(), and for the same
     * reason: this is the single validation choke point. Admin cards, Activate
     * validation, the per-page override choices AND Hooks' re-validation all
     * flow through here, so custom layouts join every one of those the moment
     * this returns them.
     *
     * readTrusted(), NOT ensure(): unlike getPages() this runs on the CLIENT
     * path (Hooks validates per-page layout overrides during ClientAreaPage),
     * so it must never touch the filesystem. Admin entry points call
     * LayoutsCache::ensure() first, which is what keeps the row fresh.
     *
     * @return list<string>
     */
    public function getLayouts(string $kind): array
    {
        $declared   = $this->manifest['provides']['layouts'][$kind] ?? [];
        $discovered = array_keys(LayoutsCache::readTrusted($this)['layouts'][$kind] ?? []);

        $seen = [];
        $out  = [];
        foreach ([...$declared, ...$discovered] as $name) {
            if (!is_string($name) || $name === '' || isset($seen[$name])) continue;
            $seen[$name] = true;
            $out[] = $name;
        }
        return $out;
    }

    /**
     * Union of declared (theme.json `provides.pages`) and discovered pages.
     *
     * Declared list — what the theme author committed — comes first to preserve
     * authorial intent. Discovered list — built by `PagesCache` at activation
     * and on admin action — appends any `core/pages/*` directory the author
     * hadn't explicitly declared. Dedupe is by name; same dir declared and
     * discovered stays in its declared position.
     *
     * @return list<string>
     */
    /**
     * Cart/order pages — rendered by the separate hadrian_cart order-form
     * template, so they have no core/pages/<page> dir. We surface them in the
     * Pages admin (grouped under "Order Process", Lagom-style) so they can carry
     * per-page settings such as the sub-nav override. Keyed templatefile => label.
     */
    public const ORDER_PAGES = [
        'products'               => 'Products',
        'domainregister'         => 'Register a Domain',
        'domaintransfer'         => 'Transfer a Domain',
        'configuredomains'       => 'Configure Domains',
        'configureproductdomain' => 'Product Domain',
        'configureproduct'       => 'Configure Product',
        'viewcart'               => 'View Cart',
        'checkout'               => 'Checkout',
        'addons'                 => 'Addons',
        'complete'               => 'Order Complete',
        'fraudcheck'             => 'Fraud Check',
    ];

    /**
     * List-style client-area pages whose search/pagination controls can render
     * inside the table card or float outside it (body[data-svc-layout]). These
     * are the only pages the "Service List Controls" admin toggle + per-page
     * override govern — the ones that ship the body[data-svc-layout="outside"]
     * CSS in assets/css/pages/. Page slug (templatefile) list.
     */
    public const SVC_LAYOUT_PAGES = [
        'clientareaproducts',
        'clientareainvoices',
        'clientareaquotes',
        'viewinvoice',
        'viewquote',
        'clientareaaddfunds',
        'supporttickets',
        'clientareahome',
        'affiliates',
    ];

    public function getPages(): array
    {
        // ensure() (not read()) so a page added under core/pages/* surfaces on the
        // next admin visit without a theme-version bump — the cache auto-rebuilds
        // when its directory fingerprint changes (Lagom parity). Admin-only path;
        // ensure() memoizes per request so repeated calls don't re-scan.
        $declared   = $this->manifest['provides']['pages'] ?? [];
        $discovered = PagesCache::ensure($this);
        $order      = array_keys(self::ORDER_PAGES);

        $seen = [];
        $out  = [];
        foreach ([...$declared, ...$discovered, ...$order] as $name) {
            if (!is_string($name) || $name === '' || isset($seen[$name])) continue;
            $seen[$name] = true;
            $out[] = $name;
        }
        return $out;
    }

    /**
     * Load core/pages/<page>/page.php (author contract).
     *
     * Recognised fields:
     *   display_name      string  — human name shown in admin lists
     *   group             string  — Public|Authentication|Client Area|Account|Billing|Support
     *   type              string  — public|client-portal|system|cms
     *   description       string  — one-line description
     *   listDisplay       bool    — whether to surface in admin listings
     *   defaultVariant    string  — variant when admin hasn't picked one (default: 'default')
     *   supportedOptions  array   — keyed map of option specs the editor renders:
     *                                  ['full_page' => ['type'=>'bool','label'=>'Full Page',
     *                                                   'help'=>'…','default'=>false]]
     *   seoDefaults       array   — ['indexing'=>'allow','title'=>'','description'=>'']
     *
     * Returns [] when the file is missing — the controller fills the defaults.
     */
    public function getPageMeta(string $page): array
    {
        $meta = \Hadrian\Helpers\ThemeManifest::loadVariantMeta(
            $this->fullPath . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR
            . 'pages' . DIRECTORY_SEPARATOR . $page . DIRECTORY_SEPARATOR . 'page.php'
        );
        // Cart/order pages have no core/pages dir — synthesize their metadata so
        // they list under "Order Process" in the Pages admin (see ORDER_PAGES).
        if ($meta === [] && isset(self::ORDER_PAGES[$page])) {
            return [
                'display_name'     => self::ORDER_PAGES[$page],
                'group'            => 'Order Process',
                'type'             => 'order-process',
                'description'      => 'Order-form page (rendered by the hadrian_cart template).',
                'listDisplay'      => true,
                'supportedOptions' => [],
            ];
        }
        return $meta;
    }

    /**
     * Load core/pages/<page>/<variant>/<variant>.php.
     *
     * Beyond the `name`/`description`/`fullPage` keys getPageVariants reads, a
     * variant may declare its own `supportedOptions` in exactly the shape
     * page.php uses. Those belong to that ONE template: a dashboard block list
     * only means something to the template that renders those blocks, so a
     * sibling variant must not inherit it or show it in the editor.
     *
     * Returns [] when the file is missing.
     *
     * @return array<string, mixed>
     */
    public function getVariantMeta(string $page, string $variant): array
    {
        if ($page === '' || $variant === '') {
            return [];
        }
        return \Hadrian\Helpers\ThemeManifest::loadVariantMeta(
            $this->fullPath . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR . 'pages'
            . DIRECTORY_SEPARATOR . $page . DIRECTORY_SEPARATOR . $variant
            . DIRECTORY_SEPARATOR . $variant . '.php'
        );
    }

    /**
     * Discover variants for a page from the filesystem.
     *
     * A "variant" is any subdirectory of core/pages/<page>/ that contains a
     * matching <variant>/<variant>.tpl. The optional <variant>.php sibling
     * supplies a display label (`name` key) and any other variant metadata.
     *
     * @return list<array{name:string,label:string,description:string}>
     */
    public function getPageVariants(string $page): array
    {
        $pageDir = $this->fullPath . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR
            . 'pages' . DIRECTORY_SEPARATOR . $page;
        if (!is_dir($pageDir)) {
            return [];
        }

        $variants = [];
        foreach (scandir($pageDir) ?: [] as $entry) {
            if ($entry === '.' || $entry === '..') continue;
            // Skip the buyer overwrites file (Lagom-style escape hatch). When
            // present, Hooks::resolveCurrentPage uses it regardless of variant
            // selection, so showing it in the admin grid would mislead — admins
            // would think they're choosing between overwrites and other variants.
            if ($entry === 'overwrites') continue;
            $variantDir = $pageDir . DIRECTORY_SEPARATOR . $entry;
            if (!is_dir($variantDir)) continue;
            if (!file_exists($variantDir . DIRECTORY_SEPARATOR . $entry . '.tpl')) continue;

            $variantMeta = \Hadrian\Helpers\ThemeManifest::loadVariantMeta(
                $variantDir . DIRECTORY_SEPARATOR . $entry . '.php'
            );
            $variants[] = [
                'name'        => $entry,
                'label'       => (string)($variantMeta['name'] ?? ucfirst(str_replace(['-', '_'], ' ', $entry))),
                'description' => (string)($variantMeta['description'] ?? ''),
            ];
        }

        // Surface 'default' first when present, then alphabetical.
        usort($variants, function ($a, $b) {
            if ($a['name'] === 'default') return -1;
            if ($b['name'] === 'default') return 1;
            return strcmp($a['name'], $b['name']);
        });
        return $variants;
    }

    /**
     * Bulk-load page metadata for the discovery set. Used by the menu builder's
     * "Choose a WHMCS page" picker so it can render a grouped, searchable list
     * with display names instead of raw templatefile slugs.
     *
     * @return array<string, array{name:string,display_name:string,group:string,description:string}>
     */
    public function getAllPageMeta(): array
    {
        $out = [];
        foreach ($this->getPages() as $name) {
            $meta = $this->getPageMeta($name);
            $out[$name] = [
                'name'         => $name,
                'display_name' => (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $name))),
                'group'        => (string)($meta['group'] ?? 'Other'),
                'description'  => (string)($meta['description'] ?? ''),
            ];
        }
        return $out;
    }

    /** @return list<string> */
    public function getExtensions(): array
    {
        return $this->manifest['provides']['extensions'] ?? [];
    }

    public function getManifest(): array
    {
        return $this->manifest;
    }

    private static function templatesRoot(): string
    {
        $root = defined('ROOTDIR') ? ROOTDIR : dirname(__DIR__, 5);
        return rtrim($root, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . 'templates';
    }
}
