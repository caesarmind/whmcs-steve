{* =========================================================================
   Captcha include. Supports reCAPTCHA (visible / invisible) and WHMCS default
   image captcha. Outer container follows apple .form-group conventions.
   ========================================================================= *}
{if $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
    <div class="captcha-wrapper{if $containerClass} {$containerClass}{else} form-group{/if}">
        {if $captcha->recaptcha->isEnabled() && !$captcha->recaptcha->isInvisible()}
            <div id="google-recaptcha-domainchecker" class="recaptcha-container" data-action="{$captchaForm}"></div>
        {elseif !$captcha->recaptcha->isEnabled()}
            <div id="default-captcha-domainchecker" class="default-captcha{if $filename == 'domainchecker'} in-domain-checker{/if}">
                <p class="form-hint">{lang key="captchaverify"}</p>
                <div class="captcha-row">
                    <div class="captcha-image">
                        <img id="inputCaptchaImage" data-src="{$systemurl}includes/verifyimage.php" src="{$systemurl}includes/verifyimage.php" alt="">
                    </div>
                    <div class="captcha-input">
                        <input id="inputCaptcha" type="text" name="code" maxlength="6" class="form-input"
                               data-toggle="tooltip" data-placement="right" data-trigger="manual" title="{lang key='orderForm.required'}">
                    </div>
                </div>
            </div>
        {/if}
    </div>
{/if}
