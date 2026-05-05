{* =========================================================================
   account-user-permissions.tpl — set per-user permission flags.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='accountManagement.permissions'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="token" value="{$token}">
    <input type="hidden" name="userid" value="{$selectedUserId}">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{$selectedUser.full_name}</h3></div>
        <div class="card-body">
            {foreach $allPermissions as $permission}
                <label class="checkbox-label">
                    <input type="checkbox" name="permissions[]" value="{$permission.name}" class="form-checkbox"{if in_array($permission.name, $userPermissions)} checked{/if}>
                    <span><strong>{$permission.label}</strong>{if $permission.description}<br><small class="form-hint">{$permission.description}</small>{/if}</span>
                </label>
            {/foreach}
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
        <a href="{routePath('account-users')}" class="btn btn-secondary">{lang key='cancel'}</a>
    </div>
</form>
