{*
    "0.00" -> "Free" for the order form. The cart's ONE price partial —
    self-contained: no includes from the client theme (a $template include
    would resolve against the ACTIVE System Theme and fatal whenever
    hadrian_cart runs under six/twenty-one), no reliance on theme CSS.

    Two render modes, picked by what this request has available:

    1. $hadrian.addonSettings present (every full-page cart render — the
       addon's ClientAreaPage hook assigns it under ANY system theme):
       plain server-side swap. Zero + flag on -> the localized label;
       otherwise the price string exactly as before, no wrapper markup.

    2. $hadrian absent (the ordersummary.tpl fragment re-rendered by
       recalctotals() outside the hook flow): Lagom-style always-emit —
       both a .hn-free-label and the numeric .hn-free-amt span for a zero
       amount, and css/custom.css picks one based on the data-free-label
       attribute the hadrian theme's header.tpl stamps on <body> (the attr
       survives every AJAX refresh). Under a non-hadrian theme the attr is
       absent, so the label stays hidden and the numeric amount shows —
       fail-safe in the exact configuration mode 1 cannot crash in either.

    Zero detection is the digits-only test shared with the theme's
    includes/common/price.tpl and the PriceHelper PHP twin: strip every
    non-digit, free only when the non-empty remainder is all zeros.

    Params:
      hnPrice  (required) the pre-formatted money string, e.g. "$0.00 USD".
               Printed raw, matching how the cart printed it before.
*}
{assign var=hnPriceDigits value=$hnPrice|regex_replace:'/[^0-9]/':''}{assign var=hnPriceNonZero value=$hnPriceDigits|regex_replace:'/0/':''}{assign var=hnPriceIsZero value=false}{if $hnPriceDigits ne '' && $hnPriceNonZero eq ''}{assign var=hnPriceIsZero value=true}{/if}{if isset($hadrian.addonSettings)}{if $hnPriceIsZero && $hadrian.addonSettings.free_label|default:false}{$LANG.orderfree|default:'Free'}{else}{$hnPrice}{/if}{elseif $hnPriceIsZero}<span class="hn-free-label">{$LANG.orderfree|default:'Free'}</span><span class="hn-free-amt">{$hnPrice}</span>{else}{$hnPrice}{/if}