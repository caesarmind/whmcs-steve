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

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login.css?v={$myTheme.version|default:'1.0'}">
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/login-split.css?v={$myTheme.version|default:'1.0'}">

<div class="mt-loginscreen">

    {* ── Left: brand + welcome + latest announcements ── *}
    <aside class="mt-ls-panel">
        <a href="{$WEB_ROOT}/" class="mt-ls-brand">
            {if !empty($myTheme.branding.logo.light)}
                <img src="{$myTheme.branding.logo.light|escape}" alt="{$companyname|escape}">
            {else}
                <span class="mt-ls-brand-mark">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                </span>
                <span class="mt-ls-brand-name">{$companyname|default:'Hostnodes'|escape}</span>
            {/if}
        </a>

        <div class="mt-ls-copy">
            <h2>{$LANG.welcomeback|default:'Welcome back.'}</h2>
            <p>{$LANG.loginwelcomesub|default:'Manage your services, domains, invoices and support — all from one control panel.'}</p>
        </div>

        <div class="mt-ls-news">
            <div class="mt-ls-news-head">
                <h3>{$LANG.announcements|default:'Latest announcements'}</h3>
                <a href="{$WEB_ROOT}/announcements.php">{$LANG.viewall|default:'View all'}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </a>
            </div>

            {if !empty($loginAnnouncements) && $loginAnnouncements|@count > 0}
                <div class="mt-ls-news-list">
                    {foreach $loginAnnouncements as $a}
                        <a href="{$WEB_ROOT}/announcements.php?id={$a.id|escape:'url'}" class="mt-ls-news-item">
                            <span class="mt-ls-news-title">{$a.title|escape}</span>
                            <span class="mt-ls-news-date">{$a.date|escape}</span>
                        </a>
                    {/foreach}
                </div>
            {else}
                <div class="mt-ls-news-empty">{$LANG.loginnonews|default:"You're all caught up — no announcements right now."}</div>
            {/if}
        </div>
    </aside>

    {* ── Right: sign-in form ── *}
    <main class="mt-ls-main">
        <div class="mt-ls-card">
            <header class="page-header">
                <p class="page-eyebrow">{$LANG.accounttab|default:'Account'}</p>
                <h1>{$LANG.clientareanavlogin|default:'Sign in'}</h1>
                <p class="page-subtitle">{$LANG.loginintro|default:'Use your account email and password.'}</p>
            </header>

            {if $logout}
                <div class="auth-notice success">{$LANG.logoutsuccessful|default:'You have been logged out. See you next time.'}</div>
            {/if}
            {if $incorrect}
                <div class="auth-notice">{$LANG.logindetailsincorrect|default:'The email address or password you entered is incorrect. Please try again.'}</div>
            {/if}
            {if $verifylinkexpired}
                <div class="auth-notice">{$LANG.verifylinkexpired|default:'This email-verification link has expired. Sign in to request a new one.'}</div>
            {/if}
            {if $passwordResetSuccessful}
                <div class="auth-notice success">{$LANG.pwresetsuccess|default:'Your password has been reset. Sign in with your new password.'}</div>
            {/if}

            <form class="auth-form" method="post" action="{$WEB_ROOT}/dologin.php">
                <input type="hidden" name="token" value="{$token}" />

                <div class="form-group">
                    <label class="form-label" for="loginEmail">{$LANG.loginemail|default:'Email Address'}</label>
                    <input type="email" id="loginEmail" name="username" class="form-input" placeholder="you@example.com" autocomplete="email" autofocus required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="loginPassword">{$LANG.loginpassword|default:'Password'}</label>
                    <div class="password-wrapper">
                        <input type="password" id="loginPassword" name="password" class="form-input" placeholder="{$LANG.loginpasswordplaceholder|default:'Enter your password'}" autocomplete="current-password" required>
                        <button type="button" class="password-toggle" aria-label="{$LANG.togglepasswordvisibility|default:'Show or hide password'}" data-toggle-pwd>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>

                <div class="form-row-inline">
                    <label class="checkbox-label">
                        <input type="checkbox" name="rememberme" class="form-checkbox" {if $rememberMe}checked{/if}>
                        <span>{$LANG.loginrememberme|default:'Remember me'}</span>
                    </label>
                    <a href="{$WEB_ROOT}/pwreset.php" class="auth-link">{$LANG.loginforgotten|default:'Forgot password?'}</a>
                </div>

                <button type="submit" class="btn-primary btn-lg btn-full">{$LANG.loginbutton|default:'Sign In'}</button>
            </form>

            {if $ssoProviders|default:false && $ssoProviders|@count > 0}
                <div class="auth-divider">{$LANG.orcontinuewith|default:'or continue with'}</div>
                <div class="auth-sso-row">
                    {foreach $ssoProviders as $provider}
                        <a href="{$provider.url|escape}" class="auth-sso-btn">
                            {if $provider.icon}<img src="{$provider.icon|escape}" alt="">{/if}
                            <span>{$provider.label|escape|default:'Continue'}</span>
                        </a>
                    {/foreach}
                </div>
            {/if}

            <div class="auth-footer">
                {$LANG.dontHaveAccount|default:"Don't have an account?"}
                <a href="{$WEB_ROOT}/register.php" class="auth-link">{$LANG.createaccount|default:'Create one'}</a>
            </div>
        </div>
    </main>

</div>

{literal}
<script>
(function () {
    document.querySelectorAll('[data-toggle-pwd]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input = btn.parentNode.querySelector('input');
            if (!input) return;
            input.type = (input.type === 'password') ? 'text' : 'password';
        });
    });
})();
</script>
{/literal}
