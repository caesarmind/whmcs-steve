{* Hostnodes -- Sign in (Beacon variant). Full-bleed.

   Renders edge-to-edge: header.tpl/footer.tpl suppress the portal chrome when
   the active variant declares fullPage (see core/pages/login/beacon/beacon.php).

   WHMCS standard vars (same set core/pages/login/split/split.tpl uses):
     $token, $incorrect, $rememberMe, $ssoProviders, $logout,
     $verifylinkexpired, $passwordResetSuccessful

   Featured announcements:
     $loginAnnouncements -- list of {id,title,date,excerpt} injected by the
     ClientAreaPageLogin hook (Hooks::clientAreaPageLogin). Empty/unset is fine;
     the empty state below is what a fresh install sees.

   Variant options, read as $hadrian.pages.login.options.* (NOT .config.*, which
   does not exist):
     bcn_field_style  gradient|solid|soft|light -- how the page field is filled
     bcn_news         bool -- render the announcements strip at all
*}

{* A stored FALSE must not be re-defaulted to true. |default: fires on whatever
   the modifier considers "missing", and which values those are depends on the
   Smarty build in play: the inlined compiler form tests null/'', an empty()-based
   smarty_modifier_default treats false as missing and hands back the default --
   so a toggle switched OFF comes back ON and the control looks broken. isset()
   is right under either implementation. Same hazard bento.tpl documents. *}
{assign var=bcnNews value=true}
{if isset($hadrian.pages.login.options.bcn_news)}{assign var=bcnNews value=$hadrian.pages.login.options.bcn_news}{/if}
{assign var=bcnStyle value=$hadrian.pages.login.options.bcn_field_style|default:'gradient'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login.css?v={$hadrian.version|default:'1.0'}">
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login-beacon.css?v={$hadrian.version|default:'1.0'}">

{* The field is painted on the WRAPPER, not on <body>: the reference paints
   body.lv4 directly, but this template is included INTO the theme's shell and
   does not own <body> -- header.tpl does. A full-height wrapper carrying the
   same background gets the identical result without a body script, and keeps
   the variant from leaking its colour onto any other page that happens to
   render through the same shell. *}
<div class="mt-bcn" data-bcn-style="{$bcnStyle|escape}">

    {* Brand bar. Pinned top-left, out of the centred column's flow, so the card
       stays vertically centred no matter how tall the bar's contents are. *}
    <div class="mt-bcn-bar">
        <a href="{$WEB_ROOT}/" class="mt-bcn-brand">
            {* data-logo-dark is what initLogoSwap selects on (document-wide,
               img[data-logo-dark]) and it is emitted only when the two uploads
               actually differ -- matching every other render site in the theme.
               Without it a dark-on-transparent logo sits invisible here. *}
            {if !empty($hadrian.branding.logo.light)}
                <img src="{$hadrian.branding.logo.light|escape}" alt="{$companyname|escape}"
                     {if !empty($hadrian.branding.logo.dark) && $hadrian.branding.logo.dark != $hadrian.branding.logo.light}data-logo-dark="{$hadrian.branding.logo.dark|escape}"{/if}>
            {else}
                <span class="mt-bcn-brand-mark">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                </span>
                <span class="mt-bcn-brand-name">{$companyname|default:'Hostnodes'|escape}</span>
            {/if}
        </a>
    </div>

    <section class="mt-bcn-hero">
        <div class="mt-bcn-copy">
            <h2>{$hadrianLang.auth.welcomeBack}</h2>
            <p>{$hadrianLang.auth.loginWelcomeSub}</p>
        </div>

        <div class="mt-bcn-card">
            {* The routed /index.php/login flow reports a failed login (and other
               notices) through get_flash_message(), NOT the legacy $incorrect
               var. Both are handled: an install still posting to dologin.php
               sets $incorrect and nothing else. *}
            {if $message = get_flash_message()}
                <div class="auth-notice{if $message.type == 'success'} success{elseif $message.type == 'warning' || $message.type == 'info'} info{/if}">{$message.text}</div>
            {/if}

            {if $logout}
                <div class="auth-notice success">{$hadrianLang.auth.logoutSuccessful}</div>
            {/if}
            {if $incorrect}
                <div class="auth-notice">{$hadrianLang.auth.loginDetailsIncorrect}</div>
            {/if}
            {if $verifylinkexpired}
                <div class="auth-notice">{$hadrianLang.auth.verifyLinkExpired}</div>
            {/if}
            {if $passwordResetSuccessful}
                <div class="auth-notice success">{$hadrianLang.auth.pwResetSuccess}</div>
            {/if}

            <form class="auth-form" method="post" action="{routePath('login-validate')}">
                <input type="hidden" name="token" value="{$token}" />

                <div class="form-group">
                    <label class="form-label" for="loginEmail">{$LANG.loginemail}</label>
                    <input type="email" id="loginEmail" name="username" class="form-input" placeholder="{$hadrianLang.auth.emailPlaceholder}" autocomplete="email" autofocus required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="loginPassword">{$LANG.clientareapassword}</label>
                    <div class="password-wrapper">
                        <input type="password" id="loginPassword" name="password" class="form-input" placeholder="{$hadrianLang.auth.passwordPlaceholder}" autocomplete="current-password" required>
                        <button type="button" class="password-toggle" aria-label="{$hadrianLang.auth.togglePassword}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>

                <div class="form-row-inline">
                    <label class="checkbox-label">
                        <input type="checkbox" name="rememberme" class="form-checkbox" {if $rememberMe}checked{/if}>
                        <span>{$LANG.loginrememberme}</span>
                    </label>
                    <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.forgotpw}</a>
                </div>

                {* CAPTCHA -- renders only when enabled for the login form in admin.
                   $captcha is an OBJECT: getMarkup() emits the widget and the
                   reCAPTCHA api.js is auto-injected by {$headoutput}. A bare
                   {$captcha} prints nothing useful. *}
                {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                <div class="form-group auth-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
                {/if}

                <button type="submit" class="btn-primary btn-lg btn-full{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.loginbutton}</button>
            </form>

            {if $ssoProviders|default:false && $ssoProviders|@count > 0}
                <div class="auth-divider">{$LANG.or}</div>
                <div class="auth-sso-row">
                    {foreach $ssoProviders as $provider}
                        <a href="{$provider.url|escape}" class="auth-sso-btn">
                            {if $provider.icon}<img src="{$provider.icon|escape}" alt="">{/if}
                            <span>{$provider.label|escape|default:$hadrianLang.auth.continueSso}</span>
                        </a>
                    {/foreach}
                </div>
            {/if}

            <div class="auth-footer">
                {$LANG.userLogin.notRegistered}
                <a href="{$WEB_ROOT}/register.php" class="auth-link">{$LANG.userLogin.createAccount}</a>
            </div>
        </div>
    </section>

    {if $bcnNews}
    <section class="mt-bcn-news">
        <div class="mt-bcn-news-head">
            <h3>{$hadrianLang.auth.latestAnnouncements}</h3>
            <a href="{$WEB_ROOT}/announcements.php">{$LANG.viewall|default:'View All'} &rarr;</a>
        </div>
        {if $loginAnnouncements|default:false && $loginAnnouncements|@count > 0}
            <div class="mt-bcn-news-grid">
                {foreach $loginAnnouncements as $a}
                    <a href="{$WEB_ROOT}/announcements.php?id={$a.id}" class="mt-bcn-news-card">
                        <h4>{$a.title|escape}</h4>
                        {* The excerpt is a real field on the row -- the hook
                           strips the body's markup down to a sentence. Absent on
                           an announcement whose body is empty, so it is gated
                           rather than printed blank. *}
                        {if $a.excerpt|default:''}<p>{$a.excerpt|escape}</p>{/if}
                        <span class="mt-bcn-news-date">{$a.date|escape}</span>
                    </a>
                {/foreach}
            </div>
        {else}
            <div class="mt-bcn-news-empty">
                <span class="ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                </span>
                <p>{$LANG.noannouncements}</p>
            </div>
        {/if}
    </section>
    {/if}

</div>
