{* =========================================================================
   Inner partial (step 3 — set new password).
   ========================================================================= *}
<h1 class="auth-title">{lang key='newpassword'}</h1>
<p class="auth-subtitle">{lang key='pwresetenternewpw'}</p>

<form class="auth-form using-password-strength" method="POST" action="{routePath('password-reset-change-perform')}">
    <input type="hidden" name="answer" id="answer" value="{$securityAnswer}">

    <div class="form-group" id="newPassword1">
        <label for="inputNewPassword1" class="form-label">{lang key='newpassword'}</label>
        <input type="password" name="newpw" id="inputNewPassword1" class="form-input" autocomplete="off">
    </div>

    <div class="form-group" id="newPassword2">
        <label for="inputNewPassword2" class="form-label">{lang key='confirmnewpassword'}</label>
        <input type="password" name="confirmpw" id="inputNewPassword2" class="form-input" autocomplete="off">
        <div id="inputNewPassword2Msg"></div>
    </div>

    <div class="form-group">
        <label class="form-label">{lang key='pwstrength'}</label>
        {include file="$template/includes/pwstrength.tpl" maximumPasswordLength=$maximumPasswordLength}
    </div>

    <div class="btn-group">
        <button type="submit" name="submit" class="btn btn-primary btn-lg">{lang key='clientareasavechanges'}</button>
        <button type="reset" class="btn btn-secondary btn-lg">{lang key='cancel'}</button>
    </div>
</form>
