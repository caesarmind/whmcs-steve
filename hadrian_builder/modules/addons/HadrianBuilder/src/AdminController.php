<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The module's admin page: addonmodules.php?module=HadrianBuilder
 *
 * dispatch() reads ?action= :
 *   index     every page, with its address and status, and the "new page" form
 *   edit      the editor for one page (&id=)
 *   create    POST make a page and open it in the editor
 *   delete    POST remove a page
 *   mode      POST set "Website served by" (Theme or Page Builder)
 *   replace   POST choose the theme page a built page stands in for, and when
 *
 * The editor talks JSON to its endpoints (api-preview, api-save, api-publish,
 * api-unpublish), and the section list on a built page's settings in Pages
 * (ContentPanel) to api-content, api-preview and api-publish. They come
 * through dispatch() like every other action, so
 * WHMCS has already enforced the admin login and this addon's role
 * permissions; they answer and exit before WHMCS prints any admin chrome.
 *
 * Every write checks the WHMCS admin CSRF token: these actions change what a
 * company's public site says.
 *
 * The pages are drawn inside Hadrian's admin shell (its header, navigation,
 * footer scripts and stylesheet), so the module looks like a part of Hadrian
 * while living in its own folder.
 */
final class AdminController
{
    public const VERSION = '0.1.0';
    public const MODULE  = 'HadrianBuilder';
    public const BASE    = '?module=HadrianBuilder';

    /**
     * What Hadrian's navigation highlights while this module's editor is
     * open. The module has no tab of its own: its pages are listed in
     * Hadrian's Pages (see SitePages), so the editor belongs under that tab.
     */
    public const NAV_KEY = 'pages';

    public function dispatch(): string
    {
        $this->ensureSchema();
        $action = (string)($_GET['action'] ?? 'index');

        // The editor's JSON endpoints. Handled here, inside _output(), and not
        // from hooks.php: this is the first point at which WHMCS has verified
        // the admin login and this addon's role permissions. See hooks.php.
        if (str_starts_with($action, 'api-')) {
            try {
                $this->api($action);
            } catch (\Throwable $e) {
                error_log('Hadrian Page Builder AJAX: ' . $e->getMessage() . ' at ' . $e->getFile() . ':' . $e->getLine());
                // Signed-in admins only by this point, so the real message is
                // useful and safe to show.
                $this->json(['ok' => false, 'error' => 'Server error: ' . $e->getMessage()], 500);
            }
        }

        if (!Bridge::available()) {
            return $this->unavailable();
        }
        // The list of built pages, the site switch and the replace rules are
        // drawn inside Hadrian's Pages screen. An older Hadrian has no such
        // place for them.
        if (!Bridge::listsPages()) {
            return $this->unavailable('This version of Hadrian Page Builder lists its pages in Hadrian\'s Pages screen, which the installed Hadrian addon does not offer yet. Update Hadrian, then come back here.');
        }
        return match ($action) {
            'edit'   => $this->edit(),
            'create' => $this->create(),
            'delete' => $this->delete(),
            'mode'    => $this->setMode(),
            'replace' => $this->setReplaces(),
            // No screen of its own: the pages are in Hadrian's Pages.
            default  => $this->redirect(SitePages::listUrl()),
        };
    }

    // ---------------------------------------------------------------- pages
    // Made, replaced and deleted from Hadrian's Pages screen (SitePages draws
    // the controls there); each of these answers by sending the admin back.

    private function create(): string
    {
        $this->requirePost();
        $name = Text::line(html_entity_decode((string)($_POST['name'] ?? ''), ENT_QUOTES, 'UTF-8'), 120);
        if ($name === '') {
            $this->fail('Give the page a name.');
        }
        // Suggest an address from the name; the editor lets the admin change it.
        $slug = Text::slug((string)preg_replace('/[^a-z0-9]+/', '-', strtolower($name)));
        if ($slug !== '' && Page::slugTaken($slug)) {
            $slug = '';
        }
        $id = Page::create([
            'name' => $name,
            'slug' => $slug,
            'meta' => Document::normalizeMeta(['title' => $name]),
        ]);
        Bridge::pagesChanged();
        $this->redirect(self::BASE . '&action=edit&id=' . $id);
    }

    private function delete(): string
    {
        $this->requirePost();
        $id   = (int)($_POST['id'] ?? 0);
        $page = Page::find($id);
        if ($page === null) {
            $this->fail('That page no longer exists.');
        }
        Page::delete($id);
        Bridge::pagesChanged();
        unset($_SESSION[Router::PREVIEW_SESSION][$id]);
        $this->done('"' . $page['name'] . '" was deleted.');
    }

    // ------------------------------------------------- replacing theme pages

    private function setMode(): string
    {
        $this->requirePost();
        $mode = (string)($_POST['mode'] ?? '');
        if (!in_array($mode, [Replace::MODE_THEME, Replace::MODE_BUILDER], true)) {
            $this->fail('Choose Theme or Page Builder.');
        }
        Replace::setMode($mode);
        Bridge::pagesChanged();
        $this->done($mode === Replace::MODE_BUILDER
            ? 'Your website is now served by Page Builder wherever a built page replaces a theme page.'
            : 'Your website is now served by the theme. Built replacements are kept on standby.');
    }

    private function setReplaces(): string
    {
        $this->requirePost();
        $id   = (int)($_POST['id'] ?? 0);
        $page = Page::find($id);
        if ($page === null) {
            $this->fail('That page no longer exists.');
        }
        $target = (string)($_POST['replaces'] ?? '');
        if ($target !== '' && !Replace::isTarget($target)) {
            $this->fail('That page cannot be replaced.');
        }
        Page::setReplaces($id, $target, Replace::rule((string)($_POST['replace_rule'] ?? '')));
        Bridge::pagesChanged();
        $this->done($target === ''
            ? '"' . $page['name'] . '" no longer replaces a theme page.'
            : '"' . $page['name'] . '" now replaces ' . Replace::TARGETS[$target] . '.', $id);
    }

    // --------------------------------------------------------------- editor

    private function edit(): string
    {
        $id   = (int)($_GET['id'] ?? 0);
        $page = Page::find($id);
        if ($page === null) {
            $this->fail('That page no longer exists.');
        }
        $installed = Bridge::languages();

        // Opening the editor starts from what is saved, not from a preview an
        // earlier visit left behind.
        unset($_SESSION[Router::PREVIEW_SESSION][$id]);

        $boot = self::sectionKit() + [
            'id'        => $id,
            'name'      => (string)$page['name'],
            'slug'      => (string)$page['slug'],
            'meta'      => Document::normalizeMeta((array)$page['meta'], $installed),
            'doc'       => Document::normalize((array)$page['draft'], $installed),
            'status'    => (string)$page['status'],
            'changed'   => Page::hasUnpublishedChanges($page),
            // "Preview with": the site's styles and layouts, and its own pick.
            'looks'     => Bridge::looks(),
            // Where the site look is changed for real: Hadrian's customizer.
            'customizeUrl' => 'addonmodules.php?module=Hadrian&action=customize',
            // The preview address; ?hb_sample=<type> draws one section type
            // on its own, for the "add a section" list (Router::sample()).
            'previewPath'  => Router::previewUrlFor($id),
            'siteUrl'   => rtrim(Bridge::systemUrl(), '/') . '/',
            'pageUrl'   => $page['slug'] !== '' ? Router::urlFor((string)$page['slug']) : '',
            'api'       => self::BASE,
            'token'     => $this->token(),
        ];

        return $this->view('editor', [
            'boot'      => json_encode($boot, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE),
            // Inlined rather than linked: nothing here depends on the module's
            // asset directory being reachable over HTTP. fields.* are shared
            // with the section list in Pages (ContentPanel).
            'editorCss' => self::asset('css/fields.css') . "\n" . self::asset('css/page-builder.css'),
            'editorJs'  => self::asset('js/fields.js') . "\n" . self::asset('js/page-builder.js'),
            'name'      => (string)$page['name'],
        ]);
    }

    // ------------------------------------------------------------ JSON API
    // Reached from dispatch(). Each of these ends the request.

    private function api(string $action): never
    {
        if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
            $this->json(['ok' => false, 'error' => 'POST only.'], 405);
        }
        $in = $this->jsonIn();
        if (!Bridge::available()) {
            $this->json(['ok' => false, 'error' => Bridge::reason()], 409);
        }
        $page = Page::find((int)($in['id'] ?? 0));
        if ($page === null) {
            $this->json(['ok' => false, 'error' => 'That page no longer exists.'], 404);
        }
        match ($action) {
            'api-preview'   => $this->apiPreview($page, $in),
            'api-save'      => $this->apiSave($page, $in),
            'api-content'   => $this->apiContent($page, $in),
            'api-publish'   => $this->apiPublish($page),
            'api-unpublish' => $this->apiUnpublish($page),
            default         => $this->json(['ok' => false, 'error' => 'Unknown action.'], 404),
        };
    }

    /**
     * Keep the editor's unsaved document for this admin's session and say
     * where to load it. The preview is the real page: Router draws it through
     * the theme, at an address only a signed-in admin can open.
     *
     * @param array<string,mixed> $page
     * @param array<string,mixed> $in
     */
    private function apiPreview(array $page, array $in): never
    {
        $id  = (int)$page['id'];
        $doc = Document::normalize(is_array($in['doc'] ?? null) ? $in['doc'] : [], Bridge::languages());
        if (!isset($_SESSION[Router::PREVIEW_SESSION]) || !is_array($_SESSION[Router::PREVIEW_SESSION])) {
            $_SESSION[Router::PREVIEW_SESSION] = [];
        }
        $_SESSION[Router::PREVIEW_SESSION][$id] = $doc;

        $lang = strtolower((string)($in['lang'] ?? '_'));
        $lang = preg_match('/^[a-z_][a-z0-9_-]{0,40}$/', $lang) ? $lang : '_';
        // Another style or layout to draw the page with, for this admin only.
        $look = is_array($in['look'] ?? null) ? $in['look'] : [];
        $this->json([
            'ok'  => true,
            'url' => Router::previewUrlFor($id) . '?hb_lang=' . rawurlencode($lang) . '&hb_t=' . time()
                . ($look !== [] ? Bridge::lookQuery($look) : ''),
        ]);
    }

    /**
     * @param array<string,mixed> $page
     * @param array<string,mixed> $in
     */
    private function apiSave(array $page, array $in): never
    {
        $id        = (int)$page['id'];
        $installed = Bridge::languages();

        $name = Text::line(is_scalar($in['name'] ?? null) ? (string)$in['name'] : '', 120);
        if ($name === '') {
            $this->json(['ok' => false, 'error' => 'Give the page a name.', 'field' => 'name'], 422);
        }
        $typed = trim(is_scalar($in['slug'] ?? null) ? (string)$in['slug'] : '');
        $slug  = Text::slug($typed);
        if ($typed !== '' && $slug === '') {
            $this->json(['ok' => false, 'field' => 'slug',
                'error' => 'An address can use lowercase letters, numbers and hyphens, with up to three parts separated by "/". For example: hosting/wordpress'], 422);
        }
        if ($slug !== '' && str_starts_with($slug . '/', Router::PREVIEW_PREFIX . '/')) {
            $this->json(['ok' => false, 'field' => 'slug', 'error' => 'That address is used by the editor\'s preview. Choose another.'], 422);
        }
        if ($slug !== '' && Page::slugTaken($slug, $id)) {
            $this->json(['ok' => false, 'field' => 'slug', 'error' => 'Another page already uses that address.'], 422);
        }
        if ($slug === '' && $page['status'] === 'published') {
            $this->json(['ok' => false, 'field' => 'slug', 'error' => 'A published page needs an address. Unpublish it first to remove the address.'], 422);
        }

        $doc  = Document::normalize(is_array($in['doc'] ?? null) ? $in['doc'] : [], $installed);
        $meta = Document::normalizeMeta(is_array($in['meta'] ?? null) ? $in['meta'] : [], $installed);
        Page::update($id, ['name' => $name, 'slug' => $slug, 'meta' => $meta, 'draft' => $doc]);
        Bridge::pagesChanged();
        unset($_SESSION[Router::PREVIEW_SESSION][$id]);

        $fresh = Page::find($id) ?? $page;
        $this->json([
            'ok'      => true,
            'doc'     => $doc,
            'meta'    => $meta,
            'name'    => $name,
            'slug'    => $slug,
            'status'  => (string)$fresh['status'],
            'changed' => Page::hasUnpublishedChanges($fresh),
            'pageUrl' => $slug !== '' ? Router::urlFor($slug) : '',
        ]);
    }

    /**
     * Save the sections only, as the draft. The section list in Pages uses
     * this: the page's name and address are not on that screen, so they are
     * left as they are.
     *
     * @param array<string,mixed> $page
     * @param array<string,mixed> $in
     */
    private function apiContent(array $page, array $in): never
    {
        $id  = (int)$page['id'];
        $doc = Document::normalize(is_array($in['doc'] ?? null) ? $in['doc'] : [], Bridge::languages());
        Page::update($id, ['draft' => $doc]);
        unset($_SESSION[Router::PREVIEW_SESSION][$id]);

        $fresh = Page::find($id) ?? $page;
        $this->json([
            'ok'      => true,
            'doc'     => $doc,
            'status'  => (string)$fresh['status'],
            'changed' => Page::hasUnpublishedChanges($fresh),
            'pageUrl' => (string)$fresh['slug'] !== '' ? Router::urlFor((string)$fresh['slug']) : '',
        ]);
    }

    /** @param array<string,mixed> $page */
    private function apiPublish(array $page): never
    {
        if ((string)$page['slug'] === '') {
            $this->json(['ok' => false, 'field' => 'slug', 'error' => 'Give the page an address before publishing it.'], 422);
        }
        Page::publish((int)$page['id']);
        Bridge::pagesChanged();
        $this->json(['ok' => true, 'status' => 'published', 'changed' => false, 'pageUrl' => Router::urlFor((string)$page['slug'])]);
    }

    /** @param array<string,mixed> $page */
    private function apiUnpublish(array $page): never
    {
        Page::unpublish((int)$page['id']);
        Bridge::pagesChanged();
        $this->json(['ok' => true, 'status' => 'draft', 'changed' => false]);
    }

    // -------------------------------------------------------------- helpers

    /** One of the module's own files under views/assets, as text. '' when missing. */
    public static function asset(string $relative): string
    {
        return (string)@file_get_contents(dirname(__DIR__) . '/views/assets/' . $relative);
    }

    /**
     * What both content screens need to draw a page's sections: the schemas,
     * spacing names, icons, products and the languages to edit in.
     *
     * @return array<string,mixed>
     */
    public static function sectionKit(): array
    {
        $default   = Bridge::defaultLanguage();
        $languages = [['code' => '_', 'label' => Bridge::languageName($default) . ' (default)']];
        foreach (Bridge::offeredLanguages() as $code) {
            if ($code !== $default) {
                $languages[] = ['code' => $code, 'label' => Bridge::languageName($code)];
            }
        }
        return [
            'types'     => Sections::forEditor(),
            'spacing'   => Document::SPACING,
            'icons'     => Icons::all(),
            'iconNames' => Icons::options(),
            'products'  => Catalog::options(),
            'languages' => $languages,
        ];
    }

    private function ensureSchema(): void
    {
        try {
            Schema::ensure();
        } catch (\Throwable $e) {
            error_log('Hadrian Page Builder: could not create its tables: ' . $e->getMessage());
        }
    }

    /** @param array<string,mixed> $vars */
    private function view(string $template, array $vars): string
    {
        $class  = Bridge::smartyClass();
        $smarty = new $class();
        // Own views first, then Hadrian's: {include file="includes/header.tpl"}
        // resolves to Hadrian's shell partial.
        $smarty->setTemplateDir([dirname(__DIR__) . '/views', Bridge::shellViews()]);
        $smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-builder-admin-smarty');
        $smarty->setCacheDir(sys_get_temp_dir() . '/hadrian-builder-admin-smarty-cache');
        $smarty->setCaching(false);
        $smarty->assign([
            // What Hadrian's shell partials read.
            'viewHelper'    => Bridge::viewHelper(),
            'currentAction' => self::NAV_KEY,
            'mtExtensions'  => Bridge::extensionNav(),
            'mtThemeVersion' => Bridge::themeVersion(),
            'base'          => self::BASE,
            // Where the list of built pages is: Hadrian's Pages, Built tab.
            'pagesUrl'      => SitePages::listUrl(),
        ] + $vars);
        return (string)$smarty->fetch($template . '.tpl');
    }

    /** Hadrian is missing, switched off, too old, or its theme cannot draw a page. */
    private function unavailable(string $reason = ''): string
    {
        $e = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        return '<div style="max-width:720px;margin:32px auto;padding:24px 28px;border:1px solid #e8e8ed;border-radius:14px;background:#fff;font:15px/1.55 -apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,Helvetica,Arial,sans-serif;color:#1d1d1f;">'
            . '<div style="font-size:20px;font-weight:600;margin:0 0 10px;">Hadrian Page Builder needs Hadrian</div>'
            . '<p style="margin:0 0 12px;">' . $e($reason !== '' ? $reason : Bridge::reason()) . '</p>'
            . '<p style="margin:0;color:#6e6e73;">Built pages are not being served until this is fixed. Nothing has been deleted.</p>'
            . '</div>';
    }

    // ----------------------------------------------------------- CSRF + I/O

    private function token(): string
    {
        return self::adminToken();
    }

    /** WHMCS's admin token for this session; '' outside WHMCS. Also for the forms SitePages renders. */
    public static function adminToken(): string
    {
        try {
            return function_exists('generate_token') ? (string)generate_token('plain') : '';
        } catch (\Throwable $e) {
            return '';
        }
    }

    private function tokenOk(string $given): bool
    {
        $expected = $this->token();
        // No token function means no WHMCS admin session to forge against
        // (a test harness); inside WHMCS it always exists.
        return $expected === '' || ($given !== '' && hash_equals($expected, $given));
    }

    private function requirePost(): void
    {
        if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
            $this->fail('That action needs to be submitted from the Pages screen.');
        }
        if (!$this->tokenOk((string)($_POST['token'] ?? ''))) {
            $this->fail('Your session expired. Reload the page and try again.');
        }
    }

    private function redirect(string $url): never
    {
        header('Location: ' . $url);
        exit;
    }

    /**
     * Back to Hadrian's Pages with the outcome: the Built tab, or the
     * settings of one page when the action was taken there.
     */
    private function done(string $message, int $pageId = 0): never
    {
        $query = '&ext_ok=' . rawurlencode($message);
        $this->redirect($pageId > 0 ? SitePages::settingsUrl($pageId, $query) : SitePages::listUrl($query));
    }

    private function fail(string $message): never
    {
        $this->redirect(SitePages::listUrl('&ext_err=' . rawurlencode($message)));
    }

    /** @return array<string,mixed> */
    private function jsonIn(): array
    {
        // The raw body, not $_POST: WHMCS entity-encodes request variables,
        // which would mangle every tag in a rich-text field.
        $in = json_decode((string)file_get_contents('php://input'), true);
        if (!is_array($in)) {
            $this->json(['ok' => false, 'error' => 'Malformed request.'], 400);
        }
        if (!$this->tokenOk((string)($in['token'] ?? ''))) {
            $this->json(['ok' => false, 'error' => 'Your session expired. Reload the page and try again.'], 403);
        }
        return $in;
    }

    /** @param array<string,mixed> $data */
    private function json(array $data, int $code = 200): never
    {
        while (ob_get_level() > 0) {
            @ob_end_clean();
        }
        if (!headers_sent()) {
            http_response_code($code);
            header('Content-Type: application/json; charset=utf-8');
        }
        echo (string)json_encode($data, JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);
        exit;
    }
}
