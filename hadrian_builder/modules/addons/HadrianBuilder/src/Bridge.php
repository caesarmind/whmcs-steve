<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The only file in this module that knows the Hadrian addon exists.
 *
 * Hadrian Page Builder is its own WHMCS addon, with its own tables, activation
 * and admin page. It needs Hadrian for three things, and all three go through
 * here so the dependency has one edge instead of being spread through the code:
 *
 *   - the theme: built pages are drawn inside Hadrian's header and footer, and
 *     their sections use the theme's own classes and colour tokens
 *   - languages: which are installed, their codes and native names
 *   - the admin look: Hadrian's shell templates and stylesheet
 *
 * Every method degrades to a safe answer when Hadrian is missing, because the
 * page router runs on client requests and must not be the thing that breaks
 * one.
 */
final class Bridge
{
    /** Module name as WHMCS knows the Hadrian addon. */
    private const HADRIAN = 'Hadrian';

    /** The theme template that prints a module-built page body (see Router). */
    public const PAGE_TEMPLATE = 'module-page';

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

    /** Installed AND switched on in WHMCS, with a theme that can draw a page. */
    public static function available(): bool
    {
        return self::reason() === '';
    }

    /** Why Hadrian cannot be used, in words an admin can act on. '' when it can. */
    public static function reason(): string
    {
        if (!self::boot()) {
            return 'The Hadrian addon is not installed. Hadrian Page Builder draws its pages with the Hadrian theme and cannot run without it.';
        }
        $active = array_map('trim', explode(',', (string)self::config('ActiveAddonModules')));
        if (!in_array(self::HADRIAN, $active, true)) {
            return 'The Hadrian addon is installed but not activated. Activate it under Addon Modules, then come back here.';
        }
        if (!self::themeCanDrawPages()) {
            return 'The active client theme has no "' . self::PAGE_TEMPLATE . '.tpl". Set the Hadrian theme as the WHMCS template and update it to a version that supports the Page Builder.';
        }
        return '';
    }

    /** The active client theme ships the template a built page is printed through. */
    public static function themeCanDrawPages(): bool
    {
        $slug = preg_replace('/[^A-Za-z0-9_-]/', '', self::templateSlug()) ?? '';
        return $slug !== '' && is_file(self::root() . '/templates/' . $slug . '/' . self::PAGE_TEMPLATE . '.tpl');
    }

    public static function root(): string
    {
        return defined('ROOTDIR') ? (string)ROOTDIR : dirname(__DIR__, 4);
    }

    // ------------------------------------------------------- WHMCS settings

    public static function config(string $key): ?string
    {
        try {
            $v = \WHMCS\Database\Capsule::table('tblconfiguration')->where('setting', $key)->value('value');
            return $v === null ? null : (string)$v;
        } catch (\Throwable $e) {
            return null;
        }
    }

    public static function systemUrl(): string
    {
        return rtrim((string)self::config('SystemURL'), '/') . '/';
    }

    /** The path WHMCS is installed under: "" at a domain root, "/billing" in a folder. */
    public static function basePath(): string
    {
        $path = (string)(parse_url(self::systemUrl(), PHP_URL_PATH) ?? '');
        return rtrim($path, '/');
    }

    /** The client-area template WHMCS is set to. */
    public static function templateSlug(): string
    {
        return (string)self::config('Template');
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

    /**
     * The active Hadrian theme's version, for the pill in the shared admin
     * header. '' when it cannot be read; the header then hides the pill.
     */
    public static function themeVersion(): string
    {
        if (!self::boot() || !class_exists('\\Hadrian\\Helpers\\AddonHelper')) {
            return '';
        }
        try {
            return (string)(\Hadrian\Helpers\AddonHelper::getTemplate()?->getVersion() ?? '');
        } catch (\Throwable $e) {
            return '';
        }
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

    /**
     * Tell Hadrian's Media screen where this module keeps image addresses, so
     * it can show "used in" and warn before a delete (see MediaSource). An
     * older Hadrian has no such screen and nothing is registered.
     */
    public static function registerMediaSource(string $id, callable $source): void
    {
        if (self::boot() && class_exists('\\Hadrian\\Helpers\\MediaUsage')) {
            \Hadrian\Helpers\MediaUsage::register($id, $source);
        }
    }

    /** Hadrian is recent enough to list a module's pages in its Pages screen. */
    public static function listsPages(): bool
    {
        return self::boot() && class_exists('\\Hadrian\\Helpers\\ExtensionPages');
    }

    /**
     * Report this module's pages to Hadrian's Pages screen (see SitePages).
     * An older Hadrian has no such list; built pages then work as before,
     * with the settings this module has itself.
     *
     * @param array<string,mixed> $module
     */
    public static function registerPages(array $module): void
    {
        if (self::listsPages()) {
            \Hadrian\Helpers\ExtensionPages::register($module);
        }
    }

    /**
     * A built page was created, changed, published or deleted. Bring
     * Hadrian's page registry up to date now, so the sitemap and the Pages
     * screen do not wait for someone to open Pages. Never throws: the change
     * itself is already saved.
     */
    public static function pagesChanged(): void
    {
        if (!self::listsPages() || !class_exists('\\Hadrian\\Service\\PageRegistry')
            || !method_exists('\\Hadrian\\Service\\PageRegistry', 'syncExtensionPages')) {
            return;
        }
        try {
            $template = \Hadrian\Helpers\AddonHelper::getTemplate();
            if ($template !== null) {
                \Hadrian\Helpers\ExtensionPages::refresh();
                \Hadrian\Service\PageRegistry::syncExtensionPages($template);
            }
        } catch (\Throwable $e) {
            error_log('Hadrian Page Builder: could not update Hadrian\'s page list: ' . $e->getMessage());
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
