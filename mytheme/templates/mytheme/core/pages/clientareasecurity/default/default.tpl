{* Hostnodes — Security Settings (Apple-style).

   WHMCS standard variables expected:
     $twoFactorEnabled    — bool, true if 2FA is currently active
     $twoFactorEnforced   — bool, admin requires 2FA
     $clientsdetails.email — recipient for login-alert emails
*}

{assign var=tfaEnabled value=$twoFactorEnabled|default:false}
{assign var=tfaEnforced value=$twoFactorEnforced|default:false}
{assign var=alertEmail value=$clientsdetails.email|default:''}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareasecurity.css?v={$myTheme.version|default:'1.0'}">

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
    <p class="page-subtitle">{$LANG.securitysettingssub|default:'Two-factor authentication, sign-in devices, and login alerts.'}</p>
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
                {$LANG.securitysettings|default:'Security Settings'}
            </a>
            <a href="{$WEB_ROOT}/logout.php" class="subnav-item danger">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                {$LANG.logout|default:'Logout'}
            </a>
        </div>
    </aside>

    {* ══ RIGHT: stacked cards ══ *}
    <div class="sec-main">

        {* Two-factor authentication card *}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.twofactorauth|default:'Two-factor authentication'}</h2>
                <div class="sec-header-sub">{$LANG.twofactorauthsub|default:'Require a second step to sign in to your account.'}</div>
            </div>
            <div class="tfa-body">
                <div class="tfa-shield{if $tfaEnabled} enabled{/if}">
                    {if $tfaEnabled}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>
                    {else}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    {/if}
                </div>
                <div class="tfa-copy">
                    <div class="tfa-status-row">
                        <span class="tfa-status-title">{$LANG.twofactorauth|default:'Two-factor authentication'}</span>
                        <span class="tfa-status-pill{if $tfaEnabled} on{/if}">{if $tfaEnabled}{$LANG.enabled|default:'Enabled'}{else}{$LANG.disabled|default:'Disabled'}{/if}</span>
                    </div>
                    <p class="tfa-desc">
                        {if $tfaEnabled}
                            {$LANG.twofactorenableddesc|default:'Two-factor authentication is currently active on your account. Sign-ins require both your password and a code from your second factor.'}
                        {else}
                            {$LANG.twofactordisableddesc|default:'Two-factor authentication is currently disabled. We recommend enabling two-factor authentication to provide an extra layer of security to your account.'}
                        {/if}
                    </p>
                </div>
                <div class="tfa-cta">
                    <a href="{$WEB_ROOT}/clientarea.php?action=security{if $tfaEnabled}&tfaDisable=true{else}&tfaEnable=true{/if}" class="btn-primary">
                        {if $tfaEnabled}{$LANG.disabletwofactor|default:'Disable two-factor'}{else}{$LANG.enabletwofactor|default:'Enable two-factor'}{/if}
                    </a>
                </div>
            </div>

            {* Available methods grid *}
            <div class="tfa-methods">
                <div class="tfa-method">
                    <div class="tfa-method-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg>
                    </div>
                    <div class="tfa-method-title">{$LANG.tfamethodapp|default:'Authenticator app'}</div>
                    <div class="tfa-method-sub">{$LANG.tfamethodappsub|default:'Generate codes with 1Password, Authy, or Google Authenticator.'}</div>
                    <span class="tfa-method-rec">{$LANG.recommended|default:'Recommended'}</span>
                </div>
                <div class="tfa-method">
                    <div class="tfa-method-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                    </div>
                    <div class="tfa-method-title">{$LANG.tfamethodemail|default:'Email codes'}</div>
                    <div class="tfa-method-sub">{$LANG.tfamethodemailsub|default:'Receive a one-time code at'} {$alertEmail|escape}.</div>
                </div>
                <div class="tfa-method">
                    <div class="tfa-method-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="12" rx="2"/><line x1="2" y1="20" x2="22" y2="20"/><line x1="12" y1="16" x2="12" y2="20"/></svg>
                    </div>
                    <div class="tfa-method-title">{$LANG.tfamethodkey|default:'Security key'}</div>
                    <div class="tfa-method-sub">{$LANG.tfamethodkeysub|default:'Use a hardware key (YubiKey, Passkey-compatible device).'}</div>
                </div>
            </div>
        </div>

        {* Login alerts card *}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.loginalerts|default:'Login alerts'}</h2>
                <div class="sec-header-sub">{$LANG.loginalertssub|default:'Get notified about sign-ins and sensitive account changes.'}</div>
            </div>
            <div class="sec-row">
                <div class="sec-row-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg></div>
                <div class="sec-row-meta">
                    <div class="sec-row-title">{$LANG.alertnewdevice|default:'Email me when a new device signs in'}</div>
                    <div class="sec-row-sub">{$LANG.alertssentto|default:'Alerts sent to'} {$alertEmail|escape}</div>
                </div>
                <button type="button" class="sec-toggle on" role="switch" aria-checked="true" aria-label="{$LANG.alertnewdevice|default:'Toggle new-device alerts'}"></button>
            </div>
            <div class="sec-row">
                <div class="sec-row-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg></div>
                <div class="sec-row-meta">
                    <div class="sec-row-title">{$LANG.alertpwchange|default:'Email me when my password changes'}</div>
                    <div class="sec-row-sub">{$LANG.alertssentto|default:'Alerts sent to'} {$alertEmail|escape}</div>
                </div>
                <button type="button" class="sec-toggle on" role="switch" aria-checked="true" aria-label="{$LANG.alertpwchange|default:'Toggle password-change alerts'}"></button>
            </div>
            <div class="sec-row">
                <div class="sec-row-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg></div>
                <div class="sec-row-meta">
                    <div class="sec-row-title">{$LANG.alertpaymentchange|default:'Email me when a payment method changes'}</div>
                    <div class="sec-row-sub">{$LANG.alertssentto|default:'Alerts sent to'} {$alertEmail|escape}</div>
                </div>
                <button type="button" class="sec-toggle" role="switch" aria-checked="false" aria-label="{$LANG.alertpaymentchange|default:'Toggle payment-method alerts'}"></button>
            </div>
        </div>

        {* Active sessions card *}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.activesessions|default:'Active sessions'}</h2>
                <div class="sec-header-sub">{$LANG.activesessionssub|default:'Devices currently signed in to your account.'}</div>
            </div>
            <div class="sec-row">
                <div class="sec-row-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8"/><path d="M12 17v4"/></svg></div>
                <div class="sec-row-meta">
                    <div class="sec-row-title">{$LANG.currentsession|default:'Current session'} <span class="sec-row-chip">{$LANG.thisdevice|default:'This device'}</span></div>
                    <div class="sec-row-sub">{$LANG.activenow|default:'Active now'}</div>
                </div>
            </div>
            <div class="sec-footer-row">
                <span class="sec-footer-note">{$LANG.signoutallnote|default:'Sign out of every other device except this one.'}</span>
                <a href="{$WEB_ROOT}/logout.php?all=true">{$LANG.signoutall|default:'Sign out all other sessions'}</a>
            </div>
        </div>

    </div>
</div>

<script>
{literal}
// Toggle button visual state — purely cosmetic for now (login-alert preferences
// don't have a WHMCS-native endpoint). If we add server-side persistence later,
// post the new state on toggle.
document.addEventListener('click', function (e) {
    var btn = e.target.closest('.sec-toggle');
    if (!btn) return;
    var on = btn.classList.toggle('on');
    btn.setAttribute('aria-checked', on ? 'true' : 'false');
});
{/literal}
</script>
