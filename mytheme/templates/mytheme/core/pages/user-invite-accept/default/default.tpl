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
            <h1 class="uia-title">{$LANG.accountinvite_youhavebeen|default:"You're invited to access"} <strong>{$invite->getClientName()|escape}</strong></h1>
            <p class="uia-sub">
                {$LANG.accountinvite_givenaccess|default:'has invited you to manage their account.'|sprintf:$invite->getSenderName()|escape}
            </p>

            {if isset($errormessage) && $errormessage}
            <div class="uia-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
            {/if}

            {if $loggedin}
                {* Already signed in — one-click accept (posts to the invite route). *}
                <p class="uia-note">{$LANG.accountinvite_inviteacceptloggedin|default:'You are signed in — accept to add this account to your switcher.'}</p>
                <form method="post" action="{routePath('invite-validate', $invite->token)}" class="uia-actions">
                    {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                    <button type="submit" class="btn-primary">{$LANG.accountinvite_accept|default:'Accept invitation'}</button>
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                </form>
            {else}
                <p class="uia-note">{$LANG.accountinvite_inviteacceptloggedout|default:'Sign in or create an account to accept the invitation.'}</p>
                <div class="uia-forms">

                    {* ── Sign in ── *}
                    <div class="uia-form-card">
                        <h2 class="uia-form-title">{$LANG.signin|default:'Sign in'}</h2>
                        <form method="post" action="{routePath('login-validate')}" class="uia-form">
                            {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                            <div class="uia-field">
                                <label class="uia-label" for="uia-login-email">{$LANG.loginemail|default:'Email address'}</label>
                                <input type="email" id="uia-login-email" name="username" class="uia-input" value="{$formdata.email|default:''|escape}" autocomplete="email" required>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-login-pw">{$LANG.loginpassword|default:'Password'}</label>
                                <input type="password" id="uia-login-pw" name="password" class="uia-input" autocomplete="current-password" required>
                            </div>
                            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                            <div class="form-group uia-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                            {/if}
                            <button type="submit" class="btn-primary uia-btn{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.signin|default:'Sign in'}</button>
                        </form>
                    </div>

                    {* ── Create account (accepts the invite) ── *}
                    <div class="uia-form-card">
                        <h2 class="uia-form-title">{$LANG.createaccount|default:'Create account'}</h2>
                        <form method="post" action="{routePath('invite-validate', $invite->token)}" class="uia-form">
                            {if isset($token)}<input type="hidden" name="token" value="{$token|escape}">{/if}
                            <div class="uia-field-row">
                                <div class="uia-field">
                                    <label class="uia-label" for="uia-fn">{$LANG.clientareafirstname|default:'First name'}</label>
                                    <input type="text" id="uia-fn" name="firstname" class="uia-input" value="{$formdata.firstname|default:''|escape}" autocomplete="given-name" required>
                                </div>
                                <div class="uia-field">
                                    <label class="uia-label" for="uia-ln">{$LANG.clientarealastname|default:'Last name'}</label>
                                    <input type="text" id="uia-ln" name="lastname" class="uia-input" value="{$formdata.lastname|default:''|escape}" autocomplete="family-name" required>
                                </div>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-email">{$LANG.loginemail|default:'Email address'}</label>
                                <input type="email" id="uia-email" name="email" class="uia-input" value="{$formdata.email|default:''|escape}" autocomplete="email" required>
                            </div>
                            <div class="uia-field">
                                <label class="uia-label" for="uia-pw">{$LANG.loginpassword|default:'Password'}</label>
                                <input type="password" id="uia-pw" name="password" class="uia-input" autocomplete="new-password" required>
                            </div>
                            {if isset($accept_tos) && $accept_tos}
                            <label class="uia-tos">
                                <input type="checkbox" name="accept" id="uia-accept" required>
                                <span>{$LANG.ordertosagreement|default:'I have read and agree to the'} <a href="{$tos_url|default:''|escape}" target="_blank" rel="noopener">{$LANG.ordertos|default:'Terms of Service'}</a></span>
                            </label>
                            {/if}
                            {* Switch the captcha form id to the register form before its widget/button. *}
                            {if isset($captchaFormRegister)}{assign var=captchaForm value=$captchaFormRegister}{/if}
                            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                            <div class="form-group uia-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                            {/if}
                            <button type="submit" class="btn-primary uia-btn{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.createaccount|default:'Create account'}</button>
                        </form>
                    </div>

                </div>
            {/if}
        {else}
            <div class="uia-ico uia-ico-warn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></div>
            <h1 class="uia-title">{$LANG.accountinvite_invalid|default:'Invitation not found'}</h1>
            <p class="uia-sub">{$LANG.accountinvite_invalidsub|default:'This invitation link is no longer valid or has already been used.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.continuetoclientarea|default:'Continue to client area'}</a>
        {/if}
    </div>
</div>
