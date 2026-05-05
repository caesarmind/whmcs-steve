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

    /** @return list<string> */
    public function getPages(): array
    {
        return $this->manifest['provides']['pages'] ?? [];
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
