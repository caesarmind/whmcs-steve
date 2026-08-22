{* Hostnodes — Password Reset, wired to WHMCS's ROUTED reset flow.

   WHMCS renders the `password-reset-container` shell template and exposes:
     $innerTemplate    — current step: 'email-prompt' | 'security-prompt' | 'change-prompt'
     $successMessage   — set after a step succeeds (e.g. the "check your email"
                         confirmation, or "password changed"); $successTitle is its heading
     $errorMessage     — validation error for the current step
     $loggedin         — bool; password reset isn't allowed while signed in
     $securityQuestion — the security question text (security-prompt step)
     $securityAnswer   — carried into the change-prompt step as a hidden field
     $captcha / $showCaptchaAfterLimit / $captchaForm — captcha shown after repeated attempts

   Each step POSTs to a WHMCS route via routePath(). The legacy pwreset.php entry
   (templatefile 'pwreset', which sets no $innerTemplate) falls through to the email
   step, whose form posts into the routed flow — so both entry points work.

   NOTE: the container/step dispatchers all forward here, so we render every step
   INLINE off $innerTemplate (including a step tpl here would recurse). *}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/pwreset.css?v={$hadrian.version|default:'1.0'}">

{assign var=pwStep value=$innerTemplate|default:'email-prompt'}

<div class="pw-wrap">
    <div class="card pw-card">

        {if $loggedin && isset($innerTemplate) && $innerTemplate}
            {* WHMCS blocks password reset while signed in. *}
            <div class="pw-error" role="alert">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <div>{$LANG.noPasswordResetWhenLoggedIn}</div>
            </div>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary pw-cta">{$LANG.clientareanavhome|default:'Go to dashboard'}</a>

        {elseif isset($successMessage) && $successMessage}
            {* Success — "check your email" after step 1, or "password changed" at the end. *}
            <div class="pw-ico pw-ico-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <h1 class="pw-title">{if isset($successTitle) && $successTitle}{$successTitle|strip_tags}{else}{$hadrianLang.auth.pwresetCheckEmailTitle}{/if}</h1>
            <p class="pw-sub">{$successMessage|strip_tags}</p>
            <a href="{$WEB_ROOT}/login" class="btn-primary pw-cta">{$hadrianLang.auth.backToLogin}</a>

        {else}
            {if isset($errorMessage) && $errorMessage}
            <div class="pw-error" role="alert">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <div>{$errorMessage|strip_tags}</div>
            </div>
            {/if}

            {if $pwStep == 'security-prompt'}
                {* ── Step 2: security question ── *}
                <h1 class="pw-title">{$hadrianLang.auth.pwresetSecurityTitle}</h1>
                <p class="pw-sub">{$LANG.pwresetsecurityquestionrequired}</p>
                <form method="post" action="{routePath('password-reset-security-verify')}" class="pw-form">
                    {if isset($securityQuestion) && $securityQuestion}
                    <div class="pw-question">{$securityQuestion|escape}</div>
                    {/if}
                    <div class="form-group">
                        <label class="form-label" for="pw-answer">{$hadrianLang.auth.yourAnswer}</label>
                        <input type="text" class="form-input" id="pw-answer" name="answer" autocomplete="off" required autofocus>
                    </div>
                    <button type="submit" class="btn-primary pw-submit">{$LANG.pwresetsubmit}</button>
                </form>

            {elseif $pwStep == 'change-prompt'}
                {* ── Step 3: new password ── *}
                <h1 class="pw-title">{$hadrianLang.auth.pwresetNewTitle}</h1>
                <p class="pw-sub">{$LANG.pwresetenternewpw}</p>
                <form method="post" action="{routePath('password-reset-change-perform')}" class="pw-form">
                    <input type="hidden" name="answer" value="{$securityAnswer|default:''|escape}">
                    <div class="form-group">
                        <label class="form-label" for="pw-new1">{$LANG.newpassword}</label>
                        <input type="password" class="form-input" id="pw-new1" name="newpw" autocomplete="new-password" required autofocus>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="pw-new2">{$LANG.confirmnewpassword}</label>
                        <input type="password" class="form-input" id="pw-new2" name="confirmpw" autocomplete="new-password" required>
                    </div>
                    <button type="submit" name="submit" class="btn-primary pw-submit">{$LANG.clientareasavechanges}</button>
                </form>

            {else}
                {* ── Step 1: email entry (also the legacy pwreset.php landing) ── *}
                <h1 class="pw-title">{$LANG.pwreset}</h1>
                <p class="pw-sub">{$LANG.pwresetemailneeded}</p>
                <form method="post" action="{routePath('password-reset-validate-email')}" class="pw-form">
                    <input type="hidden" name="action" value="reset">
                    <div class="form-group">
                        <label class="form-label" for="pw-email">{$LANG.loginemail}</label>
                        <input type="email" class="form-input" id="pw-email" name="email" value="{$email|default:''|escape}" autocomplete="email" required autofocus>
                    </div>
                    {* Captcha only kicks in after repeated attempts ($showCaptchaAfterLimit). *}
                    {if isset($captcha) && $captcha && $captcha->isEnabled() && (isset($showCaptchaAfterLimit) && $showCaptchaAfterLimit) && $captcha->isEnabledForForm($captchaForm)}
                    <div class="form-group pw-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                    {/if}
                    <button type="submit" class="btn-primary pw-submit{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.pwresetsubmit}</button>
                </form>
                <p class="pw-altlink"><a href="{$WEB_ROOT}/login">{$hadrianLang.auth.backToLogin}</a></p>
            {/if}

        {/if}

    </div>
</div>
