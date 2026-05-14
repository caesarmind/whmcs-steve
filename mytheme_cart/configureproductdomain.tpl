{*
 * mytheme_cart/configureproductdomain.tpl — Domain selection step.
 *
 * Rendered URL: /index.php/store/<group-slug>/<product-slug>
 *                (and the legacy cart.php?a=add&pid=X path that
 *                immediately follows Order Now on products.tpl)
 *
 * Visual source: apple-client-area/configureproductdomain.html.
 *
 * The user has just clicked Order Now on products.tpl. The product
 * is already in the cart; this page asks how they want to handle
 * the domain — register a new one, transfer one in, or point an
 * existing domain at our nameservers.
 *
 * Available Smarty variables (cart-domain-options bootstrap):
 *   $productinfo / $productname  — the product just selected
 *   $domain                       — pre-filled if user came from search
 *   $errormessage                 — validation error from previous submit
 *   $productgroups, $productgroup — for the sidebar
 *   $cartcount                    — view-cart badge
 *   $WEB_ROOT, $carttpl
 *
 * Form posts to cart.php?a=add with `domainoption` set to one of:
 *   register | transfer | owndomain | subdomain
 * plus the relevant {sld,tld} fields for the chosen option.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* configureproductdomain.tpl page-specific styles (.dp-*)
   Apple-language port of apple-client-area/configureproductdomain.html */

.dp-page-header { margin-bottom: 24px; }
.dp-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.dp-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; line-height: 1.5; margin: 0; max-width: 620px; }

/* 2-col split matching products.tpl */
.dp-split { display: grid; grid-template-columns: 240px 1fr; gap: 24px; align-items: start; }
@media (max-width: 880px) { .dp-split { grid-template-columns: 1fr; } }

/* Step strip */
.dp-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.dp-step { display: inline-flex; align-items: center; gap: 8px; }
.dp-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.dp-step.done .dp-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.dp-step.active .dp-step-num { background: var(--color-accent); color: #fff; }
.dp-step.active { color: var(--color-text-primary); font-weight: 500; }
.dp-step-sep { color: var(--color-text-quaternary); }

/* Option radio cards — 3-up grid */
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

/* Panel — the form for the currently selected option */
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
.dp-search-cta { height: 46px; padding: 0 24px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; transition: background var(--transition-fast); display: inline-flex; align-items: center; gap: 6px; flex-shrink: 0; }
.dp-search-cta:hover { background: var(--color-accent-hover); color: #fff; }
.dp-search-cta svg { width: 14px; height: 14px; }
.dp-example { font-size: 12.5px; color: var(--color-text-tertiary); line-height: 1.5; letter-spacing: -0.004em; margin-bottom: 18px; max-width: 640px; }
.dp-example code { background: var(--color-surface-secondary); padding: 1px 6px; border-radius: 4px; font-family: var(--font-mono, ui-monospace, Menlo, monospace); font-size: 11.5px; color: var(--color-text-secondary); }

.dp-error { display: flex; align-items: flex-start; gap: 12px; margin-top: 16px; padding: 14px 16px; background: var(--color-red-bg); border-radius: var(--radius-md); color: var(--color-red-text); letter-spacing: -0.008em; }
.dp-error svg { width: 18px; height: 18px; flex-shrink: 0; margin-top: 1px; }
.dp-error-body { flex: 1; min-width: 0; }
.dp-error-title { font-size: 13.5px; font-weight: 600; margin-bottom: 2px; }
.dp-error-text { font-size: 12.5px; margin: 0; line-height: 1.5; color: var(--color-red-text); }
.dp-error-text a { color: var(--color-red-text); text-decoration: underline; }

/* Footer action bar */
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
        <p class="page-subtitle">Register something new, bring a domain from another registrar, or point an existing one at our nameservers.</p>
    </header>

    <div class="dp-split">

        {* ══ LEFT — Categories + Actions sidebar (mirrors products.tpl) ══ *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* ══ RIGHT — domain picker ══ *}
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

            <form method="post" action="{$WEB_ROOT}/cart.php?a=add" id="dpForm">
                <input type="hidden" name="pid" value="{$productinfo.pid|default:$productinfo.id|default:$pid|escape}">

                <div class="card" style="padding: 0;">

                    {* Three radio cards — chosen value drives which panel shows *}
                    <div class="dp-options" role="radiogroup" aria-label="How you'll provide a domain">
                        <label class="dp-option">
                            <input type="radio" name="domainoption" value="register" checked>
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></span>
                            <span class="dp-option-title">Register a new domain</span>
                            <span class="dp-option-desc">Search and register a brand-new domain name.</span>
                        </label>
                        <label class="dp-option">
                            <input type="radio" name="domainoption" value="transfer">
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg></span>
                            <span class="dp-option-title">Transfer from another registrar</span>
                            <span class="dp-option-desc">Move your domain to us — includes a free year extension.</span>
                        </label>
                        <label class="dp-option">
                            <input type="radio" name="domainoption" value="owndomain">
                            <span class="dp-option-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                            <span class="dp-option-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg></span>
                            <span class="dp-option-title">Use my existing domain</span>
                            <span class="dp-option-desc">Keep it with your current registrar and point DNS at us.</span>
                        </label>
                    </div>

                    {* Display server-side error if any *}
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

                    {* Panel: Register a new domain *}
                    <div class="dp-panel is-active" data-panel="register">
                        <p class="dp-panel-hint"><strong>Search by keyword or full domain.</strong> We'll check availability across all our supported TLDs and offer suggestions if your first choice is taken.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                <input type="text" name="sld" class="dp-input" placeholder="example.com" value="{$domain|default:$sld|escape}" autocomplete="off">
                            </div>
                            <input type="hidden" name="domain" value="register">
                            <button type="submit" name="checkavailability" value="1" class="dp-search-cta">
                                Search
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                            </button>
                        </div>
                        <p class="dp-example">
                            For example: <code>mycompany.com</code>, <code>my-store</code>, or <code>example.io</code>.
                            Free WHOIS privacy included on every TLD that supports it.
                        </p>
                    </div>

                    {* Panel: Transfer from another registrar *}
                    <div class="dp-panel" data-panel="transfer">
                        <p class="dp-panel-hint"><strong>Transfer your domain from another registrar.</strong> Enter your existing domain and we'll guide you through unlock + auth-code. Most transfers add a <strong>free extra year</strong> to your registration.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                <input type="text" name="transfer" class="dp-input" placeholder="mycompany.com" value="{$transfer|default:''|escape}" autocomplete="off">
                            </div>
                            <button type="submit" name="checktransfer" value="1" class="dp-search-cta">Check</button>
                        </div>
                        <p class="dp-example">
                            Before transferring: make sure the domain is <strong>unlocked</strong> at your current registrar, has been registered for at least <strong>60 days</strong>, and you have access to the <strong>auth / EPP code</strong>.
                        </p>
                    </div>

                    {* Panel: Use existing domain *}
                    <div class="dp-panel" data-panel="owndomain">
                        <p class="dp-panel-hint"><strong>I'll use my existing domain and update my nameservers.</strong> Tell us which domain you'd like to use — after checkout we'll email you the nameservers to set at your current registrar.</p>
                        <div class="dp-search-row">
                            <div class="dp-input-wrap">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                <input type="text" name="owndomain" class="dp-input" placeholder="mysite.com" value="{$owndomain|default:''|escape}" autocomplete="off">
                            </div>
                        </div>
                        <p class="dp-example">
                            <strong>Heads up:</strong> the domain will only resolve to your new service once you've updated its nameservers at the registrar where it's registered. We'll send you the exact nameservers after checkout.
                        </p>
                    </div>

                    <div class="dp-footer">
                        <span class="dp-footer-note">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            Free WHOIS privacy included on every TLD that supports it.
                        </span>
                        <span class="spacer"></span>
                        <a href="{$WEB_ROOT}/cart.php" class="dp-back">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                            Back
                        </a>
                        <button type="submit" class="dp-continue">
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
    // Reveal only the panel matching the selected option
    var radios = document.querySelectorAll('.dp-option input[type="radio"]');
    var panels = document.querySelectorAll('.dp-panel');

    function showPanel(key) {
        panels.forEach(function (p) { p.classList.remove('is-active'); });
        var target = document.querySelector('.dp-panel[data-panel="' + key + '"]');
        if (target) target.classList.add('is-active');
    }

    radios.forEach(function (r) {
        r.addEventListener('change', function () {
            if (r.checked) showPanel(r.value);
        });
    });

    // Sync on load — if a non-default option is already checked
    var checked = document.querySelector('.dp-option input[type="radio"]:checked');
    if (checked) showPanel(checked.value);
})();
{/literal}
</script>
