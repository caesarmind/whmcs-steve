{* Hostnodes — Sign in (Split + Announcements variant). Full-bleed.

   Renders edge-to-edge: header.tpl/footer.tpl suppress the portal chrome when
   the active variant declares fullPage (see core/pages/login/split/split.php).

   WHMCS standard vars (same as core/pages/login/default/default.tpl):
     $token, $incorrect, $rememberMe, $ssoProviders, $logout,
     $verifylinkexpired, $passwordResetSuccessful

   Featured announcements:
     $loginAnnouncements — list of {id,title,date} injected by the
     ClientAreaPageLogin hook (Hooks::clientAreaPageLogin). Empty/unset is fine.
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login.css?v={$hadrian.version|default:'1.0'}">
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login-split.css?v={$hadrian.version|default:'1.0'}">

<div class="mt-loginscreen{if !empty($hadrian.pages.login.options.info_right)} is-info-right{/if}">

    {* ── Info panel: brand + welcome + latest announcements (left by default;
       admin "Info panel on the right" option moves it to the right) ── *}
    <aside class="mt-ls-panel">
        <a href="{$WEB_ROOT}/" class="mt-ls-brand">
            {if !empty($hadrian.branding.logo.light)}
                <img src="{$hadrian.branding.logo.light|escape}" alt="{$companyname|escape}">
            {else}
                <span class="mt-ls-brand-mark">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                </span>
                <span class="mt-ls-brand-name">{$companyname|default:'Hostnodes'|escape}</span>
            {/if}
        </a>

        <div class="mt-ls-copy">
            <h2>{$hadrianLang.auth.welcomeBack}</h2>
            <p>{$hadrianLang.auth.loginWelcomeSub}</p>
        </div>

        <div class="mt-ls-news">
            <div class="mt-ls-news-head">
                <h3>{$hadrianLang.auth.latestAnnouncements}</h3>
                <a href="{$WEB_ROOT}/announcements.php">{$LANG.viewall|default:'View All'}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            </div>

            {if !empty($loginAnnouncements) && $loginAnnouncements|@count > 0}
                <div class="mt-ls-news-list">
                    {foreach $loginAnnouncements as $a}
                        <a href="{$WEB_ROOT}/announcements.php?id={$a.id|escape:'url'}" class="mt-ls-news-item">
                            <span class="mt-ls-news-title">{$a.title|escape}</span>
                            {if !empty($a.excerpt)}<span class="mt-ls-news-excerpt">{$a.excerpt|escape}</span>{/if}
                            <span class="mt-ls-news-date">{$a.date|escape}</span>
                        </a>
                    {/foreach}
                </div>
            {else}
                <div class="mt-ls-news-empty">{$LANG.noannouncements}</div>
            {/if}
        </div>
    </aside>

    {* ── Right: sign-in form ── *}
    <main class="mt-ls-main">
        <div class="mt-ls-card">
            <header class="page-header">
                <p class="page-eyebrow">{$hadrianLang.auth.account}</p>
                <h1>{$LANG.clientareahomeloginbtn}</h1>
                <p class="page-subtitle">{$hadrianLang.auth.loginIntro}</p>
            </header>

            {* The routed /index.php/login flow reports a failed login (and other
               notices) through get_flash_message(), NOT the legacy $incorrect var. *}
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

                {* CAPTCHA — renders only when enabled for the login form in admin.
                   getMarkup() emits the widget; reCAPTCHA api.js is auto-injected by {$headoutput}. *}
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
    </main>

</div>
