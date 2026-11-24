{* Usage-based billing metrics for one service - the WHMCS shared include.

   Included by Hadrian's product details page and by server-module templates
   that include "$template/clientareaproductusagebilling.tpl" by name (the
   stock cPanel and WP Squared overviews do). Same contract as stock Nexus:
     $metricStats[]  displayName, systemName, currentValue, unitName,
                     lowestPrice, includedQuantity, includedQuantityUnits,
                     pricing[] (from, price_per_unit), pricingSchema.info /
                     .detail, lastUpdated (string or a Carbon date)
   Stock opens tiered pricing in a Bootstrap modal (usagebillingpricing.tpl);
   the client area doesn't load Bootstrap's JS, so the tiers open in place.
   Styles are scoped to .hn-metrics: the usage-pricing page stylesheet also
   restyles .page-header, so it can't be linked from another page. *}
<style>{literal}
.hn-metrics-intro{margin:0 0 14px;font-size:var(--text-sm);color:var(--color-text-secondary);line-height:1.5}
.hn-metrics-wrap{overflow-x:auto}
.hn-metrics{width:100%;border-collapse:collapse}
.hn-metrics th{padding:10px 12px;font-size:var(--text-xs);font-weight:var(--fw-semibold);color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:.05em;text-align:left;border-bottom:.5px solid var(--color-border);white-space:nowrap}
.hn-metrics td{padding:12px;font-size:var(--text-md);color:var(--color-text-primary);border-bottom:.5px solid var(--color-border);vertical-align:top;font-variant-numeric:tabular-nums}
.hn-metrics tr:last-child td{border-bottom:0}
.hn-metrics-name{font-weight:var(--fw-semibold)}
.hn-metrics-sub{display:block;font-size:var(--text-sm);color:var(--color-text-secondary);margin-top:2px}
.hn-metrics-tiers summary{cursor:pointer;color:var(--color-accent);font-size:var(--text-sm);margin-top:4px}
{/literal}</style>
<p class="hn-metrics-intro">{$LANG.metrics.explanation}</p>
<div class="hn-metrics-wrap">
    <table class="hn-metrics">
        <thead>
            <tr>
                <th>{$LANG.metrics.metric}</th>
                <th>{$LANG.metrics.currentUsage}</th>
                <th>{$LANG.metrics.pricing}</th>
                <th>{$LANG.metrics.lastUpdated}</th>
            </tr>
        </thead>
        <tbody>
            {foreach $metricStats as $metric}
            <tr>
                <td class="hn-metrics-name">{$metric.displayName}</td>
                <td>{$metric.currentValue}</td>
                <td>
                    {if count($metric.pricing) > 1}
                        {$LANG.metrics.startingFrom} {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                        <details class="hn-metrics-tiers">
                            <summary>{$LANG.metrics.viewPricing}</summary>
                            {if $metric.pricingSchema.info}<span class="hn-metrics-sub">{$metric.pricingSchema.info} {$metric.pricingSchema.detail}</span>{/if}
                            {foreach $metric.pricing as $tier}
                                <span class="hn-metrics-sub">{$LANG.metrics.from} {$tier.from}: {$tier.price_per_unit}</span>
                            {/foreach}
                            {if $metric.includedQuantity}<span class="hn-metrics-sub">{$metric.includedQuantity} {$metric.includedQuantityUnits} {$LANG.metrics.includedInBase}</span>{/if}
                        </details>
                    {elseif count($metric.pricing) == 1}
                        {$metric.lowestPrice} / {if $metric.unitName}{$metric.unitName}{else}{$LANG.metrics.unit}{/if}
                        {if $metric.includedQuantity > 0}<span class="hn-metrics-sub">{$metric.includedQuantity} {$LANG.metrics.includedNotCounted}</span>{/if}
                    {else}
                        &mdash;
                    {/if}
                </td>
                <td>{if is_string($metric.lastUpdated)}{$metric.lastUpdated}{else}{$metric.lastUpdated->diffForHumans()}{/if}</td>
            </tr>
            {/foreach}
        </tbody>
    </table>
</div>
