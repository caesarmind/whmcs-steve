{*
 * mytheme_cart/viewcart.tpl — Cart review page.
 *
 * Rendered URL: /cart.php?a=view
 *
 * Visual source: apple-client-area/cart.html + cart-empty.html
 * Layout: page header → step strip → 2-col split
 *         Left: product/domain cards w/ addons + cycle + price
 *               + promo/tax tabs card
 *         Right (sticky): order summary + last-chance upsells +
 *                         totals + checkout/continue buttons + trust
 *         Empty state when cart is empty.
 *
 * Available Smarty variables (set by WHMCS cart bootstrap):
 *   $products              — cart products array (pid, name, productinfo,
 *                            billingcycle, pricing, recurring, domain,
 *                            addons, configoptions, group)
 *   $domains               — cart domains (domain, type, regperiod, pricing)
 *   $cartitemcount         — total count for the badge
 *   $totaltodaytext        — formatted "due today" amount
 *   $rawdata.subtotal,
 *      .total, .taxtotal   — raw totals
 *   $promotion             — applied promo code (if any)
 *   $upsellproducts        — recommended add-ons
 *   $loggedin              — bool
 *   $WEB_ROOT, $carttpl    — standard
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* ── viewcart.tpl page-specific component vocabulary (.ct-*).
   Apple-language port of apple-client-area/cart.html.
   Inline here so this template stays self-contained until we
   audit the .ct-* set into the shared style.min.css. ──────── */

.ct-page-header { margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; flex-wrap: wrap; }
.ct-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.ct-page-header .sub { font-size: 14px; color: var(--color-text-tertiary); letter-spacing: -0.008em; margin: 0; }
.ct-page-header .sub strong { color: var(--color-text-primary); font-weight: 600; font-variant-numeric: tabular-nums; }
.ct-back-shop {
    height: 36px; padding: 0 16px; font-size: 13px;
    display: inline-flex; align-items: center; gap: 6px;
    border-radius: var(--radius-pill);
    border: 1px solid var(--color-border);
    background: transparent; color: var(--color-text-primary);
    text-decoration: none;
    letter-spacing: -0.008em;
    transition: all var(--transition-fast);
}
.ct-back-shop:hover { border-color: var(--color-accent); color: var(--color-accent); }
.ct-back-shop svg { width: 13px; height: 13px; }

/* Step strip — Choose plan ✓ → Domain ✓ → Configure ✓ → Cart ● → Checkout ○ */
.ct-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.ct-step { display: inline-flex; align-items: center; gap: 8px; }
.ct-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.ct-step.done .ct-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.ct-step.active .ct-step-num { background: var(--color-accent); color: #fff; }
.ct-step.active { color: var(--color-text-primary); font-weight: 500; }
.ct-step-sep { color: var(--color-text-quaternary); }

/* 2-col split — products left, sticky summary right */
.ct-split { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
@media (max-width: 960px) { .ct-split { grid-template-columns: 1fr; } }

/* Product card */
.ct-product { padding: 0; }
.ct-product-head { display: flex; align-items: flex-start; gap: 14px; padding: 22px 24px 18px; border-bottom: 0.5px solid var(--color-border); }
.ct-product-ico { width: 48px; height: 48px; border-radius: 12px; background: var(--color-accent-light); color: var(--color-accent); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ct-product-ico svg { width: 22px; height: 22px; }
.ct-product-meta { flex: 1; min-width: 0; }
.ct-product-eyebrow { font-size: 10.5px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 0.06em; margin-bottom: 2px; }
.ct-product-title { font-size: 18px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.018em; margin: 0 0 3px; }
.ct-product-domain { font-size: 12.5px; color: var(--color-text-tertiary); font-family: var(--font-mono, ui-monospace, Menlo, monospace); }
.ct-product-remove { width: 32px; height: 32px; border-radius: 50%; background: transparent; border: 0; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; transition: all var(--transition-fast); flex-shrink: 0; align-self: flex-start; }
.ct-product-remove:hover { background: var(--color-red-bg); color: var(--color-red-text); }
.ct-product-remove svg { width: 15px; height: 15px; }

/* Addons */
.ct-addons-head { padding: 14px 24px 8px; font-size: 11px; font-weight: 600; color: var(--color-text-tertiary); text-transform: uppercase; letter-spacing: 0.06em; }
.ct-addon-row { display: grid; grid-template-columns: 28px 1fr auto auto; gap: 12px; align-items: center; padding: 12px 24px; border-bottom: 0.5px solid var(--color-border); transition: background var(--transition-fast); }
.ct-addon-row:last-of-type { border-bottom: 0; }
.ct-addon-row:hover { background: rgba(0, 0, 0, 0.02); }
.ct-addon-row:hover .ct-addon-remove-one { opacity: 1; }
.ct-addon-remove-one { width: 26px; height: 26px; border-radius: 50%; background: transparent; border: 0; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; transition: all var(--transition-fast); opacity: 0; flex-shrink: 0; }
.ct-addon-remove-one:hover { background: var(--color-red-bg); color: var(--color-red-text); }
.ct-addon-remove-one svg { width: 12px; height: 12px; }
@media (hover: none) { .ct-addon-remove-one { opacity: 1; } }
.ct-addon-ico { width: 28px; height: 28px; border-radius: 8px; background: var(--color-surface-secondary); color: var(--color-text-secondary); display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ct-addon-ico svg { width: 13px; height: 13px; }
.ct-addon-meta { min-width: 0; }
.ct-addon-name { font-size: 13.5px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; }
.ct-addon-sub { font-size: 11.5px; color: var(--color-text-tertiary); margin-top: 1px; letter-spacing: -0.004em; }
.ct-addon-price { font-size: 12.5px; font-weight: 500; color: var(--color-text-primary); font-variant-numeric: tabular-nums; letter-spacing: -0.008em; white-space: nowrap; }
.ct-addon-price.free { color: var(--color-green-text); font-weight: 600; font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; }

.ct-manage-addons { padding: 10px 24px 16px; border-bottom: 0.5px solid var(--color-border); font-size: 12.5px; display: flex; align-items: center; gap: 18px; flex-wrap: wrap; }
.ct-manage-addons a, .ct-manage-addons button { color: var(--color-accent); text-decoration: none; letter-spacing: -0.008em; display: inline-flex; align-items: center; gap: 4px; cursor: pointer; background: transparent; border: 0; font-family: inherit; font-size: inherit; padding: 0; }
.ct-manage-addons a:hover, .ct-manage-addons button:hover { color: var(--color-accent-hover); }
.ct-manage-addons svg { width: 11px; height: 11px; }
.ct-manage-addons .sep { width: 1px; height: 12px; background: var(--color-border); }
.ct-manage-addons .danger { color: var(--color-text-tertiary); }
.ct-manage-addons .danger:hover { color: var(--color-red-text); }

/* Footer: cycle + price */
.ct-product-foot { display: grid; grid-template-columns: 1fr auto; gap: 18px; align-items: center; padding: 18px 24px 20px; }
@media (max-width: 560px) { .ct-product-foot { grid-template-columns: 1fr; } }
.ct-cycle-row { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
.ct-cycle-label { font-size: 11px; font-weight: 600; color: var(--color-text-tertiary); letter-spacing: 0.04em; text-transform: uppercase; }
.ct-cycle-select { appearance: none; height: 40px; padding: 0 34px 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 13.5px; font-weight: 500; color: var(--color-text-primary); font-family: inherit; letter-spacing: -0.008em; cursor: pointer; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 12px center; max-width: 280px; width: 100%; }
.ct-cycle-select:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.ct-product-price { text-align: right; min-width: 0; }
.ct-product-price .amount { display: inline-flex; align-items: baseline; gap: 3px; font-size: 26px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.025em; font-variant-numeric: tabular-nums; line-height: 1; }
.ct-product-price .amount .currency { font-size: 15px; color: var(--color-text-secondary); font-weight: 500; }
.ct-product-price .amount .unit { font-size: 13px; color: var(--color-text-tertiary); font-weight: 500; margin-left: 4px; }
.ct-product-price .period { margin-top: 4px; font-size: 11.5px; color: var(--color-text-tertiary); letter-spacing: -0.004em; display: inline-flex; align-items: center; gap: 4px; justify-content: flex-end; }

/* Domain card (smaller variant of product card) */
.ct-domain-card { padding: 0; }
.ct-domain-row { display: flex; align-items: center; gap: 14px; padding: 18px 24px; }
.ct-domain-ico { width: 36px; height: 36px; border-radius: 10px; background: var(--color-surface-secondary); color: var(--color-text-secondary); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ct-domain-ico svg { width: 16px; height: 16px; }
.ct-domain-meta { flex: 1; min-width: 0; }
.ct-domain-name { font-size: 14.5px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; font-family: var(--font-mono, ui-monospace, Menlo, monospace); }
.ct-domain-sub { font-size: 11.5px; color: var(--color-text-tertiary); margin-top: 1px; letter-spacing: -0.004em; }
.ct-domain-price { font-size: 14px; font-weight: 600; color: var(--color-text-primary); font-variant-numeric: tabular-nums; white-space: nowrap; }

/* Promo / taxes tabs */
.ct-tabs-card { padding: 0; }
.ct-tabs { display: flex; align-items: center; gap: 24px; border-bottom: 0.5px solid var(--color-border); padding: 0 24px; }
.ct-tab { position: relative; padding: 14px 0; background: none; border: 0; font-size: 13px; font-weight: 500; letter-spacing: -0.008em; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; transition: color var(--transition-fast); }
.ct-tab:hover { color: var(--color-text-primary); }
.ct-tab.active { color: var(--color-accent); }
.ct-tab.active::after { content: ""; position: absolute; left: 0; right: 0; bottom: -0.5px; height: 2px; background: var(--color-accent); border-radius: 2px 2px 0 0; }
.ct-tab-panel { display: none; padding: 18px 24px 20px; }
.ct-tab-panel.is-active { display: block; }
.ct-promo-row { display: flex; gap: 8px; }
.ct-promo-input-wrap { position: relative; flex: 1; min-width: 0; }
.ct-promo-input-wrap svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); width: 14px; height: 14px; color: var(--color-text-tertiary); pointer-events: none; }
.ct-promo-input { width: 100%; height: 40px; padding: 0 14px 0 38px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 13.5px; letter-spacing: -0.008em; color: var(--color-text-primary); font-family: inherit; }
.ct-promo-input:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.ct-promo-apply { height: 40px; padding: 0 20px; border-radius: var(--radius-pill); background: transparent; border: 0.5px solid var(--color-border); color: var(--color-text-primary); font-size: 13px; font-weight: 500; cursor: pointer; font-family: inherit; letter-spacing: -0.008em; transition: all var(--transition-fast); flex-shrink: 0; }
.ct-promo-apply.is-active { background: var(--color-accent); color: #fff; border-color: var(--color-accent); }
.ct-promo-apply.is-active:hover { background: var(--color-accent-hover); }
.ct-tax-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; }
@media (max-width: 560px) { .ct-tax-grid { grid-template-columns: 1fr; } }
.ct-tax-row { display: flex; flex-direction: column; gap: 5px; }
.ct-tax-label { font-size: 11.5px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; }
.ct-tax-input { height: 36px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 13px; letter-spacing: -0.008em; color: var(--color-text-primary); font-family: inherit; }
.ct-tax-input:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }

/* ══ Right: sticky order summary ══ */
.ct-summary-card { position: sticky; top: 72px; padding: 0; }
.ct-summary-head { padding: 18px 20px 14px; border-bottom: 0.5px solid var(--color-border); display: flex; justify-content: space-between; align-items: baseline; }
.ct-summary-head h2 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0; }
.ct-summary-head .count { font-size: 12px; color: var(--color-text-tertiary); letter-spacing: -0.004em; font-variant-numeric: tabular-nums; }
.ct-summary-product { display: flex; align-items: center; justify-content: space-between; gap: 10px; padding: 14px 20px; border-bottom: 0.5px solid var(--color-border); }
.ct-summary-product-meta { min-width: 0; }
.ct-summary-product-name { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; }
.ct-summary-product-sub { font-size: 11.5px; color: var(--color-text-tertiary); margin-top: 2px; letter-spacing: -0.004em; }
.ct-summary-product-price { font-size: 13px; font-weight: 600; color: var(--color-text-primary); font-variant-numeric: tabular-nums; letter-spacing: -0.008em; white-space: nowrap; }

.ct-totals { padding: 10px 20px; border-top: 0.5px solid var(--color-border); }
.ct-totals-row { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; padding: 7px 0; font-size: 12.5px; font-variant-numeric: tabular-nums; letter-spacing: -0.004em; }
.ct-totals-row .label { color: var(--color-text-secondary); display: inline-flex; align-items: center; gap: 5px; }
.ct-totals-row .label svg { width: 11px; height: 11px; color: var(--color-text-quaternary); }
.ct-totals-row .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; }

.ct-summary-total { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding: 14px 20px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); font-variant-numeric: tabular-nums; }
.ct-summary-total .label { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; }
.ct-summary-total .value { font-size: 22px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.022em; white-space: nowrap; }

.ct-summary-footer { padding: 16px 20px 18px; display: flex; flex-direction: column; gap: 10px; }
.ct-checkout-btn { height: 46px; padding: 0 20px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; transition: background var(--transition-fast); }
.ct-checkout-btn:hover { background: var(--color-accent-hover); color: #fff; }
.ct-checkout-btn svg { width: 14px; height: 14px; }
.ct-continue-shop { font-size: 12.5px; color: var(--color-text-tertiary); text-align: center; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 4px; letter-spacing: -0.004em; }
.ct-continue-shop:hover { color: var(--color-accent); }
.ct-continue-shop svg { width: 11px; height: 11px; }

.ct-trust { padding: 12px 20px 16px; display: flex; flex-direction: column; gap: 6px; font-size: 11px; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.ct-trust-item { display: inline-flex; align-items: center; gap: 6px; }
.ct-trust-item svg { width: 12px; height: 12px; color: var(--color-green-text); flex-shrink: 0; }

/* Empty state */
.ct-empty { padding: 72px 24px 64px; text-align: center; }
.ct-empty-ico { width: 64px; height: 64px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; margin-bottom: 18px; }
.ct-empty-ico svg { width: 28px; height: 28px; }
.ct-empty-title { font-size: 19px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.016em; margin: 0 0 6px; }
.ct-empty-desc { font-size: 14px; color: var(--color-text-tertiary); max-width: 420px; margin: 0 auto 22px; line-height: 1.55; letter-spacing: -0.008em; }
.ct-empty-actions { display: inline-flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
.ct-empty-actions a { height: 40px; padding: 0 20px; font-size: 13.5px; display: inline-flex; align-items: center; gap: 6px; border-radius: var(--radius-pill); text-decoration: none; font-weight: 500; transition: all var(--transition-fast); }
.ct-empty-actions .btn-primary { background: var(--color-accent); color: #fff; border: 1px solid var(--color-accent); }
.ct-empty-actions .btn-primary:hover { background: var(--color-accent-hover); color: #fff; }
.ct-empty-actions .btn-secondary { background: transparent; color: var(--color-text-primary); border: 1px solid var(--color-border); }
.ct-empty-actions .btn-secondary:hover { border-color: var(--color-accent); color: var(--color-accent); }
.ct-empty-actions svg { width: 13px; height: 13px; }
{/literal}</style>

<div class="content-area">

    {* ── Page header — title + count/monthly subtotal + "browse" CTA ── *}
    <header class="ct-page-header">
        <div>
            <h1>Your cart</h1>
            {if ($products && count($products) > 0) || ($domains && count($domains) > 0)}
                {$totalItems = (count($products)|default:0) + (count($domains)|default:0)}
                <p class="sub">
                    <strong>{$totalItems} {if $totalItems == 1}item{else}items{/if}</strong>
                    {if $totaltodaytext} · <strong>{$totaltodaytext}</strong> due today{/if}
                </p>
            {/if}
        </div>
        <a href="{$WEB_ROOT}/cart.php" class="ct-back-shop">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 5 12 12 19"/></svg>
            Browse products & services
        </a>
    </header>

    {* ── Step strip — Cart is the active step ── *}
    <div class="ct-steps">
        <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Choose plan</span>
        <span class="ct-step-sep">›</span>
        <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Domain</span>
        <span class="ct-step-sep">›</span>
        <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Configure</span>
        <span class="ct-step-sep">›</span>
        <span class="ct-step active"><span class="ct-step-num">4</span>Cart</span>
        <span class="ct-step-sep">›</span>
        <span class="ct-step"><span class="ct-step-num">5</span>Checkout</span>
    </div>

    {* ─────────────────────────────────────────────────────────
       FULL STATE — cart has products and/or domains
       ───────────────────────────────────────────────────────── *}
    {if ($products && count($products) > 0) || ($domains && count($domains) > 0)}

    <div class="ct-split">

        {* ══ LEFT — products + domains + promo/tax tabs ══ *}
        <div style="min-width: 0; display: flex; flex-direction: column; gap: 14px;">

            {* ── Cart products loop ── *}
            {if $products && count($products) > 0}
                {foreach $products as $cartItem}
                    {$itemIndex = $cartItem@iteration - 1}
                    <div class="card ct-product">
                        <div class="ct-product-head">
                            <div class="ct-product-ico">
                                {if $cartItem.productinfo.image}
                                    <img src="{$cartItem.productinfo.image|escape}" alt="" style="width:24px;height:24px;object-fit:contain;">
                                {else}
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 4H4a2 2 0 00-2 2v12a2 2 0 002 2h16a2 2 0 002-2V6a2 2 0 00-2-2z"/><circle cx="12" cy="12" r="4"/></svg>
                                {/if}
                            </div>
                            <div class="ct-product-meta">
                                {if $cartItem.group}
                                    <div class="ct-product-eyebrow">{$cartItem.group|escape}</div>
                                {/if}
                                <h2 class="ct-product-title">{$cartItem.name|escape}</h2>
                                {if $cartItem.domain}
                                    <div class="ct-product-domain">{$cartItem.domain|escape}</div>
                                {/if}
                            </div>
                            <form method="post" action="{$WEB_ROOT}/cart.php" style="margin:0;">
                                <input type="hidden" name="a" value="remove">
                                <input type="hidden" name="i" value="{$itemIndex}">
                                <button type="submit" class="ct-product-remove" title="Remove product">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </form>
                        </div>

                        {* Addons block — only if this product has selected addons *}
                        {if $cartItem.addons && count($cartItem.addons) > 0}
                            <div class="ct-addons-head">
                                Included addons · {count($cartItem.addons)}
                            </div>
                            {foreach $cartItem.addons as $addon}
                                <div class="ct-addon-row">
                                    <div class="ct-addon-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                    </div>
                                    <div class="ct-addon-meta">
                                        <div class="ct-addon-name">{$addon.name|escape}</div>
                                        {if $addon.description}
                                            <div class="ct-addon-sub">{$addon.description|strip_tags|truncate:80}</div>
                                        {/if}
                                    </div>
                                    <div class="ct-addon-price{if $addon.isFree} free{/if}">
                                        {if $addon.isFree}
                                            Free
                                        {else}
                                            {$addon.pricing}
                                        {/if}
                                    </div>
                                </div>
                            {/foreach}

                            <div class="ct-manage-addons">
                                <a href="{$WEB_ROOT}/cart.php?a=confproduct&i={$itemIndex}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    Manage addons
                                </a>
                            </div>
                        {/if}

                        {* Footer — billing cycle + price *}
                        <div class="ct-product-foot">
                            <div class="ct-cycle-row">
                                <label class="ct-cycle-label" for="ct-cycle-{$itemIndex}">Billing cycle</label>
                                <select id="ct-cycle-{$itemIndex}" class="ct-cycle-select" data-cart-item="{$itemIndex}" name="billingcycle">
                                    {if $cartItem.pricingcycles}
                                        {foreach $cartItem.pricingcycles as $cycleKey => $cyclePrice}
                                            <option value="{$cycleKey|escape}"{if $cycleKey == $cartItem.billingcycle} selected{/if}>
                                                {$cyclePrice|escape}
                                            </option>
                                        {/foreach}
                                    {else}
                                        <option selected>{$cartItem.billingcycle|capitalize} — {$cartItem.pricing}</option>
                                    {/if}
                                </select>
                            </div>
                            <div class="ct-product-price">
                                <span class="amount">
                                    {if $cartItem.pricingParts}
                                        <span class="currency">{$cartItem.pricingParts.currency|escape}</span>{$cartItem.pricingParts.amount|escape}<span class="unit">{$currency.code|default:'USD'|escape}</span>
                                    {else}
                                        {$cartItem.pricing}
                                    {/if}
                                </span>
                                <div class="period">
                                    {$cartItem.billingcycle|escape} price
                                </div>
                            </div>
                        </div>
                    </div>
                {/foreach}
            {/if}

            {* ── Cart domains loop ── *}
            {if $domains && count($domains) > 0}
                <div class="card ct-domain-card">
                    <div class="ct-addons-head" style="border-bottom: 0.5px solid var(--color-border); padding: 18px 24px 14px;">
                        Domains · {count($domains)}
                    </div>
                    {foreach $domains as $dom}
                        <div class="ct-domain-row" style="border-bottom: 0.5px solid var(--color-border);">
                            <div class="ct-domain-ico">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                            </div>
                            <div class="ct-domain-meta">
                                <div class="ct-domain-name">{$dom.domain|escape}</div>
                                <div class="ct-domain-sub">
                                    {if $dom.type == 'register'}Register{elseif $dom.type == 'transfer'}Transfer{else}{$dom.type|escape}{/if}
                                    · {$dom.regperiod|escape} year(s)
                                </div>
                            </div>
                            <div class="ct-domain-price">{$dom.pricing|escape}</div>
                        </div>
                    {/foreach}
                </div>
            {/if}

            {* ── Promo / taxes tabs ── *}
            <div class="card ct-tabs-card">
                <div class="ct-tabs" role="tablist">
                    <button type="button" class="ct-tab active" data-tab="promo">Apply promo code</button>
                    <button type="button" class="ct-tab" data-tab="tax">Estimate taxes</button>
                </div>

                <div class="ct-tab-panel is-active" data-panel="promo">
                    <form method="post" action="{$WEB_ROOT}/cart.php?a=view">
                        <input type="hidden" name="ajax" value="1">
                        <div class="ct-promo-row">
                            <div class="ct-promo-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12V8H6a2 2 0 01-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 00-2 2c0 1.1.9 2 2 2h4v-4h-4z"/></svg>
                                <input type="text" name="promocode" class="ct-promo-input" placeholder="Enter promo code if you have one" value="{$promotioncode|escape}">
                            </div>
                            <button type="submit" name="validatepromo" value="true" class="ct-promo-apply{if $promotioncode} is-active{/if}">Apply</button>
                        </div>
                    </form>
                </div>

                <div class="ct-tab-panel" data-panel="tax">
                    <form method="post" action="{$WEB_ROOT}/cart.php?a=view">
                        <div class="ct-tax-grid">
                            <div class="ct-tax-row">
                                <label class="ct-tax-label" for="ct-tax-country">Country</label>
                                <select id="ct-tax-country" name="country" class="ct-tax-input">
                                    {if $countries}
                                        {foreach $countries as $cKey => $cName}
                                            <option value="{$cKey|escape}"{if $cKey == $taxcountry} selected{/if}>{$cName|escape}</option>
                                        {/foreach}
                                    {else}
                                        <option>Select country</option>
                                    {/if}
                                </select>
                            </div>
                            <div class="ct-tax-row">
                                <label class="ct-tax-label" for="ct-tax-state">State / region</label>
                                <input id="ct-tax-state" type="text" name="state" class="ct-tax-input" placeholder="California" value="{$taxstate|escape}">
                            </div>
                        </div>
                        <div class="ct-tax-grid">
                            <div class="ct-tax-row">
                                <label class="ct-tax-label" for="ct-tax-city">City</label>
                                <input id="ct-tax-city" type="text" name="city" class="ct-tax-input" value="{$taxcity|escape}">
                            </div>
                            <div class="ct-tax-row">
                                <label class="ct-tax-label" for="ct-tax-zip">Postcode</label>
                                <input id="ct-tax-zip" type="text" name="postcode" class="ct-tax-input" value="{$taxpostcode|escape}">
                            </div>
                        </div>
                        <button type="submit" name="updatetax" value="true" class="ct-promo-apply is-active" style="width: 100%;">Estimate taxes</button>
                    </form>
                </div>
            </div>
        </div>

        {* ══ RIGHT — sticky order summary ══ *}
        <aside>
            <div class="card ct-summary-card">
                <div class="ct-summary-head">
                    <h2>Order summary</h2>
                    {if $totalItems}
                        <span class="count">{$totalItems} {if $totalItems == 1}item{else}items{/if}</span>
                    {/if}
                </div>

                {* Product rows in summary *}
                {if $products}
                    {foreach $products as $cartItem}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">
                                    {if $cartItem.group}{$cartItem.group|escape} / {/if}{$cartItem.name|escape}
                                </div>
                                <div class="ct-summary-product-sub">
                                    {$cartItem.billingcycle|capitalize|escape} renewal
                                    {if $cartItem.domain} · {$cartItem.domain|escape}{/if}
                                </div>
                            </div>
                            <div class="ct-summary-product-price">{$cartItem.pricing}</div>
                        </div>
                    {/foreach}
                {/if}

                {* Domain rows in summary *}
                {if $domains}
                    {foreach $domains as $dom}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$dom.domain|escape}</div>
                                <div class="ct-summary-product-sub">
                                    {if $dom.type == 'register'}Register{elseif $dom.type == 'transfer'}Transfer{/if}
                                    · {$dom.regperiod|escape} year(s)
                                </div>
                            </div>
                            <div class="ct-summary-product-price">{$dom.pricing|escape}</div>
                        </div>
                    {/foreach}
                {/if}

                {* Totals *}
                <div class="ct-totals">
                    {if $totalrecurringmonthly && $totalrecurringmonthly != '0.00'}
                        <div class="ct-totals-row">
                            <span class="label">Recurring
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                            </span>
                            <span class="value">{$totalrecurringmonthly}</span>
                        </div>
                    {/if}
                    {if $rawdata.subtotal}
                        <div class="ct-totals-row">
                            <span class="label">Subtotal</span>
                            <span class="value">{$rawdata.subtotal}</span>
                        </div>
                    {/if}
                    {if $rawdata.taxtotal}
                        <div class="ct-totals-row">
                            <span class="label">Tax</span>
                            <span class="value">{$rawdata.taxtotal}</span>
                        </div>
                    {/if}
                </div>

                {* Grand total *}
                <div class="ct-summary-total">
                    <span class="label">Total</span>
                    <span class="value">{$totaltodaytext|default:$rawdata.total}</span>
                </div>

                {* Footer — checkout + continue shopping *}
                <div class="ct-summary-footer">
                    <a href="{$WEB_ROOT}/cart.php?a=checkout" class="ct-checkout-btn">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        Checkout
                        {if $totaltodaytext} — {$totaltodaytext}{/if}
                    </a>
                    <a href="{$WEB_ROOT}/cart.php" class="ct-continue-shop">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                        Continue shopping
                    </a>
                </div>

                <div class="ct-trust">
                    <span class="ct-trust-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        256-bit SSL · PCI-DSS Level 1
                    </span>
                    <span class="ct-trust-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        30-day money-back guarantee
                    </span>
                </div>
            </div>
        </aside>
    </div>

    {* ─────────────────────────────────────────────────────────
       EMPTY STATE — no products and no domains
       ───────────────────────────────────────────────────────── *}
    {else}

    <div class="card ct-empty">
        <div class="ct-empty-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
        </div>
        <h2 class="ct-empty-title">Your cart is empty</h2>
        <p class="ct-empty-desc">Browse our plans and add something to get started. Everything comes with a 30-day money-back guarantee.</p>
        <div class="ct-empty-actions">
            <a href="{$WEB_ROOT}/cart.php" class="btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                Browse plans
            </a>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="btn-secondary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                Register a domain
            </a>
        </div>
    </div>

    {/if}

</div>

<script>
{literal}
(function () {
    // Tabs (promo / tax estimator)
    document.querySelectorAll('.ct-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            var key = tab.dataset.tab;
            document.querySelectorAll('.ct-tab').forEach(function (t) { t.classList.remove('active'); });
            document.querySelectorAll('.ct-tab-panel').forEach(function (p) { p.classList.remove('is-active'); });
            tab.classList.add('active');
            var panel = document.querySelector('.ct-tab-panel[data-panel="' + key + '"]');
            if (panel) panel.classList.add('is-active');
        });
    });

    // Promo apply toggle visual state when input has content
    var promo = document.querySelector('.ct-tab-panel[data-panel="promo"] .ct-promo-input');
    var apply = document.querySelector('.ct-tab-panel[data-panel="promo"] .ct-promo-apply');
    if (promo && apply) {
        promo.addEventListener('input', function () {
            apply.classList.toggle('is-active', promo.value.trim().length > 0);
        });
    }

    // Per-product cycle change submits an update to cart.php?a=update
    document.querySelectorAll('.ct-cycle-select[data-cart-item]').forEach(function (sel) {
        sel.addEventListener('change', function () {
            var idx = sel.dataset.cartItem;
            // Submit a tiny form to update billing cycle server-side.
            var f = document.createElement('form');
            f.method = 'post';
            f.action = (window.WEB_ROOT || '') + '/cart.php?a=update';
            ['i', idx, 'billingcycle', sel.value].reduce(function (_, v, i, a) {
                if (i % 2 === 1) return;
                var input = document.createElement('input');
                input.type = 'hidden';
                input.name = a[i]; input.value = a[i + 1];
                f.appendChild(input);
            }, null);
            document.body.appendChild(f);
            f.submit();
        });
    });
})();
{/literal}
</script>
