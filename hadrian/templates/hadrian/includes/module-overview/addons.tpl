{* "Addons & Extras" purchase card + the Sitejet upsell, from the cPanel /
   Plesk / WP Squared overviews. $availableAddonProducts are product addons
   the client can still buy for this service (posted to cart.php?a=add with
   serviceid). The Sitejet cards offer the Sitejet addon or a package upgrade
   that includes it, only when Sitejet is not active yet. All prices come from
   WHMCS (pricing()->best()). *}
{assign var=hnSjAddons value=0}
{if isset($availableSitejetAddons) && $availableSitejetAddons}{assign var=hnSjAddons value=$availableSitejetAddons->count()}{/if}
{assign var=hnSjUpgrades value=0}
{if isset($availableSitejetProductUpgrades) && $availableSitejetProductUpgrades}{assign var=hnSjUpgrades value=$availableSitejetProductUpgrades->count()}{/if}

{if !empty($availableAddonProducts)}
<div class="card" id="{$panelId|default:'cPanelExtrasPurchasePanel'}">
    <div class="card-header"><h2 class="card-title">{lang key='addonsExtras'}</h2></div>
    <div class="card-body">
        <form method="post" action="{$WEB_ROOT}/cart.php?a=add" class="hn-mo-row">
            <input type="hidden" name="serviceid" value="{$serviceid}" />
            <select name="aid" class="pd-field-input" aria-label="{lang key='addonsExtras'}">
                {foreach $availableAddonProducts as $addonId => $addonName}
                    <option value="{$addonId}">{$addonName|escape}</option>
                {/foreach}
            </select>
            <button type="submit" class="btn-primary hn-mo-shrink">{lang key='purchaseActivate'}</button>
        </form>
    </div>
</div>
{/if}

{if empty($isSitejetActive) && $hnSjAddons}
<div class="card" id="cPanelGetSitejet">
    <div class="card-header"><h2 class="card-title">{lang key='sitejetBuilder.get.title'}</h2></div>
    <div class="card-body">
        <p class="hn-mo-muted">{lang key='sitejetBuilder.upsellDescription'}</p>
        {foreach $availableSitejetAddons as $availableSitejetAddon}
            <a href="cart.php?a=add&aid={$availableSitejetAddon->id}&serviceid={$serviceId}" class="btn-primary">
                {lang key='activateNowFor' price=$availableSitejetAddon->pricing()->best()->breakdownPrice()}
            </a>
            {break}
        {/foreach}
    </div>
</div>
{elseif empty($isSitejetActive) && $hnSjUpgrades}
<div class="card" id="cPanelGetSitejet">
    <div class="card-header"><h2 class="card-title">{lang key='sitejetBuilder.upgradeTo.title'}</h2></div>
    <div class="card-body">
        <p class="hn-mo-muted">{lang key='sitejetBuilder.upsellDescription'}</p>
        {foreach $availableSitejetProductUpgrades as $availableSitejetProductUpgrade}
            <form method="post" action="upgrade.php">
                <input type="hidden" name="step" value="2">
                <input type="hidden" name="type" value="package">
                <input type="hidden" name="id" value="{$serviceId}">
                <input type="hidden" name="pid" value="{$availableSitejetProductUpgrade->id}">
                <input type="hidden" name="billingcycle" value="{$availableSitejetProductUpgrade->pricing()->best()->cycle()}">
                <button type="submit" name="upgradeSitejet" class="btn-primary">
                    {lang key='upgradeToFor' package=$availableSitejetProductUpgrade->name price=$availableSitejetProductUpgrade->pricing()->best()->breakdownPrice()}
                </button>
            </form>
            {break}
        {/foreach}
    </div>
</div>
{/if}
