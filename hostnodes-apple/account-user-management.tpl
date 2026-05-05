{* =========================================================================
   account-user-management.tpl — manage invited users that can access the
   client account.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='accountManagement.users'}</h1>
    <a href="#" class="btn btn-primary" data-toggle="modal" data-target="#inviteUserModal"><i class="fas fa-user-plus"></i> {lang key='accountManagement.inviteUser'}</a>
</div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='accountManagement.activeUsers'}</h3></div>
    <div class="card-body">
        {if $users && count($users) > 0}
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>{lang key='name'}</th>
                            <th>{lang key='email'}</th>
                            <th>{lang key='accountManagement.status'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $users as $user}
                            <tr>
                                <td>{$user.full_name}</td>
                                <td>{$user.email}</td>
                                <td><span class="status-pill {if $user.is_owner}active{elseif $user.pending}pending{else}info{/if}">{if $user.is_owner}{lang key='accountManagement.owner'}{elseif $user.pending}{lang key='accountManagement.pending'}{else}{lang key='accountManagement.active'}{/if}</span></td>
                                <td class="text-right">
                                    {if !$user.is_owner}
                                        <a href="{routePath('account-user-permissions', $user.id)}" class="btn btn-secondary btn-sm">{lang key='accountManagement.permissions'}</a>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='accountManagement.noUsers'}" textcenter=true}
        {/if}
    </div>
</div>
