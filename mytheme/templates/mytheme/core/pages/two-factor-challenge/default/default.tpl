{* Hostnodes — Two-Factor Authentication Challenge (Apple-style).

   WHMCS standard variables on /login/twofactor:
     $challenge      — raw HTML widget WHMCS renders for the primary 2FA method
                       (TOTP input, push notification status, etc.)
     $usingBackup    — bool, user toggled the backup-code flow
     $incorrect      — bool, last submitted code was wrong
     $newbackupcode  — bool, user just consumed a backup code and got new ones
     $error          — string error message (if any)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/two-factor-challenge.css?v={$myTheme.version|default:"1.0"}">

<div class="tfac-wrap">
    <div class="card tfac-card">
        <div class="tfac-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
        <h1 class="tfac-title">{$LANG.twofactorauth}</h1>

        {if $newbackupcode}
            <div class="tfac-alert tfac-alert-success">{$LANG.twofabackupcodereset}</div>
        {elseif $incorrect}
            <div class="tfac-alert tfac-alert-error">{$LANG.twofa2ndfactorincorrect}</div>
        {elseif isset($error) && $error}
            <div class="tfac-alert tfac-alert-error">{$error|strip_tags|escape}</div>
        {else}
            <p class="tfac-sub">{$LANG.twofa2ndfactorreq}</p>
        {/if}

        <form method="post" id="frmTwoFactorChallenge" class="tfac-form{if $usingBackup} tfac-hidden{/if}">
            <div class="tfac-challenge">{$challenge}</div>
        </form>

        <form method="post" id="frmTwoFactorBackup" class="tfac-form{if !$usingBackup} tfac-hidden{/if}">
            <label class="form-label" for="tfac-backup">{$LANG.twofabackupcodelogin}</label>
            <input type="text" name="twofabackupcode" id="tfac-backup" class="form-input tfac-backup-input" placeholder="{$hadrianLang.auth.backupCodePlaceholder}" autocomplete="one-time-code">
            <button type="submit" class="btn-primary tfac-submit">{$LANG.loginbutton}</button>
        </form>

        <div class="tfac-foot">
            <button type="button" id="tfacToggle" class="tfac-link">
                {if $usingBackup}{$hadrianLang.auth.useTotpInstead}{else}{$hadrianLang.auth.useBackupCode}{/if}
            </button>
        </div>
    </div>
</div>

<script>var _localLang = { useBackupCode: '{$hadrianLang.auth.useBackupCode|escape:"javascript"}', useTotpInstead: '{$hadrianLang.auth.useTotpInstead|escape:"javascript"}' };</script>
<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.getElementById('tfacToggle');
    var fChallenge = document.getElementById('frmTwoFactorChallenge');
    var fBackup    = document.getElementById('frmTwoFactorBackup');
    if (!toggle || !fChallenge || !fBackup) return;
    toggle.addEventListener('click', function () {
        var usingBackup = !fBackup.classList.contains('tfac-hidden');
        fBackup.classList.toggle('tfac-hidden', usingBackup);
        fChallenge.classList.toggle('tfac-hidden', !usingBackup);
        toggle.textContent = usingBackup ? _localLang.useBackupCode : _localLang.useTotpInstead;
    });
});
{/literal}
</script>
