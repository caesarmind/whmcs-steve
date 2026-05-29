{* Hostnodes — Contact Us (Apple-style).

   WHMCS standard variables on /contact.php:
     $departments  — array of public departments (id, name)
     $name, $email, $subject, $message — sticky form values
     $errormessage — array of validation errors
     $captcha      — bool/object, captcha challenge if enabled
     $sent         — bool, true after successful submission
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/contact.css?v={$myTheme.version|default:'1.0'}">

<div class="ct-wrap">
    <div class="card ct-card">
        {if isset($sent) && $sent}
            <div class="ct-ico ct-ico-success"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <h1 class="ct-title">{$LANG.contactsent|default:'Message sent'}</h1>
            <p class="ct-sub">{$LANG.contactsentsub|default:'Thanks — our team will reply by email as soon as possible.'}</p>
            <a href="{$WEB_ROOT}/" class="btn-primary">{$LANG.backtohome|default:'Back to home'}</a>
        {else}
            <h1 class="ct-title">{$LANG.contactus|default:'Contact us'}</h1>
            <p class="ct-sub">{$LANG.contactsub|default:'Send us a message and our team will follow up.'}</p>

            {if isset($errormessage) && $errormessage}
            <div class="ct-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <div>
                    {if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}
                </div>
            </div>
            {/if}

            <form method="post" action="{$WEB_ROOT}/contact.php" class="ct-form">
                <input type="hidden" name="send" value="true">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="ct-name">{$LANG.contactname|default:'Your name'}</label>
                        <input type="text" class="form-input" id="ct-name" name="name" value="{$name|default:''|escape}" autocomplete="name" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ct-email">{$LANG.contactemail|default:'Email address'}</label>
                        <input type="email" class="form-input" id="ct-email" name="email" value="{$email|default:''|escape}" autocomplete="email" required>
                    </div>
                </div>
                {if isset($departments) && $departments|@count > 0}
                <div class="form-group">
                    <label class="form-label" for="ct-dept">{$LANG.contactdepartment|default:'Department'}</label>
                    <select class="form-select" id="ct-dept" name="department">
                        {foreach $departments as $dept}
                        <option value="{$dept.id|escape}">{$dept.name|escape}</option>
                        {/foreach}
                    </select>
                </div>
                {/if}
                <div class="form-group">
                    <label class="form-label" for="ct-subject">{$LANG.contactsubject|default:'Subject'}</label>
                    <input type="text" class="form-input" id="ct-subject" name="subject" value="{$subject|default:''|escape}" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="ct-message">{$LANG.contactmessage|default:'Message'}</label>
                    <textarea class="form-input ct-message-area" id="ct-message" name="message" rows="8" required>{$message|default:''|escape}</textarea>
                </div>
                {* CAPTCHA — $captcha is an object; render via getMarkup() gated on the
                   per-form admin setting. The reCAPTCHA/hCaptcha api.js is auto-injected
                   by headoutput in header.tpl, so no extra JS bundle is needed here. *}
                {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                <div class="form-group ct-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                {/if}
                <button type="submit" class="btn-primary ct-submit{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.contactsend|default:'Send message'}</button>
            </form>
        {/if}
    </div>
</div>
