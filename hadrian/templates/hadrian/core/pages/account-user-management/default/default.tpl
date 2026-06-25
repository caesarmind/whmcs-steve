{* Hostnodes — User Management (Apple-style), Lagom-parity UX.

   WHMCS v9 data (verified against Nexus + Lagom):
     $users        — Eloquent Collection of WHMCS\User\User models
                     properties: id, email, firstname, lastname
                     pivot:      owner (bool), hasLastLogin(), getLastLogin() (Carbon)
                     methods:    hasTwoFactorAuthEnabled()
     $invites      — Eloquent Collection of pending invites (id, email, created_at)
     $permissions  — array of permission options ( .key, .title, .description )
     $formdata     — pre-filled invite-form data ($formdata.inviteemail)
     $token        — CSRF token

   UX (matches Lagom):
     · "Invite new user" button opens a MODAL where the whole invite happens.
     · A "Pending invites" list shows invitations awaiting acceptance (resend / cancel).

   Do NOT read isOwner as a property — v9 makes that a relationship method that
   needs an argument; use the pivot field $user->pivot->owner instead.
*}

{assign var=usCount value=0}
{if isset($users)}{assign var=usCount value=$users->count()}{/if}
{assign var=invCount value=0}
{if isset($invites)}{assign var=invCount value=$invites->count()}{/if}

{* Capture the flash once (it's consumed on read). A failed invite re-renders with
   $formdata.inviteemail set — in that case auto-open the modal and show the error
   inside it; otherwise show the flash at the top of the page. *}
{if $umFlash = get_flash_message()}{/if}
{assign var=umAutoOpen value=false}
{if isset($formdata.inviteemail) && $formdata.inviteemail}{assign var=umAutoOpen value=true}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-user-management.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{if $usCount > 0 || $invCount > 0}full{else}empty{/if}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <h1>{$LANG.usermanagement|default:'User Management'}</h1>
            <p class="page-subtitle">{$hadrianLang.account.userManagementSub}</p>
        </div>
        <button type="button" class="um-invite-btn" data-um-invite-open>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.userManagement.inviteNewUser}
        </button>
    </div>
</header>

<div class="um-split">
    <div class="um-main">

        {if $umFlash && !$umAutoOpen}
            <div class="um-alert um-alert-{if $umFlash.type == 'error'}error{elseif $umFlash.type == 'success'}success{elseif $umFlash.type == 'warning'}warn{else}info{/if}">
                {$umFlash.text}
            </div>
        {/if}

        {* ── Users with access ── *}
        <div class="um-list">
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
                            {if $isOwner}<span class="um-tag um-tag-owner">{$LANG.clientOwner}</span>{/if}
                        </div>
                        <div class="um-row-sub">
                            {$user->email|default:''|escape}
                            {if $user->hasTwoFactorAuthEnabled()}
                                <span class="um-2fa" title="{$LANG.twoFactor.enabled}">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                </span>
                            {/if}
                        </div>
                        {if isset($user->pivot)}
                            <div class="um-row-meta-extra">
                                {$LANG.userManagement.lastLogin}:
                                {if $user->pivot->hasLastLogin()}{$user->pivot->getLastLogin()->diffForHumans()}{else}{$LANG.never}{/if}
                            </div>
                        {/if}
                    </div>
                    <div class="um-row-actions">
                        <a href="{if $isOwner}#{else}{routePath('account-users-permissions', $user->id)}{/if}" class="um-row-btn{if $isOwner} um-row-btn-disabled{/if}"{if $isOwner} aria-disabled="true"{/if}>
                            {$LANG.userManagement.managePermissions}
                        </a>
                        {if !$isOwner}
                            <button type="button" class="um-row-btn um-row-btn-danger" data-um-remove="{$user->id|escape}">{$LANG.userManagement.removeAccess}</button>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>

        {* ── Pending invites (#1) ── *}
        {if $invCount > 0}
        <div class="um-list um-pending">
            <div class="um-section-label">{$LANG.userManagement.pendingInvites}</div>
            {foreach $invites as $invite}
                <div class="um-row um-row-invite">
                    <div class="um-row-avatar um-row-avatar-pending">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    </div>
                    <div class="um-row-meta">
                        <div class="um-row-name">{$invite->email|default:''|escape} <span class="um-tag um-tag-invited">{$hadrianLang.account.invitePending}</span></div>
                        <div class="um-row-sub">
                            {$LANG.userManagement.inviteSent}
                            {if isset($invite->created_at)}{$invite->created_at->diffForHumans()}{/if}
                        </div>
                    </div>
                    <div class="um-row-actions">
                        <form method="post" action="{routePath('account-users-invite-resend')}" style="display:inline">
                            <input type="hidden" name="token" value="{$token|default:''|escape}">
                            <input type="hidden" name="inviteid" value="{$invite->id|escape}">
                            <button type="submit" class="um-row-btn">{$LANG.userManagement.resendInvite}</button>
                        </form>
                        <button type="button" class="um-row-btn um-row-btn-danger" data-um-cancel-invite="{$invite->id|escape}">{$LANG.userManagement.cancelInvite}</button>
                    </div>
                </div>
            {/foreach}
        </div>
        {/if}

        <p class="um-footnote">* {$LANG.userManagement.accountOwnerPermissionsInfo}</p>

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
                {$LANG.paymentMethods.title}
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

{* ── Invite-new-user modal (#2) — the whole invite happens here ── *}
<div class="um-modal" id="umInviteModal" hidden{if $umAutoOpen} data-um-autoopen="1"{/if} role="dialog" aria-modal="true" aria-labelledby="umInviteTitle">
    <div class="um-modal-backdrop" data-um-close></div>
    <div class="um-modal-dialog" role="document">
        <form method="post" action="{routePath('account-users-invite')}" class="um-modal-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <div class="um-modal-head">
                <h2 class="um-modal-title" id="umInviteTitle">{$LANG.userManagement.inviteNewUser}</h2>
                <button type="button" class="um-modal-x" data-um-close aria-label="{$LANG.close}">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>
            <div class="um-modal-body">
                {if $umFlash && $umAutoOpen}
                    <div class="um-alert um-alert-{if $umFlash.type == 'error'}error{elseif $umFlash.type == 'success'}success{elseif $umFlash.type == 'warning'}warn{else}info{/if}">
                        {$umFlash.text}
                    </div>
                {/if}
                <p class="um-invite-sub">{$LANG.userManagement.inviteNewUserDescription}</p>
                <div class="um-form-row">
                    <label class="um-label" for="umInviteEmail">{$LANG.userManagement.emailAddress}</label>
                    <input type="email" id="umInviteEmail" name="inviteemail" class="um-input" placeholder="name@example.com" value="{$formdata.inviteemail|default:''|escape}" required>
                </div>
                <div class="um-form-row">
                    <span class="um-label">{$LANG.userManagement.permissions}</span>
                    <label class="um-radio">
                        <input type="radio" name="permissions" value="all" checked>
                        <span>{$LANG.userManagement.allPermissions}</span>
                    </label>
                    <label class="um-radio">
                        <input type="radio" name="permissions" value="choose">
                        <span>{$LANG.userManagement.choosePermissions}</span>
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
            </div>
            <div class="um-modal-foot">
                <button type="button" class="btn-secondary" data-um-close>{$LANG.cancel}</button>
                <button type="submit" class="btn-primary">{$LANG.userManagement.sendInvite}</button>
            </div>
        </form>
    </div>
</div>

{* Hidden POST forms for remove + cancel-invite confirmations *}
<form method="post" action="{routePath('account-users-remove')}" id="umRemoveForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="userid" id="umRemoveUserId">
</form>
<form method="post" action="{routePath('account-users-invite-cancel')}" id="umCancelInviteForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="inviteid" id="umCancelInviteId">
</form>

<script>
var _localLang = {
    'removeAccessSure': '{$LANG.userManagement.removeAccessSure|escape:"javascript"}',
    'cancelInviteSure': '{$LANG.userManagement.cancelInviteSure|escape:"javascript"}'
};
</script>
<script>{literal}
(function () {
    /* ── Invite modal open/close ── */
    var modal = document.getElementById('umInviteModal');
    function openModal() {
        if (!modal) return;
        modal.hidden = false;
        document.body.classList.add('um-modal-open');
        var f = document.getElementById('umInviteEmail');
        if (f) { f.focus(); }
    }
    function closeModal() {
        if (!modal) return;
        modal.hidden = true;
        document.body.classList.remove('um-modal-open');
    }
    var openers = document.querySelectorAll('[data-um-invite-open]');
    for (var i = 0; i < openers.length; i++) {
        openers[i].addEventListener('click', function (e) { e.preventDefault(); openModal(); });
    }
    if (modal) {
        var closers = modal.querySelectorAll('[data-um-close]');
        for (var c = 0; c < closers.length; c++) { closers[c].addEventListener('click', closeModal); }
        if (modal.getAttribute('data-um-autoopen') === '1') { openModal(); }
    }
    document.addEventListener('keydown', function (e) {
        if ((e.key === 'Escape' || e.keyCode === 27) && modal && !modal.hidden) { closeModal(); }
    });

    /* ── Toggle individual-permissions list when "choose" is selected ── */
    var permsWrap = document.querySelector('[data-um-perms]');
    var radios = document.querySelectorAll('input[name="permissions"]');
    for (var r = 0; r < radios.length; r++) {
        radios[r].addEventListener('change', function () {
            if (permsWrap) { permsWrap.hidden = (document.querySelector('input[name="permissions"]:checked') || {}).value !== 'choose'; }
        });
    }

    /* ── Remove-user confirm + submit ── */
    var rm = document.querySelectorAll('[data-um-remove]');
    for (var m = 0; m < rm.length; m++) {
        rm[m].addEventListener('click', function () {
            var id = this.getAttribute('data-um-remove');
            if (!confirm(_localLang.removeAccessSure)) { return; }
            document.getElementById('umRemoveUserId').value = id;
            document.getElementById('umRemoveForm').submit();
        });
    }

    /* ── Cancel-invite confirm + submit ── */
    var ci = document.querySelectorAll('[data-um-cancel-invite]');
    for (var k = 0; k < ci.length; k++) {
        ci[k].addEventListener('click', function () {
            var id = this.getAttribute('data-um-cancel-invite');
            if (!confirm(_localLang.cancelInviteSure)) { return; }
            document.getElementById('umCancelInviteId').value = id;
            document.getElementById('umCancelInviteForm').submit();
        });
    }
})();
{/literal}</script>
