{* Hostnodes — Change Password (Apple-style).

   WHMCS standard variables (templatefile user-password / changepassword):
     $clientsdetails  — for the page eyebrow (email)
     $token           — CSRF token, required on POST
     $errormessage    — array/string of validation errors
     $successful      — bool, password was changed
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-password.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <h1>{$LANG.clientareanavchangepassword|default:'Change password'}</h1>
    <p class="page-subtitle">{$LANG.changepasswordsub|default:'Pick a strong new password — minimum 8 characters with mixed case and numbers.'}</p>
</header>

<div class="cp-split">

    {* ══ LEFT: Profile sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=changepw" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                {$LANG.clientareanavchangepassword|default:'Change Password'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security Settings'}
            </a>
        </div>
    </aside>

    {* ══ RIGHT: form ══ *}
    <div class="cp-main">
        <div class="card cp-card">
            {if !empty($successful)}
            <div class="cp-alert cp-alert-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                {$LANG.changessavedsuccessfully|default:'Password updated successfully.'}
            </div>
            {/if}

            {if isset($errormessage) && $errormessage}
            <div class="cp-alert cp-alert-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
            </div>
            {/if}

            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=changepw" class="cp-form">
                <input type="hidden" name="token" value="{$token|default:''|escape}">

                <div class="cp-form-row">
                    <label class="cp-form-label" for="cp-existing">{$LANG.currentpassword|default:'Current password'}</label>
                    <input type="password" class="cp-input" id="cp-existing" name="existingpw" autocomplete="current-password" required autofocus>
                </div>

                <div class="cp-form-row">
                    <label class="cp-form-label" for="cp-new">{$LANG.newpassword|default:'New password'}</label>
                    <input type="password" class="cp-input" id="cp-new" name="newpw" autocomplete="new-password" required>
                    <div class="cp-strength" data-strength-wrap>
                        <div class="cp-strength-bar"><div class="cp-strength-fill" data-strength-fill></div></div>
                        <span class="cp-strength-label" data-strength-label>{$LANG.pwstrength|default:'Password strength'}</span>
                    </div>
                </div>

                <div class="cp-form-row">
                    <label class="cp-form-label" for="cp-confirm">{$LANG.confirmnewpassword|default:'Confirm new password'}</label>
                    <input type="password" class="cp-input" id="cp-confirm" name="confirmpw" autocomplete="new-password" required>
                    <div class="cp-match" data-match-msg></div>
                </div>

                <div class="cp-actions">
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                    <button type="submit" class="btn-primary">{$LANG.changepassword|default:'Change password'}</button>
                </div>
            </form>
        </div>
    </div>

</div>

<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
    var newPw = document.getElementById('cp-new');
    var confirmPw = document.getElementById('cp-confirm');
    var strengthFill = document.querySelector('[data-strength-fill]');
    var strengthLabel = document.querySelector('[data-strength-label]');
    var matchMsg = document.querySelector('[data-match-msg]');

    function scorePassword(pw) {
        var score = 0;
        if (!pw) return 0;
        if (pw.length >= 8) score++;
        if (pw.length >= 12) score++;
        if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) score++;
        if (/\d/.test(pw)) score++;
        if (/[^A-Za-z0-9]/.test(pw)) score++;
        return Math.min(score, 4);
    }

    function updateStrength() {
        if (!newPw || !strengthFill) return;
        var s = scorePassword(newPw.value);
        var pct = (s / 4) * 100;
        strengthFill.style.width = pct + '%';
        var labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];
        var levels = ['weak', 'weak', 'fair', 'good', 'strong'];
        strengthFill.className = 'cp-strength-fill ' + 'cp-strength-' + (levels[s] || 'weak');
        if (strengthLabel) strengthLabel.textContent = labels[s] || labels[0];
    }

    function checkMatch() {
        if (!confirmPw || !matchMsg || !newPw) return;
        if (!confirmPw.value) {
            matchMsg.textContent = '';
            matchMsg.className = 'cp-match';
            return;
        }
        if (newPw.value === confirmPw.value) {
            matchMsg.textContent = 'Passwords match';
            matchMsg.className = 'cp-match cp-match-ok';
        } else {
            matchMsg.textContent = 'Passwords do not match';
            matchMsg.className = 'cp-match cp-match-bad';
        }
    }

    if (newPw) newPw.addEventListener('input', function () { updateStrength(); checkMatch(); });
    if (confirmPw) confirmPw.addEventListener('input', checkMatch);
});
{/literal}
</script>
