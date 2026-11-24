{* WHMCS includes this file once per usage metric, with $metric set, inside
   the order form's Configure Product option row (and stock's
   clientareaproductusagebilling.tpl). There it must render only that
   metric's pricing modal, the target of the row's "View Pricing" button
   (data-target="#modalMetricPricing-<systemName>"). The order form loads
   Bootstrap's modal JS and styles .modal (hadrian_cart/css/style.min.css).
   Without $metric it is the Page Manager page, dispatched as before. *}
{if isset($metric) && $metric}
<div class="modal fade modal-metric-pricing" tabindex="-1" role="dialog" id="modalMetricPricing-{$metric.systemName}">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title">{$metric.displayName} {$LANG.metrics.pricing}</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="{$LANG.close}"><span aria-hidden="true">&times;</span></button>
            </div>
            <div class="modal-body">
                <p>{$metric.pricingSchema.info}<br>{$metric.pricingSchema.detail}</p>
                <table class="table table-sm">
                    <tr>
                        <th>{$LANG.metrics.startingQuantity}</th>
                        <th>{$LANG.metrics.pricePer} {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}</th>
                    </tr>
                    {foreach $metric.pricing as $pricing}
                    <tr>
                        <td>{$pricing.from}</td>
                        <td>{$pricing.price_per_unit}</td>
                    </tr>
                    {/foreach}
                </table>
                {if $metric.includedQuantity}
                    <p>{$metric.includedQuantity} {$metric.includedQuantityUnits} {$LANG.metrics.includedInBase}</p>
                {/if}
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{$LANG.close}</button>
            </div>
        </div>
    </div>
</div>
{elseif isset($hadrian.pages.usagebillingpricing.fullPath) && $hadrian.pages.usagebillingpricing.fullPath && file_exists("templates/`$hadrian.pages.usagebillingpricing.fullPath`")}
	{include file="`$hadrian.pages.usagebillingpricing.fullPath`"}
{else}
	{include file="`$template`/core/pages/usagebillingpricing/default/default.tpl"}
{/if}
