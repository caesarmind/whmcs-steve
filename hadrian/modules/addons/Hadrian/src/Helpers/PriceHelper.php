<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Settings;

/**
 * "0.00" -> "Free" price display (admin Settings flag `free_label`).
 *
 * Single source of truth for the SERVER-rendered paths — today that's the
 * AJAX data tables (TableData::fmtMoney), which hold the raw numeric amount
 * and so can decide numerically rather than by string comparison.
 *
 * Lagom does this by string-matching the *formatted* price against the exact
 * literals "0.00"/"0,00" after stripping the currency prefix/suffix and
 * spaces (lagom2-theme/includes/common/price.tpl), duplicated inline across
 * ~10 templates plus a JS copy in the services table. That misses three-
 * decimal currencies (0.000 — BHD, KWD), &nbsp; separators and "-0.00", and
 * the copies can drift. Deciding on the number avoids all of it.
 *
 * The Smarty side can't reach PHP, so it re-does the test on the formatted
 * string — with a digits-only match rather than an equality check, failing
 * SAFE: anything not provably zero renders as the normal price. Two partials,
 * one per tree: the theme's includes/common/price.tpl (client-area pages),
 * and hadrian_cart/includes/free-price.tpl (every order-form price — the
 * cart deliberately never includes the theme partial, since a $template
 * include resolves against the ACTIVE System Theme and would fatal under
 * six/twenty-one). The cart partial reads the flag from
 * $hadrian.addonSettings when present; in the AJAX-rendered ordersummary
 * fragment, where it isn't, it always emits label+amount spans and
 * hadrian_cart/css/custom.css picks one off body[data-free-label].
 */
final class PriceHelper
{
    /** Setting key for the toggle (admin Settings -> General). */
    public const FLAG = 'free_label';

    /** Fallback when WHMCS has no `orderfree` string loaded. */
    private const FALLBACK_LABEL = 'Free';

    /**
     * Is the "0.00" -> "Free" display enabled?
     *
     * Reads the stored value directly rather than through a defaults-to-true
     * helper: unset must mean OFF here, so an install that has never opened
     * the Settings screen doesn't silently start relabelling prices.
     */
    public static function enabled(): bool
    {
        $raw = Settings::getValue(self::FLAG, '0');
        return $raw === '1' || $raw === 1 || $raw === true;
    }

    /**
     * Does this amount represent no charge?
     *
     * Accepts a float/int (the raw amount) or a formatted money string. For
     * strings, every non-digit is stripped — currency symbols, entities,
     * thousands separators, decimal points, minus signs, spaces — and the
     * remainder is "free" only when it is all zeros. So "$0.00", "0,00",
     * "0.000" and "-0.00" are free; "$0.01" and "$10.00" are not.
     *
     * A string carrying no digit at all (e.g. "-", "N/A", "") is NOT treated
     * as free — there's no price there to relabel.
     */
    public static function isFree(mixed $price): bool
    {
        if (is_int($price) || is_float($price)) {
            return abs((float)$price) < 0.0000001;
        }

        $digits = preg_replace('/\D/', '', (string)$price);
        if (!is_string($digits) || $digits === '') {
            return false;
        }
        return trim($digits, '0') === '';
    }

    /**
     * The localized "Free" label. Uses WHMCS's own `orderfree` string (the
     * key Lagom uses too) so it follows the visitor's language, and falls
     * back to English rather than rendering blank.
     */
    public static function label(): string
    {
        $lang = $GLOBALS['_LANG'] ?? [];
        if (is_array($lang) && !empty($lang['orderfree']) && is_string($lang['orderfree'])) {
            return $lang['orderfree'];
        }
        return self::FALLBACK_LABEL;
    }

    /**
     * Convenience for the server-rendered paths: the label when the flag is
     * on and the amount is zero, otherwise the already-formatted price
     * unchanged.
     */
    public static function display(mixed $rawAmount, string $formatted): string
    {
        if (self::enabled() && self::isFree($rawAmount)) {
            return self::label();
        }
        return $formatted;
    }
}
