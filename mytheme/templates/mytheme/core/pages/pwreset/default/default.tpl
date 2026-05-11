{* Hostnodes — Password Reset (Apple-style).

   WHMCS routes /pwreset through four templatefiles in sequence:
     password-reset-container       — landing / status wrapper
     password-reset-email-prompt    — step 1: enter your email
     password-reset-security-prompt — step 2: answer security question
     password-reset-change-prompt   — step 3: enter new password

   This single tpl handles all four by branching on $templatefile.

   WHMCS standard variables across the flow:
     $email                  — email entered in step 1
     $verifyhash             — token carried through subsequent steps
     $securityquestion       — text of the security question (step 2)
     $errormessage           — array/string of validation errors
     $passwordresetstatus    — set on the container page after success
     $captcha                — captcha widget if enabled
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/pwreset.css?v={$myTheme.version|default:'1.0'}">

{assign var=pwStep value=$templatefile|default:'password-reset-email-prompt'}

<div class="pw-wrap">
    <div class="card pw-card">

        {* Step indicator *}
        {if $pwStep != 'password-reset-container'}
        <div class="pw-steps">
            <span class="pw-step{if $pwStep == 'password-reset-email-prompt'} pw-step-active{elseif $pwStep == 'password-reset-security-prompt' || $pwStep == 'password-reset-change-prompt'} pw-step-done{/if}">1</span>
            <span class="pw-step-bar"></span>
            <span class="pw-step{if $pwStep == 'password-reset-security-prompt'} pw-step-active{elseif $pwStep == 'password-reset-change-prompt'} pw-step-done{/if}">2</span>
            <span class="pw-step-bar"></span>
            <span class="pw-step{if $pwStep == 'password-reset-change-prompt'} pw-step-active{/if}">3</span>
        </div>
        {/if}

        {if isset($errormessage) && $errormessage}
        <div class="pw-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        </div>
        {/if}

        {if $pwStep == 'password-reset-container'}
            {* Landing — usually post-submit success page *}
            <div class="pw-ico pw-ico-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <h1 class="pw-title">{$LANG.pwresetcheckemailtitle|default:'Check your email'}</h1>
            <p class="pw-sub">{$LANG.pwresetcheckemailsub|default:'If an account matches the email you entered, we have just sent it a password reset link. Follow the link to continue.'}</p>
            <a href="{$WEB_ROOT}/login" class="btn-primary pw-cta">{$LANG.backtologin|default:'Back to sign in'}</a>

        {elseif $pwStep == 'password-reset-email-prompt'}
            {* Step 1 — email entry *}
            <h1 class="pw-title">{$LANG.pwresettitle|default:'Reset your password'}</h1>
            <p class="pw-sub">{$LANG.pwresetsub|default:'Enter the email associated with your account and we will send a reset link.'}</p>
            <form method="post" action="{$WEB_ROOT}/pwreset.php" class="pw-form">
                <input type="hidden" name="action" value="reset">
                <div class="form-group">
                    <label class="form-label" for="pw-email">{$LANG.clientareaemail|default:'Email address'}</label>
                    <input type="email" class="form-input" id="pw-email" name="email" value="{$email|default:''|escape}" autocomplete="email" required autofocus>
                </div>
                {if isset($captcha) && $captcha}
                <div class="form-group">{$captcha}</div>
                {/if}
                <button type="submit" class="btn-primary pw-submit">{$LANG.pwresetsendlink|default:'Send reset link'}</button>
            </form>
            <p class="pw-altlink"><a href="{$WEB_ROOT}/login">{$LANG.backtologin|default:'Back to sign in'}</a></p>

        {elseif $pwStep == 'password-reset-security-prompt'}
            {* Step 2 — security question *}
            <h1 class="pw-title">{$LANG.pwresetsecuritytitle|default:'Verify your identity'}</h1>
            <p class="pw-sub">{$LANG.pwresetsecuritysub|default:'Answer your security question to continue.'}</p>
            <form method="post" action="{$WEB_ROOT}/pwreset.php" class="pw-form">
                <input type="hidden" name="action" value="reset">
                <input type="hidden" name="key" value="{$verifyhash|default:''|escape}">
                {if isset($securityquestion) && $securityquestion}
                <div class="pw-question">{$securityquestion|escape}</div>
                {/if}
                <div class="form-group">
                    <label class="form-label" for="pw-answer">{$LANG.youranswer|default:'Your answer'}</label>
                    <input type="text" class="form-input" id="pw-answer" name="securityanswer" autocomplete="off" required autofocus>
                </div>
                <button type="submit" class="btn-primary pw-submit">{$LANG.continuebutton|default:'Continue'}</button>
            </form>

        {elseif $pwStep == 'password-reset-change-prompt'}
            {* Step 3 — new password *}
            <h1 class="pw-title">{$LANG.pwresetnewtitle|default:'Choose a new password'}</h1>
            <p class="pw-sub">{$LANG.pwresetnewsub|default:'Pick a strong password — minimum 8 characters with mixed case and numbers.'}</p>
            <form method="post" action="{$WEB_ROOT}/pwreset.php" class="pw-form">
                <input type="hidden" name="action" value="reset">
                <input type="hidden" name="key" value="{$verifyhash|default:''|escape}">
                <div class="form-group">
                    <label class="form-label" for="pw-new1">{$LANG.newpassword|default:'New password'}</label>
                    <input type="password" class="form-input" id="pw-new1" name="newpw" autocomplete="new-password" required autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label" for="pw-new2">{$LANG.confirmnewpassword|default:'Confirm new password'}</label>
                    <input type="password" class="form-input" id="pw-new2" name="confirmnewpw" autocomplete="new-password" required>
                </div>
                <button type="submit" class="btn-primary pw-submit">{$LANG.pwresetchange|default:'Set new password'}</button>
            </form>

        {else}
            {* Fallback for unknown step — show step 1 form *}
            <h1 class="pw-title">{$LANG.pwresettitle|default:'Reset your password'}</h1>
            <p class="pw-sub">{$LANG.pwresetsub|default:'Enter the email associated with your account and we will send a reset link.'}</p>
            <form method="post" action="{$WEB_ROOT}/pwreset.php" class="pw-form">
                <div class="form-group">
                    <label class="form-label" for="pw-email-fb">{$LANG.clientareaemail|default:'Email address'}</label>
                    <input type="email" class="form-input" id="pw-email-fb" name="email" autocomplete="email" required>
                </div>
                <button type="submit" class="btn-primary pw-submit">{$LANG.pwresetsendlink|default:'Send reset link'}</button>
            </form>
        {/if}

    </div>
</div>
