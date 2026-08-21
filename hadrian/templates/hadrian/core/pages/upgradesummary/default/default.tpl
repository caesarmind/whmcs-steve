{* Hostnodes - Upgrade summary (Apple-style). Real WHMCS upgrade confirm step.

   WHMCS variables (cross-checked against Lagom upgradesummary.tpl):
     $type        - 'package' | 'configoptions'        $id - service id
     $upgrades    - each (package): oldproductname, newproductname, newproductid,
                    newproductbillingcycle, price, daysuntilrenewal
                    each (configoptions): configname, originalvalue, newvalue, price
     $configoptions - cid => value (hidden carry-over)
     $subtotal, $taxname/$taxrate/$taxtotal, $taxname2/$taxrate2/$taxtotal2, $total
     $promocode, $promodesc, $discount
     $gateways (sysname,name), $selectedgateway, $allowgatewayselection
   Promo form posts step=2; checkout posts step=3.
   Demo data under ?preview=1.
*}

{assign var=upType value=$type|default:'package'}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasUpgrades value=false}
{if isset($upgrades) && $upgrades|@count > 0}{assign var=hasUpgrades value=true}{/if}

{assign var=upDemo value=false}
{if !$hasUpgrades && $isPreview}
    {assign var=upDemo value=true}
    {assign var=upgrades value=[['oldproductname'=>'Cloud Hosting - Pro','newproductname'=>'Cloud Hosting - Business','newproductid'=>2,'newproductbillingcycle'=>'monthly','price'=>'$29.08','daysuntilrenewal'=>18]]}
    {assign var=subtotal value='$29.08'}
    {assign var=total value='$29.08'}
    {assign var=gateways value=[['sysname'=>'stripe','name'=>'Credit card'],['sysname'=>'paypal','name'=>'PayPal']]}
    {assign var=hasUpgrades value=true}
{/if}

{if $hasUpgrades}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/upgradesummary.css?v={$hadrian.version|default:'1.0'}">

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
    <h1>{$LANG.ordersummary}</h1>
    <p class="page-subtitle">{$hadrianLang.services.upgradeSummaryIntro}</p>
</header>

{if $hasUpgrades}
<div class="when-full">
<div class="up-grid">

    {* ==== MAIN ==== *}
    <div class="up-main">
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.orderdesc}</h2></div>
            <div class="card-body">
                {foreach $upgrades as $upg}
                <div class="up-line">
                    <span class="up-line-desc">
                        {if $upType == 'configoptions'}{$upg.configname|default:''|escape}: {$upg.originalvalue|default:''|escape} &rarr; {$upg.newvalue|default:''|escape}
                        {else}{$upg.oldproductname|default:''|escape} &rarr; {$upg.newproductname|default:''|escape}{/if}
                    </span>
                    <span class="up-line-price">{include file="`$template`/includes/common/price.tpl" hPrice=$upg.price|default:'' hEscape=false}</span>
                </div>
                {/foreach}
                {if $upType == 'package' && isset($upgrades.0.daysuntilrenewal)}
                <p style="margin: 14px 0 0; font-size: 12.5px; color: var(--color-text-tertiary); line-height: 1.5;">
                    {$LANG.upgradeproductlogic} ({$upgrades.0.daysuntilrenewal|escape} {$LANG.days}).
                </p>
                {/if}
            </div>
        </div>

        {* Promo code *}
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.orderpromotioncode}</h2></div>
            <div class="card-body">
                <form method="post" action="{$WEB_ROOT}/upgrade.php" class="up-promo">
                    <input type="hidden" name="step" value="2">
                    <input type="hidden" name="type" value="{$upType|escape}">
                    <input type="hidden" name="id" value="{$id|default:''|escape}">
                    {if $upType == 'package' && isset($upgrades.0.newproductid)}
                        <input type="hidden" name="pid" value="{$upgrades.0.newproductid|escape}">
                        <input type="hidden" name="billingcycle" value="{$upgrades.0.newproductbillingcycle|default:''|escape}">
                    {/if}
                    {if isset($configoptions)}{foreach $configoptions as $cid => $cval}<input type="hidden" name="configoption[{$cid}]" value="{$cval|escape}">{/foreach}{/if}
                    <input class="form-input" type="text" name="promocode" placeholder="{$LANG.orderpromotioncode}"{if isset($promocode) && $promocode} value="{$promocode|escape}" disabled{/if}>
                    {if isset($promocode) && $promocode}
                        <button type="submit" name="removepromo" value="1" class="btn-secondary">{$LANG.orderdontusepromo}</button>
                    {else}
                        <button type="submit" class="btn-secondary">{$LANG.orderpromovalidatebutton}</button>
                    {/if}
                </form>
            </div>
        </div>

        {* Payment + checkout *}
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.orderpaymentmethod}</h2></div>
            <div class="card-body">
                <form method="post" action="{$WEB_ROOT}/upgrade.php">
                    <input type="hidden" name="step" value="3">
                    <input type="hidden" name="type" value="{$upType|escape}">
                    <input type="hidden" name="id" value="{$id|default:''|escape}">
                    {if $upType == 'package' && isset($upgrades.0.newproductid)}
                        <input type="hidden" name="pid" value="{$upgrades.0.newproductid|escape}">
                        <input type="hidden" name="billingcycle" value="{$upgrades.0.newproductbillingcycle|default:''|escape}">
                    {/if}
                    {if isset($configoptions)}{foreach $configoptions as $cid => $cval}<input type="hidden" name="configoption[{$cid}]" value="{$cval|escape}">{/foreach}{/if}
                    {if isset($promocode) && $promocode}<input type="hidden" name="promocode" value="{$promocode|escape}">{/if}
                    {if isset($gateways) && $gateways|@count > 0}
                    <div class="form-group">
                        <label class="form-label" for="inputPaymentMethod">{$LANG.orderpaymentmethod}</label>
                        <select name="paymentmethod" id="inputPaymentMethod" class="form-select">
                            {if isset($allowgatewayselection) && $allowgatewayselection}<option value="none">{$LANG.paymentmethoddefault}</option>{/if}
                            {foreach $gateways as $gateway}
                                <option value="{$gateway.sysname|escape}"{if isset($selectedgateway) && $gateway.sysname == $selectedgateway} selected{/if}>{$gateway.name|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                    {/if}
                    <div class="page-actions" style="margin-top: 8px;">
                        <button type="submit" class="btn-primary">{$LANG.orderForm.checkout}</button>
                        <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$id|default:''|escape}" class="btn-secondary">{$LANG.cancel}</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    {* ==== ASIDE: order summary ==== *}
    <aside class="up-aside">
        <div class="card">
            <div class="card-header"><h2 class="card-title">{$LANG.ordersummary}</h2></div>
            <div class="card-body">
                <div class="summary-row"><span>{$LANG.ordersubtotal}</span><span>{$subtotal|default:''}</span></div>
                {if isset($taxrate) && $taxrate}<div class="summary-row"><span>{$taxname|default:''|escape} @ {$taxrate|escape}%</span><span>{$taxtotal|default:''}</span></div>{/if}
                {if isset($taxrate2) && $taxrate2}<div class="summary-row"><span>{$taxname2|default:''|escape} @ {$taxrate2|escape}%</span><span>{$taxtotal2|default:''}</span></div>{/if}
                {if isset($promocode) && $promocode}<div class="summary-row"><span>{$promodesc|default:$hadrianLang.services.promoFallback|escape}</span><span class="summary-credit">{$discount|default:''}</span></div>{/if}
                <div class="summary-row total"><span>{$LANG.ordertotalduetoday}</span><span>{$total|default:''}</span></div>
            </div>
        </div>
    </aside>
</div>
</div>
{/if}

{if !$hasUpgrades}
<div class="when-empty">
    <div class="card">
        <div class="up-empty">
            <div class="up-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="16 12 12 8 8 12"/><line x1="12" y1="16" x2="12" y2="8"/></svg>
            </div>
            <p class="up-empty-title">{$hadrianLang.services.upgradeNoSummaryTitle}</p>
            <p class="up-empty-sub">{$hadrianLang.services.upgradeNoSummarySub}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        </div>
    </div>
</div>
{/if}
