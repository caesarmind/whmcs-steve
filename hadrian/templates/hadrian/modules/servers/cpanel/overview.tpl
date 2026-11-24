{* Hadrian override of the cPanel server module's overview
   (modules/servers/cpanel/templates/overview.tpl). WHMCS renders it into
   $tplOverviewTabOutput, which Hadrian's product details page prints after
   its own cards.

   Only the panels that page doesn't already draw natively are here: the
   Sitejet Builder card, "Addons and Extras" + the Sitejet upsell, WordPress
   Toolkit, the WP Toolkit Deluxe link and Quick Create Email Account. Package,
   usage, quick shortcuts, billing, configurable options, custom fields,
   metrics and hook output are rendered by core/pages/clientareaproductdetails.

   Runs while WHMCS builds the page, before Hadrian's ClientAreaPage hooks, so
   only WHMCS variables ($LANG, {lang}, module vars) exist here - not
   $hadrianLang or $hadrian. *}
<div class="hn-module-overview">
{include file="$template/includes/module-overview/styles.tpl"}
{include file="$template/includes/module-overview/scripts.tpl" clientJs='cpanel'}

{include file="$template/includes/module-overview/sitejet.tpl" panelId='cPanelPackagePanel'}
{include file="$template/includes/module-overview/addons.tpl" panelId='cPanelExtrasPurchasePanel'}

{if isset($systemStatus) && $systemStatus == 'Active'}
    {include file="$template/includes/module-overview/wordpress.tpl" panelId='cPanelWordPress'}

    {if !empty($hasWPTDeluxe)}
    <div class="card" id="cPanelWptk">
        <div class="card-header"><h2 class="card-title">{$LANG.cPanel.wptk}</h2></div>
        <div class="card-body">
            <a href="clientarea.php?action=productdetails&amp;id={$serviceid}&amp;addonId={$wptkDeluxeAddonId}&amp;doaddonsignon=1" target="_blank" rel="noopener" class="btn-primary">{$LANG.cPanel.wptk}</a>
        </div>
    </div>
    {/if}

    <div class="card" id="cPanelQuickEmailPanel">
        <div class="card-header"><h2 class="card-title">{$LANG.cPanel.createEmailAccount}</h2></div>
        <div class="card-body">
            {include file="$template/includes/alert.tpl" type="success" msg=$LANG.cPanel.emailAccountCreateSuccess textcenter=true hide=true idname="emailCreateSuccess" additionalClasses="email-create-feedback"}
            {include file="$template/includes/alert.tpl" type="danger" msg=$LANG.cPanel.emailAccountCreateFailed|cat:' <span id="emailCreateFailedErrorMsg"></span>' textcenter=true hide=true idname="emailCreateFailed" additionalClasses="email-create-feedback"}

            {* doEmailCreate() (module js/client.js) posts this form's fields to
               clientarea.php?action=productdetails&modop=custom&a=CreateEmailAccount. *}
            <form method="POST" id="frmCreateEmailAccount" class="hn-mo-row" onsubmit="doEmailCreate();return false">
                <input type="hidden" name="id" value="{$serviceid}" />
                <input type="hidden" name="email_quota" value="250" />
                <div class="hn-mo-suffix">
                    <input type="text" id="cpanel-email-prefix" name="email_prefix" class="pd-field-input" placeholder="{$LANG.cPanel.usernamePlaceholder}" aria-label="{$LANG.cPanel.usernamePlaceholder}">
                    <span>@{$domain}</span>
                </div>
                <input type="password" id="cpanel-email-password" name="email_pw" class="pd-field-input" placeholder="{$LANG.cPanel.passwordPlaceholder}" aria-label="{$LANG.cPanel.passwordPlaceholder}" autocomplete="new-password">
                <button type="submit" class="btn-primary hn-mo-shrink"><i id="btnCreateLoader" aria-hidden="true"></i>{$LANG.cPanel.create}</button>
            </form>
        </div>
    </div>
{/if}
</div>
