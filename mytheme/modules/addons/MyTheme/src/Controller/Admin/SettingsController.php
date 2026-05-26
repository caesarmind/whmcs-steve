<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\LocaleHelper;
use MyTheme\Models\Settings;
use MyTheme\Template\Template;

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
        'custom_logo_url'        => ['Custom Logo URL',          'Send the visitor to this URL when clicking the logo.',                   false, 'bool'],
        'sticky_sidebars'        => ['Sticky Sidebars',          'Keep sidebars visible while scrolling.',                                  true,  'bool'],
        'gravatar'               => ['Gravatar',                 'Show Gravatar avatars next to user details.',                            true,  'bool'],
        'affixed_navigation'     => ['Affixed Navigation',       'Pin the navbar on scroll.',                                              false, 'bool'],
        'cookie_box'             => ['Cookie Box',               'Show a cookie consent banner on first visit.',                          false, 'bool'],
        'free_label'             => ['"0.00" → "Free"',          'Display free items as "Free" instead of "$0.00".',                       true,  'bool'],
        'show_status_icon'       => ['Show Status Icon',         'Use status icons in product/service lists.',                            false, 'bool'],
        'table_cache_duration'   => ['Table Cache Duration',     'Cache rendered tables to reduce DB load.',                              true,  'bool'],
        'show_client_id'         => ['Show Client ID',           "Display the client's numeric ID in their account dropdown.",            false, 'bool'],
        'enable_alternate_links' => ['Enable Alternate Links',   'Add SEO multi-language alternate links.',                               true,  'bool'],
        'capitalize_titles'      => ['Section Titles Capitalization', 'Apply uppercase to section titles.',                                 true,  'bool'],
        'disable_cms_cache'      => ['Disable CMS Menu Cache',   'Bypass the menu cache during development.',                             false, 'bool'],
        'hide_cycle_discounts'   => ['Hide Billing Cycle Discounts', 'Hide percentage savings shown next to billing cycles.',              false, 'bool'],
        'enable_dynamic_ajax'    => ['Enable Dynamic AJAX Loading',  'Load some panels via AJAX after the page paints.',                   true,  'bool'],
        'custom_language_list'   => ['Custom Language List',     'Override the language list shown to clients in the locale chooser.',    false, 'bool'],
        'enable_dark_mode'       => ['Enable Dark Mode',         'Allow visitors to toggle dark mode.',                                   true,  'bool'],
        'topnav_show_icons'      => ['Top-Nav Icons',            'Show icons next to menu items in the top navigation. Off by default.',  false, 'bool'],
        'cart_subnav'            => ['Order Category Sidebar',   'Show the Categories / Actions sidebar on order (cart) pages.',          true,  'bool'],
        'website_subnav'         => ['Website Section Sidebar',  'Show the per-page section sub-nav (Account, Domain Tools, etc.) on client-area pages.', true, 'bool'],
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

        return $this->view('settings/index', [
            'flags'              => self::FLAGS,
            'flagTabs'           => self::FLAG_TABS,
            'values'             => $values,
            'darkModeDisplay'    => (string)Settings::getValue('dark_mode_display', 'switcher'),
            'darkModeDefault'    => (string)Settings::getValue('dark_mode_default', 'light'),
            'tab'                => $_GET['tab'] ?? 'general',
            'installedLanguages' => $installedLanguages,
            'selectedLanguages'  => $selectedLanguages,
            'langListKey'        => LocaleHelper::LIST_KEY,
            'orderPages'         => $orderPages,
            'websitePages'       => $websitePages,
            'subnavOrderList'    => $subnavOrderList,
            'subnavWebsiteList'  => $subnavWebsiteList,
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
}
