{* =========================================================================
   user-password.tpl — change user password.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='userSecurity.changePassword'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body">
        <form class="using-password-strength" method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="token" value="{$token}">

            <div class="form-group">
                <label for="inputCurrentPassword" class="form-label">{lang key='existingpw'}</label>
                <input type="password" name="existingpw" id="inputCurrentPassword" class="form-input" autocomplete="current-password">
            </div>
            <div class="form-group" id="newPassword1">
                <label for="inputNewPassword1" class="form-label">{lang key='newpassword'}</label>
                <input type="password" name="newpw" id="inputNewPassword1" class="form-input" autocomplete="new-password">
                {include file="$template/includes/pwstrength.tpl"}
            </div>
            <div class="form-group" id="newPassword2">
                <label for="inputNewPassword2" class="form-label">{lang key='confirmnewpassword'}</label>
                <input type="password" name="confirmpw" id="inputNewPassword2" class="form-input" autocomplete="new-password">
                <div id="inputNewPassword2Msg"></div>
            </div>
            <div class="btn-group">
                <button type="button" class="btn btn-secondary generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">{lang key='generatePassword.btnLabel'}</button>
                <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
            </div>
        </form>
    </div>
</div>
