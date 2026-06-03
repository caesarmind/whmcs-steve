{* Hostnodes — Accept Sub-User Invitation (Apple-style), wired to the WHMCS invite flow.

   WHMCS standard variables on the invite route:
     $invite             — invitation object: ->getClientName(), ->getSenderName(), ->token
     $loggedin           — bool
     $formdata           — sticky form values (email, firstname, lastname)
     $accept_tos/$tos_url — TOS acceptance for the register form (when required)
     $captcha            — captcha object; $captchaForm (login) / $captchaFormRegister (register)
     $errormessage       — validation errors

   Flow (matches stock WHMCS / Lagom): a logged-OUT invitee signs in OR creates an
   account INLINE here, posting to the invite route so the invite is accepted and the
   account linked in one step. Linking out to register.php would lose the invite — and
   /register isn't even a valid URL (registration is register.php), which is why the old
   "Create account" link 404'd.
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-invite-accept.css?v={$myTheme.version|default:'1.0'}">

<div class="uia-wrap">
    <div class="card uia-card{if isset($invite) && $invite && !$loggedin} uia-card-wide{/if}">
        {if isset($invite) && $invite}
            <div class="uia-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg></div>
            <h1 class="uia-title">{lang key="accountInvite.youHaveBeenInvited" clientName=$invite->getClientName()}</h1>
            <p class="uia-sub">
                {lang key="accountInvite.givenAccess" senderName=$invite->getSenderName() clientName=$invite->getClientName() ot="<strong>" ct="</strong>"}
            </p>

            {if isset($errormessage) && $errormessage}
            <div class="uia-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
            {/if}

            {if $loggedin}
                {* Already signed in — one-click accept (posts to the invite route). *}
                <p class="uia-note">{$LANG.accountInvite.inviteAcceptLoggedIn}</p>
                <form method="post" action="{routePath('invite-validate', $invite->token)}" class="uia-actions">
                    {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                    <button type="submit" class="btn-primary">{$LANG.accountInvite.accept}</button>
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$LANG.cancel}</a>
                </form>
            {else}
                <p class="uia-note">{$LANG.accountInvite.inviteAcceptLoggedOut}</p>
                <div class="uia-forms">

                    {* ── Sign in ── *}
                    <div class="uia-form-card">
                        <h2 class="uia-form-title">{$LANG.login}</h2>
                        <form method="post" action="{routePath('login-validate')}" class="uia-form">
                            {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                            <div class="uia-field">
                                <label class="uia-label" for="uia-login-email">{$LANG.loginemail}</label>
                                <input type="email" id="uia-login-email" name="username" class="uia-input" value="{$formdata.email|default:''|escape}" autocomplete="email" required>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-login-pw">{$LANG.loginpassword}</label>
                                <input type="password" id="uia-login-pw" name="password" class="uia-input" autocomplete="current-password" required>
                            </div>
                            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                            <div class="form-group uia-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                            {/if}
                            <button type="submit" class="btn-primary uia-btn{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.login}</button>
                        </form>
                    </div>

                    {* ── Create account (accepts the invite) ── *}
                    <div class="uia-form-card">
                        <h2 class="uia-form-title">{$LANG.orderForm.createAccount}</h2>
                        <form method="post" action="{routePath('invite-validate', $invite->token)}" class="uia-form">
                            {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                            <div class="uia-field-row">
                                <div class="uia-field">
                                    <label class="uia-label" for="uia-fn">{$LANG.clientareafirstname}</label>
                                    <input type="text" id="uia-fn" name="firstname" class="uia-input" value="{$formdata.firstname|default:''|escape}" autocomplete="given-name" required>
                                </div>
                                <div class="uia-field">
                                    <label class="uia-label" for="uia-ln">{$LANG.clientarealastname}</label>
                                    <input type="text" id="uia-ln" name="lastname" class="uia-input" value="{$formdata.lastname|default:''|escape}" autocomplete="family-name" required>
                                </div>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-email">{$LANG.loginemail}</label>
                                <input type="email" id="uia-email" name="email" class="uia-input" value="{$formdata.email|default:''|escape}" autocomplete="email" required>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-pw">{$LANG.loginpassword}</label>
                                <input type="password" id="uia-pw" name="password" class="uia-input" autocomplete="new-password" required>
                                <div class="uia-pw-tools">
                                    <button type="button" class="uia-genpw" data-uia-genpw>
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/></svg>
                                        {$LANG.generatePassword.btnLabel}
                                    </button>
                                    <button type="button" class="uia-pw-reveal" data-uia-reveal aria-label="{$hadrianLang.account.togglePasswordVisibility}">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                    </button>
                                </div>
                                <div class="uia-pwmeter" data-uia-pwmeter hidden>
                                    <span class="uia-pwmeter-track"><span class="uia-pwmeter-fill"></span></span>
                                    <span class="uia-pwmeter-label"></span>
                                </div>
                            </div>
                            {if isset($accept_tos) && $accept_tos}
                            <label class="uia-tos">
                                <input type="checkbox" name="accept" id="uia-accept" required>
                                <span>{$LANG.ordertosagreement} <a href="{$tos_url|default:''|escape}" target="_blank" rel="noopener">{$LANG.ordertos}</a></span>
                            </label>
                            {/if}
                            {* Switch the captcha form id to the register form before its widget/button. *}
                            {if isset($captchaFormRegister)}{assign var=captchaForm value=$captchaFormRegister}{/if}
                            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                            <div class="form-group uia-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                            {/if}
                            <button type="submit" class="btn-primary uia-btn{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.orderForm.createAccount}</button>
                        </form>
                    </div>

                </div>
            {/if}
        {else}
            <div class="uia-ico uia-ico-warn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
            <h1 class="uia-title">{$LANG.accountInvite.notFound}</h1>
            <p class="uia-sub">{$hadrianLang.account.inviteInvalidSub}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.orderForm.continueToClientArea}</a>
        {/if}
    </div>
</div>

{* Create-account password helpers: "Generate password" (fills + reveals a strong
   password) and a live strength meter. Self-contained — no jQuery / WHMCS JS. *}
<script>var _localLang = {
    'pwVeryWeak': '{$hadrianLang.account.pwStrengthVeryWeak|escape:"javascript"}',
    'pwWeak': '{$hadrianLang.account.pwStrengthWeak|escape:"javascript"}',
    'pwFair': '{$hadrianLang.account.pwStrengthFair|escape:"javascript"}',
    'pwGood': '{$hadrianLang.account.pwStrengthGood|escape:"javascript"}',
    'pwStrong': '{$hadrianLang.account.pwStrengthStrong|escape:"javascript"}'
};</script>
<script>{literal}
(function () {
    var pw = document.getElementById('uia-pw');
    if (!pw) { return; }

    function randInts(n) {
        var c = window.crypto || window.msCrypto;
        if (c && c.getRandomValues) { var a = new Uint32Array(n); c.getRandomValues(a); return a; }
        var f = []; for (var i = 0; i < n; i++) { f.push(Math.floor(Math.random() * 4294967296)); } return f;
    }
    function generate(len) {
        var lo = 'abcdefghijkmnopqrstuvwxyz', up = 'ABCDEFGHJKLMNPQRSTUVWXYZ', di = '23456789', sy = '!@#$%^&*()-_=+';
        var all = lo + up + di + sy, r = randInts(len);
        var o = [lo.charAt(r[0] % lo.length), up.charAt(r[1] % up.length), di.charAt(r[2] % di.length), sy.charAt(r[3] % sy.length)];
        for (var i = 4; i < len; i++) { o.push(all.charAt(r[i] % all.length)); }
        var s = randInts(len);
        for (var j = o.length - 1; j > 0; j--) { var k = s[j] % (j + 1), t = o[j]; o[j] = o[k]; o[k] = t; }
        return o.join('');
    }

    var meter = document.querySelector('[data-uia-pwmeter]');
    var fill = meter ? meter.querySelector('.uia-pwmeter-fill') : null;
    var label = meter ? meter.querySelector('.uia-pwmeter-label') : null;
    var LABELS = [_localLang.pwVeryWeak, _localLang.pwWeak, _localLang.pwFair, _localLang.pwGood, _localLang.pwStrong];
    var CLASSES = ['vweak', 'weak', 'fair', 'good', 'strong'];
    var PCT = [16, 34, 56, 78, 100];
    function level(v) {
        var p = 0;
        if (v.length >= 8) { p++; }
        if (v.length >= 12) { p++; }
        if (/[a-z]/.test(v) && /[A-Z]/.test(v)) { p++; }
        if (/[0-9]/.test(v)) { p++; }
        if (/[^A-Za-z0-9]/.test(v)) { p++; }
        return p <= 1 ? 0 : (p >= 5 ? 4 : p - 1);
    }
    function updateMeter() {
        if (!meter) { return; }
        var v = pw.value || '';
        if (!v) { meter.hidden = true; return; }
        meter.hidden = false;
        var lv = level(v);
        meter.setAttribute('data-strength', CLASSES[lv]);
        if (fill) { fill.style.width = PCT[lv] + '%'; }
        if (label) { label.textContent = LABELS[lv]; }
    }
    pw.addEventListener('input', updateMeter);

    var genBtn = document.querySelector('[data-uia-genpw]');
    if (genBtn) {
        genBtn.addEventListener('click', function () {
            pw.value = generate(16);
            pw.type = 'text';            /* reveal so the user can note it down */
            var rb = document.querySelector('[data-uia-reveal]');
            if (rb) { rb.classList.add('is-on'); }
            updateMeter();
        });
    }
    var revealBtn = document.querySelector('[data-uia-reveal]');
    if (revealBtn) {
        revealBtn.addEventListener('click', function () {
            pw.type = (pw.type === 'password') ? 'text' : 'password';
            revealBtn.classList.toggle('is-on', pw.type === 'text');
        });
    }
})();
{/literal}</script>
