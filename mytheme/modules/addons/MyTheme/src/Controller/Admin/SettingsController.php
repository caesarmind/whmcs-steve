<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Models\Settings;

final class SettingsController extends AbstractController
{
    /**
     * Available settings — used by the view to render the toggle list and by save() to validate keys.
     * Each entry: [label, help, default, type ('bool'|'string'|'int')]
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
        'custom_language_list'   => ['Custom Language List',     'Override the language list shown to clients.',                          false, 'bool'],
        'enable_dark_mode'       => ['Enable Dark Mode',         'Allow visitors to toggle dark mode.',                                   true,  'bool'],
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

        return $this->view('settings/index', [
            'flags'  => self::FLAGS,
            'values' => $values,
            'tab'    => $_GET['tab'] ?? 'general',
        ]);
    }

    private function save(): void
    {
        foreach (self::FLAGS as $key => [, , , $type]) {
            // Posted as 'on' when checked, missing when unchecked
            $val = isset($_POST[$key]) ? true : false;
            Settings::setValue($key, $val ? '1' : '0', $type);
        }
    }
}
