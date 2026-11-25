<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Serves built pages at their addresses.
 *
 * WHMCS sends every request that is not a real file through index.php. A
 * path none of its own routes match ends as its "page not found" page, and
 * on the way there it runs the ClientAreaPage hook with nothing sent yet.
 * That is the one place this class acts: if the requested path is the address
 * of a published page, it draws that page through the theme and ends the
 * request with a 200.
 *
 * Hooking the not-found page means no rewrite rule or file in the WHMCS root
 * is needed (the server configuration WHMCS already requires is enough), and
 * a built page's own address can never shadow one WHMCS answers.
 *
 * The one exception is deliberate and opt-in: a built page may stand in for
 * one of a short list of the theme's website pages (see Replace). That goes
 * through the same hook, when WHMCS is about to draw that theme page.
 *
 * The editor's preview comes through here too, at preview/<id> under
 * PREVIEW_PREFIX, for a signed-in admin only.
 */
final class Router
{
    /** WHMCS's own template for an address nothing matched. */
    private const NOT_FOUND = 'error/page-not-found';

    /** First path segment of the editor's preview address. Not a valid page slug prefix for visitors. */
    public const PREVIEW_PREFIX = 'hb-preview';

    /** Session key holding documents the editor has not saved yet, by page id. */
    public const PREVIEW_SESSION = 'hadrianBuilderPreview';

    /** True while this class is drawing its own page, so its hook stands aside. */
    private static bool $serving = false;

    /**
     * ClientAreaPage hook. Returns [] in every case where WHMCS should carry
     * on with whatever it was doing; does not return when it serves a page.
     *
     * @param array<string,mixed> $vars
     * @return array<string,mixed>
     */
    public static function intercept(array $vars): array
    {
        if (self::$serving) {
            return [];
        }
        if (!in_array($_SERVER['REQUEST_METHOD'] ?? 'GET', ['GET', 'HEAD'], true)) {
            return [];
        }
        $template = (string)($vars['templatefile'] ?? '');
        if ($template !== self::NOT_FOUND) {
            return self::interceptReplaced($template, $vars);
        }
        try {
            $path = self::requestedPath();
            if ($path === '' || !Bridge::available()) {
                return [];
            }
            $found = self::resolve($path);
            if ($found === null) {
                return [];
            }
            self::serve($found['page'], $found['doc'], $found['preview'], $vars);
        } catch (\Throwable $e) {
            // Whatever went wrong, the visitor still gets WHMCS's own
            // not-found page rather than an error.
            error_log('Hadrian Page Builder: could not serve "' . ($_SERVER['REQUEST_URI'] ?? '') . '": ' . $e->getMessage()
                . ' at ' . $e->getFile() . ':' . $e->getLine());
            self::$serving = false;
        }
        return [];
    }

    /**
     * WHMCS is about to draw one of the theme's own website pages. If a built
     * page stands in for it right now (see Replace), draw that instead.
     *
     * A signed-in admin can add ?hb_original=1 to see the theme's page while
     * the built one is live.
     *
     * @param array<string,mixed> $vars
     * @return array<string,mixed>
     */
    private static function interceptReplaced(string $template, array $vars): array
    {
        if (!Replace::isTarget($template)) {
            return [];
        }
        try {
            $query = $_GET;
            if (isset($query['hb_original'])) {
                if (self::isAdmin()) {
                    return [];
                }
                unset($query['hb_original']);
            }
            if (!Bridge::available()) {
                return [];
            }
            $page = Replace::pageFor($template, self::requestedPath(), $query);
            if ($page !== null) {
                self::serve($page, (array)$page['published'], false, $vars);
            }
        } catch (\Throwable $e) {
            // The theme's own page is still there to draw.
            error_log('Hadrian Page Builder: could not replace "' . $template . '": ' . $e->getMessage()
                . ' at ' . $e->getFile() . ':' . $e->getLine());
            self::$serving = false;
        }
        return [];
    }

    /**
     * The page and document for a path, or null.
     *
     * @return array{page: array<string,mixed>, doc: array<string,mixed>, preview: bool}|null
     */
    private static function resolve(string $path): ?array
    {
        if (preg_match('#^' . self::PREVIEW_PREFIX . '/(\d+)$#', $path, $m)) {
            if (!self::isAdmin()) {
                return null;
            }
            $id   = (int)$m[1];
            $page = Page::find($id);
            if ($page === null) {
                return null;
            }
            // One section type on its own, for the editor's "add a section"
            // list to show what it looks like before it is added.
            $sample = $_GET['hb_sample'] ?? null;
            if (is_string($sample) && $sample !== '' && ($doc = self::sample($sample)) !== null) {
                return ['page' => $page, 'doc' => $doc, 'preview' => true];
            }
            // What the editor last sent, if anything; otherwise the saved draft.
            $unsaved = $_SESSION[self::PREVIEW_SESSION][$id] ?? null;
            return ['page' => $page, 'doc' => is_array($unsaved) ? $unsaved : (array)$page['draft'], 'preview' => true];
        }

        $slug = Text::slug($path);
        if ($slug === '' || $slug !== $path) {
            return null;        // not shaped like a page address: leave it to WHMCS
        }
        $page = Page::bySlug($slug);
        return $page === null ? null : ['page' => $page, 'doc' => (array)$page['published'], 'preview' => false];
    }

    /**
     * A page of one section of $type with its default content. Product
     * fields get the first products in WHMCS, so a pricing section shows real
     * prices instead of "nothing to show yet". Null for an unknown type.
     *
     * @return array<string,mixed>|null
     */
    public static function sample(string $type): ?array
    {
        $languages = Bridge::languages();
        $section   = Document::make($type, $languages);
        $def       = Sections::type($type);
        if ($section === null || $def === null) {
            return null;
        }
        $ids  = array_column(array_slice(Catalog::options(), 0, 6), 'id');
        $next = 0;
        $pid  = static function () use ($ids, &$next): int {
            return $ids === [] ? 0 : (int)$ids[$next++ % count($ids)];
        };
        foreach ($def['fields'] as $f) {
            if ($f['type'] === 'product') {
                $section['props'][$f['key']] = $pid();
            } elseif ($f['type'] === 'list') {
                $productKeys = array_column(array_filter($f['fields'], static fn(array $s): bool => $s['type'] === 'product'), 'key');
                if ($productKeys === []) {
                    continue;
                }
                $items = $section['props'][$f['key']] ?: [[], [], []];
                foreach ($items as &$item) {
                    foreach ($productKeys as $k) {
                        $item[$k] = $pid();
                    }
                }
                unset($item);
                $section['props'][$f['key']] = $items;
            }
        }
        return Document::normalize(['sections' => [$section]], $languages);
    }

    /**
     * @param array<string,mixed> $page
     * @param array<string,mixed> $doc
     * @param array<string,mixed> $vars the not-found page's template variables
     */
    private static function serve(array $page, array $doc, bool $preview, array $vars): never
    {
        self::$serving = true;

        $lang = self::language($vars);
        if ($preview && isset($_GET['hb_lang']) && is_string($_GET['hb_lang'])) {
            $wanted = strtolower($_GET['hb_lang']);
            if ($wanted === '_' || in_array($wanted, Bridge::languages(), true)) {
                $lang = $wanted === '_' ? Bridge::defaultLanguage() : $wanted;
            }
        }

        $html = Renderer::page($doc, [
            'lang'      => $lang,
            'webRoot'   => Bridge::basePath(),
            'loggedIn'  => !empty($vars['loggedin']),
            'annotate'  => $preview,
            'languages' => Bridge::languages(),
        ]);

        $meta  = Document::normalizeMeta((array)($page['meta'] ?? []));
        $title = Text::pick($meta['title'], $lang);
        if ($title === '') {
            $title = (string)$page['name'];
        }

        // WHMCS set a 404 for the page it was about to draw.
        http_response_code(200);
        if ($preview) {
            header('X-Robots-Tag: noindex, nofollow');
            header('Cache-Control: no-store');
        }

        $ca = new \WHMCS\ClientArea();
        $ca->setPageTitle($title);
        $ca->initPage();
        $ca->assign('modulePageHtml', $html);
        $ca->assign('modulePage', [
            'module'      => AdminController::MODULE,
            'id'          => (int)$page['id'],
            // The page's row in Hadrian's Pages screen; the theme applies
            // that row's settings to this request.
            'pageKey'     => SitePages::key((int)$page['id']),
            'slug'        => (string)$page['slug'],
            'title'       => $title,
            'description' => Text::pick($meta['description'], $lang),
            'preview'     => $preview,
        ]);
        $ca->setTemplate(Bridge::PAGE_TEMPLATE);
        $ca->output();
        exit;
    }

    /**
     * The requested path relative to the WHMCS address, without slashes at
     * either end: "hosting", "about/team". '' when it cannot be a page.
     *
     * Covers WHMCS's three URL modes: /hosting, /index.php/hosting and
     * /index.php?rp=/hosting.
     */
    public static function requestedPath(): string
    {
        $uri  = (string)($_SERVER['REQUEST_URI'] ?? '');
        $path = (string)(parse_url($uri, PHP_URL_PATH) ?? '');
        $path = rawurldecode($path);

        $base = Bridge::basePath();
        if ($base !== '' && str_starts_with($path, $base . '/')) {
            $path = substr($path, strlen($base));
        }
        $path = trim($path, '/');

        if ($path === 'index.php' || $path === '') {
            $rp   = $_GET['rp'] ?? '';
            $path = is_string($rp) ? trim(rawurldecode($rp), '/') : '';
        } elseif (str_starts_with($path, 'index.php/')) {
            $path = trim(substr($path, 10), '/');
        }
        return strlen($path) > 160 ? '' : $path;
    }

    /** @param array<string,mixed> $vars */
    private static function language(array $vars): string
    {
        foreach ([$vars['language'] ?? null, $_SESSION['Language'] ?? null] as $candidate) {
            if (is_string($candidate) && $candidate !== '') {
                return strtolower($candidate);
            }
        }
        return Bridge::defaultLanguage();
    }

    /** A signed-in WHMCS admin is making this request. */
    private static function isAdmin(): bool
    {
        return !empty($_SESSION['adminid']);
    }

    /** The address a page is served at, as a path from the domain root. */
    public static function urlFor(string $slug): string
    {
        return Bridge::basePath() . '/' . $slug;
    }

    /** The preview address of a page, as a path from the domain root. */
    public static function previewUrlFor(int $id): string
    {
        return Bridge::basePath() . '/' . self::PREVIEW_PREFIX . '/' . $id;
    }
}
