{*
 * mytheme_cart/products.tpl — Product group landing page.
 *
 * Rendered URL:   cart.php?gid=<id>  (and any friendly-URL mapping
 *                 WHMCS exposes, e.g. /store/<group-slug>)
 *
 * Visual source: apple-client-area/store/{vps-hosting,wordpress-hosting,
 *                web-hosting,reseller-hosting,...}.html
 *
 *   Shell      = .store-nav (horizontal pill row, dynamic from $productgroups)
 *                + .store-hero (icon + title + tagline)
 *                + .store-plans (3-up plan grid)
 *
 * Standard_cart contract preserved (so the WHMCS cart-add server-side
 * pipeline + recommendations modal keep working):
 *   - Outer wrapper #order-standard_cart  (apple-layout.css scopes its
 *     wrapper resets to this id)
 *   - sidebar-categories-collapsed.tpl include (mobile currency picker)
 *   - recommendations-modal.tpl include (triggered by data-has-recommendations
 *     on .btn-order-now via scripts.min.js)
 *   - Each plan card carries:
 *       id="{idPrefix}"                   ← product123 or bundle45
 *       #{idPrefix}-name, #{idPrefix}-price, #{idPrefix}-description,
 *       #{idPrefix}-feature{N}, #{idPrefix}-order-button
 *     so the WHMCS DOM hooks for in-page JS (recommendations, qty,
 *     analytics) still bind.
 *   - <a href="{$product.productUrl}"> rather than a hand-built
 *     cart.php?a=add&pid= — productUrl honours custom routing.
 *   - $product.bid (bundles) handled with $product.displayprice +
 *     $LANG.bundledeal copy.
 *   - $product.stockControlEnabled → qty available chip.
 *   - $errormessage + missing-group alert preserved.
 *
 * $productgroup vs $productGroup: WHMCS 9 assigns the lowercase form
 * on the live install (verified). The .X|default:->X dual-pattern
 * accesses both array and object property shapes since the same TPL
 * has to render across multiple WHMCS minor versions.
 *
 * CSS: every class used here (.store-nav, .store-hero, .store-plans,
 * .store-plan-card, .featured-badge, .tile-icon, .btn-primary,
 * .btn-secondary) is owned by mytheme's apple-theme.css, which is
 * loaded by mytheme/header.tpl on every cart-flow page. mytheme_cart's
 * style.min.css only owns cart-specific tweaks.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">
    <div class="content-area">

        {if $errormessage}
            <div class="alert alert-danger" role="alert">
                {$errormessage}
            </div>
        {elseif !$productgroup}
            <div class="alert alert-info" role="alert">
                {lang key='orderForm.selectCategory'}
            </div>
        {/if}

        {* ──────────────────────────────────────────────────────────
           Horizontal category pill nav — visible md+
           ────────────────────────────────────────────────────────── *}
        {if $productgroups}
            {$_curGroupId = $productgroup.id|default:$productgroup->id}
            <div class="store-nav hidden-xs hidden-sm d-none d-md-flex">
                {foreach $productgroups as $cat}
                    {$_catId = $cat.id|default:$cat->id}
                    <a href="{$WEB_ROOT}/cart.php?gid={$_catId}"{if $_catId == $_curGroupId} class="active"{/if}>
                        {$cat.name|default:$cat->name|escape}
                    </a>
                {/foreach}
            </div>
        {/if}

        {* ── Mobile category picker — WHMCS-rendered currency + category select ── *}
        {include file="orderforms/standard_cart/sidebar-categories-collapsed.tpl"}

        {* ──────────────────────────────────────────────────────────
           Hero — group icon + title + tagline
           ────────────────────────────────────────────────────────── *}
        <div class="store-hero">
            <div class="store-hero-icon tile-icon orange" aria-hidden="true">
                {$_image = $productgroup.image|default:$productgroup->image}
                {if $_image}
                    <img src="{$_image|escape}" alt="">
                {else}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                {/if}
            </div>
            <h1 class="store-hero-title">
                {$_headline = $productgroup.headline|default:$productgroup->headline}
                {if $_headline}
                    {$_headline}
                {else}
                    {$productgroup.name|default:$productgroup->name|escape}
                {/if}
            </h1>
            {$_tagline = $productgroup.tagline|default:$productgroup->tagline}
            {if $_tagline}
                <p class="store-hero-subtitle">{$_tagline}</p>
            {/if}
        </div>

        {* ──────────────────────────────────────────────────────────
           Plan grid (or empty state)
           ────────────────────────────────────────────────────────── *}
        {if $products && count($products) > 0}

            {$productCount = count($products)}
            {$featuredIndex = -1}
            {if $productCount >= 3}{$featuredIndex = 1}{/if}

            <div class="store-plans" id="products">
                {foreach $products as $key => $product}
                    {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}
                    {$idx = $product@iteration - 1}
                    {$isFeatured = ($idx == $featuredIndex)}

                    <div class="store-plan-card{if $isFeatured} featured{/if}" id="{$idPrefix}">

                        <div class="store-plan-name">
                            <span id="{$idPrefix}-name">{$product.name}</span>
                            {if $isFeatured}
                                <span class="featured-badge">Most Popular</span>
                            {/if}
                            {if $product.stockControlEnabled}
                                <span class="store-plan-stock">
                                    {$product.qty} {$LANG.orderavailable}
                                </span>
                            {/if}
                        </div>

                        <div class="store-plan-price" id="{$idPrefix}-price">
                            {if $product.bid}
                                {if $product.displayprice}
                                    {$product.displayprice}
                                {/if}
                                <span class="period">{$LANG.bundledeal}</span>
                            {else}
                                {if $product.pricing.hasconfigoptions}
                                    <span class="store-plan-price-prefix">{$LANG.startingfrom}</span>
                                {/if}
                                {$product.pricing.minprice.price}
                                <span class="period">
                                    {if $product.pricing.minprice.cycle eq "monthly"}/mo
                                    {elseif $product.pricing.minprice.cycle eq "quarterly"}/qtr
                                    {elseif $product.pricing.minprice.cycle eq "semiannually"}/6mo
                                    {elseif $product.pricing.minprice.cycle eq "annually"}/yr
                                    {elseif $product.pricing.minprice.cycle eq "biennially"}/2yr
                                    {elseif $product.pricing.minprice.cycle eq "triennially"}/3yr
                                    {/if}
                                </span>
                                {if $product.pricing.minprice.setupFee}
                                    <span class="store-plan-setup">
                                        + {$product.pricing.minprice.setupFee->toPrefixed()} {$LANG.ordersetupfee}
                                    </span>
                                {/if}
                            {/if}
                        </div>

                        {if $product.featuresdesc}
                            <p class="store-plan-desc" id="{$idPrefix}-description">
                                {$product.featuresdesc}
                            </p>
                        {elseif $product.description}
                            <p class="store-plan-desc" id="{$idPrefix}-description">
                                {$product.description|strip_tags|truncate:140}
                            </p>
                        {/if}

                        {if $product.features}
                            <ul class="store-plan-features">
                                {foreach $product.features as $feature => $value}
                                    <li id="{$idPrefix}-feature{$value@iteration}">
                                        <strong>{$value}</strong> {$feature}
                                    </li>
                                {/foreach}
                            </ul>
                        {/if}

                        <div class="store-plan-cta">
                            <a href="{$product.productUrl}"
                               id="{$idPrefix}-order-button"
                               class="{if $isFeatured}btn-primary{else}btn-secondary{/if} btn-order-now"
                               {if $product.hasRecommendations} data-has-recommendations="1"{/if}>
                                {$LANG.ordernowbutton}
                            </a>
                        </div>

                    </div>
                {/foreach}
            </div>

        {else}

            <div class="store-empty">
                <div class="store-empty-ico" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/><line x1="9" y1="11" x2="15" y2="11"/></svg>
                </div>
                <h3 class="store-empty-title">No plans in this category yet</h3>
                <p class="store-empty-desc">We're preparing plans for this service. Browse another category or get in touch — our team can put together a custom quote for you.</p>
                <div class="store-empty-actions">
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">Request a quote</a>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">Browse all categories</a>
                </div>
            </div>

        {/if}

    </div>
</div>

{* Cart-add recommendations modal — populated server-side, triggered by
   data-has-recommendations on order buttons via scripts.min.js. *}
{include file="orderforms/standard_cart/recommendations-modal.tpl"}
