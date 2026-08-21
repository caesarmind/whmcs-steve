{*
 * hadrian_cart/configuredomains.tpl - Apple-shell rebuild
 *
 * Rendered URL:   cart.php?a=confdomains
 *
 * Shell = .st-page-header (H1 "Domains Configuration")
 *         + .cd-split (240px sidebar + 1fr main)
 *           |- sidebar-categories.tpl (Categories + Actions)
 *           `- main column
 *               |- .cd-when-full (rendered when $domains is non-empty)
 *               |   |- .cd-steps  (5-step progress strip, step 3 active)
 *               |   `- <form id="frmConfigureDomains">
 *               |       |- .card.cd-domain-card  (per $domain)
 *               |       |   |- .cd-domain-head   (icon + domain name)
 *               |       |   `- .cd-domain-body
 *               |       |       |- .cd-form-grid  (regperiod + hosting)
 *               |       |       |- .cd-field      (EPP, if eppenabled)
 *               |       |       |- .cd-addons     (DNS/ID/Email cards)
 *               |       |       `- .cd-fields     (registrant fields)
 *               |       |- .card.cd-nameservers-card  (if $atleastonenohosting)
 *               |       `- .cd-footer (Continue)
 *               `- .cd-when-empty (no domains in cart -- defensive)
 *
 * State-chip wiring:
 *   - body[data-data="empty|full"] is stamped pre-paint by an inline
 *     script using ($domains == 0). The page-scoped .cd-when-full /
 *     .cd-when-empty hide rules below pick up that attribute. We use
 *     .cd-* prefix (not the global .when-*) because hadrian's
 *     core-layout.css unconditionally hides .when-full on cart routes.
 *   - body[data-subnav="off|on"] collapses the Categories aside via
 *     the .cd-split CSS below -- mirrors .st-split / .dp-split.
 *
 * Standard_cart contract preserved (so scripts.min.js still binds):
 *   - Form id="frmConfigureDomains", POSTs to PHP_SELF?a=confdomains
 *   - Hidden input name="update" value="true"
 *   - Per-domain EPP: name="epp[{num}]", id="inputEppcode{num}"
 *   - Addon checkboxes: name="dnsmanagement[{num}]",
 *     name="idprotection[{num}]", name="emailforwarding[{num}]"
 *   - Addon panel structure: .panel.panel-default.panel-addon
 *     (.panel-addon-selected when checked), with .panel-body, .panel-price,
 *     .panel-add - scripts.min.js toggles .panel-addon-selected on click.
 *   - Domain registrant fields rendered from $domain.fields ({label}=>{html input})
 *   - Nameservers: name="domainns1..5", id="inputNs1..5"
 *
 * CSS lives inline in the {literal}<style>{/literal} block at the top --
 * same pattern as configureproduct.tpl / viewcart.tpl. Keeps page-local
 * styles out of style.min.css (which is shared across every cart page).
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* ----------------------------------------------------------------
   Page-local layout (.cd-* tokens, configureDomains).
   The global Apple primitives (.card, .btn-primary, .alert) come
   from style.min.css; only the bits unique to this page live here.
   ---------------------------------------------------------------- */

/* Two-column split (matches .st-split / .dp-split shape). */
.cd-split {
    display: grid;
    grid-template-columns: 240px 1fr;
    gap: 24px;
    align-items: start;
}
@media (max-width: 880px) { .cd-split { grid-template-columns: 1fr; } }

/* Sub-nav state-chip wiring -- same pattern used elsewhere. The
   right-column main keeps full width when the chip hides the sidebar. */
body[data-subnav="off"] .cd-split { grid-template-columns: 1fr; }
body[data-subnav="off"] .cd-split > aside { display: none; }
body[data-subnav-side="left"] .cd-split { grid-template-columns: 240px 1fr; }
body[data-subnav-side="left"] .cd-split > aside { grid-column: 1; grid-row: 1; }

/* Full / empty toggle, scoped so hadrian's global .when-full hide
   doesn't fight us on cart routes. */
body[data-data="empty"] .cd-when-full { display: none; }
body:not([data-data="empty"]) .cd-when-empty { display: none; }

/* ---- Step progress strip ---- */
.cd-steps {
    display: flex; align-items: center; flex-wrap: wrap; gap: 8px;
    margin-bottom: 16px;
    font-size: 13px;
    color: var(--color-text-tertiary);
    letter-spacing: -0.004em;
}
.cd-step { display: inline-flex; align-items: center; gap: 6px; }
.cd-step-num {
    width: 20px; height: 20px; border-radius: 50%;
    background: var(--color-surface-secondary);
    color: var(--color-text-tertiary);
    display: inline-flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 600;
}
.cd-step.done .cd-step-num { background: var(--color-green-bg); color: var(--color-green-text); }
.cd-step.active .cd-step-num { background: var(--color-accent); color: #fff; }
.cd-step.active { color: var(--color-text-primary); font-weight: 500; }
.cd-step-sep { color: var(--color-text-quaternary, #c7c7cc); margin: 0 2px; }

/* ---- Domain card ---- */
.cd-domain-card { padding: 0; margin-bottom: 16px; overflow: hidden; }
.cd-domain-head {
    display: flex; align-items: center; gap: 10px;
    padding: 16px 24px;
    border-bottom: 0.5px solid var(--color-border);
    background: var(--color-surface-secondary);
}
.cd-domain-head-ico {
    width: 32px; height: 32px; border-radius: 8px;
    background: var(--color-accent-light);
    color: var(--color-accent);
    display: inline-flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.cd-domain-head-ico svg { width: 16px; height: 16px; }
.cd-domain-head-name {
    font-size: 16px; font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.012em;
}
.cd-domain-body { padding: 20px 24px 22px; display: flex; flex-direction: column; gap: 18px; }

/* ---- Field primitives (label + input/static value) ---- */
.cd-form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px 18px;
}
@media (max-width: 720px) { .cd-form-grid { grid-template-columns: 1fr; } }
.cd-nameservers-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px 18px;
}
@media (max-width: 900px) { .cd-nameservers-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 540px) { .cd-nameservers-grid { grid-template-columns: 1fr; } }
.cd-field { display: flex; flex-direction: column; gap: 6px; min-width: 0; }
.cd-field > label,
.cd-field-label {
    font-size: 12.5px;
    font-weight: 500;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
}
.cd-field-static {
    font-size: 14px;
    color: var(--color-text-primary);
    letter-spacing: -0.008em;
    padding: 6px 0;
}
.cd-field-static .badge-ok {
    display: inline-flex; align-items: center; gap: 6px;
    color: var(--color-green-text, #248a3d);
    font-weight: 500;
}
.cd-field-static .badge-warn {
    display: inline-flex; align-items: center; gap: 6px;
    color: var(--color-accent);
    text-decoration: none;
    font-weight: 500;
}
.cd-field-static .badge-warn:hover { text-decoration: underline; }
.cd-field-static svg { width: 13px; height: 13px; flex-shrink: 0; }
.cd-input {
    height: 40px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px;
    color: var(--color-text-primary);
    letter-spacing: -0.008em;
    transition: border-color var(--transition-fast), background var(--transition-fast);
    font-family: inherit;
}
.cd-input:focus {
    outline: none;
    border-color: var(--color-accent);
    background: var(--color-surface);
}
.cd-help {
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    letter-spacing: -0.004em;
    line-height: 1.45;
}

/* Registrant fields container -- WHMCS hands us pre-rendered <input>
   blobs in $domain.fields; ensure they pick up our input look without
   us having to rewrap each one. */
.cd-fields { display: flex; flex-direction: column; gap: 14px; }
.cd-fields .form-group { display: flex; flex-direction: column; gap: 6px; margin: 0; }
.cd-fields input[type="text"],
.cd-fields input[type="email"],
.cd-fields input[type="tel"],
.cd-fields select,
.cd-fields textarea {
    width: 100%;
    height: 40px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px;
    color: var(--color-text-primary);
    letter-spacing: -0.008em;
    font-family: inherit;
}
.cd-fields textarea { height: auto; padding: 10px 14px; }
.cd-fields input:focus,
.cd-fields select:focus,
.cd-fields textarea:focus { outline: none; border-color: var(--color-accent); }

/* ---- Addon panels (DNS / ID protection / Email forwarding) ----
   Class names panel/panel-default/panel-addon/panel-addon-selected are
   the contract scripts.min.js binds to. We restyle them inside .cd-addons
   so they get the Apple card look but JS still finds them. */
.cd-addons {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}
@media (max-width: 900px) { .cd-addons { grid-template-columns: 1fr; } }
.cd-addons .panel.panel-default.panel-addon {
    position: relative;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    padding: 14px 16px 12px;
    display: flex; flex-direction: column; gap: 10px;
    transition: border-color var(--transition-fast), background var(--transition-fast);
    cursor: pointer;
    margin: 0;
}
.cd-addons .panel.panel-default.panel-addon:hover { border-color: var(--color-accent); }
.cd-addons .panel.panel-addon-selected {
    border-color: var(--color-accent);
    background: var(--color-accent-light);
}
.cd-addons .panel-body { padding: 0; display: flex; flex-direction: column; gap: 4px; }
.cd-addons .panel-body label {
    display: inline-flex; align-items: center; gap: 8px;
    margin: 0;
    font-size: 13.5px;
    font-weight: 500;
    color: var(--color-text-primary);
    cursor: pointer;
}
.cd-addons .panel-body label input[type="checkbox"] {
    width: 16px; height: 16px;
    accent-color: var(--color-accent);
    margin: 0;
}
.cd-addons .addon-name { letter-spacing: -0.008em; }
.cd-addons .addon-description {
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    letter-spacing: -0.004em;
    line-height: 1.5;
}
.cd-addons .panel-price {
    font-size: 12.5px;
    color: var(--color-text-secondary);
    font-variant-numeric: tabular-nums;
    letter-spacing: -0.004em;
}
.cd-addons .panel-add {
    font-size: 11.5px;
    color: var(--color-accent);
    font-weight: 500;
    letter-spacing: -0.004em;
    display: inline-flex; align-items: center; gap: 4px;
}
/* When the addon is selected, scripts.js swaps the .panel-add text from
   "+ Add to Cart" to "Added to Cart (Remove)" -- keep the element visible
   in both states; it's the click target the user reads to toggle off. */
.cd-addons .panel-addon-selected .panel-add { color: var(--color-accent); }
/* iCheck (loaded by standard_cart/scripts.js) replaces the native
   checkbox with a custom .icheckbox_minimal element; hide the now-
   redundant original input. The icheckbox layer remains clickable. */
.cd-addons .panel-body label input[type="checkbox"] { position: absolute; left: -9999px; }
.cd-addons .panel-body .icheckbox_minimal,
.cd-addons .panel-body .icheckbox_minimal-blue,
.cd-addons .panel-body .icheckbox {
    margin-right: 4px;
}

/* ---- Nameservers card ---- */
.cd-nameservers-card { padding: 0; margin-bottom: 16px; }
.cd-section-head {
    padding: 18px 24px 14px;
    border-bottom: 0.5px solid var(--color-border);
}
.cd-section-head h2 {
    font-size: 15px; font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.012em;
    margin: 0 0 4px;
}
.cd-section-head p {
    font-size: 12.5px;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
    margin: 0;
    line-height: 1.45;
}
.cd-nameservers-body { padding: 20px 24px 22px; }

/* ---- Footer / submit ---- */
.cd-footer {
    display: flex; justify-content: flex-end; gap: 10px;
    padding-top: 8px;
}
.cd-footer .btn-primary {
    height: 42px; padding: 0 24px; font-size: 14px;
    display: inline-flex; align-items: center; gap: 6px;
}
.cd-footer .btn-primary svg { width: 13px; height: 13px; }

/* ---- Empty state ---- */
.cd-empty {
    padding: 64px 24px;
    text-align: center;
    display: flex; flex-direction: column; align-items: center; gap: 14px;
}
.cd-empty-ico {
    width: 56px; height: 56px; border-radius: 16px;
    background: var(--color-surface-secondary);
    color: var(--color-text-tertiary);
    display: inline-flex; align-items: center; justify-content: center;
}
.cd-empty-ico svg { width: 24px; height: 24px; }
.cd-empty h2 {
    font-size: 18px; font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.014em;
    margin: 0;
}
.cd-empty p {
    font-size: 13.5px;
    color: var(--color-text-tertiary);
    letter-spacing: -0.004em;
    line-height: 1.55;
    max-width: 420px;
    margin: 0;
}
{/literal}</style>

{* Initial body[data-data] state so the global state-chip's Full/Empty
   overlay lines up with the server-side cart state on first paint.
   Without this the .cd-when-full block would render briefly even when
   no domains are present. Mirrors the same pattern in viewcart.tpl. *}
<script>{literal}
(function () {
    try { localStorage.removeItem('hn.data'); } catch (e) {}
    var d = document.body && document.body.dataset;
    if (d) { d.data = '{/literal}{if !$domains}empty{else}full{/if}{literal}'; }
})();
{/literal}</script>

<div id="order-standard_cart">

    <header class="st-page-header">
        <h1>{$LANG.cartdomainsconfig}</h1>
        <p class="page-subtitle">{$LANG.orderForm.reviewDomainAndAddons}</p>
    </header>

    <div class="cd-split">

        {* ── Sidebar: Categories + Actions (hadrian_cart's, not standard_cart's) ── *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* ── Main column ── *}
        <div style="min-width: 0;">

            {* ════════════════════════════════════════════════════════
               FULL: at least one domain is being configured
               ════════════════════════════════════════════════════════ *}
            <div class="cd-when-full">

                {* 5-step progress strip. Step 3 (Configure) is active --
                   configuredomains is the second half of the configure
                   step (after configureproduct.tpl). *}
                <div class="cd-steps" aria-label="Order progress">
                    <span class="cd-step done">
                        <span class="cd-step-num">
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </span>
                        Choose plan
                    </span>
                    <span class="cd-step-sep">›</span>
                    <span class="cd-step done">
                        <span class="cd-step-num">
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </span>
                        Choose a domain
                    </span>
                    <span class="cd-step-sep">›</span>
                    <span class="cd-step active"><span class="cd-step-num">3</span>Configure</span>
                    <span class="cd-step-sep">›</span>
                    <span class="cd-step"><span class="cd-step-num">4</span>Cart</span>
                    <span class="cd-step-sep">›</span>
                    <span class="cd-step"><span class="cd-step-num">5</span>Checkout</span>
                </div>

                <form method="post" action="{$smarty.server.PHP_SELF}?a=confdomains" id="frmConfigureDomains">
                    <input type="hidden" name="update" value="true" />

                    {if $errormessage}
                        <div class="alert alert-danger" role="alert" style="margin-bottom: 16px;">
                            <p style="margin: 0 0 6px;">{$LANG.orderForm.correctErrors}:</p>
                            <ul style="margin: 0; padding-left: 20px;">
                                {$errormessage}
                            </ul>
                        </div>
                    {/if}

                    {foreach $domains as $num => $domain}

                        <div class="card cd-domain-card">

                            <div class="cd-domain-head">
                                <span class="cd-domain-head-ico" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                </span>
                                <span class="cd-domain-head-name">{$domain.domain}</span>
                            </div>

                            <div class="cd-domain-body">

                                {* Registration period + Hosting status — read-only display *}
                                <div class="cd-form-grid">
                                    <div class="cd-field">
                                        <span class="cd-field-label">{$LANG.orderregperiod}</span>
                                        <div class="cd-field-static">{$domain.regperiod} {$LANG.orderyears}</div>
                                    </div>
                                    <div class="cd-field">
                                        <span class="cd-field-label">{$LANG.hosting}</span>
                                        <div class="cd-field-static">
                                            {if $domain.hosting}
                                                <span class="badge-ok">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                                    {$LANG.cartdomainshashosting}
                                                </span>
                                            {else}
                                                <a href="{$WEB_ROOT}/cart.php" class="badge-warn">
                                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                                                    {$LANG.cartdomainsnohosting}
                                                </a>
                                            {/if}
                                        </div>
                                    </div>
                                </div>

                                {* EPP transfer code (transfer flow only) *}
                                {if $domain.eppenabled}
                                    <div class="cd-field">
                                        <label for="inputEppcode{$num}">{$LANG.domaineppcode}</label>
                                        <input type="text" name="epp[{$num}]" id="inputEppcode{$num}" value="{$domain.eppvalue}" class="cd-input" />
                                        <span class="cd-help">{$LANG.domaineppcodedesc}</span>
                                    </div>
                                {/if}

                                {* Domain addon cards (DNS Management / ID Protection / Email Forwarding).
                                   The wrapper carries .addon-products in addition to .cd-addons
                                   because scripts.js (registerAddonEvents) scopes its click +
                                   iCheck handlers to ".addon-products .panel-addon" -- without
                                   that class the panel never toggles .panel-addon-selected and
                                   the cart total never updates. .panel-* inner structure is
                                   preserved verbatim for the same reason. *}
                                {if $domain.dnsmanagement || $domain.emailforwarding || $domain.idprotection}
                                    <div class="cd-addons addon-products">

                                        {if $domain.dnsmanagement}
                                            <div class="panel panel-default panel-addon{if $domain.dnsmanagementselected} panel-addon-selected{/if}">
                                                <div class="panel-body">
                                                    <label>
                                                        <input type="checkbox" name="dnsmanagement[{$num}]"{if $domain.dnsmanagementselected} checked{/if} />
                                                        <span class="addon-name">{$LANG.domaindnsmanagement}</span>
                                                    </label>
                                                    <div class="addon-description">{$LANG.domainaddonsdnsmanagementinfo}</div>
                                                </div>
                                                <div class="panel-price">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$domain.dnsmanagementprice} / {$domain.regperiod} {$LANG.orderyears}</div>
                                                <div class="panel-add">+ {$LANG.orderForm.addToCart}</div>
                                            </div>
                                        {/if}

                                        {if $domain.idprotection}
                                            <div class="panel panel-default panel-addon{if $domain.idprotectionselected} panel-addon-selected{/if}">
                                                <div class="panel-body">
                                                    <label>
                                                        <input type="checkbox" name="idprotection[{$num}]"{if $domain.idprotectionselected} checked{/if} />
                                                        <span class="addon-name">{$LANG.domainidprotection}</span>
                                                    </label>
                                                    <div class="addon-description">{$LANG.domainaddonsidprotectioninfo}</div>
                                                </div>
                                                <div class="panel-price">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$domain.idprotectionprice} / {$domain.regperiod} {$LANG.orderyears}</div>
                                                <div class="panel-add">+ {$LANG.orderForm.addToCart}</div>
                                            </div>
                                        {/if}

                                        {if $domain.emailforwarding}
                                            <div class="panel panel-default panel-addon{if $domain.emailforwardingselected} panel-addon-selected{/if}">
                                                <div class="panel-body">
                                                    <label>
                                                        <input type="checkbox" name="emailforwarding[{$num}]"{if $domain.emailforwardingselected} checked{/if} />
                                                        <span class="addon-name">{$LANG.domainemailforwarding}</span>
                                                    </label>
                                                    <div class="addon-description">{$LANG.domainaddonsemailforwardinginfo}</div>
                                                </div>
                                                <div class="panel-price">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$domain.emailforwardingprice} / {$domain.regperiod} {$LANG.orderyears}</div>
                                                <div class="panel-add">+ {$LANG.orderForm.addToCart}</div>
                                            </div>
                                        {/if}

                                    </div>
                                {/if}

                                {* Registrant fields - rendered by WHMCS as ready-made <input> HTML. *}
                                {if $domain.fields}
                                    <div class="cd-fields">
                                        {foreach from=$domain.fields key=domainfieldname item=domainfield}
                                            <div class="cd-field">
                                                <span class="cd-field-label">{$domainfieldname}</span>
                                                {$domainfield}
                                            </div>
                                        {/foreach}
                                    </div>
                                {/if}

                            </div>{* /.cd-domain-body *}
                        </div>{* /.cd-domain-card *}

                    {/foreach}

                    {if $atleastonenohosting}
                        <div class="card cd-nameservers-card">
                            <div class="cd-section-head">
                                <h2>{$LANG.domainnameservers}</h2>
                                <p>{$LANG.cartnameserversdesc}</p>
                            </div>
                            <div class="cd-nameservers-body">
                                <div class="cd-nameservers-grid">
                                    <div class="cd-field">
                                        <label for="inputNs1">{$LANG.domainnameserver1}</label>
                                        <input type="text" class="cd-input" id="inputNs1" name="domainns1" value="{$domainns1}" placeholder="ns1.example.com" />
                                    </div>
                                    <div class="cd-field">
                                        <label for="inputNs2">{$LANG.domainnameserver2}</label>
                                        <input type="text" class="cd-input" id="inputNs2" name="domainns2" value="{$domainns2}" placeholder="ns2.example.com" />
                                    </div>
                                    <div class="cd-field">
                                        <label for="inputNs3">{$LANG.domainnameserver3}</label>
                                        <input type="text" class="cd-input" id="inputNs3" name="domainns3" value="{$domainns3}" />
                                    </div>
                                    <div class="cd-field">
                                        <label for="inputNs4">{$LANG.domainnameserver4}</label>
                                        <input type="text" class="cd-input" id="inputNs4" name="domainns4" value="{$domainns4}" />
                                    </div>
                                    <div class="cd-field">
                                        <label for="inputNs5">{$LANG.domainnameserver5}</label>
                                        <input type="text" class="cd-input" id="inputNs5" name="domainns5" value="{$domainns5}" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/if}

                    <div class="cd-footer">
                        <button type="submit" class="btn-primary">
                            {$LANG.continue}
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                        </button>
                    </div>

                </form>

            </div>{* /.cd-when-full *}

            {* ════════════════════════════════════════════════════════
               EMPTY: no domains to configure (defensive -- under normal
               flow WHMCS routes elsewhere when $domains is empty, but
               this block makes the state-chip Empty preview work too).
               ════════════════════════════════════════════════════════ *}
            <div class="cd-when-empty">
                <div class="card cd-empty">
                    <div class="cd-empty-ico" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                    </div>
                    <h2>{$hadrianLang.cart.noDomainsToConfigure}</h2>
                    <p>{$hadrianLang.cart.noDomainsToConfigureDesc}</p>
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary" style="height: 42px; padding: 0 24px; font-size: 14px; display: inline-flex; align-items: center; gap: 6px;">
                        {$hadrianLang.cart.browsePlans}
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            </div>{* /.cd-when-empty *}

        </div>{* /main column *}
    </div>{* /.cd-split *}

</div>{* /#order-standard_cart *}

{include file="orderforms/$carttpl/recommendations-modal.tpl"}
