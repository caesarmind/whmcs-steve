{* Hostnodes - Usage billing pricing (Apple-style): metered resource rates.

   WHMCS variables: Lagom exposes usagebillingpricing.tpl as a per-metric modal
   ($metric: displayName, unitName, pricing[] {from, price_per_unit},
   includedQuantity, includedQuantityUnits). The full-page collection variable
   is install-dependent; we iterate $metrics defensively and fall back to the
   empty state. VERIFY the collection variable name on the live site.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasMetrics value=false}
{if isset($metrics) && $metrics|@count > 0}{assign var=hasMetrics value=true}{/if}

{assign var=ubDemo value=false}
{if !$hasMetrics && $isPreview}
    {assign var=ubDemo value=true}
    {assign var=ubDemoRows value=[
        ['name'=>'Bandwidth egress','desc'=>'Data transferred out of the server','included'=>'1,000 GB / month','rate'=>'$0.02 per GB'],
        ['name'=>'SSD storage','desc'=>'Primary account storage','included'=>'50 GB','rate'=>'$0.10 per GB / month'],
        ['name'=>'Compute hours','desc'=>'Container runtime','included'=>'720 hrs / month','rate'=>'$0.02 per hour'],
        ['name'=>'Backup retention','desc'=>'Off-site incremental backups','included'=>'10 GB','rate'=>'$0.05 per GB / month'],
        ['name'=>'Outbound email','desc'=>'Transactional + marketing','included'=>'2,500 messages','rate'=>'$0.001 per message']
    ]}
{/if}

{assign var=ubFull value=false}
{if $hasMetrics || $ubDemo}{assign var=ubFull value=true}{/if}
{if $ubFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/usagebillingpricing.css?v={$myTheme.version|default:'1.0'}">

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
    <h1>{$LANG.metrics.pricing}</h1>
    <p class="page-subtitle">{$hadrianLang.services.usagePricingIntro}</p>
</header>

{if $ubFull}
<div class="when-full">
    <div class="card" style="padding: 0; overflow: hidden;">
        <table class="ub-table">
            <thead>
                <tr>
                    <th>{$hadrianLang.services.metricResource}</th>
                    <th>{$LANG.metrics.includedInBase}</th>
                    <th>{$hadrianLang.services.metricOverageRate}</th>
                </tr>
            </thead>
            <tbody>
                {if $ubDemo}
                    {foreach $ubDemoRows as $row}
                    <tr>
                        <td><div class="ub-metric-name">{$row.name|escape}</div><div class="ub-metric-desc">{$row.desc|escape}</div></td>
                        <td class="ub-included">{$row.included|escape}</td>
                        <td class="ub-rate">{$row.rate|escape}</td>
                    </tr>
                    {/foreach}
                {else}
                    {foreach $metrics as $metric}
                    <tr>
                        <td>
                            <div class="ub-metric-name">{$metric.displayName|default:$metric.systemName|default:''|escape}</div>
                            {if isset($metric.pricingSchema.info) && $metric.pricingSchema.info}<div class="ub-metric-desc">{$metric.pricingSchema.info|strip_tags}</div>{/if}
                        </td>
                        <td class="ub-included">
                            {if isset($metric.includedQuantity) && $metric.includedQuantity}{$metric.includedQuantity|escape} {$metric.includedQuantityUnits|default:''|escape}{else}-{/if}
                        </td>
                        <td class="ub-rate">
                            {if isset($metric.pricing) && $metric.pricing|@count > 0}
                                {foreach $metric.pricing as $tier}
                                    <span class="ub-rate-tier">{$tier.price_per_unit|escape}{if isset($metric.unitName) && $metric.unitName} / {$metric.unitName|escape}{/if}{if isset($tier.from) && $tier.from > 0} ({$hadrianLang.services.metricFrom|replace:'%s':$tier.from|escape}){/if}</span>
                                {/foreach}
                            {else}-{/if}
                        </td>
                    </tr>
                    {/foreach}
                {/if}
            </tbody>
        </table>
    </div>

    <div class="ub-info">
        <strong>{$hadrianLang.services.usagePricingHowTitle}</strong>
        {$hadrianLang.services.usagePricingHow}
    </div>

    <div class="ub-actions">
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$hadrianLang.services.metricViewUsage}</a>
    </div>
</div>
{/if}

{if !$ubFull}
<div class="when-empty">
    <div class="card">
        <div class="ub-empty">
            <div class="ub-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v4l3 2"/></svg>
            </div>
            <p class="ub-empty-title">{$hadrianLang.services.usagePricingNoneTitle}</p>
            <p class="ub-empty-sub">{$hadrianLang.services.usagePricingNoneSub}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        </div>
    </div>
</div>
{/if}
