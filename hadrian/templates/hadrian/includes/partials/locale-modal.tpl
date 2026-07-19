{* Language + currency modal - opened by any [data-locale-open] button on the
   page; wiring is in apple-layout.js. Included once from footer.tpl so it lives
   outside any per-page wrapper. The language/currency lists fall back to a
   static set when the page doesn't expose $languages / $currencies; the .active
   class tracks the current selection. *}
<div class="locale-modal" id="localeModal" role="dialog" aria-modal="true" aria-labelledby="localeModalTitle" data-current-lang="{$language|default:''|escape}" data-current-currency-id="{$activeCurrency.id|default:''|escape}">
    <div class="locale-modal-panel">
        <div class="locale-modal-header">
            <h3 id="localeModalTitle">{$hadrianLang.common.localeChoose}</h3>
            <button type="button" class="locale-modal-close" id="localeModalClose" aria-label="{$LANG.close}">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
            </button>
        </div>
        <div class="locale-modal-body">
            {* Prefer the admin-curated list from Hadrian.locales.languages when
               available; fall back to WHMCS's $languages, then to a static set
               for pages where neither is populated. *}
            {if isset($hadrian.locales.languages) && $hadrian.locales.languages|@count > 0}
                {assign var=mtLangList value=$hadrian.locales.languages}
            {elseif isset($languages) && $languages|@count > 0}
                {assign var=mtLangList value=$languages}
            {else}
                {assign var=mtLangList value=[]}
            {/if}
            {* Admin gating (Layouts -> Header), mirroring locale-btn.tpl. *}
            {if !$hadrian.addonSettings.hide_language_switcher}
            <div class="locale-modal-section-label">{$LANG.chooselanguage}</div>
            <div class="locale-grid" role="radiogroup" aria-label="{$LANG.chooselanguage}">
                {if $mtLangList|@count > 0}
                    {foreach $mtLangList as $lang}
                        <button type="button" data-lang="{$lang|escape}"{if isset($language) && $language == $lang} class="active"{/if}>{$lang|escape|capitalize}</button>
                    {/foreach}
                {else}
                    <button type="button" data-lang="arabic">&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;</button>
                    <button type="button" data-lang="azerbaijani">Azerbaijani</button>
                    <button type="button" data-lang="catalan">Catal&agrave;</button>
                    <button type="button" data-lang="chinese">&#20013;&#25991;</button>
                    <button type="button" data-lang="croatian">Hrvatski</button>
                    <button type="button" data-lang="czech">&Ccaron;e&scaron;tina</button>
                    <button type="button" data-lang="danish">Dansk</button>
                    <button type="button" data-lang="dutch">Nederlands</button>
                    <button type="button" data-lang="english"{if !isset($language) || $language == 'english'} class="active"{/if}>English</button>
                    <button type="button" data-lang="estonian">Estonian</button>
                    <button type="button" data-lang="farsi">Persian</button>
                    <button type="button" data-lang="french">Fran&ccedil;ais</button>
                    <button type="button" data-lang="german">Deutsch</button>
                    <button type="button" data-lang="hebrew">&#1506;&#1489;&#1512;&#1497;&#1514;</button>
                    <button type="button" data-lang="hungarian">Magyar</button>
                    <button type="button" data-lang="italian">Italiano</button>
                    <button type="button" data-lang="macedonian">Macedonian</button>
                    <button type="button" data-lang="norwegian">Norwegian</button>
                    <button type="button" data-lang="portuguese-br">Portugu&ecirc;s (BR)</button>
                    <button type="button" data-lang="portuguese">Portugu&ecirc;s</button>
                    <button type="button" data-lang="romanian">Rom&acirc;n&abreve;</button>
                    <button type="button" data-lang="russian">&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;</button>
                    <button type="button" data-lang="spanish">Espa&ntilde;ol</button>
                    <button type="button" data-lang="swedish">Svenska</button>
                    <button type="button" data-lang="turkish">T&uuml;rk&ccedil;e</button>
                    <button type="button" data-lang="ukrainian">&#1059;&#1082;&#1088;&#1072;&#1111;&#1085;&#1089;&#1100;&#1082;&#1072;</button>
                {/if}
            </div>
            {/if}
            {* Currency section hides entirely when the WHMCS install has a single
               currency configured. We keep it visible when $currencies isn't
               populated on a page so the modal still feels complete. The admin
               toggle is an additional gate on top of that. *}
            {if !$hadrian.addonSettings.hide_currency_selector && (!isset($currencies) || $currencies|@count > 1)}
            <div class="locale-modal-section-label">{$LANG.choosecurrency}</div>
            <div class="locale-grid" role="radiogroup" aria-label="{$LANG.choosecurrency}">
                {if isset($currencies) && $currencies|@count > 0}
                    {foreach $currencies as $cur}
                        <button type="button" data-currency="{$cur.code|lower|escape}" data-currency-id="{$cur.id|escape}"{if isset($activeCurrency.id) && isset($cur.id) && $activeCurrency.id == $cur.id} class="active"{/if}>{$cur.prefix|default:''|escape} {$cur.code|escape}</button>
                    {/foreach}
                {else}
                    <button type="button" data-currency="usd" class="active">$ USD</button>
                    <button type="button" data-currency="eur">&euro; EUR</button>
                    <button type="button" data-currency="gbp">&pound; GBP</button>
                    <button type="button" data-currency="cad">$ CAD</button>
                    <button type="button" data-currency="aud">$ AUD</button>
                    <button type="button" data-currency="jpy">&yen; JPY</button>
                {/if}
            </div>
            {/if}
        </div>
        <div class="locale-modal-footer">
            <button type="button" class="apply" id="localeApply">{$LANG.apply}</button>
        </div>
    </div>
</div>
