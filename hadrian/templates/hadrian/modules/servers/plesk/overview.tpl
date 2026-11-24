{* Hadrian override of the Plesk server module's overview
   (modules/servers/plesk/templates/overview.tpl), printed by Hadrian's
   product details page from $tplOverviewTabOutput.

   Only what that page doesn't draw natively: the module's error notice, the
   Sitejet Builder card, the Plesk "Manage Domains" single sign-on link,
   "Addons and Extras" + the Sitejet upsell, and WordPress Toolkit. Usage,
   shortcuts, billing, configurable options and custom fields come from
   core/pages/clientareaproductdetails.

   Rendered before Hadrian's ClientAreaPage hooks run: WHMCS variables only,
   no $hadrianLang / $hadrian. *}
<div class="hn-module-overview">
{include file="$template/includes/module-overview/styles.tpl"}
{include file="$template/includes/module-overview/scripts.tpl" clientJs='plesk'}

{if !empty($error)}
    {include file="$template/includes/alert.tpl" type=$alertType msg=$error}
{/if}

{include file="$template/includes/module-overview/sitejet.tpl" panelId='PleskPackagePanel'}

{if empty($isSitejetActive) && !empty($ssoLoginUrl)}
<div class="card" id="pleskManagePanel">
    <div class="card-header"><h2 class="card-title">{lang key='packageDomain'}</h2></div>
    <div class="card-body">
        <div class="hn-mo-actions" style="margin-top: 0;">
            {if !empty($domain)}<a href="http://{$domain}" class="btn-secondary" target="_blank" rel="noopener">{lang key='visitwebsite'}</a>{/if}
            <a href="{$ssoLoginUrl}" class="btn-primary" target="_blank" rel="noopener">{lang key='plesk.manageDomains'}</a>
        </div>
    </div>
</div>
{/if}

{include file="$template/includes/module-overview/addons.tpl" panelId='pleskExtrasPurchasePanel'}
{include file="$template/includes/module-overview/wordpress.tpl" panelId='pleskWordPress'}
</div>
