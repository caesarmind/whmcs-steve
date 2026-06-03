{* Hostnodes — Your Profile (Apple-style).

   WHMCS v9 data (verified against Nexus user-profile.tpl):
     $user                     — WHMCS\User\User Eloquent model
       ->firstName              (camelCase, not snake_case)
       ->lastName
       ->email
       ->needsToCompleteEmailVerification()   — bool method
       ->emailVerified()                       — bool method
     $uneditableFields         — array of field-name strings that are read-only
                                  (e.g. provisioned by SSO / SAML / admin)
     $token                    — CSRF token

   Form save routes (POST):
     {routePath('user-profile-save')}        — name fields
     {routePath('user-profile-email-save')}  — email field (separate POST)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-profile.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <h1>{$LANG.yourprofile|default:'Your Profile'}</h1>
    <p class="page-subtitle">{$hadrianLang.account.profileSub}</p>
</header>

<div class="up-split">

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{routePath('user-profile')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                {$LANG.yourprofile|default:'Your Profile'}
            </a>
            <a href="{routePath('user-accounts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                {$LANG.navSwitchAccount}
            </a>
            <a href="{routePath('user-password')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                {$LANG.clientareanavchangepassword|default:'Change Password'}
            </a>
            <a href="{routePath('user-security')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security settings'}
            </a>
        </div>
    </aside>

    <div class="up-main">

        {if $message = get_flash_message()}
            <div class="up-alert up-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">
                {$message.text}
            </div>
        {/if}

        {* ── Name form (POST to user-profile-save) ── *}
        <form method="post" action="{routePath('user-profile-save')}" class="up-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">

            <div class="card up-card">
                <div class="card-header"><h2 class="card-title">{$LANG.userProfile.profile}</h2></div>
                <div class="card-body">
                    <div class="up-row-grid">
                        <div class="up-form-row">
                            <label class="up-form-label" for="up-first">{$LANG.clientareafirstname}</label>
                            <input type="text" class="up-input" id="up-first" name="firstname" value="{$user->firstName|default:''|escape}" autocomplete="given-name" {if in_array('firstname', $uneditableFields)}disabled{/if} required>
                        </div>
                        <div class="up-form-row">
                            <label class="up-form-label" for="up-last">{$LANG.clientarealastname}</label>
                            <input type="text" class="up-input" id="up-last" name="lastname" value="{$user->lastName|default:''|escape}" autocomplete="family-name" {if in_array('lastname', $uneditableFields)}disabled{/if} required>
                        </div>
                    </div>
                </div>
                <div class="up-actions">
                    <button type="reset" class="btn-secondary">{$LANG.cancel}</button>
                    <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareasavechanges}</button>
                </div>
            </div>
        </form>

        {* ── Email form (separate POST to user-profile-email-save; requires existing password) ── *}
        <form method="post" action="{routePath('user-profile-email-save')}" class="up-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">

            <div class="card up-card">
                <div class="card-header">
                    <h2 class="card-title">{$LANG.userProfile.changeEmail}</h2>
                    <div class="up-verify-tag">
                        {if $user->needsToCompleteEmailVerification()}
                            <span class="up-tag up-tag-warn">{$LANG.userProfile.notVerified}</span>
                        {elseif $user->emailVerified()}
                            <span class="up-tag up-tag-ok">{$LANG.userProfile.verified}</span>
                        {/if}
                    </div>
                </div>
                <div class="card-body">
                    <div class="up-form-row">
                        <label class="up-form-label" for="up-email">{$LANG.clientareaemail}</label>
                        <input type="email" class="up-input" id="up-email" name="email" value="{$user->email|default:''|escape}" autocomplete="email" {if in_array('email', $uneditableFields)}disabled{/if} required>
                        <p class="up-help">{$hadrianLang.account.emailUsedToSignIn}</p>
                    </div>
                    {if !in_array('email', $uneditableFields)}
                        <div class="up-form-row">
                            <label class="up-form-label" for="up-existing-pw">{$LANG.existingpassword}</label>
                            <input type="password" class="up-input" id="up-existing-pw" name="existing_password" autocomplete="current-password" required>
                            <p class="up-help">{$hadrianLang.account.existingPasswordRequired}</p>
                        </div>
                    {/if}
                </div>
                {if !in_array('email', $uneditableFields)}
                <div class="up-actions">
                    <button type="reset" class="btn-secondary">{$LANG.cancel}</button>
                    <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareasavechanges}</button>
                </div>
                {/if}
            </div>
        </form>
    </div>

</div>
