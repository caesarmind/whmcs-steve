{* Locale button - opens the language/currency modal. Wired up via
   [data-locale-open] in apple-layout.js. Falls back to English/USD when
   the page doesn't expose $language or $activeCurrency. *}
<button type="button" class="locale-btn" aria-label="Choose language and currency" data-locale-open>
    <span class="flag">{$myTheme.localeFlag|default:'&#127482;&#127480;'}</span>
    <span>{$language|default:'english'|capitalize}</span>
    <span class="sep">/</span>
    <span>{if isset($activeCurrency.prefix) && $activeCurrency.prefix}{$activeCurrency.prefix|escape} {/if}{$activeCurrency.code|default:'USD'|escape}</span>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>
</button>
