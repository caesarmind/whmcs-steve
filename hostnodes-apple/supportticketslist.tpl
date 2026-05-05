{* =========================================================================
   supportticketslist.tpl — user's support tickets list.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='clientareanavtickets'}</h1>
    <a href="{$WEB_ROOT}/supporttickets.php?action=submit" class="btn btn-primary"><i class="fas fa-plus"></i> {lang key='supportticketsopennew'}</a>
</div>

{include file="$template/includes/tablelist.tpl" tableName="TicketsList" filterColumn="2"}

<script>
    jQuery(document).ready(function() {
        var table = jQuery('#tableTicketsList').show().DataTable();
        {if $orderby == 'did' || $orderby == 'dept'}table.order(0, '{$sort}');
        {elseif $orderby == 'subject' || $orderby == 'title'}table.order(1, '{$sort}');
        {elseif $orderby == 'status'}table.order(2, '{$sort}');
        {elseif $orderby == 'lastreply'}table.order(3, '{$sort}');{/if}
        table.draw();
        jQuery('#tableLoading').hide();
    });
</script>

<div class="card">
    <div class="card-body">
        <div class="table-container">
            <table id="tableTicketsList" class="table table-hover w-hidden">
                <thead>
                    <tr>
                        <th>{lang key='supportticketsdepartment'}</th>
                        <th>{lang key='supportticketssubject'}</th>
                        <th>{lang key='supportticketsstatus'}</th>
                        <th>{lang key='supportticketsticketlastupdated'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $tickets as $ticket}
                        <tr onclick="window.location='viewticket.php?tid={$ticket.tid}&amp;c={$ticket.c}'">
                            <td>{$ticket.department}</td>
                            <td>
                                <a href="viewticket.php?tid={$ticket.tid}&amp;c={$ticket.c}">
                                    <span class="ticket-number">#{$ticket.tid}</span>
                                    <span class="ticket-subject{if $ticket.unread} unread{/if}">{$ticket.subject|escape}</span>
                                </a>
                            </td>
                            <td>
                                <span class="status-pill {if is_null($ticket.statusColor)}{$ticket.statusClass}{else}custom" style="background-color:{$ticket.statusColor}{/if}">
                                    {$ticket.status|strip_tags}
                                </span>
                            </td>
                            <td><span class="w-hidden">{$ticket.normalisedLastReply}</span>{$ticket.lastreply}</td>
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
