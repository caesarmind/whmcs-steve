<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\LocaleHelper;
use Hadrian\Models\Settings;
use Hadrian\Template\Template;

final class SettingsController extends AbstractController
{
    /**
     * Available settings — used by the view to render the toggle list and by save() to validate keys.
     * Each entry: [label, help, default, type ('bool'|'string'|'int')]
     *
     * Only boolean toggles live here. Compound settings (e.g. the language
     * picker — toggle plus a list of codes) are stored separately and
     * handled in indexAction/save below.
     */
    public const FLAGS = [
        // Help text spells out the scroll-up reveal: "Pin the navbar on scroll"
        // described neither half accurately, and a toggle whose label does not
        // match its behaviour is the exact problem this audit set out to fix.
        'affixed_navigation'     => ['Affixed Navigation',       'Keep the navbar pinned while scrolling. It slides out of the way as you scroll down and returns the moment you scroll up. Off lets the navbar scroll away with the page.', false, 'bool'],
        'hide_breadcrumb'        => ['Hide Breadcrumb',          'Hide the breadcrumb above the page title on every layout (the "Portal Home" back-link on top nav, and the "Home / Page" trail on the sidebar and icon-rail layouts).', false, 'bool'],
        'cookie_box'             => ['Cookie Box',               'Show a cookie consent banner on first visit.',                          false, 'bool'],
        // Negative key on purpose: the sidebar IS pinned today (core-theme.css:291
        // position:fixed), so a "Sticky sidebar" label would imply the toggle adds
        // stickiness that already exists. Default false == today's rendering.
        // SIDE LAYOUT ONLY -- the icon rail is the sole navigation on its layout and
        // its flyout panel is pinned to the rail (position:fixed, left:80px), while
        // .ph-mobile-toggle is display:none above 900px. Unpinning the rail would
        // scroll the only nav away and strand the panel, leaving no reachable nav
        // below the fold.
        'unpin_sidebar'          => ['Unpin Sidebar',            'Let the sidebar scroll away with the page instead of staying pinned to the viewport. Applies to the Sidebar layout above 900px only; the icon rail and the mobile slide-in drawer stay pinned. While this is on, the main menu is only reachable at the top of the page.', false, 'bool'],
        'back_to_top'            => ['Back to Top Button',       'Show a floating button in the bottom-right corner once the visitor scrolls down, returning them to the top of the page when clicked.', false, 'bool'],
        // Default OFF deliberately: the runtime (PriceHelper / price.tpl) treats
        // unset as off, so a `true` here would render the box pre-checked while
        // nothing actually changed until the admin pressed Save. Opt-in also
        // means deploying this never silently relabels prices on a live install.
        'free_label'             => ['"0.00" → "Free"',          'Display free items as "Free" instead of "$0.00".',                       false, 'bool'],
        'enable_alternate_links' => ['Enable Alternate Links',   'Add SEO multi-language alternate links.',                               true,  'bool'],
        // Scope spelled out: this covers marketing/store section labels only,
        // NOT client-area table headers or sidebar labels (see core-layout.css).
        // Lagom scopes its equivalent the same way.
        'capitalize_titles'      => ['Section Titles Capitalization', 'Uppercase the eyebrows, tags and tier labels on homepage and store pages. Client-area table headings and sidebar labels are unaffected.', true,  'bool'],
        'hide_cycle_discounts'   => ['Hide Billing Cycle Discounts', 'Hide the "Save X%" pills shown next to the billing cycle choices when configuring a product.', false, 'bool'],
        'enable_dynamic_ajax'    => ['Enable Dynamic AJAX Loading',  'Load data tables (services, domains, invoices, tickets, quotes, emails) in pages of 10 via AJAX — fast first paint on large accounts.', false, 'bool'],
        'custom_language_list'   => ['Custom Language List',     'Override the language list shown to clients in the locale chooser.',    false, 'bool'],
        'enable_dark_mode'       => ['Enable Dark Mode',         'Allow visitors to toggle dark mode.',                                   true,  'bool'],
        'topnav_show_icons'      => ['Top-Nav Icons',            'Show icons next to menu items in the top navigation. Off by default.',  false, 'bool'],
        'cart_subnav'            => ['Order Category Sidebar',   'Show the Categories / Actions sidebar on order (cart) pages.',          true,  'bool'],
        'website_subnav'         => ['Website Section Sidebar',  'Show the per-page section sub-nav (Account, Domain Tools, etc.) on client-area pages.', true, 'bool'],
        // Label widened to match what this actually does now. The CSS rule it
        // drives (core-layout.css, body[data-svc-layout="outside"]) stopped
        // being list-page-specific: it floats the .card-header — the TITLE — of
        // every standard card page onto the page background above a flat
        // .card-body. Calling it "Service List Controls" undersold it and left
        // admins looking for a titles-inside/outside option that was already here.
        'service_controls_outside' => ['Card Titles Outside the Box', 'Float card titles (and the search/pagination controls beside them) on the page background above a flat card, instead of keeping them inside one unified white card. Applies to every standard card page.', false, 'bool'],
        // Locale controls. locale-btn.tpl renders ONE button covering both, so
        // hiding both suppresses the button entirely; the modal sections are
        // gated independently. Currency additionally self-gates on the install
        // having more than one active currency.
        'hide_language_switcher'   => ['Hide Language Switcher',  'Remove the language chooser from the header. The locale button disappears entirely when the currency selector is hidden too.', false, 'bool'],
        'hide_currency_selector'   => ['Hide Currency Selector',  'Remove the currency chooser from the header. Has no visible effect on single-currency installs, which never show it.', false, 'bool'],
        // Only the extended-info footer renders socials (from $mtBrand.socials),
        // and it already self-gates on those being set in Branding. This is a
        // master override on top of that.
        'hide_footer_socials'      => ['Hide Footer Social Links', 'Hide the social icons in the footer. Only the "Extended Footer + Info" layout renders them, and only when social URLs are set under Branding.', false, 'bool'],
    ];

    /**
     * Flags that render on the Layouts page instead of here. They stay declared
     * in FLAGS above so there is still one registry for label/help/default/type
     * — LayoutsController reads their metadata straight from it.
     *
     * These are excluded from BOTH the render and save() below. The exclusion in
     * save() is the load-bearing half: that loop writes every FLAGS key from
     * `isset($_POST[$key])`, so a flag that no longer renders here would be
     * posted-as-absent and silently switched off every time Settings is saved.
     */
    public const LAYOUT_FLAGS = [
        'affixed_navigation',
        'unpin_sidebar',
        'hide_breadcrumb',
        'hide_language_switcher',
        'hide_currency_selector',
        'hide_footer_socials',
        'back_to_top',
    ];

    /**
     * Which Layouts tab+section a relocated flag renders under. Anything not
     * listed falls back to the Main menu tab's Header section.
     */
    public const LAYOUT_FLAG_SECTION = [
        'hide_footer_socials' => 'footer',
        'back_to_top'         => 'footer',
    ];

    /** Which Settings tab each flag renders on. Unlisted flags default to 'general'. */
    public const FLAG_TABS = [
        'cart_subnav' => 'order',
    ];

    /**
     * Which sub-group each flag renders under, and the order the groups appear.
     *
     * Purely presentational: it decides where a row is DRAWN, never whether it
     * is drawn. Every settingsPageFlags() key still reaches the form (see
     * grouped() below), because save() writes each key from
     * isset($_POST[$key]) — a row that stopped rendering would be
     * posted-as-absent and silently switched off.
     *
     * Declaration order here is the render order. The FLAGS array itself must
     * NOT be reordered: LayoutsController reads its slots positionally.
     */
    // A 4th positional element carrying each group's icon -- so the view can
    // draw the Hadrian demo's head (tinted chip + label + rule + count) -- was
    // added and then reverted with commit 3dd081b. If it comes back, note that
    // three groups here have no demo counterpart, and that the <svg> wrapper
    // belongs in the template so no group can ship its own stroke weight.
    private const FLAG_GROUPS = [
        // slug        => [label, one-line description, which tab it belongs to]
        'appearance'   => ['Appearance',            'Colour mode, label casing and card treatment.', 'general'],
        'navigation'   => ['Navigation',            'Menu icons and the client-area section sidebar.', 'general'],
        'pricing'      => ['Pricing Display',       'How prices are presented. Nothing here changes a price.', 'general'],
        'locale'       => ['Language & SEO',        'The locale chooser and multi-language link tags.', 'general'],
        'privacy'      => ['Privacy & Performance', 'Consent banner and data-table loading.', 'general'],
        // Catch-all. Empty today; it exists so a future FLAGS key with no
        // FLAG_GROUP entry lands somewhere VISIBLE rather than vanishing.
        'general'      => ['Other',                 'Options not yet assigned to a category.', 'general'],
        'cart'         => ['Cart Layout',           'The order form’s own sidebar.', 'order'],
    ];

    /** flag key => FLAG_GROUPS slug. Anything unlisted falls into 'general'. */
    private const FLAG_GROUP = [
        'enable_dark_mode'         => 'appearance',
        'capitalize_titles'        => 'appearance',
        'service_controls_outside' => 'appearance',
        'topnav_show_icons'        => 'navigation',
        'website_subnav'           => 'navigation',
        'free_label'               => 'pricing',
        'hide_cycle_discounts'     => 'pricing',
        'custom_language_list'     => 'locale',
        'enable_alternate_links'   => 'locale',
        'cookie_box'               => 'privacy',
        'enable_dynamic_ajax'      => 'privacy',
        'cart_subnav'              => 'cart',
    ];

    /**
     * Extra words folded into a row's search haystack, so a setting is
     * findable by the outcome an admin has in mind rather than only by the
     * exact words in its label ("gdpr" -> Cookie Box, "hreflang" -> Enable
     * Alternate Links).
     */
    private const FLAG_SEARCH_TERMS = [
        'cookie_box'               => 'gdpr consent banner privacy notice',
        'enable_alternate_links'   => 'hreflang seo multilingual alternate head tags',
        'custom_language_list'     => 'locale chooser restrict limit languages translations',
        'enable_dynamic_ajax'      => 'paginate pagination tables performance services domains invoices tickets',
        'free_label'               => 'price pricing zero 0.00 currency',
        'hide_cycle_discounts'     => 'save percent pill billing cycle discount',
        'capitalize_titles'        => 'uppercase caps casing marketing store homepage eyebrow',
        'service_controls_outside' => 'card title header inside outside layout flat',
        'topnav_show_icons'        => 'menu icons navbar header navigation',
        'website_subnav'           => 'sidebar section client area subnav account domain tools',
        'cart_subnav'              => 'sidebar categories cart order store subnav',
        'enable_dark_mode'         => 'dark light theme colour color switcher forced',
    ];

    /** FLAGS minus the ones that have moved to the Layouts page. */
    public static function settingsPageFlags(): array
    {
        return array_diff_key(self::FLAGS, array_flip(self::LAYOUT_FLAGS));
    }

    /**
     * settingsPageFlags() partitioned into render groups.
     *
     * Built by iterating settingsPageFlags() itself — the same array save()
     * iterates — so the set of keys the form renders is provably identical to
     * the set save() writes. A key with no FLAG_GROUP entry falls into
     * 'general' rather than disappearing. Empty groups are dropped so no bare
     * heading is drawn.
     *
     * @return list<array{slug:string,label:string,sub:string,tab:string,flags:array<string,array>}>
     */
    public static function groupedFlags(): array
    {
        $buckets = array_fill_keys(array_keys(self::FLAG_GROUPS), []);
        foreach (self::settingsPageFlags() as $key => $meta) {
            $slug = self::FLAG_GROUP[$key] ?? 'general';
            if (!array_key_exists($slug, $buckets)) {
                $slug = 'general';           // unknown slug still renders
            }
            $buckets[$slug][$key] = $meta;
        }

        $out = [];
        foreach (self::FLAG_GROUPS as $slug => [$label, $sub, $tab]) {
            if ($buckets[$slug] === []) {
                continue;
            }
            $out[] = ['slug' => $slug, 'label' => $label, 'sub' => $sub, 'tab' => $tab, 'flags' => $buckets[$slug]];
        }
        return $out;
    }

    /** @return array<string,string> flag key => extra search words */
    public static function searchTerms(): array
    {
        return self::FLAG_SEARCH_TERMS;
    }

    public function indexAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->save();
        }

        $values = [];
        foreach (self::FLAGS as $key => [$_label, $_help, $default, $type]) {
            $values[$key] = Settings::getValue($key, $default);
        }

        $installedLanguages = LocaleHelper::detectInstalled();
        $stored = Settings::getValue(LocaleHelper::LIST_KEY, []);
        $selectedLanguages = [];
        if (is_array($stored)) {
            foreach ($stored as $code) {
                if (is_string($code) && $code !== '') {
                    $selectedLanguages[] = strtolower($code);
                }
            }
            $selectedLanguages = array_values(array_unique($selectedLanguages));
        }

        $template     = AddonHelper::getTemplate();
        $orderPages   = Template::ORDER_PAGES;
        $websitePages = [];
        if ($template !== null) {
            foreach ($template->getPages() as $p) {
                if (isset($orderPages[$p])) { continue; }
                $meta = $template->getPageMeta($p);
                $websitePages[$p] = (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $p)));
            }
        }
        $subnavOrderList   = Settings::getValue('subnav_pages_order', []);
        $subnavWebsiteList = Settings::getValue('subnav_pages_website', []);
        if (!is_array($subnavOrderList))   { $subnavOrderList = []; }
        if (!is_array($subnavWebsiteList)) { $subnavWebsiteList = []; }

        // Service-list-controls exception picker — only the list-style pages
        // that actually ship body[data-svc-layout] CSS (Template::SVC_LAYOUT_PAGES),
        // filtered to those registered on the active template.
        $svcPages = [];
        if ($template !== null) {
            $registered = $template->getPages();
            foreach (Template::SVC_LAYOUT_PAGES as $slug) {
                if (!in_array($slug, $registered, true)) { continue; }
                $meta = $template->getPageMeta($slug);
                $svcPages[$slug] = (string)($meta['display_name'] ?? ucwords(str_replace(['-', '_'], ' ', $slug)));
            }
        }
        $svcLayoutList = Settings::getValue('svc_layout_pages', []);
        if (!is_array($svcLayoutList)) { $svcLayoutList = []; }

        // ── Order Process (Lagom-parity) settings ──────────────────────────
        // Hide Nameservers / Hide Hostname are enum (off|all|selected) + a json
        // GID list; Use Custom Hostname carries prefix/interfix/suffix/chars.
        // All three features render on the 'order' tab.
        $opNsGroups   = Settings::getValue('op_hide_nameservers_groups', []);
        $opHostGroups = Settings::getValue('op_hide_hostname_groups', []);
        $opChars      = Settings::getValue('op_custom_hostname_chars', ['upper', 'lower', 'numbers']);
        if (!is_array($opNsGroups))   { $opNsGroups = []; }
        if (!is_array($opHostGroups)) { $opHostGroups = []; }
        if (!is_array($opChars))      { $opChars = ['upper', 'lower', 'numbers']; }

        // Cookie Box message — stored per-language (Lagom-parity). Surface it as
        // a lang-code => message map for the per-language editor. Tolerate a
        // legacy flat string by tucking it under the system default language so
        // the admin sees existing copy and a re-save normalises it to a map.
        $defaultLanguage   = $this->systemDefaultLanguage();
        $rawCookieMessage  = Settings::getValue('cookie_box_message', []);
        $cookieBoxMessages = [];
        if (is_string($rawCookieMessage)) {
            if (trim($rawCookieMessage) !== '') {
                $cookieBoxMessages[$defaultLanguage] = $rawCookieMessage;
            }
        } elseif (is_array($rawCookieMessage)) {
            foreach ($rawCookieMessage as $code => $msg) {
                if (is_string($code) && is_string($msg)) {
                    $cookieBoxMessages[strtolower($code)] = $msg;
                }
            }
        }

        return $this->view('settings/index', [
            'flags'              => self::settingsPageFlags(),
            'flagTabs'           => self::FLAG_TABS,
            'flagGroups'         => self::groupedFlags(),
            'searchTerms'        => self::searchTerms(),
            'values'             => $values,
            'darkModeDisplay'    => (string)Settings::getValue('dark_mode_display', 'switcher'),
            'darkModeDefault'    => (string)Settings::getValue('dark_mode_default', 'light'),
            'cookieBoxMessages'  => $cookieBoxMessages,
            'defaultLanguage'    => $defaultLanguage,
            'cookieBoxPosition'  => (string)Settings::getValue('cookie_box_position', 'bottom-left'),
            'cookieBoxButton'    => (string)Settings::getValue('cookie_box_button', 'Continue'),
            'tab'                => $_GET['tab'] ?? 'general',
            'installedLanguages' => $installedLanguages,
            'selectedLanguages'  => $selectedLanguages,
            'langListKey'        => LocaleHelper::LIST_KEY,
            'orderPages'         => $orderPages,
            'websitePages'       => $websitePages,
            'subnavOrderList'    => $subnavOrderList,
            'subnavWebsiteList'  => $subnavWebsiteList,
            'svcPages'           => $svcPages,
            'svcLayoutList'      => $svcLayoutList,
            // Order Process
            'productGroups'           => $this->fetchProductGroups(),
            'opHideNs'                => (string)Settings::getValue('op_hide_nameservers', 'off'),
            'opHideNsGroups'          => array_map('strval', $opNsGroups),
            'opHideHost'              => (string)Settings::getValue('op_hide_hostname', 'off'),
            'opHideHostGroups'        => array_map('strval', $opHostGroups),
            'opCustomHostname'        => (bool)Settings::getValue('op_custom_hostname', false),
            'opCustomHostnamePrefix'  => (string)Settings::getValue('op_custom_hostname_prefix', ''),
            'opCustomHostnameInterfix'=> (int)Settings::getValue('op_custom_hostname_interfix', 20),
            'opCustomHostnameSuffix'  => (string)Settings::getValue('op_custom_hostname_suffix', ''),
            'opCustomHostnameChars'   => array_values(array_map('strval', $opChars)),
            'opHideHostnameCheckout'  => (bool)Settings::getValue('op_hide_hostname_checkout', false),
            'opRootPwStrength'        => (bool)Settings::getValue('op_root_pw_strength', false),
        ]);
    }

    private function save(): void
    {
        foreach (self::settingsPageFlags() as $key => [, , , $type]) {
            // Posted as 'on' when checked, missing when unchecked. Flags that
            // render on Layouts are skipped — this form never carries them, so
            // including them here would write '0' over the admin's choice.
            $val = isset($_POST[$key]) ? true : false;
            Settings::setValue($key, $val ? '1' : '0', $type);
        }

        // Dark-mode sub-options (revealed under the Enable Dark Mode toggle).
        // Display type: 'switcher' (visitors get a light/dark toggle) or
        // 'forced' (locked to the default mode, no toggle). Default mode:
        // 'light' or 'dark' — the mode the site loads in. Validated against
        // their allowed sets so a stale form can't store junk.
        $display = (string)($_POST['dark_mode_display'] ?? 'switcher');
        Settings::setValue('dark_mode_display', in_array($display, ['switcher', 'forced'], true) ? $display : 'switcher', 'string');
        $defaultMode = (string)($_POST['dark_mode_default'] ?? 'light');
        Settings::setValue('dark_mode_default', in_array($defaultMode, ['light', 'dark'], true) ? $defaultMode : 'light', 'string');

        // Cookie Box sub-fields (revealed under the cookie_box toggle). Message
        // allows basic admin-authored HTML; position is validated; button label
        // falls back to "Continue".
        //
        // Message is per-language (Lagom-parity): inputs arrive as
        // cookie_box_message[<langcode>]. Keep only installed languages with
        // non-empty content and store as a JSON map. A stale form that posts a
        // flat string is tucked under the system default language so nothing is
        // lost, and an empty box for a language drops that translation.
        $postedCookieMsgs = $_POST['cookie_box_message'] ?? [];
        $cookieMsgs = [];
        if (is_array($postedCookieMsgs)) {
            $installedLangs = array_flip(LocaleHelper::detectInstalled());
            foreach ($postedCookieMsgs as $code => $msg) {
                $code = strtolower((string)$code);
                if (!isset($installedLangs[$code])) { continue; }
                $msg = trim((string)$msg);
                if ($msg === '') { continue; }
                $cookieMsgs[$code] = $msg;
            }
        } elseif (is_string($postedCookieMsgs) && trim($postedCookieMsgs) !== '') {
            $cookieMsgs[$this->systemDefaultLanguage()] = trim($postedCookieMsgs);
        }
        Settings::setValue('cookie_box_message', $cookieMsgs, 'json');
        $cookiePos = (string)($_POST['cookie_box_position'] ?? 'bottom-left');
        Settings::setValue('cookie_box_position', in_array($cookiePos, ['bottom-left', 'bottom-right', 'bottom'], true) ? $cookiePos : 'bottom-left', 'string');
        $cookieBtn = trim((string)($_POST['cookie_box_button'] ?? ''));
        Settings::setValue('cookie_box_button', $cookieBtn !== '' ? $cookieBtn : 'Continue', 'string');

        // Custom language picker — POST sends an array of checked codes under
        // <key>[] (or nothing when the picker is hidden). Filter against the
        // installed set so a stale browser tab can't sneak in unknown values.
        $posted = $_POST[LocaleHelper::LIST_KEY] ?? [];
        if (!is_array($posted)) {
            $posted = [];
        }
        $installed = array_flip(LocaleHelper::detectInstalled());
        $clean = array_values(array_unique(array_filter(
            array_map(static fn($code) => strtolower((string)$code), $posted),
            static fn($code) => $code !== '' && isset($installed[$code])
        )));
        Settings::setValue(LocaleHelper::LIST_KEY, $clean, 'json');

        // Sub-nav exception lists — page templatefiles that flip the global toggle.
        $orderKeys   = Template::ORDER_PAGES;
        $template    = AddonHelper::getTemplate();
        $websiteKeys = [];
        if ($template !== null) {
            foreach ($template->getPages() as $p) {
                if (!isset($orderKeys[$p])) { $websiteKeys[$p] = true; }
            }
        }
        $this->saveSubnavList('subnav_pages_order', $orderKeys);
        $this->saveSubnavList('subnav_pages_website', $websiteKeys);

        // Service-list-controls exception list — valid set is the fixed
        // SVC_LAYOUT_PAGES const (a listed page flips the global inside<->outside).
        $svcKeys = [];
        foreach (Template::SVC_LAYOUT_PAGES as $slug) { $svcKeys[$slug] = true; }
        $this->saveSubnavList('svc_layout_pages', $svcKeys);

        $this->saveOrderProcess();
    }

    /** Persist a sub-nav exception list, filtered to the given valid page set. */
    private function saveSubnavList(string $key, array $validSet): void
    {
        $posted = $_POST[$key] ?? [];
        if (!is_array($posted)) { $posted = []; }
        $clean = array_values(array_unique(array_filter(
            array_map('strval', $posted),
            static fn($p) => $p !== '' && isset($validSet[$p])
        )));
        Settings::setValue($key, $clean, 'json');
    }

    /** WHMCS system default language (lowercased), e.g. "english". */
    private function systemDefaultLanguage(): string
    {
        try {
            $lang = strtolower((string)\WHMCS\Config\Setting::getValue('Language'));
            return $lang !== '' ? $lang : 'english';
        } catch (\Throwable $e) {
            return 'english';
        }
    }

    /**
     * Product groups for the Order Process hide pickers.
     *
     * @return list<array{id:int,name:string}>
     */
    private function fetchProductGroups(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table('tblproductgroups')
                ->orderBy('order')->orderBy('name')->get(['id', 'name']);
            $out = [];
            foreach ($rows as $r) {
                $out[] = ['id' => (int)$r->id, 'name' => (string)$r->name];
            }
            return $out;
        } catch (\Throwable $e) {
            return [];
        }
    }

    /**
     * Persist the Lagom-parity Order Process settings (Configure Server step).
     *
     * Hide Nameservers / Hide Hostname store an enum (off|all|selected) plus a
     * json GID list — the runtime hides the fields when the value is 'all', or
     * 'selected' and the product's group is in the list. "All" stays "all" (not
     * frozen to current GIDs), so groups added later are still covered.
     * Custom-hostname + the two toggles round out the feature set. All inputs
     * are always present in the form (tab visibility is CSS-only), so reading
     * $_POST here works regardless of which tab the admin saved from.
     */
    private function saveOrderProcess(): void
    {
        $validGids = [];
        foreach ($this->fetchProductGroups() as $g) {
            $validGids[(string)$g['id']] = true;
        }

        foreach ([
            'op_hide_nameservers' => 'op_hide_nameservers_groups',
            'op_hide_hostname'    => 'op_hide_hostname_groups',
        ] as $modeKey => $groupsKey) {
            $enabled = isset($_POST[$modeKey . '_enabled']);
            $mode    = (string)($_POST[$modeKey . '_mode'] ?? 'all');
            if (!in_array($mode, ['all', 'selected'], true)) { $mode = 'all'; }
            Settings::setValue($modeKey, $enabled ? $mode : 'off', 'string');

            $posted = $_POST[$groupsKey] ?? [];
            if (!is_array($posted)) { $posted = []; }
            $clean = array_values(array_unique(array_filter(
                array_map('strval', $posted),
                static fn($id) => isset($validGids[$id])
            )));
            Settings::setValue($groupsKey, $clean, 'json');
        }

        // Use Custom Hostname (+ sub-fields). Interfix clamped 8-50, suffix
        // normalized with a leading dot (mirrors Lagom's SettingsProcessor).
        Settings::setValue('op_custom_hostname', isset($_POST['op_custom_hostname']) ? '1' : '0', 'bool');
        Settings::setValue('op_custom_hostname_prefix', trim((string)($_POST['op_custom_hostname_prefix'] ?? '')), 'string');

        $interfix = (int)($_POST['op_custom_hostname_interfix'] ?? 20);
        if ($interfix < 8)  { $interfix = 8; }
        if ($interfix > 50) { $interfix = 50; }
        Settings::setValue('op_custom_hostname_interfix', (string)$interfix, 'int');

        $suffix = trim((string)($_POST['op_custom_hostname_suffix'] ?? ''));
        if ($suffix !== '' && $suffix[0] !== '.') { $suffix = '.' . $suffix; }
        Settings::setValue('op_custom_hostname_suffix', $suffix, 'string');

        $chars = $_POST['op_custom_hostname_chars'] ?? [];
        if (!is_array($chars)) { $chars = []; }
        $chars = array_values(array_intersect(array_map('strval', $chars), ['upper', 'lower', 'numbers']));
        Settings::setValue('op_custom_hostname_chars', $chars, 'json');

        Settings::setValue('op_hide_hostname_checkout', isset($_POST['op_hide_hostname_checkout']) ? '1' : '0', 'bool');
        Settings::setValue('op_root_pw_strength', isset($_POST['op_root_pw_strength']) ? '1' : '0', 'bool');
    }
}
