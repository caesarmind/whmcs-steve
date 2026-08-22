{* Hostnodes — Security Settings — clientarea.php?action=security.

   In WHMCS 9 this page carries ONLY Single Sign-On + third-party linked accounts
   (verified: nexus/clientareasecurity.tpl renders SSO only; lagom2 adds linked
   accounts). Two-factor authentication is managed on its own page (/user/security),
   NOT here — clientareasecurity is not given 2FA vars and ?tfaEnable=true is a no-op,
   so we do not show a 2FA card on this page (that was invented/non-functional).

   Variables WHMCS exposes here:
     $showSsoSetting     — bool, the Single Sign-On toggle is available
     $isSsoEnabled       — bool, SSO currently on
     $linkableProviders  — array of third-party sign-in providers (OAuth); each
                           entry's .code is WHMCS-rendered button markup. Present
                           only when a Remote Authn provider is configured.
     $token              — CSRF token
   When none of these is available we show a "nothing enabled — contact support"
   empty state (mirrors lagom's no-records state).
*}

{assign var=hasSso value=false}
{if isset($showSsoSetting) && $showSsoSetting}{assign var=hasSso value=true}{/if}
{assign var=hasProviders value=false}
{if isset($linkableProviders) && $linkableProviders}{assign var=hasProviders value=true}{/if}
{assign var=anyOption value=false}
{if $hasSso || $hasProviders}{assign var=anyOption value=true}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareasecurity.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', 'full');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.securitysettings|default:'Security settings'}</h1>
    <p class="page-subtitle">{$hadrianLang.account.securitySettingsSsoSub}</p>
</header>

<div class="sec-split">

    {* ══ LEFT: Profile sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=changepw" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                {$LANG.clientareanavchangepassword|default:'Change Password'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security settings'}
            </a>
            <a href="{$WEB_ROOT}/logout.php" class="subnav-item danger">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                {$LANG.logout|default:'Sign Out'}
            </a>
        </div>
    </aside>

    {* ══ RIGHT: stacked cards ══ *}
    <div class="sec-main">

        {* ── Single Sign-On (only rendered when WHMCS offers it) ── *}
        {if $hasSso}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.sso.title}</h2>
                <div class="sec-header-sub">{$hadrianLang.account.ssoSummary}</div>
            </div>
            <form id="frmSingleSignOn" method="post" action="{$WEB_ROOT}/clientarea.php?action=security">
                <input type="hidden" name="token" value="{$token|default:''|escape}">
                <input type="hidden" name="action" value="security">
                <input type="hidden" name="toggle_sso" value="1">
                <div class="sec-row">
                    <div class="sec-row-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 012 2v14a2 2 0 01-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg></div>
                    <div class="sec-row-meta">
                        <div class="sec-row-title">{$LANG.sso.title}</div>
                        <div class="sec-row-sub">{$hadrianLang.account.ssoDisableNotice}</div>
                    </div>
                    <button type="button" class="sec-toggle{if $isSsoEnabled} on{/if}" role="switch" aria-checked="{if $isSsoEnabled}true{else}false{/if}" data-sso-toggle aria-label="{$LANG.sso.title}"></button>
                    <input type="checkbox" name="allow_sso" id="inputAllowSso" hidden{if $isSsoEnabled} checked{/if}>
                </div>
            </form>
        </div>
        {/if}

        {* ── Linked accounts — third-party sign-in providers (OAuth). Only when a
              Remote Authn provider is configured ($linkableProviders populated). The
              provider buttons are WHMCS-rendered markup, output verbatim. ── *}
        {if $hasProviders}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.remoteAuthn.titleLinkedAccounts}</h2>
                <div class="sec-header-sub">{$hadrianLang.account.linkedAccountsSub}</div>
            </div>
            <div class="sec-providers">
                {foreach $linkableProviders as $provider}{$provider.code}{/foreach}
            </div>
            <div class="providerLinkingFeedback"></div>
        </div>
        {/if}

        {* ── Nothing enabled — admin hasn't turned on SSO or any linked-account provider ── *}
        {if !$anyOption}
        <div class="card sec-card-inner">
            <div class="sec-empty">
                <div class="sec-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <p class="sec-empty-title">{$hadrianLang.account.securityNoOptionsTitle}</p>
                <p class="sec-empty-sub">{$hadrianLang.account.securityNoOptionsSsoSub}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-secondary">{$LANG.contactus}</a>
            </div>
        </div>
        {/if}

    </div>
</div>

<script>
{literal}
// Single Sign-On toggle: reflect the switch state into the hidden checkbox and
// submit the form so WHMCS toggles SSO (no jQuery / WHMCS scripts on this theme).
(function () {
    var toggle = document.querySelector('[data-sso-toggle]');
    if (!toggle) { return; }
    var cb = document.getElementById('inputAllowSso');
    var form = document.getElementById('frmSingleSignOn');
    toggle.addEventListener('click', function () {
        var on = toggle.classList.toggle('on');
        toggle.setAttribute('aria-checked', on ? 'true' : 'false');
        if (cb) { cb.checked = on; }
        if (form) { form.submit(); }
    });
})();
{/literal}
</script>
