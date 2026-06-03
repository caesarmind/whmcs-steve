{* Hostnodes - User permissions (Apple-style).

   WHMCS v9 data (verified against Lagom/Nexus account-user-permissions.tpl):
     $user            - the sub-user being edited: ->id, ->email
     $permissions     - array, each: key, title, description
     $userPermissions - object: ->hasPermission($key) returns bool
   POST: {routePath('account-users-permissions-save', $user->id)}, perms[{key}]=1.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasPerms value=false}
{if isset($permissions) && $permissions|@count > 0}{assign var=hasPerms value=true}{/if}

{assign var=permDemo value=false}
{if !$hasPerms && $isPreview}
    {assign var=permDemo value=true}
    {assign var=permList value=[
        ['key'=>'services','title'=>'View services','description'=>'Can view all services on the account','checked'=>true],
        ['key'=>'managesvc','title'=>'Manage services','description'=>'Can upgrade, downgrade and cancel services','checked'=>true],
        ['key'=>'domains','title'=>'View domains','description'=>'Can view all domains on the account','checked'=>true],
        ['key'=>'managedns','title'=>'Manage DNS','description'=>'Can edit DNS records for domains','checked'=>false],
        ['key'=>'invoices','title'=>'View invoices','description'=>'Can view invoices and billing history','checked'=>true],
        ['key'=>'payments','title'=>'Make payments','description'=>'Can pay invoices','checked'=>false],
        ['key'=>'tickets','title'=>'Manage tickets','description'=>'Can open and reply to support tickets','checked'=>true]
    ]}
{/if}

{assign var=permFull value=false}
{if $hasPerms || $permDemo}{assign var=permFull value=true}{/if}
{if $permFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{assign var=permEmail value='user@example.com'}
{if isset($user->email)}{assign var=permEmail value=$user->email}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-user-permissions.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <p class="eyebrow">{$LANG.accounttab}</p>
    <h1>{$LANG.userManagement.permissions}</h1>
    <p class="page-subtitle">{$hadrianLang.account.managePermissionsSub}</p>
</header>

<div class="perm-split">
    <div class="perm-main">
        {if $permFull}
        <div class="when-full">
            <div class="card perm-user">
                <div class="perm-user-avatar">{$permEmail|truncate:1:""|escape}</div>
                <div>
                    <div class="perm-user-email">{$permEmail|escape}</div>
                    <div class="perm-user-sub">{$LANG.userManagement.permissions}</div>
                </div>
            </div>

            <form method="post" action="{if $permDemo}#{else}{routePath('account-users-permissions-save', $user->id)}{/if}">
                <input type="hidden" name="token" value="{$token|default:''|escape}">
                <div class="card">
                    <div class="perm-card-header"><span class="perm-card-title">{$LANG.userManagement.permissions}</span></div>
                    {if $permDemo}
                        {foreach $permList as $perm}
                        <div class="perm-row">
                            <div class="perm-row-info">
                                <div class="perm-row-label">{$perm.title|escape}</div>
                                <div class="perm-row-desc">{$perm.description|escape}</div>
                            </div>
                            <label class="perm-toggle">
                                <input type="checkbox" name="perms[{$perm.key|escape}]" value="1"{if $perm.checked} checked{/if}>
                                <span class="perm-track"></span>
                            </label>
                        </div>
                        {/foreach}
                    {else}
                        {foreach $permissions as $permission}
                        <div class="perm-row">
                            <div class="perm-row-info">
                                <div class="perm-row-label">{$permission.title|escape}</div>
                                {if isset($permission.description) && $permission.description}<div class="perm-row-desc">{$permission.description|escape}</div>{/if}
                            </div>
                            <label class="perm-toggle">
                                <input type="checkbox" name="perms[{$permission.key|escape}]" value="1"{if isset($userPermissions) && $userPermissions->hasPermission($permission.key)} checked{/if}>
                                <span class="perm-track"></span>
                            </label>
                        </div>
                        {/foreach}
                    {/if}
                </div>

                <div class="perm-actions">
                    <button type="submit" class="btn-primary">{$LANG.clientareasavechanges}</button>
                    <a href="{routePath('account-users')}" class="btn-secondary">{$LANG.cancel}</a>
                </div>
            </form>
        </div>
        {/if}

        {if !$permFull}
        <div class="when-empty">
            <div class="card">
                <div class="perm-empty">
                    <div class="perm-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                    </div>
                    <p class="perm-empty-title">{$hadrianLang.account.noUserSelected}</p>
                    <p class="perm-empty-sub">{$hadrianLang.account.selectUserSub}</p>
                    <a href="{routePath('account-users')}" class="btn-primary">{$LANG.usermanagement}</a>
                </div>
            </div>
        </div>
        {/if}
    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails}
            </a>
            <a href="{routePath('account-users')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                {$LANG.usermanagement}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentMethods.title}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts}
            </a>
        </div>
    </aside>
</div>
