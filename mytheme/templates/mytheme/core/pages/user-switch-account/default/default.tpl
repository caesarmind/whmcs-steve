{* Hostnodes — Switch Account (Apple-style).

   WHMCS standard variables on /clientarea.php?action=switchaccount:
     $accounts / $accountList  — array, each: id, name, email,
                                  companyname, isActive
     $currentAccountId         — the account currently in session
     $token                    — CSRF token
     $errormessage             — array/string of validation errors
*}

{if isset($accounts) && $accounts|@count > 0}
    {assign var=swList value=$accounts}
{elseif isset($accountList) && $accountList|@count > 0}
    {assign var=swList value=$accountList}
{else}
    {assign var=swList value=[]}
{/if}
{assign var=swCount value=$swList|@count}
{if $swCount > 0}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-switch-account.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <h1>{$LANG.switchaccount|default:'Switch account'}</h1>
    <p class="page-subtitle">{$LANG.switchaccountsub|default:'Pick the account you want to manage.'}</p>
</header>

<div class="sw-split">
    <div class="sw-main">

        {if isset($errormessage) && $errormessage}
        <div class="sw-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <div class="when-full sw-list">
            {if $swCount > 0}
                {foreach $swList as $a}
                {assign var=swIsCurrent value=isset($currentAccountId) && $currentAccountId == $a.id}
                {assign var=swName value=$a.name|default:''|cat:''}
                {if !$swName}{assign var=swName value="`$a.firstname|default:''` `$a.lastname|default:''`"}{/if}
                {assign var=swInitial value=$swName|default:$a.email|default:'?'|substr:0:1|upper}
                <div class="sw-row{if $swIsCurrent} sw-row-current{/if}">
                    <div class="sw-row-avatar">{$swInitial|escape}</div>
                    <div class="sw-row-meta">
                        <div class="sw-row-name">{$swName|escape}{if $swIsCurrent} <span class="sw-tag-current">{$LANG.currentaccount|default:'Current'}</span>{/if}</div>
                        <div class="sw-row-sub">
                            {if !empty($a.companyname)}{$a.companyname|escape} · {/if}{$a.email|default:''|escape}
                        </div>
                    </div>
                    <div class="sw-row-action">
                        {if $swIsCurrent}
                            <span class="sw-row-btn sw-row-btn-disabled">{$LANG.signedin|default:'Signed in'}</span>
                        {else}
                            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=switchaccount" style="display:inline">
                                <input type="hidden" name="token" value="{$token|default:''|escape}">
                                <input type="hidden" name="accountid" value="{$a.id|escape}">
                                <button type="submit" class="sw-row-btn">{$LANG.switchto|default:'Switch to'}</button>
                            </form>
                        {/if}
                    </div>
                </div>
                {/foreach}
            {/if}
        </div>

        <div class="when-empty sw-empty">
            <div class="sw-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg></div>
            <p class="sw-empty-title">{$LANG.nootheraccounts|default:'Only one account on this login'}</p>
            <p class="sw-empty-sub">{$LANG.nootheraccountssub|default:'You only have access to a single client account at the moment. Once someone invites you to another account, you can switch between them here.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.continuetoclientarea|default:'Continue to client area'}</a>
        </div>

    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{$WEB_ROOT}/account/profile" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                {$LANG.yourprofile|default:'Your Profile'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=switchaccount" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                {$LANG.switchaccount|default:'Switch Account'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=changepw" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                {$LANG.clientareanavchangepassword|default:'Change Password'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security Settings'}
            </a>
        </div>
    </aside>
</div>
