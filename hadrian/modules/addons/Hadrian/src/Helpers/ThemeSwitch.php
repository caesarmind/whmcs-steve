<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Configuration;

/**
 * Turns Hadrian on for the whole site, and back off again.
 *
 * "On" is two rows in tblconfiguration: `Template` (the client area) and
 * `OrderFormTemplate` (the order form). They are the same rows General
 * Settings writes, so the two screens always agree. The change applies from
 * the next request; nothing about the current one is touched.
 *
 * Before changing a row this remembers what it held, so the Setup page can
 * offer a way back. It only remembers a value that is not Hadrian's own, and
 * switching back only touches a row that still points at Hadrian: an admin who
 * has since picked something else in General Settings keeps their pick.
 */
final class ThemeSwitch
{
    public const THEME = 'hadrian';
    public const CART  = 'hadrian_cart';

    private const PREV_THEME = 'hadrian_setup_prev_template';
    private const PREV_CART  = 'hadrian_setup_prev_orderform';

    /** @return array{template:string,orderform:string,prev_template:string,prev_orderform:string} */
    public static function state(): array
    {
        return [
            'template'       => (string)Configuration::getValue('Template'),
            'orderform'      => (string)Configuration::getValue('OrderFormTemplate'),
            'prev_template'  => (string)Configuration::getValue(self::PREV_THEME),
            'prev_orderform' => (string)Configuration::getValue(self::PREV_CART),
        ];
    }

    /** @param bool $withCart also switch the order form (only when its folder is uploaded) */
    public static function goLive(bool $withCart): void
    {
        $now = self::state();

        if ($now['template'] !== self::THEME) {
            if ($now['template'] !== '') {
                Configuration::setValue(self::PREV_THEME, $now['template']);
            }
            Configuration::setValue('Template', self::THEME);
        }

        if ($withCart && $now['orderform'] !== self::CART) {
            if ($now['orderform'] !== '') {
                Configuration::setValue(self::PREV_CART, $now['orderform']);
            }
            Configuration::setValue('OrderFormTemplate', self::CART);
        }
    }

    /**
     * Put back what goLive() replaced.
     *
     * @param string $root the WHMCS root, to check the old theme is still there
     * @return string|null why nothing was changed, or null when it worked
     */
    public static function switchBack(string $root): ?string
    {
        $now  = self::state();
        $root = rtrim($root, '/\\');

        if ($now['prev_template'] === '' && $now['prev_orderform'] === '') {
            return 'There is no earlier theme on record to switch back to. Pick one in General Settings.';
        }

        // Check both before changing either, so a missing folder never leaves
        // the client area on one theme and the order form on another.
        if ($now['prev_template'] !== '' && !is_dir($root . '/templates/' . $now['prev_template'])) {
            return 'The earlier theme "' . $now['prev_template'] . '" is no longer in templates/. Pick a theme in General Settings.';
        }
        if ($now['prev_orderform'] !== '' && !is_dir($root . '/templates/orderforms/' . $now['prev_orderform'])) {
            return 'The earlier order form "' . $now['prev_orderform'] . '" is no longer in templates/orderforms/. Pick one in General Settings.';
        }

        if ($now['prev_template'] !== '') {
            if ($now['template'] === self::THEME) {
                Configuration::setValue('Template', $now['prev_template']);
            }
            Configuration::deleteValue(self::PREV_THEME);
        }
        if ($now['prev_orderform'] !== '') {
            if ($now['orderform'] === self::CART) {
                Configuration::setValue('OrderFormTemplate', $now['prev_orderform']);
            }
            Configuration::deleteValue(self::PREV_CART);
        }
        return null;
    }
}
