{* Hostnodes — Your Profile (Apple-style).

   WHMCS user-level (vs account-level) profile. Variables (verified against
   Nexus user-profile.tpl):
     $user / $loggedInUser  — firstname, lastname, email, language
     $languages             — array of locale codes
     $errormessage          — array/string of validation errors
     $token                 — CSRF token
     $successful            — bool, form saved
*}

{assign var=upUser value=$loggedInUser|default:$user|default:$clientsdetails}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-profile.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <h1>{$LANG.yourprofile|default:'Your Profile'}</h1>
    <p class="page-subtitle">{$LANG.yourprofilesub|default:'Personal information attached to your sign-in account.'}</p>
</header>

<div class="up-split">

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{$WEB_ROOT}/account/profile" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                {$LANG.yourprofile|default:'Your Profile'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=switchaccount" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                {$LANG.switchaccount|default:'Switch Account'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=changepw" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                {$LANG.clientareanavchangepassword|default:'Change Password'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security Settings'}
            </a>
        </div>
    </aside>

    <div class="up-main">
        {if !empty($successful)}
        <div class="up-alert up-alert-success">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            {$LANG.changessavedsuccessfully|default:'Profile updated.'}
        </div>
        {/if}
        {if isset($errormessage) && $errormessage}
        <div class="up-alert up-alert-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        </div>
        {/if}

        <form method="post" action="" class="up-form">
            <input type="hidden" name="token" value="{$token|default:''|escape}">

            <div class="card up-card">
                <div class="card-header"><h2 class="card-title">{$LANG.personalinformation|default:'Personal information'}</h2></div>
                <div class="card-body">
                    <div class="up-row-grid">
                        <div class="up-form-row">
                            <label class="up-form-label" for="up-first">{$LANG.clientareafirstname|default:'First name'}</label>
                            <input type="text" class="up-input" id="up-first" name="firstname" value="{$upUser.firstname|default:''|escape}" autocomplete="given-name" required>
                        </div>
                        <div class="up-form-row">
                            <label class="up-form-label" for="up-last">{$LANG.clientarealastname|default:'Last name'}</label>
                            <input type="text" class="up-input" id="up-last" name="lastname" value="{$upUser.lastname|default:''|escape}" autocomplete="family-name" required>
                        </div>
                    </div>
                    <div class="up-form-row">
                        <label class="up-form-label" for="up-email">{$LANG.clientareaemail|default:'Email address'}</label>
                        <input type="email" class="up-input" id="up-email" name="email" value="{$upUser.email|default:''|escape}" autocomplete="email" required>
                        <p class="up-help">{$LANG.youremailisusedforsign|default:'Used to sign in to your account.'}</p>
                    </div>
                    {if isset($languages) && $languages|@count > 0}
                    <div class="up-form-row">
                        <label class="up-form-label" for="up-lang">{$LANG.clientarealanguage|default:'Language'}</label>
                        <select class="up-input up-select" id="up-lang" name="language">
                            {foreach $languages as $lang}
                            <option value="{$lang|escape}"{if $upUser.language == $lang} selected{/if}>{$lang|capitalize|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                    {/if}
                </div>
            </div>

            <div class="up-actions">
                <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                <button type="submit" class="btn-primary">{$LANG.savechanges|default:'Save changes'}</button>
            </div>
        </form>
    </div>

</div>
