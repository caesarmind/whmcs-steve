{* =========================================================================
   serverstatus.tpl — status dashboard for servers + network issues.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='serverstatus'}</h1></div>

{if $openissues}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='openissues'}</h3></div>
        <div class="card-body">
            {foreach $openissues as $issue}
                <div class="callout {if $issue.type == 'Outage'}danger{else}warning{/if}">
                    <strong>{$issue.title}</strong>
                    <p>{$issue.description}</p>
                    <div class="form-hint">{$issue.date}</div>
                </div>
            {/foreach}
        </div>
    </div>
{/if}

{if $scheduledissues}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='scheduledissues'}</h3></div>
        <div class="card-body">
            {foreach $scheduledissues as $issue}
                <div class="callout info">
                    <strong>{$issue.title}</strong>
                    <p>{$issue.description}</p>
                    <div class="form-hint">{$issue.scheduleddate}</div>
                </div>
            {/foreach}
        </div>
    </div>
{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='servers'}</h3></div>
    <div class="card-body">
        {if $servers}
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='servername'}</th>
                            <th>{lang key='status'}</th>
                            <th>{lang key='uptime'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $servers as $server}
                            <tr>
                                <td>{$server.name}</td>
                                <td><span class="status-pill {if $server.status == 'Online'}active{else}danger{/if}">{$server.status}</span></td>
                                <td>{$server.uptime}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='nostatus'}" textcenter=true}
        {/if}
    </div>
</div>
