{*
 * mytheme_cart/configureproductdomain.tpl — Domain selection step.
 *
 * Rendered URL: /index.php/store/<group-slug>/<product-slug>
 *
 * This page is the WHMCS 9 NEXUS-style cart-order route, NOT the
 * classic standard_cart `?a=add` flow. The expected form contract
 * (learned the hard way from a Continue→refresh loop):
 *
 *   action  = {routePath('cart-order-addtocart')}
 *   pid     = product id
 *   billingcycle = monthly | quarterly | annually | …
 *   domain_type  = existing-domain | sub-domain | custom-domain | no-domain
 *   custom_domain = "mycompany.com"  (full domain — for custom-domain)
 *   existing_domain                   (for existing-domain)
 *   sub_domain + existing_sld_for_subdomain  (for sub-domain)
 *   continue=1  OR  checkout=1        (submit-name decides next page)
 *
 * The classic standard_cart vocabulary (domain / sld / tld /
 * owndomainsld / owndomaintld / incart=1) is silently ignored on
 * this route — that's why the form just re-rendered the same page.
 *
 * Visual source: apple-client-area/configureproductdomain.html.
 * The three Apple radio cards (Register / Transfer / Use existing)
 * remain visually distinct but all submit as domain_type=custom-domain
 * with the full domain in custom_domain — WHMCS auto-detects whether
 * to treat the domain as a registration, a transfer, or an existing
 * one based on availability and account ownership.
 *
 * Available Smarty variables:
 *   $product / $productinfo / $pid  — the product being configured
 *   $requireDomain                   — bool (omit picker if false)
 *   $allowSubdomains                 — bool
 *   $domains                         — existing domains for logged-in users
 *   $requestedCycle                  — pre-selected billing cycle
 *   $errormessage                    — validation feedback
 *   $productgroups, $productgroup    — sidebar data
 *   $cartcount                       — view-cart badge
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
.dp-page-header { margin-bottom: 24px; }
.dp-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.dp-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; line-height: 1.5; margin: 0; max-width: 620px; }

.dp-split { display: grid; grid-template-columns: 240px 1fr; gap: 24px; align-items: start; }
@media (max-width: 880px) { .dp-split { grid-template-columns: 1fr; } }

.dp-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.dp-step { display: inline-flex; align-items: center; gap: 8px; }
.dp-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.dp-step.done .dp-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.dp-step.active .dp-step-num { background: var(--color-accent); color: #fff; }
.dp-step.active { color: var(--color-text-primary); font-weight: 500; }
.dp-step-sep { color: var(--color-text-quaternary); }

.dp-options { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; padding: 22px 22px 0; }
@media (max-width: 720px) { .dp-options { grid-template-columns: 1fr; } }
.dp-option { position: relative; padding: 18px 18px 16px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); cursor: pointer; transition: all var(--transition-fast); display: flex; flex-direction: column; gap: 4px; }
.dp-option input { position: absolute; opacity: 0; pointer-events: none; }
.dp-option:hover { border-color: var(--color-accent); }
.dp-option:has(input:checked) { border-color: var(--color-accent); background: var(--color-accent-light); }
.dp-option-ico { width: 32px; height: 32px; border-radius: 10px; background: var(--color-surface-secondary); color: var(--color-text-secondary); display: inline-flex; align-items: center; justify-content: center; margin-bottom: 6px; flex-shrink: 0; }
.dp-option:has(input:checked) .dp-option-ico { background: var(--color-accent); color: #fff; }
.dp-option-ico svg { width: 16px; height: 16px; }
.dp-option-title { font-size: 13px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; }
.dp-option-desc { font-size: 11.5px; color: var(--color-text-tertiary); line-height: 1.45; letter-spacing: -0.004em; }
.dp-option-check { position: absolute; top: 14px; right: 14px; width: 16px; height: 16px; border-radius: 50%; border: 1.5px solid var(--color-border); background: var(--color-surface); display: flex; align-items: center; justify-content: center; color: #fff; }
.dp-option:has(input:checked) .dp-option-check { background: var(--color-accent); border-color: var(--color-accent); }
.dp-option-check svg { width: 10px; height: 10px; opacity: 0; }
.dp-option:has(input:checked) .dp-option-check svg { opacity: 1; }

.dp-panel { display: none; padding: 22px 22px 24px; border-top: 0.5px solid var(--color-border); margin-top: 22px; }
.dp-panel.is-active { display: block; }
.dp-panel-hint { font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.004em; line-height: 1.55; margin: 0 0 14px; max-width: 640px; }
.dp-panel-hint strong { color: var(--color-text-primary); font-weight: 500; }

.dp-search-row { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; }
.dp-input-wrap { position: relative; flex: 1; min-width: 260px; }
.dp-input-wrap > svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); width: 15px; height: 15px; color: var(--color-text-tertiary); pointer-events: none; }
.dp-input { width: 100%; height: 46px; padding: 0 16px 0 40px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 15px; letter-spacing: -0.012em; color: var(--color-text-primary); font-family: inherit; transition: all var(--transition-fast); }
.dp-input::placeholder { color: var(--color-text-quaternary); }
.dp-input:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.dp-select { height: 46px; padding: 0 40px 0 16px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 15px; color: var(--color-text-primary); font-family: inherit; appearance: none; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 14px center; cursor: pointer; min-width: 200px; }
.dp-search-cta { height: 46px; padding: 0 24px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; transition: background var(--transition-fast); display: inline-flex; align-items: center; gap: 6px; flex-shrink: 0; }
.dp-search-cta:hover { background: var(--color-accent-hover); color: #fff; }
.dp-example { font-size: 12.5px; color: var(--color-text-tertiary); line-height: 1.5; letter-spacing: -0.004em; margin-bottom: 18px; max-width: 640px; }
.dp-example code { background: var(--color-surface-secondary); padding: 1px 6px; border-radius: 4px; font-family: var(--font-mono, ui-monospace, Menlo, monospace); font-size: 11.5px; color: var(--color-text-secondary); }

.dp-error { display: flex; align-items: flex-start; gap: 12px; margin-top: 16px; padding: 14px 16px; background: var(--color-red-bg); border-radius: var(--radius-md); color: var(--color-red-text); letter-spacing: -0.008em; }
.dp-error svg { width: 18px; height: 18px; flex-shrink: 0; margin-top: 1px; }
.dp-error-body { flex: 1; min-width: 0; }
.dp-error-title { font-size: 13.5px; font-weight: 600; margin-bottom: 2px; }
.dp-error-text { font-size: 12.5px; margin: 0; line-height: 1.5; color: var(--color-red-text); }

.dp-cycle-row { padding: 22px 22px 0; }
.dp-cycle-label { display: block; font-size: 12px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; margin-bottom: 8px; }
.dp-cycle-select { width: 100%; max-width: 320px; }

.dp-footer { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; padding: 16px 22px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); }
.dp-footer .spacer { flex: 1; }
.dp-footer-note { display: inline-flex; align-items: center; gap: 6px; font-size: 11.5px; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.dp-footer-note svg { width: 12px; height: 12px; color: var(--color-green-text); flex-shrink: 0; }
.dp-back, .dp-continue { height: 38px; padding: 0 18px; border-radius: var(--radius-pill); font-size: 13px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; transition: all var(--transition-fast); border: 0; }
.dp-back { background: transparent; color: var(--color-text-primary); border: 0.5px solid var(--color-border); }
.dp-back:hover { border-color: var(--color-accent); color: var(--color-accent); }
.dp-continue { background: var(--color-accent); color: #fff; }
.dp-continue:hover { background: var(--color-accent-hover); color: #fff; }
.dp-back svg, .dp-continue svg { width: 13px; height: 13px; }
{/literal}</style>

<div class="content-area">
    <header class="dp-page-header">
        <h1>Choose a domain</h1>
        <p class="page-subtitle">Pick a billing cycle, then tell us how you'd like to handle the domain for this service.</p>
    </header>

    <div class="dp-split">

        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        <div style="min-width: 0;">

            <div class="dp-steps">
                <span class="dp-step done"><span class="dp-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Choose plan</span>
                <span class="dp-step-sep">›</span>
                <span class="dp-step active"><span class="dp-step-num">2</span>Choose a domain</span>
                <span class="dp-step-sep">›</span>
                <span class="dp-step"><span class="dp-step-num">3</span>Configure</span>
                <span class="dp-step-sep">›</span>
                <span class="dp-step"><span class="dp-step-num">4</span>Cart</span>
                <span class="dp-step-sep">›</span>
                <span class="dp-step"><span class="dp-step-num">5</span>Checkout</span>
            </div>

            {*
                Form contract — see file header. We mirror nexus/store/order.tpl
                exactly because that's what WHMCS 9's cart-order route processes.
            *}
            <form method="post" action="{routePath('cart-order-addtocart')}" id="dpForm" name="frmAddToCart">
                {* PID — defensive across the variable shapes WHMCS uses *}
                {$_pid = $product->id|default:$pid|default:$productinfo.pid|default:$productinfo.id|default:$smarty.get.pid|default:''}
                {if $_pid}
                    <input type="hidden" name="pid" value="{$_pid|escape}">
                {/if}

                {* domain_type — JS keeps this in sync with the radio. NEXUS
                   accepts: custom-domain | existing-domain | sub-domain | no-domain.
                   Our three Apple cards all map to "custom-domain" — WHMCS
                   auto-detects new-registration vs. transfer vs. existing
                   based on availability + account ownership. *}
                <input type="hidden" name="domain_type" id="dp-domain-type" value="custom-domain">

                {* custom_domain — JS populates this from whichever panel's
                   visible input the user filled in. *}
                <input type="hidden" name="custom_domain" id="dp-custom-domain" value="">

                <div class="card" style="padding: 0;">

                    {* Billing cycle — defaults from sessionStorage (set by
                       the cycle pill on products.tpl) so the user's pick
                       on the product grid carries through. *}
                    <div class="dp-cycle-row">
                        <label class="dp-cycle-label" for="dp-billingcycle-visible">Billing cycle</label>
                        <select id="dp-billingcycle-visible" name="billingcycle" class="dp-select dp-cycle-select">
                            {if $product && $product->pricing}
                                {foreach $product->pricing()->allAvailableCycles() as $pricing}
                                    <option value="{$pricing->cycle()|escape}"{if $requestedCycle == $pricing->cycle()} selected{/if}>
                                        {if $pricing->isRecurring()}
                                            {$pricing->cycle()|capitalize} — {$pricing->toPrefixedString()}
                                        {else}
                                            {$pricing->toFullString()}
                                        {/if}
                                    </option>
                                {/foreach}
                            {else}
                                {* Fallback when $product isn't an object on this page *}
                                <option value="monthly">Monthly</option>
                                <option value="quarterly">Quarterly</option>
                                <option value="semiannually">Semi-Annually</option>
                                <option value="annually" selected>Annually</option>
                                <option value="biennially">Biennially</option>
                                <option value="triennially">Triennially</option>
                            {/if}
                        </select>
                    </div>

                    <div class="dp-options" role="radiogroup" aria-label="How you'll provide a domain">
                        <label class="dp-option">
                            <input type="radio" name="dp-choice" value="register" checked>
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></span>
                            <span class="dp-option-title">Register a new domain</span>
                            <span class="dp-option-desc">Search and register a brand-new domain name.</span>
                        </label>
                        <label class="dp-option">
                            <input type="radio" name="dp-choice" value="transfer">
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg></span>
                            <span class="dp-option-title">Transfer from another registrar</span>
                            <span class="dp-option-desc">Move your domain to us — includes a free year extension.</span>
                        </label>
                        <label class="dp-option">
                            <input type="radio" name="dp-choice" value="owndomain">
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg></span>
                            <span class="dp-option-title">Use my existing domain</span>
                            <span class="dp-option-desc">Keep it with your current registrar and point DNS at us.</span>
                        </label>
                    </div>

                    {if $errormessage}
                        <div style="padding: 0 22px;">
                            <div class="dp-error" style="margin-top: 22px;">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                <div class="dp-error-body">
                                    <div class="dp-error-title">There was a problem</div>
                                    <p class="dp-error-text">{$errormessage}</p>
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* All three panels share the same flow: type a full
                       domain, JS copies it to the hidden #dp-custom-domain
                       field on submit. The visible inputs are UNNAMED so
                       they don't pollute the POST body. *}
                    <div class="dp-panel is-active" data-panel="register">
                        <p class="dp-panel-hint"><strong>Search and register a new domain.</strong> Type the domain you want — we'll check availability and register it on checkout.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                <input type="text" class="dp-input" placeholder="example.com" value="{$customDomain|default:''|escape}" autocomplete="off" data-domain-input="register">
                            </div>
                        </div>
                        <p class="dp-example">
                            For example: <code>mycompany.com</code>, <code>my-store.io</code>, or <code>example.shop</code>.
                            Free WHOIS privacy included on every TLD that supports it.
                        </p>
                    </div>

                    <div class="dp-panel" data-panel="transfer">
                        <p class="dp-panel-hint"><strong>Transfer your domain from another registrar.</strong> Enter your existing domain — we'll guide you through unlock + auth-code. Most transfers add a <strong>free extra year</strong>.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                <input type="text" class="dp-input" placeholder="mycompany.com" autocomplete="off" data-domain-input="transfer">
                            </div>
                        </div>
                        <p class="dp-example">
                            Before transferring: make sure the domain is <strong>unlocked</strong> at your current registrar, has been registered for at least <strong>60 days</strong>, and you have access to the <strong>auth / EPP code</strong>.
                        </p>
                    </div>

                    <div class="dp-panel" data-panel="owndomain">
                        <p class="dp-panel-hint"><strong>I'll use my existing domain and update my nameservers.</strong> Tell us which domain you'd like to use — after checkout we'll email you the nameservers to set at your current registrar.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                <input type="text" class="dp-input" placeholder="mysite.com" autocomplete="off" data-domain-input="owndomain">
                            </div>
                        </div>
                        <p class="dp-example">
                            <strong>Heads up:</strong> the domain will only resolve to your new service once you've updated its nameservers at the registrar where it's registered. We'll send you the exact nameservers after checkout.
                        </p>
                    </div>

                    <div class="dp-footer">
                        <span class="dp-footer-note">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            Free WHOIS privacy on every TLD that supports it.
                        </span>
                        <span class="spacer"></span>
                        <a href="{$WEB_ROOT}/cart.php" class="dp-back">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                            Back
                        </a>
                        <button type="submit" name="continue" value="1" class="dp-continue">
                            Continue
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
{literal}
(function () {
    var form = document.getElementById('dpForm');
    if (!form) return;

    // Restore preferred cycle from sessionStorage (set on products.tpl)
    try {
        var savedCycle = sessionStorage.getItem('mytheme_cart.preferredCycle');
        if (savedCycle) {
            var sel = form.querySelector('select[name="billingcycle"]');
            if (sel) {
                var opt = sel.querySelector('option[value="' + savedCycle + '"]');
                if (opt) sel.value = savedCycle;
            }
        }
    } catch (e) {}

    // Reveal only the panel matching the currently-checked option
    var radios = form.querySelectorAll('.dp-option input[type="radio"]');
    var panels = form.querySelectorAll('.dp-panel');
    function showPanel(key) {
        panels.forEach(function (p) { p.classList.remove('is-active'); });
        var target = form.querySelector('.dp-panel[data-panel="' + key + '"]');
        if (target) target.classList.add('is-active');
    }
    radios.forEach(function (r) {
        r.addEventListener('change', function () { if (r.checked) showPanel(r.value); });
    });

    // Normalize the user's free-form input into a clean domain
    function normalizeDomain(value) {
        return (value || '').trim().toLowerCase()
            .replace(/^https?:\/\//, '')
            .replace(/^www\./, '')
            .replace(/\/.*$/, '');
    }

    // Before submit, copy the active panel's input value into the
    // hidden custom_domain field. NEXUS accepts custom_domain as the
    // full domain string — no sld/tld split needed.
    form.addEventListener('submit', function () {
        var picked = form.querySelector('.dp-option input[type="radio"]:checked');
        if (!picked) return;
        var visible = form.querySelector('.dp-panel[data-panel="' + picked.value + '"] [data-domain-input]');
        var hidden  = document.getElementById('dp-custom-domain');
        if (visible && hidden) {
            hidden.value = normalizeDomain(visible.value);
        }
        // All three Apple cards map to NEXUS's custom-domain — WHMCS
        // distinguishes register / transfer / own by checking the
        // domain's availability + ownership server-side.
        var dt = document.getElementById('dp-domain-type');
        if (dt) dt.value = 'custom-domain';
    });

    // Sync on load
    var checked = form.querySelector('.dp-option input[type="radio"]:checked');
    if (checked) showPanel(checked.value);
})();
{/literal}
</script>
