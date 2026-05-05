{* =========================================================================
   usagebillingpricing.tpl — shows tiered pricing for usage-based billing.
   ========================================================================= *}
<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='pricing'}</h3></div>
    <div class="card-body">
        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>{lang key='metric'}</th>
                        <th class="text-right">{lang key='included'}</th>
                        <th class="text-right">{lang key='overage'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $pricing as $row}
                        <tr>
                            <td>{$row.metric}</td>
                            <td class="text-right">{$row.included}</td>
                            <td class="text-right">{$row.overage}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>
