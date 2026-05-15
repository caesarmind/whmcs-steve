{*
 * mytheme_cart/configureproduct.tpl — mockup-faithful rebuild
 *
 * Visual source: apple-client-area/configureproduct.html
 *   Shell    = .cp-steps (5-step strip)
 *              + 2-col grid: main column + sticky .cp-summary-card
 *   Sections = .card > .cp-section (Billing cycle | Configuration |
 *                 Server info | Custom fields | Add-ons)
 *   Vocab    = .cp-cycle-opt (radio cards) for billing cycles
 *              .cp-opt-row for each configurable option / field
 *              .cp-opt-picker (select) / .cp-opt-qty (qty stepper)
 *              .st-addon for add-on cards
 *
 * Server contract preserved (these are what cart.php's POST handler
 * for `configure=true` reads):
 *   - <form id="frmConfigureProduct"> (no method/action — scripts.min.js
 *     submits via POST to PHP_SELF). We keep the same form id.
 *   - Hidden inputs: configure=true, i={$i}
 *   - billingcycle = monthly|quarterly|semiannually|annually|biennially|triennially
 *   - configoption[<id>] for each configurable option (value depends on
 *     optiontype: option id for select/radio, 1 for checkbox, qty for type 4)
 *   - hostname, rootpw, ns1prefix, ns2prefix (server type only)
 *   - customfield[<id>] (rendered by WHMCS as $customfield.input HTML)
 *   - addons[<id>] checkbox per add-on
 *
 * JS contract preserved (these power the live summary):
 *   - recalctotals() — re-fetches the summary HTML and injects into
 *     #producttotal. Wired to every qty input via onchange/onkeyup.
 *     Called once at the bottom to populate initially.
 *   - updateConfigurableOptions(i, cycle) — fires when billing cycle
 *     changes (some configoption prices vary by cycle). Wired to each
 *     billing-cycle radio's onchange.
 *   - ion.rangeSlider for configoptions where qtymaximum is set and
 *     range > 25 — kept as-is; widget styles fine inside .cp-opt-row.
 *
 * Dropped:
 *   - The "have questions? contact us" alert under the form. Not in
 *     the mockup. Easy to add back.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<script>
var _localLang = {
    'addToCart': '{$LANG.orderForm.addToCart|escape}',
    'addedToCartRemove': '{$LANG.orderForm.addedToCartRemove|escape}'
};
</script>

<div id="order-standard_cart">

    {* mytheme/header.tpl already opens <div class="content-area"> for
       us; the inner wrapper that used to live here produced double
       padding. Class renamed from .page-header to .st-page-header to
       match products.tpl (style.min.css only defines rules for the
       latter). *}

    <header class="st-page-header">
        <h1>{$LANG.orderconfigure|default:'Configure your plan'}</h1>
        <p class="page-subtitle">{$LANG.cartconfigsubtitle|default:"Pick your billing cycle, server region and any add-ons — we'll total it up on the right."}</p>
    </header>

        <div class="cp-steps" aria-label="Order progress">
            <span class="cp-step done">
                <span class="cp-step-num">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </span>
                Choose plan
            </span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step done">
                <span class="cp-step-num">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </span>
                Choose a domain
            </span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step active"><span class="cp-step-num">3</span>Configure</span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step"><span class="cp-step-num">4</span>Cart</span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step"><span class="cp-step-num">5</span>Checkout</span>
        </div>

        <form id="frmConfigureProduct">
            <input type="hidden" name="configure" value="true">
            <input type="hidden" name="i" value="{$i}">

            <div class="cp-grid">

                {* ════════════════════════════════════════════
                   LEFT COLUMN
                   ════════════════════════════════════════════ *}
                <div class="cp-main">

                    {* Validation errors (populated by scripts.min.js) *}
                    <div class="alert alert-danger w-hidden" role="alert" id="containerProductValidationErrors">
                        <p>{$LANG.orderForm.correctErrors}:</p>
                        <ul id="containerProductValidationErrorsList"></ul>
                    </div>

                    {* ── Selected-plan hero ────────────────────────────
                       Shows the product the user picked on the previous
                       step (icon + name + short description), with a
                       "Change plan" link back to the products listing
                       for the same group. Mockup-faithful version of
                       what was previously only a one-line text in the
                       page-header subtitle. *}
                    <div class="card cp-plan-hero">
                        <div class="cp-plan-hero-ico" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                        </div>
                        <div class="cp-plan-hero-meta">
                            <div class="cp-plan-hero-eyebrow">{$LANG.cartselectedplan|default:'Selected plan'}</div>
                            <div class="cp-plan-hero-name">{$productinfo.name}</div>
                            {if $productinfo.description}
                                <div class="cp-plan-hero-desc">{$productinfo.description|strip_tags|truncate:120}</div>
                            {/if}
                        </div>
                        <a href="{$WEB_ROOT}/cart.php{if $productinfo.gid}?gid={$productinfo.gid}{/if}" class="cp-plan-hero-change">
                            {$LANG.cartchangeplan|default:'Change plan'}
                        </a>
                    </div>

                    {* ── Billing cycle (only for recurring products) ── *}
                    {if $pricing.type eq "recurring"}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.cartbillingcycle|default:'Billing cycle'}</h2>
                                <div class="cp-section-sub">{$LANG.cartbillingcyclesub|default:'Longer commitments = bigger discounts. You can upgrade or switch later.'}</div>
                            </div>
                            <div class="cp-section-body">
                                {* ── Billing-cycle cards ──
                                   Each card lays out as: cycle name (title) +
                                   "Billed every X" sub-description + the
                                   WHMCS-formatted price as a prominent number.
                                   WHMCS provides each cycle's price as a
                                   pre-formatted string ($pricing.monthly etc.),
                                   so we drop it into .cp-cycle-price which
                                   styles it large + tabular-nums. The mockup
                                   also shows "SAVE X%" badges on annual+; that
                                   would require computing the per-cycle
                                   savings from the raw prices, which WHMCS
                                   doesn't expose directly — skipped for now. *}
                                <div class="cp-cycle" role="radiogroup" aria-label="{$LANG.cartchoosecycle}">
                                    {if $pricing.monthly}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="monthly"{if $billingcycle eq "monthly"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermmonthly}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledmonthly|default:'Billed every month'}</div>
                                            <div class="cp-cycle-price">{$pricing.monthly}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.quarterly}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="quarterly"{if $billingcycle eq "quarterly"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermquarterly}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledquarterly|default:'Billed every 3 months'}</div>
                                            <div class="cp-cycle-price">{$pricing.quarterly}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.semiannually}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="semiannually"{if $billingcycle eq "semiannually"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermsemiannually}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledsemiannually|default:'Billed every 6 months'}</div>
                                            <div class="cp-cycle-price">{$pricing.semiannually}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.annually}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="annually"{if $billingcycle eq "annually"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermannually}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledannually|default:'Billed once per year'}</div>
                                            <div class="cp-cycle-price">{$pricing.annually}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.biennially}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="biennially"{if $billingcycle eq "biennially"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermbiennially}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledbiennially|default:'Billed every 2 years'}</div>
                                            <div class="cp-cycle-price">{$pricing.biennially}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.triennially}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="triennially"{if $billingcycle eq "triennially"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermtriennially}</div>
                                            <div class="cp-cycle-sub">{$LANG.cartbilledtriennially|default:'Billed every 3 years'}</div>
                                            <div class="cp-cycle-price">{$pricing.triennially}</div>
                                        </label>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Usage-billing metrics (if any) ── *}
                    {if count($metrics) > 0}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.metrics.title}</h2>
                                <div class="cp-section-sub">{$LANG.metrics.explanation}</div>
                            </div>
                            <div class="cp-section-body">
                                <ul class="cp-metric-list">
                                    {foreach $metrics as $metric}
                                        <li class="cp-opt-row">
                                            <div class="cp-opt-meta">
                                                <div class="cp-opt-name">{$metric.displayName}</div>
                                                <div class="cp-opt-desc">
                                                    {if count($metric.pricing) > 1}
                                                        {$LANG.metrics.startingFrom} {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                                    {elseif count($metric.pricing) == 1}
                                                        {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                                        {if $metric.includedQuantity > 0} · {$metric.includedQuantity} {$LANG.metrics.includedNotCounted}{/if}
                                                    {/if}
                                                </div>
                                            </div>
                                            {if count($metric.pricing) > 1}
                                                <button type="button" class="btn-secondary" data-toggle="modal" data-target="#modalMetricPricing-{$metric.systemName}">
                                                    {$LANG.metrics.viewPricing}
                                                </button>
                                            {/if}
                                            {include file="$template/usagebillingpricing.tpl"}
                                        </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    {/if}

                    {* ── Server info (only for product type=server) ── *}
                    {if $productinfo.type eq "server"}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.cartconfigserver}</h2>
                                <div class="cp-section-sub">Set the hostname, root password, and nameserver prefixes for your server.</div>
                            </div>
                            <div class="cp-section-body">
                                <div class="cp-form-grid">
                                    <div class="cp-field">
                                        <label for="inputHostname">{$LANG.serverhostname}</label>
                                        <input type="text" name="hostname" id="inputHostname" class="cp-input" value="{$server.hostname}" placeholder="servername.example.com">
                                    </div>
                                    <div class="cp-field">
                                        <label for="inputRootpw">{$LANG.serverrootpw}</label>
                                        <input type="password" name="rootpw" id="inputRootpw" class="cp-input" value="{$server.rootpw}">
                                    </div>
                                    <div class="cp-field">
                                        <label for="inputNs1prefix">{$LANG.serverns1prefix}</label>
                                        <input type="text" name="ns1prefix" id="inputNs1prefix" class="cp-input" value="{$server.ns1prefix}" placeholder="ns1">
                                    </div>
                                    <div class="cp-field">
                                        <label for="inputNs2prefix">{$LANG.serverns2prefix}</label>
                                        <input type="text" name="ns2prefix" id="inputNs2prefix" class="cp-input" value="{$server.ns2prefix}" placeholder="ns2">
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Configurable options ── *}
                    {if $configurableoptions}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.orderconfigpackage}</h2>
                                <div class="cp-section-sub">Customize storage, CPU, region, and other options for this plan.</div>
                            </div>
                            <div class="cp-section-body" id="productConfigurableOptions">
                                {foreach $configurableoptions as $num => $configoption}
                                    <div class="cp-opt-row">
                                        <div class="cp-opt-meta">
                                            <div class="cp-opt-name">
                                                <label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label>
                                            </div>
                                            {if $configoption.optiontype eq 3 && $configoption.options.0.name}
                                                <div class="cp-opt-desc">{$configoption.options.0.name}</div>
                                            {/if}
                                        </div>
                                        <div class="cp-opt-control">
                                            {if $configoption.optiontype eq 1}
                                                {* Dropdown *}
                                                <select name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" class="cp-opt-picker">
                                                    {foreach key=num2 item=options from=$configoption.options}
                                                        <option value="{$options.id}"{if $configoption.selectedvalue eq $options.id} selected{/if}>{$options.name}</option>
                                                    {/foreach}
                                                </select>
                                            {elseif $configoption.optiontype eq 2}
                                                {* Radio group *}
                                                <div class="cp-opt-radios">
                                                    {foreach key=num2 item=options from=$configoption.options}
                                                        <label class="cp-opt-radio">
                                                            <input type="radio" name="configoption[{$configoption.id}]" value="{$options.id}"{if $configoption.selectedvalue eq $options.id} checked{/if}>
                                                            <span>{if $options.name}{$options.name}{else}{$LANG.enable}{/if}</span>
                                                        </label>
                                                    {/foreach}
                                                </div>
                                            {elseif $configoption.optiontype eq 3}
                                                {* Checkbox / toggle *}
                                                <label class="cp-toggle">
                                                    <input type="checkbox" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="1"{if $configoption.selectedqty} checked{/if}>
                                                    <span class="cp-toggle-track" aria-hidden="true"></span>
                                                </label>
                                            {elseif $configoption.optiontype eq 4}
                                                {* Quantity (with optional range slider for large ranges) *}
                                                {if $configoption.qtymaximum}
                                                    {if !$rangesliderincluded}
                                                        <script type="text/javascript" src="{$BASE_PATH_JS}/ion.rangeSlider.min.js"></script>
                                                        <link href="{$BASE_PATH_CSS}/ion.rangeSlider.css" rel="stylesheet">
                                                        <link href="{$BASE_PATH_CSS}/ion.rangeSlider.skinModern.css" rel="stylesheet">
                                                        {assign var='rangesliderincluded' value=true}
                                                    {/if}
                                                    <input type="text" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}">
                                                    <script>
                                                        var sliderTimeoutId = null;
                                                        var sliderRangeDifference = {$configoption.qtymaximum} - {$configoption.qtyminimum};
                                                        var sliderStepThreshold = 25;
                                                        var setLargerMarkers = sliderRangeDifference > sliderStepThreshold;
                                                        jQuery("#inputConfigOption{$configoption.id}").ionRangeSlider({
                                                            min: {$configoption.qtyminimum},
                                                            max: {$configoption.qtymaximum},
                                                            grid: true,
                                                            grid_snap: setLargerMarkers ? false : true,
                                                            onChange: function () {
                                                                if (sliderTimeoutId) clearTimeout(sliderTimeoutId);
                                                                sliderTimeoutId = setTimeout(function () {
                                                                    sliderTimeoutId = null;
                                                                    recalctotals();
                                                                }, 250);
                                                            }
                                                        });
                                                    </script>
                                                {else}
                                                    <div class="cp-opt-qty">
                                                        <input type="number" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}" min="{$configoption.qtyminimum}" onchange="recalctotals()" onkeyup="recalctotals()">
                                                        <span class="cp-opt-qty-unit">x {$configoption.options.0.name}</span>
                                                    </div>
                                                {/if}
                                            {/if}
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                    {* ── Custom fields ── *}
                    {if $customfields}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.orderadditionalrequiredinfo}</h2>
                                <div class="cp-section-sub">{lang key='orderForm.requiredField'}</div>
                            </div>
                            <div class="cp-section-body">
                                <div class="cp-form-grid">
                                    {foreach $customfields as $customfield}
                                        <div class="cp-field">
                                            <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                                            {$customfield.input}
                                            {if $customfield.description}
                                                <span class="cp-field-help">{$customfield.description}</span>
                                            {/if}
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Add-ons ── *}
                    {if $addons || count($addonsPromoOutput) > 0}
                        <div class="card cp-section" id="productAddonsContainer">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.cartavailableaddons}</h2>
                                <div class="cp-section-sub">Optional extras to enhance your plan. Add or remove anytime.</div>
                            </div>
                            <div class="cp-section-body">
                                {foreach $addonsPromoOutput as $output}
                                    <div>{$output}</div>
                                {/foreach}

                                {foreach $addons as $addon}
                                    <label class="st-addon{if $addon.status} is-selected{/if}">
                                        <div class="st-addon-head">
                                            <div>
                                                <div class="st-addon-title">
                                                    <input type="checkbox" name="addons[{$addon.id}]"{if $addon.status} checked{/if}>
                                                    {$addon.name}
                                                </div>
                                                <div class="st-addon-desc">{$addon.description}</div>
                                            </div>
                                            <div class="st-addon-tier-price">{$addon.pricing}</div>
                                        </div>
                                    </label>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                </div>

                {* ════════════════════════════════════════════
                   RIGHT COLUMN — sticky summary card
                   ════════════════════════════════════════════ *}
                <aside class="cp-summary-wrap" id="scrollingPanelContainer">
                    <div class="card cp-summary-card" id="orderSummary">
                        <div class="cp-section-head">
                            <h2 class="cp-section-title">{$LANG.ordersummary}</h2>
                            <div class="loader w-hidden" id="orderSummaryLoader" aria-hidden="true">
                                <i class="fas fa-fw fa-sync fa-spin"></i>
                            </div>
                        </div>
                        <div class="cp-section-body">
                            <div class="summary-container" id="producttotal"></div>
                        </div>
                        <div class="cp-summary-footer">
                            <button type="submit" id="btnCompleteProductConfig" class="btn-primary">
                                {$LANG.continue}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                            </button>
                        </div>
                    </div>
                </aside>

            </div>
        </form>
</div>{* /#order-standard_cart *}

<style>{literal}
/* Page-local layout helpers — most .cp-* classes come from mytheme's
   apple-theme.css. These bind the page's grid + a few small primitives
   not covered by the parent theme. */
.cp-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 340px;
    gap: 20px;
    align-items: start;
}
@media (max-width: 880px) {
    .cp-grid { grid-template-columns: 1fr; }
    .cp-summary-wrap { position: static !important; }
}
.cp-main > .cp-section + .cp-section { margin-top: 16px; }

.cp-form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
}
@media (max-width: 720px) { .cp-form-grid { grid-template-columns: 1fr; } }
.cp-field { display: flex; flex-direction: column; gap: 6px; }
.cp-field > label {
    font-size: 12.5px;
    font-weight: 500;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
}
.cp-input {
    height: 40px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px;
    color: var(--color-text-primary);
    font-family: inherit;
}
.cp-input:focus {
    outline: none;
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}
.cp-field-help {
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    line-height: 1.4;
}

.cp-opt-radios { display: flex; gap: 10px; flex-wrap: wrap; }
.cp-opt-radio {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-pill);
    font-size: 13px;
    cursor: pointer;
    transition: all var(--transition-fast);
}
.cp-opt-radio:has(input:checked) {
    border-color: var(--color-accent);
    background: var(--color-accent-light);
    color: var(--color-accent);
}
.cp-opt-radio input { margin: 0; accent-color: var(--color-accent); }

.cp-toggle { display: inline-flex; align-items: center; cursor: pointer; }
.cp-toggle input { position: absolute; opacity: 0; pointer-events: none; }
.cp-toggle-track {
    position: relative;
    width: 40px; height: 24px;
    border-radius: 999px;
    background: var(--color-border);
    transition: background var(--transition-fast);
}
.cp-toggle-track::after {
    content: ""; position: absolute;
    top: 2px; left: 2px;
    width: 20px; height: 20px;
    background: #fff;
    border-radius: 50%;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
    transition: transform var(--transition-fast);
}
.cp-toggle input:checked + .cp-toggle-track { background: var(--color-accent); }
.cp-toggle input:checked + .cp-toggle-track::after { transform: translateX(16px); }

.cp-opt-qty-unit {
    font-size: 12px;
    color: var(--color-text-tertiary);
    margin-left: 8px;
}

.cp-summary-card { position: sticky; top: 72px; padding: 0; }
.cp-summary-footer {
    padding: 14px 22px 18px;
    border-top: 0.5px solid var(--color-border);
}
.cp-summary-footer .btn-primary { width: 100%; justify-content: center; }
{/literal}</style>

{include file="orderforms/standard_cart/recommendations-modal.tpl"}

<script>recalctotals();</script>

<script>
{literal}
/* Split each .cp-cycle-price text into currency / amount / period
   spans so the mockup typography (small / big / small) can be applied.
   WHMCS emits price as one string e.g. "$20.00 USD Monthly". We parse:
     - leading non-digit run -> currency symbol ($)
     - numeric run           -> amount (20.00)
     - optional ISO code     -> dropped (USD)
     - trailing word         -> cycle name -> mapped to /mo abbreviation */
(function () {
    var CYCLE_ABBR = {
        monthly:      '/mo',
        quarterly:    '/qtr',
        semiannually: '/6mo',
        semi:         '/6mo',
        annually:     '/yr',
        annual:       '/yr',
        biennially:   '/2yr',
        biennial:     '/2yr',
        triennially:  '/3yr',
        triennial:    '/3yr'
    };
    var nodes = document.querySelectorAll('.cp-cycle-price');
    for (var i = 0; i < nodes.length; i++) {
        var el = nodes[i];
        var raw = (el.textContent || '').trim();
        if (!raw) continue;
        // Match: [non-digits][digits.decimals] [optional ISO code] [optional cycle word]
        var m = raw.match(/^([^\d\-]*)\s*(-?\d[\d.,]*)\s*([A-Za-z]{2,4})?\s*(.*)$/);
        if (!m) continue;
        var currency = (m[1] || '').trim() || '$';
        var amount = (m[2] || '').trim();
        var rest = (m[4] || '').toLowerCase().trim();
        // If the third group is a 3-letter ISO code (USD, EUR, etc.) it's
        // already consumed; whatever is left is the cycle term.
        var key = rest.replace(/[^a-z]/g, '');
        var period = CYCLE_ABBR[key] || (rest ? '/' + rest.substr(0, 3) : '');
        el.innerHTML = '<span class="currency"></span><span class="amount"></span><span class="period"></span>';
        el.querySelector('.currency').textContent = currency;
        el.querySelector('.amount').textContent = amount;
        el.querySelector('.period').textContent = period;
    }
})();
{/literal}
</script>
