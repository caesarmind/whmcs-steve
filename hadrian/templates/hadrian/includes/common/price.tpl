{*
    "0.00" -> "Free" price display.

    Renders a WHMCS pre-formatted money string, swapping in the localized
    "Free" label when the admin's `free_label` flag is on AND the amount is
    zero. Templates that print a price call this instead of echoing the
    variable directly:

        {include file="`$template`/includes/common/price.tpl" hPrice=$product.recurringamount}

    Params:
      hPrice    (required) the pre-formatted money string, e.g. "$0.00"
      hEscape   (optional) escape the price on output; default true. Pass
                false only for values WHMCS already escaped.

    Emits NO surrounding whitespace, so it is safe inside inline elements
    whose text content is read by JS. That is also why this file has no
    trailing newline - Smarty would emit it.

    Why a digits-only test rather than Lagom's string equality:
    Lagom strips the currency prefix/suffix + spaces and compares against the
    exact literals "0.00"/"0,00", which misses three-decimal currencies
    (0.000 - BHD, KWD), &nbsp; separators and "-0.00". Here every non-digit is
    stripped and the remainder is "free" only when it is all zeros, so all of
    those resolve correctly regardless of locale or currency formatting.

    Fails SAFE in both directions: a string with no digits at all (e.g. "-")
    is not free, and anything not provably zero renders as the normal price.
    The PHP twin used by the AJAX tables is Hadrian\Helpers\PriceHelper, and
    hadrian/scripts/check-free-price.mjs asserts the two agree.
*}
{assign var=hPriceDigits value=$hPrice|regex_replace:'/[^0-9]/':''}{assign var=hPriceNonZero value=$hPriceDigits|regex_replace:'/0/':''}{if $hadrian.addonSettings.free_label|default:false && $hPriceDigits ne '' && $hPriceNonZero eq ''}{$LANG.orderfree|default:'Free'}{else}{if $hEscape|default:true}{$hPrice|escape}{else}{$hPrice}{/if}{/if}