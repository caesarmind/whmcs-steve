{* =========================================================================
   clientareadomains.tpl — list of all domains with DataTables.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='clientareanavdomains'}</h1>
</div>

{if $warnings}
    {include file="$template/includes/alert.tpl" type="warning" msg=$warnings textcenter=true}
{/if}

{include file="$template/includes/tablelist.tpl" tableName="DomainsList" noSortColumns="0, 1" startOrderCol="2" filterColumn="5"}

<script>
    jQuery(document).ready(function() {
        var table = jQuery('#tableDomainsList').show().DataTable();
        {if $orderby == 'domain'}table.order(2, '{$sort}');
        {elseif $orderby == 'regdate' || $orderby == 'registrationdate'}table.order(3, '{$sort}');
        {elseif $orderby == 'nextduedate'}table.order(4, '{$sort}');
        {elseif $orderby == 'autorenew'}table.order(5, '{$sort}');
        {elseif $orderby == 'status'}table.order(6, '{$sort}');{/if}
        table.draw();
        jQuery('#tableLoading').hide();
    });
</script>

<div class="card">
    <div class="card-body">
        <form id="domainForm" method="post" action="clientarea.php?action=bulkdomain">
            <input id="bulkaction" name="update" type="hidden">

            <div class="btn-group mb-3">
                <button type="button" class="btn btn-secondary btn-sm setBulkAction" id="nameservers"><i class="far fa-globe"></i> {lang key='domainmanagens'}</button>
                <button type="button" class="btn btn-secondary btn-sm setBulkAction" id="contactinfo"><i class="far fa-user"></i> {lang key='domaincontactinfoedit'}</button>
                {if $allowrenew}
                    <button type="button" class="btn btn-secondary btn-sm setBulkAction" id="renewDomains"><i class="fas fa-sync"></i> {lang key='domainmassrenew'}</button>
                {/if}
                <button type="button" class="btn btn-secondary btn-sm setBulkAction" id="autorenew"><i class="fas fa-sync"></i> {lang key='domainautorenewstatus'}</button>
                <button type="button" class="btn btn-secondary btn-sm setBulkAction" id="reglock"><i class="fas fa-lock"></i> {lang key='domainreglockstatus'}</button>
            </div>

            <div class="table-container">
                <table id="tableDomainsList" class="table table-hover w-hidden">
                    <thead>
                        <tr>
                            <th></th>
                            <th></th>
                            <th>{lang key='orderdomain'}</th>
                            <th>{lang key='clientareahostingregdate'}</th>
                            <th>{lang key='clientareahostingnextduedate'}</th>
                            <th>{lang key='domainstatus'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $domains as $domain}
                            <tr onclick="clickableSafeRedirect(event, 'clientarea.php?action=domaindetails&amp;id={$domain.id}', false)">
                                <td><input type="checkbox" name="domids[]" class="domids stopEventBubble" value="{$domain.id}"></td>
                                <td class="ssl-info" data-element-id="{$domain.id}" data-type="domain" data-domain="{$domain.domain}">
                                    {if $domain.sslStatus}
                                        <img src="{$domain.sslStatus->getImagePath()}" width="20" data-toggle="tooltip" title="{$domain.sslStatus->getTooltipContent()}" class="{$domain.sslStatus->getClass()}">
                                    {elseif !$domain.isActive}
                                        <img src="{$BASE_PATH_IMG}/ssl/ssl-inactive-domain.png" width="20" data-toggle="tooltip" title="{lang key='sslState.sslInactiveDomain'}">
                                    {/if}
                                </td>
                                <td>
                                    <a href="http://{$domain.domain}" target="_blank" rel="noopener">{$domain.domain}</a>
                                    <div class="form-hint">
                                        {if $domain.autorenew}<i class="fas fa-check text-success"></i>{else}<i class="fas fa-times text-danger"></i>{/if}
                                        {lang key='domainsautorenew'}
                                    </div>
                                </td>
                                <td><span class="w-hidden">{$domain.normalisedRegistrationDate}</span>{$domain.registrationdate}</td>
                                <td><span class="w-hidden">{$domain.normalisedNextDueDate}</span>{$domain.nextduedate}</td>
                                <td>
                                    <span class="status-pill {$domain.statusClass}">{$domain.statustext}</span>
                                    <span class="w-hidden">{if $domain.expiringSoon}<span>{lang key='domainsExpiringSoon'}</span>{/if}</span>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                <div class="text-center" id="tableLoading">
                    <p><i class="fas fa-spinner fa-spin"></i> {lang key='loading'}</p>
                </div>
            </div>
        </form>
    </div>
</div>
