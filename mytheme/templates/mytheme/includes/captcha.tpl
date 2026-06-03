{* ── Active CAPTCHA markup (Apple-styled) ──────────────────────────────────
   Rendered INSIDE a page's own .X-captcha container, which already gates on
   $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm) and styles
   the image/input/label.

   IMPORTANT: $captcha->getMarkup() returns an EMPTY string on this WHMCS install
   (verified live), so we emit the markup explicitly the way stock WHMCS does.
   mytheme loads no WHMCS scripts.min.js, so the built-in image CAPTCHA is plain
   HTML (image + code input) and works on its own. reCAPTCHA/hCaptcha render their
   container; their api.js comes from {$headoutput}. *}
{if isset($captcha->recaptcha) && $captcha->recaptcha->isEnabled()}
    {* Google reCAPTCHA / hCaptcha widget container. *}
    <div class="recaptcha-container g-recaptcha" data-action="{$captchaForm|escape}"></div>
    {assign var=_capPageJs value=$captcha->getPageJs()}
    {if $_capPageJs}<script>{$_capPageJs}</script>{/if}
{else}
    {* WHMCS built-in image CAPTCHA — distorted-text image + the answer box. *}
    <p class="mt-captcha-verify">{$LANG.captchaverify}</p>
    <img class="mt-captcha-img" src="{$WEB_ROOT}/includes/verifyimage.php" alt="CAPTCHA">
    <input class="mt-captcha-code" type="text" name="code" maxlength="6" autocomplete="off" autocapitalize="off" autocorrect="off" spellcheck="false" required>
{/if}
