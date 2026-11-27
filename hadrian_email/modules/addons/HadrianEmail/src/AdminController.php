<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The module's admin page: addonmodules.php?module=HadrianEmail
 *
 * dispatch() reads ?action= :
 *   index     overview: on/off, appearance, the layout, every WHMCS email
 *   builder   the block editor, for the layout (&layout=1) or one email
 *             (&target=<WHMCS template name>)
 *   settings  POST appearance settings
 *   enable    POST take over WHMCS's global email header and footer
 *   disable   POST give them back
 *   reapply   POST rewrite them after an edit in WHMCS's Mail tab
 *   delete    POST drop a design (restoring the WHMCS template first)
 *
 * The builder talks JSON to four endpoints (api-preview, api-save,
 * api-publish, api-restore). They come through dispatch() like every other
 * action, so WHMCS has already enforced the admin login and this addon's role
 * permissions; they answer and exit before WHMCS prints any admin chrome.
 *
 * Every write checks the WHMCS admin CSRF token. These actions rewrite
 * WHMCS's own mail settings and email templates, so a forged request would
 * change what a company sends to its customers.
 *
 * The pages are drawn inside Hadrian's admin shell (its header, navigation,
 * footer scripts and stylesheet), so the module looks like a part of Hadrian
 * while living in its own folder.
 */
final class AdminController
{
    public const MODULE = 'HadrianEmail';
    public const BASE   = '?module=HadrianEmail';

    /** What Hadrian's navigation highlights for this module's pages. */
    public const NAV_KEY = 'ext-email';

    private const MODES = [
        'auto'  => "Match the recipient's device",
        'light' => 'Always light',
        'dark'  => 'Always dark',
    ];

    public function dispatch(): string
    {
        $this->ensureSchema();
        $action = (string)($_GET['action'] ?? 'index');

        // The builder's JSON endpoints. Handled here, inside _output(), and not
        // from hooks.php: this is the first point at which WHMCS has verified
        // the admin login and this addon's role permissions. See hooks.php.
        if (str_starts_with($action, 'api-')) {
            try {
                $this->api($action);
            } catch (\Throwable $e) {
                error_log('Hadrian Email AJAX: ' . $e->getMessage() . ' at ' . $e->getFile() . ':' . $e->getLine());
                // Signed-in admins only by this point, so the real message is
                // useful and safe to show.
                $this->json(['ok' => false, 'error' => 'Server error: ' . $e->getMessage()], 500);
            }
        }

        if (!Bridge::available()) {
            return $this->unavailable();
        }
        return match ($action) {
            'builder'  => $this->builder(),
            'settings' => $this->saveSettings(),
            'enable'   => $this->enable(),
            'design'   => $this->design(),
            'disable'  => $this->disable(),
            'reapply'  => $this->reapply(),
            'delete'   => $this->delete(),
            default    => $this->index(),
        };
    }

    // ------------------------------------------------------------- overview

    private function index(): string
    {
        $notes = [];

        // The theme's colours, the logo or the layout changed since the
        // static header was written, or a design was published under the old
        // colours. Bring both up to date before showing the page.
        try {
            if (Takeover::isStale()) {
                Takeover::refresh();
                $n = Publisher::republishAll();
                Takeover::markFresh();
                if ($n > 0) {
                    $notes[] = 'Your Hadrian style changed, so ' . $n . ' published ' . ($n === 1 ? 'design was' : 'designs were') . ' recompiled with the new colours.';
                }
            }
        } catch (\Throwable $e) {
            error_log('Hadrian Email: refresh failed: ' . $e->getMessage());
        }

        $theme   = Theme::load();
        $designs = Design::messagesByTarget();
        $groups  = [];
        $counts  = ['published' => 0, 'draft' => 0];
        try {
            foreach (Publisher::templates() as $type => $group) {
                foreach ($group['items'] as &$item) {
                    $d = $designs[$item['name']] ?? null;
                    $item['designId'] = $d['id'] ?? 0;
                    $item['status']   = 'stock';
                    $item['starter']  = in_array($item['name'], Presets::names(), true);
                    if ($d !== null) {
                        $item['status'] = $d['status'] === 'published' ? 'published' : 'draft';
                        if ($item['status'] === 'published' && Publisher::drift($d) !== []) {
                            $item['status'] = 'edited';
                        }
                        $counts[$d['status'] === 'published' ? 'published' : 'draft']++;
                    }
                }
                unset($item);
                $groups[$type] = $group;
            }
        } catch (\Throwable $e) {
            $notes[] = 'Could not read the WHMCS email templates: ' . $e->getMessage();
        }

        return $this->view('index', [
            'status'      => Takeover::status(),
            'settings'    => $theme['settings'],
            'modes'       => self::MODES,
            'logoIssue'   => (string)$theme['logoIssue'],
            'hasLogo'     => (string)$theme['logo']['light'] !== '',
            'groups'      => $groups,
            'counts'      => $counts,
            'designs'     => $this->designCards($theme),
            'designGroups' => Designs::GROUPS,
            'token'       => $this->token(),
            'notes'       => $notes,
            'flashMsg'    => (string)($_GET['flash'] ?? ''),
            'flashErr'    => (string)($_GET['err'] ?? ''),
        ]);
    }

    // -------------------------------------------------------------- builder

    private function builder(): string
    {
        $installed = Bridge::languages();
        $default   = Bridge::defaultLanguage();
        $isLayout  = isset($_GET['layout']);

        if ($isLayout) {
            $row  = Design::layout();
            $kind = Blocks::KIND_LAYOUT;
            $doc  = Blocks::normalize(
                $row !== null ? (array)$row['doc'] : Presets::layout(Bridge::footerLinks()),
                $kind,
                $installed
            );
            $boot = [
                'id' => $row['id'] ?? 0, 'target' => '', 'name' => 'Layout', 'type' => '',
                'status' => $row !== null ? 'saved' : 'new', 'subject' => '', 'drift' => [],
            ];
        } else {
            $target   = (string)($_GET['target'] ?? '');
            $template = null;
            try {
                $template = Publisher::template($target);
            } catch (\Throwable $e) {
                // Fall through to the not-found redirect.
            }
            if ($template === null) {
                $this->fail('WHMCS has no client email template called "' . $target . '".');
            }
            $row  = Design::forTarget($target);
            $kind = Blocks::KIND_MESSAGE;
            if ($row !== null) {
                $source = (array)$row['doc'];
            } else {
                $source = Presets::message($target) ?? Presets::import((string)$template->message);
            }
            $doc = Blocks::normalize($source, $kind, $installed);

            // Saved since it was last published? Compile the saved document
            // and compare with what the publish wrote, so the badge is right
            // on a fresh page load and not only within one editing session.
            $pending = false;
            if ($row !== null && $row['status'] === 'published') {
                $hash    = (string)($row['published']['']['hash'] ?? '');
                $pending = $hash !== sha1(Renderer::compileMessage(Theme::load(), $doc, $default));
            }
            $boot = [
                'id' => $row['id'] ?? 0, 'target' => $target, 'name' => $target, 'type' => (string)$template->type,
                'status' => $row !== null ? (string)$row['status'] : 'new',
                'pending' => $pending,
                'subject' => (string)$template->subject,
                'drift' => $row !== null ? Publisher::drift($row) : [],
                'starter' => $row === null && Presets::message($target) !== null,
            ];
        }

        $languages = [['code' => '_', 'label' => Bridge::languageName($default) . ' (default)', 'rtl' => Theme::isRtl($default)]];
        foreach (Bridge::offeredLanguages() as $code) {
            if ($code !== $default) {
                $languages[] = ['code' => $code, 'label' => Bridge::languageName($code), 'rtl' => Theme::isRtl($code)];
            }
        }

        $boot += [
            'kind'        => $kind,
            'doc'         => $doc,
            'types'       => Blocks::typesFor($kind),
            'designs'     => $kind === Blocks::KIND_LAYOUT ? Designs::all() : (object)[],
            'languages'   => $languages,
            'mergeFields' => MergeFields::forType((string)$boot['type']),
            'api'         => self::BASE,
            'token'       => $this->token(),
            'enabled'     => Takeover::isEnabled(),
        ];

        $assets = dirname(__DIR__) . '/views/assets';
        return $this->view('builder', [
            'boot'       => json_encode($boot, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE),
            // Inlined rather than linked: nothing here depends on the module's
            // asset directory being reachable over HTTP.
            'builderCss' => (string)@file_get_contents($assets . '/css/email-builder.css'),
            'builderJs'  => (string)@file_get_contents($assets . '/js/email-builder.js'),
            'name'       => $boot['name'],
            'isLayout'   => $isLayout,
        ]);
    }

    // ------------------------------------------------------------ form posts

    private function saveSettings(): string
    {
        $this->requirePost();
        // WHMCS entity-encodes request input before an addon sees it. Custom
        // CSS is the field where that matters most: "a > b" must not be
        // stored as "a &gt; b".
        $post = static fn(string $k): string => html_entity_decode((string)($_POST[$k] ?? ''), ENT_QUOTES, 'UTF-8');
        Store::set(Theme::SETTINGS_KEY, Theme::normalizeSettings([
            'mode'      => $post('mode'),
            'logo'      => $post('logo'),
            'logoDark'  => $post('logoDark'),
            'width'     => (int)($_POST['width'] ?? 600),
            'radius'    => (int)($_POST['radius'] ?? 16),
            'customCss' => $post('customCss'),
        ]));
        Theme::forget();
        $n = $this->afterChange();
        $this->done('Appearance saved.' . ($n > 0 ? ' ' . $n . ' published ' . ($n === 1 ? 'design' : 'designs') . ' recompiled.' : ''));
    }

    private function enable(): string
    {
        $this->requirePost();
        if (Design::layout() === null) {
            // First switch-on with no saved layout: save the default one, so
            // what goes out is a row the admin can open and edit.
            $doc = Blocks::normalize(Presets::layout(Bridge::footerLinks()), Blocks::KIND_LAYOUT, Bridge::languages());
            $id  = Design::create(['kind' => Blocks::KIND_LAYOUT, 'name' => 'Layout', 'doc' => $doc]);
            Store::set(Design::ACTIVE_LAYOUT_KEY, $id);
        }
        Takeover::enable();
        $this->done('Hadrian email is on. Your previous WHMCS header, footer and CSS are kept and come back when you turn it off.');
    }

    private function disable(): string
    {
        $this->requirePost();
        Takeover::disable(isset($_POST['keep']));
        $this->done('Hadrian email is off. WHMCS is using its own global header, footer and CSS again.');
    }

    private function reapply(): string
    {
        $this->requirePost();
        Takeover::refresh(true);
        $this->done('The Hadrian header and footer were written to WHMCS again.');
    }

    private function delete(): string
    {
        $this->requirePost();
        $id     = (int)($_POST['id'] ?? 0);
        $design = Design::find($id);
        if ($design === null || $design['kind'] !== Blocks::KIND_MESSAGE) {
            $this->fail('That design no longer exists.');
        }
        if ($design['status'] === 'published') {
            Publisher::restore($id);
        }
        Design::delete($id);
        $this->done('"' . $design['name'] . '" is back to its WHMCS template and the design was removed.');
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
        match ($action) {
            'api-preview' => $this->apiPreview($in),
            'api-save'    => $this->apiSave($in),
            'api-publish' => $this->apiPublish($in),
            'api-restore' => $this->apiRestore($in),
            default       => $this->json(['ok' => false, 'error' => 'Unknown action.'], 404),
        };
    }

    /** @param array<string,mixed> $in */
    private function apiPreview(array $in): never
    {
        $kind      = ($in['kind'] ?? '') === Blocks::KIND_LAYOUT ? Blocks::KIND_LAYOUT : Blocks::KIND_MESSAGE;
        $installed = Bridge::languages();
        $doc       = Blocks::normalize(is_array($in['doc'] ?? null) ? $in['doc'] : [], $kind, $installed);

        $lang = strtolower((string)($in['lang'] ?? '_'));
        $lang = ($lang === '_' || !in_array($lang, $installed, true)) ? Bridge::defaultLanguage() : $lang;
        $opts = [
            'lang'     => $lang,
            'scheme'   => in_array($in['scheme'] ?? null, ['light', 'dark'], true) ? $in['scheme'] : null,
            'annotate' => $kind,
        ];
        // A message with no blocks is not an empty email: until something is
        // published WHMCS keeps sending the template's own text, so that is
        // what the canvas shows. The pre-publish original, if there is one,
        // because the row itself may hold an earlier version of this design.
        // The header's subject title: this email's own subject when editing
        // one (the design's, else the WHMCS template's), a sample otherwise.
        if ($kind === Blocks::KIND_MESSAGE) {
            $template = Publisher::template((string)($in['target'] ?? ''));
            $own = trim(\HadrianEmail\Merge::pick($doc['settings']['subject'], $lang));
            if ($own === '') {
                $own = $template !== null ? (string)$template->subject : '';
            }
            $opts['subject'] = $own;
            $opts['message'] = $template !== null ? (string)$template->name : '';
            $opts['type']    = $template !== null ? (string)$template->type : '';
        }
        if ($kind === Blocks::KIND_MESSAGE && $doc['blocks'] === []) {
            $target = (string)($in['target'] ?? '');
            $design = Design::forTarget($target);
            $body   = $design['backup']['']['message'] ?? null;
            if (!is_string($body)) {
                $template = Publisher::template($target);
                $body     = $template !== null ? (string)$template->message : null;
            }
            if (is_string($body) && trim($body) !== '') {
                $opts['body'] = $body;
            }
        }

        $theme = Theme::load();
        $html  = $kind === Blocks::KIND_LAYOUT
            ? Renderer::preview($theme, $doc, null, $opts)
            : Renderer::preview($theme, Takeover::layoutDoc(), $doc, $opts);

        $this->json(['ok' => true, 'html' => $html, 'bytes' => strlen($html)]);
    }

    /** @param array<string,mixed> $in */
    private function apiSave(array $in): never
    {
        $kind = ($in['kind'] ?? '') === Blocks::KIND_LAYOUT ? Blocks::KIND_LAYOUT : Blocks::KIND_MESSAGE;
        $doc  = Blocks::normalize(is_array($in['doc'] ?? null) ? $in['doc'] : [], $kind, Bridge::languages());
        $id   = (int)($in['id'] ?? 0);

        if ($kind === Blocks::KIND_LAYOUT) {
            $row = $id > 0 ? Design::find($id) : Design::layout();
            if ($row !== null && $row['kind'] === Blocks::KIND_LAYOUT) {
                $id = (int)$row['id'];
                Design::update($id, ['doc' => $doc]);
            } else {
                $id = Design::create(['kind' => $kind, 'name' => 'Layout', 'doc' => $doc]);
            }
            Store::set(Design::ACTIVE_LAYOUT_KEY, $id);
            // The layout is live as soon as it is saved: rewrite the static
            // header WHMCS holds, and drop the copy this request built.
            SendHook::reset();
            Takeover::refresh();
            $this->json(['ok' => true, 'id' => $id, 'doc' => $doc, 'status' => 'saved', 'live' => Takeover::isEnabled()]);
        }

        $target = (string)($in['target'] ?? '');
        if (Publisher::template($target) === null) {
            $this->json(['ok' => false, 'error' => 'WHMCS has no client email template called "' . $target . '".'], 422);
        }
        $row = Design::forTarget($target);
        if ($row !== null) {
            $id = (int)$row['id'];
            Design::update($id, ['doc' => $doc]);
            $status = (string)$row['status'];
        } else {
            $id     = Design::create(['kind' => $kind, 'name' => $target, 'target' => $target, 'doc' => $doc]);
            $status = 'draft';
        }
        $this->json(['ok' => true, 'id' => $id, 'doc' => $doc, 'status' => $status]);
    }

    /** @param array<string,mixed> $in */
    private function apiPublish(array $in): never
    {
        $res = Publisher::publish((int)($in['id'] ?? 0));
        SendHook::reset();
        $this->json($res + ['status' => $res['ok'] ? 'published' : 'draft'], $res['ok'] ? 200 : 422);
    }

    /** @param array<string,mixed> $in */
    private function apiRestore(array $in): never
    {
        $res = Publisher::restore((int)($in['id'] ?? 0));
        SendHook::reset();
        $this->json($res + ['status' => 'draft'], $res['ok'] ? 200 : 422);
    }

    // -------------------------------------------------------------- helpers

    /** Bring WHMCS's copy of the header and every published body up to date. */
    private function afterChange(): int
    {
        SendHook::reset();
        try {
            Takeover::refresh();
            $n = Publisher::republishAll();
            Takeover::markFresh();
            return $n;
        } catch (\Throwable $e) {
            error_log('Hadrian Email: refresh after change failed: ' . $e->getMessage());
            return 0;
        }
    }

    private function ensureSchema(): void
    {
        try {
            Schema::ensure();
        } catch (\Throwable $e) {
            error_log('Hadrian Email: could not create its tables: ' . $e->getMessage());
        }
    }

    /**
     * One card per design for the Email page, each a real render of the
     * admin's own layout (their texts, links, colours and logo) in that design.
     *
     * @param array<string,mixed> $theme
     * @return list<array{id:string, label:string, description:string, active:bool, html:string}>
     */
    private function designCards(array $theme): array
    {
        $current = Takeover::layoutDoc();
        $active  = (string)($current['settings']['design'] ?? Designs::DEFAULT);
        $out     = [];
        foreach (Designs::all() as $id => $d) {
            $html = '';
            try {
                $doc  = Blocks::normalize(Designs::apply($current, $id), Blocks::KIND_LAYOUT, Bridge::languages());
                $html = Renderer::preview($theme, $doc, null, []);
            } catch (\Throwable $e) {
                error_log('Hadrian Email: design preview failed: ' . $e->getMessage());
            }
            $out[] = ['id' => $id, 'label' => $d['label'], 'description' => $d['description'], 'group' => Designs::group($id), 'active' => $id === $active, 'html' => $html];
        }
        return $out;
    }

    /** POST: switch the layout to another design, keeping its content. */
    private function design(): string
    {
        $this->requirePost();
        $id = (string)($_POST['design'] ?? '');
        if (!isset(Designs::all()[$id])) {
            $this->fail('Unknown design.');
        }
        $row = Design::layout();
        $doc = Blocks::normalize(
            Designs::apply($row !== null ? (array)$row['doc'] : Presets::layout(Bridge::footerLinks()), $id),
            Blocks::KIND_LAYOUT,
            Bridge::languages()
        );
        if ($row !== null) {
            Design::update((int)$row['id'], ['doc' => $doc]);
        } else {
            Store::set(Design::ACTIVE_LAYOUT_KEY, Design::create(['kind' => Blocks::KIND_LAYOUT, 'name' => 'Layout', 'doc' => $doc]));
        }
        SendHook::reset();
        Takeover::refresh();
        Takeover::markFresh();
        $label = Designs::all()[$id]['label'];
        $this->done(Takeover::isEnabled()
            ? 'The ' . $label . ' design is in use. Emails sent from now on look like this.'
            : 'The ' . $label . ' design is saved. Turn Hadrian email on to start using it.');
    }

    /** @param array<string,mixed> $vars */
    private function view(string $template, array $vars): string
    {
        $class  = Bridge::smartyClass();
        $smarty = new $class();
        // Own views first, then Hadrian's: {include file="includes/header.tpl"}
        // resolves to Hadrian's shell partial.
        $smarty->setTemplateDir([dirname(__DIR__) . '/views', Bridge::shellViews()]);
        $smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-email-smarty');
        $smarty->setCacheDir(sys_get_temp_dir() . '/hadrian-email-smarty-cache');
        $smarty->setCaching(false);
        $smarty->assign([
            // What Hadrian's shell partials read.
            'viewHelper'    => Bridge::viewHelper(),
            'currentAction' => self::NAV_KEY,
            'mtExtensions'  => Bridge::extensionNav(),
            'mtThemeVersion' => Bridge::themeVersion(),
            'mtBrand'       => Bridge::brand(),
            'base'          => self::BASE,
        ] + $vars);
        return (string)$smarty->fetch($template . '.tpl');
    }

    /** Hadrian is missing or switched off: nothing of its shell can be used. */
    private function unavailable(): string
    {
        $on = false;
        try {
            $on = Takeover::isEnabled();
        } catch (\Throwable $e) {
            // Leave it false.
        }
        // The one action that must work without Hadrian: giving mail back.
        if ($on && ($_GET['action'] ?? '') === 'disable-standalone' && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST'
            && $this->tokenOk((string)($_POST['token'] ?? ''))) {
            Takeover::disable();
            $this->redirect(self::BASE);
        }
        $e = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
        $html = '<div style="max-width:720px;margin:32px auto;padding:24px 28px;border:1px solid #e8e8ed;border-radius:14px;background:#fff;font:15px/1.55 -apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,Helvetica,Arial,sans-serif;color:#1d1d1f;">'
            . '<div style="font-size:20px;font-weight:600;margin:0 0 10px;">Hadrian Email Templates needs Hadrian</div>'
            . '<p style="margin:0 0 12px;">' . $e(Bridge::reason()) . '</p>';
        if ($on) {
            $html .= '<p style="margin:0 0 14px;color:#6e6e73;">Email is still being wrapped in the last layout that was built. To hand WHMCS its own header and footer back now:</p>'
                . '<form method="post" action="' . $e(self::BASE . '&action=disable-standalone') . '">'
                . '<input type="hidden" name="token" value="' . $e($this->token()) . '">'
                . '<button type="submit" class="btn btn-default">Turn Hadrian email off</button></form>';
        } else {
            $html .= '<p style="margin:0;color:#6e6e73;">WHMCS is sending email with its own global header and footer. Nothing has been changed.</p>';
        }
        return $html . '</div>';
    }

    // ----------------------------------------------------------- CSRF + I/O

    private function token(): string
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
            $this->fail('That action needs to be submitted from the Email page.');
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

    private function done(string $message): never
    {
        $this->redirect(self::BASE . '&flash=' . rawurlencode($message));
    }

    private function fail(string $message): never
    {
        $this->redirect(self::BASE . '&err=' . rawurlencode($message));
    }

    /** @return array<string,mixed> */
    private function jsonIn(): array
    {
        // The raw body, not $_POST: WHMCS entity-encodes request variables,
        // which would mangle every tag in a design document.
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
