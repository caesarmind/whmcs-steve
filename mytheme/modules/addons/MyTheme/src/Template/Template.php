<?php
declare(strict_types=1);

namespace MyTheme\Template;

use MyTheme\Helpers\IntegrityHashes;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Configuration;

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
            licenseKeyName: 'MyTheme-' . $this->slug . '-license',
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

    /** @return list<string> */
    public function getLayouts(string $kind): array
    {
        return $this->manifest['provides']['layouts'][$kind] ?? [];
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
    public function getPages(): array
    {
        $declared   = $this->manifest['provides']['pages'] ?? [];
        $discovered = PagesCache::read($this) ?? [];

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
        return \MyTheme\Helpers\ThemeManifest::loadVariantMeta(
            $this->fullPath . DIRECTORY_SEPARATOR . 'core' . DIRECTORY_SEPARATOR
            . 'pages' . DIRECTORY_SEPARATOR . $page . DIRECTORY_SEPARATOR . 'page.php'
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
            $variantDir = $pageDir . DIRECTORY_SEPARATOR . $entry;
            if (!is_dir($variantDir)) continue;
            if (!file_exists($variantDir . DIRECTORY_SEPARATOR . $entry . '.tpl')) continue;

            $variantMeta = \MyTheme\Helpers\ThemeManifest::loadVariantMeta(
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
