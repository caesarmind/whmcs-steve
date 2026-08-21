{* Locale button - opens the language/currency modal. Wired up via
   [data-locale-open] in core-layout.js. The currency segment only renders
   when WHMCS has more than one active currency configured (or hasn't
   exposed $currencies on this page yet); single-currency installs get a
   language-only button. *}
{* Admin gating (Layouts -> Header). Language and currency hide independently;
   with both hidden there is nothing left to open, so the button is dropped
   entirely rather than rendered empty. *}
{assign var=mtLangOn value=(!$hadrian.addonSettings.hide_language_switcher)}
{assign var=mtCurrOn value=(!$hadrian.addonSettings.hide_currency_selector)}
{assign var=mtShowCurrencyInLocale value=($mtCurrOn && (!isset($currencies) || $currencies|@count > 1))}
{if $mtLangOn || $mtShowCurrencyInLocale}
<button type="button" class="locale-btn" aria-label="{$hadrianLang.common.localeChoose}" data-locale-open>
    <span class="flag">{$hadrian.localeFlag|default:'&#127482;&#127480;'}</span>
    {if $mtLangOn}
    {assign var=mtActiveLangKey value=$language|default:'english'|lower}
    <span>{if isset($hadrian.locales.nativeNames[$mtActiveLangKey])}{$hadrian.locales.nativeNames[$mtActiveLangKey]|escape}{else}{$language|default:'english'|capitalize}{/if}</span>
    {/if}
    {if $mtShowCurrencyInLocale}
    {if $mtLangOn}<span class="sep">/</span>{/if}
    <span>{if isset($activeCurrency.prefix) && $activeCurrency.prefix}{$activeCurrency.prefix|escape} {/if}{$activeCurrency.code|default:'USD'|escape}</span>
    {/if}
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
</button>
{/if}
