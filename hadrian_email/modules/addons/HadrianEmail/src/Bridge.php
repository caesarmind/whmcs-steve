<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The only file in this module that knows the Hadrian addon exists.
 *
 * Hadrian Email is its own WHMCS addon, with its own tables, activation and
 * admin page. It needs Hadrian for three things, and all three go through
 * here so the dependency has one edge instead of being spread through the
 * code:
 *
 *   - the brand: colours, font, logo, social profiles (Hadrian's settings)
 *   - languages: which are installed, their codes and native names
 *   - the admin look: Hadrian's shell templates, stylesheet and media picker
 *
 * Every method degrades to a safe answer when Hadrian is missing, because the
 * send hook runs on every outgoing email and must not be the thing that
 * breaks one.
 */
final class Bridge
{
    /** Module name as WHMCS knows the Hadrian addon. */
    private const HADRIAN = 'Hadrian';

    private static ?bool $booted = null;

    /**
     * Make Hadrian's classes loadable. True when they are.
     *
     * WHMCS loads each active addon's hooks.php in no promised order, so this
     * module may run before Hadrian has registered its autoloader. Hadrian's
     * autoload.php is guarded by a constant and safe to pull in early.
     */
    public static function boot(): bool
    {
        if (self::$booted !== null) {
            return self::$booted;
        }
        if (!defined('HADRIAN_DIR')) {
            // realpath() so this is the same string PHP records when Hadrian
            // requires the file itself; require_once then sees one file even
            // where the addon directory is a junction or a symlink.
            $file = realpath(self::root() . '/modules/addons/' . self::HADRIAN . '/autoload.php');
            if ($file === false) {
                return self::$booted = false;
            }
            require_once $file;
        }
        return self::$booted = class_exists('\\Hadrian\\Models\\Settings');
    }

    /** Installed AND switched on in WHMCS. */
    public static function available(): bool
    {
        return self::reason() === '';
    }

    /** Why Hadrian cannot be used, in words an admin can act on. '' when it can. */
    public static function reason(): string
    {
        if (!self::boot()) {
            return 'The Hadrian addon is not installed. Hadrian Email Templates takes its colours, logo and fonts from Hadrian and cannot run without it.';
        }
        $active = array_map('trim', explode(',', (string)self::config('ActiveAddonModules')));
        if (!in_array(self::HADRIAN, $active, true)) {
            return 'The Hadrian addon is installed but not activated. Activate it under Addon Modules, then come back here.';
        }
        return '';
    }

    public static function root(): string
    {
        return defined('ROOTDIR') ? (string)ROOTDIR : dirname(__DIR__, 4);
    }

    // ------------------------------------------------------- WHMCS settings

    /**
     * Straight from tblconfiguration. WHMCS's own Setting cache is per
     * process; the takeover has to see what another request just saved.
     */
    public static function config(string $key): ?string
    {
        try {
            $v = \WHMCS\Database\Capsule::table('tblconfiguration')->where('setting', $key)->value('value');
            return $v === null ? null : (string)$v;
        } catch (\Throwable $e) {
            return null;
        }
    }

    public static function setConfig(string $key, string $value): void
    {
        \WHMCS\Database\Capsule::table('tblconfiguration')->updateOrInsert(['setting' => $key], ['value' => $value]);
        // Keep WHMCS's in-process copy in step, or an email sent later in this
        // same request would still be wrapped in the old header.
        try {
            if (class_exists('\\WHMCS\\Config\\Setting')) {
                \WHMCS\Config\Setting::setValue($key, $value);
            }
        } catch (\Throwable $e) {
            // The row is written; the cache catches up on the next request.
        }
    }

    public static function systemUrl(): string
    {
        return rtrim((string)self::config('SystemURL'), '/') . '/';
    }

    /** scheme://host[:port], no path: what a root-relative asset URL hangs off. */
    public static function origin(): string
    {
        if (self::boot()) {
            try {
                return \Hadrian\Helpers\MediaLibrary::origin();
            } catch (\Throwable $e) {
                // Fall through to the local parse.
            }
        }
        $p = parse_url(self::systemUrl());
        if (empty($p['host'])) {
            return '';
        }
        return ($p['scheme'] ?? 'https') . '://' . $p['host'] . (isset($p['port']) ? ':' . (int)$p['port'] : '');
    }

    /** The client-area template WHMCS is set to, which is whose colours email uses. */
    public static function templateSlug(): string
    {
        return (string)self::config('Template');
    }

    // --------------------------------------------------------- Hadrian data

    /** One of Hadrian's own settings (hadrian_settings). */
    public static function setting(string $key, mixed $default = null): mixed
    {
        if (!self::boot()) {
            return $default;
        }
        try {
            return \Hadrian\Models\Settings::getValue($key, $default);
        } catch (\Throwable $e) {
            return $default;
        }
    }

    /** The theme's colour schema (core/config/colors.php), or [] for a non-Hadrian template. */
    public static function colorsConfig(string $slug): array
    {
        $slug = preg_replace('/[^A-Za-z0-9_-]/', '', $slug) ?? '';
        $file = self::root() . '/templates/' . $slug . '/core/config/colors.php';
        if ($slug === '' || !is_file($file)) {
            return [];
        }
        try {
            $data = require $file;
            return is_array($data) ? $data : [];
        } catch (\Throwable $e) {
            return [];
        }
    }

    /** Root-relative URL of a logo uploaded on Hadrian's Branding page, or ''. */
    public static function brandLogo(string $key): string
    {
        if (!self::boot()) {
            return '';
        }
        try {
            $uploader = new \Hadrian\Helpers\Uploader();
            $stored   = $uploader->normalizeStored((string)self::setting($key, ''));
            return $stored === '' ? '' : $uploader->webUrlFor($stored);
        } catch (\Throwable $e) {
            return '';
        }
    }

    /**
     * The links in the site's own legal footer (Hadrian's "footer-secondary"
     * menu), as absolute URLs: the starting point for a new email footer.
     *
     * @return list<array{label: array<string,string>, url: string}>
     */
    public static function footerLinks(): array
    {
        if (!self::boot()) {
            return [];
        }
        try {
            if (!\WHMCS\Database\Capsule::schema()->hasTable('hadrian_menus')) {
                return [];
            }
            $menu = \Hadrian\Models\Menu::pick('footer-secondary', \Hadrian\Menu\Audience::ALL);
            if ($menu === null) {
                return [];
            }
            $origin = self::origin();
            $base   = self::systemUrl();
            $out    = [];
            foreach (\Hadrian\Menu\TreeRenderer::buildFlatList($menu) as $item) {
                $label = trim((string)($item['label'] ?? ''));
                $uri   = trim((string)($item['uri'] ?? ''));
                if ($label === '' || $uri === '' || $uri === '#') {
                    continue;
                }
                if (!preg_match('/^https?:\/\//i', $uri)) {
                    $uri = str_starts_with($uri, '/') ? $origin . $uri : $base . $uri;
                }
                $out[] = ['label' => ['_' => $label], 'url' => $uri];
                if (count($out) >= 6) {
                    break;
                }
            }
            return $out;
        } catch (\Throwable $e) {
            return [];
        }
    }

    // ------------------------------------------------------------ languages

    /** @return list<string> WHMCS language names with a file in /lang */
    public static function languages(): array
    {
        if (self::boot()) {
            try {
                return \Hadrian\Helpers\LocaleHelper::detectInstalled();
            } catch (\Throwable $e) {
                // Fall through.
            }
        }
        return [self::defaultLanguage()];
    }

    /** @return list<string> the languages the site actually offers (Hadrian's curated list) */
    public static function offeredLanguages(): array
    {
        if (self::boot()) {
            try {
                return \Hadrian\Helpers\LocaleHelper::effectiveList();
            } catch (\Throwable $e) {
                // Fall through.
            }
        }
        return self::languages();
    }

    public static function defaultLanguage(): string
    {
        static $memo = null;
        if ($memo === null) {
            $memo = strtolower(trim((string)self::config('Language'))) ?: 'english';
        }
        return $memo;
    }

    /** BCP 47 code for a WHMCS language name: "portuguese-br" gives "pt-br". */
    public static function languageCode(string $name): string
    {
        if (self::boot()) {
            try {
                return \Hadrian\Helpers\LocaleHelper::codeFor($name) ?? 'en';
            } catch (\Throwable $e) {
                // Fall through.
            }
        }
        return 'en';
    }

    public static function languageName(string $name): string
    {
        if (self::boot()) {
            try {
                return \Hadrian\Helpers\LocaleHelper::nativeName($name);
            } catch (\Throwable $e) {
                // Fall through.
            }
        }
        return ucfirst($name);
    }

    // ---------------------------------------------------------- admin shell

    /** Hadrian's admin view directory: the shell partials this module's pages include. */
    public static function shellViews(): string
    {
        return defined('HADRIAN_DIR') ? HADRIAN_DIR . '/views/adminarea' : '';
    }

    /** Hadrian's admin stylesheet, for this module's own page head. */
    public static function shellCss(): string
    {
        $file = self::shellViews() . '/assets/css/admin.css';
        return is_file($file) ? (string)file_get_contents($file) : '';
    }

    /** What Hadrian's shell partials call for their nav links. */
    public static function viewHelper(): ?object
    {
        return self::boot() && class_exists('\\Hadrian\\View\\ViewHelper') ? new \Hadrian\View\ViewHelper() : null;
    }

    /** Smarty 4 and earlier use \Smarty; Smarty 5 moved it. */
    public static function smartyClass(): string
    {
        return match (true) {
            class_exists('\\Smarty\\Smarty') => '\\Smarty\\Smarty',
            class_exists('\\Smarty')         => '\\Smarty',
            default => throw new \RuntimeException('Smarty engine not available'),
        };
    }

    /**
     * Put this module in Hadrian's admin navigation and on its Extensions
     * page. A Hadrian release without the registry simply does not list it;
     * the page is still reachable under WHMCS's Addons menu.
     *
     * @param array<string,string> $entry
     */
    public static function register(array $entry): void
    {
        if (self::boot() && class_exists('\\Hadrian\\Helpers\\Extensions')) {
            \Hadrian\Helpers\Extensions::register($entry);
        }
    }

    /** @return list<array<string,string>> */
    public static function extensionNav(): array
    {
        return self::boot() && class_exists('\\Hadrian\\Helpers\\Extensions')
            ? \Hadrian\Helpers\Extensions::all()
            : [];
    }
}
