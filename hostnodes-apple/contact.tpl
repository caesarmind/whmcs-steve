{* =========================================================================
   contact.tpl — public contact form.
   ========================================================================= *}
<div class="auth-container auth-container-wide">
    <div class="auth-card auth-card-wide">
        <h1 class="auth-title">{lang key='contactus'}</h1>
        <p class="auth-subtitle">{lang key='contactformdesc'}</p>

        {if $successful}
            {include file="$template/includes/alert.tpl" type="success" msg="{lang key='contactsuccess'}" textcenter=true}
        {/if}
        {if $errormessage}
            {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
        {/if}

        <form method="post" action="{$smarty.server.PHP_SELF}" class="auth-form">
            <input type="hidden" name="send" value="true">

            <div class="form-row">
                <div class="form-group">
                    <label for="inputName" class="form-label">{lang key='contactname'}</label>
                    <input type="text" name="name" id="inputName" value="{$name}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputEmail" class="form-label">{lang key='contactemail'}</label>
                    <input type="email" name="email" id="inputEmail" value="{$email}" class="form-input" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputSubject" class="form-label">{lang key='contactsubject'}</label>
                <input type="text" name="subject" id="inputSubject" value="{$subject}" class="form-input" required>
            </div>
            <div class="form-group">
                <label for="inputMessage" class="form-label">{lang key='contactmessage'}</label>
                <textarea name="message" id="inputMessage" rows="8" class="form-input" required>{$message}</textarea>
            </div>

            {include file="$template/includes/captcha.tpl"}

            <button type="submit" class="btn btn-primary btn-lg btn-full{$captcha->getButtonClass($captchaForm)}">{lang key='contactsend'}</button>
        </form>
    </div>
</div>
