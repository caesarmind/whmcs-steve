{*
 * hadrian_cart/configureproductdomain.tpl — mockup-faithful rebuild
 *
 * Visual source: the v18 client-area mockups
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
 * The domain check: every option asks WHMCS's /domain/check first, as
 * standard_cart does (scripts.js, #frmProductDomain submit), because the
 * a=add&domainselect=1 POST itself validates nothing.
 *   - owndomain / subdomain / incart: the check ADDS the plan to the cart
 *     and answers its cart index (result[].num); the page then goes to
 *     cart.php?a=confproduct&i=<num>. The form is never submitted, or the
 *     plan would be added twice.
 *   - register / transfer: the check only looks the name up. The form is
 *     submitted (with the name WHMCS returned) when it is valid and free
 *     (register) or registered elsewhere (transfer).
 *   - The check needs the CSRF token (window.csrfToken, header.tpl). Without
 *     it WHMCS answers 302 and resets the session: that once signed the
 *     customer out and emptied the cart (tests/FEATURES.md, bugs 37-39).
 *
 * JS contract DROPPED (per user direction "replace JS where it
 * conflicts"):
 *   - scripts.min.js's result UI (#DomainSearchResults, spotlight,
 *     suggestions); the inline script below runs the check instead.
 *   - $showAdvancedSearchOptions AI search variant + tlds[] / maxLength
 *     / safe-search multiselect. Re-introduce as a separate panel later.
 *   - $spotlightTlds card grid + $domainSuggestions / suggested-domains
 *     list — those are scripts.min.js-driven AJAX features.
 *   - $idnLanguages selector — IDN registrations now happen server-side
 *     only; edge case for follow-up.
 *
 * The inline <script> at the bottom owns the new behavior:
 *   - Swap visible .dp-panel when the radio in .dp-options changes.
 *   - On form submit, read the active panel's [data-input] fields, run
 *     the domain check above, and show WHMCS's answer in the panel.
 *   - Clear panel error state on input.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    {* Note: hadrian's header.tpl already opens <div class="content-area">
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

                        {* ─── Option radio cards ───
                           Selected on arrival: what WHMCS passes (it defaults to
                           register), except that Register with no TLD priced can never
                           be completed, so a customer who can bring their own domain
                           starts there instead. *}
                        {$_opt = $domainoption|default:'register'}
                        {if $_opt eq 'register' && !$registertlds && $owndomainenabled}{$_opt = 'owndomain'}{/if}
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
                                {$_chk = ($_opt eq "register")}
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
                                {$_chk = ($_opt eq "owndomain")}
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
                                    <select class="dp-input no-ico" data-input="incartsld" aria-label="{$LANG.orderdomain|escape}">
                                        {foreach $incartdomains as $incartdomain}
                                            <option value="{$incartdomain}">{$incartdomain}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.use}</button>
                                </div>
                            </div>
                        {/if}

                        {if $registerdomainenabled}
                            <div class="dp-panel{if $_opt eq "register"} is-active{/if}" data-panel="register">
                                {* No TLDs priced for registration (no registrar set up yet): an
                                   empty extension list reads as broken, so say why and where to
                                   go instead. *}
                                {if !$registertlds}
                                    <div class="dp-unavailable" role="status">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                        <p>{$hadrianLang.cart.registerUnavailable} <a href="{$WEB_ROOT}/contact.php">{$LANG.contactUs}</a></p>
                                    </div>
                                {else}
                                <p class="dp-panel-hint">{$hadrianLang.cart.registerPanelHint}</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="{$hadrianLang.cart.registerSldPlaceholder}" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <select class="dp-input no-ico" data-input="tld" aria-label="{$LANG.tld|escape}" style="flex: 0 0 130px;">
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
                                {/if}
                            </div>
                        {/if}

                        {if $transferdomainenabled}
                            <div class="dp-panel{if $domainoption eq "transfer"} is-active{/if}" data-panel="transfer">
                                {if !$transfertlds}
                                    <div class="dp-unavailable" role="status">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                        <p>{$hadrianLang.cart.transferUnavailable} <a href="{$WEB_ROOT}/contact.php">{$LANG.contactUs}</a></p>
                                    </div>
                                {else}
                                <p class="dp-panel-hint">{$hadrianLang.cart.transferPanelHint}</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="{$hadrianLang.cart.transferSldPlaceholder}" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <select class="dp-input no-ico" data-input="tld" aria-label="{$LANG.tld|escape}" style="flex: 0 0 130px;">
                                        {foreach from=$transfertlds item=listtld}
                                            <option value="{$listtld}"{if $listtld eq $tld} selected{/if}>{$listtld}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.transfer}</button>
                                </div>
                                <p class="dp-example">
                                    {$hadrianLang.cart.transferRequirements}
                                </p>
                                {/if}
                            </div>
                        {/if}

                        {if $owndomainenabled}
                            {* Owndomain panel — split SLD + free-text TLD, mirroring standard_cart.
                               TLD is a TEXT input (not a <select>) because owndomain must accept
                               ANY TLD — not just registrar-supported ones. Register/transfer use
                               <select> populated from $registertlds / $transfertlds because those
                               flows are restricted to TLDs we actually sell.
                               JS submit handler joins sld + '.' + tld into resultDomain. *}
                            <div class="dp-panel{if $_opt eq "owndomain"} is-active{/if}" data-panel="owndomain">
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
                                    <select class="dp-input no-ico" data-input="tld" aria-label="{$LANG.tld|escape}" style="flex: 0 0 200px;">
                                        {foreach $subdomains as $subid => $subdomain}
                                            <option value="{$subdomain}">.{$subdomain}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.check}</button>
                                </div>
                            </div>
                        {/if}

                        {* ─── Footer: Back / Continue ───
                           No privacy promise here: WHOIS/ID protection is a
                           per-TLD domain addon the host may charge for or
                           not offer, so the domain config step shows it. *}
                        <div class="dp-footer">
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

{* Smarty-to-JS lang seed for the domain check below. That script runs
   inside a Smarty literal block and cannot read Smarty vars directly. *}
<script>
var _localLang = {
    ownDomainNeedBoth: '{$hadrianLang.cart.ownDomainNeedBoth|escape:"javascript"}',
    domainNameRequired: '{$hadrianLang.cart.domainNameRequired|escape:"javascript"}',
    domainChecking: '{$hadrianLang.cart.domainChecking|escape:"javascript"}',
    domainCheckFailed: '{$hadrianLang.cart.domainCheckFailed|escape:"javascript"}',
    domainInvalid: '{$LANG.cartdomaininvalid|escape:"javascript"}',
    domainUnavailable: '{$LANG.orderForm.domainIsUnavailable|default:":domain is unavailable"|escape:"javascript"}',
    transferNotRegistered: '{$LANG.orderForm.transferNotRegistered|default:"The domain you entered does not appear to be registered."|escape:"javascript"}',
    contactSupport: '{$LANG.domainChecker.contactSupport|default:"Contact Support to Purchase"|escape:"javascript"}'
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
    //   - 'change'    — used by the client-area mockups (no iCheck).
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

    // ── The domain check (see the header comment) ──
    // One submit handler for every option. It always stops the native
    // submit, asks /domain/check, then either submits the form itself
    // (register, transfer) or goes to the configure step of the plan the
    // check just added (owndomain, subdomain, incart).
    var pid = (form.querySelector('input[name="pid"]') || {}).value || '';
    var submitting = false;

    function csrf() {
        if (typeof window.csrfToken === 'string' && window.csrfToken) return window.csrfToken;
        var input = form.querySelector('input[name="token"]');
        return input ? input.value : '';
    }

    // What the active panel asks for, in /domain/check's terms; null when
    // a field is empty.
    function query(opt, panel) {
        var sld, tld;
        if (opt === 'incart') {
            sld = readInput(panel, 'incartsld');
            return sld ? { sld: sld, tld: '', domain: sld } : null;
        }
        sld = readInput(panel, 'sld').toLowerCase();
        tld = readInput(panel, 'tld').toLowerCase().replace(/^\./, '');
        if (!sld || !tld) return null;
        return { sld: sld, tld: '.' + tld, domain: sld + '.' + tld };
    }

    function checkDomain(type, q) {
        var url = (window.WHMCS && WHMCS.utils && WHMCS.utils.getRouteUrl)
            ? WHMCS.utils.getRouteUrl('/domain/check')
            : (window.whmcsBaseUrl || window.WEB_ROOT || '') + '/index.php?rp=/domain/check';
        var body = new URLSearchParams();
        body.set('token', csrf());
        body.set('type', type);
        body.set('pid', pid);
        body.set('domain', q.domain);
        body.set('sld', q.sld);
        body.set('tld', q.tld);
        body.set('source', 'cartAddDomain');
        return fetch(url, {
            method: 'POST', credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: body.toString()
        }).then(function (r) {
            // A refused token answers with a redirect to an HTML page, which
            // fails here and is reported as a failed check.
            if (!r.ok) throw new Error('HTTP ' + r.status);
            return r.json();
        });
    }

    // data.result is a list of results, or an object such as
    // {"error": "The domain you entered is not valid"}.
    function results(data) {
        var r = data && data.result;
        if (Array.isArray(r)) return r;
        if (r && typeof r === 'object') {
            return Object.keys(r).map(function (k) { return k === 'error' ? { error: r[k] } : r[k]; });
        }
        return [];
    }
    function errorText(item) {
        if (typeof item === 'string') return item;
        if (item && item.error) return String(item.error).replace(/<br\s*\/?>/gi, ' ');
        return '';
    }
    function plainText(html) {
        var d = document.createElement('div');
        d.innerHTML = html;
        return d.textContent || '';
    }

    function goConfigure(num) {
        var url = (window.whmcsBaseUrl || window.WEB_ROOT || '') + '/cart.php?a=confproduct&i=' + encodeURIComponent(num);
        // standard_cart's recommendations modal, when the product has any.
        if (window.jQuery && typeof window.displayRecommendations === 'function') {
            try {
                window.displayRecommendations((window.whmcsBaseUrl || window.WEB_ROOT || '') + '/cart.php', 'addproductajax=1&a=confproduct&i=' + encodeURIComponent(num), false)
                    .done(function () { window.location = url; });
                return;
            } catch (e) {}
        }
        window.location = url;
    }

    function submitWith(domainName) {
        resultDomain.value = domainName;
        resultIncart.value = '';
        submitting = true;
        form.submit();
    }

    function handle(opt, panel, data) {
        var list = results(data);
        var item = list[0];
        var err = errorText(item);

        if (opt === 'owndomain' || opt === 'subdomain' || opt === 'incart') {
            if (item && item.status === true && item.num !== undefined && item.num !== null) {
                goConfigure(item.num);
                return true;
            }
            showPanelError(panel, err || _localLang.domainInvalid);
            return false;
        }

        if (!item) {
            showPanelError(panel, opt === 'transfer' ? _localLang.transferNotRegistered : _localLang.domainInvalid);
        } else if (err) {
            showPanelError(panel, err);
        } else if (!item.isValidDomain) {
            showPanelError(panel, item.domainErrorMessage || _localLang.domainInvalid);
        } else if (opt === 'transfer') {
            if (item.isRegistered) { submitWith(item.domainName); return true; }
            showPanelError(panel, _localLang.transferNotRegistered);
        } else if (item.isAvailable && typeof item.pricing !== 'string') {
            submitWith(item.domainName);
            return true;
        } else if (item.pricing === 'ContactUs') {
            showPanelError(panel, _localLang.contactSupport);
        } else {
            showPanelError(panel, plainText(_localLang.domainUnavailable.replace(':domain', item.domainName || '')));
        }
        return false;
    }

    form.addEventListener('submit', function (ev) {
        if (submitting) return;
        ev.preventDefault();
        var checked = form.querySelector('input[name="domainoption"]:checked');
        var opt = checked ? checked.value : 'register';
        var panel = form.querySelector('[data-panel="' + opt + '"]');
        if (!panel) return;
        clearPanelError(panel);

        var q = query(opt, panel);
        if (!q) {
            showPanelError(panel, opt === 'owndomain' ? _localLang.ownDomainNeedBoth : _localLang.domainNameRequired);
            return;
        }

        var buttons = form.querySelectorAll('button[type="submit"]');
        var btn = panel.querySelector('button.dp-search-cta');
        var btnHtml = btn ? btn.innerHTML : null;
        buttons.forEach(function (b) { b.disabled = true; });
        if (btn) btn.textContent = _localLang.domainChecking;
        function idle() {
            buttons.forEach(function (b) { b.disabled = false; });
            if (btn) btn.innerHTML = btnHtml;
        }

        checkDomain(opt === 'register' ? 'domain' : opt, q).then(function (data) {
            // On success the page is leaving: keep the buttons disabled.
            if (!handle(opt, panel, data)) idle();
        }).catch(function () {
            idle();
            showPanelError(panel, _localLang.domainCheckFailed);
        });
    });

    function showPanelError(panel, message) {
        clearPanelError(panel);
        var box = document.createElement('div');
        box.className = 'dp-error compact';
        box.setAttribute('data-hadrian-domain-error', '1');
        box.setAttribute('role', 'alert');
        box.style.cssText = 'margin: 12px 24px 0; padding: 10px 14px; background: var(--color-red-bg, rgba(255,59,48,0.08)); color: var(--color-red-text, #d70015); border: 0.5px solid var(--color-red-text, #d70015); border-radius: 8px; font-size: 12.5px; line-height: 1.5;';
        box.textContent = message;
        panel.appendChild(box);
        panel.setAttribute('data-state', 'error');
    }
    function clearPanelError(panel) {
        var existing = panel.querySelector('[data-hadrian-domain-error]');
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
