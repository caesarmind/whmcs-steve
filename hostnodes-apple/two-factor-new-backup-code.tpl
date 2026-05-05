{* =========================================================================
   two-factor-new-backup-code.tpl — shown once after regenerating a backup
   code. User is strongly encouraged to copy it somewhere safe.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card">
        <h1 class="auth-title">{lang key='twofactorauth'}</h1>

        {include file="$template/includes/alert.tpl" type="success" msg="{lang key='twofabackupcodereset'}" textcenter=true}

        <p class="text-center form-hint">{lang key='twofanewbackupcodeis'}</p>

        <div class="callout warning text-center backup-code-display">
            <code class="backup-code">{$newBackupCode}</code>
        </div>

        <p class="text-center">{lang key='twofabackupcodeexpl'}</p>

        <a href="{routePath('clientarea-home')}" class="btn btn-primary btn-lg btn-full">
            {lang key='continue'} <i class="fas fa-arrow-right"></i>
        </a>
    </div>
</div>
