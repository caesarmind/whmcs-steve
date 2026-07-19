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
        // Default OFF deliberately: the runtime (PriceHelper / price.tpl) treats
        // unset as off, so a `true` here would render the box pre-checked while
        // nothing actually changed until the admin pressed Save. Opt-in also
        // means deploying this never silently relabels prices on a live install.
        'free_label'             => ['"0.00" → "Free"',          'Display free items as "Free" instead of "$0.00".',                       false, 'bool'],
        'enable_alternate_links' => ['Enable Alternate Links',   'Add SEO multi-language alternate links.',                               true,  'bool'],
        // Scope spelled out: this covers marketing/store section labels only,
        // NOT client-area table headers or sidebar labels (see apple-layout.css).
        // Lagom scopes its equivalent the same way.
        'capitalize_titles'      => ['Section Titles Capitalization', 'Uppercase the eyebrows, tags and tier labels on homepage and store pages. Client-area table headings and sidebar labels are unaffected.', true,  'bool'],
        'hide_cycle_discounts'   => ['Hide Billing Cycle Discounts', 'Hide the "Save X%" pills shown next to the billing cycle choices when configuring a product.', false, 'bool'],
        'enable_dynamic_ajax'    => ['Enable Dynamic AJAX Loading',  'Load data tables (services, domains, invoices, tickets, quotes, emails) in pages of 10 via AJAX — fast first paint on large accounts.', false, 'bool'],
        'custom_language_list'   => ['Custom Language List',     'Override the language list shown to clients in the locale chooser.',    false, 'bool'],
        'enable_dark_mode'       => ['Enable Dark Mode',         'Allow visitors to toggle dark mode.',                                   true,  'bool'],
        'topnav_show_icons'      => ['Top-Nav Icons',            'Show icons next to menu items in the top navigation. Off by default.',  false, 'bool'],
        'cart_subnav'            => ['Order Category Sidebar',   'Show the Categories / Actions sidebar on order (cart) pages.',          true,  'bool'],
        'website_subnav'         => ['Website Section Sidebar',  'Show the per-page section sub-nav (Account, Domain Tools, etc.) on client-area pages.', true, 'bool'],
        'service_controls_outside' => ['Service List Controls', 'Float search & pagination outside the white card on list pages (services, invoices, domains, etc.). Off keeps them inside the card.', false, 'bool'],
    ];

    /** Which Settings tab each flag renders on. Unlisted flags default to 'general'. */
    public const FLAG_TABS = [
        'cart_subnav' => 'order',
    ];

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
            'flags'              => self::FLAGS,
            'flagTabs'           => self::FLAG_TABS,
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
        foreach (self::FLAGS as $key => [, , , $type]) {
            // Posted as 'on' when checked, missing when unchecked
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
