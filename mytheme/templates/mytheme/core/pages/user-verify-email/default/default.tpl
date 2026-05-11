{* Hostnodes — Email Verification result (Apple-style).

   WHMCS standard variables on /verify-email:
     $success  — bool, verification succeeded
     $expired  — bool, the token expired
     $loggedin — bool, request was made by a logged-in user
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-verify-email.css?v={$myTheme.version|default:'1.0'}">

<div class="uve-wrap">
    <div class="card uve-card">
        {if $success}
            <div class="uve-ico uve-ico-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailverification_success|default:'Email verified'}</h1>
            <p class="uve-sub">{$LANG.emailverification_success_sub|default:"Your email address is confirmed. You're all set."}</p>
        {elseif $expired}
            <div class="uve-ico uve-ico-warn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailverification_expired|default:'Verification link expired'}</h1>
            <p class="uve-sub">{$LANG.emailverification_expired_sub|default:'This verification link is no longer valid. Sign in to request a fresh one.'}</p>
            {if $loggedin}
            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=verify-email-resend" class="uve-action">
                <button type="submit" class="btn-secondary">{$LANG.resendemail|default:'Resend verification email'}</button>
            </form>
            {/if}
        {else}
            <div class="uve-ico uve-ico-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailverification_notfound|default:'Verification link not found'}</h1>
            <p class="uve-sub">{$LANG.emailverification_notfound_sub|default:"We couldn't find this verification request. It may have been completed already, or the link is malformed."}</p>
        {/if}

        <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary uve-cta">
            {$LANG.continuetoclientarea|default:'Continue to client area'}
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
</div>
