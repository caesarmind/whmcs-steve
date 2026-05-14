{*
 * mytheme_cart/products.tpl — Product group landing page.
 *
 * Rendered URL:   /store/<group-slug>  (e.g. /store/wordpress-hosting)
 * Legacy URL:     cart.php?gid=<id>
 *
 * Visual source: apple-client-area/store.html
 *
 * Variable shapes (confirmed against the live bill.hostnodes.com install):
 *   $productgroups  — sidebar list of all groups. Items can be either
 *                     associative arrays OR objects depending on WHMCS
 *                     minor version — use the dual `.X|default:->X`
 *                     pattern so the same TPL works for both.
 *   $productgroup   — current group (object on this install).
 *                     Same dual-fallback access.
 *   $products       — array of ASSOCIATIVE ARRAYS. Each item:
 *                       .pid       — int (product id, sometimes also .id)
 *                       .name      — string
 *                       .description — string (can contain HTML)
 *                       .paytype   — 'recurring' | 'onetime' | 'free'
 *                       .pricing   — assoc array of the shape:
 *                         {
 *                           'type'         => 'recurring',   ← metadata
 *                           'monthly'      => '$2.99 USD',
 *                           'quarterly'    => '$8.97 USD',
 *                           'semiannually' => '$17.94 USD',
 *                           'annually'     => '$35.88 USD',
 *                           'biennially'   => '$71.76 USD',
 *                           'triennially'  => '...',
 *                           'minimum'      => '...',          ← min cycle
 *                         }
 *                         Each cycle key holds the formatted price string
 *                         or '-1.00' if that cycle is disabled for the
 *                         product. The 'type' key is metadata (NOT a
 *                         price) — iterating naively grabs 'recurring'
 *                         as the first "price" which is wrong.
 *   $cartcount      — int
 *   $loggedin       — bool
 *   $WEB_ROOT, $carttpl
 *
 * Critical: products are arrays — DO NOT call methods like ->isFree()
 * or ->pricing()->first() on them, they fatal with "Call to a member
 * function on array". Pricing is itself an associative array, so we
 * read explicit cycle keys (monthly, annually, biennially, …) and
 * skip the 'type' metadata.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div class="content-area">
    <header class="st-page-header">
        <h1>Order new services</h1>
        <p class="page-subtitle">Browse our plans and add the ones you need to your cart. All plans come with a 30-day money-back guarantee.</p>
    </header>

    <div class="st-split">

        {* ══════════════════════════════════════════════════════════
           SIDEBAR — Categories + Actions
           ══════════════════════════════════════════════════════════ *}
        <aside>
            <div class="card subnav-card">
                <div class="subnav-heading">Categories</div>
                {if $productgroups}
                    {foreach $productgroups as $cat}
                        <a href="{$WEB_ROOT}/cart.php?gid={$cat.id|default:$cat->id}"
                           class="subnav-item{if ($cat.id|default:$cat->id) == ($productgroup.id|default:$productgroup->id)} active{/if}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            {$cat.name|default:$cat->name|escape}
                        </a>
                    {/foreach}
                {/if}
            </div>

            <div class="card subnav-card" style="margin-top: 12px;">
                <div class="subnav-heading">Actions</div>
                <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a9 9 0 11-9-9c2.52 0 4.82.99 6.5 2.6"/><polyline points="22 4 22 10 16 10"/></svg>
                    Renew Domains
                </a>
                <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                    Register a New Domain
                </a>
                <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                    Transfer in a Domain
                </a>
                <div class="subnav-divider"></div>
                <a href="{$WEB_ROOT}/cart.php?a=view" class="subnav-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                    View Cart
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

                <div class="st-cat-head">
                    <div class="st-cat-head-row">
                        <div class="st-cat-head-ico">
                            {$_image = $productgroup.image|default:$productgroup->image}
                            {if $_image}
                                <img src="{$_image|escape}" alt="{$productgroup.name|default:$productgroup->name|escape}">
                            {else}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            {/if}
                        </div>
                        <div class="st-cat-head-meta">
                            <h2 class="st-cat-head-title">{$productgroup.name|default:$productgroup->name|escape}</h2>
                            {$_headline = $productgroup.headline|default:$productgroup->headline}
                            {$_tagline = $productgroup.tagline|default:$productgroup->tagline}
                            {if $_headline}
                                <p class="st-cat-head-desc">{$_headline}</p>
                            {elseif $_tagline}
                                <p class="st-cat-head-desc">{$_tagline}</p>
                            {/if}
                        </div>

                        <div class="st-cycle" role="tablist" aria-label="Billing cycle">
                            <button type="button" data-cycle="monthly">Monthly</button>
                            <button type="button" class="active" data-cycle="annually">
                                Annual
                                <span class="st-cycle-saving">Save 20%</span>
                            </button>
                            <button type="button" data-cycle="biennially">Biennial</button>
                        </div>
                    </div>
                </div>

                {if $products && count($products) > 0}

                    <div class="st-pricing">
                        {$productCount = count($products)}
                        {$featuredIndex = -1}
                        {if $productCount >= 3}{$featuredIndex = 1}{/if}

                        {foreach $products as $product}
                            {$idx = $product@iteration - 1}
                            <div class="st-plan{if $idx == $featuredIndex} featured{/if}">
                                {if $idx == $featuredIndex}
                                    <span class="st-plan-badge">Most popular</span>
                                {/if}

                                <h3 class="st-plan-name">{$product.name|escape}</h3>

                                {if $product.description}
                                    <p class="st-plan-tag">{$product.description|strip_tags|truncate:90}</p>
                                {else}
                                    <p class="st-plan-tag">&nbsp;</p>
                                {/if}

                                {* Pricing — render every available cycle as a hidden
                                   span tagged with data-cycle-price; the JS at the
                                   bottom shows the one matching the active cycle
                                   pill. Skips the 'type' / 'minimum' metadata keys
                                   and any cycle whose value is '-1.00' (disabled). *}
                                <div class="st-plan-price" data-plan-price>
                                    {if $product.pricing.monthly && $product.pricing.monthly != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="monthly">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.monthly}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ mo</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.quarterly && $product.pricing.quarterly != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="quarterly">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.quarterly}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ qtr</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.semiannually && $product.pricing.semiannually != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="semiannually">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.semiannually}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ 6mo</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.annually && $product.pricing.annually != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="annually">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.annually}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ yr</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.biennially && $product.pricing.biennially != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="biennially">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.biennially}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ 2yr</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.triennially && $product.pricing.triennially != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="triennially">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.triennially}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">/ 3yr</span>
                                        </span>
                                    {/if}
                                    {if $product.pricing.onetime && $product.pricing.onetime != '-1.00'}
                                        <span class="cycle-price" data-cycle-price="onetime">
                                            <span class="amount" style="font-size: 28px;">{$product.pricing.onetime}</span>
                                            <span class="period" style="font-size: 12px; color: var(--color-text-tertiary); margin-left: 4px;">one-time</span>
                                        </span>
                                    {/if}
                                    {if $product.paytype == 'free' || $product.pricing.type == 'free'}
                                        <span class="cycle-price" data-cycle-price="free">
                                            <span class="amount" style="font-size: 28px; color: var(--color-green-text);">Free</span>
                                        </span>
                                    {/if}
                                </div>

                                <a href="{$WEB_ROOT}/cart.php?a=add&pid={$product.pid|default:$product.id}"
                                   class="st-plan-cta{if $idx != $featuredIndex} secondary{/if}">
                                    Order Now
                                </a>
                            </div>
                        {/foreach}
                    </div>

                    <div class="st-compare">
                        <span>All plans include free SSL · 99.99% uptime · DDoS protection · 24/7 support</span>
                        <span class="spacer"></span>
                        <a href="{$WEB_ROOT}/contact.php">Need help choosing? →</a>
                    </div>

                {else}

                    <div class="st-empty">
                        <div class="st-empty-ico" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/><line x1="9" y1="11" x2="15" y2="11"/></svg>
                        </div>
                        <h3 class="st-empty-title">No packages in this category yet</h3>
                        <p class="st-empty-desc">We're preparing plans for this service. Browse another category or get in touch — our team can put together a custom quote for you.</p>
                        <div class="st-empty-actions">
                            <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                                Request a quote
                            </a>
                            <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                                Browse all categories
                            </a>
                        </div>
                    </div>

                {/if}
            </div>

            {if $products && count($products) > 0}
                <div class="st-guarantees">
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 4h22v16H1z"/><path d="M1 12h22"/><path d="M15 4v16"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">30-day money back</div>
                            <div class="st-guarantee-sub">Full refund if you're not happy — no questions asked.</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">24/7 support</div>
                            <div class="st-guarantee-sub">Reach a human engineer any time via chat or ticket.</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">99.99% uptime SLA</div>
                            <div class="st-guarantee-sub">Backed by global anycast and redundant power.</div>
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </div>
</div>

<style>{literal}
/* Hide every cycle-price span by default; JS reveals the one matching
   the active pill (or the first available cycle as a fallback). */
.st-plan-price .cycle-price { display: none; }
.st-plan-price .cycle-price.is-active { display: inline-flex; align-items: baseline; }
{/literal}</style>

<script>
{literal}
(function () {
    // Billing cycle pill switcher — both UI affordance AND price filter.
    // Each .st-plan-price renders every available cycle as a hidden
    // .cycle-price span; the active pill controls which one shows.
    // We also persist the choice in sessionStorage so the configureproduct
    // step can pre-select the same cycle.
    var KEY = 'mytheme_cart.preferredCycle';

    function applyCycle(cycle) {
        // Pill state
        document.querySelectorAll('.st-cycle button[data-cycle]').forEach(function (b) {
            b.classList.toggle('active', b.dataset.cycle === cycle);
        });
        // Per-plan price reveal — falls back to the first available cycle
        // if the plan doesn't price that specific cycle.
        document.querySelectorAll('[data-plan-price]').forEach(function (priceBox) {
            var all = priceBox.querySelectorAll('.cycle-price');
            all.forEach(function (el) { el.classList.remove('is-active'); });
            var match = priceBox.querySelector('.cycle-price[data-cycle-price="' + cycle + '"]');
            if (match) {
                match.classList.add('is-active');
            } else if (all.length > 0) {
                all[0].classList.add('is-active');
            }
        });
    }

    // Default cycle — what the markup has 'active' or saved in storage
    var initialCycle = 'annually';
    try {
        var saved = sessionStorage.getItem(KEY);
        if (saved) initialCycle = saved;
    } catch (e) {}
    applyCycle(initialCycle);

    document.querySelectorAll('.st-cycle button[data-cycle]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var c = btn.dataset.cycle;
            applyCycle(c);
            try { sessionStorage.setItem(KEY, c); } catch (e) {}
        });
    });
})();
{/literal}
</script>
