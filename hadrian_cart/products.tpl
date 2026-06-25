{*
 * hadrian_cart/products.tpl — Product group landing page.
 *
 * Rendered URL:   cart.php?gid=<id>
 *                 (+ any friendly-URL mapping WHMCS exposes — e.g. /store/<slug>)
 *
 * Visual source: apple-client-area/store.html  ← /store on the dev server
 *
 *   Shell      = .st-page-header (H1 banner "Order new services")
 *                + .st-split (240px sidebar  |  main card)
 *                  ├── sidebar-categories.tpl  (Categories + Actions rail)
 *                  └── .card
 *                        ├── .st-cat-head (icon · title · tagline · billing pills)
 *                        ├── .cart-plans-grid (renamed from .when-full to
 *                        │     ├── Variant A — 3-up feature-list cards   (default)
 *                        │     ├── Variant B — 4-up minimal cards
 *                        │     ├── Variant C — horizontal rows
 *                        │     ├── Variant D — comparison table
 *                        │     ├── Variant E — bento (1 hero + 2 minis)
 *                        │     ├── Variant F — segmented bar
 *                        │     ├── Variant G — spec matrix
 *                        │     ├── Variant H — addon cards w/ radio tiers
 *                        │     └── .st-compare (fine print)
 *                        │                          avoid hadrian's global
 *                        │                          body[data-data="empty"]
 *                        │                          .when-full toggle)
 *                        └── .st-empty
 *                + .st-guarantees (3 trust cards)
 *
 * Variant switching is driven by hadrian's state-chip (`data-plan-set`).
 * The active variant is captured on <body data-plan="x"> and the
 * `.plan-variant:not(.v-x)` CSS rules in style.min.css hide the rest.
 * On "All" the chip emits no `data-plan` attr → every variant stacks
 * with an `.st-variant-label` above it so authors can preview them
 * side-by-side. When data-plan is absent on cart pages the CSS falls
 * back to Variant A (the end-user default).
 *
 * Billing-cycle pills: each price block carries `data-price-<cycle>`
 * attributes for every cycle the admin configured per-product. A pill
 * click fires the inline JS at the bottom; it walks every visible
 * `[data-price-host]` and swaps in the cycle's formatted string,
 * falling back to `data-price-min` (the WHMCS minprice) when the
 * selected cycle is not configured for that product. Pills are also
 * cosmetic-safe — if the admin only configured one cycle they still
 * render but click is a no-op since every card falls back to min.
 *
 * Standard_cart contract preserved (so the WHMCS cart-add server-side
 * pipeline + recommendations modal keep working):
 *   - Outer wrapper #order-standard_cart
 *   - sidebar-categories-collapsed.tpl include (mobile currency picker)
 *   - recommendations-modal.tpl include (triggered by data-has-recommendations
 *     on .btn-order-now via scripts.min.js)
 *   - Each card carries:
 *       id="{idPrefix}"  ← product123 or bundle45
 *       #{idPrefix}-name, #{idPrefix}-price, #{idPrefix}-description,
 *       #{idPrefix}-feature{N}, #{idPrefix}-order-button
 *     so the WHMCS DOM hooks for in-page JS (recommendations, qty,
 *     analytics) still bind.
 *   - <a href="{$product.productUrl}"> rather than hand-built
 *     cart.php?a=add&pid= — productUrl honours custom routing.
 *   - $product.bid (bundles) handled with $product.displayprice +
 *     $LANG.bundledeal copy.
 *   - $product.stockControlEnabled → "N available" chip.
 *   - $errormessage + missing-group alert preserved.
 *
 * $productgroup vs $productGroup: WHMCS sets the variable name
 * inconsistently depending on entry point — standard_cart's own
 * products.tpl reads $productGroup (capital G), while some friendly-URL
 * routes (e.g. /store/<slug>) appeared to set only the lowercase form
 * on our test install. To survive both, we resolve a single $_pg via
 * `$productGroup|default:$productgroup` and read every meta field
 * off that. The `.X|default:->X` dual-pattern on each meta field then
 * handles the array-vs-object property shape since older WHMCS
 * minor versions returned arrays here while newer ones return models.
 *
 * CSS: every class used here lives in hadrian_cart/css/style.min.css
 * (.st-* tokens) which is loaded by common.tpl. The Apple primitives
 * `.card`, `.btn-primary`, `.btn-secondary` live in the same sheet.
 *}

{include file="orderforms/$carttpl/common.tpl"}

{* Cycle abbreviation is rendered inline via an {if}/{elseif} chain at
   each call site rather than via an inline array literal lookup
   (`$cycleAbbr[$product.pricing.minprice.cycle]`). The array-literal +
   chained-dot bracket access combo silently bailed on the live WHMCS
   install's Smarty build, blocking variant rendering downstream. The
   verbose-but-portable {elseif} chain follows standard_cart's pattern
   and works across every Smarty 3.x we've encountered. *}

{* Pre-compute featured index — middle item when count >= 3, else first.
   Featured = "Most popular" CTA highlight; only applies when we have
   enough plans for a meaningful highlight (a 2-plan grid with one
   "featured" looks dishonest). *}
{$productCount = ($products) ? count($products) : 0}
{$featuredIndex = -1}
{if $productCount >= 3}{$featuredIndex = floor($productCount / 2)}{/if}

{* Resolve group: WHMCS uses $productGroup on /cart.php?gid=X (standard
   route) and may use $productgroup on /store/<slug> (friendly URL).
   Fall back through both names so we always have a handle. The
   `|default` chain returns the first non-empty value. *}
{$_pg = $productGroup|default:$productgroup}

{* Resolve group meta (array vs object shape across WHMCS versions) *}
{$_curGroupId = $_pg.id|default:$_pg->id}
{$_groupName  = $_pg.name|default:$_pg->name}
{$_headline   = $_pg.headline|default:$_pg->headline}
{$_tagline    = $_pg.tagline|default:$_pg->tagline}
{$_image      = $_pg.image|default:$_pg->image}

<div id="order-standard_cart">

    {* ──────────────────────────────────────────────────────────
       Page header banner — H1 "Order new services" + subtitle
       Sits above the 2-column split.
       ────────────────────────────────────────────────────────── *}
    <header class="st-page-header">
        <h1>{$LANG.ordernewservices|default:'Order New Services'}</h1>
        <p class="page-subtitle">{$hadrianLang.cart.orderServicesTagline}</p>
    </header>


    {if $errormessage}
        <div class="alert alert-danger" role="alert" style="margin-bottom: 16px;">
            {$errormessage}
        </div>
    {elseif !$_pg && $productCount == 0}
        {* Only show the "please choose" prompt when we have neither
           a resolved group nor any products to render. If WHMCS sets
           $products but skips the group object on friendly-URL routes,
           we proceed to render the plan grid below using $_groupName
           ?: $pagetitle as the heading fallback. *}
        <div class="alert alert-info" role="alert" style="margin-bottom: 16px;">
            {lang key='orderForm.selectCategory'}
        </div>
    {/if}

    {* NOTE: sidebar-categories-collapsed.tpl include (the WHMCS mobile
       picker) is intentionally NOT included here. Its `<select>`-based
       output relies on Bootstrap responsive utilities (.hidden-md /
       .visible-xs) to stay invisible on desktop, which we don't load in
       this theme. Instead, the sidebar-categories partial below
       responsive-wraps under the main column at 880px via the .st-split
       grid breakpoint — that handles mobile cleanly without the
       duplicate select panels. *}

    <div class="st-split">

        {* ── LEFT: Categories + Actions rail (reusable partial) ── *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* ── RIGHT: category detail ──
           Render the category card whenever we have a resolved group
           OR at least one product to show. Some WHMCS routes
           (e.g. /store/<slug>) pass $products without setting
           $productgroup, and we'd rather show plans against a fallback
           heading than fall through to the landing tiles when products
           are clearly available. *}
        <div style="min-width: 0;">

            {if $_pg || $productCount > 0}

            <div class="card" style="padding: 0; overflow: hidden;">

                {* ── Category header ─────────────────────────── *}
                <div class="st-cat-head">
                    <div class="st-cat-head-row">
                        <div class="st-cat-head-ico" aria-hidden="true">
                            {if $_image}
                                <img src="{$_image|escape}" alt="">
                            {else}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            {/if}
                        </div>
                        <div class="st-cat-head-meta">
                            <h2 class="st-cat-head-title" id="cat-title">
                                {if $_headline}{$_headline}
                                {elseif $_groupName}{$_groupName|escape}
                                {elseif $pagetitle}{$pagetitle|escape}
                                {else}{$hadrianLang.cart.plansHeading}{/if}
                            </h2>
                            {if $_tagline}
                                <p class="st-cat-head-desc" id="cat-desc">{$_tagline}</p>
                            {/if}
                        </div>

                        {* Billing cycle pill switcher — wired to inline JS below.
                           Pills render unconditionally; the JS click handler is
                           a no-op when no card has data for the picked cycle. *}
                        <div class="st-cycle" role="tablist" aria-label="Billing cycle" data-cycle-switcher>
                            <button type="button" data-cycle="monthly">{$hadrianLang.cart.cycleMonthly}</button>
                            <button type="button" data-cycle="annually" class="active">{$hadrianLang.cart.cycleAnnual} <span class="st-cycle-saving">{$hadrianLang.cart.cycleSaving}</span></button>
                            <button type="button" data-cycle="biennially">{$hadrianLang.cart.cycleBiennial}</button>
                        </div>
                    </div>
                </div>

                {if $productCount > 0}

                {* Wrapper class renamed from .when-full to .cart-plans-grid
                   because hadrian/apple-layout.css ships a global
                   `body[data-data="empty"] .when-full { display: none !important; }`
                   toggle for client-area pages with empty-state previews.
                   On cart pages we choose state via Smarty {if/else}, so we
                   don't want that toggle activating and nuking the plan
                   grid whenever something sets body[data-data="empty"]. *}
                <div class="cart-plans-grid">

                    {* ════════════════════════════════════════════════════════════
                       Variant A — 3-up feature-list cards  (default / recommended)
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                        Variant A · 3-up · feature list
                    </div>
                    <div class="plan-variant v-a">
                        <div class="st-pricing">
                            {foreach $products as $key => $product}
                                {if $product.bid}
                                    {$idPrefix = "bundle"|cat:$product.bid}
                                {else}
                                    {$idPrefix = "product"|cat:$product.pid}
                                {/if}
                                {$isFeatured = false}
                                {if $product@index == $featuredIndex}{$isFeatured = true}{/if}
                                <div class="st-plan{if $isFeatured} featured{/if}" id="{$idPrefix}">
                                    {if $isFeatured}
                                        <span class="st-plan-badge">{$hadrianLang.cart.mostPopular}</span>
                                    {/if}
                                    <h3 class="st-plan-name" id="{$idPrefix}-name">{$product.name}</h3>
                                    {if $product.featuresdesc}
                                        <p class="st-plan-tag" id="{$idPrefix}-description">{$product.featuresdesc|strip_tags|truncate:80}</p>
                                    {elseif $product.description}
                                        <p class="st-plan-tag" id="{$idPrefix}-description">{$product.description|strip_tags|truncate:80}</p>
                                    {else}
                                        <p class="st-plan-tag">&nbsp;</p>
                                    {/if}

                                    <div class="st-plan-price"
                                         id="{$idPrefix}-price"
                                         data-price-host
                                         data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                         data-cycle-min="{$product.pricing.minprice.cycle|escape}"
                                         {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                        {if $product.bid}
                                            {if $product.displayprice}
                                                <span class="amount" data-price-display>{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}</span>
                                            {/if}
                                            <span class="period" data-period-display>{$LANG.bundledeal}</span>
                                        {else}
                                            {if $product.pricing.hasconfigoptions}
                                                <span class="period" style="margin-right: 4px;">{$LANG.startingfrom}</span>
                                            {/if}
                                            <span class="amount" data-price-display>{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}</span>
                                            <span class="period" data-period-display>{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}</span>
                                        {/if}
                                    </div>
                                    {if $product.pricing.minprice.setupFee}
                                        <div class="st-plan-price-sub">+ {$product.pricing.minprice.setupFee->toPrefixed()} {$LANG.ordersetupfee}</div>
                                    {/if}

                                    {* Description body — admin writes <ul><li>...</li></ul> in
                                       the WHMCS product description. Same wrapper class used by
                                       Variants B and G so a single bit of HTML in the description
                                       renders consistently regardless of which variant is active.
                                       regex_replace strips WHMCS's auto-nl2br: WHMCS converts every
                                       newline in $product.description to <br />, which then leaks
                                       between <ul>/<li> and creates visible blank lines that no
                                       CSS rule can erase. *}
                                    <div class="st-plan-features">
                                        {if $product.description}{$product.description|regex_replace:'/<br\s*\/?>/i':''}{/if}
                                    </div>

                                    {if $product.stockControlEnabled}
                                        <div style="font-size: 11px; color: var(--color-text-tertiary); margin-bottom: 8px;">{$product.qty} {$LANG.orderavailable}</div>
                                    {/if}

                                    <a href="{$product.productUrl}"
                                       id="{$idPrefix}-order-button"
                                       class="st-plan-cta{if !$isFeatured} secondary{/if} btn-order-now"
                                       {if $product.hasRecommendations} data-has-recommendations="1"{/if}>
                                        {$LANG.ordernowbutton}
                                    </a>
                                </div>
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-a *}

                    {* ════════════════════════════════════════════════════════════
                       Variant B — 4-up minimal cards
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                        Variant B · 4-up · minimal cards
                    </div>
                    <div class="plan-variant v-b">
                        <div class="st-pricing-b">
                            {foreach $products as $key => $product}
                                {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}
                                {$isFeatured = ($product@index == $featuredIndex)}
                                <div class="st-plan-b{if $isFeatured} featured{/if}">
                                    <div class="st-plan-b-name">{$product.name}</div>
                                    <div class="st-plan-b-tag">
                                        {if $product.featuresdesc}{$product.featuresdesc|strip_tags|truncate:50}
                                        {elseif $product.description}{$product.description|strip_tags|truncate:50}
                                        {else}&nbsp;{/if}
                                    </div>
                                    <div class="st-plan-b-price"
                                         data-price-host
                                         data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                         data-cycle-min="{$product.pricing.minprice.cycle|escape}"
                                         {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                        <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                        <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                    </div>
                                    {* Description body — see Variant A note. Same admin-authored
                                       HTML, smaller scale per Variant B's denser card chrome. *}
                                    <div class="st-plan-b-specs">
                                        {if $product.description}{$product.description|regex_replace:'/<br\s*\/?>/i':''}{/if}
                                    </div>
                                    <a href="{$product.productUrl}" class="st-plan-b-cta">{$LANG.ordernowbutton}</a>
                                </div>
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-b *}

                    {* ════════════════════════════════════════════════════════════
                       Variant C — horizontal rows
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
                        Variant C · horizontal rows
                    </div>
                    <div class="plan-variant v-c">
                        <div class="st-rows">
                            {foreach $products as $key => $product}
                                {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}
                                {$isFeatured = ($product@index == $featuredIndex)}
                                <div class="st-row{if $isFeatured} featured{/if}">
                                    <div class="st-row-name">
                                        <strong>{$product.name}</strong>
                                        {if $product.featuresdesc}
                                            <span>{$product.featuresdesc|strip_tags|truncate:48}</span>
                                        {/if}
                                    </div>
                                    <div class="st-row-specs">
                                        {if $product.features}
                                            {foreach $product.features as $feature => $value}
                                                {if $feature@iteration <= 4}
                                                    <span class="st-row-spec">
                                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                                        <strong>{$value}</strong> {$feature}
                                                    </span>
                                                {/if}
                                            {/foreach}
                                        {/if}
                                    </div>
                                    <div class="st-row-price"
                                         data-price-host
                                         data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                         data-cycle-min="{$product.pricing.minprice.cycle|escape}"
                                         {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                        <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                        <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                    </div>
                                    <a href="{$product.productUrl}" class="st-row-cta">{$LANG.ordernowbutton}</a>
                                </div>
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-c *}

                    {* ════════════════════════════════════════════════════════════
                       Variant D — comparison table
                       Note: features rows are sourced from the FIRST product —
                       WHMCS features are per-product k:v pairs, not normalized
                       across the group. For perfectly aligned compare tables
                       the admin should keep feature labels consistent.
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
                        Variant D · comparison table
                    </div>
                    <div class="plan-variant v-d">
                        {* Take feature labels from first product as canonical rows. *}
                        {$_firstFeatures = []}
                        {foreach $products as $_p}
                            {if $_p@first && $_p.features}
                                {$_firstFeatures = $_p.features}
                            {/if}
                        {/foreach}
                        <div style="padding: 0 20px 24px;">
                            <table class="st-compare-tbl">
                                <thead>
                                    <tr>
                                        <th>&nbsp;</th>
                                        {foreach $products as $product}
                                            {$isFeatured = ($product@index == $featuredIndex)}
                                            <th{if $isFeatured} class="featured"{/if}>
                                                <div class="st-compare-plan-name">{$product.name}</div>
                                                <div class="st-compare-plan-price"
                                                     data-price-host
                                                     data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                                     {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                     {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                     {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                     {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                     {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                     {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                                    <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                                    <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                                </div>
                                            </th>
                                        {/foreach}
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach $_firstFeatures as $featureLabel => $_canonicalValue}
                                        <tr>
                                            <td>{$featureLabel}</td>
                                            {foreach $products as $product}
                                                {$isFeatured = ($product@index == $featuredIndex)}
                                                {* Look up this product's value for the canonical feature label.
                                                   If not present, render the green check (≈ "included"). *}
                                                {$cellVal = $product.features[$featureLabel]|default:''}
                                                <td{if $isFeatured} class="featured"{/if}>
                                                    {if $cellVal}
                                                        <span class="st-compare-val">{$cellVal}</span>
                                                    {else}
                                                        <span class="st-compare-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                                                    {/if}
                                                </td>
                                            {/foreach}
                                        </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                            <div class="st-compare-footer">
                                <div>&nbsp;</div>
                                {foreach $products as $product}
                                    {$isFeatured = ($product@index == $featuredIndex)}
                                    <div class="st-compare-footer-cta">
                                        <a href="{$product.productUrl}" class="st-plan-cta{if !$isFeatured} secondary{/if}" style="width: auto; min-width: 140px;">{$LANG.ordernowbutton}</a>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    </div>{* /.plan-variant.v-d *}

                    {* ════════════════════════════════════════════════════════════
                       Variant E — Bento asymmetric (1 hero + N minis)
                       First product = hero card spanning both cols at top
                       Remaining products = mini cards below in 2-col grid
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="8" rx="1"/><rect x="3" y="14" width="8" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                        Variant E · bento (hero + minis)
                    </div>
                    <div class="plan-variant v-e">
                        <div class="st-bento">
                            {foreach $products as $key => $product}
                                {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}
                                {if $product@first}
                                    <div class="st-bento-hero">
                                        <span class="st-plan-badge">{$hadrianLang.cart.mostPopular}</span>
                                        <div>
                                            <h3 class="st-bento-hero-name">{$product.name}</h3>
                                            {if $product.featuresdesc}
                                                <p class="st-bento-hero-tag">{$product.featuresdesc|strip_tags|truncate:120}</p>
                                            {/if}
                                            {if $product.features}
                                                <div class="st-bento-hero-specs">
                                                    {foreach $product.features as $feature => $value}
                                                        {if $feature@iteration <= 5}
                                                            <span><strong>{$value}</strong> {$feature}</span>
                                                        {/if}
                                                    {/foreach}
                                                </div>
                                            {/if}
                                        </div>
                                        <div class="st-bento-hero-right">
                                            <div class="st-bento-hero-price"
                                                 data-price-host
                                                 data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                                 {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                 {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                 {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                 {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                 {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                                 {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                                <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                                <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                            </div>
                                            <a href="{$product.productUrl}" class="st-bento-hero-cta">{$LANG.ordernowbutton}</a>
                                        </div>
                                    </div>
                                {else}
                                    <div class="st-bento-mini">
                                        <div class="st-bento-mini-name">{$product.name}</div>
                                        {if $product.featuresdesc}
                                            <div class="st-bento-mini-tag">{$product.featuresdesc|strip_tags|truncate:60}</div>
                                        {/if}
                                        <div class="st-bento-mini-price"
                                             data-price-host
                                             data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                             {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                            <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                            <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                        </div>
                                        {if $product.features}
                                            <ul class="st-bento-mini-specs">
                                                {foreach $product.features as $feature => $value}
                                                    {if $feature@iteration <= 4}
                                                        <li><strong>{$value}</strong> {$feature}</li>
                                                    {/if}
                                                {/foreach}
                                            </ul>
                                        {/if}
                                        <a href="{$product.productUrl}" class="st-bento-mini-cta">{$LANG.ordernowbutton}</a>
                                    </div>
                                {/if}
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-e *}

                    {* ════════════════════════════════════════════════════════════
                       Variant F — Segmented bar
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="6" width="18" height="12" rx="2"/><line x1="9" y1="6" x2="9" y2="18"/><line x1="15" y1="6" x2="15" y2="18"/></svg>
                        Variant F · segmented bar
                    </div>
                    <div class="plan-variant v-f">
                        <div class="st-seg">
                            {foreach $products as $key => $product}
                                {$isFeatured = ($product@index == $featuredIndex)}
                                <div class="st-seg-col{if $isFeatured} featured{/if}">
                                    <div class="st-seg-name">{$product.name}</div>
                                    {if $product.featuresdesc}
                                        <div class="st-seg-tag">{$product.featuresdesc|strip_tags|truncate:60}</div>
                                    {/if}
                                    <div class="st-seg-price"
                                         data-price-host
                                         data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                         {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                         {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                        <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                        <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                    </div>
                                    {if $product.features}
                                        <ul class="st-seg-specs">
                                            {foreach $product.features as $feature => $value}
                                                {if $feature@iteration <= 5}
                                                    <li><strong>{$value}</strong> {$feature}</li>
                                                {/if}
                                            {/foreach}
                                        </ul>
                                    {/if}
                                    <a href="{$product.productUrl}" class="st-seg-cta">{$LANG.ordernowbutton}</a>
                                </div>
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-f *}

                    {* ════════════════════════════════════════════════════════════
                       Variant G — Spec matrix (label / value rows)
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
                        Variant G · spec matrix
                    </div>
                    <div class="plan-variant v-g">
                        <div class="st-matrix">
                            {foreach $products as $key => $product}
                                {$isFeatured = ($product@index == $featuredIndex)}
                                <div class="st-matrix-card{if $isFeatured} featured{/if}">
                                    <div class="st-matrix-head">
                                        {if $isFeatured}<div class="st-matrix-eyebrow">{$hadrianLang.cart.mostPopular}</div>{/if}
                                        <h3 class="st-matrix-name">{$product.name}</h3>
                                    </div>
                                    {* Description body — see Variant A note. Was previously a
                                       label/value matrix sourced from $product.features; now
                                       renders the same description HTML as A and B so admins
                                       only write one set of <ul><li>...</li></ul>. *}
                                    <div class="st-matrix-specs">
                                        {if $product.description}{$product.description|regex_replace:'/<br\s*\/?>/i':''}{/if}
                                    </div>
                                    <div class="st-matrix-foot">
                                        <div class="st-matrix-price"
                                             data-price-host
                                             data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                             {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                            <span class="amount" data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                            <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                        </div>
                                        <a href="{$product.productUrl}" class="st-matrix-cta">{$LANG.ordernowbutton}</a>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    </div>{* /.plan-variant.v-g *}

                    {* ════════════════════════════════════════════════════════════
                       Variant H — Addon cards with radio tiers
                       Each $product gets one card with a single tier row at the
                       admin-configured minprice cycle. The radio is visual-only;
                       wiring it to a real cart-add form is deferred until the
                       admin picks H as the final layout.
                       ════════════════════════════════════════════════════════════ *}
                    <div class="st-variant-label">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Variant H · addon cards with radio tiers
                    </div>
                    <div class="plan-variant v-h">
                        {foreach $products as $key => $product}
                            {$idPrefix = ($product.bid) ? ("bundle"|cat:$product.bid) : ("product"|cat:$product.pid)}
                            <div class="st-addon-wrap">
                                <div class="st-addon">
                                    <div class="st-addon-head">
                                        <div>
                                            <h3 class="st-addon-title">{$product.name}</h3>
                                            {if $product.featuresdesc}
                                                <p class="st-addon-desc">{$product.featuresdesc|strip_tags|truncate:240}</p>
                                            {elseif $product.description}
                                                <p class="st-addon-desc">{$product.description|strip_tags|truncate:240}</p>
                                            {/if}
                                        </div>
                                        <div class="st-addon-illus">
                                            {if $_image}
                                                <img src="{$_image|escape}" alt="" style="max-width: 80px; max-height: 80px;">
                                            {else}
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                                            {/if}
                                        </div>
                                    </div>
                                    <label class="st-addon-tier">
                                        <input type="radio" name="addon-{$idPrefix}" value="{$idPrefix}" checked>
                                        <span class="st-addon-radio"></span>
                                        <div>
                                            <div class="st-addon-tier-label">{$product.name}</div>
                                            {if $product.featuresdesc}
                                                <div class="st-addon-tier-sub">{$product.featuresdesc|strip_tags|truncate:80}</div>
                                            {/if}
                                        </div>
                                        <div class="st-addon-tier-price"
                                             data-price-host
                                             data-price-min="{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}"
                                             {if $product.pricing.monthly}data-price-monthly="{$product.pricing.monthly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.quarterly}data-price-quarterly="{$product.pricing.quarterly|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.semiannually}data-price-semiannually="{$product.pricing.semiannually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.annually}data-price-annually="{$product.pricing.annually|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.biennially}data-price-biennially="{$product.pricing.biennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}
                                             {if $product.pricing.triennially}data-price-triennially="{$product.pricing.triennially|regex_replace:'/\s+[A-Z]{3}.*$/':''|escape}" {/if}>
                                            <span data-price-display>{if $product.bid && $product.displayprice}{$product.displayprice|regex_replace:'/\s+[A-Z]{3}.*$/':''}{else}{$product.pricing.minprice.price|regex_replace:'/\s+[A-Z]{3}.*$/':''}{/if}</span>
                                            <span class="period" data-period-display>{if $product.bid}{$LANG.bundledeal}{else}{if $product.pricing.minprice.cycle eq "monthly"}{$hadrianLang.cart.cycleShortMonthly}{elseif $product.pricing.minprice.cycle eq "quarterly"}{$hadrianLang.cart.cycleShortQuarterly}{elseif $product.pricing.minprice.cycle eq "semiannually"}{$hadrianLang.cart.cycleShortSemiannually}{elseif $product.pricing.minprice.cycle eq "annually"}{$hadrianLang.cart.cycleShortAnnually}{elseif $product.pricing.minprice.cycle eq "biennially"}{$hadrianLang.cart.cycleShortBiennially}{elseif $product.pricing.minprice.cycle eq "triennially"}{$hadrianLang.cart.cycleShortTriennially}{/if}{/if}</span>
                                        </div>
                                    </label>
                                </div>
                                <div style="margin-top: 12px; display: flex; justify-content: flex-end;">
                                    <a href="{$product.productUrl}" class="st-plan-cta" style="width: auto; padding: 0 22px;">{$LANG.ordernowbutton}</a>
                                </div>
                            </div>
                        {/foreach}
                    </div>{* /.plan-variant.v-h *}

                    {* ── Compare bar (fine print) ────────────────── *}
                    <div class="st-compare">
                        <span>{$hadrianLang.cart.comparePlans}</span>
                        <a href="#" id="cart-compare-link">{$hadrianLang.cart.compareAll}</a>
                        <span class="spacer"></span>
                        <span>{$hadrianLang.cart.pricesIn} {$currency.code|default:'USD'} · <a href="#" data-currency-toggle>{$LANG.changecurrency|default:'Change currency'}</a></span>
                    </div>

                </div>{* /.cart-plans-grid *}

                {else}

                {* ── Empty state ──────────────────────────────
                   Renders only when the group resolved but has zero
                   products (typical "category exists but admin hasn't
                   published packages yet" case). Previously this block
                   sat outside the {if $productCount} conditional and
                   leaked below the variants whenever a group had any
                   products at all. *}
                <div class="st-empty">
                    <div class="st-empty-ico" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/><line x1="9" y1="11" x2="15" y2="11"/></svg>
                    </div>
                    <h3 class="st-empty-title">{$hadrianLang.cart.emptyGroupTitle}</h3>
                    <p class="st-empty-desc">{$hadrianLang.cart.emptyGroupDesc}</p>
                    <div class="st-empty-actions">
                        <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                            {$hadrianLang.cart.requestQuote}
                        </a>
                        <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                            {$hadrianLang.cart.browseAll}
                        </a>
                    </div>
                </div>

                {/if}{* /productCount > 0 *}

            </div>{* /.card *}

            {* ── Guarantees strip — 3 trust cards below the main card ── *}
            {if $productCount > 0}
                <div class="st-guarantees">
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 4h22v16H1z"/><path d="M1 12h22"/><path d="M15 4v16"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{$hadrianLang.cart.moneyBack}</div>
                            <div class="st-guarantee-sub">{$hadrianLang.cart.moneyBackSub}</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{$hadrianLang.cart.support247}</div>
                            <div class="st-guarantee-sub">{$hadrianLang.cart.support247Sub}</div>
                        </div>
                    </div>
                    <div class="card st-guarantee">
                        <div class="st-guarantee-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
                        </div>
                        <div>
                            <div class="st-guarantee-title">{$hadrianLang.cart.uptime}</div>
                            <div class="st-guarantee-sub">{$hadrianLang.cart.uptimeSub}</div>
                        </div>
                    </div>
                </div>
            {/if}

            {else}
                {* ── Landing state: no category selected ──────────────
                   User landed on /cart.php without ?gid. The error/info
                   alert already explains "pick a category"; this card
                   reinforces the CTA and lists the active categories as
                   clickable tiles so the user has a clear next step
                   without scanning the sidebar. *}
                <div class="card st-pick">
                    <div class="st-pick-ico" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                    </div>
                    <h2 class="st-pick-title">{$hadrianLang.cart.pickCategoryTitle}</h2>
                    <p class="st-pick-desc">{$hadrianLang.cart.pickCategoryDesc}</p>

                    {if $productgroups}
                        <div class="st-pick-grid">
                            {foreach $productgroups as $cat}
                                {$_cId   = $cat.id|default:$cat->id}
                                {$_cName = $cat.name|default:$cat->name}
                                {$_cTag  = $cat.tagline|default:$cat->tagline}
                                <a href="{$WEB_ROOT}/cart.php?gid={$_cId}" class="st-pick-tile">
                                    <div class="st-pick-tile-ico" aria-hidden="true">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                                    </div>
                                    <div class="st-pick-tile-name">{$_cName|escape}</div>
                                    {if $_cTag}<div class="st-pick-tile-tag">{$_cTag|escape}</div>{/if}
                                    <span class="st-pick-tile-cta">
                                        {$hadrianLang.cart.viewPlans}
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                                    </span>
                                </a>
                            {/foreach}
                        </div>
                    {/if}
                </div>
            {/if}

        </div>{* /right column *}
    </div>{* /.st-split *}

</div>{* /#order-standard_cart *}

{* Cart-add recommendations modal — populated server-side, triggered by
   data-has-recommendations on order buttons via scripts.min.js. *}
{include file="orderforms/$carttpl/recommendations-modal.tpl"}

{* ──────────────────────────────────────────────────────────────────
   Billing-cycle pill swap.
   Reads data-price-<cycle> from every [data-price-host] currently in
   the DOM and substitutes the [data-price-display] text. When a card
   has no data for the picked cycle, falls back to data-price-min.
   Inert when the page has no .st-cycle pills (defensive).
   ────────────────────────────────────────────────────────────────── *}
<script>
(function () {
    var CYCLE_LABEL = {
        monthly:      '{$hadrianLang.cart.cycleShortMonthly|escape:"javascript"}',
        quarterly:    '{$hadrianLang.cart.cycleShortQuarterly|escape:"javascript"}',
        semiannually: '{$hadrianLang.cart.cycleShortSemiannually|escape:"javascript"}',
        annually:     '{$hadrianLang.cart.cycleShortAnnually|escape:"javascript"}',
        biennially:   '{$hadrianLang.cart.cycleShortBiennially|escape:"javascript"}',
        triennially:  '{$hadrianLang.cart.cycleShortTriennially|escape:"javascript"}'
    };

    var switcher = document.querySelector('[data-cycle-switcher]');
    if (!switcher) return;
    var pills = switcher.querySelectorAll('button[data-cycle]');

    function applyCycle(cycle) {
        pills.forEach(function (p) {
            p.classList.toggle('active', p.getAttribute('data-cycle') === cycle);
        });
        var hosts = document.querySelectorAll('[data-price-host]');
        hosts.forEach(function (host) {
            var amountEl = host.querySelector('[data-price-display]');
            var periodEl = host.querySelector('[data-period-display]');
            if (!amountEl) return;
            var price = host.getAttribute('data-price-' + cycle);
            if (price) {
                amountEl.textContent = price;
                if (periodEl) periodEl.textContent = CYCLE_LABEL[cycle] || '';
            } else {
                // Fall back to minprice when this product doesn't offer the picked cycle.
                var min = host.getAttribute('data-price-min');
                var minCycle = host.getAttribute('data-cycle-min');
                if (min) amountEl.textContent = min;
                if (periodEl) periodEl.textContent = CYCLE_LABEL[minCycle] || '';
            }
        });
    }

    pills.forEach(function (p) {
        p.addEventListener('click', function () {
            applyCycle(this.getAttribute('data-cycle'));
        });
    });
})();
</script>
