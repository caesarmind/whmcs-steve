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

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/upgrade.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.clientareaservices|default:'Services'}</p>
    <h1>{$LANG.upgradedowngrade|default:'Upgrade or downgrade'}</h1>
    <p class="page-subtitle">{$LANG.upgradeintro|default:'Change your plan size or feature tier. Changes are prorated.'}</p>
</header>

{if $upFull}
<div class="when-full">

    {if isset($groupname) || isset($productname)}
    <div class="up-callout">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        <div>{$LANG.upgradecurrentconfig|default:'Current plan'}: <strong>{$groupname|default:''|escape}{if isset($productname)} - {$productname|escape}{/if}</strong>{if isset($domain) && $domain} ({$domain|escape}){/if}</div>
    </div>
    {/if}

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
                            <div class="up-cfg-col-label">{$LANG.upgradecurrentconfig|default:'Current'}</div>
                            {if $cfg.optiontype == 1 || $cfg.optiontype == 2}
                                <input class="form-input" type="text" value="{$cfg.selectedname|default:''|escape}" disabled>
                            {elseif $cfg.optiontype == 3}
                                <input class="form-input" type="text" value="{if $cfg.selectedqty}{$LANG.yes|default:'Enabled'}{else}{$LANG.no|default:'Disabled'}{/if}" disabled>
                            {elseif $cfg.optiontype == 4}
                                <input class="form-input" type="text" value="{$cfg.selectedqty|default:0|escape}" disabled>
                            {/if}
                        </div>
                        <div>
                            <div class="up-cfg-col-label">{$LANG.upgradenewconfig|default:'New'}</div>
                            {if $cfg.optiontype == 1 || $cfg.optiontype == 2}
                                <select name="configoption[{$cfg.id}]" class="form-select">
                                    {foreach $cfg.options as $opt}
                                        <option value="{$opt.id}"{if !empty($opt.selected)} selected{/if}>{$opt.nameonly|default:$opt.name|escape}{if isset($opt.price) && $opt.price} - {$opt.price}{/if}</option>
                                    {/foreach}
                                </select>
                            {elseif $cfg.optiontype == 3}
                                <label style="display:flex;align-items:center;gap:10px;padding:8px 0;cursor:pointer;"><input type="checkbox" name="configoption[{$cfg.id}]" value="1"{if $cfg.selectedqty} checked{/if}> <span>{$LANG.enable|default:'Enable this option'}</span></label>
                            {elseif $cfg.optiontype == 4}
                                <input class="form-input" type="number" name="configoption[{$cfg.id}]" value="{$cfg.selectedqty|default:0|escape}" min="{$cfg.qtyminimum|default:0|escape}"{if isset($cfg.qtymaximum) && $cfg.qtymaximum > 0} max="{$cfg.qtymaximum|escape}"{/if}>
                            {/if}
                        </div>
                    </div>
                </div>
            {/foreach}
            </div>
            <div class="page-actions">
                <button type="submit" class="btn-primary">{$LANG.ordercontinuebutton|default:'Continue'}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$id|default:''|escape}" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
            </div>
        </form>

    {else}
        {* ---- Package selection ---- *}
        <div class="up-pkgs">
        {foreach $upgradepackages as $pkg}
            {assign var=isCurrent value=false}
            {if isset($productname) && $pkg.name == $productname}{assign var=isCurrent value=true}{/if}
            <form class="up-pkg{if $isCurrent} current{/if}" method="post" action="{$WEB_ROOT}/upgrade.php">
                <input type="hidden" name="step" value="2">
                <input type="hidden" name="type" value="package">
                <input type="hidden" name="id" value="{$id|default:''|escape}">
                <input type="hidden" name="pid" value="{$pkg.pid|escape}">
                <div class="up-pkg-head">
                    <span class="up-pkg-name">{$pkg.name|escape}</span>
                    {if $isCurrent}<span class="plan-badge">{$LANG.upgradecurrentconfig|default:'Current'}</span>{/if}
                </div>
                {if $pkg.pricing.type == 'free'}
                    <input type="hidden" name="billingcycle" value="free">
                    <div class="up-pkg-price"><span class="amt">{$LANG.orderfree|default:'Free'}</span></div>
                {elseif $pkg.pricing.type == 'onetime'}
                    <input type="hidden" name="billingcycle" value="onetime">
                    <div class="up-pkg-price"><span class="amt">{$pkg.pricing.onetime}</span> <span style="font-size:13px;color:var(--color-text-secondary);">{$LANG.orderpaymenttermonetime|default:'one time'}</span></div>
                {else}
                    <select name="billingcycle" class="form-select up-pkg-cycle">
                        {if $pkg.pricing.monthly}<option value="monthly">{$pkg.pricing.monthly} / {$LANG.monthly|default:'mo'}</option>{/if}
                        {if $pkg.pricing.quarterly}<option value="quarterly">{$pkg.pricing.quarterly} / {$LANG.quarterly|default:'qtr'}</option>{/if}
                        {if $pkg.pricing.semiannually}<option value="semiannually">{$pkg.pricing.semiannually} / {$LANG.semiannually|default:'6 mo'}</option>{/if}
                        {if $pkg.pricing.annually}<option value="annually">{$pkg.pricing.annually} / {$LANG.annually|default:'yr'}</option>{/if}
                        {if $pkg.pricing.biennially}<option value="biennially">{$pkg.pricing.biennially} / {$LANG.biennially|default:'2 yr'}</option>{/if}
                        {if $pkg.pricing.triennially}<option value="triennially">{$pkg.pricing.triennially} / {$LANG.triennially|default:'3 yr'}</option>{/if}
                    </select>
                {/if}
                <div class="up-pkg-features">{if isset($pkg.description) && $pkg.description}{$pkg.description}{/if}</div>
                {if $isCurrent}
                    <button type="button" class="btn-secondary" disabled style="opacity:0.5;">{$LANG.upgradecurrentplan|default:'Current plan'}</button>
                {else}
                    <button type="submit" class="btn-primary">{$LANG.upgradedowngradechooseproduct|default:'Choose this plan'}</button>
                {/if}
            </form>
        {/foreach}
        </div>
    {/if}

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
                <p class="up-empty-title">{$LANG.upgradenotavailabletitle|default:'Upgrade not available'}</p>
                <p class="up-empty-sub">{$LANG.upgradeerroroverdueinvoice|default:'You have an overdue invoice. Please settle it before upgrading.'}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.invoices|default:'My invoices'}</a>
            {elseif isset($existingupgradeinvoice) && $existingupgradeinvoice}
                <p class="up-empty-title">{$LANG.upgradenotavailabletitle|default:'Upgrade not available'}</p>
                <p class="up-empty-sub">{$LANG.upgradeexistingupgradeinvoice|default:'There is already a pending upgrade invoice for this service.'}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.invoices|default:'My invoices'}</a>
            {else}
                <p class="up-empty-title">{$LANG.upgradenotavailabletitle|default:'No upgrade available'}</p>
                <p class="up-empty-sub">{$LANG.upgradeNotPossible|default:"This service doesn't have higher tiers, or upgrades are paused."}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'All services'}</a>
            {/if}
        </div>
    </div>
</div>
{/if}
