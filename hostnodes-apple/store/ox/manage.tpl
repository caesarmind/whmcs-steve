{* store/ox/manage.tpl — OX mailbox management. *}
<div class="page-header">
    <h1 class="page-title">{lang key='store.ox.manage.title'}</h1>
    <p class="page-subtitle">{lang key='store.ox.manage.subtitle'}</p>
</div>

{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='store.ox.mailboxes'}</h3></div>
    <div class="card-body">
        {if $mailboxes}
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='email'}</th>
                            <th>{lang key='store.ox.plan'}</th>
                            <th>{lang key='status'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $mailboxes as $mailbox}
                            <tr>
                                <td>{$mailbox.email}</td>
                                <td>{$mailbox.plan}</td>
                                <td><span class="status-pill {$mailbox.status|strtolower}">{$mailbox.status}</span></td>
                                <td class="text-right">
                                    <a href="?action=edit&id={$mailbox.id}" class="btn btn-secondary btn-sm">{lang key='edit'}</a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='store.ox.noMailboxes'}" textcenter=true}
        {/if}
    </div>
</div>
