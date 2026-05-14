{*
 * mytheme_cart/products.tpl — Product group landing page.
 *
 * Rendered URL:   /store/<group-slug>  (e.g. /store/wordpress-hosting)
 * Legacy URL:     cart.php?gid=<id>
 *
 * Available Smarty variables:
 *   $productgroup       — current group object (id, name, headline, tagline, slug)
 *   $products           — array of products in this group, each w/ pid, name,
 *                         description, pricing (Money object), features, etc.
 *   $categories         — array of all product groups for sidebar
 *   $loggedin           — bool
 *   $currency           — current currency object
 *   $WEB_ROOT           — site root
 *   $carttpl            — current order form theme slug (e.g. 'mytheme_cart')
 *
 * Visual source: apple-client-area/store/wordpress-hosting.html
 * Layout: hero → plan grid → value props (3-up) → FAQ
 *         (showcase / comparison / video blocks belong in the dynamic
 *          store builder for richer per-group customization)
 *}

{include file="orderforms/$carttpl/common.tpl"}

<main class="ds-products-page">

    {* ═══════════════════════════════════════════════════════════
       HERO — group name + headline + tagline + CTA to plans
       ═══════════════════════════════════════════════════════════ *}
    <section class="ds-section ds-hero bg-main">
        <div class="ds-hero-inner">
            <div class="ds-hero-logo" aria-hidden="true">
                {if $productgroup->image}
                    <img src="{$productgroup->image|escape}" alt="{$productgroup->name|escape}">
                {else}
                    {* Default icon — generic "package" glyph *}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                {/if}
            </div>
            <h1 class="ds-hero-title">{$productgroup->name|escape}</h1>
            {if $productgroup->headline}
                <p class="ds-hero-subtitle">{$productgroup->headline}</p>
            {/if}
            {if $productgroup->tagline}
                <p class="ds-hero-description">{$productgroup->tagline}</p>
            {/if}
            {if $products && count($products) > 0}
                <a href="#plans" class="ds-hero-cta">
                    {lang key='store.seeplans'|default:'See plans'}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                </a>
            {/if}
        </div>
        <div class="ds-hero-accent" aria-hidden="true"></div>
    </section>

    {* ═══════════════════════════════════════════════════════════
       PLANS — product cards (full state)  OR  empty state
       ═══════════════════════════════════════════════════════════ *}
    {if $products && count($products) > 0}

        <section class="ds-section bg-lifted" id="plans">
            <div class="ds-container">
                <p class="ds-eyebrow">{lang key='store.chooseplan'|default:'Choose your plan'}</p>
                <h2 class="ds-section-title">{lang key='store.builtforeverystage'|default:'Built for every stage'}</h2>
                <p class="ds-section-subtitle">{lang key='store.upgradeanytime'|default:'Start where you are. Upgrade or downgrade any time without migrating.'}</p>

                <div class="ds-pricing-grid">
                    {* Mid-card gets the "featured" treatment when there are ≥3 plans.
                       Heuristic: 4 plans → card 2 featured; 3 plans → card 2; else first. *}
                    {assign var=featuredIndex value=1}
                    {if count($products) >= 4}{assign var=featuredIndex value=1}
                    {elseif count($products) >= 3}{assign var=featuredIndex value=1}
                    {else}{assign var=featuredIndex value=0}{/if}

                    {foreach $products as $product}
                        {$idx = $product@iteration - 1}
                        <div class="ds-plan{if $idx == $featuredIndex} featured{/if}">
                            {if $idx == $featuredIndex}
                                <span class="ds-plan-badge">{lang key='store.mostpopular'|default:'Most popular'}</span>
                            {/if}

                            <div class="ds-plan-name">{$product.name|escape}</div>

                            <div class="ds-plan-price{if $product.isFree} free{/if}">
                                {if $product.isFree}
                                    <span class="amount">{lang key='orderpaymenttermfree'|default:'Free'}</span>
                                {else}
                                    {* $product.pricing renders the full "$X.XX/mo" string from WHMCS. We
                                       split it visually via the currency/amount/period sub-spans when
                                       the parts are available; otherwise fall back to the raw string. *}
                                    {if $product.pricingParts}
                                        <span class="currency">{$product.pricingParts.currency|escape}</span><span class="amount">{$product.pricingParts.amount|escape}</span><span class="period">{$product.pricingParts.period|escape}</span>
                                    {else}
                                        <span class="amount" style="font-size:24px;">{$product.pricing}</span>
                                    {/if}
                                {/if}
                            </div>

                            {if $product.description}
                                <p class="ds-plan-desc">{$product.description|strip_tags|truncate:90}</p>
                            {else}
                                <p class="ds-plan-desc">&nbsp;</p>
                            {/if}

                            {if $product.features && count($product.features) > 0}
                                <ul class="ds-plan-features">
                                    {foreach $product.features as $featureLabel => $featureValue}
                                        <li>
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                            <span>
                                                {if is_bool($featureValue)}
                                                    {$featureLabel|escape}
                                                {elseif is_numeric($featureValue) || (is_string($featureValue) && $featureValue|@strlen < 12)}
                                                    {$featureLabel|escape}: <b>{$featureValue|escape}</b>
                                                {else}
                                                    {$featureValue|escape}
                                                {/if}
                                            </span>
                                        </li>
                                    {/foreach}
                                </ul>
                            {else}
                                {* No structured features — render an empty list so card heights line up. *}
                                <ul class="ds-plan-features"><li>&nbsp;</li></ul>
                            {/if}

                            <a href="{$WEB_ROOT}/cart.php?a=add&pid={$product.pid|escape}" class="ds-plan-cta">
                                {lang key='store.getstarted'|default:'Get started'}
                            </a>
                        </div>
                    {/foreach}
                </div>
            </div>
        </section>

        {* ═══════════════════════════════════════════════════════════
           VALUE PROPS — generic 3-up grid below the plans.
           Hardcoded copy for the hosting case is fine for the default
           visual; admins replace per-group via WHMCS's dynamic store
           builder when they want different copy.
           ═══════════════════════════════════════════════════════════ *}
        <section class="ds-section bg-main">
            <div class="ds-container">
                <p class="ds-eyebrow" style="text-align:center;">{lang key='store.whyus'|default:'Why us'}</p>
                <h2 class="ds-section-title" style="text-align:center;">{lang key='store.boringengineering'|default:'The boring engineering, done for you'}</h2>
                <p class="ds-section-subtitle center" style="text-align:center;">{lang key='store.builtinnotpluginshopping'|default:'Three things every great install needs — built in, no plugin shopping.'}</p>

                <div class="ds-freeform">
                    <div class="ds-freeform-grid">
                        <div class="ds-freeform-card">
                            <div class="ds-freeform-card-ico">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
                            </div>
                            <h3 class="ds-freeform-card-title">{lang key='store.perfdefault'|default:'Performance, by default'}</h3>
                            <p class="ds-freeform-card-desc">{lang key='store.perfdefaultdesc'|default:'Server-side full-page cache, Redis object cache, HTTP/3 + Brotli. We only ship a new runtime once it beats the last in real-world benchmarks.'}</p>
                        </div>
                        <div class="ds-freeform-card">
                            <div class="ds-freeform-card-ico">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>
                            </div>
                            <h3 class="ds-freeform-card-title">{lang key='store.securitynonag'|default:"Security that doesn't nag"}</h3>
                            <p class="ds-freeform-card-desc">{lang key='store.securitynagdesc'|default:'Web app firewall in front of every site. Brute-force and bot-traffic mitigation at the network edge. Two-factor on the dashboard. Mandatory disk encryption.'}</p>
                        </div>
                        <div class="ds-freeform-card">
                            <div class="ds-freeform-card-ico">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 11-9-9c2.52 0 4.82.99 6.5 2.6"/><polyline points="22 4 22 10 16 10"/></svg>
                            </div>
                            <h3 class="ds-freeform-card-title">{lang key='store.oneclickrollback'|default:'One-click rollback'}</h3>
                            <p class="ds-freeform-card-desc">{lang key='store.oneclickrollbackdesc'|default:'Pre-staging snapshots before every update. If something breaks the homepage, hit "rollback" and you are back in 30 seconds.'}</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        {* ═══════════════════════════════════════════════════════════
           FAQ — generic accordion. Admin overrides per group via
           tblproductgroups custom fields (`faq` JSON column) when
           we wire that up; until then, these are sensible defaults.
           ═══════════════════════════════════════════════════════════ *}
        <section class="ds-section bg-lifted">
            <div class="ds-container">
                <p class="ds-eyebrow" style="text-align:center;">{lang key='store.faq'|default:'FAQ'}</p>
                <h2 class="ds-section-title" style="text-align:center;">{lang key='store.commonquestions'|default:'Common questions'}</h2>
                <p class="ds-section-subtitle center" style="text-align:center;margin-bottom:48px;">
                    {lang key='store.stillonthefence'|default:'Still on the fence?'}
                    <a href="{$WEB_ROOT}/contact.php" style="color:var(--color-accent);text-decoration:none;">{lang key='store.talktous'|default:'Talk to us'}</a>
                    — {lang key='store.replywithinhour'|default:'we usually reply within an hour'}.
                </p>

                <div class="ds-faq">
                    <div class="ds-faq-item">
                        <input type="checkbox" id="ds-faq-1" class="ds-faq-toggle" checked>
                        <label for="ds-faq-1" class="ds-faq-question">
                            <span>{lang key='store.faq.q1'|default:'Can I migrate my existing site for free?'}</span>
                            <span class="ds-faq-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></span>
                        </label>
                        <div class="ds-faq-answer"><div class="ds-faq-answer-inner">
                            {lang key='store.faq.a1'|default:'Yes — every paid plan gets one free, hands-off migration. We handle the dance with the old host, including DNS cutover at a low-traffic time of your choosing, with zero downtime in the typical case.'}
                        </div></div>
                    </div>
                    <div class="ds-faq-item">
                        <input type="checkbox" id="ds-faq-2" class="ds-faq-toggle">
                        <label for="ds-faq-2" class="ds-faq-question">
                            <span>{lang key='store.faq.q2'|default:'Do you have a money-back guarantee?'}</span>
                            <span class="ds-faq-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></span>
                        </label>
                        <div class="ds-faq-answer"><div class="ds-faq-answer-inner">
                            {lang key='store.faq.a2'|default:'30 days, no questions asked. If you decide we are not the right fit, email us within 30 days of signup and we will refund the unused balance back to the original payment method within 3 business days.'}
                        </div></div>
                    </div>
                    <div class="ds-faq-item">
                        <input type="checkbox" id="ds-faq-3" class="ds-faq-toggle">
                        <label for="ds-faq-3" class="ds-faq-question">
                            <span>{lang key='store.faq.q3'|default:'What happens if I outgrow my plan?'}</span>
                            <span class="ds-faq-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></span>
                        </label>
                        <div class="ds-faq-answer"><div class="ds-faq-answer-inner">
                            {lang key='store.faq.a3'|default:'Upgrade instantly from your dashboard — no migration, no downtime, no IP change. We pro-rate the new plan against your current billing cycle so you only pay the difference for the days remaining.'}
                        </div></div>
                    </div>
                    <div class="ds-faq-item">
                        <input type="checkbox" id="ds-faq-4" class="ds-faq-toggle">
                        <label for="ds-faq-4" class="ds-faq-question">
                            <span>{lang key='store.faq.q4'|default:'Where are your data centers?'}</span>
                            <span class="ds-faq-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></span>
                        </label>
                        <div class="ds-faq-answer"><div class="ds-faq-answer-inner">
                            {lang key='store.faq.a4'|default:'US East (Ashburn, VA), EU West (Frankfurt, DE), and Asia (Singapore). You pick during checkout based on where most of your visitors are. The free CDN serves cached pages from 280+ global PoPs regardless of origin region.'}
                        </div></div>
                    </div>
                </div>
            </div>
        </section>

    {else}

        {* ═══════════════════════════════════════════════════════════
           EMPTY STATE — group has no purchasable products configured.
           Match the apple-client-area mockup's ds-empty styling.
           ═══════════════════════════════════════════════════════════ *}
        <section class="ds-section ds-empty bg-main">
            <div class="ds-empty-ico" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><line x1="9" y1="9" x2="15" y2="15"/><line x1="15" y1="9" x2="9" y2="15"/></svg>
            </div>
            <h2 class="ds-empty-title">{lang key='store.preparingcategory'|default:'This category is being prepared'}</h2>
            <p class="ds-empty-desc">{lang key='store.preparingcategorydesc'|default:'We do not have any active plans configured in'} <strong>{$productgroup->name|escape}</strong> {lang key='store.yet'|default:'yet'}. {lang key='store.browseortalk'|default:'Pop into the store catalog or get in touch — we will point you to the right product.'}</p>
            <div class="ds-empty-actions">
                <a href="{$WEB_ROOT}/cart.php" class="btn-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                    {lang key='store.browseall'|default:'Browse all products'}
                </a>
                <a href="{$WEB_ROOT}/contact.php" class="btn-secondary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                    {lang key='store.contactsales'|default:'Contact sales'}
                </a>
            </div>
        </section>

    {/if}

</main>

<script>
{literal}
(function () {
    // FAQ accordion — close siblings when one opens (one-open-at-a-time).
    // The checkbox toggles via :has() in CSS; this JS only enforces the
    // exclusive-open behavior on top of that.
    document.querySelectorAll('.ds-faq-toggle').forEach(function (input) {
        input.addEventListener('change', function () {
            if (!this.checked) return;
            document.querySelectorAll('.ds-faq-toggle').forEach(function (other) {
                if (other !== input) other.checked = false;
            });
        });
    });
})();
{/literal}
</script>
