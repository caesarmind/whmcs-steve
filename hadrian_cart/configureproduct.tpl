{*
 * hadrian_cart/configureproduct.tpl — mockup-faithful rebuild
 *
 * Visual source: apple-client-area/configureproduct.html
 *   Shell    = .cp-steps (5-step strip)
 *              + 2-col grid: main column + sticky .cp-summary-card
 *   Sections = .card > .cp-section (Billing cycle | Configuration |
 *                 Server info | Custom fields | Add-ons)
 *   Vocab    = .cp-cycle-opt (radio cards) for billing cycles
 *              .cp-opt-row for each configurable option / field
 *              .cp-opt-picker (select) / .cp-opt-qty (qty stepper)
 *              .st-addon for add-on cards
 *
 * Server contract preserved (these are what cart.php's POST handler
 * for `configure=true` reads):
 *   - <form id="frmConfigureProduct"> (no method/action — scripts.min.js
 *     submits via POST to PHP_SELF). We keep the same form id.
 *   - Hidden inputs: configure=true, i={$i}
 *   - billingcycle = monthly|quarterly|semiannually|annually|biennially|triennially
 *   - configoption[<id>] for each configurable option (value depends on
 *     optiontype: option id for select/radio, 1 for checkbox, qty for type 4)
 *   - hostname, rootpw, ns1prefix, ns2prefix (server type only)
 *   - customfield[<id>] (rendered by WHMCS as $customfield.input HTML)
 *   - addons[<id>] checkbox per add-on
 *
 * JS contract preserved (these power the live summary):
 *   - recalctotals() — re-fetches the summary HTML and injects into
 *     #producttotal. Wired to every qty input via onchange/onkeyup.
 *     Called once at the bottom to populate initially.
 *   - updateConfigurableOptions(i, cycle) — fires when billing cycle
 *     changes (some configoption prices vary by cycle). Wired to each
 *     billing-cycle radio's onchange.
 *   - ion.rangeSlider for configoptions where qtymaximum is set and
 *     range > 25 — kept as-is; widget styles fine inside .cp-opt-row.
 *
 * Dropped:
 *   - The "have questions? contact us" alert under the form. Not in
 *     the mockup. Easy to add back.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<script>
var _localLang = {
    'addToCart': '{$LANG.orderForm.addToCart|escape}',
    'addedToCartRemove': '{$LANG.orderForm.addedToCartRemove|escape}',
    'pwWeak': '{$hadrianLang.cart.pwWeak|escape:"javascript"}',
    'pwModerate': '{$hadrianLang.cart.pwModerate|escape:"javascript"}',
    'pwStrong': '{$hadrianLang.cart.pwStrong|escape:"javascript"}',
    'savePercent': '{$hadrianLang.cart.savePercent|escape:"javascript"}',
    'recalculatingPromo': '{$hadrianLang.cart.recalculatingPromo|escape:"javascript"}',
    'promoNoLongerApplies': '{$hadrianLang.cart.promoNoLongerApplies|escape:"javascript"}',
    'promoCodeTitle': '{$hadrianLang.cart.promoCodeTitle|escape:"javascript"}',
    'promoApplied': '{$hadrianLang.cart.promoApplied|escape:"javascript"}',
    'networkError': '{$hadrianLang.cart.networkError|escape:"javascript"}',
    'correctErrors': '{$LANG.orderForm.correctErrors|escape:"javascript"}'
};
</script>

<div id="order-standard_cart">

    {* hadrian/header.tpl already opens <div class="content-area"> for
       us; the inner wrapper that used to live here produced double
       padding. Class renamed from .page-header to .st-page-header to
       match products.tpl (style.min.css only defines rules for the
       latter). *}

    <header class="st-page-header">
        <h1>{$LANG.orderconfigure}</h1>
        <p class="page-subtitle">{$hadrianLang.cart.configSubtitle}</p>
    </header>

        <div class="cp-steps" aria-label="Order progress">
            <span class="cp-step done">
                <span class="cp-step-num">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </span>
                {$hadrianLang.cart.stepChoosePlan}
            </span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step done">
                <span class="cp-step-num">
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </span>
                {$LANG.domaincheckerchoosedomain}
            </span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step active"><span class="cp-step-num">3</span>{$hadrianLang.cart.stepConfigure}</span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step"><span class="cp-step-num">4</span>{$hadrianLang.cart.stepCart}</span>
            <span class="cp-step-sep">›</span>
            <span class="cp-step"><span class="cp-step-num">5</span>{$hadrianLang.cart.stepCheckout}</span>
        </div>

        <form id="frmConfigureProduct">
            <input type="hidden" name="configure" value="true">
            <input type="hidden" name="i" value="{$i}">

            <div class="cp-grid">

                {* ════════════════════════════════════════════
                   LEFT COLUMN
                   ════════════════════════════════════════════ *}
                <div class="cp-main">

                    {* Validation errors (populated by scripts.min.js) *}
                    <div class="alert alert-danger w-hidden" role="alert" id="containerProductValidationErrors">
                        <p>{$LANG.orderForm.correctErrors}:</p>
                        <ul id="containerProductValidationErrorsList"></ul>
                    </div>

                    {* ── Selected-plan hero ────────────────────────────
                       Shows the product picked on the products step (icon
                       + name + short description) and, when WHMCS has
                       captured a domain on the previous configureproductdomain
                       step, a second row with the chosen domain + "Included"
                       badge. The mockup combines both inside one .card with
                       a top + bottom row separated by a 0.5px divider. *}
                    <div class="card cp-plan-hero-card">
                        <div class="cp-plan-hero">
                            <div class="cp-plan-hero-ico" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
                            </div>
                            <div class="cp-plan-hero-meta">
                                <div class="cp-plan-hero-eyebrow">{$hadrianLang.cart.selectedPlan}</div>
                                <div class="cp-plan-hero-name">{$productinfo.name}</div>
                                {if $productinfo.description}
                                    <div class="cp-plan-hero-desc">{$productinfo.description|strip_tags|truncate:120}</div>
                                {/if}
                            </div>
                            <a href="{$WEB_ROOT}/cart.php{if $productinfo.gid}?gid={$productinfo.gid}{/if}" class="cp-plan-hero-change">
                                {$hadrianLang.cart.changePlan}
                            </a>
                        </div>

                        {if $domain}
                            <div class="cp-plan-hero-domain">
                                <svg class="cp-plan-hero-domain-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
                                <div class="cp-plan-hero-domain-meta">
                                    <div class="cp-plan-hero-domain-label">{$LANG.domain|default:'Domain'}</div>
                                    <div class="cp-plan-hero-domain-value">
                                        <span class="cp-plan-hero-domain-name">{$domain}</span>
                                        {if $domainoption eq "owndomain" || $domainoption eq "subdomain"}
                                            <span class="cp-plan-hero-domain-badge">{$hadrianLang.cart.domainIncluded}</span>
                                        {/if}
                                    </div>
                                </div>
                                {* "Change" sends the user back to the configureproductdomain step
                                   for THIS specific plan. We use $productinfo.pid (NOT $pid -- on
                                   the configureproduct route WHMCS only exposes $pid on the
                                   configureproductdomain step). With a real pid, WHMCS rewrites
                                   cart.php?a=add&pid=X to the friendly URL /store/<group>/<plan>
                                   and re-enters the domain picker. *}
                                <a href="{$WEB_ROOT}/cart.php?a=add&pid={$productinfo.pid}" class="cp-plan-hero-change">
                                    {$hadrianLang.cart.changeDomain}
                                </a>
                            </div>
                        {/if}
                    </div>

                    {* ── Billing cycle (only for recurring products) ── *}
                    {if $pricing.type eq "recurring"}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$hadrianLang.cart.billingCycle}</h2>
                                <div class="cp-section-sub">{$hadrianLang.cart.billingCycleSub}</div>
                            </div>
                            <div class="cp-section-body">
                                {* ── Billing-cycle cards ──
                                   Each card lays out as: cycle name (title) +
                                   "Billed every X" sub-description + the
                                   WHMCS-formatted price as a prominent number.
                                   WHMCS provides each cycle's price as a
                                   pre-formatted string ($pricing.monthly etc.),
                                   so we drop it into .cp-cycle-price which
                                   styles it large + tabular-nums. The mockup
                                   also shows "SAVE X%" badges on annual+; that
                                   would require computing the per-cycle
                                   savings from the raw prices, which WHMCS
                                   doesn't expose directly — skipped for now. *}
                                <div class="cp-cycle" role="radiogroup" aria-label="{$LANG.cartchoosecycle}">
                                    {if $pricing.monthly}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="monthly"{if $billingcycle eq "monthly"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermmonthly}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedMonthly}</div>
                                            <div class="cp-cycle-price">{$pricing.monthly}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.quarterly}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="quarterly"{if $billingcycle eq "quarterly"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermquarterly}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedQuarterly}</div>
                                            <div class="cp-cycle-price">{$pricing.quarterly}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.semiannually}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="semiannually"{if $billingcycle eq "semiannually"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermsemiannually}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedSemiannually}</div>
                                            <div class="cp-cycle-price">{$pricing.semiannually}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.annually}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="annually"{if $billingcycle eq "annually"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermannually}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedAnnually}</div>
                                            <div class="cp-cycle-price">{$pricing.annually}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.biennially}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="biennially"{if $billingcycle eq "biennially"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermbiennially}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedBiennially}</div>
                                            <div class="cp-cycle-price">{$pricing.biennially}</div>
                                        </label>
                                    {/if}
                                    {if $pricing.triennially}
                                        <label class="cp-cycle-opt">
                                            <input type="radio" name="billingcycle" value="triennially"{if $billingcycle eq "triennially"} checked{/if} onchange="updateConfigurableOptions({$i}, this.value); return false;">
                                            <div class="cp-cycle-title">{$LANG.orderpaymenttermtriennially}</div>
                                            <div class="cp-cycle-sub">{$hadrianLang.cart.billedTriennially}</div>
                                            <div class="cp-cycle-price">{$pricing.triennially}</div>
                                        </label>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Usage-billing metrics (if any) ── *}
                    {if count($metrics) > 0}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.metrics.title}</h2>
                                <div class="cp-section-sub">{$LANG.metrics.explanation}</div>
                            </div>
                            <div class="cp-section-body">
                                <ul class="cp-metric-list">
                                    {foreach $metrics as $metric}
                                        <li class="cp-opt-row">
                                            <div class="cp-opt-meta">
                                                <div class="cp-opt-name">{$metric.displayName}</div>
                                                <div class="cp-opt-desc">
                                                    {if count($metric.pricing) > 1}
                                                        {$LANG.metrics.startingFrom} {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                                    {elseif count($metric.pricing) == 1}
                                                        {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                                                        {if $metric.includedQuantity > 0} · {$metric.includedQuantity} {$LANG.metrics.includedNotCounted}{/if}
                                                    {/if}
                                                </div>
                                            </div>
                                            {if count($metric.pricing) > 1}
                                                <button type="button" class="btn-secondary" data-toggle="modal" data-target="#modalMetricPricing-{$metric.systemName}">
                                                    {$LANG.metrics.viewPricing}
                                                </button>
                                            {/if}
                                            {include file="$template/usagebillingpricing.tpl"}
                                        </li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>
                    {/if}

                    {* ── Server info (only for product type=server) ──
                       Lagom-parity Order Process controls (admin Settings →
                       Order Process), read from $hadrian.addonSettings:
                         - op_hide_nameservers / op_hide_hostname: off|all|selected
                           (+ *_groups GID list) hide the ns / hostname+rootpw
                           fields, keeping hidden-but-submitted inputs so the
                           WHMCS POST contract holds.
                         - op_custom_hostname (+ prefix/interfix/suffix/chars):
                           auto-generates the hidden hostname; the root pw is
                           auto-randomised.
                         - op_root_pw_strength: a strength meter on the visible
                           root-pw field (server-enforced in hooks.php).
                       Everything falls back to "off"/show when unset, so an
                       un-configured install renders exactly as before. *}
                    {if $productinfo.type eq "server"}
                        {assign var=opNs value=$hadrian.addonSettings.op_hide_nameservers|default:'off'}
                        {assign var=opHost value=$hadrian.addonSettings.op_hide_hostname|default:'off'}
                        {assign var=mtHideNs value=false}
                        {assign var=mtHideHost value=false}
                        {if $opNs == 'all'}
                            {assign var=mtHideNs value=true}
                        {elseif $opNs == 'selected'}
                            {assign var=nsGroups value=$hadrian.addonSettings.op_hide_nameservers_groups|default:[]}
                            {if is_array($nsGroups) && $productinfo.gid|in_array:$nsGroups}{assign var=mtHideNs value=true}{/if}
                        {/if}
                        {if $opHost == 'all'}
                            {assign var=mtHideHost value=true}
                        {elseif $opHost == 'selected'}
                            {assign var=hostGroups value=$hadrian.addonSettings.op_hide_hostname_groups|default:[]}
                            {if is_array($hostGroups) && $productinfo.gid|in_array:$hostGroups}{assign var=mtHideHost value=true}{/if}
                        {/if}
                        {assign var=mtPwStrength value=$hadrian.addonSettings.op_root_pw_strength|default:false}

                        <div class="card cp-section"{if $mtHideNs && $mtHideHost} style="display:none"{/if}>
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.cartconfigserver}</h2>
                                <div class="cp-section-sub">{$hadrianLang.cart.serverInfoSub}</div>
                            </div>
                            <div class="cp-section-body">
                                <div class="cp-form-grid">
                                    {if $mtHideHost}
                                        {* Hostname + root pw hidden — auto-filled + still submitted. *}
                                        {assign var=hnInterfix  value=$hadrian.addonSettings.op_custom_hostname_interfix|default:20}
                                        {assign var=hnPrefixRaw value=$hadrian.addonSettings.op_custom_hostname_prefix|default:''}
                                        {assign var=hnSuffix    value=$hadrian.addonSettings.op_custom_hostname_suffix|default:''}
                                        {assign var=hnCustom    value=$hadrian.addonSettings.op_custom_hostname|default:false}
                                        {assign var=hnCharsSet  value=$hadrian.addonSettings.op_custom_hostname_chars|default:[]}
                                        {if $hnPrefixRaw != ''}{assign var=hnPrefix value=".`$hnPrefixRaw`"}{else}{assign var=hnPrefix value=""}{/if}
                                        {assign var=hnTail value="`$hnPrefix``$hnSuffix`"}
                                        {if $hnTail == ''}
                                            {assign var=hnSlug value=$companyname|default:''|lower|regex_replace:'/[^a-z0-9]/':''}
                                            {if $hnSlug == ''}{assign var=hnSlug value='host'}{/if}
                                            {assign var=hnTail value=".`$hnSlug`.com"}
                                        {/if}
                                        {assign var=hnUpper value="ABCDEFGHIJKLMNOPQRSTUVWXYZ"}
                                        {assign var=hnLower value="abcdefghijklmnopqrstuvwxyz"}
                                        {assign var=hnNum   value="0123456789"}
                                        {if !$hnCustom || !is_array($hnCharsSet) || $hnCharsSet|@count == 0 || $hnCharsSet|@count == 3}
                                            {assign var=hnChars value="`$hnUpper``$hnLower``$hnNum`"}
                                        {else}
                                            {assign var=hnChars value=""}
                                            {if "upper"|in_array:$hnCharsSet}{assign var=hnChars value="`$hnChars``$hnUpper`"}{/if}
                                            {if "lower"|in_array:$hnCharsSet}{assign var=hnChars value="`$hnChars``$hnLower`"}{/if}
                                            {if "numbers"|in_array:$hnCharsSet}{assign var=hnChars value="`$hnChars``$hnNum`"}{/if}
                                            {if $hnChars == ''}{assign var=hnChars value="`$hnUpper``$hnLower``$hnNum`"}{/if}
                                        {/if}
                                        <div style="display:none">
                                            <input type="text" name="hostname" id="inputHostname" value="{$server.hostname}">
                                            <input type="text" name="rootpw" id="inputRootpw" value="{$server.rootpw}">
                                        </div>
                                        {literal}<script>
                                        (function () {
                                            function mtMakeId(len){var c='{/literal}{$hnChars|escape:'javascript'}{literal}',r='',i;for(i=0;i<len;i++){r+=c.charAt(Math.floor(Math.random()*c.length));}return r;}
                                            function mtGenPass(n){var a='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',d='123456789',s='@#$%^&*-+=?',p='',h=Math.ceil(n/2)-1,sp=n-2*h,i;for(i=0;i<h;i++){p+=a.charAt(Math.floor(Math.random()*a.length));p+=d.charAt(Math.floor(Math.random()*d.length));}for(i=0;i<sp;i++){p+=s.charAt(Math.floor(Math.random()*s.length));}return p.split('').sort(function(){return 0.5-Math.random();}).join('');}
                                            function mtFill(){var hh=document.getElementById('inputHostname');if(hh&&!hh.value){hh.value=mtMakeId(parseInt('{/literal}{$hnInterfix}{literal}',10)||20)+'{/literal}{$hnTail|escape:'javascript'}{literal}';}var pp=document.getElementById('inputRootpw');if(pp&&!pp.value){pp.value=mtGenPass(14);}}
                                            if(window.jQuery){jQuery(mtFill);}else if(document.readyState!=='loading'){mtFill();}else{document.addEventListener('DOMContentLoaded',mtFill);}
                                        })();
                                        </script>{/literal}
                                    {else}
                                        <div class="cp-field">
                                            <label for="inputHostname">{$LANG.serverhostname}</label>
                                            <input type="text" name="hostname" id="inputHostname" class="cp-input" value="{$server.hostname}" placeholder="servername.example.com">
                                        </div>
                                        {if $mtPwStrength}
                                            <div class="cp-field">
                                                <label for="inputRootpw">{$LANG.serverrootpw}</label>
                                                <input type="password" name="rootpw" id="inputRootpw" class="cp-input" value="{$server.rootpw}">
                                                <input type="hidden" name="rootpwstrength" value="true">
                                                <div class="cp-pw-meter" id="cpPwMeter" aria-hidden="true"><span class="cp-pw-meter-bar" id="cpPwBar"></span></div>
                                                <div class="cp-pw-label" id="cpPwLabel"></div>
                                            </div>
                                            {literal}<script>
                                            (function () {
                                                var inp=document.getElementById('inputRootpw'),bar=document.getElementById('cpPwBar'),lab=document.getElementById('cpPwLabel'),meter=document.getElementById('cpPwMeter');
                                                if(!inp||!bar||!lab||!meter)return;
                                                function score(pw){var l=Math.min(pw.length,5),n=Math.min((pw.match(/[0-9]/g)||[]).length,3),s=Math.min((pw.match(/\W/g)||[]).length,3),u=Math.min((pw.match(/[A-Z]/g)||[]).length,3),v=(l*10-20)+(n*10)+(s*15)+(u*10);return Math.max(0,Math.min(100,v));}
                                                function upd(){var pw=inp.value||'';if(!pw.length){meter.style.opacity=0;lab.textContent='';return;}meter.style.opacity=1;var v=score(pw),c,t;if(v<50){c='var(--color-red,#ff3b30)';t=_localLang.pwWeak;}else if(v<75){c='var(--color-orange,#ff9500)';t=_localLang.pwModerate;}else{c='var(--color-green,#34c759)';t=_localLang.pwStrong;}bar.style.width=v+'%';bar.style.background=c;lab.textContent=t;lab.style.color=c;}
                                                inp.addEventListener('input',upd);inp.addEventListener('keyup',upd);upd();
                                            })();
                                            </script>{/literal}
                                        {else}
                                            <div class="cp-field">
                                                <label for="inputRootpw">{$LANG.serverrootpw}</label>
                                                <input type="password" name="rootpw" id="inputRootpw" class="cp-input" value="{$server.rootpw}">
                                            </div>
                                        {/if}
                                    {/if}

                                    {if $mtHideNs}
                                        <div style="display:none">
                                            <input type="text" name="ns1prefix" id="inputNs1prefix" value="{if $server.ns1prefix}{$server.ns1prefix}{else}ns1{/if}">
                                            <input type="text" name="ns2prefix" id="inputNs2prefix" value="{if $server.ns2prefix}{$server.ns2prefix}{else}ns2{/if}">
                                        </div>
                                    {else}
                                        <div class="cp-field">
                                            <label for="inputNs1prefix">{$LANG.serverns1prefix}</label>
                                            <input type="text" name="ns1prefix" id="inputNs1prefix" class="cp-input" value="{$server.ns1prefix}" placeholder="ns1">
                                        </div>
                                        <div class="cp-field">
                                            <label for="inputNs2prefix">{$LANG.serverns2prefix}</label>
                                            <input type="text" name="ns2prefix" id="inputNs2prefix" class="cp-input" value="{$server.ns2prefix}" placeholder="ns2">
                                        </div>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Configurable options ── *}
                    {if $configurableoptions}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.orderconfigpackage}</h2>
                                <div class="cp-section-sub">{$hadrianLang.cart.configOptionsSub}</div>
                            </div>
                            <div class="cp-section-body" id="productConfigurableOptions">
                                {foreach $configurableoptions as $num => $configoption}
                                    <div class="cp-opt-row">
                                        <div class="cp-opt-meta">
                                            <div class="cp-opt-name">
                                                <label for="inputConfigOption{$configoption.id}">{$configoption.optionname}</label>
                                            </div>
                                            {if $configoption.optiontype eq 3 && $configoption.options.0.name}
                                                <div class="cp-opt-desc">{$configoption.options.0.name}</div>
                                            {/if}
                                        </div>
                                        <div class="cp-opt-control">
                                            {if $configoption.optiontype eq 1}
                                                {* Dropdown *}
                                                <select name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" class="cp-opt-picker">
                                                    {foreach key=num2 item=options from=$configoption.options}
                                                        <option value="{$options.id}"{if $configoption.selectedvalue eq $options.id} selected{/if}>{$options.name}</option>
                                                    {/foreach}
                                                </select>
                                            {elseif $configoption.optiontype eq 2}
                                                {* Radio group *}
                                                <div class="cp-opt-radios">
                                                    {foreach key=num2 item=options from=$configoption.options}
                                                        <label class="cp-opt-radio">
                                                            <input type="radio" name="configoption[{$configoption.id}]" value="{$options.id}"{if $configoption.selectedvalue eq $options.id} checked{/if}>
                                                            <span>{if $options.name}{$options.name}{else}{$LANG.enable}{/if}</span>
                                                        </label>
                                                    {/foreach}
                                                </div>
                                            {elseif $configoption.optiontype eq 3}
                                                {* Checkbox / toggle *}
                                                <label class="cp-toggle">
                                                    <input type="checkbox" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="1"{if $configoption.selectedqty} checked{/if}>
                                                    <span class="cp-toggle-track" aria-hidden="true"></span>
                                                </label>
                                            {elseif $configoption.optiontype eq 4}
                                                {* Quantity (with optional range slider for large ranges) *}
                                                {if $configoption.qtymaximum}
                                                    {if !$rangesliderincluded}
                                                        <script type="text/javascript" src="{$BASE_PATH_JS}/ion.rangeSlider.min.js"></script>
                                                        <link href="{$BASE_PATH_CSS}/ion.rangeSlider.css" rel="stylesheet">
                                                        <link href="{$BASE_PATH_CSS}/ion.rangeSlider.skinModern.css" rel="stylesheet">
                                                        {assign var='rangesliderincluded' value=true}
                                                    {/if}
                                                    <input type="text" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}">
                                                    <script>
                                                        var sliderTimeoutId = null;
                                                        var sliderRangeDifference = {$configoption.qtymaximum} - {$configoption.qtyminimum};
                                                        var sliderStepThreshold = 25;
                                                        var setLargerMarkers = sliderRangeDifference > sliderStepThreshold;
                                                        jQuery("#inputConfigOption{$configoption.id}").ionRangeSlider({
                                                            min: {$configoption.qtyminimum},
                                                            max: {$configoption.qtymaximum},
                                                            grid: true,
                                                            grid_snap: setLargerMarkers ? false : true,
                                                            onChange: function () {
                                                                if (sliderTimeoutId) clearTimeout(sliderTimeoutId);
                                                                sliderTimeoutId = setTimeout(function () {
                                                                    sliderTimeoutId = null;
                                                                    recalctotals();
                                                                }, 250);
                                                            }
                                                        });
                                                    </script>
                                                {else}
                                                    <div class="cp-opt-qty">
                                                        <input type="number" name="configoption[{$configoption.id}]" id="inputConfigOption{$configoption.id}" value="{if $configoption.selectedqty}{$configoption.selectedqty}{else}{$configoption.qtyminimum}{/if}" min="{$configoption.qtyminimum}" onchange="recalctotals()" onkeyup="recalctotals()">
                                                        <span class="cp-opt-qty-unit">x {$configoption.options.0.name}</span>
                                                    </div>
                                                {/if}
                                            {/if}
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                    {* ── Custom fields ── *}
                    {if $customfields}
                        <div class="card cp-section">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.orderadditionalrequiredinfo}</h2>
                                <div class="cp-section-sub">{lang key='orderForm.requiredField'}</div>
                            </div>
                            <div class="cp-section-body">
                                <div class="cp-form-grid">
                                    {foreach $customfields as $customfield}
                                        <div class="cp-field">
                                            <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                                            {$customfield.input}
                                            {if $customfield.description}
                                                <span class="cp-field-help">{$customfield.description}</span>
                                            {/if}
                                        </div>
                                    {/foreach}
                                </div>
                            </div>
                        </div>
                    {/if}

                    {* ── Add-ons ── *}
                    {if $addons || count($addonsPromoOutput) > 0}
                        <div class="card cp-section" id="productAddonsContainer">
                            <div class="cp-section-head">
                                <h2 class="cp-section-title">{$LANG.cartavailableaddons}</h2>
                                <div class="cp-section-sub">{$hadrianLang.cart.addonsSub}</div>
                            </div>
                            <div class="cp-section-body">
                                {foreach $addonsPromoOutput as $output}
                                    <div>{$output}</div>
                                {/foreach}

                                {* .addon-products + .panel-addon hook scripts.js:4980's
                                   delegated 'ifChecked' so toggling an $addons checkbox
                                   triggers recalctotals() and refreshes #producttotal.
                                   The classes are appended to (not replacing) our Apple
                                   .st-addon styling -- they're invisible to CSS, used
                                   only as JS selectors. *}
                                {if $addons}
                                    <div class="addon-products">
                                        {foreach $addons as $addon}
                                            <label class="st-addon panel-addon{if $addon.status} is-selected{/if}">
                                                <div class="st-addon-head">
                                                    <div>
                                                        <div class="st-addon-title">
                                                            <input type="checkbox" name="addons[{$addon.id}]"{if $addon.status} checked{/if}>
                                                            {$addon.name}
                                                        </div>
                                                        <div class="st-addon-desc">{$addon.description}</div>
                                                    </div>
                                                    <div class="st-addon-tier-price">{$addon.pricing}</div>
                                                </div>
                                            </label>
                                        {/foreach}
                                    </div>
                                {/if}
                            </div>
                        </div>
                    {/if}

                </div>

                {* ════════════════════════════════════════════
                   RIGHT COLUMN — sticky summary card
                   ════════════════════════════════════════════ *}
                <aside class="cp-summary-wrap" id="scrollingPanelContainer">
                    <div class="card cp-summary-card" id="orderSummary">
                        {* Heading uses .cp-summary-head (NOT .cp-section-head)
                           so it picks up the 14px h2 sizing from the mockup
                           rather than the 15px global .cp-section-title. *}
                        <div class="cp-summary-head">
                            <h2>{$LANG.ordersummary}</h2>
                            <div class="loader w-hidden" id="orderSummaryLoader" aria-hidden="true">
                                <i class="fas fa-fw fa-sync fa-spin"></i>
                            </div>
                        </div>

                        {* WHMCS injects line items + subtotals + Due Today
                           into #producttotal via recalctotals(). CSS styles
                           the emitted .product-name / .clearfix / .summary-totals
                           / .total-due-today in place. *}
                        <div class="summary-container" id="producttotal"></div>

                        {* Renewal note + promo code row sit between the
                           Due Today strip and the action footer. Renewal
                           text is hardcoded here as a static reassurance
                           line (mockup-faithful); WHMCS doesn't expose a
                           ready-made 'Renews $X every year' string. *}
                        <p class="cp-summary-cycle">{$hadrianLang.cart.summaryReassurance}</p>

                        <div class="cp-promo-row">
                            <input type="text" class="cp-promo-input" id="promocode" name="promocode" placeholder="{lang key="orderPromoCodePlaceholder"}" value="{if $promocode}{$promocode|escape}{/if}">
                            <button type="button" class="cp-promo-apply" onclick="applyPromoCode();">{$LANG.orderpromovalidatebutton}</button>
                        </div>

                        <div class="cp-summary-footer">
                            <button type="submit" id="btnCompleteProductConfig" class="cp-checkout-btn">
                                {$hadrianLang.cart.reviewCart}
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                            </button>
                            {* Same URL strategy as .cp-plan-hero-change above:
                               cart.php?a=add&pid={$productinfo.pid} rewrites to the
                               plan's friendly URL (/store/<group>/<product>) which lands
                               on the configureproductdomain step for THIS specific plan. *}
                            <a href="{$WEB_ROOT}/cart.php?a=add&pid={$productinfo.pid}" class="cp-back-link">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                                {$hadrianLang.cart.backToDomain}
                            </a>
                        </div>

                        <div class="cp-guarantees">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            {$hadrianLang.cart.securedNote}
                        </div>
                    </div>
                </aside>

            </div>
        </form>
</div>{* /#order-standard_cart *}

<style>{literal}
/* Page-local layout helpers — most .cp-* classes come from hadrian's
   apple-theme.css. These bind the page's grid + a few small primitives
   not covered by the parent theme. */
.cp-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 340px;
    gap: 20px;
    align-items: start;
}
@media (max-width: 880px) {
    .cp-grid { grid-template-columns: 1fr; }
    .cp-summary-wrap { position: static !important; }
}
/* No data-subnav wiring on this page on purpose: the right-side aside is
   the order summary (content), not a Categories sidebar, so the state-
   chip's "Sub-nav: Hide" should leave it alone. Same reasoning for
   viewcart.tpl and checkout.tpl -- their right asides are also summary
   panels and stay visible regardless of the chip state. */
.cp-main > .cp-section + .cp-section { margin-top: 16px; }

.cp-form-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
}
@media (max-width: 720px) { .cp-form-grid { grid-template-columns: 1fr; } }
.cp-field { display: flex; flex-direction: column; gap: 6px; }
.cp-field > label {
    font-size: 12.5px;
    font-weight: 500;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
}
.cp-input {
    height: 40px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px;
    color: var(--color-text-primary);
    font-family: inherit;
}
.cp-input:focus {
    outline: none;
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}
.cp-field-help {
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    line-height: 1.4;
}

/* Root-password strength meter (Order Process → Enable Password Strength). */
.cp-pw-meter {
    height: 4px;
    margin-top: 8px;
    border-radius: 999px;
    background: var(--color-border);
    overflow: hidden;
    opacity: 0;
    transition: opacity var(--transition-fast);
}
.cp-pw-meter-bar {
    display: block;
    height: 100%;
    width: 0;
    border-radius: 999px;
    transition: width var(--transition-fast), background var(--transition-fast);
}
.cp-pw-label {
    margin-top: 4px;
    font-size: 11.5px;
    font-weight: 500;
}

/* Inline validation / promo banner (#cpInlineBanner) — Apple-style alert:
   variant icon + tinted card + comfortable list spacing. Colors inherit via
   currentColor so the icon + bullets + text all match the variant. */
.cp-alert {
    display: flex;
    gap: 11px;
    align-items: flex-start;
    margin: 0 0 16px;
    padding: 13px 15px;
    border: 0.5px solid;
    border-radius: var(--radius-md, 12px);
    font-size: 13px;
    line-height: 1.5;
}
.cp-alert-ico { flex: 0 0 auto; width: 18px; height: 18px; margin-top: 0.5px; }
.cp-alert-ico svg { display: block; width: 100%; height: 100%; }
.cp-alert-content { flex: 1 1 auto; min-width: 0; }
.cp-alert-title { font-weight: 600; letter-spacing: -0.01em; }
.cp-alert-body { margin-top: 3px; }
.cp-alert-body:first-child { margin-top: 0; }
.cp-alert-body p { margin: 0 0 4px; }
.cp-alert-body p:last-child { margin-bottom: 0; }
.cp-alert-body ul { margin: 4px 0 0; padding-left: 18px; list-style: disc; }
.cp-alert-body ul:first-child { margin-top: 0; }
.cp-alert-body li { margin: 3px 0; }
.cp-alert-body li::marker { color: currentColor; }
.cp-alert-body a { color: inherit; font-weight: 500; text-decoration: underline; }
.cp-alert-error   { background: var(--color-red-bg, rgba(255,59,48,0.08));   border-color: var(--color-red-border, rgba(255,59,48,0.22));   color: var(--color-red-text, #d70015); }
.cp-alert-success { background: var(--color-green-bg, rgba(52,199,89,0.10)); border-color: var(--color-green-border, rgba(52,199,89,0.30)); color: var(--color-green-text, #248a3d); }
.cp-alert-info    { background: var(--color-blue-bg, rgba(0,122,255,0.10));  border-color: var(--color-blue-border, rgba(0,122,255,0.30));  color: var(--color-blue-text, #0040dd); }

.cp-opt-radios { display: flex; gap: 10px; flex-wrap: wrap; }
.cp-opt-radio {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 12px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-pill);
    font-size: 13px;
    cursor: pointer;
    transition: all var(--transition-fast);
}
.cp-opt-radio:has(input:checked) {
    border-color: var(--color-accent);
    background: var(--color-accent-light);
    color: var(--color-accent);
}
.cp-opt-radio input { margin: 0; accent-color: var(--color-accent); }

.cp-toggle { display: inline-flex; align-items: center; cursor: pointer; }
.cp-toggle input { position: absolute; opacity: 0; pointer-events: none; }
.cp-toggle-track {
    position: relative;
    width: 40px; height: 24px;
    border-radius: 999px;
    background: var(--color-border);
    transition: background var(--transition-fast);
}
.cp-toggle-track::after {
    content: ""; position: absolute;
    top: 2px; left: 2px;
    width: 20px; height: 20px;
    background: #fff;
    border-radius: 50%;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
    transition: transform var(--transition-fast);
}
.cp-toggle input:checked + .cp-toggle-track { background: var(--color-accent); }
.cp-toggle input:checked + .cp-toggle-track::after { transform: translateX(16px); }

.cp-opt-qty-unit {
    font-size: 12px;
    color: var(--color-text-tertiary);
    margin-left: 8px;
}

.cp-summary-card { position: sticky; top: 72px; padding: 0; }
.cp-summary-footer {
    padding: 14px 22px 18px;
    border-top: 0.5px solid var(--color-border);
}
.cp-summary-footer .btn-primary { width: 100%; justify-content: center; }
{/literal}</style>

{include file="orderforms/$carttpl/recommendations-modal.tpl"}

<script>recalctotals();</script>

<script>
{literal}
/* Split each .cp-cycle-price text into currency / amount / period
   spans so the mockup typography (small / big / small) can be applied.
   WHMCS emits price as one string e.g. "$20.00 USD Monthly". We parse:
     - leading non-digit run -> currency symbol ($)
     - numeric run           -> amount (20.00)
     - optional ISO code     -> dropped (USD)
     - trailing word         -> cycle name -> mapped to /mo abbreviation */
(function () {
    var CYCLE_ABBR = {
        monthly:      '/mo',
        quarterly:    '/qtr',
        semiannually: '/6mo',
        semi:         '/6mo',
        annually:     '/yr',
        annual:       '/yr',
        biennially:   '/2yr',
        biennial:     '/2yr',
        triennially:  '/3yr',
        triennial:    '/3yr'
    };
    var nodes = document.querySelectorAll('.cp-cycle-price');
    for (var i = 0; i < nodes.length; i++) {
        var el = nodes[i];
        var raw = (el.textContent || '').trim();
        if (!raw) continue;
        // Match: [non-digits][digits.decimals] [optional ISO code] [optional cycle word]
        var m = raw.match(/^([^\d\-]*)\s*(-?\d[\d.,]*)\s*([A-Za-z]{2,4})?\s*(.*)$/);
        if (!m) continue;
        var currency = (m[1] || '').trim() || '$';
        var amount = (m[2] || '').trim();
        var rest = (m[4] || '').toLowerCase().trim();
        // If the third group is a 3-letter ISO code (USD, EUR, etc.) it's
        // already consumed; whatever is left is the cycle term.
        var key = rest.replace(/[^a-z]/g, '');
        var period = CYCLE_ABBR[key] || (rest ? '/' + rest.substr(0, 3) : '');
        el.innerHTML = '<span class="currency"></span><span class="amount"></span><span class="period"></span>';
        el.querySelector('.currency').textContent = currency;
        el.querySelector('.amount').textContent = amount;
        el.querySelector('.period').textContent = period;
    }
})();

/* Compute savings vs the monthly cycle and inject a "Save X%" pill into
   each non-monthly .cp-cycle-opt. WHMCS emits the TOTAL price for each
   cycle (e.g. annually = price for 12 months), so:
       savings = (monthly_amount * cycle_months - cycle_amount)
                 / (monthly_amount * cycle_months)
   Skips when there's no monthly baseline, when savings <= 0, or when a
   pill is already present (defensive against re-runs). */
(function () {
    var CYCLE_MONTHS = {
        monthly: 1, quarterly: 3,
        semiannually: 6, annually: 12,
        biennially: 24, triennially: 36
    };
    var labels = document.querySelectorAll('.cp-cycle-opt');
    var monthlyAmount = null;
    var rows = [];
    for (var i = 0; i < labels.length; i++) {
        var label = labels[i];
        var input = label.querySelector('input[name="billingcycle"]');
        var amountEl = label.querySelector('.cp-cycle-price .amount');
        if (!input || !amountEl) continue;
        var months = CYCLE_MONTHS[input.value];
        var amount = parseFloat((amountEl.textContent || '').replace(/[^\d.\-]/g, ''));
        if (!months || isNaN(amount)) continue;
        if (input.value === 'monthly') monthlyAmount = amount;
        rows.push({ label: label, cycle: input.value, months: months, amount: amount });
    }
    if (monthlyAmount === null) return;
    for (var j = 0; j < rows.length; j++) {
        var r = rows[j];
        if (r.cycle === 'monthly') continue;
        if (r.label.querySelector('.cp-cycle-save')) continue;
        var savings = (monthlyAmount * r.months - r.amount) / (monthlyAmount * r.months);
        if (savings < 0.005) continue;
        var badge = document.createElement('span');
        badge.className = 'cp-cycle-save';
        badge.textContent = _localLang.savePercent.replace('%s', Math.round(savings * 100)).replace('%%', '%');
        r.label.insertBefore(badge, r.label.firstChild);
    }
})();

/* ── Fix #frmConfigureProduct submit + promo Apply ──────────────────
   Two bugs in the original wiring:

   #3  Review cart never commits the configuration on this install.
       scripts.min.js's submit handler (scripts.js:2660) AJAX-posts
       and then redirects to /cart.php?a=confdomains -- the
       confdomains step destabilises the cart session and the user
       lands on an empty viewcart. A naive natural form POST also
       fails because WHMCS's confproduct controller renders the
       configure form again (no commit) when posted without the
       expected ajax flag.

       Fix: drop scripts.js's submit handler and replace with our
       own AJAX commit -- POST /cart.php?ajax=1&a=confproduct&...
       (same payload scripts.js sends), then on a clean / empty
       response redirect straight to /cart.php?a=view. On a non-
       empty response (validation HTML), inject it as an inline
       error block above the form so the user sees what's wrong.

   #2  Promo Apply on configureproduct posts the promocode to
       /cart.php?a=view + validatepromo, but the configureproduct's
       in-flight configuration changes get DROPPED (cart shows
       empty after the redirect) because we navigated away without
       committing first. Chain the two requests: AJAX-commit the
       configureproduct form, THEN POST to viewcart with the promo
       + validatepromo flag so WHMCS validates against the now-
       populated cart. */
(function () {
    function init() {
        var form = document.getElementById('frmConfigureProduct');
        if (!form) return;

        // Drop scripts.js's submit handler that redirects to confdomains.
        if (window.jQuery) window.jQuery(form).off('submit');

        // Cart-wide promo state captured from the last successful
        // validatepromo response. WHMCS's recalctotals() endpoint is
        // product-scoped and never returns the cart-level discount, so
        // once we've validated a promo we patch its discount line and
        // adjusted total directly into #producttotal -- and reapply on
        // every WHMCS-driven recalc via MutationObserver below.
        var promoState = null; // null | { description, discount, total }

        function syncPromoToSummary() {
            var pt = document.getElementById('producttotal');
            if (!pt || !promoState) return;
            var totalDue = pt.querySelector('.total-due-today');
            if (!totalDue) return;

            // Append the discount as a plain .clearfix row inside
            // .summary-totals so it inherits the existing secondary
            // styling used for Setup Fees / Monthly etc. -- no custom
            // class, no decoration; the row reads as a natural WHMCS
            // summary line. Idempotent re-entry so the MutationObserver
            // loop converges in one extra pass.
            var totalsBox = pt.querySelector('.summary-totals');
            var row = pt.querySelector('[data-promo-row="1"]');
            if (!row) {
                row = document.createElement('div');
                row.className = 'clearfix';
                row.setAttribute('data-promo-row', '1');
                var l = document.createElement('span');
                l.className = 'pull-left float-left';
                var r = document.createElement('span');
                r.className = 'pull-right float-right';
                row.appendChild(l);
                row.appendChild(r);
                if (totalsBox) totalsBox.appendChild(row);
                else totalDue.parentNode.insertBefore(row, totalDue);
            }
            var lSpan = row.querySelector('.pull-left');
            var rSpan = row.querySelector('.pull-right');
            if (lSpan && lSpan.textContent !== promoState.description) lSpan.textContent = promoState.description;
            if (rSpan && rSpan.textContent !== promoState.discount) rSpan.textContent = promoState.discount;

            // Clear the "Recalculating…" placeholder marker if present
            // so subsequent observer ticks treat the row as fully
            // populated.
            if (row.hasAttribute('data-promo-state')) row.removeAttribute('data-promo-state');
            if (row.style.opacity) row.style.opacity = '';

            var amt = totalDue.querySelector('.amt');
            if (amt && amt.textContent.trim() !== promoState.total) amt.textContent = promoState.total;
        }

        // Insert a "Recalculating promo..." placeholder in place of
        // the discount row so the user never sees stale numbers between
        // a config change and the refetch landing. The placeholder
        // re-uses the [data-promo-row] marker so the MutationObserver
        // treats it as "row present" (no re-trigger). Total Due Today
        // is left at WHMCS's freshly-recalculated, non-discounted value
        // until refetch resolves.
        function showPlaceholderRow() {
            var pt = document.getElementById('producttotal');
            if (!pt) return;
            var totalsBox = pt.querySelector('.summary-totals');
            var totalDue = pt.querySelector('.total-due-today');
            var row = pt.querySelector('[data-promo-row="1"]');
            if (!row) {
                row = document.createElement('div');
                row.className = 'clearfix';
                row.setAttribute('data-promo-row', '1');
                var l = document.createElement('span');
                l.className = 'pull-left float-left';
                var r = document.createElement('span');
                r.className = 'pull-right float-right';
                row.appendChild(l);
                row.appendChild(r);
                if (totalsBox) totalsBox.appendChild(row);
                else if (totalDue) totalDue.parentNode.insertBefore(row, totalDue);
            }
            row.setAttribute('data-promo-state', 'pending');
            row.style.opacity = '0.55';
            row.querySelector('.pull-left').textContent = _localLang.recalculatingPromo;
            row.querySelector('.pull-right').textContent = '—';
        }

        // Debounced refetch of the cart-level discount/total. When the
        // user changes billing cycle / addons / qty after a promo is
        // applied, WHMCS recalctotals() updates #producttotal with the
        // new product-scoped subtotal but never re-evaluates the
        // cart-wide discount on its own. We re-GET /cart.php?a=view
        // to pull the freshly-computed #discount, #totalDueToday and
        // promotion description, then update promoState + repatch.
        // If the new config no longer qualifies for the promo, WHMCS
        // omits #discount -- treat that as "promo dropped" and clear
        // promoState so the row disappears.
        var refetchTimeoutId = null;
        var refetchInflight = false;
        function refetchPromoTotals() {
            if (!promoState) return;
            if (refetchTimeoutId) clearTimeout(refetchTimeoutId);
            refetchTimeoutId = setTimeout(function () {
                refetchTimeoutId = null;
                if (refetchInflight) return;
                refetchInflight = true;
                fetch('/cart.php?a=view', { method: 'GET', credentials: 'same-origin' })
                    .then(function (r) { return r.text(); })
                    .then(function (html) {
                        var d = (new DOMParser()).parseFromString(html, 'text/html');
                        var disc = d.querySelector('#discount');
                        var tot = d.querySelector('#totalDueToday');
                        var lbl = d.querySelector('.ct-totals-row.discount .label');
                        if (!tot) return;
                        if (disc) {
                            promoState = {
                                description: lbl ? lbl.textContent.trim() : promoState.description,
                                discount: disc.textContent.trim(),
                                total: tot.textContent.trim()
                            };
                            syncPromoToSummary();
                        } else {
                            // Promo no longer applies to this config.
                            promoState = null;
                            var pt = document.getElementById('producttotal');
                            var row = pt && pt.querySelector('[data-promo-row="1"]');
                            if (row && row.parentNode) row.parentNode.removeChild(row);
                            showInlineError({
                                variant: 'info',
                                title: _localLang.promoCodeTitle,
                                bodyText: _localLang.promoNoLongerApplies
                            });
                        }
                    })
                    .catch(function () { /* ignore refetch errors -- placeholder remains */ })
                    .then(function () { refetchInflight = false; });
            }, 150);
        }

        // Re-apply the discount patch whenever WHMCS rewrites the
        // summary (billing-cycle change, addon toggle, qty input, etc.
        // all trigger recalctotals() which replaces the innerHTML).
        // When the row is missing AND a promo is active, show the
        // "Recalculating…" placeholder immediately so the user never
        // sees stale discount math, then debounce-refetch the fresh
        // cart-wide discount + total from viewcart.
        var producttotalEl = document.getElementById('producttotal');
        if (producttotalEl && typeof MutationObserver === 'function') {
            new MutationObserver(function () {
                if (!promoState) return;
                var pt = document.getElementById('producttotal');
                var myRow = pt && pt.querySelector('[data-promo-row="1"]');
                if (!myRow) {
                    showPlaceholderRow();
                    refetchPromoTotals();
                }
            }).observe(producttotalEl, { childList: true, subtree: true });
        }

        function buildBody(includePromo) {
            var data = new FormData(form);
            // Strip the promocode out of the configure POST -- WHMCS's
            // confproduct controller doesn't read it here, and leaving
            // it in confuses the recalc downstream.
            if (!includePromo) data.delete('promocode');
            var parts = [];
            data.forEach(function (v, k) { parts.push(encodeURIComponent(k) + '=' + encodeURIComponent(v)); });
            return parts.join('&');
        }

        // Inline banner above the form. Accepts either a plain HTML
        // string (legacy WHMCS validation markup we want to render) or
        // an options object { variant, title, bodyHtml, bodyText }.
        //   variant: 'error' (default) | 'success' | 'info'
        //   bodyText: safe textContent path (escaped on insert)
        //   bodyHtml: trusted-markup innerHTML path
        // Replaces any banner already on the page so a second promo
        // attempt doesn't stack.
        function showInlineError(arg) {
            var opts = (typeof arg === 'string') ? { bodyHtml: arg } : (arg || {});
            var variant = opts.variant || 'error';
            // Variant icon (Apple-style): triangle / check-circle / info-circle.
            // Stroke inherits the alert's currentColor via CSS.
            var icons = {
                error:   '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
                success: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>',
                info:    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
            };
            if (!icons[variant]) variant = 'error';
            var existing = document.getElementById('cpInlineBanner');
            if (existing) existing.parentNode.removeChild(existing);

            var box = document.createElement('div');
            box.id = 'cpInlineBanner';
            box.className = 'cp-alert cp-alert-' + variant;
            box.setAttribute('role', 'alert');

            var ico = document.createElement('span');
            ico.className = 'cp-alert-ico';
            ico.setAttribute('aria-hidden', 'true');
            ico.innerHTML = icons[variant];
            box.appendChild(ico);

            var content = document.createElement('div');
            content.className = 'cp-alert-content';

            var defaultTitle = (variant === 'error') ? _localLang.correctErrors : '';
            var titleText = (typeof opts.title === 'string') ? opts.title : defaultTitle;
            if (titleText) {
                var title = document.createElement('div');
                title.className = 'cp-alert-title';
                title.textContent = titleText;
                content.appendChild(title);
            }
            var body = document.createElement('div');
            body.className = 'cp-alert-body';
            if (typeof opts.bodyText === 'string') body.textContent = opts.bodyText;
            else if (typeof opts.bodyHtml === 'string') body.innerHTML = opts.bodyHtml;
            content.appendChild(body);

            box.appendChild(content);
            form.parentNode.insertBefore(box, form);
            box.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }

        function commitConfig() {
            // Returns a Promise. Resolves with `true` on success
            // (empty WHMCS response), rejects with the error HTML
            // on validation failure.
            return new Promise(function (resolve, reject) {
                var xhr = new XMLHttpRequest();
                xhr.open('POST', '/cart.php?ajax=1&a=confproduct', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.setRequestHeader('Accept', 'text/html, */*');
                xhr.onload = function () {
                    var data = (xhr.responseText || '').trim();
                    if (!data) resolve(true);
                    else reject(data);
                };
                xhr.onerror = function () { reject(_localLang.networkError); };
                xhr.send(buildBody(false));
            });
        }

        // Review cart: commit config -> redirect to viewcart.
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            var btn = document.getElementById('btnCompleteProductConfig');
            if (btn) btn.disabled = true;
            commitConfig().then(function () {
                window.location = '/cart.php?a=view';
            }).catch(function (errHtml) {
                if (btn) btn.disabled = false;
                showInlineError(errHtml);
            });
        });

        // Promo Apply: commit config, then AJAX-validate the promo
        // against viewcart and update the page in-place for both
        // outcomes -- the user never leaves the configure step.
        //  - Invalid code: surface $promoerrormessage as an inline
        //    error banner; the cart session still holds the committed
        //    config so the user can correct the code and retry.
        //  - Valid code: surface promotionAccepted as a success banner
        //    and call recalctotals(), which re-fetches #producttotal.
        //    WHMCS keeps the applied promotion in the session, so the
        //    refreshed summary already includes the discount line.
        var applyBtn = document.querySelector('.cp-promo-apply');
        var promoInput = document.getElementById('promocode');
        if (applyBtn && promoInput) {
            applyBtn.removeAttribute('onclick');
            applyBtn.addEventListener('click', function () {
                var code = (promoInput.value || '').trim();
                if (!code) { promoInput.focus(); return; }
                applyBtn.disabled = true;

                commitConfig().then(function () {
                    return fetch('/cart.php?a=view', {
                        method: 'POST',
                        credentials: 'same-origin',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'promocode=' + encodeURIComponent(code) + '&validatepromo=1'
                    });
                }).then(function (res) {
                    return res.text();
                }).then(function (html) {
                    // hadrian viewcart renders four mutually-exclusive
                    // promo banners (viewcart.tpl lines 601-611):
                    //   .vc-alert.warn  -> $promoerrormessage  (invalid code)
                    //   .vc-alert.ok    -> promotionAccepted   (valid w/ discount)
                    //   .vc-alert.info  -> promoappliedbutnodiscount
                    //   .vc-alert.error -> generic $errormessage (config-level)
                    // Bundlewarnings reuse .vc-alert.warn but always
                    // include <strong> + <ul>, so filter compound
                    // alerts to isolate the promo banner. Fall back to
                    // standard_cart's .alert-* classes in case the
                    // deployed template is ever swapped.
                    var doc = (new DOMParser()).parseFromString(html, 'text/html');
                    var alerts = doc.querySelectorAll(
                        '.vc-alert[role="alert"], ' +
                        '.alert-warning[role="alert"], ' +
                        '.alert-success[role="alert"], ' +
                        '.alert-info[role="alert"]'
                    );
                    var promoErr = null, promoOk = null, promoInfo = null;
                    for (var i = 0; i < alerts.length; i++) {
                        var a = alerts[i];
                        if (a.querySelector('strong, ul, li')) continue;
                        var cl = a.classList;
                        if (!promoErr && (cl.contains('warn') || cl.contains('alert-warning'))) promoErr = a;
                        else if (!promoOk && (cl.contains('ok') || cl.contains('alert-success'))) promoOk = a;
                        else if (!promoInfo && (cl.contains('info') || cl.contains('alert-info'))) promoInfo = a;
                    }

                    applyBtn.disabled = false;

                    if (promoErr) {
                        showInlineError({
                            variant: 'error',
                            title: _localLang.promoCodeTitle,
                            bodyText: promoErr.textContent.trim()
                        });
                        promoInput.focus();
                        promoInput.select();
                        return;
                    }

                    // Accepted: pull the cart-level discount line and
                    // adjusted total from the response and patch them
                    // into #producttotal (see syncPromoToSummary above).
                    // recalctotals() returns a *product-scoped* summary
                    // and never includes the cart-wide discount, so
                    // calling it here would actually clobber the patch
                    // -- we rely on the MutationObserver to reapply.
                    var discountEl = doc.querySelector('#discount');
                    var totalEl = doc.querySelector('#totalDueToday');
                    var promoLabelEl = doc.querySelector('.ct-totals-row.discount .label');
                    var newDiscount = discountEl ? discountEl.textContent.trim() : '';
                    var newTotal = totalEl ? totalEl.textContent.trim() : '';
                    var newDesc = promoLabelEl ? promoLabelEl.textContent.trim() : _localLang.promoApplied.replace('%s', code);

                    if (newTotal) {
                        promoState = {
                            description: newDesc,
                            discount: newDiscount || 'Applied',
                            total: newTotal
                        };
                        syncPromoToSummary();
                    }

                    var variant = promoOk ? 'success' : (promoInfo ? 'info' : 'success');
                    var baseMsg = promoOk ? promoOk.textContent.trim()
                                 : promoInfo ? promoInfo.textContent.trim()
                                 : _localLang.promoApplied.replace('%s', code);
                    showInlineError({
                        variant: variant,
                        title: _localLang.promoCodeTitle,
                        bodyText: baseMsg
                    });
                }).catch(function (err) {
                    applyBtn.disabled = false;
                    if (typeof err === 'string') {
                        showInlineError(err);
                    } else {
                        showInlineError({
                            title: _localLang.promoCodeTitle,
                            bodyText: _localLang.networkError
                        });
                    }
                });
            });
        }
    }
    if (window.jQuery) {
        window.jQuery(init);
    } else if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
{/literal}
</script>
