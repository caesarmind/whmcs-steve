{*
 * mytheme_cart/checkout.tpl — Final checkout / place-order page.
 *
 * Rendered URL: /cart.php?a=checkout
 *
 * Visual source: apple-client-area/checkout.html
 * Layout: page header → step strip → 2-col split
 *         Left:  cart items list → (account section if guest) →
 *                billing details form → payment method picker →
 *                terms checkbox
 *         Right (sticky): order summary + place-order button
 *
 * Available Smarty variables (WHMCS cart-checkout bootstrap):
 *   $loggedin           — bool, whether the user is signed in
 *   $clientdetails      — { firstname, lastname, email, address1,
 *                            city, state, postcode, country,
 *                            phonenumber, companyname }
 *   $products, $domains — cart contents (same shape as viewcart)
 *   $cartitemcount      — count for header
 *   $totaltodaytext     — formatted total due today
 *   $rawdata.subtotal, .taxtotal, .total
 *   $countries          — { code => name } for country select
 *   $paymentmethods     — { module => name } available gateways
 *   $defaultgateway
 *   $loginsession_id    — used to prevent CSRF
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* ── checkout.tpl page-specific styles (.co-*).
   Apple-language port of apple-client-area/checkout.html. ── */

.co-page-header { margin-bottom: 24px; }
.co-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.co-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; line-height: 1.5; margin: 0; max-width: 620px; }

.co-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.co-step { display: inline-flex; align-items: center; gap: 8px; }
.co-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.co-step.done .co-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.co-step.active .co-step-num { background: var(--color-accent); color: #fff; }
.co-step.active { color: var(--color-text-primary); font-weight: 500; }
.co-step-sep { color: var(--color-text-quaternary); }

.co-split { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
@media (max-width: 960px) { .co-split { grid-template-columns: 1fr; } }

.co-section { padding: 0; }
.co-section-head { padding: 18px 22px 14px; border-bottom: 0.5px solid var(--color-border); display: flex; justify-content: space-between; align-items: center; gap: 12px; flex-wrap: wrap; }
.co-section-title { font-size: 15px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.012em; margin: 0; }
.co-section-head-action { font-size: 12.5px; color: var(--color-accent); text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
.co-section-head-action:hover { color: var(--color-accent-hover); }
.co-section-head-action svg { width: 12px; height: 12px; }
.co-section-body { padding: 14px 22px 18px; }

/* Cart items list */
.co-item { display: grid; grid-template-columns: 36px 1fr auto; gap: 14px; align-items: flex-start; padding: 14px 0; border-bottom: 0.5px solid var(--color-border); }
.co-item:last-child { border-bottom: 0; }
.co-item-ico { width: 36px; height: 36px; border-radius: 10px; background: var(--color-accent-light); color: var(--color-accent); display: flex; align-items: center; justify-content: center; }
.co-item-ico.domain { background: var(--color-green-bg); color: var(--color-green-text); }
.co-item-ico.addon { background: var(--color-surface-secondary); color: var(--color-text-secondary); }
.co-item-ico svg { width: 18px; height: 18px; }
.co-item-meta { min-width: 0; }
.co-item-name { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; }
.co-item-sub { font-size: 12px; color: var(--color-text-tertiary); margin-top: 2px; letter-spacing: -0.004em; }
.co-item-right { text-align: right; }
.co-item-price { font-size: 14px; font-weight: 600; color: var(--color-text-primary); font-variant-numeric: tabular-nums; white-space: nowrap; }
.co-item-price .period { font-size: 11px; color: var(--color-text-tertiary); font-weight: 400; }
.co-item-price.free { color: var(--color-green-text); text-transform: uppercase; font-size: 11px; letter-spacing: 0.04em; }
.co-item-actions { display: flex; gap: 4px; justify-content: flex-end; margin-top: 4px; }
.co-item-btn { width: 26px; height: 26px; border-radius: 50%; background: transparent; border: 0; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; transition: all var(--transition-fast); }
.co-item-btn:hover { background: var(--color-accent-light); color: var(--color-accent); }
.co-item-btn.danger:hover { background: var(--color-red-bg); color: var(--color-red-text); }
.co-item-btn svg { width: 12px; height: 12px; }

/* Form fields */
.co-form { display: flex; flex-direction: column; gap: 14px; }
.co-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.co-form-grid.col3 { grid-template-columns: 2fr 1fr 1fr; }
@media (max-width: 640px) { .co-form-grid, .co-form-grid.col3 { grid-template-columns: 1fr; } }
.co-row { display: flex; flex-direction: column; gap: 6px; }
.co-label { font-size: 12px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; }
.co-input, .co-select { height: 40px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 14px; letter-spacing: -0.008em; color: var(--color-text-primary); font-family: inherit; width: 100%; transition: all var(--transition-fast); box-sizing: border-box; }
.co-input:focus, .co-select:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.co-select { appearance: none; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 12px center; padding-right: 36px; cursor: pointer; }

.co-account-type { display: inline-flex; gap: 0; padding: 3px; border-radius: var(--radius-pill); background: var(--color-surface-secondary); }
.co-account-type label { padding: 6px 14px; border-radius: var(--radius-pill); font-size: 13px; color: var(--color-text-secondary); cursor: pointer; display: inline-flex; align-items: center; gap: 6px; letter-spacing: -0.008em; }
.co-account-type label:has(input:checked) { background: var(--color-surface); color: var(--color-text-primary); box-shadow: 0 1px 3px rgba(0,0,0,0.06); }
.co-account-type input { position: absolute; opacity: 0; pointer-events: none; }

/* Account create/signin tabs */
.co-auth-tabs { display: flex; align-items: center; gap: 24px; border-bottom: 0.5px solid var(--color-border); padding: 0 22px; }
.co-auth-tab { position: relative; padding: 14px 0; background: none; border: 0; font-size: 13px; font-weight: 500; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; transition: color var(--transition-fast); letter-spacing: -0.008em; }
.co-auth-tab:hover { color: var(--color-text-primary); }
.co-auth-tab.active { color: var(--color-accent); }
.co-auth-tab.active::after { content: ""; position: absolute; left: 0; right: 0; bottom: -0.5px; height: 2px; background: var(--color-accent); border-radius: 2px 2px 0 0; }
.co-auth-panel { display: none; padding: 18px 22px 20px; }
.co-auth-panel.is-active { display: block; }
.co-auth-hint { font-size: 13px; color: var(--color-text-tertiary); letter-spacing: -0.004em; margin: 0 0 14px; line-height: 1.5; }
.co-forgot-link { font-size: 11.5px; color: var(--color-accent); text-decoration: none; }
.co-signin-row { display: flex; justify-content: space-between; align-items: baseline; }
.co-signin-btn { height: 42px; padding: 0 20px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; gap: 6px; transition: background var(--transition-fast); }
.co-signin-btn:hover { background: var(--color-accent-hover); color: #fff; }
.co-signin-btn svg { width: 13px; height: 13px; }

/* Payment methods */
.co-pay-list { display: flex; flex-direction: column; gap: 8px; }
.co-pay { display: flex; align-items: center; gap: 12px; padding: 14px 16px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); cursor: pointer; transition: all var(--transition-fast); }
.co-pay:hover { border-color: var(--color-accent); }
.co-pay:has(input:checked) { border-color: var(--color-accent); background: var(--color-accent-light); }
.co-pay input { position: absolute; opacity: 0; pointer-events: none; }
.co-pay-radio { width: 18px; height: 18px; border-radius: 50%; border: 1.5px solid var(--color-border); background: var(--color-surface); display: flex; align-items: center; justify-content: center; flex-shrink: 0; transition: all var(--transition-fast); }
.co-pay-radio::after { content: ""; width: 8px; height: 8px; border-radius: 50%; background: #fff; transform: scale(0); transition: transform var(--transition-fast); }
.co-pay:has(input:checked) .co-pay-radio { border-color: var(--color-accent); background: var(--color-accent); }
.co-pay:has(input:checked) .co-pay-radio::after { transform: scale(1); }
.co-pay-logo { width: 40px; height: 28px; border-radius: 4px; background: var(--color-surface-secondary); color: var(--color-text-secondary); display: inline-flex; align-items: center; justify-content: center; font-size: 9.5px; font-weight: 700; letter-spacing: 0.04em; flex-shrink: 0; }
.co-pay-meta { flex: 1; min-width: 0; }
.co-pay-name { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; }
.co-pay-sub { font-size: 11.5px; color: var(--color-text-tertiary); margin-top: 1px; letter-spacing: -0.004em; }

/* Terms */
.co-terms { display: flex; align-items: flex-start; gap: 10px; padding: 16px 18px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-md); font-size: 13px; color: var(--color-text-secondary); letter-spacing: -0.004em; line-height: 1.55; }
.co-terms input { accent-color: var(--color-accent); margin-top: 3px; flex-shrink: 0; }
.co-terms a { color: var(--color-accent); text-decoration: none; }
.co-terms a:hover { text-decoration: underline; }

/* Summary */
.co-summary-card { position: sticky; top: 72px; padding: 0; }
.co-summary-head { padding: 18px 20px 14px; border-bottom: 0.5px solid var(--color-border); }
.co-summary-head h2 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0; }
.co-summary-list { padding: 8px 20px; }
.co-summary-line { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; padding: 8px 0; font-size: 12.5px; font-variant-numeric: tabular-nums; letter-spacing: -0.004em; }
.co-summary-line .label { color: var(--color-text-secondary); flex: 1; min-width: 0; }
.co-summary-line .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; }
.co-summary-line .value.muted { color: var(--color-text-tertiary); font-weight: 400; }
.co-summary-line .value.good { color: var(--color-green-text); font-weight: 500; }
.co-summary-line.divider { border-top: 0.5px solid var(--color-border); padding-top: 12px; margin-top: 4px; }
.co-summary-total { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding: 14px 20px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); font-variant-numeric: tabular-nums; }
.co-summary-total .label { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; }
.co-summary-total .value { font-size: 22px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.022em; white-space: nowrap; }
.co-summary-footer { padding: 16px 20px 18px; border-top: 0.5px solid var(--color-border); display: flex; flex-direction: column; gap: 10px; }
.co-place-order { height: 48px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14.5px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; gap: 8px; transition: background var(--transition-fast); }
.co-place-order:hover { background: var(--color-accent-hover); }
.co-place-order svg { width: 15px; height: 15px; }
.co-trust { padding: 12px 20px 16px; display: flex; flex-direction: column; gap: 6px; font-size: 11px; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.co-trust-item { display: inline-flex; align-items: center; gap: 6px; }
.co-trust-item svg { width: 12px; height: 12px; color: var(--color-green-text); flex-shrink: 0; }
{/literal}</style>

<div class="content-area">
    <header class="co-page-header">
        <h1>Checkout</h1>
        <p class="page-subtitle">Review your items, enter your billing details, and pick a way to pay.</p>
    </header>

    <div class="co-steps">
        <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Choose plan</span>
        <span class="co-step-sep">›</span>
        <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Domain</span>
        <span class="co-step-sep">›</span>
        <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Configure</span>
        <span class="co-step-sep">›</span>
        <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Cart</span>
        <span class="co-step-sep">›</span>
        <span class="co-step active"><span class="co-step-num">5</span>Checkout</span>
    </div>

    <form method="post" action="{$WEB_ROOT}/cart.php?a=checkout" id="checkoutForm">
        <input type="hidden" name="submit" value="true">
        {if $token}<input type="hidden" name="token" value="{$token|escape}">{/if}

        <div class="co-split">

            {* ══ LEFT — items + (account if guest) + billing + payment + terms ══ *}
            <div style="min-width: 0; display: flex; flex-direction: column; gap: 16px;">

                {* Items in cart — read-only summary list *}
                <div class="card co-section">
                    <div class="co-section-head">
                        <h2 class="co-section-title">
                            Items in your cart
                            <span style="color: var(--color-text-tertiary); font-weight: 500; margin-left: 4px;">· {$cartitemcount|default:0}</span>
                        </h2>
                        <a href="{$WEB_ROOT}/cart.php" class="co-section-head-action">
                            Add another
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                    </div>
                    <div class="co-section-body">
                        {if $products}
                            {foreach $products as $p}
                                <div class="co-item">
                                    <div class="co-item-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20 4H4a2 2 0 00-2 2v12a2 2 0 002 2h16a2 2 0 002-2V6a2 2 0 00-2-2z"/><circle cx="12" cy="12" r="4"/></svg></div>
                                    <div class="co-item-meta">
                                        <div class="co-item-name">{if $p.group}{$p.group|escape} · {/if}{$p.name|escape}</div>
                                        <div class="co-item-sub">{$p.billingcycle|capitalize|escape}{if $p.domain} · {$p.domain|escape}{/if}</div>
                                    </div>
                                    <div class="co-item-right">
                                        <div class="co-item-price">{$p.pricing}</div>
                                        <div class="co-item-actions">
                                            <a href="{$WEB_ROOT}/cart.php?a=confproduct&i={$p@iteration - 1}" class="co-item-btn" title="Edit">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            {/foreach}
                        {/if}
                        {if $domains}
                            {foreach $domains as $d}
                                <div class="co-item">
                                    <div class="co-item-ico domain"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                                    <div class="co-item-meta">
                                        <div class="co-item-name" style="font-family: var(--font-mono, ui-monospace, Menlo, monospace); font-size: 13.5px;">{$d.domain|escape}</div>
                                        <div class="co-item-sub">{if $d.type == 'register'}Register{elseif $d.type == 'transfer'}Transfer{/if} · {$d.regperiod|escape} year(s)</div>
                                    </div>
                                    <div class="co-item-right">
                                        <div class="co-item-price">{$d.pricing}</div>
                                    </div>
                                </div>
                            {/foreach}
                        {/if}
                    </div>
                </div>

                {* Account (guest only) *}
                {if !$loggedin}
                    <div class="card co-section">
                        <div class="co-section-head">
                            <h2 class="co-section-title">Your account</h2>
                        </div>
                        <div class="co-auth-tabs" role="tablist">
                            <button type="button" class="co-auth-tab active" data-atab="create">Create an account</button>
                            <button type="button" class="co-auth-tab" data-atab="signin">I already have one</button>
                        </div>

                        <div class="co-auth-panel is-active" data-apanel="create">
                            <p class="co-auth-hint">We'll use this for your invoices and to let you manage your services later.</p>
                            <div class="co-form">
                                <div class="co-row">
                                    <label class="co-label" for="acct-email">Email address</label>
                                    <input id="acct-email" name="email" type="email" class="co-input" placeholder="you@example.com" autocomplete="email" required>
                                </div>
                                <div class="co-form-grid">
                                    <div class="co-row">
                                        <label class="co-label" for="acct-pw">Password</label>
                                        <input id="acct-pw" name="password" type="password" class="co-input" placeholder="At least 8 characters" autocomplete="new-password" required>
                                    </div>
                                    <div class="co-row">
                                        <label class="co-label" for="acct-pw2">Confirm password</label>
                                        <input id="acct-pw2" name="password2" type="password" class="co-input" placeholder="Repeat password" autocomplete="new-password" required>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="co-auth-panel" data-apanel="signin">
                            <p class="co-auth-hint">Sign in with the account you already have and we'll use its details for this order.</p>
                            <div class="co-form">
                                <div class="co-row">
                                    <label class="co-label" for="signin-email">Email address</label>
                                    <input id="signin-email" name="loginemail" type="email" class="co-input" placeholder="you@example.com" autocomplete="email">
                                </div>
                                <div class="co-row">
                                    <div class="co-signin-row">
                                        <label class="co-label" for="signin-pw">Password</label>
                                        <a href="{$WEB_ROOT}/pwreset.php" class="co-forgot-link">Forgot your password?</a>
                                    </div>
                                    <input id="signin-pw" name="loginpassword" type="password" class="co-input" placeholder="Your password" autocomplete="current-password">
                                </div>
                                <button type="submit" name="login" value="true" class="co-signin-btn">
                                    Sign in and continue
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                                </button>
                            </div>
                        </div>
                    </div>
                {/if}

                {* Billing details *}
                <div class="card co-section">
                    <div class="co-section-head">
                        <h2 class="co-section-title">Billing details</h2>
                        {if $loggedin}
                            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="co-section-head-action">Use account details</a>
                        {/if}
                    </div>
                    <div class="co-section-body">
                        <div class="co-form">
                            <div class="co-row">
                                <label class="co-label">Account type</label>
                                <div class="co-account-type">
                                    <label>Individual <input type="radio" name="accounttype" value="individual" checked></label>
                                    <label>Business <input type="radio" name="accounttype" value="business"></label>
                                </div>
                            </div>
                            <div class="co-form-grid">
                                <div class="co-row">
                                    <label class="co-label" for="co-first">First name</label>
                                    <input id="co-first" name="firstname" type="text" class="co-input" value="{$clientdetails.firstname|escape}" autocomplete="given-name" required>
                                </div>
                                <div class="co-row">
                                    <label class="co-label" for="co-last">Last name</label>
                                    <input id="co-last" name="lastname" type="text" class="co-input" value="{$clientdetails.lastname|escape}" autocomplete="family-name" required>
                                </div>
                            </div>
                            <div class="co-form-grid">
                                {if $loggedin}
                                    <div class="co-row">
                                        <label class="co-label" for="co-email">Email</label>
                                        <input id="co-email" name="email" type="email" class="co-input" value="{$clientdetails.email|escape}" autocomplete="email" required>
                                    </div>
                                {/if}
                                <div class="co-row">
                                    <label class="co-label" for="co-phone">Phone</label>
                                    <input id="co-phone" name="phonenumber" type="tel" class="co-input" value="{$clientdetails.phonenumber|escape}" placeholder="+1 555 123 4567" autocomplete="tel">
                                </div>
                            </div>
                            <div class="co-row">
                                <label class="co-label" for="co-company">Company name (optional)</label>
                                <input id="co-company" name="companyname" type="text" class="co-input" value="{$clientdetails.companyname|escape}" autocomplete="organization">
                            </div>
                            <div class="co-row">
                                <label class="co-label" for="co-street">Street address</label>
                                <input id="co-street" name="address1" type="text" class="co-input" value="{$clientdetails.address1|escape}" placeholder="742 Evergreen Terrace" autocomplete="street-address" required>
                            </div>
                            <div class="co-form-grid col3">
                                <div class="co-row">
                                    <label class="co-label" for="co-city">City</label>
                                    <input id="co-city" name="city" type="text" class="co-input" value="{$clientdetails.city|escape}" placeholder="Springfield" autocomplete="address-level2" required>
                                </div>
                                <div class="co-row">
                                    <label class="co-label" for="co-zip">Postcode</label>
                                    <input id="co-zip" name="postcode" type="text" class="co-input" value="{$clientdetails.postcode|escape}" autocomplete="postal-code" required>
                                </div>
                                <div class="co-row">
                                    <label class="co-label" for="co-country">Country</label>
                                    <select id="co-country" name="country" class="co-select" required>
                                        {if $countries}
                                            {foreach $countries as $cKey => $cName}
                                                <option value="{$cKey|escape}"{if $cKey == $clientdetails.country} selected{/if}>{$cName|escape}</option>
                                            {/foreach}
                                        {else}
                                            <option>Select country</option>
                                        {/if}
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {* Payment method *}
                <div class="card co-section">
                    <div class="co-section-head">
                        <h2 class="co-section-title">Payment method</h2>
                    </div>
                    <div class="co-section-body">
                        <div class="co-pay-list">
                            {if $paymentmethods}
                                {foreach $paymentmethods as $gateway => $gatewayName}
                                    <label class="co-pay">
                                        <input type="radio" name="paymentmethod" value="{$gateway|escape}"{if $gateway == $defaultgateway || ($defaultgateway === '' && $gateway@first)} checked{/if}>
                                        <span class="co-pay-radio"></span>
                                        <span class="co-pay-logo">{$gateway|upper|truncate:4:""}</span>
                                        <div class="co-pay-meta">
                                            <div class="co-pay-name">{$gatewayName|escape}</div>
                                        </div>
                                    </label>
                                {/foreach}
                            {else}
                                {* Fallback when no payment methods are passed in *}
                                <label class="co-pay">
                                    <input type="radio" name="paymentmethod" value="banktransfer" checked>
                                    <span class="co-pay-radio"></span>
                                    <span class="co-pay-logo">BANK</span>
                                    <div class="co-pay-meta">
                                        <div class="co-pay-name">Bank transfer</div>
                                    </div>
                                </label>
                            {/if}
                        </div>
                    </div>
                </div>

                {* Terms *}
                <label class="co-terms">
                    <input type="checkbox" name="accepttos" value="on" required>
                    <span>
                        I have read and agree to the
                        <a href="{$WEB_ROOT}/terms-of-service" target="_blank">Terms of Service</a>
                        and
                        <a href="{$WEB_ROOT}/privacy-policy" target="_blank">Privacy Policy</a>.
                        I authorise charging my selected payment method today and for any recurring renewals until I cancel.
                    </span>
                </label>
            </div>

            {* ══ RIGHT — sticky summary + place-order button ══ *}
            <aside>
                <div class="card co-summary-card">
                    <div class="co-summary-head"><h2>Order summary</h2></div>
                    <div class="co-summary-list">
                        {if $products}
                            {foreach $products as $p}
                                <div class="co-summary-line">
                                    <span class="label">{if $p.group}{$p.group|escape} · {/if}{$p.name|escape}</span>
                                    <span class="value">{$p.pricing}</span>
                                </div>
                            {/foreach}
                        {/if}
                        {if $domains}
                            {foreach $domains as $d}
                                <div class="co-summary-line">
                                    <span class="label">Domain · {$d.domain|escape}</span>
                                    <span class="value">{$d.pricing}</span>
                                </div>
                            {/foreach}
                        {/if}
                        {if $rawdata.subtotal}
                            <div class="co-summary-line divider">
                                <span class="label">Subtotal</span>
                                <span class="value">{$rawdata.subtotal}</span>
                            </div>
                        {/if}
                        {if $rawdata.taxtotal}
                            <div class="co-summary-line">
                                <span class="label">Tax</span>
                                <span class="value">{$rawdata.taxtotal}</span>
                            </div>
                        {/if}
                    </div>
                    <div class="co-summary-total">
                        <span class="label">Due today</span>
                        <span class="value">{$totaltodaytext|default:$rawdata.total}</span>
                    </div>
                    <div class="co-summary-footer">
                        <button type="submit" name="placeorder" value="true" class="co-place-order">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            Place order{if $totaltodaytext} — {$totaltodaytext}{/if}
                        </button>
                    </div>
                    <div class="co-trust">
                        <span class="co-trust-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            256-bit SSL · PCI-DSS Level 1
                        </span>
                        <span class="co-trust-item">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            30-day money-back guarantee
                        </span>
                    </div>
                </div>
            </aside>
        </div>
    </form>
</div>

<script>
{literal}
(function () {
    // Auth tabs (create-account / sign-in)
    document.querySelectorAll('.co-auth-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            var key = tab.dataset.atab;
            document.querySelectorAll('.co-auth-tab').forEach(function (t) { t.classList.remove('active'); });
            document.querySelectorAll('.co-auth-panel').forEach(function (p) { p.classList.remove('is-active'); });
            tab.classList.add('active');
            var panel = document.querySelector('.co-auth-panel[data-apanel="' + key + '"]');
            if (panel) panel.classList.add('is-active');
        });
    });
})();
{/literal}
</script>
