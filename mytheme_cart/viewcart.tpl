{*
 * mytheme_cart/viewcart.tpl -- Apple visual rebuild
 *
 * Visual source: apple-client-area/cart.html
 *   Shell    = .content-area > header.page-header + .ct-steps + .ct-split
 *              .ct-split (1fr / 360px grid):
 *                LEFT  .card.ct-product per cart line (head, addon rows,
 *                      manage-addons strip, foot with cycle + price)
 *                      + .card.ct-tabs-card (promo / estimate-taxes tabs)
 *                RIGHT .card.ct-summary-card (per-item rows, totals,
 *                      grand total, checkout button, trust strip)
 *   Empty    = .card.ct-empty (icon, title, desc, two CTAs)
 *
 * Server contract preserved verbatim (so the cart-controller, recalc
 * pipeline, and existing modals keep working unchanged):
 *
 *   - $checkout flag still routes to checkout.tpl
 *   - common.tpl include + StatesDropdown.js load order unchanged
 *   - Main cart form: <form method="post" action="$PHP_SELF?a=view">
 *     for qty updates (qty[N], paddonqty[N][N], addonqty[N], upgradeqty[N])
 *   - Promo form: separate form posting to cart.php?a=view with
 *     name="promocode" id="inputPromotionCode" + submit name="validatepromo"
 *   - Tax form: <form action="cart.php?a=setstateandcountry"> with
 *     id="inputState" + id="inputCountry" (StatesDropdown.js dependency)
 *   - Inline JS handlers untouched:
 *       removeItem('p|a|d|r|u', num[, type])
 *       selectDomainPeriodInCart(domain, price, years, label)
 *   - Empty-cart trigger: button#btnEmptyCart -> modal#modalEmptyCart
 *     (form POSTs a=empty)
 *   - Remove-item modal: form POSTs cart.php with a=remove, r, i, rt
 *     via #inputRemoveItemType / #inputRemoveItemRef / #inputRemoveItemRenewalType
 *   - Order-summary IDs preserved for scripts.js / recalc hooks:
 *       #orderSummary  #orderSummaryLoader  #scrollingPanelContainer
 *       #subtotal  #discount  #taxTotal1  #taxTotal2
 *       #recurring  #recurringMonthly  #recurringQuarterly
 *       #recurringSemiAnnually  #recurringAnnually
 *       #recurringBiennially  #recurringTriennially
 *       #totalDueToday  #checkout  #continueShopping
 *   - $hookOutput, $gatewaysoutput, $expressCheckoutButtons preserved
 *
 * DROPPED (vs the prior Bootstrap shell):
 *   - sidebar-categories.tpl + sidebar-categories-collapsed.tpl includes
 *     (the mockup has no category rail; the main client-area rail handles
 *     navigation)
 *   - Bootstrap .nav-tabs / data-toggle="tab" (replaced with custom
 *     .ct-tabs + a tiny inline JS toggle)
 *   - Old .when-full / .when-empty class names -- mytheme's global CSS
 *     hides .when-full on cart routes (per memory). Use page-scoped
 *     .vc-when-full / .vc-when-empty instead.
 *}

{if $checkout}

    {include file="orderforms/$carttpl/checkout.tpl"}

{else}

    <script>
        var statesTab = 10;
        var stateNotRequired = true;
    </script>
    {include file="orderforms/$carttpl/common.tpl"}
    <script type="text/javascript" src="{$BASE_PATH_JS}/StatesDropdown.js"></script>

    <style>{literal}
    /* ─── Page-local Apple skin for /cart.php?a=view ───────────────────
       Mirrors apple-client-area/cart.html's inline <style>. Kept inline
       so it cannot conflict with mytheme's global style.min.css and so
       a stale CSS cache can't strand the page in the old Bootstrap look. */

    /* Page header */
    .page-header { margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; flex-wrap: wrap; }
    .page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
    .page-header .sub { font-size: 14px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
    .page-header .sub strong { color: var(--color-text-primary); font-weight: 600; font-variant-numeric: tabular-nums; }

    /* Step strip */
    .ct-steps {
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        margin-bottom: 18px;
        font-size: 12.5px; color: var(--color-text-tertiary);
        letter-spacing: -0.008em;
    }
    .ct-step { display: inline-flex; align-items: center; gap: 8px; }
    .ct-step-num {
        width: 22px; height: 22px; border-radius: 50%;
        background: var(--color-surface-secondary); color: var(--color-text-tertiary);
        display: inline-flex; align-items: center; justify-content: center;
        font-size: 11px; font-weight: 600; flex-shrink: 0;
    }
    .ct-step.done .ct-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
    .ct-step.active .ct-step-num { background: var(--color-accent); color: #fff; }
    .ct-step.active { color: var(--color-text-primary); font-weight: 500; }
    .ct-step-sep { color: var(--color-text-quaternary); }

    /* 2-col layout */
    .ct-split { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
    @media (max-width: 960px) { .ct-split { grid-template-columns: 1fr; } }
    .vc-left { min-width: 0; display: flex; flex-direction: column; gap: 14px; }

    /* Product card */
    .ct-product { padding: 0; }
    .ct-product-head {
        display: flex; align-items: flex-start; gap: 14px;
        padding: 22px 24px 18px;
        border-bottom: 0.5px solid var(--color-border);
    }
    .ct-product-ico {
        width: 48px; height: 48px; border-radius: 12px;
        background: var(--color-accent-light);
        color: var(--color-accent);
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ct-product-ico svg { width: 22px; height: 22px; }
    .ct-product-meta { flex: 1; min-width: 0; }
    .ct-product-eyebrow {
        font-size: 10.5px; font-weight: 600;
        color: var(--color-accent);
        text-transform: uppercase; letter-spacing: 0.06em;
        margin-bottom: 2px;
    }
    .ct-product-title {
        font-size: 18px; font-weight: 600;
        color: var(--color-text-primary);
        letter-spacing: -0.018em;
        margin: 0 0 3px;
    }
    .ct-product-domain {
        font-size: 12.5px; color: var(--color-text-tertiary);
        font-family: var(--font-mono, ui-monospace, Menlo, monospace);
        letter-spacing: 0;
    }
    .ct-product-remove {
        width: 32px; height: 32px; border-radius: 50%;
        background: transparent; border: 0;
        color: var(--color-text-tertiary);
        cursor: pointer; font-family: inherit;
        display: inline-flex; align-items: center; justify-content: center;
        transition: all var(--transition-fast);
        flex-shrink: 0; align-self: flex-start;
    }
    .ct-product-remove:hover { background: var(--color-red-bg); color: var(--color-red-text); }
    .ct-product-remove svg { width: 15px; height: 15px; }

    /* Addon rows */
    .ct-addons-head {
        padding: 14px 24px 8px;
        font-size: 11px; font-weight: 600;
        color: var(--color-text-tertiary);
        text-transform: uppercase; letter-spacing: 0.06em;
    }
    .ct-addon-row {
        display: grid; grid-template-columns: 28px 1fr auto;
        gap: 12px; align-items: center;
        padding: 12px 24px;
        border-bottom: 0.5px solid var(--color-border);
    }
    .ct-addon-row:last-of-type { border-bottom: 0; }
    .ct-addon-ico {
        width: 28px; height: 28px; border-radius: 8px;
        background: var(--color-surface-secondary);
        color: var(--color-text-secondary);
        display: inline-flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .ct-addon-ico svg { width: 13px; height: 13px; }
    .ct-addon-meta { min-width: 0; }
    .ct-addon-name {
        font-size: 13.5px; font-weight: 500;
        color: var(--color-text-primary);
        letter-spacing: -0.008em;
    }
    .ct-addon-sub {
        font-size: 11.5px; color: var(--color-text-tertiary);
        margin-top: 1px;
        letter-spacing: -0.004em;
    }
    .ct-addon-price {
        font-size: 12.5px; font-weight: 500;
        color: var(--color-text-primary);
        font-variant-numeric: tabular-nums;
        letter-spacing: -0.008em;
        white-space: nowrap;
    }
    .ct-addon-price.free {
        color: var(--color-green-text); font-weight: 600;
        font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em;
    }

    .ct-manage-addons {
        padding: 10px 24px 16px;
        border-bottom: 0.5px solid var(--color-border);
        font-size: 12.5px;
        display: flex; align-items: center; gap: 18px;
        flex-wrap: wrap;
    }
    .ct-manage-addons a {
        color: var(--color-accent); text-decoration: none;
        letter-spacing: -0.008em;
        display: inline-flex; align-items: center; gap: 4px;
        cursor: pointer;
    }
    .ct-manage-addons a:hover { color: var(--color-accent-hover); }
    .ct-manage-addons svg { width: 11px; height: 11px; }

    /* Product foot: cycle + price */
    .ct-product-foot {
        display: grid; grid-template-columns: 1fr auto; gap: 18px; align-items: center;
        padding: 18px 24px 20px;
    }
    @media (max-width: 560px) { .ct-product-foot { grid-template-columns: 1fr; } }
    .ct-cycle-row { display: flex; flex-direction: column; gap: 4px; min-width: 0; }
    .ct-cycle-label {
        font-size: 11px; font-weight: 600;
        color: var(--color-text-tertiary);
        letter-spacing: 0.04em; text-transform: uppercase;
    }
    .ct-cycle-value {
        font-size: 13.5px; font-weight: 500;
        color: var(--color-text-primary);
        letter-spacing: -0.008em;
    }
    .ct-product-price { text-align: right; min-width: 0; }
    .ct-product-price .amount {
        display: inline-flex; align-items: baseline; gap: 3px;
        font-size: 22px; font-weight: 600;
        color: var(--color-text-primary);
        letter-spacing: -0.025em;
        font-variant-numeric: tabular-nums;
        line-height: 1;
    }
    .ct-product-price .period {
        margin-top: 4px;
        font-size: 11.5px; color: var(--color-text-tertiary);
        letter-spacing: -0.004em;
    }

    /* Qty input (inline within head) */
    .ct-qty-row {
        padding: 12px 24px 0;
        display: inline-flex; align-items: center; gap: 8px;
        font-size: 12.5px; color: var(--color-text-secondary);
    }
    .ct-qty-row input[type="number"] {
        width: 64px; height: 32px;
        padding: 0 10px;
        border: 0.5px solid var(--color-border);
        border-radius: var(--radius-md, 8px);
        background: var(--color-surface);
        font-size: 13px; text-align: center;
        color: var(--color-text-primary);
        font-family: inherit;
        font-variant-numeric: tabular-nums;
    }
    .ct-qty-row button {
        height: 32px; padding: 0 12px;
        border-radius: var(--radius-pill);
        background: transparent;
        border: 0.5px solid var(--color-border);
        color: var(--color-text-primary);
        font-size: 12px; font-weight: 500;
        cursor: pointer; font-family: inherit;
    }

    /* Promo / taxes tabs */
    .ct-tabs-card { padding: 0; }
    .ct-tabs {
        display: flex; align-items: center; gap: 24px;
        border-bottom: 0.5px solid var(--color-border);
        padding: 0 24px;
    }
    .ct-tab {
        position: relative;
        padding: 14px 0;
        background: none; border: 0;
        font-size: 13px; font-weight: 500; letter-spacing: -0.008em;
        color: var(--color-text-tertiary);
        cursor: pointer; font-family: inherit;
        transition: color var(--transition-fast);
    }
    .ct-tab:hover { color: var(--color-text-primary); }
    .ct-tab.active { color: var(--color-accent); }
    .ct-tab.active::after {
        content: ""; position: absolute; left: 0; right: 0; bottom: -0.5px;
        height: 2px; background: var(--color-accent); border-radius: 2px 2px 0 0;
    }
    .ct-tab-panel { display: none; padding: 18px 24px 20px; }
    .ct-tab-panel.is-active { display: block; }

    .ct-promo-row { display: flex; gap: 8px; }
    .ct-promo-input-wrap {
        position: relative;
        flex: 1; min-width: 0;
    }
    .ct-promo-input-wrap svg {
        position: absolute; left: 14px; top: 50%;
        transform: translateY(-50%);
        width: 14px; height: 14px;
        color: var(--color-text-tertiary);
        pointer-events: none;
    }
    .ct-promo-input {
        width: 100%; height: 40px;
        padding: 0 14px 0 38px;
        border: 0.5px solid var(--color-border);
        border-radius: var(--radius-pill);
        background: var(--color-surface);
        font-size: 13.5px; letter-spacing: -0.008em;
        color: var(--color-text-primary);
        font-family: inherit;
    }
    .ct-promo-input::placeholder { color: var(--color-text-quaternary); }
    .ct-promo-input:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
    .ct-promo-apply {
        height: 40px; padding: 0 20px;
        border-radius: var(--radius-pill);
        background: var(--color-accent); color: #fff;
        border: 0;
        font-size: 13px; font-weight: 500;
        cursor: pointer; font-family: inherit;
        letter-spacing: -0.008em;
        flex-shrink: 0;
    }
    .ct-promo-apply:hover { background: var(--color-accent-hover); }
    .ct-promo-row .applied-pill {
        flex: 1; height: 40px;
        display: inline-flex; align-items: center; gap: 8px;
        padding: 0 14px;
        border-radius: var(--radius-pill);
        background: var(--color-green-bg); color: var(--color-green-text);
        font-size: 13px; font-weight: 500;
        letter-spacing: -0.008em;
    }
    .ct-promo-row .applied-pill svg { width: 14px; height: 14px; flex-shrink: 0; }
    .ct-promo-remove {
        height: 40px; padding: 0 16px;
        border-radius: var(--radius-pill);
        background: transparent;
        border: 0.5px solid var(--color-border);
        color: var(--color-text-secondary);
        font-size: 12.5px; font-weight: 500;
        cursor: pointer; font-family: inherit;
        text-decoration: none;
        display: inline-flex; align-items: center;
        flex-shrink: 0;
    }
    .ct-promo-remove:hover { color: var(--color-red-text); border-color: var(--color-red-text); }

    .ct-tax-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; }
    @media (max-width: 560px) { .ct-tax-grid { grid-template-columns: 1fr; } }
    .ct-tax-row { display: flex; flex-direction: column; gap: 5px; }
    .ct-tax-label {
        font-size: 11.5px; font-weight: 500;
        color: var(--color-text-secondary);
        letter-spacing: -0.004em;
    }
    .ct-tax-input {
        height: 36px; padding: 0 14px;
        border: 0.5px solid var(--color-border);
        border-radius: var(--radius-md, 8px);
        background: var(--color-surface);
        font-size: 13px; letter-spacing: -0.008em;
        color: var(--color-text-primary); font-family: inherit;
    }
    .ct-tax-input:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }

    /* Empty-cart link */
    .ct-bulk-empty {
        font-size: 12.5px; color: var(--color-text-tertiary);
        background: transparent; border: 0;
        cursor: pointer; padding: 0;
        font-family: inherit;
        display: inline-flex; align-items: center; gap: 5px;
        align-self: flex-end;
    }
    .ct-bulk-empty:hover { color: var(--color-red-text); }
    .ct-bulk-empty svg { width: 12px; height: 12px; }

    /* RIGHT: sticky order summary */
    .ct-summary-card { position: sticky; top: 72px; padding: 0; }
    .ct-summary-head {
        padding: 18px 20px 14px;
        border-bottom: 0.5px solid var(--color-border);
        display: flex; justify-content: space-between; align-items: baseline;
    }
    .ct-summary-head h2 {
        font-size: 14px; font-weight: 600;
        color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0;
    }
    .ct-summary-head .count {
        font-size: 12px; color: var(--color-text-tertiary);
        letter-spacing: -0.004em;
        font-variant-numeric: tabular-nums;
    }
    .ct-summary-head .loader { color: var(--color-text-tertiary); }

    .ct-summary-product {
        display: flex; align-items: center; justify-content: space-between;
        gap: 10px;
        padding: 14px 20px;
        border-bottom: 0.5px solid var(--color-border);
    }
    .ct-summary-product-meta { min-width: 0; }
    .ct-summary-product-name {
        font-size: 13.5px; font-weight: 600;
        color: var(--color-text-primary);
        letter-spacing: -0.008em;
    }
    .ct-summary-product-sub {
        font-size: 11.5px; color: var(--color-text-tertiary);
        margin-top: 2px; letter-spacing: -0.004em;
    }
    .ct-summary-product-price {
        font-size: 13px; font-weight: 600;
        color: var(--color-text-primary);
        font-variant-numeric: tabular-nums;
        letter-spacing: -0.008em;
        white-space: nowrap;
    }

    /* Totals block */
    .ct-totals {
        padding: 10px 20px;
        border-top: 0.5px solid var(--color-border);
    }
    .ct-totals-row {
        display: flex; justify-content: space-between; align-items: baseline;
        gap: 10px; padding: 7px 0;
        font-size: 12.5px;
        font-variant-numeric: tabular-nums;
        letter-spacing: -0.004em;
    }
    .ct-totals-row .label { color: var(--color-text-secondary); }
    .ct-totals-row .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; }
    .ct-totals-row.discount .value { color: var(--color-green-text); }

    .ct-recurring {
        padding: 10px 20px;
        border-top: 0.5px solid var(--color-border);
        font-size: 11.5px; color: var(--color-text-tertiary);
        letter-spacing: -0.004em;
    }
    .ct-recurring .recurring-charges { display: block; }
    .ct-recurring .cost {
        color: var(--color-text-primary); font-weight: 500;
        font-variant-numeric: tabular-nums;
    }

    .ct-summary-total {
        display: flex; justify-content: space-between; align-items: center;
        gap: 10px;
        padding: 18px 24px;
        border-top: 0.5px solid var(--color-border);
        background: var(--color-surface-tertiary);
        font-variant-numeric: tabular-nums;
    }
    .ct-summary-total .label {
        font-size: 15px; font-weight: 600;
        color: var(--color-text-primary); letter-spacing: -0.01em;
    }
    .ct-summary-total .value {
        font-size: 24px; font-weight: 600;
        color: var(--color-text-primary); letter-spacing: -0.025em;
        white-space: nowrap;
    }

    .ct-summary-footer {
        padding: 16px 20px 18px;
        display: flex; flex-direction: column; gap: 10px;
    }
    .ct-checkout-btn {
        height: 46px; padding: 0 20px;
        border-radius: var(--radius-pill);
        background: var(--color-accent); color: #fff; border: 0;
        font-size: 14px; font-weight: 500; letter-spacing: -0.008em;
        cursor: pointer; font-family: inherit;
        display: inline-flex; align-items: center; justify-content: center; gap: 8px;
        text-decoration: none;
        transition: background var(--transition-fast);
    }
    .ct-checkout-btn:hover { background: var(--color-accent-hover); color: #fff; }
    .ct-checkout-btn svg { width: 14px; height: 14px; }
    .ct-checkout-btn.disabled { opacity: 0.5; pointer-events: none; }
    .ct-continue-shop {
        font-size: 12.5px; color: var(--color-text-tertiary);
        text-align: center; text-decoration: none;
        display: inline-flex; align-items: center; justify-content: center; gap: 4px;
        letter-spacing: -0.004em;
    }
    .ct-continue-shop:hover { color: var(--color-accent); }
    .ct-continue-shop svg { width: 11px; height: 11px; }

    /* Trust strip */
    .ct-trust {
        padding: 12px 20px 16px;
        display: flex; flex-direction: column; gap: 6px;
        font-size: 11px; color: var(--color-text-tertiary);
        letter-spacing: -0.004em;
    }
    .ct-trust-item { display: inline-flex; align-items: center; gap: 6px; }
    .ct-trust-item svg { width: 12px; height: 12px; color: var(--color-green-text); flex-shrink: 0; }

    /* Express-checkout + gateway hook strip (server-rendered HTML, just gives it some breathing room) */
    .ct-express-row { padding: 0 20px 14px; display: flex; flex-direction: column; gap: 8px; }
    .ct-express-row .separator { text-align: center; font-size: 11px; color: var(--color-text-quaternary); letter-spacing: 0.05em; }
    .ct-hookout { margin-top: 12px; }

    /* "Recommended for you" offers card (mockup .ct-recommend-*) -- wraps
       the third-party $hookOutput so it sits in an Apple card with a
       proper header strip instead of bleeding raw HTML into the layout. */
    .ct-recommend { padding: 0; }
    .ct-recommend-head {
        padding: 16px 22px; border-bottom: 0.5px solid var(--color-border);
        display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
    }
    .ct-recommend-badge {
        padding: 3px 10px; border-radius: var(--radius-pill, 999px);
        background: var(--color-accent-light); color: var(--color-accent);
        font-size: 10px; font-weight: 600;
        letter-spacing: 0.06em; text-transform: uppercase;
    }
    .ct-recommend-title {
        font-size: 14px; font-weight: 600; color: var(--color-text-primary);
        letter-spacing: -0.012em;
    }
    .ct-recommend-sub {
        font-size: 11.5px; color: var(--color-text-tertiary);
        margin-left: auto; letter-spacing: -0.004em;
    }
    /* Inner $hookOutput is opaque marketing HTML (logos + bullets +
       Add to Cart) -- without intervention each item stacks vertically
       full-width. Force a responsive grid with bounded image sizes so
       it reads as a row of tiles. Mirrors checkout's .co-lastchance-body. */
    .ct-recommend-body { padding: 14px 18px 18px; display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; }
    .ct-recommend-body > div + div { margin-top: 0; }
    .ct-recommend-body > div {
        padding: 14px;
        border: 0.5px solid var(--color-border);
        border-radius: 12px;
        background: var(--color-surface-tertiary, var(--color-surface));
        display: flex; flex-direction: column;
        font-size: 12px;
        line-height: 1.45;
        color: var(--color-text-secondary);
        letter-spacing: -0.004em;
        min-height: 0;
        max-height: 280px;
        overflow: hidden;
        position: relative;
    }
    .ct-recommend-body > div img { max-width: 100%; max-height: 42px; object-fit: contain; align-self: flex-start; margin-bottom: 8px; }
    .ct-recommend-body > div br + br { display: none; }
    .ct-recommend-body > div p { margin: 0 0 4px; }
    .ct-recommend-body > div ul { margin: 6px 0 8px; padding-left: 18px; font-size: 11.5px; color: var(--color-text-tertiary); }
    .ct-recommend-body > div h2,
    .ct-recommend-body > div h3,
    .ct-recommend-body > div h4,
    .ct-recommend-body > div strong { font-size: 13px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 4px; letter-spacing: -0.008em; }
    .ct-recommend-body > div .btn,
    .ct-recommend-body > div button,
    .ct-recommend-body > div a.btn,
    .ct-recommend-body > div input[type="submit"],
    .ct-recommend-body > div input[type="button"] {
        margin-top: auto;
        align-self: flex-start;
        height: 32px;
        padding: 0 14px;
        border: 0.5px solid var(--color-border);
        border-radius: var(--radius-pill, 999px);
        background: transparent;
        color: var(--color-text-primary);
        font-size: 12px;
        font-weight: 500;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex; align-items: center;
        transition: all 0.15s;
    }
    .ct-recommend-body > div .btn:hover,
    .ct-recommend-body > div button:hover,
    .ct-recommend-body > div a.btn:hover {
        border-color: var(--color-accent);
        color: var(--color-accent);
    }

    /* Empty state */
    body[data-data="empty"] .vc-when-full { display: none; }
    body:not([data-data="empty"]) .vc-when-empty { display: none; }
    .ct-empty { padding: 72px 24px 64px; text-align: center; }
    .ct-empty-ico {
        width: 64px; height: 64px; border-radius: 50%;
        background: var(--color-surface-secondary);
        color: var(--color-text-tertiary);
        display: inline-flex; align-items: center; justify-content: center;
        margin-bottom: 18px;
    }
    .ct-empty-ico svg { width: 28px; height: 28px; }
    .ct-empty-title {
        font-size: 19px; font-weight: 600;
        color: var(--color-text-primary); letter-spacing: -0.016em;
        margin: 0 0 6px;
    }
    .ct-empty-desc {
        font-size: 14px; color: var(--color-text-tertiary);
        max-width: 420px; margin: 0 auto 22px;
        line-height: 1.55; letter-spacing: -0.008em;
    }
    .ct-empty-actions { display: inline-flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
    .ct-empty-actions .btn-primary, .ct-empty-actions .btn-secondary {
        height: 40px; padding: 0 20px; font-size: 13.5px;
        display: inline-flex; align-items: center; gap: 6px;
        text-decoration: none;
        border-radius: var(--radius-pill);
    }
    .ct-empty-actions .btn-primary { background: var(--color-accent); color: #fff; border: 0; }
    .ct-empty-actions .btn-primary:hover { background: var(--color-accent-hover); color: #fff; }
    .ct-empty-actions .btn-secondary { background: transparent; color: var(--color-text-primary); border: 0.5px solid var(--color-border); }
    .ct-empty-actions .btn-secondary:hover { border-color: var(--color-accent); color: var(--color-accent); }
    .ct-empty-actions svg { width: 13px; height: 13px; }

    /* Alerts (kept compact so they sit above the steps) */
    .vc-alert {
        padding: 12px 16px; border-radius: var(--radius-md, 10px);
        font-size: 13px; margin-bottom: 18px;
        border: 0.5px solid var(--color-border);
        background: var(--color-surface);
    }
    .vc-alert.warn   { border-color: var(--color-yellow-text, #b25c00); background: var(--color-yellow-bg, #fff7e6); color: var(--color-yellow-text, #b25c00); }
    .vc-alert.error  { border-color: var(--color-red-text); background: var(--color-red-bg); color: var(--color-red-text); }
    .vc-alert.info   { border-color: var(--color-accent); background: var(--color-accent-light); color: var(--color-accent); }
    .vc-alert.ok     { border-color: var(--color-green-text); background: var(--color-green-bg); color: var(--color-green-text); }
    .vc-alert ul { margin: 4px 0 0; padding-left: 18px; }

    /* ── Remove-item / Empty-cart confirm modal ──
       The TPL uses Bootstrap's .modal markup but the mytheme bundle
       doesn't ship Bootstrap's modal positioning, so the dialog used
       to drop in-flow at the bottom of the page. Re-implement just
       enough to render it as a centered overlay with the same Apple
       card chrome used elsewhere -- backdrop blur, soft shadow, no
       chrome-borrowed icons. Bootstrap's JS (jQuery.modal) already
       toggles `.show` / inline `display: block` and inserts the
       .modal-backdrop sibling, so these rules just style what's there. */
    .modal {
        position: fixed; inset: 0;
        z-index: 1050;
        display: none;
        align-items: center; justify-content: center;
        padding: 24px;
        overflow-y: auto;
    }
    .modal.show, .modal[style*="display: block"], .modal[style*="display:block"] {
        display: flex !important;
    }
    .modal-backdrop {
        position: fixed; inset: 0;
        z-index: 1040;
        background: rgba(0, 0, 0, 0.45);
        backdrop-filter: saturate(140%) blur(6px);
        -webkit-backdrop-filter: saturate(140%) blur(6px);
    }
    .modal-backdrop.show, .modal-backdrop.fade.in { opacity: 1; }
    .modal-dialog {
        position: relative;
        width: 100%; max-width: 420px;
        margin: 0;
    }
    .modal-content {
        background: var(--color-surface);
        border: 0.5px solid var(--color-border);
        border-radius: 16px;
        box-shadow: 0 24px 60px rgba(0, 0, 0, 0.22);
        overflow: hidden;
    }
    .modal-body {
        padding: 22px 24px 12px;
        font-size: 13.5px;
        line-height: 1.5;
        color: var(--color-text-secondary);
    }
    .modal-body .float-right { float: right; }
    .modal-body .close {
        appearance: none; background: transparent;
        border: 0; padding: 0;
        font-size: 22px; line-height: 1;
        color: var(--color-text-tertiary);
        cursor: pointer;
    }
    .modal-body .close:hover { color: var(--color-text-primary); }
    .modal-title {
        display: flex; align-items: center; gap: 10px;
        margin: 0 0 6px;
        font-size: 16px;
        font-weight: 600;
        color: var(--color-text-primary);
        letter-spacing: -0.01em;
    }
    .modal-title i { font-size: 18px; color: var(--color-red-text, #d70015); }
    .modal-title .fa-3x { font-size: 18px; }
    .modal-footer {
        display: flex; gap: 8px;
        justify-content: flex-end;
        padding: 14px 24px 18px;
        border-top: 0.5px solid var(--color-border);
        background: var(--color-surface-tertiary, transparent);
    }
    .modal-footer.justify-content-center { justify-content: center; }
    .modal-footer .btn,
    .modal-footer button {
        height: 36px;
        padding: 0 18px;
        border-radius: 999px;
        border: 0.5px solid var(--color-border);
        background: transparent;
        color: var(--color-text-primary);
        font-size: 13px; font-weight: 500;
        cursor: pointer;
        transition: all .12s ease;
    }
    .modal-footer .btn:hover,
    .modal-footer button:hover { border-color: var(--color-text-primary); }
    .modal-footer .btn-primary,
    .modal-footer button[type="submit"] {
        background: var(--color-red-text, #d70015);
        color: #fff;
        border-color: var(--color-red-text, #d70015);
    }
    .modal-footer .btn-primary:hover,
    .modal-footer button[type="submit"]:hover {
        filter: brightness(0.95);
        border-color: var(--color-red-text, #d70015);
    }
    body.modal-open { overflow: hidden; }

    {/literal}</style>

    {* Initial body state so the global state-chip overlay (Full/Empty)
       lines up with the actual server-side cart state on first paint.
       Without this the .vc-when-full block would always be visible even
       when the cart is empty.

       Also clear any stale hn.data preview state from localStorage:
       apple-layout.js's initStateToggles runs after partials load and
       resolves the chip state from (URL param > existing body attr >
       saved localStorage > 'full'). On real-cart routes the server's
       $cartitems is authoritative -- a previous chip click stored as
       'empty' should not hide a populated cart. Removing the saved key
       lets the body[data-data] we set below win the priority chain. *}
    <script>{literal}
    (function () {
        try { localStorage.removeItem('hn.data'); } catch (e) {}
        var d = document.body && document.body.dataset;
        if (d) {/literal} d.data = '{if $cartitems == 0}empty{else}full{/if}'; {literal} }
    })();
    {/literal}</script>

    <div id="order-standard_cart">

        {* ── Inline status / error / success messages (rendered ABOVE the
              page header so they're seen before the user scrolls). The
              alert classes match the mockup's compact muted style. ── *}
        {if $promoerrormessage}
            <div class="vc-alert warn" role="alert">{$promoerrormessage}</div>
        {elseif $errormessage}
            <div class="vc-alert error" role="alert">
                <strong>{$LANG.orderForm.correctErrors}:</strong>
                <ul>{$errormessage}</ul>
            </div>
        {elseif $promotioncode && $rawdiscount eq "0.00"}
            <div class="vc-alert info" role="alert">{$LANG.promoappliedbutnodiscount}</div>
        {elseif $promoaddedsuccess}
            <div class="vc-alert ok" role="alert">{$LANG.orderForm.promotionAccepted}</div>
        {/if}

        {if $bundlewarnings}
            <div class="vc-alert warn" role="alert">
                <strong>{$LANG.bundlereqsnotmet}</strong>
                <ul>
                    {foreach from=$bundlewarnings item=warning}
                        <li>{$warning}</li>
                    {/foreach}
                </ul>
            </div>
        {/if}

        {* ── Page header ── *}
        <header class="page-header">
            <div>
                <h1>{$LANG.viewcart|default:'Your cart'}</h1>
                <p class="sub">
                    {if $cartitems > 0}
                        <strong>{$cartitems} {if $cartitems == 1}item{else}items{/if}</strong>
                    {else}
                        {$LANG.cartempty|default:'Your cart is empty'}
                    {/if}
                </p>
            </div>
            <a href="{$WEB_ROOT}/cart.php" class="btn-secondary" style="height: 36px; padding: 0 16px; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; border-radius: 999px;">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 5 12 12 19"/></svg>
                {$LANG.orderForm.continueShopping|default:'Continue shopping'}
            </a>
        </header>

        {* ── Step strip (Cart = step 4 of 5) ── *}
        <div class="ct-steps" aria-label="Checkout progress">
            <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Choose plan</span>
            <span class="ct-step-sep">&rsaquo;</span>
            <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Domain</span>
            <span class="ct-step-sep">&rsaquo;</span>
            <span class="ct-step done"><span class="ct-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Configure</span>
            <span class="ct-step-sep">&rsaquo;</span>
            <span class="ct-step active"><span class="ct-step-num">4</span>Cart</span>
            <span class="ct-step-sep">&rsaquo;</span>
            <span class="ct-step"><span class="ct-step-num">5</span>Checkout</span>
        </div>

        {* ═══════════════════════════════════════════════════════════════
           FULL STATE — product cards + summary in a 2-col split
           ═══════════════════════════════════════════════════════════════ *}
        <div class="vc-when-full ct-split">

            <div class="vc-left">

                {* The main form wraps qty inputs + remove buttons. All
                   removeItem(...) calls open the #modalRemoveItem form
                   (which is its OWN form below) -- this form only carries
                   qty updates. *}
                <form method="post" action="{$smarty.server.PHP_SELF}?a=view">

                    {* ─── Products (one .ct-product card each, with nested addons) ─── *}
                    {foreach $products as $num => $product}
                        <div class="card ct-product" data-cart-item="product-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 4H4a2 2 0 00-2 2v12a2 2 0 002 2h16a2 2 0 002-2V6a2 2 0 00-2-2z"/><circle cx="12" cy="12" r="4"/></svg>
                                </div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{$product.productinfo.groupname}</div>
                                    <h2 class="ct-product-title">{$product.productinfo.name}</h2>
                                    {if $product.domain}
                                        <div class="ct-product-domain">{$product.domain}</div>
                                    {/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('p','{$num}')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>

                            {if $product.configoptions}
                                <div class="ct-addons-head">{$LANG.orderForm.config|default:'Configuration'}</div>
                                {foreach key=confnum item=configoption from=$product.configoptions}
                                    <div class="ct-addon-row" style="grid-template-columns: 1fr auto;">
                                        <div class="ct-addon-meta">
                                            <div class="ct-addon-name">{$configoption.name}</div>
                                        </div>
                                        <div class="ct-addon-price">
                                            {if $configoption.type eq 1 || $configoption.type eq 2}{$configoption.option}{elseif $configoption.type eq 3}{if $configoption.qty}{$configoption.option}{else}{$LANG.no}{/if}{elseif $configoption.type eq 4}{$configoption.qty} x {$configoption.option}{/if}
                                        </div>
                                    </div>
                                {/foreach}
                            {/if}

                            {if $product.addons}
                                <div class="ct-addons-head">{$LANG.orderaddons|default:'Included addons'} &middot; {$product.addons|@count}</div>
                                {foreach $product.addons as $addonnum => $addon}
                                    <div class="ct-addon-row">
                                        <div class="ct-addon-ico">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                        </div>
                                        <div class="ct-addon-meta">
                                            <div class="ct-addon-name">{$addon.name}</div>
                                            <div class="ct-addon-sub">{$addon.billingcyclefriendly}{if $addon.setup} &middot; {$addon.setup->toPrefixed()} {$LANG.ordersetupfee}{/if}</div>
                                        </div>
                                        <div class="ct-addon-price">{$addon.totaltoday}</div>
                                        {if $showAddonQtyOptions && $addon.allowqty === 2}
                                            <div class="ct-qty-row" style="grid-column: 1 / -1;">
                                                <label>{$LANG.orderForm.qty}</label>
                                                <input type="number" name="paddonqty[{$num}][{$addonnum}]" value="{$addon.qty}" min="0">
                                                <button type="submit">{$LANG.orderForm.update}</button>
                                            </div>
                                        {/if}
                                    </div>
                                {/foreach}
                            {/if}

                            <div class="ct-manage-addons">
                                <a href="{$WEB_ROOT}/cart.php?a=confproduct&i={$num}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    {$LANG.orderForm.edit|default:'Edit configuration'}
                                </a>
                            </div>

                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.cartbillingcycle|default:'Billing cycle'}</span>
                                    <span class="ct-cycle-value">{$product.billingcyclefriendly}</span>
                                </div>
                                <div class="ct-product-price">
                                    <span class="amount">{$product.pricing.totalTodayExcludingTaxSetup}</span>
                                    <div class="period">
                                        {if $product.pricing.productonlysetup}{$product.pricing.productonlysetup->toPrefixed()} {$LANG.ordersetupfee}{/if}
                                        {if $product.proratadate}{$LANG.orderprorata} {$product.proratadate}{/if}
                                    </div>
                                </div>
                            </div>

                            {if $showqtyoptions && $product.allowqty}
                                <div class="ct-qty-row" style="padding-bottom: 16px;">
                                    <label>{$LANG.orderForm.qty}</label>
                                    <input type="number" name="qty[{$num}]" value="{$product.qty}" min="0">
                                    <button type="submit">{$LANG.orderForm.update}</button>
                                </div>
                            {/if}
                        </div>
                    {/foreach}

                    {* ─── Standalone addons ─── *}
                    {foreach $addons as $num => $addon}
                        <div class="card ct-product" data-cart-item="addon-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                </div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{$LANG.orderaddon}</div>
                                    <h2 class="ct-product-title">{$addon.name}</h2>
                                    {if $addon.productname}<div class="ct-product-domain">{$addon.productname}{if $addon.domainname} &middot; {$addon.domainname}{/if}</div>{/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('a','{$num}')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.cartbillingcycle|default:'Billing cycle'}</span>
                                    <span class="ct-cycle-value">{$addon.billingcyclefriendly}</span>
                                </div>
                                <div class="ct-product-price">
                                    <span class="amount">{$addon.totaltoday}</span>
                                    <div class="period">
                                        {if $addon.setup}{$addon.setup->toPrefixed()} {$LANG.ordersetupfee}{/if}
                                        {if $addon.isProrated}{$LANG.orderprorata} {$addon.prorataDate}{/if}
                                    </div>
                                </div>
                            </div>
                            {if $showAddonQtyOptions && $addon.allowqty === 2}
                                <div class="ct-qty-row" style="padding-bottom: 16px;">
                                    <label>{$LANG.orderForm.qty}</label>
                                    <input type="number" name="addonqty[{$num}]" value="{$addon.qty}" min="0">
                                    <button type="submit">{$LANG.orderForm.update}</button>
                                </div>
                            {/if}
                        </div>
                    {/foreach}

                    {* ─── Domain registrations / transfers ─── *}
                    {foreach $domains as $num => $domain}
                        <div class="card ct-product" data-cart-item="domain-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                </div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{if $domain.type eq "register"}{$LANG.orderdomainregistration}{else}{$LANG.orderdomaintransfer}{/if}</div>
                                    <h2 class="ct-product-title">{$domain.domain}</h2>
                                    {if $domain.dnsmanagement || $domain.emailforwarding || $domain.idprotection}
                                        <div class="ct-product-domain" style="font-family: inherit;">
                                            {if $domain.dnsmanagement}&middot; {$LANG.domaindnsmanagement} {/if}
                                            {if $domain.emailforwarding}&middot; {$LANG.domainemailforwarding} {/if}
                                            {if $domain.idprotection}&middot; {$LANG.domainidprotection}{/if}
                                        </div>
                                    {/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('d','{$num}')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-manage-addons">
                                <a href="{$WEB_ROOT}/cart.php?a=confdomains">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                    {$LANG.orderForm.edit|default:'Edit'}
                                </a>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.orderForm.registrationPeriod|default:'Registration period'}</span>
                                    {if count($domain.pricing) == 1 || $domain.type == 'transfer'}
                                        <span class="ct-cycle-value">{$domain.regperiod} {$domain.yearsLanguage}</span>
                                    {else}
                                        {* Period selector: preserves selectDomainPeriodInCart() *}
                                        <select class="ct-cycle-value" style="padding: 4px 8px; border: 0.5px solid var(--color-border); border-radius: 6px; background: var(--color-surface); font: inherit;" id="{$domain.domain}Pricing" onchange="(function(o){ var p=o.value.split('|'); selectDomainPeriodInCart('{$domain.domain}', p[0], parseInt(p[1],10), p[2]); })(this)">
                                            {foreach $domain.pricing as $years => $price}
                                                <option value="{$price.register}|{$years}|{if $years == 1}{lang key='orderForm.year'}{else}{lang key='orderForm.years'}{/if}"{if $years == $domain.regperiod} selected{/if}>{$years} {if $years == 1}{lang key='orderForm.year'}{else}{lang key='orderForm.years'}{/if} @ {$price.register}</option>
                                            {/foreach}
                                        </select>
                                    {/if}
                                    {if isset($domain.renewprice)}
                                        <span class="ct-cycle-label" style="margin-top: 6px;">{lang key='domainrenewalprice'} {$domain.renewprice->toPrefixed()}{$domain.shortRenewalYearsLanguage}</span>
                                    {/if}
                                </div>
                                <div class="ct-product-price">
                                    <span class="amount" name="{$domain.domain}Price">{$domain.price}</span>
                                </div>
                            </div>
                        </div>
                    {/foreach}

                    {* ─── Service renewals ─── *}
                    {foreach $renewalsByType['services'] as $num => $service}
                        <div class="card ct-product" data-cart-item="srvrenew-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/><path d="M3 21v-5h5"/></svg></div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{lang key='renewService.titleAltSingular'}</div>
                                    <h2 class="ct-product-title">{$service.name}</h2>
                                    {if $service.domainName}<div class="ct-product-domain">{$service.domainName}</div>{/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('r','{$num}','service')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.cartbillingcycle|default:'Billing cycle'}</span>
                                    <span class="ct-cycle-value">{$service.billingCycle}</span>
                                </div>
                                <div class="ct-product-price"><span class="amount">{$service.recurringBeforeTax}</span></div>
                            </div>
                        </div>
                    {/foreach}

                    {* ─── Addon renewals ─── *}
                    {foreach $renewalsByType['addons'] as $num => $service}
                        <div class="card ct-product" data-cart-item="addonrenew-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0115-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 01-15 6.7L3 16"/><path d="M3 21v-5h5"/></svg></div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{lang key='renewServiceAddon.titleAltSingular'}</div>
                                    <h2 class="ct-product-title">{$service.name}</h2>
                                    {if $service.domainName}<div class="ct-product-domain">{$service.domainName}</div>{/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('r','{$num}','addon')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.cartbillingcycle|default:'Billing cycle'}</span>
                                    <span class="ct-cycle-value">{$service.billingCycle}</span>
                                </div>
                                <div class="ct-product-price"><span class="amount">{$service.recurringBeforeTax}</span></div>
                            </div>
                        </div>
                    {/foreach}

                    {* ─── Domain renewals ─── *}
                    {foreach $renewalsByType['domains'] as $num => $domain}
                        <div class="card ct-product" data-cart-item="domrenew-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg></div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{$LANG.domainrenewal}</div>
                                    <h2 class="ct-product-title">{$domain.domain}</h2>
                                    {if $domain.dnsmanagement || $domain.emailforwarding || $domain.idprotection}
                                        <div class="ct-product-domain" style="font-family: inherit;">
                                            {if $domain.dnsmanagement}&middot; {$LANG.domaindnsmanagement} {/if}
                                            {if $domain.emailforwarding}&middot; {$LANG.domainemailforwarding} {/if}
                                            {if $domain.idprotection}&middot; {$LANG.domainidprotection}{/if}
                                        </div>
                                    {/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('r','{$num}','domain')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.orderForm.registrationPeriod|default:'Period'}</span>
                                    <span class="ct-cycle-value">{$domain.regperiod} {$LANG.orderyears}</span>
                                </div>
                                <div class="ct-product-price"><span class="amount">{$domain.price}</span></div>
                            </div>
                        </div>
                    {/foreach}

                    {* ─── Upgrades ─── *}
                    {foreach $upgrades as $num => $upgrade}
                        <div class="card ct-product" data-cart-item="upgrade-{$num}">
                            <div class="ct-product-head">
                                <div class="ct-product-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 11 12 6 7 11"/><polyline points="17 18 12 13 7 18"/></svg></div>
                                <div class="ct-product-meta">
                                    <div class="ct-product-eyebrow">{$LANG.upgrade}</div>
                                    <h2 class="ct-product-title">
                                        {if $upgrade->type == 'service'}
                                            {$upgrade->originalProduct->name} &rarr; {$upgrade->newProduct->name}
                                        {elseif $upgrade->type == 'addon'}
                                            {$upgrade->originalAddon->name} &rarr; {$upgrade->newAddon->name}
                                        {/if}
                                    </h2>
                                    {if $upgrade->type == 'service' && $upgrade->service->domain}<div class="ct-product-domain">{$upgrade->service->domain}</div>{/if}
                                </div>
                                <button type="button" class="ct-product-remove" onclick="removeItem('u','{$num}')" title="{$LANG.orderForm.remove}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                                </button>
                            </div>
                            <div class="ct-product-foot">
                                <div class="ct-cycle-row">
                                    <span class="ct-cycle-label">{$LANG.cartbillingcycle|default:'Billing cycle'}</span>
                                    <span class="ct-cycle-value">{$upgrade->localisedNewCycle}</span>
                                </div>
                                <div class="ct-product-price"><span class="amount">{$upgrade->newRecurringAmount}</span></div>
                            </div>
                            {if $upgrade->totalDaysInCycle > 0}
                                <div class="ct-manage-addons" style="border-bottom: 0;">
                                    <span style="color: var(--color-green-text); font-weight: 500;">{$LANG.upgradeCredit}: -{$upgrade->creditAmount}</span>
                                    <span style="color: var(--color-text-tertiary); font-size: 11.5px;">{lang key="upgradeCreditDescription" daysRemaining=$upgrade->daysRemaining totalDays=$upgrade->totalDaysInCycle}</span>
                                </div>
                            {/if}
                            {if $showUpgradeQtyOptions && $upgrade->allowMultipleQuantities}
                                <div class="ct-qty-row" style="padding-bottom: 16px;">
                                    <label>{$LANG.orderForm.qty}</label>
                                    <input type="number" name="upgradeqty[{$num}]" value="{$upgrade->qty}" min="{$upgrade->minimumQuantity}">
                                    <button type="submit">{$LANG.orderForm.update}</button>
                                </div>
                            {/if}
                        </div>
                    {/foreach}

                </form>

                {if $cartitems > 0}
                    <button type="button" class="ct-bulk-empty" id="btnEmptyCart">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6m3 0V4a2 2 0 012-2h4a2 2 0 012 2v2"/></svg>
                        {$LANG.emptycart}
                    </button>
                {/if}

                {* ─── Promo / tax tabs ─── *}
                <div class="card ct-tabs-card">
                    <div class="ct-tabs" role="tablist">
                        <button type="button" class="ct-tab active" data-tab="promo">
                            {$LANG.orderForm.applyPromoCode}
                        </button>
                        {if $taxenabled && !$loggedin}
                            <button type="button" class="ct-tab" data-tab="tax">
                                {$LANG.orderForm.estimateTaxes}
                            </button>
                        {/if}
                    </div>

                    <div class="ct-tab-panel is-active" data-panel="promo">
                        {if $promotioncode}
                            <div class="ct-promo-row">
                                <span class="applied-pill">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    <strong>{$promotioncode}</strong> &middot; {$promotiondescription}
                                </span>
                                <a href="{$WEB_ROOT}/cart.php?a=removepromo" class="ct-promo-remove">{$LANG.orderForm.removePromotionCode}</a>
                            </div>
                        {else}
                            <form method="post" action="{$WEB_ROOT}/cart.php?a=view">
                                <div class="ct-promo-row">
                                    <div class="ct-promo-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 12V8H6a2 2 0 01-2-2c0-1.1.9-2 2-2h12v4"/><path d="M4 6v12c0 1.1.9 2 2 2h14v-4"/><path d="M18 12a2 2 0 00-2 2c0 1.1.9 2 2 2h4v-4h-4z"/></svg>
                                        <input type="text" name="promocode" id="inputPromotionCode" class="ct-promo-input" placeholder="{lang key='orderPromoCodePlaceholder'}" required>
                                    </div>
                                    <button type="submit" name="validatepromo" class="ct-promo-apply" value="{$LANG.orderpromovalidatebutton}">{$LANG.orderpromovalidatebutton}</button>
                                </div>
                            </form>
                        {/if}
                    </div>

                    {if $taxenabled && !$loggedin}
                        <div class="ct-tab-panel" data-panel="tax">
                            <form method="post" action="{$WEB_ROOT}/cart.php?a=setstateandcountry">
                                <div class="ct-tax-grid">
                                    <div class="ct-tax-row">
                                        <label class="ct-tax-label" for="inputState">{$LANG.orderForm.state}</label>
                                        <input id="inputState" type="text" name="state" value="{$clientsdetails.state}" class="ct-tax-input"{if $loggedin} disabled{/if}>
                                    </div>
                                    <div class="ct-tax-row">
                                        <label class="ct-tax-label" for="inputCountry">{$LANG.orderForm.country}</label>
                                        <select id="inputCountry" name="country" class="ct-tax-input">
                                            {foreach $countries as $countrycode => $countrylabel}
                                                <option value="{$countrycode}"{if (!$country && $countrycode == $defaultcountry) || $countrycode eq $country} selected{/if}>{$countrylabel}</option>
                                            {/foreach}
                                        </select>
                                    </div>
                                </div>
                                <button type="submit" class="ct-promo-apply" style="width: 100%;">{$LANG.orderForm.updateTotals}</button>
                            </form>
                        </div>
                    {/if}
                </div>

                {* ─── Hook output (3rd-party additions to the cart body) ───
                   Wrapped in the Apple .ct-recommend offers card so the
                   third-party HTML sits inside a styled "Recommended for
                   you" panel instead of bleeding raw markup into the
                   layout. The hook content itself stays untouched -- it
                   may render its own grid / cards / banner depending on
                   what the merchant has installed. *}
                {if $hookOutput}
                    <div class="card ct-recommend">
                        <div class="ct-recommend-head">
                            <span class="ct-recommend-badge">{$LANG.recommended|default:'Recommended'}</span>
                            <span class="ct-recommend-title">{$LANG.recommendedforyou|default:'Recommended for you'}</span>
                            <span class="ct-recommend-sub">{$LANG.oneclickadd|default:'One-click add. Remove anytime.'}</span>
                        </div>
                        <div class="ct-recommend-body">
                            {foreach $hookOutput as $output}
                                <div>{$output}</div>
                            {/foreach}
                        </div>
                    </div>
                {/if}

                {* Gateway-rendered checkout buttons stay as the gateway emits them
                   so any extra <form>s / scripts they bring still work. *}
                {if $gatewaysoutput}
                    <div class="ct-hookout">
                        {foreach $gatewaysoutput as $gatewayoutput}
                            <div class="view-cart-gateway-checkout">{$gatewayoutput}</div>
                        {/foreach}
                    </div>
                {/if}
            </div>

            {* ═══════════════════════════════════════════════════════════
               RIGHT — sticky summary card
               ═══════════════════════════════════════════════════════════ *}
            <aside id="scrollingPanelContainer">
                <div class="card ct-summary-card" id="orderSummary">
                    <div class="ct-summary-head">
                        <h2>{$LANG.ordersummary}</h2>
                        <span class="count">
                            {$cartitems} {if $cartitems == 1}item{else}items{/if}
                            <span class="loader w-hidden" id="orderSummaryLoader" aria-hidden="true" style="margin-left: 6px;">
                                <i class="fas fa-fw fa-sync fa-spin"></i>
                            </span>
                        </span>
                    </div>

                    {* Per-item rows — same hierarchy the user already saw above, in
                       compact form. *}
                    {foreach $products as $num => $product}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$product.productinfo.name}</div>
                                <div class="ct-summary-product-sub">{$product.productinfo.groupname} &middot; {$product.billingcyclefriendly}{if $product.domain} &middot; {$product.domain}{/if}</div>
                            </div>
                            <div class="ct-summary-product-price">{$product.pricing.totalTodayExcludingTaxSetup}</div>
                        </div>
                    {/foreach}
                    {foreach $addons as $num => $addon}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">+ {$addon.name}</div>
                                <div class="ct-summary-product-sub">{$LANG.orderaddon} &middot; {$addon.billingcyclefriendly}</div>
                            </div>
                            <div class="ct-summary-product-price">{$addon.totaltoday}</div>
                        </div>
                    {/foreach}
                    {foreach $domains as $num => $domain}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$domain.domain}</div>
                                <div class="ct-summary-product-sub">{if $domain.type eq "register"}{$LANG.orderdomainregistration}{else}{$LANG.orderdomaintransfer}{/if} &middot; {$domain.regperiod} {$domain.yearsLanguage}</div>
                            </div>
                            <div class="ct-summary-product-price">{$domain.price}</div>
                        </div>
                    {/foreach}
                    {foreach $renewalsByType['services'] as $num => $service}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$service.name}</div>
                                <div class="ct-summary-product-sub">{lang key='renewService.titleAltSingular'} &middot; {$service.billingCycle}{if $service.domainName} &middot; {$service.domainName}{/if}</div>
                            </div>
                            <div class="ct-summary-product-price">{$service.recurringBeforeTax}</div>
                        </div>
                    {/foreach}
                    {foreach $renewalsByType['addons'] as $num => $service}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$service.name}</div>
                                <div class="ct-summary-product-sub">{lang key='renewServiceAddon.titleAltSingular'} &middot; {$service.billingCycle}</div>
                            </div>
                            <div class="ct-summary-product-price">{$service.recurringBeforeTax}</div>
                        </div>
                    {/foreach}
                    {foreach $renewalsByType['domains'] as $num => $domain}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$domain.domain}</div>
                                <div class="ct-summary-product-sub">{$LANG.domainrenewal} &middot; {$domain.regperiod} {$LANG.orderyears}</div>
                            </div>
                            <div class="ct-summary-product-price">{$domain.price}</div>
                        </div>
                    {/foreach}
                    {foreach $upgrades as $num => $upgrade}
                        <div class="ct-summary-product">
                            <div class="ct-summary-product-meta">
                                <div class="ct-summary-product-name">{$LANG.upgrade}</div>
                                <div class="ct-summary-product-sub">{$upgrade->localisedNewCycle}</div>
                            </div>
                            <div class="ct-summary-product-price">{$upgrade->newRecurringAmount}</div>
                        </div>
                    {/foreach}

                    {* Totals: subtotal + discount + taxes (preserves ALL scripts.js-bound IDs) *}
                    <div class="ct-totals">
                        <div class="ct-totals-row">
                            <span class="label">{$LANG.ordersubtotal}</span>
                            <span class="value" id="subtotal">{$subtotal}</span>
                        </div>
                        {if $promotioncode}
                            <div class="ct-totals-row discount">
                                <span class="label">{$promotiondescription}</span>
                                <span class="value" id="discount">{$discount}</span>
                            </div>
                        {/if}
                        {if $taxrate}
                            <div class="ct-totals-row">
                                <span class="label">{$taxname} @ {$taxrate}%</span>
                                <span class="value" id="taxTotal1">{$taxtotal}</span>
                            </div>
                        {/if}
                        {if $taxrate2}
                            <div class="ct-totals-row">
                                <span class="label">{$taxname2} @ {$taxrate2}%</span>
                                <span class="value" id="taxTotal2">{$taxtotal2}</span>
                            </div>
                        {/if}
                    </div>

                    {* Recurring totals strip -- preserves the per-cycle <span>s
                       scripts.js toggles via display:none / display:inline. *}
                    <div class="ct-recurring">
                        <div style="font-weight: 500; color: var(--color-text-secondary); margin-bottom: 4px;">{$LANG.orderForm.totals}</div>
                        <span id="recurring" class="recurring-charges">
                            <span id="recurringMonthly" {if !$totalrecurringmonthly}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringmonthly}</span> {$LANG.orderpaymenttermmonthly}<br>
                            </span>
                            <span id="recurringQuarterly" {if !$totalrecurringquarterly}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringquarterly}</span> {$LANG.orderpaymenttermquarterly}<br>
                            </span>
                            <span id="recurringSemiAnnually" {if !$totalrecurringsemiannually}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringsemiannually}</span> {$LANG.orderpaymenttermsemiannually}<br>
                            </span>
                            <span id="recurringAnnually" {if !$totalrecurringannually}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringannually}</span> {$LANG.orderpaymenttermannually}<br>
                            </span>
                            <span id="recurringBiennially" {if !$totalrecurringbiennially}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringbiennially}</span> {$LANG.orderpaymenttermbiennially}<br>
                            </span>
                            <span id="recurringTriennially" {if !$totalrecurringtriennially}style="display:none;"{/if}>
                                <span class="cost">{$totalrecurringtriennially}</span> {$LANG.orderpaymenttermtriennially}<br>
                            </span>
                        </span>
                    </div>

                    <div class="ct-summary-total">
                        <span class="label">{$LANG.ordertotalduetoday}</span>
                        <span class="value" id="totalDueToday">{$total}</span>
                    </div>

                    {if $expressCheckoutButtons}
                        <div class="ct-express-row">
                            {foreach $expressCheckoutButtons as $checkoutButton}
                                {$checkoutButton}
                                <div class="separator">&mdash; {$LANG.or|strtoupper} &mdash;</div>
                            {/foreach}
                        </div>
                    {/if}

                    <div class="ct-summary-footer">
                        <a href="{$WEB_ROOT}/cart.php?a=checkout&e=false" id="checkout" class="ct-checkout-btn{if $cartitems == 0} disabled{/if}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            {$LANG.orderForm.checkout}
                        </a>
                        <a href="{$WEB_ROOT}/cart.php" id="continueShopping" class="ct-continue-shop">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                            {$LANG.orderForm.continueShopping}
                        </a>
                    </div>

                    <div class="ct-trust">
                        <span class="ct-trust-item"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>{$LANG.cartsecured|default:'256-bit SSL · PCI-DSS Level 1'}</span>
                        <span class="ct-trust-item"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>{$LANG.cartmoneyback|default:'30-day money-back guarantee'}</span>
                    </div>
                </div>
            </aside>
        </div>

        {* ═══════════════════════════════════════════════════════════════
           EMPTY STATE
           ═══════════════════════════════════════════════════════════════ *}
        <div class="vc-when-empty">
            <div class="card ct-empty">
                <div class="ct-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                </div>
                <h2 class="ct-empty-title">{$LANG.cartempty|default:'Your cart is empty'}</h2>
                <p class="ct-empty-desc">{$LANG.cartemptysub|default:'Browse our plans and add something to get started. Everything comes with a 30-day money-back guarantee.'}</p>
                <div class="ct-empty-actions">
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>
                        {$LANG.orderForm.continueShopping|default:'Browse plans'}
                    </a>
                    <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="btn-secondary">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                        {$LANG.cartregisterdomainchoice|default:'Register a domain'}
                    </a>
                </div>
            </div>
        </div>

        {* ═══════════════════════════════════════════════════════════════
           Remove-item modal -- populated by removeItem(type, ref[, rType])
           inline JS from scripts.js. Form posts to cart.php?a=remove.
           ═══════════════════════════════════════════════════════════════ *}
        <form method="post" action="{$WEB_ROOT}/cart.php">
            <input type="hidden" name="a" value="remove">
            <input type="hidden" name="r" value="" id="inputRemoveItemType">
            <input type="hidden" name="i" value="" id="inputRemoveItemRef">
            <input type="hidden" name="rt" value="" id="inputRemoveItemRenewalType">
            <div class="modal fade modal-remove-item" id="modalRemoveItem" tabindex="-1" role="dialog">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-body">
                            <div class="float-right">
                                <button type="button" class="close" data-dismiss="modal" aria-label="{lang key='orderForm.close'}"><span aria-hidden="true">&times;</span></button>
                            </div>
                            <h4 class="modal-title margin-bottom mb-3">
                                <i class="fas fa-times fa-3x"></i>
                                <span>{lang key='orderForm.removeItem'}</span>
                            </h4>
                            {lang key='cartremoveitemconfirm'}
                        </div>
                        <div class="modal-footer justify-content-center">
                            <button type="button" class="btn btn-default" data-dismiss="modal">{lang key='no'}</button>
                            <button type="submit" class="btn btn-primary">{lang key='yes'}</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        {* ═══════════════════════════════════════════════════════════════
           Empty-cart modal -- triggered by #btnEmptyCart click.
           ═══════════════════════════════════════════════════════════════ *}
        <form method="post" action="{$WEB_ROOT}/cart.php">
            <input type="hidden" name="a" value="empty">
            <div class="modal fade modal-remove-item" id="modalEmptyCart" tabindex="-1" role="dialog">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-body">
                            <div class="float-right">
                                <button type="button" class="close" data-dismiss="modal" aria-label="{$LANG.orderForm.close}"><span aria-hidden="true">&times;</span></button>
                            </div>
                            <h4 class="modal-title margin-bottom mb-3">
                                <i class="fas fa-trash-alt fa-3x"></i>
                                <span>{$LANG.emptycart}</span>
                            </h4>
                            {$LANG.cartemptyconfirm}
                        </div>
                        <div class="modal-footer justify-content-center">
                            <button type="button" class="btn btn-default" data-dismiss="modal">{$LANG.no}</button>
                            <button type="submit" class="btn btn-primary">{$LANG.yes}</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>

    </div>{* /#order-standard_cart *}

    {include file="orderforms/standard_cart/recommendations-modal.tpl"}

    <script>{literal}
    (function () {
        // Tabs -- promo / estimate-taxes
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

        // #btnEmptyCart -- standard_cart's scripts.min.js wires this up via
        // Bootstrap's data-toggle modal, but our button has no data-toggle
        // attribute (we kept it text-link styled). Open #modalEmptyCart
        // manually so the empty-cart form is reachable.
        var btn = document.getElementById('btnEmptyCart');
        if (btn) {
            btn.addEventListener('click', function () {
                if (window.jQuery && jQuery.fn.modal) {
                    jQuery('#modalEmptyCart').modal('show');
                }
            });
        }
    })();
    {/literal}</script>

{/if}
