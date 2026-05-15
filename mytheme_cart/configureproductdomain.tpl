{*
 * mytheme_cart/configureproductdomain.tpl — mockup-faithful rebuild
 *
 * Visual source: apple-client-area/configureproductdomain.html
 *   Shell    = .dp-split (240px sidebar + main) wrapping
 *              .dp-steps (4-step progress strip)
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
        <h1>{$LANG.domaincheckerchoosedomain|default:'Choose a domain'}</h1>
        <p class="page-subtitle">{$LANG.choosedomainsubtitle|default:'Register something new, transfer one you already own, or point an existing domain at our nameservers.'}</p>
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
                        Choose plan
                    </span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step active"><span class="dp-step-num">2</span>Choose a domain</span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step"><span class="dp-step-num">3</span>Configure</span>
                    <span class="dp-step-sep">›</span>
                    <span class="dp-step"><span class="dp-step-num">4</span>Checkout</span>
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
                        <div class="dp-options" role="radiogroup" aria-label="How you'll provide a domain">

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
                                    <span class="dp-option-desc">Use a domain that's already in your cart.</span>
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
                                    <span class="dp-option-desc">Search and register a brand-new domain name.</span>
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
                                    <span class="dp-option-desc">Move your domain to us — usually includes a free year extension.</span>
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
                                    <span class="dp-option-desc">Keep it with your current registrar and point DNS at us.</span>
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
                                    <span class="dp-option-desc">Use a subdomain on one of our shared domains.</span>
                                </label>
                            {/if}

                        </div>

                        {* ─── Per-option search panels ─── *}

                        {if $incartdomains}
                            <div class="dp-panel{if $domainoption eq "incart"} is-active{/if}" data-panel="incart">
                                <p class="dp-panel-hint">Pick from the domains already in your cart.</p>
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
                                <p class="dp-panel-hint"><strong>Search by domain.</strong> We'll check availability across our registrar partners.</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="example" autocomplete="off" autocapitalize="none">
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
                                        <strong>Free domain on:</strong> {$freedomaintlds}
                                    </p>
                                {/if}
                            </div>
                        {/if}

                        {if $transferdomainenabled}
                            <div class="dp-panel{if $domainoption eq "transfer"} is-active{/if}" data-panel="transfer">
                                <p class="dp-panel-hint"><strong>Transfer your domain from another registrar.</strong> Most transfers add a <strong>free extra year</strong> to your registration.</p>
                                <div class="dp-search-row">
                                    <div class="dp-input-wrap">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                        <input type="text" class="dp-input" data-input="sld" value="{$sld}" placeholder="mydomain" autocomplete="off" autocapitalize="none">
                                    </div>
                                    <select class="dp-input no-ico" data-input="tld" style="flex: 0 0 130px;">
                                        {foreach from=$transfertlds item=listtld}
                                            <option value="{$listtld}"{if $listtld eq $tld} selected{/if}>{$listtld}</option>
                                        {/foreach}
                                    </select>
                                    <button type="submit" class="dp-search-cta">{$LANG.orderForm.transfer}</button>
                                </div>
                                <p class="dp-example">
                                    Before transferring: domain must be <strong>unlocked</strong>, registered for at least <strong>60 days</strong>, and you'll need the <strong>auth / EPP code</strong> from your current registrar.
                                </p>
                            </div>
                        {/if}

                        {if $owndomainenabled}
                            <div class="dp-panel{if $domainoption eq "owndomain"} is-active{/if}" data-panel="owndomain">
                                <p class="dp-panel-hint"><strong>I'll use my existing domain.</strong> After checkout we'll email you the nameservers to set at your current registrar.</p>
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
                                <p class="dp-panel-hint"><strong>Use a subdomain.</strong> Pick a parent domain and enter the prefix you'd like.</p>
                                <div class="dp-search-row">
                                    <input type="text" class="dp-input no-ico" data-input="sld" value="{$sld}" placeholder="yourname" autocomplete="off" autocapitalize="none">
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
                                Your domain details stay private — WHOIS privacy included on every TLD that supports it.
                            </span>
                            <span class="spacer"></span>
                            <a href="{$WEB_ROOT}/cart.php" class="dp-back">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                                Back
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

{include file="orderforms/standard_cart/recommendations-modal.tpl"}

<script>
{literal}
(function () {
    var form = document.getElementById('frmProductDomain');
    if (!form) return;

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
    radios.forEach(function (r) {
        r.addEventListener('change', function () { showPanel(r.value); });
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
            var sld = readInput(panel, 'sld').toLowerCase();
            var tld = readInput(panel, 'tld').toLowerCase();
            if (tld && tld.charAt(0) !== '.') tld = '.' + tld;
            if (sld) resultDomain.value = sld + tld;
        } else if (opt === 'subdomain') {
            var sld = readInput(panel, 'sld').toLowerCase();
            var parent = readInput(panel, 'tld');
            if (sld && parent) resultDomain.value = sld + '.' + parent;
        }
    });

    // Sync panel to whichever radio is initially checked.
    var initial = form.querySelector('input[name="domainoption"]:checked');
    if (initial) showPanel(initial.value);
})();
{/literal}
</script>
