{* =========================================================================
   clientareaproducts.tpl — list of all services with DataTables behavior.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='clientareanavservices'}</h1>
</div>

{include file="$template/includes/tablelist.tpl" tableName="ServicesList" filterColumn="4" noSortColumns="0"}

<script>
    jQuery(document).ready(function() {
        var table = jQuery('#tableServicesList').show().DataTable();
        {if $orderby == 'product'}table.order([1, '{$sort}'], [4, 'asc']);
        {elseif $orderby == 'amount' || $orderby == 'billingcycle'}table.order(2, '{$sort}');
        {elseif $orderby == 'nextduedate'}table.order(3, '{$sort}');
        {elseif $orderby == 'domainstatus'}table.order(4, '{$sort}');{/if}
        table.draw();
        jQuery('#tableLoading').hide();
    });
</script>

<div class="card">
    <div class="card-body">
        <div class="table-container">
            <table id="tableServicesList" class="table table-hover w-hidden">
                <thead>
                    <tr>
                        <th></th>
                        <th>{lang key='orderproduct'}</th>
                        <th>{lang key='clientareaaddonpricing'}</th>
                        <th>{lang key='clientareahostingnextduedate'}</th>
                        <th>{lang key='clientareastatus'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $services as $service}
                        <tr onclick="clickableSafeRedirect(event, 'clientarea.php?action=productdetails&amp;id={$service.id}', false)">
                            <td class="ssl-col{if $service.sslStatus} ssl-info{/if}" data-element-id="{$service.id}" data-type="service"{if $service.domain} data-domain="{$service.domain}"{/if}>
                                {if $service.sslStatus}
                                    <img src="{$service.sslStatus->getImagePath()}" data-toggle="tooltip" title="{$service.sslStatus->getTooltipContent()}" class="{$service.sslStatus->getClass()}" width="20">
                                {elseif !$service.isActive}
                                    <img src="{$BASE_PATH_IMG}/ssl/ssl-inactive-domain.png" data-toggle="tooltip" title="{lang key='sslState.sslInactiveService'}" width="20">
                                {/if}
                            </td>
                            <td>
                                <strong>{$service.product}</strong>
                                {if $service.domain}<br><a href="http://{$service.domain}" target="_blank" rel="noopener" class="service-domain-link">{$service.domain}</a>{/if}
                            </td>
                            <td data-order="{$service.amountnum}">
                                {$service.amount}
                                <div class="form-hint">{$service.billingcycle}</div>
                            </td>
                            <td><span class="w-hidden">{$service.normalisedNextDueDate}</span>{$service.nextduedate}</td>
                            <td><span class="status-pill {$service.status|strtolower}">{$service.statustext}</span></td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
            <div class="text-center" id="tableLoading">
                <p><i class="fas fa-spinner fa-spin"></i> {lang key='loading'}</p>
            </div>
        </div>
    </div>
</div>
