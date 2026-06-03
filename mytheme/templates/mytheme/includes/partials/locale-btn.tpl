{* Locale button - opens the language/currency modal. Wired up via
   [data-locale-open] in apple-layout.js. The currency segment only renders
   when WHMCS has more than one active currency configured (or hasn't
   exposed $currencies on this page yet); single-currency installs get a
   language-only button. *}
{assign var=mtShowCurrencyInLocale value=(!isset($currencies) || $currencies|@count > 1)}
<button type="button" class="locale-btn" aria-label="{$hadrianLang.common.localeChoose}" data-locale-open>
    <span class="flag">{$myTheme.localeFlag|default:'&#127482;&#127480;'}</span>
    <span>{$language|default:'english'|capitalize}</span>
    {if $mtShowCurrencyInLocale}
    <span class="sep">/</span>
    <span>{if isset($activeCurrency.prefix) && $activeCurrency.prefix}{$activeCurrency.prefix|escape} {/if}{$activeCurrency.code|default:'USD'|escape}</span>
    {/if}
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
</button>
