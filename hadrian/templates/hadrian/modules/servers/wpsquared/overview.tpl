{* Hadrian override of the WP Squared server module's overview
   (modules/servers/wpsquared/templates/overview.tpl), printed by Hadrian's
   product details page from $tplOverviewTabOutput.

   The stock overview repeats package, usage, billing, configurable options,
   metrics and custom fields, all drawn natively by
   core/pages/clientareaproductdetails, so only "Addons and Extras" is left.
   Rendered before Hadrian's ClientAreaPage hooks: WHMCS variables only. *}
<div class="hn-module-overview">
{include file="$template/includes/module-overview/styles.tpl"}
{include file="$template/includes/module-overview/addons.tpl" panelId='wpsquaredExtrasPurchasePanel'}
</div>
