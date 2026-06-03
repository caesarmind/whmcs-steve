{*
 * mytheme_cart/configureproductdomain.tpl — mockup-faithful rebuild
 *
 * Visual source: apple-client-area/configureproductdomain.html
 *   Shell    = .dp-split (240px sidebar + main) wrapping
 *              .dp-steps (5-step progress strip)
 *              .card containing .dp-options (radio cards)
 *                                .dp-panel[data-panel] (per-option search)
 *                                .dp-footer (back + continue)
 *
 * Server contract (preserved verbatim):
 *   - POST to {$WEB_ROOT}/cart.php?a=add&pid={$pid}&domainselect=1
 *   - Body fields:
 *       pid           — int (also in query string; doubled for safety)
 *       domainoption  — register | transfer | owndomain | subdomain | incart
 *       domains[]     — full <sld>.<tld> (everything except incart)
 *       incartdomain  — full domain string (only when option=incart)
 *
 * JS contract DROPPED (per user direction "replace JS where it
 * conflicts"):
 *   - scripts.min.js's AJAX domain-availability check.
 *     The "Search" button just submits the form; WHMCS server-side
 *     validates the domain and bounces back with an error if invalid.
 *   - $showAdvancedSearchOptions AI search variant + tlds[] / maxLength
 *     / safe-search multiselect. Re-introduce as a separate panel later.
 *   - $spotlightTlds card grid + $domainSuggestions / suggested-domains
 *     list — those are scripts.min.js-driven AJAX features.
 *   - $idnLanguages selector — IDN registrations now happen server-side
 *     only; edge case for follow-up.
 *
 * The inline <script> at the bottom owns the new behavior:
 *   - Swap visible .dp-panel when the radio in .dp-options changes.
 *   - On form submit, read the active panel's [data-input] fields and
 *     write the result into the hidden #resultDomain / #resultIncart.
 *   - Clear panel error state on input.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    {* Note: mytheme's header.tpl already opens <div class="content-area">
       so we render straight into it. The inner .content-area that used
       to live here produced double padding. *}

    <header class="st-page-header">
        <h1>{$LANG.domaincheckerchoosedomain}</h1>
        <p class="page-subtitle">{$hadrianLang.cart.chooseDomainSubtitle}</p>
    </header>

    <div class="dp-split">

        {* ── Sidebar: Categories + Actions ──
           sidebar-categories.tpl already wraps its content in <aside>,
           so we include it directly here (the old <aside><aside>...</aside></aside>
           double-wrap was invalid HTML and added a stray layout box). *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* ── Main column: step strip + chooser card ── *}
        <div style="min-width: 0;">

                <div class="dp-steps" aria-label="Order progress">
                    <span class="dp-step done">
                        <span class="dp-step-num">
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                        </span>
                        {$hadrianLang.cart.stepChoosePlan}
                    </span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step active"><span class="dp-step-num">2</span>{$hadrianLang.cart.stepChooseDomain}</span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step"><span class="dp-step-num">3</span>{$hadrianLang.cart.stepConfigure}</span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step"><span class="dp-step-num">4</span>{$hadrianLang.cart.stepCart}</span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step"><span class="dp-step-num">5</span>{$hadrianLang.cart.stepCheckout}</span>
                </div>

                <form id="frmProductDomain"
                      method="post"
                      action="{$WEB_ROOT}/cart.php?a=add&pid={$pid}&domainselect=1">

                    <input type="hidden" name="pid" value="{$pid}">
                    {* JS populates these two on submit based on the active option *}
                    <input type="hidden" name="domains[]" id="resultDomain" value="">
                    <input type="hidden" name="incartdomain" id="resultIncartDomain" value="">

                    <div class="card" style="padding: 0;">

                        {* ─── Option radio cards ─── *}
                        <div class="dp-options" role="radiogroup" aria-label="{$hadrianLang.cart.domainOptionGroupLabel}">

                            {if $incartdomains}
                                {$_chk = ($domainoption eq "incart")}
                                <label class="dp-option">
                                    <input type="radio" name="domainoption" value="incart"{if $_chk} checked{/if}>
                                    <span class="dp-option-check">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </span>
                                    <span class="dp-option-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                                    </span>
                                    <span class="dp-option-title">{$LANG.cartproductdomainuseincart}</span>
                                    <span class="dp-option-desc">{$hadrianLang.cart.useIncartDesc}</span>
                                </label>
                            {/if}

                            {if $registerdomainenabled}
                                {$_chk = (!$domainoption || $domainoption eq "register")}
                                <label class="dp-option">
                                    <input type="radio" name="domainoption" value="register"{if $_chk} checked{/if}>
                                    <span class="dp-option-check">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </span>
                                    <span class="dp-option-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                    </span>
                                    <span class="dp-option-title">{$LANG.cartregisterdomainchoice|sprintf2:$companyname}</span>
                                    <span class="dp-option-desc">{$hadrianLang.cart.registerDesc}</span>
                                </label>
                            {/if}

                            {if $transferdomainenabled}
                                {$_chk = ($domainoption eq "transfer")}
                                <label class="dp-option">
                                    <input type="radio" name="domainoption" value="transfer"{if $_chk} checked{/if}>
                                    <span class="dp-option-check">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </span>
                                    <span class="dp-option-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                                    </span>
                                    <span class="dp-option-title">{$LANG.carttransferdomainchoice|sprintf2:$companyname}</span>
                                    <span class="dp-option-desc">{$hadrianLang.cart.transferDesc}</span>
                                </label>
                            {/if}

                            {if $owndomainenabled}
                                {$_chk = ($domainoption eq "owndomain")}
                                <label class="dp-option">
                                    <input type="radio" name="domainoption" value="owndomain"{if $_chk} checked{/if}>
                                    <span class="dp-option-check">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </span>
                                    <span class="dp-option-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                    </span>
                                    <span class="dp-option-title">{$LANG.cartexistingdomainchoice|sprintf2:$companyname}</span>
                                    <span class="dp-option-desc">{$hadrianLang.cart.owndomainDesc}</span>
                                </label>
                            {/if}

                            {if $subdomains}
                                {$_chk = ($domainoption eq "subdomain")}
                                <label class="dp-option">
                                    <input type="radio" name="domainoption" value="subdomain"{if $_chk} checked{/if}>
                                    <span class="dp-option-check">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </span>
                                    <span class="dp-option-ico">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 22 9 12 15 12 15 22"/><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg>
                                    </span>
                                    <span class="dp-option-title">{$LANG.cartsubdomainchoice|sprintf2:$companyname}</span>
                                    <span class="dp-option-desc">{$hadrianLang.cart.subdomainDesc}</span>
                                </label>
                            {/if}

                        </div>

                        {* ─── Per-option search panels ─── *}

                        {if $incartdomains}
                            <div class="dp-panel{if $domainoption eq "incart"} is-active{/if}" data-panel="incart">
                                <p class="dp-panel-hint">{$hadrianLang.cart.incartPanelHint}</p>
                                <div class="dp-search-row">
                                    <select class="dp-input no-ico" data-input="incartsld">
                                        {foreach $incartdomains as $incartdomain}
                                            <option value="{$incartdomain}">{$incartdomain}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.use}</button>
                                </div>
                            </div>
                        {/if}

                        {if $registerdomainenabled}
                            <div class="dp-panel{if !$domainoption || $domainoption eq "register"} is-active{/if}" data-panel="register">
                                <p class="dp-panel-hint">{$hadrianLang.cart.registerPanelHint}</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="{$hadrianLang.cart.registerSldPlaceholder}" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <select class="dp-input no-ico" data-input="tld" style="flex: 0 0 130px;">
                                        {foreach from=$registertlds item=listtld}
                                            <option value="{$listtld}"{if $listtld eq $tld} selected{/if}>{$listtld}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">
                                        {$LANG.orderForm.check}
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                                    </button>
                                </div>
                                {if $freedomaintlds}
                                    <p class="dp-example">
                                        <strong>{$hadrianLang.cart.freeDomainOn}</strong> {$freedomaintlds}
                                    </p>
                                {/if}
                            </div>
                        {/if}

                        {if $transferdomainenabled}
                            <div class="dp-panel{if $domainoption eq "transfer"} is-active{/if}" data-panel="transfer">
                                <p class="dp-panel-hint">{$hadrianLang.cart.transferPanelHint}</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="{$hadrianLang.cart.transferSldPlaceholder}" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <select class="dp-input no-ico" data-input="tld" style="flex: 0 0 130px;">
                                        {foreach from=$transfertlds item=listtld}
                                            <option value="{$listtld}"{if $listtld eq $tld} selected{/if}>{$listtld}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.transfer}</button>
                                </div>
                                <p class="dp-example">
                                    {$hadrianLang.cart.transferRequirements}
                                </p>
                            </div>
                        {/if}

                        {if $owndomainenabled}
                            {* Owndomain panel — split SLD + free-text TLD, mirroring standard_cart.
                               TLD is a TEXT input (not a <select>) because owndomain must accept
                               ANY TLD — not just registrar-supported ones. Register/transfer use
                               <select> populated from $registertlds / $transfertlds because those
                               flows are restricted to TLDs we actually sell.
                               JS submit handler joins sld + '.' + tld into resultDomain. *}
                            <div class="dp-panel{if $domainoption eq "owndomain"} is-active{/if}" data-panel="owndomain">
                                <p class="dp-panel-hint">{$hadrianLang.cart.owndomainPanelHint}</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="{lang key='yourdomainplaceholder'}" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <input type="text" class="dp-input no-ico" data-input="tld" value="{$tld|substr:1}" placeholder="{$LANG.yourtldplaceholder}" autocomplete="off" autocapitalize="none" style="flex: 0 0 130px;">
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.use}</button>
                                </div>
                            </div>
                        {/if}

                        {if $subdomains}
                            <div class="dp-panel{if $domainoption eq "subdomain"} is-active{/if}" data-panel="subdomain">
                                <p class="dp-panel-hint">{$hadrianLang.cart.subdomainPanelHint}</p>
                                <div class="dp-search-row">
                                    <input type="text" class="dp-input no-ico" data-input="sld" value="{$sld}" placeholder="{$hadrianLang.cart.subdomainSldPlaceholder}" autocomplete="off" autocapitalize="none">
                                    <select class="dp-input no-ico" data-input="tld" style="flex: 0 0 200px;">
                                        {foreach $subdomains as $subid => $subdomain}
                                            <option value="{$subdomain}">.{$subdomain}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.check}</button>
                                </div>
                            </div>
                        {/if}

                        {* ─── Footer: privacy note + Back / Continue ─── *}
                        <div class="dp-footer">
                            <span class="dp-footer-note">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                                {$hadrianLang.cart.whoisPrivacyNote}
                            </span>
                            <span class="spacer"></span>
                            <a href="{$WEB_ROOT}/cart.php" class="dp-back">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                                {$LANG.goback}
                            </a>
                            <button type="submit" class="dp-continue">
                                {$LANG.continue}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                            </button>
                        </div>

                    </div>
                </form>
            </div>{* /right column *}
        </div>{* /.dp-split *}
</div>{* /#order-standard_cart *}

{include file="orderforms/$carttpl/recommendations-modal.tpl"}

{* Smarty-to-JS lang seed for the own-domain validator below. That script runs
   inside a Smarty literal block and cannot read Smarty vars directly. *}
<script>
var _localLang = {
    ownDomainNeedBoth: '{$hadrianLang.cart.ownDomainNeedBoth|escape:"javascript"}',
    domainChecking: '{$hadrianLang.cart.domainChecking|escape:"javascript"}',
    domainInvalid: '{$LANG.cartdomaininvalid|escape:"javascript"}'
};
</script>
<script>
{literal}
(function () {
    function init() {
        var form = document.getElementById('frmProductDomain');
        if (!form) return;

        // standard_cart's scripts.min.js binds a jQuery submit handler on
        // #frmProductDomain (scripts.js:2724) inside its own
        // jQuery(document).ready, expecting DOM (#registersld /
        // #DomainSearchResults / #frmProductDomainSelections / ...) we
        // don't render. It silently blocks submission for every option.
        //
        // We must run AFTER scripts.min.js's ready callback so its handler
        // is in place when we drop it -- hence init() is wrapped in a
        // jQuery ready callback below (queued after scripts.min.js's,
        // since scripts.min.js loads earlier in the document).
        if (window.jQuery) {
            window.jQuery(form).off('submit');
        }

        var radios = form.querySelectorAll('input[name="domainoption"]');
    var panels = form.querySelectorAll('.dp-panel');
    var resultDomain = document.getElementById('resultDomain');
    var resultIncart = document.getElementById('resultIncartDomain');

    function showPanel(key) {
        panels.forEach(function (p) {
            p.classList.toggle('is-active', p.dataset.panel === key);
            p.removeAttribute('data-state');
        });
    }

    function readInput(panel, key) {
        var el = panel.querySelector('[data-input="' + key + '"]');
        return el ? String(el.value || '').trim() : '';
    }

    // Switch visible panel when option radio changes.
    //
    // Bind BOTH native 'change' and iCheck's 'ifChecked' event:
    //   - 'change'    — used by the apple-client-area mockup (no iCheck).
    //   - 'ifChecked' — used in production. WHMCS's scripts.min.js wraps
    //     each radio in iCheck (.iradio_square-blue + .iCheck-helper),
    //     which swallows the native 'change' event and exposes its own
    //     jQuery-only events. Without this, clicking the third option
    //     ticks the radio but never swaps the dp-panel.
    radios.forEach(function (r) {
        r.addEventListener('change', function () { showPanel(r.value); });
        if (window.jQuery) {
            window.jQuery(r).on('ifChecked', function () { showPanel(r.value); });
        }
    });

    // Clear error state once the user starts typing.
    panels.forEach(function (p) {
        p.querySelectorAll('.dp-input').forEach(function (inp) {
            inp.addEventListener('input', function () { p.removeAttribute('data-state'); });
        });
    });

    // Populate the hidden submit fields based on the chosen option.
    form.addEventListener('submit', function () {
        var checked = form.querySelector('input[name="domainoption"]:checked');
        var opt = checked ? checked.value : 'register';
        var panel = form.querySelector('.dp-panel.is-active') ||
                    form.querySelector('[data-panel="' + opt + '"]');
        if (!panel) return;

        resultDomain.value = '';
        resultIncart.value = '';

        if (opt === 'incart') {
            resultIncart.value = readInput(panel, 'incartsld');
        } else if (opt === 'register' || opt === 'transfer') {
            var sld = readInput(panel, 'sld').toLowerCase();
            var tld = readInput(panel, 'tld');
            if (sld) resultDomain.value = sld + tld;
        } else if (opt === 'owndomain') {
            // Split SLD + free-text TLD (mirrors standard_cart). User can enter
            // any TLD — WHMCS server-side validates the join is parseable.
            var sld = readInput(panel, 'sld').toLowerCase();
            var tld = readInput(panel, 'tld').toLowerCase().replace(/^\./, '');
            if (sld && tld) resultDomain.value = sld + '.' + tld;
        } else if (opt === 'subdomain') {
            var sld = readInput(panel, 'sld').toLowerCase();
            var parent = readInput(panel, 'tld');
            if (sld && parent) resultDomain.value = sld + '.' + parent;
        }
    });

        // ── WHMCS owndomain validation (mirrors standard_cart) ──
        // Standard_cart's domain panel POSTs to WHMCS's /domain/check
        // endpoint to verify the entered domain (right format, not
        // already in cart, etc.) BEFORE accepting the submission.
        // Mirror that here so an invalid domain in the owndomain panel
        // shows a proper error instead of getting silently bounced
        // back by the server.
        //
        // Implementation: hook another submit listener that runs FIRST
        // (capture phase). For owndomain only, intercept, AJAX-call
        // /domain/check, then re-fire form.submit() with the bypass
        // flag set so we don't loop.
        var ownValidationBypass = false;
        form.addEventListener('submit', function (ev) {
            if (ownValidationBypass) return; // re-fire from successful AJAX
            var checked = form.querySelector('input[name="domainoption"]:checked');
            if (!checked || checked.value !== 'owndomain') return;
            var panel = form.querySelector('[data-panel="owndomain"]');
            if (!panel) return;
            var sld = readInput(panel, 'sld').toLowerCase();
            var tld = readInput(panel, 'tld').toLowerCase().replace(/^\./, '');
            if (!sld || !tld) {
                ev.preventDefault();
                showOwndomainError(panel, _localLang.ownDomainNeedBoth);
                return;
            }

            ev.preventDefault();
            clearOwndomainError(panel);
            var btn = panel.querySelector('button.dp-search-cta');
            var btnOriginalText = btn ? btn.textContent : null;
            if (btn) { btn.disabled = true; btn.textContent = _localLang.domainChecking; }

            var pid = (form.querySelector('input[name="pid"]') || {}).value || '';
            var csrfMeta = document.querySelector('meta[name="csrf-token"]');
            var csrf = csrfMeta ? csrfMeta.getAttribute('content') : '';
            var routeBase = (window.WHMCS_BASE_URL || '');

            // POST to /domain/check via the WHMCS jQuery helper if
            // available (handles the WHMCS CSRF / route prefixing
            // internals); otherwise fall through to a plain fetch.
            var doRequest;
            if (window.WHMCS && WHMCS.utils && WHMCS.utils.getRouteUrl) {
                doRequest = window.jQuery.post(
                    WHMCS.utils.getRouteUrl('/domain/check'),
                    { token: csrf, type: 'owndomain', pid: pid, domain: sld + '.' + tld, sld: sld, tld: '.' + tld, source: 'cartAddDomain' },
                    null, 'json'
                );
            } else {
                doRequest = fetch(routeBase + '/index.php/domain/check', {
                    method: 'POST', credentials: 'include',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'Accept': 'application/json' },
                    body: 'token=' + encodeURIComponent(csrf) + '&type=owndomain&pid=' + encodeURIComponent(pid) +
                          '&domain=' + encodeURIComponent(sld + '.' + tld) +
                          '&sld=' + encodeURIComponent(sld) + '&tld=' + encodeURIComponent('.' + tld) +
                          '&source=cartAddDomain'
                }).then(function (r) { return r.json(); });
            }

            (window.jQuery && doRequest.done ? doRequest.done.bind(doRequest) : doRequest.then.bind(doRequest))(function (data) {
                var ok = false;
                if (data && data.result) {
                    var first = Array.isArray(data.result) ? data.result[0] : data.result;
                    if (first && first.status === true) ok = true;
                }
                if (ok) {
                    if (btn) { btn.disabled = false; btn.textContent = btnOriginalText; }
                    ownValidationBypass = true;
                    form.submit();
                } else {
                    if (btn) { btn.disabled = false; btn.textContent = btnOriginalText; }
                    var msg = '';
                    if (data && data.result) {
                        var first = Array.isArray(data.result) ? data.result[0] : data.result;
                        if (typeof first === 'string') msg = first;
                        else if (first && first.message) msg = first.message;
                    }
                    showOwndomainError(panel, msg || _localLang.domainInvalid);
                }
            });
            (window.jQuery && doRequest.fail ? doRequest.fail.bind(doRequest) : doRequest.catch.bind(doRequest))(function () {
                if (btn) { btn.disabled = false; btn.textContent = btnOriginalText; }
                // On network / route failure, fall back to the previous
                // behaviour: let the form submit and let WHMCS server-side
                // do its own validation.
                ownValidationBypass = true;
                form.submit();
            });
        }, true); // capture so this runs before the field-populating handler

        function showOwndomainError(panel, message) {
            clearOwndomainError(panel);
            var box = document.createElement('div');
            box.className = 'dp-error compact';
            box.setAttribute('data-apple-owndomain-error', '1');
            box.style.cssText = 'margin: 12px 24px 0; padding: 10px 14px; background: var(--color-red-bg, rgba(255,59,48,0.08)); color: var(--color-red-text, #d70015); border: 0.5px solid var(--color-red-text, #d70015); border-radius: 8px; font-size: 12.5px; line-height: 1.5;';
            box.textContent = message;
            panel.appendChild(box);
            panel.setAttribute('data-state', 'error');
        }
        function clearOwndomainError(panel) {
            var existing = panel.querySelector('[data-apple-owndomain-error]');
            if (existing) existing.parentNode.removeChild(existing);
            panel.removeAttribute('data-state');
        }

        // Sync panel to whichever radio is initially checked.
        var initial = form.querySelector('input[name="domainoption"]:checked');
        if (initial) showPanel(initial.value);
    }

    if (window.jQuery) {
        // Queues AFTER scripts.min.js's ready callback (since scripts.min.js
        // loads earlier in the document and its ready was registered first).
        window.jQuery(init);
    } else if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
{/literal}
</script>
