<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Database\Migrator;
use Hadrian\Models\Configuration;

/**
 * Gathers the facts the Setup page judges: what is on disk, what the server
 * runs, what the database holds, what the license server says, and which theme
 * the site is using. SetupChecks turns them into the checklist.
 *
 * Each fact is gathered on its own and a failure in one is recorded, not
 * thrown: this page exists for installs where something is wrong, so it has to
 * render when a folder is missing or a table does not exist yet.
 */
final class SetupProbe
{
    /** Where the license check lives, relative to the WHMCS root. */
    public const HOOK = 'includes/hooks/hostnodes_theme_license.php';

    /**
     * Files whose absence means the folder was only partly uploaded. The
     * theme's styles, layouts and declared pages are added from its own
     * theme.json, so this list never has to follow a release.
     */
    private const THEME_FILES = ['theme.json', 'core/hadrian.php', 'header.tpl', 'footer.tpl', 'homepage.tpl', 'clientareahome.tpl'];
    private const CART_FILES  = ['theme.yaml', 'common.tpl', 'products.tpl', 'configureproduct.tpl', 'viewcart.tpl', 'checkout.tpl', 'complete.tpl'];

    /** PHP extensions the addon calls directly. */
    private const EXTENSIONS = ['curl', 'mbstring'];

    /**
     * Is there something the admin has to do before the theme can run: it is
     * not the site's theme yet, or new files are ahead of the database?
     *
     * Asked on every Hadrian admin page (for the notice in the header), so it
     * is two cheap reads and never touches the network.
     */
    public static function needsAttention(): bool
    {
        try {
            if ((string)Configuration::getValue('Template') !== ThemeSwitch::THEME) {
                return true;
            }
            return (new Migrator(self::addonRoot()))->pending() !== [];
        } catch (\Throwable) {
            return false; // never let the notice take an admin page down
        }
    }

    /**
     * @param bool $freshLicense ask the license server now instead of using a recent answer
     * @return array<string,mixed>
     */
    public static function facts(bool $freshLicense = false): array
    {
        $root     = self::root();
        $themeDir = $root . '/templates/' . ThemeSwitch::THEME;
        $cartDir  = $root . '/templates/orderforms/' . ThemeSwitch::CART;
        $manifest = self::manifest($themeDir . '/theme.json');
        $uploads  = 'templates/' . ThemeSwitch::THEME . '/assets/img/branding';

        return [
            'slugs' => ['theme' => ThemeSwitch::THEME, 'cart' => ThemeSwitch::CART],
            'theme' => [
                'path'    => 'templates/' . ThemeSwitch::THEME,
                'present' => is_dir($themeDir),
                'missing' => is_dir($themeDir) ? self::missing($themeDir, array_merge(self::THEME_FILES, self::declared($manifest))) : [],
                'version' => self::themeVersion($themeDir),
            ],
            'cart' => [
                'path'    => 'templates/orderforms/' . ThemeSwitch::CART,
                'present' => is_dir($cartDir),
                'missing' => is_dir($cartDir) ? self::missing($cartDir, self::CART_FILES) : [],
            ],
            'hook' => [
                'path'    => self::HOOK,
                'present' => is_file($root . '/' . self::HOOK),
            ],
            // The release each folder came from: scripts/package.mjs writes the
            // same release.json into all three. null = the folder is not
            // there, '' = there but unmarked (a source checkout has none).
            'release' => [
                'theme' => self::releaseOf($themeDir),
                'cart'  => self::releaseOf($cartDir),
                'addon' => self::releaseOf(self::addonRoot()),
            ],
            'requires'         => is_array($manifest['requires'] ?? null) ? $manifest['requires'] : [],
            'php'              => PHP_VERSION,
            'whmcs'            => self::whmcsVersion(),
            'extensions'       => array_combine(self::EXTENSIONS, array_map('extension_loaded', self::EXTENSIONS)),
            'uploads_path'     => $uploads,
            'uploads_writable' => self::writable($root . '/' . $uploads),
            'migrations'       => self::migrations(),
            'menus'            => self::menuCount(),
            'license'          => self::license($freshLicense),
            'live'             => self::liveState(),
        ];
    }

    public static function root(): string
    {
        $root = defined('ROOTDIR') ? (string)ROOTDIR : dirname(__DIR__, 5);
        return rtrim(str_replace('\\', '/', $root), '/');
    }

    public static function addonRoot(): string
    {
        return defined('HADRIAN_DIR') ? (string)HADRIAN_DIR : dirname(__DIR__, 2);
    }

    // ------------------------------------------------------------------- disk

    /** @return array<string,mixed> */
    private static function manifest(string $path): array
    {
        $raw  = is_file($path) ? @file_get_contents($path) : false;
        $data = is_string($raw) ? json_decode($raw, true) : null;
        return is_array($data) ? $data : [];
    }

    /**
     * The folders theme.json says this version ships, as paths under the
     * theme. A release that adds a style or a page is covered without touching
     * this file.
     *
     * @return list<string>
     */
    private static function declared(array $manifest): array
    {
        $provides = is_array($manifest['provides'] ?? null) ? $manifest['provides'] : [];
        $paths    = [];
        foreach ((array)($provides['styles'] ?? []) as $style) {
            if (is_string($style)) {
                $paths[] = 'core/styles/' . $style;
            }
        }
        foreach ((array)($provides['layouts'] ?? []) as $kind => $names) {
            foreach ((array)$names as $name) {
                if (is_string($name)) {
                    $paths[] = 'core/layouts/' . $kind . '/' . $name;
                }
            }
        }
        foreach ((array)($provides['pages'] ?? []) as $page) {
            if (is_string($page)) {
                $paths[] = 'core/pages/' . $page;
            }
        }
        // Names come from a file on disk; keep anything that climbs out of the theme away.
        return array_values(array_filter($paths, static fn(string $p) => !str_contains($p, '..')));
    }

    /** @return list<string> the entries of $wanted that are not under $dir */
    private static function missing(string $dir, array $wanted): array
    {
        $gone = [];
        foreach ($wanted as $rel) {
            if (!file_exists($dir . '/' . $rel)) {
                $gone[] = $rel;
            }
        }
        return $gone;
    }

    private static function releaseOf(string $dir): ?string
    {
        if (!is_dir($dir)) {
            return null;
        }
        $mark = self::manifest($dir . '/release.json');
        return is_string($mark['release'] ?? null) ? $mark['release'] : '';
    }

    private static function themeVersion(string $themeDir): string
    {
        $file = $themeDir . '/core/' . ThemeSwitch::THEME . '.php';
        if (!is_file($file)) {
            return '';
        }
        try {
            $config = require $file;
            return is_array($config) ? (string)($config['version'] ?? '') : '';
        } catch (\Throwable) {
            return ''; // a truncated upload can leave a file PHP cannot parse
        }
    }

    private static function writable(string $dir): bool
    {
        // The Uploader creates the folder on first use, so a missing folder is
        // fine as long as its parent can be written to.
        while (!is_dir($dir)) {
            $parent = dirname($dir);
            if ($parent === $dir) {
                return false;
            }
            $dir = $parent;
        }
        return is_writable($dir);
    }

    // ------------------------------------------------------------ server + db

    private static function whmcsVersion(): string
    {
        try {
            $raw = (string)Configuration::getValue('Version');
        } catch (\Throwable) {
            return '';
        }
        return preg_match('/^\d+(?:\.\d+)*/', $raw, $m) ? $m[0] : '';
    }

    /** @return array{total:int,pending:list<string>,error:string} */
    private static function migrations(): array
    {
        try {
            $migrator = new Migrator(self::addonRoot());
            return ['total' => $migrator->total(), 'pending' => $migrator->pending(), 'error' => ''];
        } catch (\Throwable $e) {
            return ['total' => 0, 'pending' => [], 'error' => $e->getMessage()];
        }
    }

    private static function menuCount(): int
    {
        try {
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                return 0;
            }
            return (int)\WHMCS\Database\Capsule::table('hadrian_menus')->count();
        } catch (\Throwable) {
            return 0;
        }
    }

    /** @return array{key:string,status:string,active:bool} */
    private static function license(bool $fresh): array
    {
        try {
            $key    = (string)Configuration::getValue('hadrian_license_key');
            $result = LicenseCheck::status($key, $fresh);
            return ['key' => $key, 'status' => (string)$result['status'], 'active' => (bool)$result['active']];
        } catch (\Throwable) {
            return ['key' => '', 'status' => 'Unknown', 'active' => false];
        }
    }

    /** @return array{template:string,orderform:string,prev_template:string,prev_orderform:string} */
    private static function liveState(): array
    {
        try {
            return ThemeSwitch::state();
        } catch (\Throwable) {
            return ['template' => '', 'orderform' => '', 'prev_template' => '', 'prev_orderform' => ''];
        }
    }
}
