{*
 * mytheme_cart/configureproduct.tpl — Per-product configuration page.
 *
 * Rendered URL: /cart.php?a=confproduct&i=<item-index>
 *
 * Visual source: apple-client-area/configureproduct.html
 * Layout: page header → step strip → 2-col split
 *         Left: plan hero + billing cycle picker + configurable
 *               options + custom fields + addons
 *         Right (sticky): order summary + submit
 *
 * Available Smarty variables (WHMCS cart-confproduct bootstrap):
 *   $producttitle, $productdesc — current product
 *   $productinfo               — full product object (image, group, etc.)
 *   $pricingcycles             — { cycle => formatted-price }
 *   $billingcycle              — currently selected cycle
 *   $configurableoptions       — array of admin-defined options
 *     each: .name, .type ('dropdown'|'quantity'|'yesno'),
 *           .options [{ id, name, pricing, selected }]
 *   $customfields              — array of custom fields w/ .name, .input (HTML)
 *   $addons                    — array of addons w/ .id, .name,
 *                                .description, .pricing, .selected
 *   $domain                    — attached domain (if any)
 *   $cartitemid                — index of this cart item
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* ── configureproduct.tpl page-specific styles (.cp-*).
   Apple-language port of apple-client-area/configureproduct.html.
   Inline so this template stays self-contained. ─────────── */

.cp-page-header { margin-bottom: 24px; }
.cp-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.cp-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; line-height: 1.5; max-width: 620px; margin: 0; }

/* Step strip — reuse the .ct-steps look from viewcart */
.cp-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.cp-step { display: inline-flex; align-items: center; gap: 8px; }
.cp-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.cp-step.done .cp-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.cp-step.active .cp-step-num { background: var(--color-accent); color: #fff; }
.cp-step.active { color: var(--color-text-primary); font-weight: 500; }
.cp-step-sep { color: var(--color-text-quaternary); }

/* 2-col split */
.cp-split { display: grid; grid-template-columns: 1fr 340px; gap: 24px; align-items: start; }
@media (max-width: 960px) { .cp-split { grid-template-columns: 1fr; } }

/* Section card */
.cp-section { padding: 0; }
.cp-section-head { padding: 18px 22px 14px; border-bottom: 0.5px solid var(--color-border); }
.cp-section-title { font-size: 15px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.012em; margin: 0; }
.cp-section-sub { font-size: 12.5px; color: var(--color-text-tertiary); margin-top: 2px; letter-spacing: -0.008em; }
.cp-section-body { padding: 18px 22px 20px; }

/* Plan hero */
.cp-plan-hero { display: flex; align-items: center; gap: 18px; padding: 22px 24px; flex-wrap: wrap; }
.cp-plan-hero-ico { width: 52px; height: 52px; border-radius: 14px; background: var(--color-accent-light); color: var(--color-accent); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.cp-plan-hero-ico svg { width: 22px; height: 22px; }
.cp-plan-hero-ico img { width: 28px; height: 28px; object-fit: contain; }
.cp-plan-hero-meta { flex: 1; min-width: 200px; }
.cp-plan-hero-eyebrow { font-size: 10.5px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 0.06em; }
.cp-plan-hero-name { font-size: 20px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.018em; margin: 2px 0 2px; }
.cp-plan-hero-desc { font-size: 13px; color: var(--color-text-tertiary); letter-spacing: -0.008em; line-height: 1.45; }
.cp-plan-hero-change { height: 32px; padding: 0 16px; background: transparent; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); color: var(--color-text-secondary); font-size: 12.5px; font-weight: 500; cursor: pointer; font-family: inherit; text-decoration: none; transition: all var(--transition-fast); align-self: center; flex-shrink: 0; display: inline-flex; align-items: center; justify-content: center; }
.cp-plan-hero-change:hover { border-color: var(--color-accent); color: var(--color-accent); }

/* Domain attached row */
.cp-domain-row { padding: 14px 24px; border-top: 0.5px solid var(--color-border); display: flex; align-items: center; gap: 14px; flex-wrap: wrap; }
.cp-domain-row svg.dom { width: 16px; height: 16px; color: var(--color-text-tertiary); flex-shrink: 0; }
.cp-domain-row > div { flex: 1; min-width: 0; }
.cp-domain-row .label { font-size: 12px; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.cp-domain-row .value { font-size: 13.5px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; font-family: var(--font-mono, ui-monospace, Menlo, monospace); }

/* Billing cycle — segmented picker */
.cp-cycle { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
@media (max-width: 720px) { .cp-cycle { grid-template-columns: 1fr; } }
.cp-cycle-opt { position: relative; padding: 16px 16px 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); cursor: pointer; transition: all var(--transition-fast); }
.cp-cycle-opt input { position: absolute; opacity: 0; pointer-events: none; }
.cp-cycle-opt:hover { border-color: var(--color-accent); }
.cp-cycle-opt:has(input:checked) { border-color: var(--color-accent); background: var(--color-accent-light); }
.cp-cycle-save { position: absolute; top: 12px; right: 12px; padding: 3px 9px; border-radius: var(--radius-pill); background: var(--color-green-bg); color: var(--color-green-text); font-size: 9.5px; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; line-height: 1.1; }
.cp-cycle-title { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; }
.cp-cycle-price { display: flex; align-items: baseline; gap: 2px; font-variant-numeric: tabular-nums; margin-top: 10px; }
.cp-cycle-price .amount { font-size: 22px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.02em; line-height: 1; }

/* Form fields */
.cp-form { display: flex; flex-direction: column; gap: 16px; }
.cp-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
@media (max-width: 640px) { .cp-form-grid { grid-template-columns: 1fr; } }
.cp-row { display: flex; flex-direction: column; gap: 6px; }
.cp-label { font-size: 12px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; }
.cp-label .required { color: var(--color-red-text); margin-left: 2px; }
.cp-input, .cp-select { height: 38px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 14px; letter-spacing: -0.008em; color: var(--color-text-primary); font-family: inherit; width: 100%; transition: all var(--transition-fast); }
.cp-input:focus, .cp-select:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.cp-select { appearance: none; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 12px center; padding-right: 36px; cursor: pointer; }
.cp-hint { font-size: 11.5px; color: var(--color-text-tertiary); letter-spacing: -0.004em; margin-top: 2px; }

/* Option row (config options w/ inline label + picker) */
.cp-opt-row { display: flex; align-items: center; gap: 14px; padding: 14px 0; border-bottom: 0.5px solid var(--color-border); }
.cp-opt-row:last-child { border-bottom: 0; }
.cp-opt-meta { flex: 1; min-width: 0; }
.cp-opt-name { font-size: 13.5px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; }
.cp-opt-desc { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; letter-spacing: -0.004em; line-height: 1.45; }
.cp-opt-picker { height: 34px; padding: 0 32px 0 12px; border: 0.5px solid var(--color-border); border-radius: var(--radius-sm); background: var(--color-surface); font-size: 13px; font-variant-numeric: tabular-nums; color: var(--color-text-primary); font-family: inherit; appearance: none; min-width: 180px; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 10px center; cursor: pointer; flex-shrink: 0; }
.cp-opt-picker:focus { outline: none; border-color: var(--color-accent); }
.cp-opt-qty { display: inline-flex; align-items: center; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); overflow: hidden; background: var(--color-surface); }
.cp-opt-qty button { width: 32px; height: 32px; background: transparent; border: 0; color: var(--color-text-secondary); cursor: pointer; font-family: inherit; font-size: 14px; display: inline-flex; align-items: center; justify-content: center; transition: color var(--transition-fast); }
.cp-opt-qty button:hover { color: var(--color-accent); }
.cp-opt-qty input { width: 42px; text-align: center; border: 0; background: transparent; font: inherit; font-variant-numeric: tabular-nums; font-size: 13px; font-weight: 500; color: var(--color-text-primary); font-family: inherit; padding: 0; }
.cp-opt-qty input:focus { outline: none; }
.cp-opt-yesno { display: inline-flex; align-items: center; gap: 8px; }
.cp-opt-yesno input { accent-color: var(--color-accent); }

/* Custom field row (raw WHMCS-rendered <input>s) */
.cp-cfield { display: flex; flex-direction: column; gap: 6px; padding: 12px 0; border-bottom: 0.5px solid var(--color-border); }
.cp-cfield:last-child { border-bottom: 0; }
.cp-cfield-label { font-size: 13px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; }
.cp-cfield-input input,
.cp-cfield-input select,
.cp-cfield-input textarea { height: 38px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 14px; color: var(--color-text-primary); font-family: inherit; width: 100%; box-sizing: border-box; }
.cp-cfield-input textarea { height: auto; min-height: 80px; padding: 10px 14px; resize: vertical; }
.cp-cfield-desc { font-size: 11.5px; color: var(--color-text-tertiary); }

/* Addon row */
.cp-addon { display: flex; align-items: flex-start; gap: 12px; padding: 14px 0; border-bottom: 0.5px solid var(--color-border); }
.cp-addon:last-child { border-bottom: 0; }
.cp-addon input[type="checkbox"] { accent-color: var(--color-accent); margin-top: 4px; flex-shrink: 0; }
.cp-addon-meta { flex: 1; min-width: 0; }
.cp-addon-name { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; }
.cp-addon-desc { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; line-height: 1.5; }
.cp-addon-price { font-size: 13px; font-weight: 500; color: var(--color-text-primary); font-variant-numeric: tabular-nums; white-space: nowrap; align-self: center; }

/* Right summary */
.cp-summary-card { position: sticky; top: 72px; padding: 0; }
.cp-summary-head { padding: 18px 20px 14px; border-bottom: 0.5px solid var(--color-border); }
.cp-summary-head h2 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0; }
.cp-summary-list { padding: 8px 20px; }
.cp-summary-line { display: flex; justify-content: space-between; gap: 10px; padding: 8px 0; font-size: 12.5px; font-variant-numeric: tabular-nums; letter-spacing: -0.004em; }
.cp-summary-line .label { color: var(--color-text-secondary); }
.cp-summary-line .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; }
.cp-summary-line.divider { border-top: 0.5px solid var(--color-border); padding-top: 12px; margin-top: 4px; }
.cp-summary-total { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding: 14px 20px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); font-variant-numeric: tabular-nums; }
.cp-summary-total .label { font-size: 14px; font-weight: 600; color: var(--color-text-primary); }
.cp-summary-total .value { font-size: 22px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.022em; white-space: nowrap; }
.cp-summary-cycle { font-size: 11px; color: var(--color-text-tertiary); padding: 10px 20px 14px; }
.cp-summary-footer { padding: 16px 20px 18px; border-top: 0.5px solid var(--color-border); display: flex; flex-direction: column; gap: 10px; }
.cp-submit { height: 44px; padding: 0 20px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; gap: 6px; transition: background var(--transition-fast); }
.cp-submit:hover { background: var(--color-accent-hover); }
.cp-back-link { font-size: 12.5px; color: var(--color-text-tertiary); text-align: center; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 4px; }
.cp-back-link:hover { color: var(--color-accent); }
.cp-back-link svg { width: 11px; height: 11px; }
{/literal}</style>

<div class="content-area">
    <header class="cp-page-header">
        <h1>{lang key='cart.configure.title'|default:'Configure your plan'}</h1>
        <p class="page-subtitle">{lang key='cart.configure.subtitle'|default:"Pick a billing cycle and any optional add-ons — we'll keep a running total on the right."}</p>
    </header>

    <div class="cp-steps">
        <span class="cp-step done"><span class="cp-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{lang key='cart.step.plan'|default:'Choose plan'}</span>
        <span class="cp-step-sep">›</span>
        <span class="cp-step done"><span class="cp-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{lang key='cart.step.domain'|default:'Domain'}</span>
        <span class="cp-step-sep">›</span>
        <span class="cp-step active"><span class="cp-step-num">3</span>{lang key='cart.step.configure'|default:'Configure'}</span>
        <span class="cp-step-sep">›</span>
        <span class="cp-step"><span class="cp-step-num">4</span>{lang key='cart.step.cart'|default:'Cart'}</span>
        <span class="cp-step-sep">›</span>
        <span class="cp-step"><span class="cp-step-num">5</span>{lang key='cart.step.checkout'|default:'Checkout'}</span>
    </div>

    <form method="post" action="{$WEB_ROOT}/cart.php?a=confproduct&i={$cartitemid|default:0}" id="configProductForm">
        <input type="hidden" name="confproductsubmit" value="true">

        <div class="cp-split">

            {* ══ LEFT — configuration form ══ *}
            <div style="min-width: 0; display: flex; flex-direction: column; gap: 16px;">

                {* Selected plan hero *}
                <div class="card">
                    <div class="cp-plan-hero">
                        <div class="cp-plan-hero-ico">
                            {if $productinfo.image}
                                <img src="{$productinfo.image|escape}" alt="">
                            {else}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 4H4a2 2 0 00-2 2v12a2 2 0 002 2h16a2 2 0 002-2V6a2 2 0 00-2-2z"/><circle cx="12" cy="12" r="4"/></svg>
                            {/if}
                        </div>
                        <div class="cp-plan-hero-meta">
                            {if $productinfo.group}
                                <div class="cp-plan-hero-eyebrow">{$productinfo.group|escape}</div>
                            {/if}
                            <h2 class="cp-plan-hero-name">{$producttitle|escape}</h2>
                            {if $productdesc}
                                <div class="cp-plan-hero-desc">{$productdesc|strip_tags|truncate:120}</div>
                            {/if}
                        </div>
                        <a href="{$WEB_ROOT}/cart.php" class="cp-plan-hero-change">
                            {lang key='cart.configure.changeplan'|default:'Change plan'}
                        </a>
                    </div>
                    {if $domain}
                        <div class="cp-domain-row">
                            <svg class="dom" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                            <div>
                                <div class="label">{lang key='cart.configure.domain'|default:'Domain'}</div>
                                <div class="value">{$domain|escape}</div>
                            </div>
                        </div>
                    {/if}
                </div>

                {* Billing cycle — radio-card grid *}
                {if $pricingcycles && count($pricingcycles) > 0}
                    <div class="card cp-section">
                        <div class="cp-section-head">
                            <h2 class="cp-section-title">{lang key='cart.configure.billingcycle'|default:'Billing cycle'}</h2>
                            <div class="cp-section-sub">{lang key='cart.configure.billingcyclesub'|default:'Longer commitments unlock bigger savings. You can upgrade or switch later.'}</div>
                        </div>
                        <div class="cp-section-body">
                            <div class="cp-cycle" role="radiogroup" aria-label="{lang key='cart.configure.billingcycle'|default:'Billing cycle'}">
                                {foreach $pricingcycles as $cycleKey => $cyclePrice}
                                    <label class="cp-cycle-opt">
                                        <input type="radio" name="billingcycle" value="{$cycleKey|escape}"{if $cycleKey == $billingcycle} checked{/if}>
                                        <div class="cp-cycle-title">{$cycleKey|capitalize|escape}</div>
                                        <div class="cp-cycle-price">
                                            <span class="amount">{$cyclePrice|escape}</span>
                                        </div>
                                    </label>
                                {/foreach}
                            </div>
                        </div>
                    </div>
                {/if}

                {* Configurable options *}
                {if $configurableoptions && count($configurableoptions) > 0}
                    <div class="card cp-section">
                        <div class="cp-section-head">
                            <h2 class="cp-section-title">{lang key='cart.configure.options'|default:'Configuration'}</h2>
                            <div class="cp-section-sub">{lang key='cart.configure.optionssub'|default:'Optional resources and extras. You can change these later from the service page.'}</div>
                        </div>
                        <div class="cp-section-body">
                            {foreach $configurableoptions as $configoption}
                                <div class="cp-opt-row">
                                    <div class="cp-opt-meta">
                                        <div class="cp-opt-name">{$configoption.optionname|escape}</div>
                                    </div>

                                    {if $configoption.optiontype == 1}
                                        {* Dropdown *}
                                        <select name="configoption[{$configoption.id}]" class="cp-opt-picker">
                                            {foreach $configoption.options as $opt}
                                                <option value="{$opt.id|escape}"{if $opt.selected} selected{/if}>
                                                    {$opt.name|escape} — {$opt.pricing|escape}
                                                </option>
                                            {/foreach}
                                        </select>
                                    {elseif $configoption.optiontype == 3}
                                        {* Yes/No checkbox *}
                                        {foreach $configoption.options as $opt}
                                            <label class="cp-opt-yesno">
                                                <input type="checkbox" name="configoption[{$configoption.id}]" value="{$opt.id|escape}"{if $opt.selected} checked{/if}>
                                                <span>{$opt.pricing|escape}</span>
                                            </label>
                                        {/foreach}
                                    {elseif $configoption.optiontype == 4}
                                        {* Quantity stepper *}
                                        {foreach $configoption.options as $opt}
                                            <div class="cp-opt-qty">
                                                <button type="button" aria-label="Decrease" data-step="-1">−</button>
                                                <input type="text" name="configoption[{$configoption.id}]" value="{$opt.qty|default:0}" data-min="{$opt.qtyminimum|default:0}" data-max="{$opt.qtymaximum|default:99}" inputmode="numeric">
                                                <button type="button" aria-label="Increase" data-step="1">+</button>
                                            </div>
                                        {/foreach}
                                    {else}
                                        {* Default: dropdown fallback *}
                                        <select name="configoption[{$configoption.id}]" class="cp-opt-picker">
                                            {foreach $configoption.options as $opt}
                                                <option value="{$opt.id|escape}"{if $opt.selected} selected{/if}>
                                                    {$opt.name|escape} — {$opt.pricing|escape}
                                                </option>
                                            {/foreach}
                                        </select>
                                    {/if}
                                </div>
                            {/foreach}
                        </div>
                    </div>
                {/if}

                {* Custom fields *}
                {if $customfields && count($customfields) > 0}
                    <div class="card cp-section">
                        <div class="cp-section-head">
                            <h2 class="cp-section-title">{lang key='cart.configure.additional'|default:'Additional information'}</h2>
                            <div class="cp-section-sub">{lang key='cart.configure.additionalsub'|default:"Anything our deployment team should know."}</div>
                        </div>
                        <div class="cp-section-body">
                            {foreach $customfields as $cfield}
                                <div class="cp-cfield">
                                    <label class="cp-cfield-label">
                                        {$cfield.name|escape}
                                        {if $cfield.required}<span style="color: var(--color-red-text); margin-left: 2px;">*</span>{/if}
                                    </label>
                                    <div class="cp-cfield-input">{$cfield.input}</div>
                                    {if $cfield.description}
                                        <div class="cp-cfield-desc">{$cfield.description|escape}</div>
                                    {/if}
                                </div>
                            {/foreach}
                        </div>
                    </div>
                {/if}

                {* Available addons — checkbox + price *}
                {if $addons && count($addons) > 0}
                    <div class="card cp-section">
                        <div class="cp-section-head">
                            <h2 class="cp-section-title">{lang key='cart.configure.addons'|default:'Available add-ons'}</h2>
                            <div class="cp-section-sub">{lang key='cart.configure.addonssub'|default:'Optional extras billed alongside your plan. Change or cancel any time.'}</div>
                        </div>
                        <div class="cp-section-body">
                            {foreach $addons as $addon}
                                <label class="cp-addon">
                                    <input type="checkbox" name="addons[{$addon.id}]" value="1"{if $addon.selected} checked{/if}>
                                    <div class="cp-addon-meta">
                                        <div class="cp-addon-name">{$addon.name|escape}</div>
                                        {if $addon.description}
                                            <div class="cp-addon-desc">{$addon.description|strip_tags|truncate:140}</div>
                                        {/if}
                                    </div>
                                    <div class="cp-addon-price">{$addon.pricing|escape}</div>
                                </label>
                            {/foreach}
                        </div>
                    </div>
                {/if}
            </div>

            {* ══ RIGHT — sticky summary ══ *}
            <aside>
                <div class="card cp-summary-card">
                    <div class="cp-summary-head">
                        <h2>{lang key='cart.ordersummary'|default:'Order summary'}</h2>
                    </div>
                    <div class="cp-summary-list">
                        <div class="cp-summary-line">
                            <span class="label">{$producttitle|escape}</span>
                            <span class="value">{$baseprice|default:''}</span>
                        </div>
                        {if $domain}
                            <div class="cp-summary-line">
                                <span class="label">{lang key='cart.configure.domain'|default:'Domain'} · {$domain|escape}</span>
                                <span class="value">{$domainprice|default:'—'}</span>
                            </div>
                        {/if}
                        {if $rawdata.subtotal}
                            <div class="cp-summary-line divider">
                                <span class="label">{lang key='cart.subtotal'|default:'Subtotal'}</span>
                                <span class="value">{$rawdata.subtotal}</span>
                            </div>
                        {/if}
                    </div>
                    <div class="cp-summary-total">
                        <span class="label">{lang key='cart.duetoday'|default:'Due today'}</span>
                        <span class="value">{$totaltodaytext|default:$rawdata.total|default:''}</span>
                    </div>
                    {if $billingcycle}
                        <p class="cp-summary-cycle">
                            {lang key='cart.configure.renewsnote'|default:'Renews on'} {$billingcycle|escape} {lang key='cart.configure.cycle'|default:'cycle'}.
                            {lang key='cart.configure.guarantee'|default:'30-day money-back guarantee.'}
                        </p>
                    {/if}

                    <div class="cp-summary-footer">
                        <button type="submit" class="cp-submit">
                            {lang key='cart.configure.continue'|default:'Continue to cart'}
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;"><polyline points="9 18 15 12 9 6"/></svg>
                        </button>
                        <a href="{$WEB_ROOT}/cart.php" class="cp-back-link">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                            {lang key='cart.configure.back'|default:'Back to catalogue'}
                        </a>
                    </div>
                </div>
            </aside>
        </div>
    </form>
</div>

<script>
{literal}
(function () {
    // Quantity stepper on configurable options
    document.querySelectorAll('.cp-opt-qty').forEach(function (group) {
        var input = group.querySelector('input');
        if (!input) return;
        var min = parseInt(input.dataset.min, 10) || 0;
        var max = parseInt(input.dataset.max, 10) || 99;
        function clamp(v) { return Math.max(min, Math.min(max, v || 0)); }
        group.querySelectorAll('button[data-step]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var step = parseInt(btn.dataset.step, 10);
                input.value = clamp((parseInt(input.value, 10) || 0) + step);
            });
        });
        input.addEventListener('blur', function () {
            input.value = clamp(parseInt(input.value, 10));
        });
    });
})();
{/literal}
</script>
