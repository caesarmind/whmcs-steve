{* Hostnodes — Email Verification result (Apple-style).

   WHMCS standard variables on /verify-email:
     $success  — bool, verification succeeded
     $expired  — bool, the token expired
     $loggedin — bool, request was made by a logged-in user
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-verify-email.css?v={$hadrian.version|default:'1.0'}">

<div class="uve-wrap">
    <div class="card uve-card">
        {if $success}
            <div class="uve-ico uve-ico-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailVerification.success}</h1>
            <p class="uve-sub">{$hadrianLang.account.emailVerifiedSub}</p>
        {elseif $expired}
            <div class="uve-ico uve-ico-warn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailVerification.expired}</h1>
            <p class="uve-sub">{$LANG.emailVerification.loginToRequest}</p>
            {if $loggedin}
            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=verify-email-resend" class="uve-action">
                <button type="submit" class="btn-secondary">{$LANG.resendEmail}</button>
            </form>
            {/if}
        {else}
            <div class="uve-ico uve-ico-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            </div>
            <h1 class="uve-title">{$LANG.emailVerification.notFound}</h1>
            <p class="uve-sub">{$hadrianLang.account.emailNotFoundSub}</p>
        {/if}

        <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary uve-cta">
            {$LANG.orderForm.continueToClientArea}
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
</div>
