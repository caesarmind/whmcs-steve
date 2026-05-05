{* =========================================================================
   clientareaproductusagebilling.tpl — per-service usage metrics.
   Typically included as a tab inside clientareaproductdetails.tpl.
   ========================================================================= *}
<div class="usage-billing">
    {if $metricStats}
        {foreach $metricStats as $metric}
            <div class="usage-stat card">
                <div class="card-header"><h4 class="card-title">{$metric.label}</h4></div>
                <div class="card-body">
                    <div class="usage-bar"><div class="usage-bar-fill" style="width:{$metric.percentage}%"></div></div>
                    <div class="usage-detail">
                        <span class="usage-used">{$metric.used}</span>
                        <span class="usage-separator">/</span>
                        <span class="usage-limit">{$metric.limit}</span>
                        {if $metric.unit}<span class="usage-unit">{$metric.unit}</span>{/if}
                    </div>
                    {if $metric.nextInvoiceAmount}
                        <p class="form-hint">{lang key='nextInvoiceAmount'}: <strong>{$metric.nextInvoiceAmount}</strong></p>
                    {/if}
                </div>
            </div>
        {/foreach}
    {else}
        {include file="$template/includes/alert.tpl" type="info" msg="{lang key='metrics.noneFound'}" textcenter=true}
    {/if}
</div>
