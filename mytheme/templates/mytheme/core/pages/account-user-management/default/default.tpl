{* Hostnodes — User Management (Apple-style).

   WHMCS standard variables on /clientarea.php?action=users:
     $users / $userList    — array of users; each has id, email,
                             firstname, lastname, ownerIndicatorText
                             ("Owner"|"Invited"|"Active"), permissions
     $clientsdetails       — current account
     $errormessage         — array/string of validation errors
     $token                — CSRF token
*}

{if isset($users) && $users|@count > 0}
    {assign var=usList value=$users}
{elseif isset($userList) && $userList|@count > 0}
    {assign var=usList value=$userList}
{else}
    {assign var=usList value=[]}
{/if}
{assign var=usCount value=$usList|@count}
{if $usCount > 0}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

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
        <a href="{$WEB_ROOT}/clientarea.php?action=users&sub=invite" class="page-header-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.inviteuser|default:'Invite new user'}
        </a>
    </div>
</header>

<div class="um-split">
    <div class="um-main">

        {if isset($errormessage) && $errormessage}
        <div class="um-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <div class="when-full um-list">
            {if $usCount > 0}
                {foreach $usList as $u}
                {assign var=uName value=$u.firstname|default:''|cat:" "|cat:$u.lastname|default:''}
                {assign var=uInitial value=$u.firstname|default:$u.email|default:'?'|substr:0:1|upper}
                {assign var=uTag value=$u.ownerIndicatorText|default:$u.status|default:'Active'}
                {assign var=uTagLower value=$uTag|lower|replace:' ':'-'}
                <div class="um-row">
                    <div class="um-row-avatar">{$uInitial|escape}</div>
                    <div class="um-row-meta">
                        <div class="um-row-name">{$uName|escape}{if !empty($u.isOwner)} <span class="um-tag um-tag-owner">{$LANG.owner|default:'Owner'}</span>{/if}</div>
                        <div class="um-row-sub">{$u.email|default:''|escape}</div>
                    </div>
                    {if $uTag}
                    <span class="um-tag um-tag-{$uTagLower|escape}">{$uTag|escape}</span>
                    {/if}
                    <div class="um-row-actions">
                        {if empty($u.isOwner)}
                        <a href="{$WEB_ROOT}/clientarea.php?action=users&sub=permissions&userid={$u.id|default:''|escape}" class="um-row-btn">{$LANG.permissions|default:'Permissions'}</a>
                        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=users&sub=remove" style="display:inline" onsubmit="return confirm('{$LANG.userremoveconfirm|default:'Remove this user?'}');">
                            <input type="hidden" name="token" value="{$token|default:''|escape}">
                            <input type="hidden" name="userid" value="{$u.id|default:''|escape}">
                            <button type="submit" class="um-row-btn um-row-btn-danger">{$LANG.remove|default:'Remove'}</button>
                        </form>
                        {/if}
                    </div>
                </div>
                {/foreach}
            {/if}
        </div>

        <div class="when-empty um-empty">
            <div class="um-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg></div>
            <p class="um-empty-title">{$LANG.nousers|default:'No additional users'}</p>
            <p class="um-empty-sub">{$LANG.nouserssub|default:'You are the only person with access to this account. Invite a teammate, accountant, or developer to collaborate.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=users&sub=invite" class="btn-primary">{$LANG.inviteuser|default:'Invite new user'}</a>
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
