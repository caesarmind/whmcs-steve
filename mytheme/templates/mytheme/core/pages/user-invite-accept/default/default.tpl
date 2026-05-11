{* Hostnodes — Accept Sub-User Invitation (Apple-style).

   WHMCS standard variables on /user-invite-accept:
     $invite   — invitation object: ->getClientName(), ->getSenderName(), ->token
     $loggedin — bool
     $errormessage — array/string of validation errors
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-invite-accept.css?v={$myTheme.version|default:'1.0'}">

<div class="uia-wrap">
    <div class="card uia-card">
        {if isset($invite) && $invite}
            <div class="uia-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg></div>
            <h1 class="uia-title">{$LANG.accountinvite_youhavebeen|default:"You're invited to access"} <strong>{$invite->getClientName()|escape}</strong></h1>
            <p class="uia-sub">
                {$LANG.accountinvite_givenaccess|default:'has invited you to manage their account.'|sprintf:$invite->getSenderName()|escape}
            </p>

            {if isset($errormessage) && $errormessage}
            <div class="uia-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
            {/if}

            {if $loggedin}
                <p class="uia-note">{$LANG.accountinvite_inviteacceptloggedin|default:'Sign in is confirmed — accept to add this account to your switcher.'}</p>
                <form method="post" action="{$WEB_ROOT}/user-invite-accept?token={$invite->token|escape}" class="uia-actions">
                    <button type="submit" class="btn-primary">{$LANG.accountinvite_accept|default:'Accept invitation'}</button>
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                </form>
            {else}
                <p class="uia-note">{$LANG.accountinvite_inviteacceptloggedout|default:'Sign in or create an account to accept the invitation.'}</p>
                <div class="uia-actions">
                    <a href="{$WEB_ROOT}/login" class="btn-primary">{$LANG.signin|default:'Sign in'}</a>
                    <a href="{$WEB_ROOT}/register" class="btn-secondary">{$LANG.createaccount|default:'Create account'}</a>
                </div>
            {/if}
        {else}
            <div class="uia-ico uia-ico-warn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
            <h1 class="uia-title">{$LANG.accountinvite_invalid|default:'Invitation not found'}</h1>
            <p class="uia-sub">{$LANG.accountinvite_invalidsub|default:'This invitation link is no longer valid or has already been used.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.continuetoclientarea|default:'Continue to client area'}</a>
        {/if}
    </div>
</div>
