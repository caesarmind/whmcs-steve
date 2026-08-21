<?php
declare(strict_types=1);

namespace Hadrian\Service;

use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\LocaleHelper;
use Hadrian\Helpers\ThemeManifest;
use Hadrian\Helpers\Uploader;
use Hadrian\Helpers\VisibilityGate;
use Hadrian\Models\Page;
use Hadrian\Models\Settings;
use Hadrian\Template\Template;

/**
 * Front-of-house hook service.
 *
 * Replaces "6 separate ClientAreaPage hook registrations + 200-line god-function"
 * with a single registration that calls dispatch(), routing by hook name to a
 * method here. One hook → one method → easy to read, easy to test, easy to extend.
 */
final class Hooks
{
    /**
     * Templatefiles that are genuinely a single piece of authored, dated
     * content and so warrant og:type=article. Everything else — including the
     * announcement and knowledge-base LIST pages, which merely index these —
     * gets Open Graph's own default of "website".
     *
     * @var list<string>
     */
    private const OG_ARTICLE_PAGES = ['viewannouncement', 'knowledgebasearticle'];

    /**
     * How many rows each $dashboard list carries (clientareahome only).
     *
     * Was a hardcoded 5 in three separate fetchers. The minimal dashboard
     * variant caps its visible rows lower still and reveals the remainder in
     * place, so anything at or below its own visible cap made that control dead
     * on arrival. Kept small: these run on every dashboard load.
     */
    private const DASHBOARD_ROWS = 8;

    private static ?self $instance = null;

    public static function instance(): self
    {
        return self::$instance ??= new self();
    }

    public function dispatch(string $hookName, mixed $hookArg): mixed
    {
        $template = AddonHelper::getTemplate();
        // Don't gate the dispatch on canActivate(). The theme renders
        // the license-required error screen via the template-level
        // $mtLicenseGateEnabled flag in header.tpl / footer.tpl — that's
        // the right place to enforce licensing UX, not the data-assembly
        // hook. Suppressing the entire $hadrian payload here means a
        // licence-fail install loses layout dispatch, addon settings,
        // and pages metadata even when the gate flag is off, so the
        // public site renders with stale defaults and the admin's
        // Layouts choices have no effect on output.
        //
        // The clientAreaPage method still receives $template so it can
        // skip license-sensitive enrichment if we ever need to; for
        // now everything in $hadrian is license-neutral metadata.
        if ($template === null) {
            return null;
        }

        $method = lcfirst($hookName);
        if (!method_exists($this, $method)) {
            return null;
        }
        return $this->{$method}($hookArg, $template);
    }

    // ------------------------------------------------------------------ hooks

    /** Runs LAST among ClientAreaPage hooks (priority -1). Assembles $hadrian. */
    private function clientAreaPage(array $vars, Template $template): array
    {
        // Per-page Visibility enforcement — before any payload assembly, since
        // a gated request never renders. May redirect + exit; returns for the
        // overwhelmingly common public case.
        $this->enforceVisibility($vars, $template);

        $pages    = $this->resolveCurrentPage($vars, $template);
        $layouts  = [
            'main-menu' => $this->resolveActiveLayout($template, 'main-menu'),
            'footer'    => $this->resolveActiveLayout($template, 'footer'),
        ];

        // Per-page layout override (set in admin Pages editor). When a page
        // pins a specific main-menu or footer layout, swap the global pick
        // before exposing $hadrian.layouts to Smarty — templates don't have
        // to know about overrides; they just see the effective layout.
        $currentPage = (string)($vars['templatefile'] ?? '');
        if ($currentPage !== '' && isset($pages[$currentPage]['layout_overrides'])) {
            foreach (['main-menu', 'footer'] as $kind) {
                $override = $pages[$currentPage]['layout_overrides'][$kind] ?? null;
                if (is_string($override) && $override !== ''
                    && in_array($override, $template->getLayouts($kind), true)) {
                    $layouts[$kind] = $this->buildLayoutMeta($template, $kind, $override);
                }
            }
        }

        $branding = $this->resolveBranding();

        return [
            'hadrian' => [
                'name'          => $template->getName(),
                'version'       => $template->getVersion(),
                'manifest'      => $template->getManifest(),
                'styles'        => $this->resolveActiveStyle($template),
                'layouts'       => $layouts,
                'pages'         => $pages,
                // Computed SEO context (canonical, og:url/type, hreflang) for the
                // document <head> in header.tpl. Built in PHP so the query-param
                // stripping + locale resolution stays consistent and testable.
                'seo'           => $this->resolveSeoContext($vars),
                'subnav'        => $this->resolveSubnav($template, $vars, $pages),
                'svcLayout'     => $this->resolveSvcLayout($template, $vars, $pages),
                'license'       => [
                    'canRender' => true,
                    'devMode'   => $template->license()->isDevMode(),
                ],
                'addonSettings' => $this->addonSettingsForRender((string)($vars['language'] ?? 'english')),
                'branding'      => $branding,
                // Effective language list for the locale chooser. Respects the
                // admin's "Custom Language List" toggle + curated codes from
                // the Settings tab; otherwise falls back to every language
                // installed in WHMCS root /lang/.
                'locales'       => [
                    'languages'   => $mtLocaleList = LocaleHelper::effectiveList(),
                    // code => native name ("french" => "Français") so the
                    // modal can label each language for its own readers
                    // instead of |capitalize-ing the English code name.
                    'nativeNames' => LocaleHelper::nativeNamesFor($mtLocaleList),
                ],
                // Flag emoji for the ACTIVE language. The locale button read
                // $hadrian.localeFlag since day one, but nothing ever assigned
                // it — every install showed the template's US-flag default.
                'localeFlag'    => LocaleHelper::flagFor((string)($vars['language'] ?? 'english')),
                // Preview-only affordances. layoutTokens (token => folder) is
                // what header.tpl's ?layout= whitelist and the state-chip's
                // custom-layout anchors read; empty outside ?preview=1 so
                // production requests never pay the manifest reads.
                'preview'       => [
                    'layoutTokens' => ($_GET['preview'] ?? '') === '1'
                        ? $this->resolvePreviewLayoutTokens($template)
                        : [],
                ],
            ],
            'hadrianLang' => $this->loadLanguage($template, $vars['language'] ?? 'english'),
            // Convenience root alias — templates that just want "the logo"
            // can read $mtLogo directly without walking $hadrian.branding.
            // Resolves to the light-surface logo (best default for the
            // legacy WHMCS $logo variable that some included tpls expect).
            'mtLogo'    => $branding['logo']['light'] ?? '',
            'mtFavicon' => $branding['favicon'] ?? '',
        ];
    }

    /**
     * Act on the page's stored Visibility (admin Pages editor): 'disabled'
     * sends the visitor to WHMCS's 404 route, 'auth' sends signed-out
     * visitors to login. The decision — including every guardrail that keeps
     * this from gating the login page or the checkout — lives in
     * VisibilityGate::decide(); this wrapper only gathers its inputs and acts.
     *
     * One extra Page::get per request, ahead of resolveCurrentPage's own row
     * read. Kept separate on purpose: enforcement must run before ANY payload
     * work, and resolveCurrentPage's result is shaped for rendering, not for
     * an early exit. The lookup is a two-column indexed WHERE.
     *
     * Defensive throughout: any failure (no table yet, weird row, session API
     * differences) renders the page normally. Enforcement must never be the
     * reason a site breaks.
     */
    private function enforceVisibility(array $vars, Template $template): void
    {
        try {
            $page = (string)($vars['templatefile'] ?? '');
            if ($page === '') {
                return;
            }
            $row = Page::get($template->getName(), $page);
            if ($row === null) {
                return;
            }

            $action = VisibilityGate::decide(
                isset($row['visibility']) ? (string)$row['visibility'] : null,
                isset($row['page_group']) ? (string)$row['page_group'] : null,
                $page,
                $this->isClientSignedIn(),
                !empty($_SESSION['adminid'])
            );
            if ($action === null) {
                return;
            }

            $dest = $this->routeUrl($action === VisibilityGate::LOGIN ? 'login' : 'page-not-found');
            header('Location: ' . $dest, true, 302);
            exit;
        } catch (\Throwable $e) {
            return; // fail open — see docblock
        }
    }

    /**
     * Is anyone signed in on the client side? Covers clients, users, and an
     * admin masquerading as a client (which sets the client session). Prefers
     * the CurrentUser API; falls back to the classic session key.
     */
    private function isClientSignedIn(): bool
    {
        try {
            if (class_exists('\\WHMCS\\Authentication\\CurrentUser')) {
                $cu = new \WHMCS\Authentication\CurrentUser();
                if ($cu->client() !== null || $cu->user() !== null) {
                    return true;
                }
            }
        } catch (\Throwable $e) {
            // fall through to the session key
        }
        return !empty($_SESSION['uid']);
    }

    /**
     * Root-relative URL for a named WHMCS route, honouring the install's
     * subdirectory (taken from the PATH of SystemURL, never its scheme/host,
     * so the redirect can't bounce between http and https). Falls back to the
     * ?rp= form, which WHMCS resolves whether or not friendly URLs are on.
     */
    private function routeUrl(string $route): string
    {
        $path = '/index.php?rp=/' . $route;
        try {
            if (function_exists('routePath')) {
                $p = (string)routePath($route);
                if ($p !== '') {
                    $path = '/' . ltrim($p, '/');
                }
            }
        } catch (\Throwable $e) {
            // unknown route name — keep the ?rp= fallback
        }

        $base = '';
        try {
            $sys = (string)\WHMCS\Config\Setting::getValue('SystemURL');
            if ($sys !== '') {
                $base = rtrim((string)(parse_url($sys, PHP_URL_PATH) ?: ''), '/');
            }
        } catch (\Throwable $e) {
            // no SystemURL (CLI/test) — root-relative is correct
        }
        return $base . $path;
    }

    /**
     * Login page (priority 1 ClientAreaPageLogin). Surfaces the latest
     * published announcements as $loginAnnouncements for the "split" login
     * variant's featured panel. Other variants ignore the var.
     *
     * @return array{loginAnnouncements: list<array{id:int,title:string,date:string}>}
     */
    private function clientAreaPageLogin(array $vars, Template $template): array
    {
        return ['loginAnnouncements' => $this->fetchRecentAnnouncements(3, (string)($vars['language'] ?? ''))];
    }

    /**
     * Public homepage (templatefile 'homepage'). Surfaces the real product
     * catalogue as $homeProductGroups so the "product categories" section can
     * show live groups and prices instead of hardcoded tiers.
     *
     * WHMCS already passes $announcements to homepage.tpl natively (see stock
     * six/homepage.tpl), so the announcements block needs nothing from here.
     *
     * @return array{homeProductGroups: list<array<string,mixed>>}
     */
    private function clientAreaPageHomepage(array $vars, Template $template): array
    {
        return [
            'homeProductGroups' => $this->fetchProductGroups(4),
            'homeTldPricing'    => $this->fetchDomainTldPricing(6),
        ];
    }

    /**
     * Cheapest 1-year REGISTER price per TLD, for the price strip under the
     * homepage domain search.
     *
     * Uses localAPI('GetTLDPricing') rather than querying tbldomainpricing /
     * tblpricing directly: WHMCS stores domain year-prices in reused product
     * columns (1yr in msetupfee, 2yr in qsetupfee, ...), which is exactly the
     * kind of schema quirk fetchClientProducts() already avoids by going
     * through the API. The API also resolves the visitor's currency for us.
     *
     * TLDs with no positive register price are skipped rather than rendered as
     * "0.00" — matching fetchProductGroups(), which treats <= 0 as "no price
     * to show" rather than free.
     *
     * Defensive throughout: any failure returns an empty list and the template
     * simply omits the strip, exactly like fetchProductGroups().
     *
     * @return list<array{tld:string, price:string}>
     */
    private function fetchDomainTldPricing(int $limit): array
    {
        if ($limit < 1) {
            return [];
        }

        try {
            if (!function_exists('localAPI')) {
                return [];
            }
            $res = localAPI('GetTLDPricing', []);
            if (($res['result'] ?? '') !== 'success' || empty($res['pricing']) || !is_array($res['pricing'])) {
                return [];
            }

            $out = [];
            foreach ($res['pricing'] as $tld => $data) {
                if (!is_array($data)) {
                    continue;
                }
                // register is keyed by registration period in years.
                $raw = $data['register']['1'] ?? null;
                if ($raw === null || $raw === '') {
                    continue;
                }
                $amount = (float)$raw;
                if ($amount <= 0) {
                    continue;
                }

                $ext = (string)$tld;
                if ($ext === '') {
                    continue;
                }
                if ($ext[0] !== '.') {
                    $ext = '.' . $ext;
                }

                $out[] = ['tld' => $ext, 'price' => $this->formatPrice($amount)];
                if (count($out) >= $limit) {
                    break;
                }
            }
            return $out;
        } catch (\Throwable $e) {
            return [];
        }
    }

    /**
     * Visible product groups with a "starting at" price, mirroring what Lagom's
     * homepage shows per group (name, tagline, cheapest cycle price).
     *
     * The price is the lowest positive recurring price across every active
     * product in the group, in the visitor's currency. WHMCS stores "not
     * available for this cycle" as -1 (and free as 0), so anything <= 0 is
     * skipped rather than rendered as a real "$0 / -1" price. A group with no
     * priced product still returns, with fromPrice = null — the template shows
     * the group without a price rather than dropping it.
     *
     * Defensive throughout: any DB failure returns an empty list, exactly like
     * fetchRecentAnnouncements(), so a broken catalogue can never take down the
     * public homepage.
     *
     * @return list<array{gid:int,name:string,tagline:string,url:string,fromPrice:?string,cycle:string}>
     */
    private function fetchProductGroups(int $limit): array
    {
        $cycles = ['monthly', 'quarterly', 'semiannually', 'annually', 'biennially', 'triennially'];

        try {
            $groups = \WHMCS\Database\Capsule::table('tblproductgroups')
                ->where('hidden', '!=', 1)
                ->orderBy('order')
                ->orderBy('name')
                ->limit($limit)
                ->get(['id', 'name', 'tagline', 'slug']);

            if ($groups->isEmpty()) {
                return [];
            }

            $gids = [];
            foreach ($groups as $g) {
                $gids[] = (int)$g->id;
            }

            // Active products per group, then their pricing rows in one pass —
            // avoids a query per group on a page that must stay fast.
            $products = \WHMCS\Database\Capsule::table('tblproducts')
                ->whereIn('gid', $gids)
                ->where('hidden', '!=', 1)
                ->get(['id', 'gid']);

            $gidByPid = [];
            foreach ($products as $p) {
                $gidByPid[(int)$p->id] = (int)$p->gid;
            }

            $lowest = [];
            if ($gidByPid !== []) {
                $currency = $this->currentCurrencyId();
                $pricingQuery = \WHMCS\Database\Capsule::table('tblpricing')
                    ->where('type', 'product')
                    ->whereIn('relid', array_keys($gidByPid));
                if ($currency !== null) {
                    $pricingQuery->where('currency', $currency);
                }

                foreach ($pricingQuery->get() as $row) {
                    $gid = $gidByPid[(int)$row->relid] ?? null;
                    if ($gid === null) {
                        continue;
                    }
                    foreach ($cycles as $cycle) {
                        $price = isset($row->{$cycle}) ? (float)$row->{$cycle} : -1.0;
                        if ($price <= 0) {
                            continue; // -1 = cycle unavailable
                        }
                        if (!isset($lowest[$gid]) || $price < $lowest[$gid]['amount']) {
                            $lowest[$gid] = ['amount' => $price, 'cycle' => $cycle];
                        }
                    }
                }
            }

            $out = [];
            foreach ($groups as $g) {
                $gid  = (int)$g->id;
                $slug = trim((string)($g->slug ?? ''));
                $best = $lowest[$gid] ?? null;

                $out[] = [
                    'gid'       => $gid,
                    'name'      => (string)($g->name ?? ''),
                    'tagline'   => (string)($g->tagline ?? ''),
                    'url'       => $slug !== '' ? 'cart.php?gid=' . rawurlencode($slug) : 'cart.php?gid=' . $gid,
                    'fromPrice' => $best ? $this->formatPrice($best['amount']) : null,
                    'cycle'     => $best['cycle'] ?? '',
                ];
            }
            return $out;
        } catch (\Throwable $e) {
            return [];
        }
    }

    /** Active currency id, or null to fall back to whatever pricing rows exist. */
    private function currentCurrencyId(): ?int
    {
        try {
            if (function_exists('getCurrency')) {
                $c = getCurrency();
                if (is_array($c) && !empty($c['id'])) {
                    return (int)$c['id'];
                }
            }
        } catch (\Throwable $e) {
            // fall through
        }
        return null;
    }

    /**
     * Currency-format a price. Same approach as TableData::fmtMoney() — WHMCS's
     * own formatter when available, plain number otherwise.
     */
    private function formatPrice(float $amount): string
    {
        try {
            if (class_exists('\\WHMCS\\View\\Formatter\\Price') && function_exists('getCurrency')) {
                return (string)(new \WHMCS\View\Formatter\Price($amount, getCurrency()))->toPrefixed();
            }
        } catch (\Throwable $e) {
            // fall through
        }
        return number_format($amount, 2);
    }

    /**
     * Latest published, past-dated announcements, in the visitor's language.
     *
     * WHMCS stores announcement translations as CHILD rows of the base
     * announcement (parentid = base id, language = WHMCS language name), so a
     * naive query returns the base and every translation as separate items —
     * duplicates, some in the wrong language. Base rows only here
     * (parentid 0/NULL), then one whereIn fetches the translations matching
     * $lang and substitutes title/body per announcement. The id stays the BASE
     * id — it is what announcements.php links route on.
     *
     * Defensive: any DB failure returns an empty list so the login page can
     * never break.
     *
     * @return list<array{id:int,title:string,date:string,excerpt:string}>
     */
    private function fetchRecentAnnouncements(int $limit, string $lang = ''): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table('tblannouncements')
                ->where('published', 1)
                ->where('date', '<=', date('Y-m-d H:i:s'))
                ->where(function ($q) {
                    $q->where('parentid', 0)->orWhereNull('parentid');
                })
                ->orderBy('date', 'desc')
                ->limit($limit)
                ->get(['id', 'title', 'date', 'announcement']);
        } catch (\Throwable $e) {
            return [];
        }

        // Translations for the fetched set, one query, keyed by base id. The
        // base row IS the default language, so a visitor on it simply misses.
        $translations = [];
        $lang = strtolower(trim($lang));
        if ($lang !== '' && count($rows) > 0) {
            try {
                $ids = [];
                foreach ($rows as $row) {
                    $ids[] = (int)($row->id ?? 0);
                }
                $childRows = \WHMCS\Database\Capsule::table('tblannouncements')
                    ->whereIn('parentid', $ids)
                    ->where('language', $lang)
                    ->get(['parentid', 'title', 'announcement']);
                foreach ($childRows as $child) {
                    $translations[(int)($child->parentid ?? 0)] = $child;
                }
            } catch (\Throwable $e) {
                $translations = []; // untranslated beats broken
            }
        }

        $out = [];
        foreach ($rows as $row) {
            $t  = $translations[(int)($row->id ?? 0)] ?? null;
            $ts = strtotime((string)($row->date ?? ''));
            $out[] = [
                'id'      => (int)($row->id ?? 0),
                'title'   => (string)(($t->title ?? '') !== '' ? $t->title : ($row->title ?? '')),
                'date'    => $ts ? date('M j, Y', $ts) : '',
                // Split for the bento variant's calendar chip. Done here rather
                // than in Smarty because 'date' above is already one formatted
                // string with no timestamp left in it to take apart, and both
                // are empty when the row's date would not parse, so the chip is
                // dropped instead of rendering blank. Additive: every other
                // consumer of this fetcher ignores keys it does not read.
                'dateMonth' => $ts ? date('M', $ts) : '',
                'dateDay'   => $ts ? date('j', $ts) : '',
                'excerpt' => $this->announcementExcerpt((string)(($t->announcement ?? '') !== '' ? $t->announcement : ($row->announcement ?? ''))),
            ];
        }
        return $out;
    }

    /** First ~160 chars of an announcement body — tags stripped, cut on a word boundary. */
    private function announcementExcerpt(string $body): string
    {
        $text = trim((string)preg_replace('/\s+/', ' ', strip_tags($body)));
        if (mb_strlen($text) <= 160) {
            return $text;
        }
        return (string)preg_replace('/\s+\S*$/', '', mb_substr($text, 0, 160)) . '…';
    }

    /**
     * Build the $hadrian.branding payload — resolved web URLs, ready for
     * the template to drop into <img src="..."> / <link rel="icon"> without
     * any further work.
     *
     * @return array{
     *   logo:    array{light:string, dark:string},
     *   square:  array{light:string, dark:string},
     *   favicon: string,
     *   has:     array{anyLogo:bool, anySquare:bool, favicon:bool},
     * }
     */
    private function resolveBranding(): array
    {
        $uploader = new Uploader();
        $resolve  = static function (Uploader $u, string $key): string {
            $stored = $u->normalizeStored((string)Settings::getValue($key, ''));
            return $stored === '' ? '' : $u->webUrlFor($stored);
        };

        $logoLight       = $resolve($uploader, 'logo_light');
        $logoDark        = $resolve($uploader, 'logo_dark');
        $logoSquareLight = $resolve($uploader, 'logo_square_light');
        $logoSquareDark  = $resolve($uploader, 'logo_square_dark');
        $favicon         = $resolve($uploader, 'favicon');

        return [
            'logo' => [
                // Each variant falls back to the other so a single upload
                // works on both surfaces — admin doesn't have to upload
                // both to get a usable result.
                'light' => $logoLight !== '' ? $logoLight : $logoDark,
                'dark'  => $logoDark  !== '' ? $logoDark  : $logoLight,
            ],
            'square' => [
                'light' => $logoSquareLight !== '' ? $logoSquareLight : $logoSquareDark,
                'dark'  => $logoSquareDark  !== '' ? $logoSquareDark  : $logoSquareLight,
            ],
            'favicon' => $favicon,
            'has' => [
                'anyLogo'   => $logoLight !== '' || $logoDark !== '',
                'anySquare' => $logoSquareLight !== '' || $logoSquareDark !== '',
                'favicon'   => $favicon !== '',
            ],
        ];
    }

    private function clientAreaHeadOutput(array $vars, Template $template): ?string
    {
        $colors  = $this->buildColorsHead($template);
        $typo    = $this->buildTypographyHead($template);
        $buttons = $this->buildButtonsHead($template);
        $forms   = $this->buildFormsHead($template);
        $layout  = $this->buildLayoutHead($template) . $this->buildLayoutGatesHead($template);
        $elements = $this->buildElementsHead($template);
        // General is the SCALE layer (radius/shadow/control/motion), so it is
        // emitted BEFORE the panels that select between its steps -- Elements
        // resolving "Large" to var(--radius-lg) must see the buyer's value for
        // --radius-lg, and both land at :root where source order decides.
        $general = $this->buildGeneralHead($template);
        $ext     = (string)$this->extensionOutput($template, $vars, slot: 'headOutput');
        $custom  = $this->buildCustomCss($template);
        // Custom CSS goes LAST so it can override the theme + token overrides.
        $out     = $colors . $typo . $general . $buttons . $forms . $layout . $elements . $ext . $custom;
        return $out !== '' ? $out : null;
    }

    /**
     * Emit a small inline <style> overriding ONLY the typography tokens the
     * admin changed from default (Styles → Typography). Defaults stay in the
     * cacheable static core-theme.css; this block lands in {$headoutput},
     * which header.tpl renders AFTER the stylesheet links, so it wins on
     * source order. Returns '' when nothing is overridden.
     *
     * Values are sanitized (var-name allowlist, int sizes/weights, font-stack
     * char allowlist, Google font name allowlist) to avoid CSS injection.
     */
    private function buildTypographyHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_typography', null);
        if (!is_array($stored)) {
            return '';
        }

        $cfg      = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/typography.php');
        $fallback = (string)($cfg['fontFamily']['fallback'] ?? 'sans-serif');

        $decls    = [];
        $links    = '';
        $fontFace = '';

        // Font family. The admin-editable "stack" string is the source of truth for
        // what's EMITTED to --font-family (Apple-first is encoded as a leading
        // -apple-system/BlinkMacSystemFont right in that string); the picked font
        // (google/folder/bundled) still drives what's LOADED. With no stored override
        // we derive a sensible stack from the pick.
        $ff    = is_array($stored['fontFamily'] ?? null) ? $stored['fontFamily'] : [];
        $mode  = (string)($ff['mode'] ?? 'default');
        $stack = trim((string)preg_replace('/[^A-Za-z0-9 ,\'"\-]/', '', (string)($ff['stack'] ?? '')));
        if ($mode === 'system') {
            // Each visitor's OS font; no link, no @font-face, nothing downloads.
            $decls['--font-family'] = $stack !== '' ? $stack : (string)($cfg['fontFamily']['system'] ?? $fallback);
        } elseif ($mode === 'google' && !empty($ff['google'])) {
            $name = trim((string)preg_replace('/[^A-Za-z0-9 ]/', '', (string)$ff['google']));
            if ($name !== '') {
                $href  = 'https://fonts.googleapis.com/css2?family=' . rawurlencode($name)
                       . ':wght@300;400;500;600;700&display=swap';
                $links = '<link rel="preconnect" href="https://fonts.googleapis.com">'
                       . '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
                       . '<link rel="stylesheet" href="' . htmlspecialchars($href, ENT_QUOTES) . '">';
                $decls['--font-family'] = $stack !== '' ? $stack : "'{$name}', {$fallback}";
            }
        } elseif ($mode === 'folder' && !empty($ff['folder'])) {
            // Self-hosted: the stored value is the typed font-face NAME. Look for a
            // matching file (name.woff2/woff/ttf/otf) in assets/fonts/custom to
            // @font-face it; the family + emitted stack use the typed name.
            $name = trim((string)preg_replace('/[^A-Za-z0-9 _-]/', '', (string)$ff['folder']));
            if ($name !== '') {
                $dir = $template->getFullPath() . '/assets/fonts/custom';
                foreach (['woff2' => 'woff2', 'woff' => 'woff', 'ttf' => 'truetype', 'otf' => 'opentype'] as $ext => $fmt) {
                    if (is_file($dir . '/' . $name . '.' . $ext)) {
                        $webRoot  = defined('WEB_ROOT') ? rtrim((string)WEB_ROOT, '/') : '';
                        $url      = $webRoot . '/templates/' . $template->getName() . '/assets/fonts/custom/' . $name . '.' . $ext;
                        $fontFace = '@font-face{font-family:"' . $name . '";font-style:normal;font-weight:100 900;'
                                  . 'font-display:swap;src:url("' . $url . '") format("' . $fmt . '");}';
                        break;
                    }
                }
                $decls['--font-family'] = $stack !== '' ? $stack : '"' . $name . '", ' . $fallback;
            }
        }

        // Sizes (px) + weights (numeric). Each stored bucket holds only overrides.
        foreach (['sizes' => 'px', 'weights' => ''] as $bucket => $unit) {
            if (!is_array($stored[$bucket] ?? null)) {
                continue;
            }
            foreach ($stored[$bucket] as $var => $val) {
                if (!preg_match('/^--[a-z0-9-]+$/', (string)$var)) {
                    continue;
                }
                $num = (int)$val;
                if ($num <= 0) {
                    continue;
                }
                $decls[(string)$var] = $num . $unit;
            }
        }

        if ($decls === []) {
            return $links;
        }

        $css = $fontFace . ':root{';
        foreach ($decls as $var => $val) {
            $css .= $var . ':' . $val . ';';
        }
        $css .= '}';

        return $links . '<style id="hadrian-typography">' . $css . '</style>';
    }

    /**
     * Emit the admin's global Custom CSS (Styles → Custom CSS), LAST in head
     * output so it overrides everything. Admin-entered (trusted), but strip any
     * </style> as defense-in-depth so it can't break out of the tag.
     */
    private function buildCustomCss(Template $template): string
    {
        $css = trim((string)Settings::getValue($template->getName() . '_custom_css', ''));
        if ($css === '') {
            return '';
        }
        $css = (string)preg_replace('#</\s*style#i', '', $css);
        return '<style id="hadrian-custom-css">' . $css . '</style>';
    }

    /**
     * Emit an inline <style> applying the admin's per-token Color overrides
     * (Styles -> Colors). Mirrors buildTypographyHead: defaults stay in the
     * cacheable core-theme.css; this block lands after the stylesheet links so
     * it wins on source order. Overrides are stored per style; each style emits
     * into the selector matching its colorMode (light => :root, dark =>
     * [data-theme="dark"]). Var names + color values are re-validated on the way
     * out. Returns '' when nothing is overridden.
     */
    private function buildColorsHead(Template $template): string
    {
        $name = $template->getName();
        // Resolves the legacy 'dark'/empty pointer AND a pointer left behind by
        // a retired style -- otherwise the saved rows of a style that no longer
        // exists keep painting a site whose Styles page cannot show or edit it.
        $active = $template->resolveStyleName(
            (string)Settings::getValue($name . '_active_style', 'default')
        );

        // Each style now carries BOTH scopes: light -> :root, dark ->
        // [data-theme="dark"]. Read the per-scope keys, falling back to the
        // pre-refactor keys (_colors_<active> for light, _colors_dark for dark)
        // so saved colors keep applying before the admin-side migration runs.
        //
        // The dark selector is deliberately `html[data-theme="dark"]` and not
        // the bare `[data-theme="dark"]`. Bare, it scores (0,1,0) -- exactly the
        // same as `:root` -- so a token overridden in the LIGHT scope only would
        // beat core-theme.css's own dark value on source order and leak into
        // dark mode. Measured before the fix: a preset with a warm sidebar in
        // light kept that warm panel in dark mode while the text correctly
        // flipped to near-white, giving 1.01:1. Adding the element bumps it to
        // (0,1,1) so the dark scope always outranks the light one, which is what
        // "light -> :root, dark -> dark block" was always meant to mean.
        //
        // That armour only works for tokens the dark block actually declares,
        // and a whole class of them never does. The seven `follows` sidebar
        // tokens are declared ONCE, at :root, as var() chains --
        //     --sidebar-text: var(--_sb-ink, var(--color-text-primary));
        // (core-theme.css:121-124) -- and dark-ness reaches them through
        // --color-text-primary flipping, not through a second declaration. So a
        // LIGHT override of --sidebar-text lands at :root, later in the cascade
        // than the theme's own :root, and there is nothing in the dark block to
        // beat it. Dark mode then paints near-black menu text on the near-black
        // sidebar: measured 1.01:1, against 15.63:1 with the override removed.
        //
        // It needs an override to exist in light and NOT in dark, which is
        // exactly what "Generate from one colour" produces: it nudges the light
        // neutrals a few units towards the seed hue (#1d1d1f -> #1d1d21) while
        // the dark ones come back byte-identical to their defaults, and
        // saveColorsAction leaves anything equal to its default unstored.
        //
        // Fixed by scoping the light block so it cannot match in dark mode at
        // all, rather than by racing it. `:not([data-palette])` keeps the one
        // precedence this changes: html[data-palette] (core-layout.css, set
        // from ?palette= for previews) scores (0,1,1) and used to outrank the
        // light block's (0,1,0). Without the second :not() the light block
        // would reach (0,1,1) too and win on source order, silently breaking
        // palette previews.
        $scopes = [
            'html:not([data-theme="dark"]):not([data-palette])'
                                       => ['_colors_' . $active . '_light', '_colors_' . $active],
            'html[data-theme="dark"]'  => ['_colors_' . $active . '_dark',  '_colors_dark'],
        ];

        $blocks = '';
        foreach ($scopes as $selector => $keys) {
            $stored = null;
            foreach ($keys as $k) {
                $v = Settings::getValue($name . $k, null);
                if (is_array($v) && $v !== []) { $stored = $v; break; }
            }
            if (!is_array($stored) || $stored === []) {
                continue;
            }
            $decls = '';
            foreach ($stored as $var => $val) {
                $var = (string)$var;
                if (!preg_match('/^--[a-z0-9-]+$/', $var)) {
                    continue;
                }
                if (!$this->isColorValue((string)$val)
                    && !$this->isNonColorToken((string)$var, (string)$val)) {
                    continue;
                }
                $decls .= $var . ':' . trim((string)$val) . ';';
            }
            if ($decls !== '') {
                $blocks .= $selector . '{' . $decls . '}';
            }
        }

        return $blocks !== '' ? '<style id="hadrian-colors">' . $blocks . '</style>' : '';
    }

    /**
     * Emit an inline <style> applying the admin's Buttons overrides (Styles ->
     * Buttons). GLOBAL (one mapping styles both modes), so it always targets
     * :root — the referenced ramp/base tokens are themselves mode-aware, so the
     * same var() resolves correctly under [data-theme="dark"]. Mirrors
     * buildColorsHead: defaults stay in the cacheable core-theme.css; this block
     * lands after the stylesheet links so it wins on source order.
     *
     * Stored shape (only changed values): ['sizes' => ['--btn-...'=>int, ...],
     * 'variants' => ['<variant>' => ['<slot>'=>'<optionKey>', ...], ...]]. Size
     * vars + variant/slot keys are re-validated against core/config/buttons.php,
     * and each option key is mapped through the config's own css strings (authored
     * here, never user input) — so there's no injection surface. Returns '' when
     * nothing is overridden.
     */
    private function buildButtonsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_buttons', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/buttons.php');

        // option key -> emitted css value (var()/hex/rgba()/transparent)
        $cssByKey = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $cssByKey[(string)$o['key']] = (string)$o['css'];
        }
        // size var -> field meta (type + scale) from the tiers; + scales + bounds
        $sizeMeta = [];
        foreach (($cfg['sizeTiers'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);
        // valid variant + slot keys
        $validVariant = [];
        foreach (($cfg['variants'] ?? []) as $v) {
            $validVariant[(string)$v['key']] = true;
        }
        $validSlot = [];
        foreach (($cfg['slots'] ?? []) as $s) {
            $validSlot[(string)$s['key']] = true;
        }

        $decls = '';

        if (is_array($stored['sizes'] ?? null)) {
            foreach ($stored['sizes'] as $var => $val) {
                $var = (string)$var;
                if (!isset($sizeMeta[$var])) {
                    continue;
                }
                $f = $sizeMeta[$var];
                if (($f['type'] ?? 'px') === 'scale') {
                    // map the stored scale key back to its css value
                    $css = null;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === (string)$val) {
                            $css = (string)$o['css'];
                            break;
                        }
                    }
                    if ($css === null) {
                        continue;
                    }
                    $decls .= $var . ':' . $css . ';';
                } else {
                    $num = (int)$val;
                    if ($num < $min || $num > $max) {
                        continue;
                    }
                    $decls .= $var . ':' . $num . 'px;';
                }
            }
        }

        if (is_array($stored['variants'] ?? null)) {
            foreach ($stored['variants'] as $vk => $slots) {
                $vk = (string)$vk;
                if (!isset($validVariant[$vk]) || !is_array($slots)) {
                    continue;
                }
                foreach ($slots as $sk => $optKey) {
                    $sk = (string)$sk;
                    if (!isset($validSlot[$sk])) {
                        continue;
                    }
                    $optKey = (string)$optKey;
                    if (!isset($cssByKey[$optKey])) {
                        continue;
                    }
                    $decls .= '--btn-' . $vk . '-' . $sk . ':' . $cssByKey[$optKey] . ';';
                }
            }
        }

        return $decls !== '' ? '<style id="hadrian-buttons">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Emit the admin's Forms overrides (Styles -> Forms). GLOBAL, always into
     * :root (referenced tokens are mode-aware). Sizes: px -> Npx, scale -> the
     * scale option's css. Colours: option key -> css. Var names + keys are
     * re-validated against core/config/forms.php; option css is authored here
     * (never user input), so no injection surface. Mirrors buildButtonsHead.
     */
    private function buildFormsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_forms', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/forms.php');

        $cssByKey = [];
        foreach (($cfg['colorOptions'] ?? []) as $o) {
            $cssByKey[(string)$o['key']] = (string)$o['css'];
        }
        $sizeMeta = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $colorVars = [];
        foreach (($cfg['colorGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $colorVars[(string)$f['var']] = true;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);

        $decls = '';

        if (is_array($stored['sizes'] ?? null)) {
            foreach ($stored['sizes'] as $var => $val) {
                $var = (string)$var;
                if (!isset($sizeMeta[$var])) {
                    continue;
                }
                $f = $sizeMeta[$var];
                if (($f['type'] ?? 'px') === 'scale') {
                    $css = null;
                    foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                        if ((string)$o['key'] === (string)$val) {
                            $css = (string)$o['css'];
                            break;
                        }
                    }
                    if ($css === null) {
                        continue;
                    }
                    $decls .= $var . ':' . $css . ';';
                } else {
                    $num = (int)$val;
                    if ($num < $min || $num > $max) {
                        continue;
                    }
                    $decls .= $var . ':' . $num . 'px;';
                }
            }
        }

        if (is_array($stored['colors'] ?? null)) {
            foreach ($stored['colors'] as $var => $key) {
                $var = (string)$var;
                if (!isset($colorVars[$var]) || !isset($cssByKey[(string)$key])) {
                    continue;
                }
                $decls .= $var . ':' . $cssByKey[(string)$key] . ';';
            }
        }

        return $decls !== '' ? '<style id="hadrian-forms">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Emit the admin's Layout overrides (Styles -> Layout) — page-structure
     * dimensions, px only, into :root. Var names re-validated against
     * core/config/layout.php; values are ints. Returns '' when nothing changed.
     */
    /**
     * Emit the Styles > General overrides — the scale layer (corner radius,
     * shadow, control sizing, motion) that Elements/Buttons/Forms select
     * between. Same contract as buildLayoutHead: defaults live in the cacheable
     * core-theme.css, only changed values are stored, and this block lands
     * after the stylesheet links so it wins on source order.
     *
     * Values arrive already unit-suffixed from saveGeneralAction (`12px`,
     * `150ms cubic-bezier(...)`, a shadow stack), so this is a passthrough --
     * but it re-validates rather than trusting the row, because a stored value
     * is buyer-writable state that lands inside a <style> block. The var name
     * must be in the schema and the value must match one of the shapes the
     * saver can produce; anything else is dropped.
     */
    private function buildGeneralHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_general', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg   = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/general.php');
        $valid = [];
        foreach (($cfg['groups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $valid[(string)$f['var']] = (string)($f['type'] ?? 'px');
            }
        }
        // A shadow may only ever be one of the stacks we author.
        $shadows = [];
        foreach ((array)($cfg['shadowOptions'] ?? []) as $o) {
            $shadows[preg_replace('/\s+/', '', (string)$o['css'])] = true;
        }

        $decls = '';
        foreach ($stored as $var => $val) {
            $var = (string)$var;
            $val = trim((string)$val);
            if (!isset($valid[$var]) || $val === '') {
                continue;
            }
            switch ($valid[$var]) {
                case 'preset':
                    if (!isset($shadows[preg_replace('/\s+/', '', $val)])) {
                        continue 2;
                    }
                    break;
                case 'em':
                    if (!preg_match('/^\d{1,2}(\.\d{1,2})?em$/', $val)) {
                        continue 2;
                    }
                    break;
                case 'ms':
                    if (!preg_match('/^\d{1,5}ms cubic-bezier\([\d.,\s]+\)$/', $val)) {
                        continue 2;
                    }
                    break;
                default:
                    if (!preg_match('/^\d{1,4}px$/', $val)) {
                        continue 2;
                    }
            }
            $decls .= $var . ':' . $val . ';';
        }

        return $decls !== '' ? '<style id="hadrian-general">:root{' . $decls . '}</style>' : '';
    }

    private function buildLayoutHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_layout_vars', null);
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $cfg   = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/layout.php');
        $min   = (int)($cfg['sizeMin'] ?? 0);
        $max   = (int)($cfg['sizeMax'] ?? 4000);
        $valid = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $valid[(string)$f['var']] = true;
            }
        }

        $decls = '';
        foreach ($stored as $var => $val) {
            $var = (string)$var;
            if (!isset($valid[$var])) {
                continue;
            }
            $num = (int)$val;
            if ($num < $min || $num > $max) {
                continue;
            }
            $decls .= $var . ':' . $num . 'px;';
        }

        return $decls !== '' ? '<style id="hadrian-layout">:root{' . $decls . '}</style>' : '';
    }

    /**
     * Generated structural CSS for CUSTOM (non-declared) main-menu layouts —
     * the piece that makes a dropped-in layout folder work without editing
     * core-layout.css. For each emitted token:
     *
     *   body:not([data-layout=X]) .only-X { display:none !important }   gate
     *   body[data-layout=X] .ph-main-wrap { margin-<side>: Npx }        offset
     *   @media (max-width:900px) { ... margin-<side>: 0 }               collapse
     *
     * driven by an optional `css` block in the layout's manifest:
     *   'css' => ['contentOffset' => 240, 'offsetSide' => 'left',
     *             'mobileCollapse' => true]
     *
     * SHIPPED tokens (top/side/rail) are deliberately NOT emitted here — their
     * rules stay hand-written in core-layout.css, so existing installs get
     * byte-identical output. The engine guarantees a positioned, gated,
     * mobile-collapsing shell; the layout's own chrome lives in its layout.css
     * (linked by header.tpl), which is authored, not generated — the middle
     * path between Lagom (nothing generated, new layouts get zero styling)
     * and pretending CSS authoring can disappear.
     *
     * Cost discipline: in production only the ACTIVE layout's manifest is read
     * (one file, the same price buildLayoutMeta already pays); the every-
     * custom-layout emission runs only under ?preview=1, where the state-chip
     * can point the session at any registered token.
     *
     * Token re-validated here even though LayoutsCache validated at rebuild —
     * it is interpolated into selectors, so both ends check (the colour
     * pipeline's stance).
     */
    private function buildLayoutGatesHead(Template $template): string
    {
        $declared = $template->getDeclaredLayouts('main-menu');
        $custom   = \Hadrian\Template\LayoutsCache::readTrusted($template)['layouts']['main-menu'] ?? [];
        if ($custom === []) {
            return '';
        }

        $preview = ($_GET['preview'] ?? '') === '1';
        $active  = $this->resolveActiveLayout($template, 'main-menu');
        $activeName = (string)($active['name'] ?? '');

        $css = '';
        foreach ($custom as $name => $token) {
            if (in_array($name, $declared, true)) {
                continue;                                 // shipped: hand-written rules own it
            }
            if (!$preview && $name !== $activeName) {
                continue;                                 // production: only the active layout costs a read
            }
            if (!preg_match(\Hadrian\Template\LayoutsCache::TOKEN_PATTERN, (string)$token)) {
                continue;                                 // emit-side re-validation
            }

            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . '/core/layouts/main-menu/' . $name . '/layout.php'
            );
            $cfg    = is_array($meta['css'] ?? null) ? $meta['css'] : [];
            $offset = (int)($cfg['contentOffset'] ?? 0);
            $offset = max(0, min(4000, $offset));         // clamp to the layout.php schema bounds
            $side   = ($cfg['offsetSide'] ?? 'left') === 'right' ? 'right' : 'left';
            $collapse = ($cfg['mobileCollapse'] ?? true) !== false;

            $css .= 'body:not([data-layout="' . $token . '"]) .only-' . $token . '{display:none !important;}';
            if ($offset > 0) {
                $css .= 'body[data-layout="' . $token . '"] .ph-main-wrap{margin-' . $side . ':' . $offset . 'px;}';
                if ($collapse) {
                    $css .= '@media (max-width:900px){body[data-layout="' . $token . '"] .ph-main-wrap{margin-' . $side . ':0;}}';
                }
            }
        }

        return $css !== '' ? '<style id="hadrian-layout-gates">' . $css . '</style>' : '';
    }

    /**
     * The valid ?layout= tokens for preview mode, as token => folder-name.
     * Built ONLY under ?preview=1 (N manifest reads are a preview-only cost;
     * production requests never call this). header.tpl uses it to replace the
     * old hardcoded top|side|rail whitelist, and the state-chip uses it to
     * render an anchor per custom token.
     */
    private function resolvePreviewLayoutTokens(Template $template): array
    {
        $tokens = [];
        $custom = \Hadrian\Template\LayoutsCache::readTrusted($template)['layouts']['main-menu'] ?? [];
        foreach ($template->getDeclaredLayouts('main-menu') as $name) {
            $meta  = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . '/core/layouts/main-menu/' . $name . '/layout.php'
            );
            $token = (string)($meta['variables']['dataLayout'] ?? '');
            if ($token !== '') {
                $tokens[$token] = $name;
            }
        }
        foreach ($custom as $name => $token) {
            $token = (string)$token;
            if ($token !== '' && !isset($tokens[$token])
                && preg_match(\Hadrian\Template\LayoutsCache::TOKEN_PATTERN, $token)) {
                $tokens[$token] = $name;
            }
        }
        return $tokens;
    }

    /**
     * Emit the admin's Elements overrides (Styles -> Elements) — component shape
     * tokens, into :root. Sizes: px -> Npx, scale -> the scale option's css. Var
     * names + keys re-validated against core/config/elements.php; option css is
     * authored there. Mirrors the size half of buildFormsHead.
     */
    private function buildElementsHead(Template $template): string
    {
        $stored = Settings::getValue($template->getName() . '_elements', null);
        if (!is_array($stored) || $stored === [] || !is_array($stored['sizes'] ?? null)) {
            return '';
        }

        $cfg      = ThemeManifest::loadVariantMeta($template->getFullPath() . '/core/config/elements.php');
        $sizeMeta = [];
        foreach (($cfg['sizeGroups'] ?? []) as $fields) {
            foreach ($fields as $f) {
                $sizeMeta[(string)$f['var']] = $f;
            }
        }
        $scales = $cfg['scales'] ?? [];
        $min    = (int)($cfg['sizeMin'] ?? 0);
        $max    = (int)($cfg['sizeMax'] ?? 999);

        $decls = '';
        foreach ($stored['sizes'] as $var => $val) {
            $var = (string)$var;
            if (!isset($sizeMeta[$var])) {
                continue;
            }
            $f = $sizeMeta[$var];
            if (($f['type'] ?? 'px') === 'scale') {
                $css = null;
                foreach (($scales[(string)($f['scale'] ?? '')] ?? []) as $o) {
                    if ((string)$o['key'] === (string)$val) {
                        $css = (string)$o['css'];
                        break;
                    }
                }
                if ($css === null) {
                    continue;
                }
                $decls .= $var . ':' . $css . ';';
            } else {
                $num = (int)$val;
                if ($num < $min || $num > $max) {
                    continue;
                }
                $decls .= $var . ':' . $num . 'px;';
            }
        }

        return $decls !== '' ? '<style id="hadrian-elements">:root{' . $decls . '}</style>' : '';
    }

    /** Re-validate a stored color before emitting (defense-in-depth vs CSS injection). */
    /**
     * Tokens whose value is NOT a colour, and the shape each one accepts.
     *
     * The colour pipeline is deliberately narrow -- isColor/isColorValue take
     * hex and comma-form rgb/rgba/hsl/hsla and nothing else -- because it is
     * writing values straight into a <style> block. That narrowness is why the
     * Gradient nav style stores two colour STOPS and composes the gradient in
     * CSS rather than storing `linear-gradient(...)`, which would be dropped
     * silently on save and again on emit.
     *
     * The direction cannot be expressed as a colour at all, so it gets an
     * entry here instead of a hole in the validator: an angle in whole degrees,
     * nothing else. Keep this list short and each pattern anchored -- every key
     * added is a value that reaches a stylesheet without the colour check.
     */
    private const NON_COLOR_TOKENS = [
        '--sidebar-grad-angle' => '/^\d{1,3}deg$/',
    ];

    /** True when $var is a declared non-colour token AND $v fits its shape. */
    private function isNonColorToken(string $var, string $v): bool
    {
        $pat = self::NON_COLOR_TOKENS[$var] ?? null;
        return $pat !== null && (bool)preg_match($pat, trim($v));
    }

    private function isColorValue(string $v): bool
    {
        $v = trim($v);
        return (bool)(
            preg_match('/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/', $v)
            || preg_match('/^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
            || preg_match('/^hsla?\(\s*\d{1,3}\s*,\s*\d{1,3}%\s*,\s*\d{1,3}%\s*(,\s*(?:0|1|0?\.\d+)\s*)?\)$/i', $v)
        );
    }

    private function clientAreaFooterOutput(array $vars, Template $template): ?string
    {
        return $this->extensionOutput($template, $vars, slot: 'footerOutput');
    }

    private function clientAreaHomepagePanels(mixed $panels, Template $template): void
    {
        $this->normalizeRecentTicketPanel($panels);
    }

    /**
     * Populate $dashboard.{activeServices, domains, recentInvoices, openTickets,
     * announcements} for clientareahome. Uses WHMCS localAPI so we don't have to
     * hardcode the schema.
     *
     * The row cap is DASHBOARD_ROWS rather than the old hardcoded 5: the
     * "minimal" dashboard variant shows the first few rows and reveals the rest
     * in place, so a cap of 5 left its Show-more control permanently dead. The
     * "default" variant renders the same arrays and simply lists a few more rows.
     *
     * $dashboard is read by clientareahome only (both variants) — nothing else
     * in the theme consumes it.
     */
    private function clientAreaPageHome(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) {
            return ['dashboard' => [
                'activeServices' => [], 'domains' => [], 'recentInvoices' => [],
                'openTickets' => [], 'announcements' => [],
                'greeting' => $this->greetingBucket(),
                'today' => $this->todayLabel(),
            ]];
        }

        return [
            'dashboard' => [
                // Time-of-day bucket for the minimal variant's greeting.
                // Computed here rather than in Smarty because |date_format's
                // %-style codes are broken on PHP 8.1+ (strftime deprecation;
                // see the trap documented in viewannouncement/default.tpl).
                'greeting'       => $this->greetingBucket(),
                // Formatted here for the same reason as the greeting: Smarty's
                // |date_format uses %-style codes, which rely on strftime and
                // are broken on PHP 8.1+.
                'today'          => $this->todayLabel(),
                'activeServices' => $this->fetchActiveServices($clientId),
                // Domains were previously fetched only on the domains page. The
                // minimal dashboard lists them as a primary section, so surface a
                // capped, active-first slice here too.
                'domains'        => $this->fetchDashboardDomains($clientId),
                'recentInvoices' => $this->fetchRecentInvoices($clientId),
                'openTickets'    => $this->fetchOpenTickets($clientId),
                // WHMCS does NOT pass $publishedAnnouncements to clientareahome —
                // only the "Recent News" $panels tree, whose children carry a label
                // and a badge and nothing else. Reuse the login page's fetcher so
                // the dashboard gets real ids, titles and dates.
                'announcements'  => $this->fetchRecentAnnouncements(self::DASHBOARD_ROWS, (string)($vars['language'] ?? '')),
                // TLD prices for the Register-a-domain block. GATED: this is an
                // uncached localAPI('GetTLDPricing') on the busiest page in the
                // client area, so it only runs when a layout actually mentions
                // that block. A substring test rather than a full parse -- the
                // false positive (block present but switched off) costs one
                // wasted call on a page nobody has arranged that way, whereas a
                // second Page::get + parse would cost every visitor.
                'tldPricing'     => $this->dashboardMentions($template, 'domainreg')
                    ? $this->fetchDomainTldPricing(6)
                    : [],
                // $clientsdetails carries the ISO country CODE and no name, and
                // the code=>name map ($countries) is page-scoped to the details
                // page. Resolve the display name here, gated the same way as the
                // TLD prices so it costs nothing unless the block is in use.
                'countryName'    => $this->dashboardMentions($template, 'profile')
                    ? $this->fetchClientCountryName($clientId)
                    : '',
                // Aggregate for the Billing tile's summary mode: what is
                // overdue, how overdue the worst one is, and any credit that
                // will come off first. $clientsstats carries the counts and the
                // unpaid total but none of the detail.
                // Saved cards and bank accounts. Deliberately NOT gated behind
                // dashboardMentions() like the two above, and the reason is a
                // trap rather than a preference: that gate is a substring test
                // against the STORED layout string, but SectionLayout::parse
                // appends every catalogue key the string is missing (verified --
                // parsing "stats:1/1" returns all ten blocks). So a block added
                // to the catalogue today renders immediately for everyone while
                // no saved layout yet contains its name, and gating it would
                // show a permanently empty card until each admin re-saved.
                // The cost is two indexed queries; the gated pair guard an
                // uncached GetTLDPricing, which is a different order of expense.
                // $client is page-scoped to the routed account pages, so unlike
                // account-paymentmethods this cannot read it from Smarty.
                'payMethods'     => $this->fetchPayMethods($clientId),
                'billing'        => $this->fetchBillingSummary($clientId),
                // Counts for the attention strip. COUNT queries over the whole
                // set, not tallies of the 8-row dashboard slices -- that is the
                // difference between "2 services need action" being true and
                // being true only of what happens to be on screen.
                'attention'      => $this->fetchAttentionCounts($clientId),
            ],
        ];
    }

    /**
     * The client's country as a display NAME ("United States"), not the ISO
     * code $clientsdetails carries. Empty when it cannot be resolved, so the
     * template simply omits the line rather than printing "US".
     */
    private function fetchClientCountryName(int $clientId): string
    {
        if ($clientId === 0) {
            return '';
        }
        try {
            $res = localAPI('GetClientsDetails', ['clientid' => $clientId, 'stats' => false]);
            if (($res['result'] ?? '') !== 'success') {
                return '';
            }
            // Shape differs across WHMCS versions: some return the fields at the
            // top level, some nest them under 'client'.
            return (string)($res['countryname'] ?? $res['client']['countryname'] ?? '');
        } catch (\Throwable) {
            return '';
        }
    }

    /**
     * Cheap "is this block in the saved dashboard layout at all" probe, used to
     * gate work that only one block needs. Reads the same registry row the
     * renderer will read moments later; returns false when nothing is saved,
     * which is the common case for minimal (a blank layout there means the
     * classic shell, which has no such blocks).
     *
     * BENTO IS THE EXCEPTION, and it is the reason for the second half of this
     * method. A blank layout means "built-in arrangement" for every variant,
     * but bento's built-in arrangement DOES carry both panels. Probing only for
     * a mention would starve them on every install that has not rearranged the
     * grid: the Register tile would come up with no price chips and the Profile
     * tile with no country line, with nothing logged anywhere.
     */
    private function dashboardMentions(Template $template, string $sectionKey): bool
    {
        try {
            $row = \Hadrian\Models\Page::get($template->getName(), 'clientareahome');
            if ($row === null) {
                return false;
            }
            $settings = is_array($row['settings'] ?? null) ? $row['settings'] : [];
            $options  = is_array($settings['options'] ?? null) ? $settings['options'] : [];
            $variant  = (string)($row['variant'] ?? '');

            // This variant's own stored layout, if it has one. Namespaced as
            // <key>__<variant>; the bare key is the pre-namespacing legacy form.
            $ownLayout = '';

            foreach ($options as $key => $value) {
                if (!is_string($value)) {
                    continue;
                }
                $k = (string)$key;
                foreach (['min_sections', 'bnt_sections'] as $prefix) {
                    if (!str_starts_with($k, $prefix)) {
                        continue;
                    }
                    if ($k === $prefix || ($variant !== '' && str_ends_with($k, '__' . $variant))) {
                        $ownLayout = $value;
                    }
                    // A substring test rather than a full parse: the false
                    // positive (block present but switched off) costs one
                    // wasted call on a page nobody has arranged that way,
                    // whereas a second Page::get + parse would cost every
                    // visitor. Deliberately looks at EVERY sections option, not
                    // just the active variant's, so this keeps behaving exactly
                    // as it did before bento existed.
                    if (str_contains($value, $sectionKey)) {
                        return true;
                    }
                }
            }

            if ($variant === 'bento' && trim($ownLayout) === '') {
                return true;
            }
        } catch (\Throwable) {
            // Registry unavailable -- skip the extra work rather than fail the page.
        }
        return false;
    }

    /**
     * 'morning' | 'afternoon' | 'evening', from the WHMCS server clock — the
     * same clock every other date on the dashboard is rendered against. The
     * visitor's local time is not knowable server-side, and guessing it from
     * the browser would make the heading flicker on load.
     */
    /**
     * Today as "Tuesday - 2 June", for the Atrium hero eyebrow.
     *
     * date(), not Smarty's |date_format, whose %-style codes rely on strftime
     * and are broken on PHP 8.1+ -- the same trap the greeting bucket is
     * computed here to avoid. Deliberately not localised beyond PHP's own day
     * and month names: WHMCS exposes no locale-aware date helper to hooks, and
     * a half-translated date reads worse than an English one.
     */
    private function todayLabel(): string
    {
        return date('l') . " \u{00B7} " . date('j F');
    }

    /**
     * Saved payment methods for the dashboard block.
     *
     * Every WHMCS object is flattened to a plain array HERE rather than handed
     * to Smarty, which is the whole point of this method. The template can then
     * do nothing worse than print an empty string, whereas a pay-method object
     * in a template is a live fatal: Smarty's |default: does NOT guard a method
     * call on null -- the call happens first -- so one client whose gateway was
     * removed would take the client area down to Six for everybody.
     *
     * Three details are load-bearing, each verified against the stock Six theme
     * and Hadrian's own account-paymentmethods page rather than assumed:
     *
     *   payMethods is a PROPERTY, not a method. $client->payMethods() hands back
     *   the Eloquent relation, which has no validateGateways() -- a fatal.
     *
     *   validateGateways() is mandatory, not a nicety. It drops methods whose
     *   gateway module is no longer enabled, and those are exactly the rows
     *   whose ->payment is missing further down.
     *
     *   getDisplayName() lives on ->payment, NOT on the pay method. Unanimous
     *   across six, nexus, lagom and standard_cart; it is the string carrying
     *   the card brand and last four.
     *
     * The class name is checked rather than imported: nothing in this repo can
     * prove the FQCN, and a `use` of a class that moved is an unconditional
     * fatal at file load, where a false from class_exists() is just an empty
     * block.
     *
     * @return list<array{id:int,label:string,sub:string,isDefault:bool,isExpired:bool}>
     */
    private function fetchPayMethods(int $clientId): array
    {
        try {
            if (!class_exists('\WHMCS\User\Client')) {
                return [];
            }
            $client = \WHMCS\User\Client::find($clientId);
            if ($client === null) {
                return [];
            }
            $methods = $client->payMethods;
            if ($methods === null || !method_exists($methods, 'validateGateways')) {
                return [];
            }

            $out = [];
            foreach ($methods->validateGateways() as $pm) {
                $payment = $pm->payment ?? null;

                $label = '';
                if ($payment !== null && method_exists($payment, 'getDisplayName')) {
                    $label = trim((string)$payment->getDisplayName());
                }
                $description = trim((string)($pm->description ?? ''));

                // The description is the client's own name for the method. It
                // leads only when there is no card identity to lead with, and
                // never repeats itself on the second line.
                if ($label === '') {
                    $label = $description;
                    $description = '';
                }

                // Brand badge. Sniffed from the display name because that is
                // the only place the brand appears -- the same approach lagom
                // and the stock cart take. Falls back on the type, so a method
                // from a gateway nobody anticipated still gets a badge rather
                // than a gap. Kept to a short code: real brand artwork is
                // licensed, and eight of these would be eight network requests.
                $type = '';
                if (method_exists($pm, 'getType')) {
                    $type = (string)$pm->getType();
                }
                $hay   = strtolower($label . ' ' . $description . ' ' . $type);
                $brand = '';
                foreach ([
                    'american express' => 'AMEX', 'amex'     => 'AMEX',
                    'mastercard'       => 'MC',   'master'   => 'MC',
                    'visa'             => 'VISA', 'discover' => 'DISC',
                    'paypal'           => 'PP',   'diners'   => 'DINERS',
                    'unionpay'         => 'UP',   'maestro'  => 'MAES',
                    'jcb'              => 'JCB',
                ] as $needle => $code) {
                    if (str_contains($hay, $needle)) { $brand = $code; break; }
                }
                if ($brand === '') {
                    $brand = str_contains($hay, 'bank') ? 'BANK' : 'CARD';
                }

                // Trailing four digits, so the row can read as a card does
                // rather than repeating the gateway's own "MasterCard-5933".
                // Only when they are actually there -- a PayPal method carries
                // an email address and must keep it.
                $last4 = '';
                if (preg_match('/(\d{4})\D*$/', $label, $m) === 1) {
                    $last4 = $m[1];
                }

                // Guarded in three steps because stock WHMCS guards it in three
                // steps: the payment object can be absent, getExpiryDate can
                // return null, and only a real date object has format().
                $expires = '';
                if ($payment !== null && method_exists($payment, 'getExpiryDate')) {
                    $exp = $payment->getExpiryDate();
                    if (is_object($exp) && method_exists($exp, 'format')) {
                        $expires = (string)$exp->format('m/y');
                    }
                }

                $out[] = [
                    'id'        => (int)($pm->id ?? 0),
                    'label'     => $label,
                    'brand'     => $brand,
                    'last4'     => $last4,
                    'expires'   => $expires,
                    'sub'       => $description === $label ? '' : $description,
                    'isDefault' => method_exists($pm, 'isDefaultPayMethod') && (bool)$pm->isDefaultPayMethod(),
                    'isExpired' => method_exists($pm, 'isExpired') && (bool)$pm->isExpired(),
                ];
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function greetingBucket(): string
    {
        $hour = (int)date('G');
        if ($hour < 12) return 'morning';
        if ($hour < 18) return 'afternoon';
        return 'evening';
    }

    /**
     * Active-first domain slice for the dashboard. Deliberately NOT fetchAllDomains():
     * that pulls up to 100 rows of every status for the paginated domains page,
     * where the dashboard wants a handful of live ones.
     *
     * @return list<array{id:int,domain:string,status:string,statusLower:string,expirydate:string,nextduedate:string}>
     */
    private function fetchDashboardDomains(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsDomains', [
                'clientid' => $clientId,
                'limitnum' => 50,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $live = [];
            $rest = [];
            foreach (($response['domains']['domain'] ?? []) as $d) {
                $status = (string)($d['status'] ?? 'Active');
                $row = [
                    'id'          => (int)($d['id'] ?? 0),
                    'domain'      => (string)($d['domainname'] ?? ''),
                    'status'      => $status,
                    'statusLower' => strtolower($status),
                    'expirydate'  => !empty($d['expirydate']) && $d['expirydate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['expirydate']))
                        : '',
                    'nextduedate' => !empty($d['nextduedate']) && $d['nextduedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['nextduedate']))
                        : '',
                ];
                if ($row['domain'] === '') continue;
                // Active and Pending Transfer first; expired/cancelled last, so a
                // short dashboard list never fills up with dead names.
                if (in_array($status, ['Active', 'Pending Transfer', 'Pending Registration'], true)) {
                    $live[] = $row;
                } else {
                    $rest[] = $row;
                }
            }
            return array_slice(array_merge($live, $rest), 0, self::DASHBOARD_ROWS);
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchActiveServices(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsProducts', [
                'clientid'  => $clientId,
                'stats'     => false,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $services = [];
            foreach (($response['products']['product'] ?? []) as $p) {
                if (!in_array($p['status'] ?? '', ['Active', 'Suspended'], true)) continue;
                $name   = (string)($p['name'] ?? $p['groupname'] ?? 'Service');
                $domain = (string)($p['domain'] ?? '');

                // WHMCS's `domain` column is free text for anything that is not
                // hosting, and licensing modules put the LICENCE KEY in it --
                // observed live as "22B91-DF67E-FD1FA-E84F3". So a dashboard
                // that leads with the domain (which is the right identifier for
                // a hosting account, where the product name repeats down the
                // whole column) has to know when the value is not one.
                //
                // The test is deliberately narrow: at least one dot, no
                // whitespace, and no character a hostname cannot contain. It
                // decides a LABEL only -- nothing downstream is gated on it --
                // so a false negative costs a nicer title, never a broken link.
                $looksLikeHost = $domain !== ''
                    && str_contains($domain, '.')
                    && preg_match('/^[A-Za-z0-9.\-]+$/', $domain) === 1;

                $services[] = [
                    'id'           => (int)($p['id'] ?? 0),
                    'name'         => $name,
                    'domain'       => $domain,
                    // What to put on the row, and what to put under it. Resolved
                    // here rather than in Smarty because the test is a regex.
                    'label'        => $looksLikeHost ? $domain : $name,
                    'sublabel'     => $looksLikeHost ? $name : '',
                    'status'       => (string)($p['status'] ?? 'Active'),
                    'nextDueDate'  => !empty($p['nextduedate']) ? date('M j, Y', strtotime((string)$p['nextduedate'])) : '',
                    'manageUrl'    => '/clientarea.php?action=productdetails&id=' . (int)($p['id'] ?? 0),
                ];
                if (count($services) >= self::DASHBOARD_ROWS) break;
            }
            return $services;
        } catch (\Throwable) {
            return [];
        }
    }

    /**
     * Populate $products on /clientarea.php?action=services when WHMCS's
     * native variable isn't available or is empty. Mirrors the standard
     * keys the legacy clientareaproducts.tpl expects: id, productname,
     * groupname, name, domain, firstpaymentamount, recurringamount,
     * billingcycle, paymentmethod, paymentmethodname, nextduedate, status,
     * statusClass.
     */
    private function clientAreaPageProductsServices(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) {
            return [];
        }
        $list = $this->fetchAllProducts($clientId);

        // Per-status counts across ALL the client's services (direct DB group-by,
        // independent of any ?status filter or localAPI row limit) so the template
        // renders only the status tabs that actually have services.
        $counts = [];
        try {
            $rows = \WHMCS\Database\Capsule::table('tblhosting')
                ->where('userid', $clientId)
                ->groupBy('domainstatus')
                ->get(['domainstatus', \WHMCS\Database\Capsule::raw('COUNT(*) as cnt')]);
            foreach ($rows as $r) {
                $counts[(string)$r->domainstatus] = (int)$r->cnt;
            }
        } catch (\Throwable) {
            // leave empty — the template falls back to its in-page tally
        }

        return ['mtProducts' => $list, 'mtServiceStatusCounts' => $counts];
    }

    /** Tickets list — populates $mtTickets on /supporttickets.php. */
    private function clientAreaPageSupportTickets(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtTickets' => $this->fetchAllTickets($clientId)];
    }

    /** Invoices list — populates $mtInvoices on /clientarea.php?action=invoices. */
    private function clientAreaPageInvoices(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtInvoices' => $this->fetchAllInvoices($clientId)];
    }

    /** Domains list — populates $mtDomains on /clientarea.php?action=domains. */
    private function clientAreaPageDomains(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtDomains' => $this->fetchAllDomains($clientId)];
    }

    /** Quotes list — populates $mtQuotes on /clientarea.php?action=quotes. */
    private function clientAreaPageQuotes(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) return [];
        return ['mtQuotes' => $this->fetchAllQuotes($clientId)];
    }

    private function fetchAllTickets(int $clientId): array
    {
        try {
            $response = localAPI('GetTickets', [
                'clientid' => $clientId,
                'limitnum' => 100,
                // localAPI runs as an admin, and GetTickets adheres to that
                // admin's department memberships unless told otherwise -- a
                // restricted API user gets result=success with an empty list,
                // which reads exactly like "this client has no tickets". Same
                // root cause that emptied the dashboard tile; see
                // fetchOpenTickets. This path is only the fallback behind
                // WHMCS-native $tickets on supporttickets, so it keeps the API
                // (and its deptname/unread fields) and just asks correctly.
                'ignore_dept_assignments' => true,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['tickets']['ticket'] ?? []) as $t) {
                $status      = (string)($t['status'] ?? 'Open');
                $statusClass = strtolower(str_replace([' ', '_'], '-', $status));
                $lastReplyRaw = (string)($t['lastreply'] ?? '');
                $out[] = [
                    'id'         => (int)($t['id'] ?? 0),
                    'tid'        => (string)($t['tid'] ?? ''),
                    'c'          => (string)($t['c'] ?? ''),
                    'subject'    => (string)($t['subject'] ?? ''),
                    'department' => (string)($t['deptname'] ?? $t['department'] ?? ''),
                    'priority'   => (string)($t['priority'] ?? $t['urgency'] ?? 'Medium'),
                    'status'     => $status,
                    'statusClass'=> $statusClass,
                    'statusclass'=> $statusClass,
                    'unread'     => !empty($t['unread']),
                    'lastreply'  => !empty($lastReplyRaw) && $lastReplyRaw !== '0000-00-00 00:00:00'
                        ? date('M j, Y', strtotime($lastReplyRaw))
                        : '',
                    'date'       => !empty($t['date']) ? date('M j, Y', strtotime((string)$t['date'])) : '',
                    // Raw sort value for DataTables data-order attribute. ISO-ish so
                    // localeCompare() in JS sorts chronologically.
                    '_sort_lastreply_raw' => $lastReplyRaw,
                ];
            }

            // URL-driven sort — mirrors fetchAllInvoices for initial render + no-JS fallback.
            $orderby = (string)($_GET['orderby'] ?? 'updated');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'subject'    => fn($a, $b) => strcasecmp($a['subject'], $b['subject']),
                'department' => fn($a, $b) => strcasecmp($a['department'], $b['department']),
                'status'     => fn($a, $b) => strcasecmp($a['status'], $b['status']),
                default      => fn($a, $b) => strcmp($a['_sort_lastreply_raw'], $b['_sort_lastreply_raw']),
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllInvoices(int $clientId): array
    {
        try {
            $response = localAPI('GetInvoices', [
                'userid'   => $clientId,
                'limitnum' => 100,
                'orderby'  => 'date',
                'order'    => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['invoices']['invoice'] ?? []) as $inv) {
                $status = strip_tags((string)($inv['status'] ?? 'Unpaid'));
                $out[] = [
                    'id'             => (int)($inv['id'] ?? 0),
                    'invoicenum'     => (string)($inv['invoicenum'] ?? $inv['id'] ?? ''),
                    'invoiceid'      => (int)($inv['id'] ?? 0),
                    'datecreated'    => !empty($inv['date']) && $inv['date'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$inv['date']))
                        : '',
                    'duedate'        => !empty($inv['duedate']) && $inv['duedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$inv['duedate']))
                        : '',
                    'datepaid'       => !empty($inv['datepaid']) && $inv['datepaid'] !== '0000-00-00 00:00:00'
                        ? date('M j, Y', strtotime((string)$inv['datepaid']))
                        : '',
                    'total'          => (string)($inv['total'] ?? ''),
                    'status'         => $status,
                    'statusLower'    => strtolower($status),
                    // Raw values kept for sorting (the display values above are
                    // formatted strings that don't compare meaningfully).
                    '_sort_date_raw' => (string)($inv['date'] ?? ''),
                    '_sort_due_raw'  => (string)($inv['duedate'] ?? ''),
                    '_sort_amount'   => (float)preg_replace('/[^0-9.\-]/', '', (string)($inv['total'] ?? '0')),
                ];
            }

            // URL-driven sort: /clientarea.php?action=invoices&orderby=KEY&sort=ASC|DESC
            // Honor only known keys + directions; bail to default otherwise.
            $orderby = (string)($_GET['orderby'] ?? 'id');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'date'   => fn($a, $b) => strcmp($a['_sort_date_raw'], $b['_sort_date_raw']),
                'due'    => fn($a, $b) => strcmp($a['_sort_due_raw'], $b['_sort_due_raw']),
                'amount' => fn($a, $b) => $a['_sort_amount'] <=> $b['_sort_amount'],
                'status' => fn($a, $b) => strcasecmp($a['status'], $b['status']),
                default  => fn($a, $b) => $a['id'] <=> $b['id'],   // 'id'
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllQuotes(int $clientId): array
    {
        try {
            $response = localAPI('GetQuotes', [
                'userid'   => $clientId,
                'limitnum' => 100,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['quotes']['quote'] ?? []) as $q) {
                $stage = strip_tags((string)($q['stage'] ?? 'Draft'));
                $out[] = [
                    'id'             => (int)($q['id'] ?? 0),
                    'subject'        => (string)($q['subject'] ?? ''),
                    'datecreated'    => !empty($q['datecreated']) && $q['datecreated'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$q['datecreated']))
                        : '',
                    'validuntil'     => !empty($q['validuntil']) && $q['validuntil'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$q['validuntil']))
                        : '',
                    'total'          => (string)($q['total'] ?? ''),
                    'stage'          => $stage,
                    'stageLower'     => strtolower(str_replace([' ', '_'], '-', $stage)),
                    // Raw sort values for DataTables data-order attributes.
                    '_sort_date_raw'  => (string)($q['datecreated'] ?? ''),
                    '_sort_valid_raw' => (string)($q['validuntil'] ?? ''),
                    '_sort_amount'    => (float)preg_replace('/[^0-9.\-]/', '', (string)($q['total'] ?? '0')),
                ];
            }

            // URL-driven sort — mirrors fetchAllInvoices.
            $orderby = (string)($_GET['orderby'] ?? 'id');
            $sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
            if (!in_array($sort, ['ASC', 'DESC'], true)) {
                $sort = 'DESC';
            }
            $cmp = match ($orderby) {
                'date'   => fn($a, $b) => strcmp($a['_sort_date_raw'], $b['_sort_date_raw']),
                'valid'  => fn($a, $b) => strcmp($a['_sort_valid_raw'], $b['_sort_valid_raw']),
                'amount' => fn($a, $b) => $a['_sort_amount'] <=> $b['_sort_amount'],
                'status' => fn($a, $b) => strcasecmp($a['stage'], $b['stage']),
                default  => fn($a, $b) => $a['id'] <=> $b['id'],
            };
            usort($out, $cmp);
            if ($sort === 'DESC') {
                $out = array_reverse($out);
            }

            // Optional stage filter — ?stage=Draft|Delivered|Accepted|Lost|Dead|On Hold
            $stageFilter = (string)($_GET['stage'] ?? '');
            if ($stageFilter !== '') {
                $out = array_values(array_filter(
                    $out,
                    fn($row) => strcasecmp($row['stage'], $stageFilter) === 0
                ));
            }

            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchAllDomains(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsDomains', [
                'clientid' => $clientId,
                'limitnum' => 100,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];
            $out = [];
            foreach (($response['domains']['domain'] ?? []) as $d) {
                $status = (string)($d['status'] ?? 'Active');
                $out[] = [
                    'id'         => (int)($d['id'] ?? 0),
                    'domain'     => (string)($d['domainname'] ?? ''),
                    'domainname' => (string)($d['domainname'] ?? ''),
                    'regdate'    => !empty($d['regdate']) && $d['regdate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['regdate']))
                        : '',
                    'nextduedate'=> !empty($d['nextduedate']) && $d['nextduedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['nextduedate']))
                        : '',
                    'expirydate' => !empty($d['expirydate']) && $d['expirydate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$d['expirydate']))
                        : '',
                    'status'     => $status,
                    'statusLower'=> strtolower($status),
                    'autorenew'  => !empty($d['donotrenew']) ? false : true,
                    'registrar'  => (string)($d['registrar'] ?? ''),
                ];
            }
            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    /** Full product list (all statuses) shaped for clientareaproducts.tpl. */
    private function fetchAllProducts(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsProducts', [
                'clientid' => $clientId,
                'stats'    => false,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $out = [];
            foreach (($response['products']['product'] ?? []) as $p) {
                $status = (string)($p['status'] ?? 'Active');
                $statusClass = match ($status) {
                    'Active'                                  => 'active',
                    'Pending'                                 => 'pending',
                    'Suspended'                               => 'suspended',
                    'Terminated', 'Cancelled', 'Fraud'        => 'terminated',
                    default                                   => 'active',
                };
                $out[] = [
                    'id'                 => (int)($p['id'] ?? 0),
                    'productname'        => (string)($p['name'] ?? ''),
                    'groupname'          => (string)($p['groupname'] ?? 'Service'),
                    'name'               => (string)($p['name'] ?? ''),
                    'domain'             => (string)($p['domain'] ?? ''),
                    'firstpaymentamount' => (string)($p['firstpaymentamount'] ?? ''),
                    'recurringamount'    => (string)($p['recurringamount'] ?? ''),
                    'billingcycle'       => (string)($p['billingcycle'] ?? ''),
                    'paymentmethod'      => (string)($p['paymentmethod'] ?? ''),
                    'paymentmethodname'  => (string)($p['paymentmethodname'] ?? ''),
                    'nextduedate'        => !empty($p['nextduedate']) && $p['nextduedate'] !== '0000-00-00'
                        ? date('M j, Y', strtotime((string)$p['nextduedate']))
                        : '',
                    'status'             => $status,
                    'statusClass'        => $statusClass,
                ];
            }
            return $out;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchRecentInvoices(int $clientId): array
    {
        try {
            $response = localAPI('GetInvoices', [
                'userid'    => $clientId,
                'limitnum'  => self::DASHBOARD_ROWS,
                'orderby'   => 'date',
                'order'     => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $invoices = [];
            foreach (($response['invoices']['invoice'] ?? []) as $inv) {
                // WHMCS wraps invoice status in markup ('<span class="textred">
                // Overdue</span>'), so strip it here the way fetchAllInvoices
                // already does — otherwise a status-pill class built from this
                // value is markup, not a word.
                $status = trim(strip_tags((string)($inv['status'] ?? '')));
                $invoices[] = [
                    'id'          => (int)($inv['id'] ?? 0),
                    'date'        => !empty($inv['date']) ? date('M j, Y', strtotime((string)$inv['date'])) : '',
                    // Currency-formatted, not the API's bare decimal. GetInvoices
                    // returns total as "20.00" with no symbol, so the dashboard
                    // was listing an amount with no unit -- and this row sits
                    // beside a Balance due figure that IS formatted, which made
                    // the two look like different kinds of number. Same helper
                    // the billing summary already uses, so an install with a
                    // non-dollar currency gets its own prefix and separators.
                    'total'       => $this->formatPrice((float)($inv['total'] ?? 0)),
                    'status'      => $status,
                    'statusLower' => strtolower(str_replace(' ', '-', $status)),
                ];
            }
            return $invoices;
        } catch (\Throwable) {
            return [];
        }
    }

    /**
     * The client's open tickets for the dashboard.
     *
     * READS tbltickets DIRECTLY, and that is the whole point of this method.
     *
     * It used to call localAPI('GetTickets'). localAPI runs as an ADMIN, and
     * GetTickets adheres to the departments that admin is a member of unless
     * `ignore_dept_assignments` is passed — the official parameter table words
     * it as "Pass as true to not adhere to the departments the API user is a
     * member of". A department-restricted API user therefore gets back
     * result=success with an EMPTY ticket list, which is indistinguishable
     * from "this client has no tickets".
     *
     * That produced a dashboard reading "6 Tickets" over "No open tickets.":
     * the heading comes from $clientsstats.numactivetickets, which WHMCS
     * computes straight from the client's rows with no department filter, and
     * the body came from this fetch, which the department filter had emptied.
     *
     * Passing ignore_dept_assignments would fix that one cause. Querying the
     * table removes the whole class of them — no admin identity, no department
     * adherence, no API-user configuration to get wrong on a buyer's install.
     * It is also what this codebase already does everywhere else tickets
     * actually work: TableData::tickets() (the Support page's AJAX table) runs
     * exactly this query with the same $_SESSION['uid'], which is the evidence
     * that the client id was never the problem.
     *
     * Side benefit: the old call passed 'orderby'/'order', which GetTickets
     * does not accept — the intended "newest reply first" never happened and
     * the rows came back in whatever order the API chose. It is a real
     * ORDER BY now.
     */
    /**
     * Detail behind the Billing tile's summary: the overdue slice of what is
     * owed, the single worst invoice, and any account credit.
     *
     * $clientsstats already carries numunpaidinvoices, numoverdueinvoices and
     * unpaidinvoicesamount, and those stay the source for the headline figures
     * -- they are account totals WHMCS computes itself. What it does NOT carry
     * is how much of the balance is overdue, which invoice is worst, or how
     * many days late it is, and the summary card is mostly about exactly that.
     *
     * Reads tblinvoices directly rather than through GetInvoices, for the same
     * reason fetchOpenTickets does: localAPI runs as an admin and carries
     * per-admin scoping this has no business inheriting. One query, ordered so
     * the first row IS the worst one -- no second lookup.
     *
     * "Overdue" is derived, not stored: tblinvoices.status has no such value,
     * so it is Unpaid with a due date in the past. That is the same definition
     * WHMCS's own numoverdueinvoices uses, so the two agree.
     *
     * @return array{overdueCount:int, overdueAmount:string, worstNum:string,
     *                worstAmount:string, worstDays:int, credit:string,
     *                hasCredit:bool}
     */
    private function fetchBillingSummary(int $clientId): array
    {
        $out = [
            'overdueCount' => 0, 'overdueAmount' => '',
            'worstNum' => '', 'worstAmount' => '', 'worstDays' => 0,
            'credit' => '', 'hasCredit' => false,
        ];
        if ($clientId === 0) {
            return $out;
        }

        try {
            $today = date('Y-m-d');
            $rows  = \WHMCS\Database\Capsule::table('tblinvoices')
                ->where('userid', $clientId)
                ->where('status', 'Unpaid')
                ->where('duedate', '<', $today)
                ->orderBy('duedate', 'asc')
                ->get(['id', 'invoicenum', 'duedate', 'total']);

            // Walked rather than indexed: ->get() hands back a Collection on
            // some WHMCS builds and a plain array on others, and foreach is the
            // only access both agree on. The first row is the worst because the
            // query is ordered by due date.
            $sum   = 0.0;
            $count = 0;
            $worst = null;
            foreach ($rows as $row) {
                $count++;
                $sum += (float)($row->total ?? 0);
                if ($worst === null) {
                    $worst = $row;
                }
            }

            if ($count > 0 && $worst !== null) {
                $due = strtotime((string)($worst->duedate ?? ''));
                // invoicenum when the install uses custom numbering, else the id
                // -- the same choice the invoice pages make.
                $num = trim((string)($worst->invoicenum ?? ''));
                $out['overdueCount']  = $count;
                $out['overdueAmount'] = $this->formatPrice($sum);
                $out['worstNum']      = $num !== '' ? $num : (string)($worst->id ?? '');
                $out['worstAmount']   = $this->formatPrice((float)($worst->total ?? 0));
                $out['worstDays']     = $due ? (int)floor((strtotime($today) - $due) / 86400) : 0;
            }
        } catch (\Throwable) {
            // Leave the detail empty -- the tile falls back to the headline
            // figures, which come from $clientsstats and are always there.
        }

        try {
            // Raw decimal, so it can be TESTED as well as printed.
            // $clientsstats.creditbalance arrives pre-formatted, which makes
            // "is there any credit" a string comparison against "$0.00".
            $credit = (float)\WHMCS\Database\Capsule::table('tblclients')
                ->where('id', $clientId)
                ->value('credit');
            if ($credit > 0) {
                $out['credit']    = $this->formatPrice($credit);
                $out['hasCredit'] = true;
            }
        } catch (\Throwable) {
            // no credit line rather than no page
        }

        return $out;
    }

    /**
     * The two attention figures WHMCS does not publish.
     *
     * $clientsstats covers overdue invoices and expiring domains, so those come
     * from there. It has nothing for "suspended services" or "tickets waiting
     * on the client", and the obvious substitute -- counting the $dashboard
     * arrays -- is wrong: the hook caps those at DASHBOARD_ROWS and slices them
     * in API order, so a suspended service can fall off the end entirely and
     * the chip would quietly undercount. That is why these chips were left out
     * when the strip first shipped.
     *
     * A COUNT over the whole table has no such ceiling, so they are exact now.
     *
     * "Answered" is WHMCS's term for a ticket staff have replied to, i.e. the
     * ball is with the client -- which is what "awaiting your reply" means from
     * the client's side.
     *
     * @return array{suspended:int, awaitingReply:int}
     */
    private function fetchAttentionCounts(int $clientId): array
    {
        $out = ['suspended' => 0, 'awaitingReply' => 0];
        if ($clientId === 0) {
            return $out;
        }
        try {
            $out['suspended'] = (int)\WHMCS\Database\Capsule::table('tblhosting')
                ->where('userid', $clientId)
                ->where('domainstatus', 'Suspended')
                ->count();
        } catch (\Throwable) {
            // A missing figure drops its chip; it never shows a wrong one.
        }
        try {
            $out['awaitingReply'] = (int)\WHMCS\Database\Capsule::table('tbltickets')
                ->where('userid', $clientId)
                ->where('status', 'Answered')
                ->count();
        } catch (\Throwable) {
        }
        return $out;
    }

    private function fetchOpenTickets(int $clientId): array
    {
        if ($clientId === 0) {
            return [];
        }
        try {
            // select('*') rather than naming columns: this runs against every
            // buyer's schema and an unknown column name is a fatal, whereas a
            // missing key below just reads as ''.
            $rows = \WHMCS\Database\Capsule::table('tbltickets')
                ->where('userid', $clientId)
                // Same exclusion the API path applied, kept verbatim so this
                // change cannot alter which tickets appear — only whether any
                // appear at all. A custom status configured as closed-like in
                // tblticketstatuses is still treated as open here, exactly as
                // it was before.
                ->where('status', '!=', 'Closed')
                ->orderBy('lastreply', 'desc')
                ->orderBy('id', 'desc')
                ->limit(self::DASHBOARD_ROWS)
                ->get();
        } catch (\Throwable) {
            // Schema not as expected — fall back to the API, this time asking
            // it not to adhere to department assignments.
            return $this->fetchOpenTicketsViaApi($clientId);
        }

        $tickets = [];
        foreach ($rows as $row) {
            // tbltickets calls the subject 'title'; the API called it
            // 'subject'. The templates read 'subject', so map it here rather
            // than touching three variant templates.
            $dateRaw      = (string)($row->date ?? '');
            $lastReplyRaw = (string)($row->lastreply ?? '');
            $dateTs       = $dateRaw !== '' ? strtotime($dateRaw) : false;
            $lastReplyTs  = ($lastReplyRaw !== '' && $lastReplyRaw !== '0000-00-00 00:00:00')
                ? strtotime($lastReplyRaw) : false;

            $tickets[] = [
                'tid'       => (string)($row->tid ?? ''),
                'c'         => (string)($row->c ?? ''),
                'subject'   => (string)($row->title ?? ''),
                'status'    => trim(strip_tags((string)($row->status ?? ''))),
                'priority'  => (string)($row->urgency ?? 'Medium'),
                'date'      => $dateTs ? date('M j, Y', $dateTs) : '',
                'lastreply' => $lastReplyTs ? date('M j, Y', $lastReplyTs) : '',
            ];
        }
        return $tickets;
    }

    /**
     * Fallback for fetchOpenTickets when the direct query is unavailable.
     * Identical output shape. `ignore_dept_assignments` is the load-bearing
     * parameter — without it a department-restricted API user silently returns
     * success with zero tickets. 'orderby'/'order' are deliberately absent:
     * GetTickets does not accept them.
     */
    private function fetchOpenTicketsViaApi(int $clientId): array
    {
        try {
            $response = localAPI('GetTickets', [
                'clientid'                => $clientId,
                'limitnum'                => 25,
                'ignore_dept_assignments' => true,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $tickets = [];
            foreach (($response['tickets']['ticket'] ?? []) as $tkt) {
                $status = trim(strip_tags((string)($tkt['status'] ?? '')));
                if (strcasecmp($status, 'Closed') === 0) continue;

                $dateRaw = (string)($tkt['date'] ?? '');
                $dateTimestamp = $dateRaw !== '' ? strtotime($dateRaw) : false;
                $lastReplyRaw = (string)($tkt['lastreply'] ?? '');
                $lastReplyTimestamp = $lastReplyRaw !== '' ? strtotime($lastReplyRaw) : false;

                $tickets[] = [
                    'tid'      => (string)($tkt['tid'] ?? ''),
                    'c'        => (string)($tkt['c'] ?? ''),
                    'subject'  => (string)($tkt['subject'] ?? ''),
                    'status'   => $status,
                    'priority' => (string)($tkt['priority'] ?? 'Medium'),
                    'date'     => $dateTimestamp ? date('M j, Y', $dateTimestamp) : $dateRaw,
                    'lastreply' => $lastReplyTimestamp ? date('M j, Y', $lastReplyTimestamp) : $lastReplyRaw,
                ];
                if (count($tickets) >= self::DASHBOARD_ROWS) break;
            }
            return $tickets;
        } catch (\Throwable) {
            return [];
        }
    }

    // ---------------------------------------------------------------- helpers

    private function normalizeRecentTicketPanel(mixed $panels): void
    {
        $ticketPanel = $this->findPanel($panels, 'Recent Support Tickets');
        if ($ticketPanel === null || !method_exists($ticketPanel, 'hasChildren') || !$ticketPanel->hasChildren()) {
            return;
        }

        foreach ($ticketPanel->getChildren() as $ticketItem) {
            if (!method_exists($ticketItem, 'getLabel') || !method_exists($ticketItem, 'setLabel')) {
                continue;
            }

            $currentBadge = method_exists($ticketItem, 'hasBadge') && $ticketItem->hasBadge()
                ? (string)$ticketItem->getBadge()
                : '';
            $normalized = $this->parseTicketPanelLabel((string)$ticketItem->getLabel(), $currentBadge);

            if ($normalized['subject'] !== '') {
                $ticketItem->setLabel($normalized['subject']);
            }
            if ($normalized['status'] !== '' && method_exists($ticketItem, 'setBadge')) {
                $ticketItem->setBadge($normalized['status']);
            }
            if ($normalized['tid'] !== '' && method_exists($ticketItem, 'setExtra')) {
                $ticketItem->setExtra('tid', $normalized['tid']);
            }
            if ($normalized['lastreply'] !== '' && method_exists($ticketItem, 'setExtra')) {
                $ticketItem->setExtra('lastreply', $normalized['lastreply']);
            }
        }
    }

    private function findPanel(mixed $panels, string $name): mixed
    {
        if (method_exists($panels, 'getChild')) {
            $child = $panels->getChild($name);
            if ($child !== null) {
                return $child;
            }
        }

        if (!method_exists($panels, 'getChildren')) {
            return null;
        }

        foreach ($panels->getChildren() as $panel) {
            $panelName = method_exists($panel, 'getName') ? (string)$panel->getName() : '';
            $panelLabel = method_exists($panel, 'getLabel') ? trim(strip_tags((string)$panel->getLabel())) : '';
            if ($panelName === $name || $panelLabel === $name) {
                return $panel;
            }
        }

        return null;
    }

    /** @return array{subject: string, tid: string, lastreply: string, status: string} */
    private function parseTicketPanelLabel(string $label, string $currentBadge): array
    {
        $withBreaks = preg_replace('/<br\s*\/?>/i', "\n", $label) ?? $label;
        $text = preg_replace('/<[^>]+>/', ' ', $withBreaks) ?? $withBreaks;
        $text = html_entity_decode($text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
        $text = preg_replace('/[ \t]+/', ' ', $text) ?? $text;
        $text = preg_replace('/\s*\n\s*/', "\n", trim($text)) ?? trim($text);

        $lines = array_values(array_filter(array_map('trim', preg_split('/\R+/', $text) ?: [])));
        $firstLine = $lines[0] ?? $text;
        $lastReply = '';
        foreach ($lines as $line) {
            if (preg_match('/^Last\s+Updated:\s*(.+)$/i', $line, $matches)) {
                $lastReply = trim($matches[1]);
                break;
            }
        }

        $status = trim($currentBadge);
        $knownStatuses = [
            'Awaiting Reply',
            'Customer Reply',
            'Customer-Reply',
            'In Progress',
            'On Hold',
            'Answered',
            'Pending',
            'Closed',
            'Open',
        ];

        foreach ($knownStatuses as $knownStatus) {
            if (preg_match('/\b' . preg_quote($knownStatus, '/') . '\b\s*$/i', $firstLine)) {
                if ($status === '') {
                    $status = str_replace('-', ' ', $knownStatus);
                }
                $firstLine = trim((string)preg_replace('/\b' . preg_quote($knownStatus, '/') . '\b\s*$/i', '', $firstLine));
                break;
            }
        }

        $ticketId = '';
        $subject = $firstLine;
        if (preg_match('/^(#?[A-Z0-9]+-\d+)\s+-\s+(.+)$/i', $firstLine, $matches)) {
            $ticketId = ltrim($matches[1], '#');
            $subject = trim($matches[2]);
        }

        return [
            'subject'   => $subject,
            'tid'       => $ticketId,
            'lastreply' => $lastReply,
            'status'    => $status,
        ];
    }

    private function extensionOutput(Template $template, array $vars, string $slot): ?string
    {
        $output = '';
        foreach ($template->getExtensions() as $name) {
            $extPath = $template->getFullPath() . "/core/extensions/{$name}/{$name}.php";
            if (!file_exists($extPath)) {
                continue;
            }
            $extConfig = require $extPath;
            $callable  = $extConfig[$slot] ?? null;
            if (is_callable($callable)) {
                $output .= (string)$callable($vars);
            }
        }
        return $output !== '' ? $output : null;
    }

    private function resolveActiveStyle(Template $template): array
    {
        $active   = $template->resolveStyleName(
            (string)Settings::getValue($template->getName() . '_active_style', 'default')
        );
        $metaPath = $template->getFullPath() . "/core/styles/{$active}/style.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);
        return [
            'name' => $active,
            'meta' => $meta,
            'vars' => $meta['variables'] ?? [],
        ];
    }

    /**
     * Effective sub-nav visibility for the current page, per scope.
     * Precedence (most specific wins): per-page editor field (on/off) >
     * Settings exception-list picker (a listed page flips the global) >
     * global toggle. Exposed as $hadrian.subnav.{order,website}.
     *
     * @param array<string,mixed> $pages resolveCurrentPage() output
     * @return array{order:bool, website:bool}
     */
    private function resolveSubnav(Template $template, array $vars, array $pages): array
    {
        $tf     = (string)($vars['templatefile'] ?? '');
        $editor = (string)($pages[$tf]['subnav'] ?? 'inherit');

        $orderList = Settings::getValue('subnav_pages_order', []);
        $webList   = Settings::getValue('subnav_pages_website', []);
        if (!is_array($orderList)) { $orderList = []; }
        if (!is_array($webList))   { $webList   = []; }

        $eff = static function (string $editor, bool $inList, bool $global): bool {
            if ($editor === 'on')  { return true; }
            if ($editor === 'off') { return false; }
            return $inList ? !$global : $global; // exception list flips the global
        };

        return [
            'order'   => $eff($editor, in_array($tf, $orderList, true), $this->settingFlag('cart_subnav')),
            'website' => $eff($editor, in_array($tf, $webList, true), $this->settingFlag('website_subnav')),
        ];
    }

    /**
     * Effective service-list controls placement ('inside'|'outside') for the
     * current page. Precedence mirrors resolveSubnav: per-page editor field
     * (inside/outside) > Settings exception-list (a listed page flips the
     * global) > global toggle. Exposed as $hadrian.svcLayout.
     *
     * The global is read directly (default '0' = inside) rather than via
     * settingFlag(), which defaults UNSET to true — that would flip the live
     * default to 'outside' before the admin ever saves the Settings screen.
     *
     * @param array<string,mixed> $pages resolveCurrentPage() output
     */
    private function resolveSvcLayout(Template $template, array $vars, array $pages): string
    {
        $tf     = (string)($vars['templatefile'] ?? '');
        $editor = (string)($pages[$tf]['svclayout'] ?? 'inherit');
        if ($editor === 'inside')  { return 'inside'; }
        if ($editor === 'outside') { return 'outside'; }

        $list = Settings::getValue('svc_layout_pages', []);
        if (!is_array($list)) { $list = []; }

        $raw           = Settings::getValue('service_controls_outside', '0');
        $globalOutside = $raw === '1' || $raw === 1 || $raw === true;
        $inList        = in_array($tf, $list, true);
        $effOutside    = $inList ? !$globalOutside : $globalOutside; // exception list flips the global

        return $effOutside ? 'outside' : 'inside';
    }

    /** A boolean addon flag — defaults to true (shown) when unset. */
    private function settingFlag(string $key): bool
    {
        $v = Settings::getValue($key, '1');
        return $v !== '0' && $v !== 0 && $v !== false && $v !== '';
    }

    private function resolveActiveLayout(Template $template, string $kind): array
    {
        // Lagom-style per-audience pointers. The admin Layouts manager
        // writes one row per (kind, audience): guest-audience visitors
        // get one layout, logged-in clients get another. Fallback chain:
        //   1. per-audience key  hadrian_active_layout_<kind>_<aud>
        //   2. legacy single key hadrian_active_layout_<kind>
        //      (backwards-compat for installs migrated from the
        //      pre-dual-pointer Settings shape)
        //   3. default-by-kind (`main-menu`→`sidebar`, `footer`→`extended`)
        //
        // Keep this default-by-kind table in sync with
        // LayoutsController::DEFAULT_BY_KIND — otherwise the admin's
        // "Active" badge will disagree with the live render.
        $defaultByKind = ['main-menu' => 'sidebar', 'footer' => 'extended'];
        $default       = $defaultByKind[$kind] ?? 'default';

        $audience    = \Hadrian\Menu\Audience::current();
        $audienceKey = $audience === \Hadrian\Menu\Audience::CLIENT ? 'client' : 'guest';

        $newKey = $template->getName() . '_active_layout_' . $kind . '_' . $audienceKey;
        $active = (string)Settings::getValue($newKey, '');

        if ($active === '') {
            $legacyKey = $template->getName() . '_active_layout_' . $kind;
            $active    = (string)Settings::getValue($legacyKey, $default);
        }

        /* A pointer at a layout that no longer exists (a deleted custom folder,
           a renamed dir) must resolve to the default, NOT be rendered from a
           missing manifest. Without this, buildLayoutMeta loads [] and the page
           silently falls back to the sidebar via header.tpl's |default:'side'
           while the admin still shows the stale name as Active — the render and
           the badge disagreeing is exactly Lagom's stale-pointer defect.
           Resolving to default is the honest answer (the resolveStyleName
           philosophy); the Settings row is left in place, so re-dropping the
           folder restores the pick. getLayouts() reads the cached union — no
           filesystem work on this client path. */
        if (!in_array($active, $template->getLayouts($kind), true)) {
            $active = $default;
        }

        return $this->buildLayoutMeta($template, $kind, $active);
    }

    /** Build a layout metadata struct for a known $name. Shared between the
     *  global resolver and the per-page override path. */
    private function buildLayoutMeta(Template $template, string $kind, string $name): array
    {
        $metaPath = $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);

        // Resolve the layout's saved options (e.g. content alignment); each
        // stored value falls back to the option's declared default. The admin
        // writes these in the Layouts cards (see LayoutsController).
        $supported  = is_array($meta['supportedOptions'] ?? null) ? $meta['supportedOptions'] : [];
        $storedOpts = Settings::getValue($template->getName() . "_layout_opts_{$kind}_{$name}", []);
        if (!is_array($storedOpts)) { $storedOpts = []; }
        $options = [];
        foreach ($supported as $okey => $ospec) {
            $options[$okey] = (string)($storedOpts[$okey] ?? ($ospec['default'] ?? ''));
        }

        // No 'mediumPath': it was built for every layout and read by nothing.
        // footer.tpl composes the include path itself from .name, and main-menu
        // layouts render through includes/partials rather than core/layouts.
        return [
            'name'    => $name,
            'meta'    => $meta,
            'vars'    => $meta['variables'] ?? [],
            'options' => $options,
        ];
    }

    /**
     * Resolve the active variant + per-page overrides for the current request.
     *
     * Returned shape (keyed by templatefile, so root tpls can read e.g.
     * $hadrian.pages.login.fullPath):
     *   [
     *     'meta'             => array,    // from core/pages/<page>/page.php
     *     'variant'          => string,   // active variant name
     *     'fullPath'         => ?string,  // include path for root-tpl dispatch
     *     'seo'              => ['title','description','social_image'],
     *     'options'          => array<string,mixed>,
     *     'indexing'         => 'allow'|'disallow'|'inherit',
     *     'visibility'       => 'public'|'auth'|'disabled',
     *     'layout_overrides' => ['main-menu'=>?string,'footer'=>?string],
     *   ]
     */
    private function resolveCurrentPage(array $vars, Template $template): array
    {
        $page = (string)($vars['templatefile'] ?? '');
        if ($page === '') {
            return [];
        }

        // Normalize Nexus-style store templatefile paths to our flat naming
        // convention. WHMCS routes /store/<slug> through a templatefile like
        // 'store/<slug>/index' (or 'store/<slug>/<sub>' for sub-products such
        // as ssl/dv, ssl/ev). Our discovery + admin Pages tab keep them as
        // 'store-<slug>' or 'store-<slug>-<sub>' so they slot into the flat
        // core/pages/ scheme alongside every other page.
        if (preg_match('#^store/([^/]+)(?:/(\w+))?$#', $page, $m)) {
            $slug = $m[1];
            $sub  = $m[2] ?? '';
            $page = ($sub !== '' && $sub !== 'index')
                ? 'store-' . $slug . '-' . $sub
                : 'store-' . $slug;
        }

        $pageMeta = $template->getPageMeta($page);

        // Per-page config now lives in the hadrian_pages registry. Read the row
        // (read-only on this client path — the admin Pages tab seeds/maintains
        // the table) and resolve the active variant; $stored is rebuilt from the
        // row below in the legacy shape so the rest of this method is unchanged.
        $row = \Hadrian\Models\Page::get($template->getName(), $page);
        if ($row !== null) {
            $rowSettings = is_array($row['settings'] ?? null) ? $row['settings'] : [];
            $variant     = (string)($row['variant'] ?? '') !== ''
                ? (string)$row['variant']
                : (string)($pageMeta['defaultVariant'] ?? 'default');
        } else {
            // Registry row/table absent — the table is created lazily by the
            // admin Pages-tab self-heal. Fall back to the legacy hadrian_settings
            // store so SEO + variant keep working before the first import.
            $rowSettings = [];
            $variant     = (string)Settings::getValue(
                $template->getName() . '_page_variant_' . $page,
                (string)($pageMeta['defaultVariant'] ?? 'default')
            );
        }

        // Overwrites escape hatch — Lagom-style buyer override. If a customer
        // dropped core/pages/<page>/overwrites/overwrites.tpl in their theme,
        // that wins over BOTH the admin-selected variant and the default. Lets
        // buyers fully replace a page's body without forking the vendor file,
        // safe across theme updates. Lagom uses the same pattern at
        // templates/lagom2/<page>/overwrites/index.tpl; we keep it inside
        // core/pages/ so it lives next to the variants it overrides.
        $overwritesTpl = $template->getFullPath() . "/core/pages/{$page}/overwrites/overwrites.tpl";
        if (file_exists($overwritesTpl)) {
            $fullPath = "{$template->getName()}/core/pages/{$page}/overwrites/overwrites.tpl";
            $variant  = 'overwrites'; // surface in $hadrian.pages so admin can see it
        } else {
            $variantTpl = $template->getFullPath() . "/core/pages/{$page}/{$variant}/{$variant}.tpl";
            $fullPath   = file_exists($variantTpl)
                ? "{$template->getName()}/core/pages/{$page}/{$variant}/{$variant}.tpl"
                : null;
        }

        // Rebuild the legacy $stored shape from the registry row. SEO title/
        // description resolve to the request language; empty values are OMITTED
        // so the seoDefaults fallback in $entry still applies (keeps page.php
        // defaults live for pages the admin never customised).
        if ($row !== null) {
            $lang = (string)($vars['language'] ?? 'english');
            $stored = [
                'indexing'         => $row['indexing'] ?? null,
                'visibility'       => $row['visibility'] ?? null,
                'subnav'           => $rowSettings['subnav'] ?? null,
                'svclayout'        => $rowSettings['svclayout'] ?? null,
                'options'          => is_array($rowSettings['options'] ?? null) ? $rowSettings['options'] : [],
                'layout_overrides' => is_array($rowSettings['layout_overrides'] ?? null) ? $rowSettings['layout_overrides'] : [],
            ];
            $title = \Hadrian\Models\Page::lang($row['seo_title'] ?? null, $lang);
            $desc  = \Hadrian\Models\Page::lang($row['seo_description'] ?? null, $lang);
            $img   = (string)($row['seo_image'] ?? '');
            $seo = [];
            if ($title !== '') { $seo['title'] = $title; }
            if ($desc  !== '') { $seo['description'] = $desc; }
            if ($img   !== '') { $seo['social_image'] = $img; }
            $stored['seo'] = $seo;
        } else {
            // Legacy fallback (see above): the raw hadrian_settings page options
            // in their original shape. The $entry build below applies the same
            // seoDefaults fallback the pre-registry code did.
            $legacy = Settings::getValue($template->getName() . '_page_options_' . $page, null);
            $stored = is_array($legacy) ? $legacy : [];
        }
        $seoDefaults = is_array($pageMeta['seoDefaults'] ?? null) ? $pageMeta['seoDefaults'] : [];

        // Full-bleed flag — a variant can declare `fullPage => true` in its
        // <variant>.php meta (e.g. login/split), or an admin can enable the
        // page-level `full_page` option. Either makes header.tpl/footer.tpl
        // suppress the portal nav, sidebar/rail, breadcrumb and footer.
        $variantMeta  = ThemeManifest::loadVariantMeta(
            $template->getFullPath() . "/core/pages/{$page}/{$variant}/{$variant}.php"
        );
        $fullPageFlag = (bool)($variantMeta['fullPage'] ?? false)
            || (isset($stored['options']['full_page']) && (bool)$stored['options']['full_page']);

        $entry = [
            'meta'       => $pageMeta,
            'variant'    => $variant,
            'fullPage'   => $fullPageFlag,
            'fullPath'   => $fullPath,
            'indexing'   => (string)($stored['indexing']   ?? $seoDefaults['indexing'] ?? 'inherit'),
            'visibility' => (string)($stored['visibility'] ?? 'public'),
            'seo' => [
                'title'        => (string)($stored['seo']['title']        ?? $seoDefaults['title']        ?? ''),
                'description'  => (string)($stored['seo']['description']  ?? $seoDefaults['description']  ?? ''),
                'social_image' => (string)($stored['seo']['social_image'] ?? ''),
            ],
            'options' => is_array($stored['options'] ?? null) ? $stored['options'] : [],
            'subnav'  => in_array((string)($stored['subnav'] ?? 'inherit'), ['inherit', 'on', 'off'], true)
                ? (string)($stored['subnav'] ?? 'inherit') : 'inherit',
            'svclayout' => in_array((string)($stored['svclayout'] ?? 'inherit'), ['inherit', 'inside', 'outside'], true)
                ? (string)($stored['svclayout'] ?? 'inherit') : 'inherit',
            'layout_overrides' => [
                'main-menu' => isset($stored['layout_overrides']['main-menu']) && is_string($stored['layout_overrides']['main-menu'])
                    ? $stored['layout_overrides']['main-menu'] : null,
                'footer'    => isset($stored['layout_overrides']['footer']) && is_string($stored['layout_overrides']['footer'])
                    ? $stored['layout_overrides']['footer'] : null,
            ],
        ];

        // Variant-scoped options. A variant may declare its own
        // `supportedOptions` in <variant>.php; those are stored namespaced as
        // `<key>@<variant>` so sibling templates keep independent settings.
        // Flatten the ACTIVE variant's into $entry['options'] under their bare
        // keys, so a template just reads
        // $hadrian.pages.<page>.options.<key> and never has to know.
        //
        // Page-scoped options already sit there and are not disturbed; a
        // variant key of the same name wins, since it is the more specific.
        $variantMetaOpts = is_array($variantMeta['supportedOptions'] ?? null)
            ? $variantMeta['supportedOptions'] : [];
        foreach ($variantMetaOpts as $optKey => $optSpec) {
            // Separator must match PagesController::VARIANT_SEP. Kept to
            // [a-z0-9_]: WHMCS's POST handling drops option keys containing an
            // '@', so anything fancier never reaches the database at all.
            $nsKey = $optKey . '__' . $variant;
            if (array_key_exists($nsKey, $stored['options'] ?? [])) {
                $entry['options'][$optKey] = $stored['options'][$nsKey];
            } elseif (!array_key_exists($optKey, $entry['options'])) {
                // Legacy: this option used to be page-scoped, so an install
                // that saved it before the move still has the bare key.
                $entry['options'][$optKey] = $stored['options'][$optKey] ?? null;
            }
        }

        // Section layouts. Any option of type 'sections' — declared on the page
        // or on the active variant — is parsed from its stored string into an
        // ordered list of ['key','width','span','visible'] and exposed as
        // $hadrian.pages.<page>.sections.<optionKey>. Driven off the spec, not
        // the page name, so any page can adopt it by declaring the option.
        $sectionSpecs = array_merge(
            is_array($pageMeta['supportedOptions'] ?? null) ? $pageMeta['supportedOptions'] : [],
            $variantMetaOpts
        );
        foreach ($sectionSpecs as $optKey => $optSpec) {
            if (!is_array($optSpec) || ($optSpec['type'] ?? '') !== 'sections') {
                continue;
            }
            $entry['sections'][$optKey] = \Hadrian\Helpers\SectionLayout::parse(
                (string)($entry['options'][$optKey] ?? ''),
                is_array($optSpec['sections'] ?? null) ? $optSpec['sections'] : [],
                // Paint vocabulary, declared once beside the catalogue. Anything
                // outside it is dropped rather than rendered, so a retired or
                // mistyped palette key can never reach the CSS.
                array_keys(is_array($optSpec['paints'] ?? null) ? $optSpec['paints'] : [])
            );
        }

        // Expose under the normalized key (admin Pages tab, dispatcher hardcoded keys)
        // AND under the original templatefile when WHMCS used a Nexus-style nested
        // path — so header.tpl's $hadrian.pages[$templatefile] SEO lookup still works.
        $original = (string)($vars['templatefile'] ?? '');
        $out = [$page => $entry];
        if ($original !== '' && $original !== $page) {
            $out[$original] = $entry;
        }
        return $out;
    }

    /**
     * Computed SEO context for the document <head> (exposed as $hadrian.seo).
     * Centralises the bits that are awkward or error-prone in Smarty:
     *   - canonical / og:url — the absolute current URL with the volatile
     *     `currency` and `language` query params stripped, so paginated or
     *     localised variants don't fragment into duplicate-content URLs.
     *   - og:type — "website" for the home/index, "article" otherwise.
     *   - hreflang — the alternate-language link set, emitted only when the
     *     "Enable Alternate Links" flag is on (Lagom's enable_hreflang_links
     *     parity) and a language's ISO code resolves; unmappable languages are
     *     skipped rather than emitting a broken tag.
     *
     * URLs are built from $_SERVER the same way header.tpl builds its <base>
     * tag (scheme + host + REQUEST_URI). When no host is resolvable (CLI/test)
     * canonical is left empty so the template omits the tag.
     *
     * @return array{canonical:string, ogType:string, hreflang:list<array{code:string,url:string}>}
     */
    private function resolveSeoContext(array $vars): array
    {
        $https  = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $scheme = (string)($_SERVER['REQUEST_SCHEME'] ?? ($https ? 'https' : 'http'));
        $host   = (string)($_SERVER['HTTP_HOST'] ?? '');
        $base   = $host !== '' ? $scheme . '://' . $host : '';

        // Split REQUEST_URI into path + query, then drop the volatile params.
        $uri   = (string)($_SERVER['REQUEST_URI'] ?? '');
        $split = explode('?', $uri, 2);
        $path  = $split[0];
        parse_str($split[1] ?? '', $params);
        unset($params['currency'], $params['language']);
        $clean = $path . ($params !== [] ? '?' . http_build_query($params) : '');

        // og:type. "article" is for time-stamped, authored content — it was
        // previously the default for everything except the homepage, which
        // labelled shop and client-area pages (store/sitelock, My Services)
        // as articles. Open Graph's own default is "website", so that is the
        // fallback and "article" is now the exception: a SINGLE announcement
        // or knowledge-base entry. The list pages that index them
        // (announcements, knowledgebase, knowledgebasecat) stay "website" —
        // a listing is not an article.
        $page   = (string)($vars['templatefile'] ?? '');
        $ogType = in_array($page, self::OG_ARTICLE_PAGES, true) ? 'article' : 'website';

        $hreflang = [];
        if ($base !== '' && $this->settingFlag('enable_alternate_links')) {
            // x-default → the site default (no language param).
            $hreflang[] = ['code' => 'x-default', 'url' => $base . $clean];
            foreach (LocaleHelper::effectiveList() as $name) {
                $code = LocaleHelper::codeFor($name);
                if ($code === null) {
                    continue;
                }
                $langParams = $params;
                $langParams['language'] = $name;
                $hreflang[] = [
                    'code' => $code,
                    'url'  => $base . $path . '?' . http_build_query($langParams),
                ];
            }
            // Only x-default resolved (no per-language codes) → emit nothing.
            if (count($hreflang) === 1) {
                $hreflang = [];
            }
        }

        return [
            'canonical' => $base !== '' ? $base . $clean : '',
            'ogType'    => $ogType,
            'hreflang'  => $hreflang,
        ];
    }

    /**
     * All theme settings for the front-end payload, with request-time
     * resolution applied where a stored value is language-keyed.
     *
     * Today that's only cookie_box_message: it's stored as a per-language map
     * ({"english": "...", "spanish": "..."}, Lagom-parity), but the cookie bar
     * shows exactly ONE message, so we collapse it to the right string for the
     * active request language here. Resolving in PHP (not the template) keeps it
     * robust across the client area, the order form, and full-bleed login pages
     * — none of which reliably expose $activeLocale in the footer include scope.
     *
     * @return array<string, mixed>
     */
    private function addonSettingsForRender(string $currentLang): array
    {
        $settings = Settings::all();
        if (array_key_exists('cookie_box_message', $settings)) {
            $settings['cookie_box_message'] = $this->resolveCookieMessage($settings['cookie_box_message'], $currentLang);
        }
        return $settings;
    }

    /**
     * Pick the cookie-bar message from the stored per-language map:
     * active language → WHMCS system default language → '' (the template then
     * falls back to the built-in $hadrianLang.common.cookieMessage).
     *
     * Tolerates a legacy flat string (pre per-language storage) by returning it
     * unchanged, so an install that saved a message before this change keeps
     * showing it until the admin re-saves and normalises it to a per-language map.
     */
    private function resolveCookieMessage(mixed $stored, string $currentLang): string
    {
        if (is_string($stored)) {
            return $stored; // legacy single-string storage
        }
        if (!is_array($stored) || $stored === []) {
            return '';
        }

        $current = strtolower($currentLang);
        if (isset($stored[$current]) && is_string($stored[$current]) && $stored[$current] !== '') {
            return $stored[$current];
        }

        $default = '';
        try {
            $default = strtolower((string)\WHMCS\Config\Setting::getValue('Language'));
        } catch (\Throwable $e) {
            // Setting unavailable (CLI/test) — fall through to empty.
        }
        if ($default !== '' && isset($stored[$default]) && is_string($stored[$default]) && $stored[$default] !== '') {
            return $stored[$default];
        }

        return '';
    }

    /**
     * Theme translation strings for the active language, as a three-layer
     * per-key merge (later layers win):
     *
     *   1. core/lang/english.php            — the full shipped key set
     *   2. core/lang/<language>.php         — a translation; may be PARTIAL,
     *      untranslated keys fall back to English key-by-key rather than
     *      rendering as empty strings
     *   3. core/lang/overrides/<language>.php — buyer-owned edits. The
     *      overrides/ folder is never shipped, so nothing in it is touched
     *      by a theme update.
     *
     * The language token comes from WHMCS ($vars['language']) but is
     * re-validated before touching the filesystem — it is interpolated into a
     * path. Overlay files are buyer-authored, so each is loaded inside its own
     * try/catch: a syntax error in an override must degrade to "override
     * ignored", never to a white screen.
     */
    private function loadLanguage(Template $template, string $lang): array
    {
        $lang = strtolower(trim($lang));
        if (!preg_match('/^[a-z][a-z0-9_-]*$/', $lang)) {
            $lang = 'english';
        }

        $dir     = $template->getFullPath() . '/core/lang';
        $strings = ThemeManifest::loadVariantMeta($dir . '/english.php');

        foreach (["{$dir}/{$lang}.php", "{$dir}/overrides/{$lang}.php"] as $overlay) {
            if ($lang === 'english' && $overlay === "{$dir}/{$lang}.php") {
                continue; // layer 1 already is english.php
            }
            try {
                $extra = ThemeManifest::loadVariantMeta($overlay);
            } catch (\Throwable $e) {
                $extra = [];
            }
            if ($extra !== []) {
                $strings = array_replace_recursive($strings, $extra);
            }
        }

        return $strings;
    }
}
