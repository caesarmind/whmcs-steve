<?php
/**
 * What happens to the Pages rows of a module's pages when the module cannot
 * list them. Bug 3 in tests/FEATURES.md, fixed 2026-11-25.
 *
 * An admin's SEO, indexing and visibility for a built page live in its
 * hadrian_pages row. PageRegistry::syncExtensionPages() deletes the row of
 * every page the module no longer reports, which is right when the page was
 * deleted and was wrong when the module merely failed to answer:
 *
 *   - Hadrian: a provider that threw was skipped by ExtensionPages::all(),
 *     but owns() still claimed its prefix, so the sync deleted every row.
 *     The sync now deletes only for modules that answered().
 *   - Page Builder: Page::forSite() turned any database error into [],
 *     which Hadrian cannot tell from "this site has no built pages". It now
 *     answers [] only for a table that does not exist, and throws otherwise.
 *
 * Runs the real ExtensionPages, PageRegistry and HadrianBuilder\Page with
 * in-memory stand-ins for the tables, so no WHMCS and no database are needed.
 *
 *   php tests/static/test-extension-page-rows.php
 */

declare(strict_types=1);

namespace Hadrian\Models {
    /** hadrian_pages, in memory. */
    final class Page
    {
        /** @var array<string, array<string, array<string,mixed>>> */
        public static array $rows = [];

        public static function exists(string $tpl, string $page): bool
        {
            return isset(self::$rows[$tpl][$page]);
        }

        /** @return array<string,mixed>|null */
        public static function get(string $tpl, string $page): ?array
        {
            return self::$rows[$tpl][$page] ?? null;
        }

        /** @param array<string,mixed> $data */
        public static function upsert(string $tpl, string $page, array $data): void
        {
            self::$rows[$tpl][$page] = $data + (self::$rows[$tpl][$page] ?? []) + ['page' => $page];
        }

        /** @return list<array<string,mixed>> */
        public static function all(string $tpl): array
        {
            return array_values(self::$rows[$tpl] ?? []);
        }

        public static function delete(string $tpl, string $page): void
        {
            unset(self::$rows[$tpl][$page]);
        }
    }

    /** hadrian_settings, in memory. */
    final class Settings
    {
        /** @var array<string,mixed> */
        public static array $values = [];

        public static function getValue(string $key, mixed $default = null): mixed
        {
            return self::$values[$key] ?? $default;
        }

        public static function setValue(string $key, mixed $value): void
        {
            self::$values[$key] = $value;
        }
    }
}

namespace Hadrian\Template {
    /** Only what the sync asks a template for. */
    class Template
    {
        public function getName(): string
        {
            return 'hadrian';
        }

        /** @return array<string,mixed> */
        public function getPageMeta(string $page): array
        {
            return \Hadrian\Helpers\ExtensionPages::meta($page);
        }

        /** @return list<string> */
        public function getPages(): array
        {
            return [];
        }
    }
}

namespace Hadrian\Service {
    final class SitemapGenerator
    {
        public static int $refreshed = 0;

        public static function refresh(string $tpl): void
        {
            self::$refreshed++;
        }
    }
}

namespace WHMCS\Database {
    /** A database that has gone away ('down'), or one without the builder's table ('missing'). */
    final class Capsule
    {
        public static string $mode = 'down';

        public static function table(string $name): never
        {
            throw new \RuntimeException(self::$mode === 'down'
                ? 'SQLSTATE[HY000] [2002] Connection refused'
                : "SQLSTATE[42S02]: Base table or view not found: 1146 Table 'whmcs.{$name}' doesn't exist");
        }

        public static function schema(): object
        {
            return new class {
                public function hasTable(string $name): bool
                {
                    if (Capsule::$mode === 'down') {
                        throw new \RuntimeException('SQLSTATE[HY000] [2002] Connection refused');
                    }
                    return false;
                }
            };
        }
    }
}

namespace {
    use Hadrian\Helpers\ExtensionPages as X;
    use Hadrian\Models\Page;
    use Hadrian\Models\Settings;
    use Hadrian\Service\PageRegistry;
    use Hadrian\Service\SitemapGenerator;
    use Hadrian\Template\Template;

    $root = dirname(__DIR__, 2);
    $src  = $root . '/hadrian/modules/addons/Hadrian/src';
    require $src . '/Helpers/PageArea.php';
    require $src . '/Helpers/ExtensionPages.php';
    require $src . '/Service/PageRegistry.php';
    $builder = $root . '/hadrian_builder/modules/addons/HadrianBuilder/src';
    require $builder . '/Schema.php';
    require $builder . '/Page.php';

    // A failing provider is logged by design; keep it out of the output.
    ini_set('error_log', PHP_OS_FAMILY === 'Windows' ? 'NUL' : '/dev/null');

    $ok    = 0;
    $fails = 0;

    function same(string $label, mixed $got, mixed $want): void
    {
        global $ok, $fails;
        if ($got === $want) {
            $ok++;
            return;
        }
        $fails++;
        echo "FAIL  {$label}\n      got:  " . json_encode($got) . "\n      want: " . json_encode($want) . "\n";
    }

    $template = new Template();
    $listing  = static fn (): array => [['id' => 7, 'name' => 'WordPress hosting', 'url' => 'wordpress', 'live' => true, 'replaces' => 'homepage']];
    $broken   = static function (): array { throw new \RuntimeException('Page Builder could not reach its table'); };
    $register = static function (callable $provider): void {
        X::reset();
        X::register(['id' => 'hadrianbuilder', 'prefix' => 'built', 'label' => 'Page Builder', 'group' => 'Built', 'provider' => $provider]);
    };
    $adminSettings = ['seo_title' => '{"english":"WordPress hosting that stays fast"}', 'indexing' => 'allow', 'visibility' => 'auth'];
    $start = static function () use ($register, $listing, $template, $adminSettings): void {
        Page::$rows = [];
        Settings::$values = [];
        $register($listing);
        PageRegistry::syncExtensionPages($template);
        // What an admin then sets in Pages > built-7.
        Page::upsert('hadrian', 'built-7', $adminSettings);
    };

    // ------------------------------------------------------------------
    // What the sync has always done, and must keep doing.
    $start();
    same('a listed page gets a row', Page::exists('hadrian', 'built-7'), true);
    same('what the admin set is stored on it', Page::get('hadrian', 'built-7')['visibility'] ?? null, 'auth');
    same('its stand-in is remembered', Settings::getValue('hadrian_extension_standins'), '{"built-7":"homepage"}');

    $register($listing);
    PageRegistry::syncExtensionPages($template);
    same('a sync that lists the page again keeps the admin settings', Page::get('hadrian', 'built-7')['seo_title'] ?? null, $adminSettings['seo_title']);

    $register(static fn (): array => []);
    PageRegistry::syncExtensionPages($template);
    same('a page the module really deleted loses its row', Page::exists('hadrian', 'built-7'), false);
    same('...and its stand-in is forgotten', Settings::getValue('hadrian_extension_standins'), '');

    // ------------------------------------------------------------------
    // Hadrian: a provider that throws costs the module nothing.
    $start();
    $refreshedBefore = SitemapGenerator::$refreshed;
    $register($broken);
    PageRegistry::syncExtensionPages($template);
    same('a module whose page list fails keeps its pages\' rows', Page::exists('hadrian', 'built-7'), true);
    same('...with the admin\'s Pages settings in them', Page::get('hadrian', 'built-7')['seo_title'] ?? null, $adminSettings['seo_title']);
    same('...and its stand-ins, which are unknown, not gone', Settings::getValue('hadrian_extension_standins'), '{"built-7":"homepage"}');
    same('...so the sitemap is not rebuilt without them', SitemapGenerator::$refreshed, $refreshedBefore);
    same('answered() says the module did not answer', [X::answered('built-7'), X::anyFailed()], [false, true]);

    $register($listing);
    PageRegistry::syncExtensionPages($template);
    same('once it answers again, nothing was lost', Page::get('hadrian', 'built-7')['visibility'] ?? null, 'auth');
    same('...and answered() is true again', [X::answered('built-7'), X::anyFailed()], [true, false]);
    $register(static fn (): array => []);
    PageRegistry::syncExtensionPages($template);
    same('...and a real deletion after that still removes the row', Page::exists('hadrian', 'built-7'), false);
    same('a theme page key is never an answered module page', X::answered('homepage'), false);

    // ------------------------------------------------------------------
    // Page Builder: a failed query reads as a failure, not as no pages.
    \WHMCS\Database\Capsule::$mode = 'down';
    $threw = false;
    $got   = null;
    try {
        $got = \HadrianBuilder\Page::forSite();
    } catch (\Throwable $e) {
        $threw = str_contains($e->getMessage(), 'Connection refused');
    }
    same('Page::forSite() passes a database error on', [$threw, $got], [true, null]);

    \WHMCS\Database\Capsule::$mode = 'missing';
    $got = 'threw';
    try {
        $got = \HadrianBuilder\Page::forSite();
    } catch (\Throwable $e) {
    }
    same('...but a table that does not exist yet still means no pages', $got, []);

    // ------------------------------------------------------------------
    echo $ok . ' ok, ' . $fails . " failed\n";
    exit($fails === 0 ? 0 : 1);
}
