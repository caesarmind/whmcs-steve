{* =========================================================================
   two-factor-challenge.tpl — post-login 2FA prompt.
   Renders the module-provided challenge ($challenge) or a backup-code form.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card">
        <h1 class="auth-title">{lang key='twofactorauth'}</h1>

        {include file="$template/includes/flashmessage.tpl" align="center"}

        {if $newbackupcode}
            {include file="$template/includes/alert.tpl" type="success" msg="{lang key='twofabackupcodereset'}" textcenter=true}
        {elseif $incorrect}
            {include file="$template/includes/alert.tpl" type="error" msg="{lang key='twofa2ndfactorincorrect'}" textcenter=true}
        {elseif $error}
            {include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}
        {else}
            {include file="$template/includes/alert.tpl" type="warning" msg="{lang key='twofa2ndfactorreq'}" textcenter=true}
        {/if}

        <form method="post" action="{routePath('login-two-factor-challenge-verify')}" id="frmTwoFactorChallenge" class="auth-form{if $usingBackup} w-hidden{/if}">
            {$challenge}
        </form>

        <form method="post" action="{routePath('login-two-factor-challenge-backup-verify')}" id="frmTwoFactorBackup" class="auth-form{if !$usingBackup} w-hidden{/if}">
            <div class="form-group">
                <label for="twofabackupcode" class="form-label">{lang key='twofabackupcodelogin'}</label>
                <input type="text" name="twofabackupcode" id="twofabackupcode" class="form-input" autofocus>
            </div>
            <button type="submit" class="btn btn-primary btn-lg btn-full" id="btnLogin">{lang key='loginbutton'}</button>
            <a href="#" class="btn btn-secondary btn-lg btn-full" id="backupCodeCancel">{lang key='cancel'}</a>
        </form>

        <div class="auth-footer" id="frmTwoFactorChallengeFooter">
            <small>{lang key='twofacantaccess2ndfactor'}</small>
            <a href="#" id="loginWithBackupCode" class="auth-link">{lang key='twofaloginusingbackupcode'}</a>
        </div>
    </div>
</div>

<script>
    jQuery(document).ready(function() {
        jQuery('#loginWithBackupCode').click(function(e) {
            e.preventDefault();
            jQuery('#frmTwoFactorChallenge').hide();
            jQuery('#frmTwoFactorChallengeFooter').hide();
            jQuery('#frmTwoFactorBackup').show();
        });
        jQuery('#backupCodeCancel').click(function(e) {
            e.preventDefault();
            jQuery('#frmTwoFactorChallenge').show();
            jQuery('#frmTwoFactorChallengeFooter').show();
            jQuery('#frmTwoFactorBackup').hide();
        });
    });
</script>
