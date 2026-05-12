{* Hostnodes — User Management (Apple-style).

   WHMCS v9 data (verified against Nexus):
     $users        — Eloquent Collection of WHMCS\User\User models
                     properties: id, email, firstname, lastname
                     pivot:      owner (bool), hasLastLogin(), getLastLogin() (Carbon)
                     methods:    hasTwoFactorAuthEnabled()
     $invites      — Eloquent Collection of pending invites
                     properties: id, email, created_at (Carbon)
     $permissions  — array of permission options (for invite form)
                     each has .key, .title, .description
     $formdata     — pre-filled invite-form data (e.g. $formdata.inviteemail)
     $token        — CSRF token

   Do NOT read isOwner as a property — v9 makes that a relationship method
   that needs an argument; the property read triggers ArgumentCountError.
   Always use the v9 pivot field $user->pivot->owner instead.
*}

{assign var=usCount value=0}
{if isset($users)}{assign var=usCount value=$users->count()}{/if}
{assign var=invCount value=0}
{if isset($invites)}{assign var=invCount value=$invites->count()}{/if}
{if $usCount > 0 || $invCount > 0}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-user-management.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <h1>{$LANG.usermanagement|default:'User Management'}</h1>
            <p class="page-subtitle">{$LANG.usermanagementsub|default:'Invite people to access this account and choose what they can do.'}</p>
        </div>
        <a href="#umInviteForm" class="page-header-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.userManagement.inviteNewUser|default:'Invite new user'}
        </a>
    </div>
</header>

<div class="um-split">
    <div class="um-main">

        {if $message = get_flash_message()}
            <div class="um-alert um-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">
                {$message.text}
            </div>
        {/if}

        {if $usCount > 0}
        <div class="when-full um-list">
            {foreach $users as $user}
                {assign var=uFirst value=$user->firstname|default:''}
                {assign var=uLast  value=$user->lastname|default:''}
                {assign var=uName  value=$uFirst|cat:' '|cat:$uLast}
                {assign var=uName  value=$uName|trim}
                {if $uName == ''}{assign var=uName value=$user->email|default:''}{/if}
                {assign var=uInitial value=$uFirst|default:$user->email|default:'?'}
                {assign var=uInitial value=$uInitial|substr:0:1|upper}
                {assign var=isOwner value=false}
                {if isset($user->pivot) && $user->pivot->owner}{assign var=isOwner value=true}{/if}
                <div class="um-row{if $isOwner} um-row-owner{/if}">
                    <div class="um-row-avatar">{$uInitial|escape}</div>
                    <div class="um-row-meta">
                        <div class="um-row-name">
                            {$uName|escape}
                            {if $isOwner}<span class="um-tag um-tag-owner">{$LANG.clientOwner|default:'Owner'}</span>{/if}
                        </div>
                        <div class="um-row-sub">
                            {$user->email|default:''|escape}
                            {if $user->hasTwoFactorAuthEnabled()}
                                <span class="um-2fa" title="{$LANG.twoFactor.enabled|default:'Two-factor enabled'}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                </span>
                            {/if}
                        </div>
                        {if isset($user->pivot)}
                            <div class="um-row-meta-extra">
                                {$LANG.userManagement.lastLogin|default:'Last login'}:
                                {if $user->pivot->hasLastLogin()}{$user->pivot->getLastLogin()->diffForHumans()}{else}{$LANG.never|default:'Never'}{/if}
                            </div>
                        {/if}
                    </div>
                    <div class="um-row-actions">
                        <a href="{if $isOwner}#{else}{routePath('account-users-permissions', $user->id)}{/if}" class="um-row-btn{if $isOwner} um-row-btn-disabled{/if}"{if $isOwner} aria-disabled="true"{/if}>
                            {$LANG.userManagement.managePermissions|default:'Permissions'}
                        </a>
                        {if !$isOwner}
                            <button type="button" class="um-row-btn um-row-btn-danger" data-um-remove="{$user->id|escape}">{$LANG.userManagement.removeAccess|default:'Remove'}</button>
                        {/if}
                    </div>
                </div>
            {/foreach}

            {if $invCount > 0}
                <div class="um-section-label">{$LANG.userManagement.pendingInvites|default:'Pending invites'}</div>
                {foreach $invites as $invite}
                    <div class="um-row um-row-invite">
                        <div class="um-row-avatar um-row-avatar-pending">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                        </div>
                        <div class="um-row-meta">
                            <div class="um-row-name">{$invite->email|default:''|escape}</div>
                            <div class="um-row-sub">
                                {$LANG.userManagement.inviteSent|default:'Invited'}
                                {if isset($invite->created_at)}{$invite->created_at->diffForHumans()}{/if}
                            </div>
                        </div>
                        <div class="um-row-actions">
                            <form method="post" action="{routePath('account-users-invite-resend')}" style="display:inline">
                                <input type="hidden" name="token" value="{$token|default:''|escape}">
                                <input type="hidden" name="inviteid" value="{$invite->id|escape}">
                                <button type="submit" class="um-row-btn">{$LANG.userManagement.resendInvite|default:'Resend'}</button>
                            </form>
                            <button type="button" class="um-row-btn um-row-btn-danger" data-um-cancel-invite="{$invite->id|escape}">{$LANG.userManagement.cancelInvite|default:'Cancel'}</button>
                        </div>
                    </div>
                {/foreach}
            {/if}
        </div>
        {/if}

        <div class="when-empty um-empty">
            <div class="um-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg></div>
            <p class="um-empty-title">{$LANG.userManagement.noUsers|default:'No additional users'}</p>
            <p class="um-empty-sub">{$LANG.userManagement.noUsersSub|default:'You are the only person with access to this account. Invite a teammate, accountant, or developer to collaborate.'}</p>
        </div>

        {* ───── Invite form ───── *}
        <div class="card um-invite" id="umInviteForm">
            <div class="um-invite-header">
                <h2 class="um-invite-title">{$LANG.userManagement.inviteNewUser|default:'Invite a new user'}</h2>
                <p class="um-invite-sub">{$LANG.userManagement.inviteNewUserDescription|default:'Send an invitation email. The user can sign up or sign in to their existing WHMCS account to accept.'}</p>
            </div>
            <form method="post" action="{routePath('account-users-invite')}" class="um-invite-form">
                <input type="hidden" name="token" value="{$token|default:''|escape}">
                <div class="um-form-row">
                    <label class="um-label" for="umInviteEmail">{$LANG.emailaddress|default:'Email address'}</label>
                    <input type="email" id="umInviteEmail" name="inviteemail" class="um-input" placeholder="name@example.com" value="{$formdata.inviteemail|default:''|escape}" required>
                </div>
                <div class="um-form-row">
                    <span class="um-label">{$LANG.userManagement.permissions|default:'Permissions'}</span>
                    <label class="um-radio">
                        <input type="radio" name="permissions" value="all" checked>
                        <span>{$LANG.userManagement.allPermissions|default:'All permissions'}</span>
                    </label>
                    <label class="um-radio">
                        <input type="radio" name="permissions" value="choose">
                        <span>{$LANG.userManagement.choosePermissions|default:'Choose individual permissions'}</span>
                    </label>
                </div>
                {if isset($permissions) && $permissions|@count > 0}
                <div class="um-perms" data-um-perms hidden>
                    {foreach $permissions as $perm}
                        <label class="um-perm">
                            <input type="checkbox" name="perms[{$perm.key|escape}]" value="1">
                            <span>
                                <strong>{$perm.title|escape}</strong>
                                <span class="um-perm-desc">{$perm.description|default:''|escape}</span>
                            </span>
                        </label>
                    {/foreach}
                </div>
                {/if}
                <div class="um-form-actions">
                    <button type="submit" class="btn-primary">{$LANG.userManagement.sendInvite|default:'Send invitation'}</button>
                </div>
            </form>
        </div>

    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-users')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                {$LANG.usermanagement|default:'User Management'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                {$LANG.emailstitle|default:'Email History'}
            </a>
        </div>
    </aside>
</div>

{* Hidden POST forms for remove + cancel-invite modals *}
<form method="post" action="{routePath('account-users-remove')}" id="umRemoveForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="userid" id="umRemoveUserId">
</form>
<form method="post" action="{routePath('account-users-invite-cancel')}" id="umCancelInviteForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="inviteid" id="umCancelInviteId">
</form>

<script>{literal}
(function(){
    // Toggle individual-permissions section when "choose" radio is selected
    var permsWrap = document.querySelector('[data-um-perms]');
    document.querySelectorAll('input[name="permissions"]').forEach(function(r){
        r.addEventListener('change', function(){
            if (permsWrap) permsWrap.hidden = (r.value !== 'choose');
        });
    });
    // Remove-user confirm + submit
    document.querySelectorAll('[data-um-remove]').forEach(function(b){
        b.addEventListener('click', function(){
            var id = b.getAttribute('data-um-remove');
            if (!confirm('Remove this user’s access to your account?')) return;
            document.getElementById('umRemoveUserId').value = id;
            document.getElementById('umRemoveForm').submit();
        });
    });
    // Cancel-invite confirm + submit
    document.querySelectorAll('[data-um-cancel-invite]').forEach(function(b){
        b.addEventListener('click', function(){
            var id = b.getAttribute('data-um-cancel-invite');
            if (!confirm('Cancel this pending invitation?')) return;
            document.getElementById('umCancelInviteId').value = id;
            document.getElementById('umCancelInviteForm').submit();
        });
    });
})();
{/literal}</script>
