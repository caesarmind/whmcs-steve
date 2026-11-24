{* MarketConnect add-on landing page for WP Toolkit Deluxe (cPanel) and WP
   Toolkit with Smart Updates (Plesk) - WHMCS renders store/addon/
   wp-toolkit-cpanel.tpl / wp-toolkit-plesk.tpl, which include this with
   wptkPanel = 'cpanel' | 'plesk'. Ported from stock twenty-one (the two stock
   files differ only in copy, images and Plesk's Smart Updates block).

   Data, as stock: $clientServices[] {service, addon, addonPrice} (the logged-in
   client's eligible hosting), $firstMatchingAddon (for "starting from"),
   $ssoService (the service the client arrived from: pre-added to the cart),
   $hasPleskWptk / $hasCpanelWptk (the other edition is sold too),
   $browsePackagesAction, $addonSlug, $serviceId, $activeCurrency, $loggedin.
   The add-on cart posts servicemap = JSON {serviceId: addonId} to the
   store-add-addons route, exactly like stock; stock's jQuery is replaced by
   the plain script at the bottom. Copy is WHMCS's store.addon.wptk.* text. *}
{assign var=wk value=$wptkPanel}
{assign var=wkPlesk value=($wk == 'plesk')}
{assign var=wkImg value=$WEB_ROOT|cat:'/assets/img/store/wp-toolkit'}

<style>{literal}
.hn-wptk-wrap{max-width:var(--w-prose);margin:0 auto;padding:56px 22px}
.hn-wptk-wrap h2{text-align:center;margin:0 0 12px}
.hn-wptk-copy{color:var(--color-text-secondary);line-height:1.6;text-align:center;max-width:760px;margin:0 auto}
.hn-wptk-feature img{width:48px;height:48px;object-fit:contain;margin-bottom:12px}
.hn-wptk-shots{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;margin-top:24px}
.hn-wptk-shots a{display:block;border-radius:14px;overflow:hidden;border:.5px solid var(--color-border)}
.hn-wptk-shots img{display:block;width:100%;height:auto}
.hn-wptk-services{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px;margin:24px 0}
.hn-wptk-service{display:flex;flex-direction:column;gap:6px;padding:18px;border-radius:14px;background:var(--color-surface-secondary)}
.hn-wptk-service.in-cart{box-shadow:inset 0 0 0 2px var(--color-accent)}
.hn-wptk-service .hn-wptk-name{font-weight:var(--fw-semibold);color:var(--color-text-primary);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.hn-wptk-service .hn-wptk-domain{font-size:var(--text-sm);color:var(--color-text-secondary);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.hn-wptk-service .hn-wptk-price{font-size:var(--text-lg);font-weight:var(--fw-semibold);color:var(--color-text-primary);margin:6px 0}
.hn-wptk-cart{margin-top:8px;padding:20px;border-radius:14px;background:var(--color-surface)}
.hn-wptk-cart-item{display:flex;justify-content:space-between;align-items:center;gap:12px;padding:8px 0;border-bottom:.5px solid var(--color-border);font-size:var(--text-sm)}
.hn-wptk-cart-item button{border:0;background:transparent;color:var(--color-text-tertiary);cursor:pointer;font-size:var(--text-lg);line-height:1}
.hn-wptk-cart-total{display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;margin-top:14px;font-weight:var(--fw-semibold)}
.hn-wptk-faq{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:12px 32px}
.hn-wptk-faq details{padding:14px 0;border-top:.5px solid var(--color-border)}
.hn-wptk-faq summary{cursor:pointer;font-weight:var(--fw-semibold);color:var(--color-text-primary)}
.hn-wptk-faq p{margin:10px 0 0;color:var(--color-text-secondary);line-height:1.6}
{/literal}</style>

<div class="wp-toolkit">
    {* 1. Hero *}
    <section class="hp-hero-split" style="padding: 60px 22px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{if $wkPlesk}{lang key='store.addon.wptk.pleskTagline'}{else}{lang key='store.addon.wptk.redefined1'}{/if}</div>
            <h1>{if $wkPlesk}{lang key='store.addon.wptk.pleskTitle'}{else}{lang key='store.addon.wptk.redefined2'}{/if}</h1>
            <img src="{$wkImg}/{$wk}.png" alt="{if $wkPlesk}Plesk{else}cPanel{/if}" style="max-height:36px;width:auto;margin:4px 0 16px;">
            <div class="hp-cta-row"><a href="#pricing" class="hp-buy-btn">{lang key='store.addon.wptk.getItNow'}</a></div>
            {if !$wkPlesk && $hasPleskWptk}
                <p style="margin-top:14px;">{lang key='store.addon.wptk.switchPlesk'} <a href="{fqdnRoutePath('store-addon', 'plesk-wordpress-toolkit-with-smart-updates')}">{lang key='clickHere'}</a></p>
            {elseif $wkPlesk && $hasCpanelWptk}
                <p style="margin-top:14px;">{lang key='store.addon.wptk.switchCpanel'} <a href="{fqdnRoutePath('store-addon', 'wp-toolkit-deluxe')}">{lang key='clickHere'}</a></p>
            {/if}
        </div>
        <div class="hp-split-visual">
            <img src="{$wkImg}/feature-laptop{if $wkPlesk}-plesk{/if}.png" alt="" style="max-width:100%;height:auto;">
        </div>
    </section>

    {* 2. Intro *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <h2 style="text-align:left;">{if $wkPlesk}{lang key='store.addon.wptk.pleskIntroTitle'}{else}{lang key='store.addon.wptk.introTitle'}{/if}</h2>
                <p>{if $wkPlesk}{lang key='store.addon.wptk.pleskIntroBody'}{else}{lang key='store.addon.wptk.introBody'}{/if}</p>
            </div>
            <div class="hp-alt-visual"><img src="{$wkImg}/graphic{if $wkPlesk}-plesk{/if}.png" alt="" style="max-width:100%;height:auto;"></div>
        </div>
    </div>

    {* 3. Smart Updates (Plesk edition only) *}
    {if $wkPlesk}
    <section class="hn-wptk-wrap">
        <div class="hp-feature-cards" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;">
            {foreach [['how',1],['safe',2],['unsafe',3]] as $su}
            <div class="hp-feature-card hn-wptk-feature">
                <img src="{$wkImg}/icon-{$su[0]}.png" alt="">
                <h4>{lang key="store.addon.wptk.smartUpdates.featureTitle`$su[1]`"}</h4>
                <p>{lang key="store.addon.wptk.smartUpdates.featureBody`$su[1]`"}</p>
            </div>
            {/foreach}
        </div>
    </section>
    {/if}

    {* 4. Features *}
    <section class="hp-features-section" style="padding: 56px 22px;">
        <h2 style="text-align:center;margin:0 0 28px;">{lang key='store.addon.wptk.midTitle1' breaktag=''}</h2>
        <div class="hp-feature-cards" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;max-width:var(--w-prose);margin:0 auto;">
            {foreach ['create','experiment','security','updates','cloning','maintenance'] as $fIcon}
            {assign var=fN value=$fIcon@iteration}
            <div class="hp-feature-card hn-wptk-feature">
                <img src="{$wkImg}/icon-{$fIcon}.png" alt="">
                {if $wkPlesk}
                    <h4>{lang key="store.addon.wptk.plesk.featureTitle`$fN`"}</h4>
                    <p>{lang key="store.addon.wptk.plesk.featureBody`$fN`"}</p>
                {else}
                    <h4>{lang key="store.addon.wptk.featureTitle`$fN`"}</h4>
                    <p>{lang key="store.addon.wptk.featureBody`$fN`"}</p>
                {/if}
            </div>
            {/foreach}
        </div>
    </section>

    {* 5. Screenshots *}
    <section class="hn-wptk-wrap">
        <h2>{lang key='store.addon.wptk.midTitle2'}</h2>
        <p class="hn-wptk-copy">
            {if $firstMatchingAddon && !$firstMatchingAddon->pricing()->first()->isFree()}
                {if $wkPlesk}{lang key='store.addon.wptk.smartUpdates.screenshotDesc' price=$firstMatchingAddon->pricing()->first()->price()}{else}{lang key='store.addon.wptk.screenshotDesc' price=$firstMatchingAddon->pricing()->first()->price()}{/if}
            {else}
                {if $wkPlesk}{lang key='store.addon.wptk.smartUpdates.screenshotDescFree'}{else}{lang key='store.addon.wptk.screenshotDescFree'}{/if}
            {/if}
        </p>
        <div class="hn-wptk-shots">
            {foreach ['01','02','03','04'] as $shot}
                <a href="{$wkImg}/screen-{$shot}-full.png" target="_blank" rel="noopener"><img src="{$wkImg}/screen-{$shot}.png" alt="WP Toolkit"></a>
            {/foreach}
        </div>
    </section>

    {* 6. Pricing / add-on cart *}
    <section class="hn-wptk-wrap" id="pricing">
        {if $loggedin && count($clientServices)}
            <h2>{if $wkPlesk}{lang key='store.addon.wptk.smartUpdates.getStartedToday'}{else}{lang key='store.addon.wptk.getStartedToday'}{/if}</h2>
            <p class="hn-wptk-copy">{lang key='store.addon.wptk.chooseDomains'}</p>
            <div class="hn-wptk-services">
                {foreach $clientServices as $service}
                <div class="hn-wptk-service" data-hn-wptk-service="{$service['service']->id}">
                    <span class="hn-wptk-name">{$service['service']->product->name}</span>
                    <span class="hn-wptk-domain">{$service['service']->domain}</span>
                    {if $service['addon']}
                        <span style="font-size:var(--text-sm);color:var(--color-text-secondary);">{lang key='store.addon.wptk.addAddonFor' addon={$service['addon']->name}}</span>
                        <span class="hn-wptk-price">{if $service['addon']->isFree()}{lang key='orderfree'}{else}{$service['addonPrice']->price()}{($service['addon']->isOneTime()) ? '' : "/{$service['addonPrice']->getShortCycle()}"}{/if}</span>
                        <button type="button" class="btn-primary" data-hn-wptk-add
                                data-product-name="{$service['addon']->name|escape}"
                                data-serviceid="{$service['service']->id}"
                                data-addonid="{$service['addon']->id}"
                                data-domain-name="{$service['service']->domain|escape}"
                                data-price="{$service['addonPrice']->price()->toNumeric()}">{lang key='addtocart'}</button>
                    {else}
                        <span style="font-size:var(--text-sm);color:var(--color-text-tertiary);">{lang key='store.addon.wptk.unavailable'}</span>
                        <button type="button" class="btn-secondary" disabled>{lang key='addtocart'}</button>
                    {/if}
                </div>
                {/foreach}
            </div>
            <div class="hn-wptk-cart" id="hnWptkCart" hidden>
                <form method="post" data-role="cart-form" action="{fqdnRoutePath('store-add-addons')}">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <input type="hidden" name="servicemap" value="">
                    <div id="hnWptkCartItems"></div>
                    <div class="hn-wptk-cart-total">
                        <span>{lang key='store.addon.wptk.totalInCart'} {$activeCurrency->prefix}<span id="hnWptkTotal">0.00</span></span>
                        <button type="submit" class="hp-buy-btn">{lang key='store.addon.wptk.proceedToCheckout'}</button>
                    </div>
                </form>
            </div>
            <template id="hnWptkItemTpl"><div class="hn-wptk-cart-item"><span><strong class="product-name"></strong> {lang key='store.addon.wptk.for'} <span class="domain-name"></span></span><span>{$activeCurrency->prefix}<span class="price"></span> <button type="button" aria-label="{lang key='cartremove'}">&times;</button></span></div></template>
            <script>
                var hnWptkSso = {if $ssoService}{$ssoService->id}{else}0{/if};
            </script>
            <script>{literal}
            (function () {
                var cart = document.getElementById('hnWptkCart');
                if (!cart) return;
                var items = document.getElementById('hnWptkCartItems');
                var totalEl = document.getElementById('hnWptkTotal');
                var field = cart.querySelector('input[name="servicemap"]');
                var tpl = document.getElementById('hnWptkItemTpl');
                var map = {}, total = 0;
                var sync = function () {
                    field.value = JSON.stringify(map);
                    totalEl.textContent = total.toFixed(2);
                    cart.hidden = Object.keys(map).length === 0;
                };
                var add = function (btn) {
                    var sid = btn.getAttribute('data-serviceid');
                    if (map[sid]) return;
                    map[sid] = btn.getAttribute('data-addonid');
                    var price = parseFloat(btn.getAttribute('data-price')) || 0;
                    total += price;
                    var row = tpl.content.firstElementChild.cloneNode(true);
                    row.querySelector('.product-name').textContent = btn.getAttribute('data-product-name');
                    row.querySelector('.domain-name').textContent = btn.getAttribute('data-domain-name');
                    row.querySelector('.price').textContent = price.toFixed(2);
                    row.querySelector('button').addEventListener('click', function () {
                        delete map[sid];
                        total -= price;
                        row.parentNode.removeChild(row);
                        var card = document.querySelector('[data-hn-wptk-service="' + sid + '"]');
                        if (card) card.classList.remove('in-cart');
                        btn.disabled = false;
                        sync();
                    });
                    items.appendChild(row);
                    var card = document.querySelector('[data-hn-wptk-service="' + sid + '"]');
                    if (card) card.classList.add('in-cart');
                    btn.disabled = true;
                    sync();
                };
                document.querySelectorAll('[data-hn-wptk-add]').forEach(function (btn) {
                    btn.addEventListener('click', function () { add(btn); });
                });
                if (window.hnWptkSso) {
                    var pre = document.querySelector('[data-hn-wptk-add][data-serviceid="' + window.hnWptkSso + '"]');
                    if (pre) add(pre);
                }
            })();
            {/literal}</script>
        {else}
            {if $firstMatchingAddon && !$firstMatchingAddon->pricing()->first()->isFree()}
                <h2>{lang key='startingfrom'} {$firstMatchingAddon->pricing()->first()->price()}/{$firstMatchingAddon->pricing()->first()->getShortCycle()}</h2>
            {/if}
            {if !$loggedin}<p class="hn-wptk-copy">{lang key='store.addon.wptk.loginToSeePricing'}</p>{/if}
            <form method="post" action="{$browsePackagesAction}" style="display:flex;flex-wrap:wrap;justify-content:center;gap:12px;margin-top:20px;">
                {if !$loggedin}
                    <a href="{routePath('store-addon-login', $addonSlug, $serviceId)}" class="hp-buy-btn">{lang key='store.addon.wptk.loginNow'}</a>
                {/if}
                <button type="submit" class="btn-secondary">{lang key='store.addon.wptk.browsePackages'}</button>
            </form>
        {/if}
    </section>

    {* 7. FAQ *}
    <section class="hn-wptk-wrap">
        <div class="hn-wptk-faq">
            {if $wkPlesk}
                {assign var=wkFaqs value=[1,3,6]}
            {else}
                {assign var=wkFaqs value=[1,2,3,4,5]}
            {/if}
            {foreach $wkFaqs as $q}
                <details>
                    <summary>{lang key="store.addon.wptk.faqQ`$q`"}</summary>
                    <p>{lang key="store.addon.wptk.faqA`$q`" webRoot=$WEB_ROOT}</p>
                </details>
            {/foreach}
        </div>
    </section>
</div>
