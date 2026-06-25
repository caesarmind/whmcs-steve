{* Hostnodes - Upgrade / downgrade (Apple-style). Real WHMCS upgrade templatefile.

   WHMCS variables (cross-checked against Lagom upgrade.tpl):
     $type            - 'package' | 'configoptions'
     $id              - service id     $groupname, $productname, $domain
     $overdueinvoice / $existingupgradeinvoice / $upgradenotavailable - block states
     type=package:     $upgradepackages - each: pid, groupname, name, description,
                        pricing{ type:'free'|'onetime'|'recurring', onetime, monthly,
                        quarterly, semiannually, annually, biennially, triennially }
     type=configoptions: $configoptions - each: id, optionname, optiontype(1..4),
                        selectedname, selectedqty, qtyminimum, qtymaximum,
                        options[]{ id, name, nameonly, price, selected }
   Form posts step=2, type, id, pid, billingcycle (package) / configoption[id] (configoptions).
   Demo package cards under ?preview=1.
*}

{assign var=upType value=$type|default:'package'}

{assign var=upBlocked value=false}
{if (isset($overdueinvoice) && $overdueinvoice) || (isset($existingupgradeinvoice) && $existingupgradeinvoice) || (isset($upgradenotavailable) && $upgradenotavailable)}{assign var=upBlocked value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasPkgs value=false}
{if isset($upgradepackages) && $upgradepackages|@count > 0}{assign var=hasPkgs value=true}{/if}
{assign var=hasCfg value=false}
{if isset($configoptions) && $configoptions|@count > 0}{assign var=hasCfg value=true}{/if}

{assign var=upDemo value=false}
{if !$upBlocked && !$hasPkgs && !$hasCfg && $isPreview}
    {assign var=upDemo value=true}
    {assign var=upType value='package'}
    {assign var=groupname value='Cloud Hosting'}
    {assign var=productname value='Pro'}
    {assign var=upgradepackages value=[
        ['pid'=>1,'groupname'=>'Cloud Hosting','name'=>'Starter','pricing'=>['type'=>'recurring','monthly'=>'$10.17','annually'=>'$102.00'],'description'=>'20 GB SSD<br>500 GB bandwidth<br>1 website<br>Free SSL'],
        ['pid'=>2,'groupname'=>'Cloud Hosting','name'=>'Business','pricing'=>['type'=>'recurring','monthly'=>'$49.00','annually'=>'$490.00'],'description'=>'500 GB SSD<br>Unmetered bandwidth<br>Dedicated IP + firewall<br>Hourly backups<br>99.99% SLA']
    ]}
    {assign var=hasPkgs value=true}
{/if}

{assign var=upFull value=false}
{if !$upBlocked && ($hasPkgs || $hasCfg)}{assign var=upFull value=true}{/if}
{if $upFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/upgrade.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
    {* No hardcoded data-subnav: the section sidebar (.up-split > aside) now follows
       the global "Website Section Sidebar" admin toggle (body[data-subnav-website]),
       same as the list/management pages. *}
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.clientareaservices|default:'Services'}</p>
    <h1>{$LANG.upgradedowngrade|default:'Upgrade or downgrade'}</h1>
    <p class="page-subtitle">{$hadrianLang.services.upgradeIntro}</p>
</header>

{if $upFull}
<div class="when-full">

    {if isset($groupname) || isset($productname)}
    <div class="up-callout">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <div>{$LANG.upgradecurrentconfig}: <strong>{$groupname|default:''|escape}{if isset($productname)} - {$productname|escape}{/if}</strong>{if isset($domain) && $domain} ({$domain|escape}){/if}</div>
    </div>
    {/if}

    {* Section split: main flow on the left, Services sub-nav aside on the right.
       The wrapper is a *-split, so the global website-sidebar toggle hides the aside
       + collapses to one column when the admin turns the section sidebar off. *}
    <div class="up-split">
    <div class="up-main">

    {if $upType == 'configoptions'}
        {* ---- Configurable options diff ---- *}
        <form method="post" action="{$WEB_ROOT}/upgrade.php">
            <input type="hidden" name="step" value="2">
            <input type="hidden" name="type" value="configoptions">
            <input type="hidden" name="id" value="{$id|default:''|escape}">
            {if isset($errormessage) && $errormessage}
            <div class="up-callout warn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg><div>{$errormessage|strip_tags}</div></div>
            {/if}
            <div class="up-cfg">
            {foreach $configoptions as $cfg}
                <div class="card up-cfg-row">
                    <div class="up-cfg-name">{$cfg.optionname|escape}</div>
                    <div class="up-cfg-cols">
                        <div>
                            <div class="up-cfg-col-label">{$LANG.upgradecurrentconfig}</div>
                            {if $cfg.optiontype == 1 || $cfg.optiontype == 2}
                                <input class="form-input" type="text" value="{$cfg.selectedname|default:''|escape}" disabled>
                            {elseif $cfg.optiontype == 3}
                                <input class="form-input" type="text" value="{if $cfg.selectedqty}{$hadrianLang.services.enabledState}{else}{$hadrianLang.services.disabledState}{/if}" disabled>
                            {elseif $cfg.optiontype == 4}
                                <input class="form-input" type="text" value="{$cfg.selectedqty|default:0|escape}" disabled>
                            {/if}
                        </div>
                        <div>
                            <div class="up-cfg-col-label">{$LANG.upgradenewconfig}</div>
                            {if $cfg.optiontype == 1 || $cfg.optiontype == 2}
                                <select name="configoption[{$cfg.id}]" class="form-select">
                                    {foreach $cfg.options as $opt}
                                        <option value="{$opt.id}"{if !empty($opt.selected)} selected{/if}>{$opt.nameonly|default:$opt.name|escape}{if isset($opt.price) && $opt.price} - {$opt.price}{/if}</option>
                                    {/foreach}
                                </select>
                            {elseif $cfg.optiontype == 3}
                                <label style="display:flex;align-items:center;gap:10px;padding:8px 0;cursor:pointer;"><input type="checkbox" name="configoption[{$cfg.id}]" value="1"{if $cfg.selectedqty} checked{/if}> <span>{$LANG.enable}</span></label>
                            {elseif $cfg.optiontype == 4}
                                <input class="form-input" type="number" name="configoption[{$cfg.id}]" value="{$cfg.selectedqty|default:0|escape}" min="{$cfg.qtyminimum|default:0|escape}"{if isset($cfg.qtymaximum) && $cfg.qtymaximum > 0} max="{$cfg.qtymaximum|escape}"{/if}>
                            {/if}
                        </div>
                    </div>
                </div>
            {/foreach}
            </div>
            <div class="page-actions">
                <button type="submit" class="btn-primary">{$LANG.ordercontinuebutton}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$id|default:''|escape}" class="btn-secondary">{$LANG.cancel}</a>
            </div>
        </form>

    {else}
        {* ---- Package selection — same card design as the hadrian_cart store
             grid (.st-pricing / .st-plan). The .st-* CSS lives in upgrade.css
             (hadrian_cart's stylesheet isn't loaded on client-area pages). Each
             card stays the upgrade POST form; the billing-cycle picker, current-
             plan state, and free/onetime/recurring variants are preserved. ---- *}
        <div class="st-pricing up-st-pricing" data-count="{$upgradepackages|@count}">
        {foreach $upgradepackages as $pkg}
            {assign var=isCurrent value=false}
            {if isset($productname) && $pkg.name == $productname}{assign var=isCurrent value=true}{/if}
            <form class="st-plan up-st-plan{if $isCurrent} current{/if}" method="post" action="{$WEB_ROOT}/upgrade.php">
                <input type="hidden" name="step" value="2">
                <input type="hidden" name="type" value="package">
                <input type="hidden" name="id" value="{$id|default:''|escape}">
                <input type="hidden" name="pid" value="{$pkg.pid|escape}">
                {if $isCurrent}<span class="st-plan-badge up-st-badge-current">{$LANG.upgradecurrentconfig}</span>{/if}
                <h3 class="st-plan-name">{$pkg.name|escape}</h3>
                <p class="st-plan-tag">{if isset($pkg.groupname) && $pkg.groupname}{$pkg.groupname|escape}{else}&nbsp;{/if}</p>

                {if $pkg.pricing.type == 'free'}
                    <input type="hidden" name="billingcycle" value="free">
                    <div class="st-plan-price"><span class="amount">{$LANG.orderfree}</span></div>
                {elseif $pkg.pricing.type == 'onetime'}
                    <input type="hidden" name="billingcycle" value="onetime">
                    <div class="st-plan-price"><span class="amount">{$pkg.pricing.onetime}</span> <span class="period">{$LANG.orderpaymenttermonetime}</span></div>
                {else}
                    {* Recurring: the billing-cycle <select> IS the price control — each
                       option already shows its per-term price (e.g. "$50.00 USD Monthly
                       / mo"), so there's no separate price headline above it (that line
                       just duplicated the amount + cycle). *}
                    <select name="billingcycle" class="form-select st-plan-cycle">
                        {if $pkg.pricing.monthly}<option value="monthly">{$pkg.pricing.monthly} / {$hadrianLang.services.cycleMonthlyShort}</option>{/if}
                        {if $pkg.pricing.quarterly}<option value="quarterly">{$pkg.pricing.quarterly} / {$hadrianLang.services.cycleQuarterlyShort}</option>{/if}
                        {if $pkg.pricing.semiannually}<option value="semiannually">{$pkg.pricing.semiannually} / {$hadrianLang.services.cycleSemiannuallyShort}</option>{/if}
                        {if $pkg.pricing.annually}<option value="annually">{$pkg.pricing.annually} / {$hadrianLang.services.cycleAnnuallyShort}</option>{/if}
                        {if $pkg.pricing.biennially}<option value="biennially">{$pkg.pricing.biennially} / {$hadrianLang.services.cycleBienniallyShort}</option>{/if}
                        {if $pkg.pricing.triennially}<option value="triennially">{$pkg.pricing.triennially} / {$hadrianLang.services.cycleTrienniallyShort}</option>{/if}
                    </select>
                {/if}

                {* Admin writes <ul><li>..</li></ul> in the WHMCS product description;
                   strip WHMCS's auto-nl2br <br> so the list renders clean (same as
                   the store's products.tpl). *}
                <div class="st-plan-features">{if isset($pkg.description) && $pkg.description}{$pkg.description|regex_replace:'/<br\s*\/?>/i':''}{/if}</div>

                {if $isCurrent}
                    <button type="button" class="st-plan-cta secondary" disabled>{$LANG.upgradecurrentplan|default:'Current plan'}</button>
                {else}
                    <button type="submit" class="st-plan-cta">{$LANG.upgradedowngradechooseproduct}</button>
                {/if}
            </form>
        {/foreach}
        </div>

        {* Back out of the upgrade flow — to the service being upgraded, else the
           services list. (The configoptions branch above has its own Cancel.) *}
        <div class="up-back">
            <a href="{if isset($id) && $id}{$WEB_ROOT}/clientarea.php?action=productdetails&id={$id|escape}{else}{$WEB_ROOT}/clientarea.php?action=services{/if}" class="up-back-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {if isset($id) && $id}{$hadrianLang.services.backToMyService}{else}{$hadrianLang.services.backToServices}{/if}
            </a>
        </div>
    {/if}

    </div>{* /.up-main *}

    {* Services section sub-nav — mirrors the services-list aside. Hidden + the split
       collapses to one column when the admin disables the website section sidebar
       (body[data-subnav-website="off"] [class$="-split"] in apple-layout.css). *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.services|default:'Services'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg>
                {$LANG.myservices|default:'My Services'}
            </a>
            <a href="{$WEB_ROOT}/cart.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg>
                {$LANG.ordernewservices|default:'Order New Services'}
            </a>
            <a href="{$WEB_ROOT}/cart.php?gid=addons" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.viewavailableaddons|default:'View Available Addons'}
            </a>
            <a href="{$WEB_ROOT}/upgrade.php{if isset($id) && $id}?type=package&id={$id|escape}{/if}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 11 12 6 7 11"/><polyline points="17 18 12 13 7 18"/></svg>
                {$LANG.upgrade}
            </a>
        </div>
    </aside>
    </div>{* /.up-split *}

</div>
{/if}

{if !$upFull}
<div class="when-empty">
    <div class="card">
        <div class="up-empty">
            <div class="up-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="16 12 12 8 8 12"/><line x1="12" y1="16" x2="12" y2="8"/></svg>
            </div>
            {if isset($overdueinvoice) && $overdueinvoice}
                <p class="up-empty-title">{$hadrianLang.services.upgradeNotAvailTitle}</p>
                <p class="up-empty-sub">{$LANG.upgradeerroroverdueinvoice}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.invoices|default:'My invoices'}</a>
            {elseif isset($existingupgradeinvoice) && $existingupgradeinvoice}
                <p class="up-empty-title">{$hadrianLang.services.upgradeNotAvailTitle}</p>
                <p class="up-empty-sub">{$LANG.upgradeexistingupgradeinvoice}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.invoices|default:'My invoices'}</a>
            {else}
                <p class="up-empty-title">{$hadrianLang.services.noUpgradeTitle}</p>
                <p class="up-empty-sub">{$LANG.upgradeNotPossible}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
            {/if}
        </div>
    </div>
</div>
{/if}
