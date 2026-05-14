{*
 * mytheme_cart/products.tpl — Product group landing page.
 *
 * Rendered URL:   /store/<group-slug>  (e.g. /store/wordpress-hosting)
 * Legacy URL:     cart.php?gid=<id>
 *
 * Visual source: apple-client-area/store.html (2-column layout —
 * categories sidebar + main card with category header, billing
 * cycle pill switcher, plan grid, guarantees strip).
 *
 * Available Smarty variables (set by WHMCS order-form bootstrap):
 *   $productgroups  — array of ALL product groups (for sidebar)
 *                     each: id, name, slug, headline, tagline, image
 *   $productgroup   — current group object
 *   $products       — products in current group; each w/ pid, name,
 *                     description, pricing (Money), features
 *   $cartcount      — number of items in cart (for sidebar badge)
 *   $loggedin       — bool
 *   $WEB_ROOT       — site root
 *   $carttpl        — current order-form theme slug (e.g. 'mytheme_cart')
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div class="content-area">
    <header class="st-page-header">
        <h1>{lang key='store.ordernewservices'|default:'Order new services'}</h1>
        <p class="page-subtitle">{lang key='store.browsedesc'|default:'Browse our plans and add the ones you need to your cart. All plans come with a 30-day money-back guarantee.'}</p>
    </header>

    <div class="st-split">

        {* ══════════════════════════════════════════════════════════
           SIDEBAR — Categories + Actions
           ══════════════════════════════════════════════════════════ *}
        <aside>
            {* Categories list — loops over all product groups *}
            <div class="card subnav-card">
                <div class="subnav-heading">{lang key='store.categories'|default:'Categories'}</div>
                {if $productgroups && count($productgroups) > 0}
                    {foreach $productgroups as $cat}
                        <a href="{$WEB_ROOT}/cart.php?gid={$cat.id|escape}"
                           class="subnav-item{if $cat.id == $productgroup->id} active{/if}">
                            {if $cat.image}
                                <img src="{$cat.image|escape}" alt="" style="width:14px;height:14px;object-fit:contain;">
                            {else}
                                {* Generic "package" icon — admin sets group image to override. *}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            {/if}
                            {$cat.name|escape}
                        </a>
                    {/foreach}
                {/if}
            </div>

            {* Actions — domain renew/register/transfer + view cart *}
            <div class="card subnav-card" style="margin-top: 12px;">
                <div class="subnav-heading">{lang key='store.actions'|default:'Actions'}</div>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 11-9-9c2.52 0 4.82.99 6.5 2.6"/><polyline points="22 4 22 10 16 10"/></svg>
                    {lang key='store.renewdomains'|default:'Renew Domains'}
                </a>
                <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                    {lang key='store.registerdomain'|default:'Register a New Domain'}
                </a>
                <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                    {lang key='store.transferdomain'|default:'Transfer in a Domain'}
                </a>
                <div class="subnav-divider"></div>
                <a href="{$WEB_ROOT}/cart.php?a=view" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                    {lang key='store.viewcart'|default:'View Cart'}
                    {if $cartcount && $cartcount > 0}
                        <span class="subnav-badge">{$cartcount}</span>
                    {/if}
                </a>
            </div>
        </aside>

        {* ══════════════════════════════════════════════════════════
           MAIN — Category header + plan grid (or empty state)
           ══════════════════════════════════════════════════════════ *}
        <div style="min-width: 0;">
            <div class="card" style="padding: 0;">

                {* Category header with billing cycle pill switcher *}
                <div class="st-cat-head">
                    <div class="st-cat-head-row">
                        <div class="st-cat-head-ico">
                            {if $productgroup->image}
                                <img src="{$productgroup->image|escape}" alt="{$productgroup->name|escape}">
                            {else}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            {/if}
                        </div>
                        <div class="st-cat-head-meta">
                            <h2 class="st-cat-head-title">{$productgroup->name|escape}</h2>
                            {if $productgroup->headline}
                                <p class="st-cat-head-desc">{$productgroup->headline}</p>
                            {elseif $productgroup->tagline}
                                <p class="st-cat-head-desc">{$productgroup->tagline}</p>
                            {/if}
                        </div>

                        {* Billing cycle switcher — UI only for now. Cycle picking
                           moves to the per-product configure step (configureproduct.tpl),
                           so this just sets a hint that future card prices respect. *}
                        <div class="st-cycle" role="tablist" aria-label="{lang key='store.billingcycle'|default:'Billing cycle'}">
                            <button type="button" data-cycle="monthly">{lang key='monthly'|default:'Monthly'}</button>
                            <button type="button" class="active" data-cycle="annually">
                                {lang key='annually'|default:'Annual'}
                                <span class="st-cycle-saving">{lang key='store.save20'|default:'Save 20%'}</span>
                            </button>
                            <button type="button" data-cycle="biennially">{lang key='biennially'|default:'Biennial'}</button>
                        </div>
                    </div>
                </div>

                {* Plans grid OR empty state *}
                {if $products && count($products) > 0}

                    <div class="st-pricing">
                        {* Mid-card auto-featured when there are ≥3 plans *}
                        {assign var=featuredIndex value=-1}
                        {if count($products) >= 3}{assign var=featuredIndex value=1}{/if}

                        {foreach $products as $product}
                            {$idx = $product@iteration - 1}
                            <div class="st-plan{if $idx == $featuredIndex} featured{/if}">
                                {if $idx == $featuredIndex}
                                    <span class="st-plan-badge">{lang key='store.mostpopular'|default:'Most popular'}</span>
                                {/if}

                                <h3 class="st-plan-name">{$product.name|escape}</h3>

                                {if $product.description}
                                    <p class="st-plan-tag">{$product.description|strip_tags|truncate:90}</p>
                                {else}
                                    <p class="st-plan-tag">&nbsp;</p>
                                {/if}

                                <div class="st-plan-price">
                                    {if $product.isFree}
                                        <span class="amount" style="font-size: 28px;">{lang key='orderpaymenttermfree'|default:'Free'}</span>
                                    {elseif $product.pricingParts}
                                        <span class="currency">{$product.pricingParts.currency|escape}</span>
                                        <span class="amount">{$product.pricingParts.amount|escape}</span>
                                        <span class="period">{$product.pricingParts.period|escape}</span>
                                    {else}
                                        <span class="amount" style="font-size: 24px;">{$product.pricing}</span>
                                    {/if}
                                </div>

                                {if $product.pricingSub}
                                    <div class="st-plan-price-sub">{$product.pricingSub|escape}</div>
                                {/if}

                                {if $product.features && count($product.features) > 0}
                                    <ul class="st-plan-features">
                                        {foreach $product.features as $featureLabel => $featureValue}
                                            <li>
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                                {if is_bool($featureValue) && $featureValue}
                                                    {$featureLabel|escape}
                                                {elseif is_bool($featureValue) && !$featureValue}
                                                    {* Skip features explicitly set to false *}
                                                {elseif is_numeric($featureValue) || ($featureValue|@strlen < 12)}
                                                    <strong>{$featureValue|escape}</strong> {$featureLabel|escape}
                                                {else}
                                                    {$featureValue|escape}
                                                {/if}
                                            </li>
                                        {/foreach}
                                    </ul>
                                {else}
                                    {* Empty feature list — keeps card heights aligned *}
                                    <ul class="st-plan-features"><li style="visibility:hidden">&nbsp;</li></ul>
                                {/if}

                                <a href="{$WEB_ROOT}/cart.php?a=add&pid={$product.pid|escape}"
                                   class="st-plan-cta{if $idx != $featuredIndex} secondary{/if}">
                                    {lang key='store.selectplan'|default:'Select plan'}
                                </a>
                            </div>
                        {/foreach}
                    </div>

                    {* Compare bar — fine print under the grid *}
                    <div class="st-compare">
                        <span>{lang key='store.allplansinclude'|default:'All plans include'}: {lang key='store.allplansincludelist'|default:'Free SSL · 99.99% uptime · DDoS protection · 24/7 support'}</span>
                        <span class="spacer"></span>
                        <a href="{$WEB_ROOT}/contact.php">{lang key='store.needhelp'|default:'Need help choosing?'} →</a>
                    </div>

                {else}

                    <div class="st-empty">
                        <div class="st-empty-ico" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/><line x1="9" y1="11" x2="15" y2="11"/></svg>
                        </div>
                        <h3 class="st-empty-title">{lang key='store.empty.title'|default:'No packages in this category yet'}</h3>
                        <p class="st-empty-desc">{lang key='store.empty.desc'|default:"We're preparing plans for this service. Browse another category or get in touch — our team can put together a custom quote for you."}</p>
                        <div class="st-empty-actions">
                            <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                                {lang key='store.empty.requestquote'|default:'Request a quote'}
                            </a>
                            <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                                {lang key='store.empty.browseall'|default:'Browse all categories'}
                            </a>
                        </div>
                    </div>

                {/if}
            </div>

            {* Guarantees strip — only when we have plans to back up *}
            {if $products && count($products) > 0}
                <div class="st-guarantees">
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 4h22v16H1z"/><path d="M1 12h22"/><path d="M15 4v16"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{lang key='store.guarantee.moneyback.title'|default:'30-day money back'}</div>
                            <div class="st-guarantee-sub">{lang key='store.guarantee.moneyback.desc'|default:"Full refund if you're not happy — no questions asked."}</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{lang key='store.guarantee.support.title'|default:'24/7 support'}</div>
                            <div class="st-guarantee-sub">{lang key='store.guarantee.support.desc'|default:'Reach a human engineer any time via chat or ticket.'}</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{lang key='store.guarantee.uptime.title'|default:'99.99% uptime SLA'}</div>
                            <div class="st-guarantee-sub">{lang key='store.guarantee.uptime.desc'|default:'Backed by global anycast and redundant power.'}</div>
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>

<script>
{literal}
(function () {
    // Billing cycle pill switcher — UI affordance only.
    // Cycle is committed on the per-product configure step (configureproduct.tpl);
    // here we just remember the choice in sessionStorage so it persists across
    // category navigation. configureproduct.tpl can read it back.
    var KEY = 'mytheme_cart.preferredCycle';
    document.querySelectorAll('.st-cycle button[data-cycle]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.st-cycle button').forEach(function (b) {
                b.classList.toggle('active', b === btn);
            });
            try { sessionStorage.setItem(KEY, btn.dataset.cycle); } catch (e) {}
        });
    });
    // Restore previous selection on load
    try {
        var saved = sessionStorage.getItem(KEY);
        if (saved) {
            var btn = document.querySelector('.st-cycle button[data-cycle="' + saved + '"]');
            if (btn) btn.click();
        }
    } catch (e) {}
})();
{/literal}
</script>
