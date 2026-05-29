{* Hostnodes — User Security / Two-Factor (Apple-style) — /user/security.

   This is the REAL account-security page (unlike clientarea.php?action=security,
   which only carries SSO + linked accounts). WHMCS feeds 2FA + security-question
   data here. Verified against nexus/user-security.tpl.

   WHMCS variables:
     $twoFactorAuthAvailable  — admin has enabled at least one 2FA method
     $twoFactorAuthEnabled    — 2FA currently active on this account
     $twoFactorAuthRequired   — admin requires 2FA for this account
     $securityQuestions       — Collection of selectable security questions
     $user                    — ->hasSecurityQuestion(), ->getSecurityQuestion()
     $linkableProviders       — third-party sign-in providers (OAuth); .code = markup
     $token                   — CSRF token
   Enable/disable routes: account-security-two-factor-enable / -disable.
   We reuse clientareasecurity.css for the shared .sec-* / .tfa-* styling.
*}

{assign var=tfaAvail value=false}
{if isset($twoFactorAuthAvailable) && $twoFactorAuthAvailable}{assign var=tfaAvail value=true}{/if}
{assign var=tfaOn value=false}
{if isset($twoFactorAuthEnabled) && $twoFactorAuthEnabled}{assign var=tfaOn value=true}{/if}
{assign var=tfaRequired value=false}
{if isset($twoFactorAuthRequired) && $twoFactorAuthRequired}{assign var=tfaRequired value=true}{/if}
{assign var=hasSq value=false}
{if isset($securityQuestions) && $securityQuestions->count() > 0}{assign var=hasSq value=true}{/if}
{assign var=hasProviders value=false}
{if isset($linkableProviders) && $linkableProviders}{assign var=hasProviders value=true}{/if}
{assign var=anyOption value=false}
{if $tfaAvail || $hasSq || $hasProviders}{assign var=anyOption value=true}{/if}

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
    <p class="page-subtitle">{$LANG.usersecuritysub|default:'Two-factor authentication and account-security options.'}</p>
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
            <a href="{$WEB_ROOT}/index.php/user/security" class="subnav-item active">
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

        {if $message = get_flash_message()}
            <div class="sec-alert sec-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">{$message.text}</div>
        {/if}

        {* ── Two-factor authentication (real WHMCS 2FA management) ── *}
        {if $tfaAvail}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.twofactorauth|default:'Two-factor authentication'}</h2>
                <div class="sec-header-sub">{$LANG.twofactorauthsub|default:'Require a second step to sign in to your account.'}</div>
            </div>
            <div class="tfa-body">
                <div class="tfa-shield{if $tfaOn} enabled{/if}">
                    {if $tfaOn}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>
                    {else}
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                    {/if}
                </div>
                <div class="tfa-copy">
                    <div class="tfa-status-row">
                        <span class="tfa-status-title">{$LANG.twofactorauth|default:'Two-factor authentication'}</span>
                        <span class="tfa-status-pill{if $tfaOn} on{/if}">{if $tfaOn}{$LANG.enabled|default:'Enabled'}{else}{$LANG.disabled|default:'Disabled'}{/if}</span>
                        {if $tfaRequired && !$tfaOn}<span class="tfa-status-pill">{$LANG.required|default:'Required'}</span>{/if}
                    </div>
                    <p class="tfa-desc">
                        {if $tfaOn}
                            {$LANG.twofactorenableddesc|default:'Two-factor authentication is active. Sign-ins require both your password and a code from your second factor.'}
                        {elseif $tfaRequired}
                            {$LANG.clientAreaSecurityTwoFactorAuthRequired|default:'Your administrator requires two-factor authentication on this account. Please enable it now to keep full access.'}
                        {else}
                            {$LANG.clientAreaSecurityTwoFactorAuthRecommendation|default:'Add an extra layer of security. After your password, you will be asked for a one-time code when you sign in.'}
                        {/if}
                    </p>
                </div>
                <div class="tfa-cta" data-tfa-token="{$token|default:''|escape}">
                    {if $tfaOn}
                    <button type="button" class="btn-secondary" data-tfa-open data-tfa-url="{routePath('account-security-two-factor-disable')}" data-tfa-title="{$LANG.twofadisable|default:'Disable two-factor'}">{$LANG.twofadisable|default:'Disable two-factor'}</button>
                    {else}
                    <button type="button" class="btn-primary" data-tfa-open data-tfa-url="{routePath('account-security-two-factor-enable')}" data-tfa-title="{$LANG.twofaenable|default:'Enable two-factor'}">{$LANG.twofaenable|default:'Enable two-factor'}</button>
                    {/if}
                </div>
            </div>
        </div>
        {/if}

        {* ── Security question ── *}
        {if $hasSq}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.clientareanavsecurityquestions|default:'Security question'}</h2>
                <div class="sec-header-sub">{$LANG.securityquestionsub|default:'A backup verification step used when recovering your account.'}</div>
            </div>
            <div class="sec-card-body">
                <form method="post" action="{routePath('user-security-question')}" class="sec-form">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    {if $user->hasSecurityQuestion()}
                    <div class="sec-field">
                        <label for="sec-curans">{$user->getSecurityQuestion()|escape}</label>
                        <input type="password" name="currentsecurityqans" id="sec-curans" autocomplete="off">
                    </div>
                    {/if}
                    <div class="sec-field">
                        <label for="sec-qid">{$LANG.clientareasecurityquestion|default:'Security question'}</label>
                        <select name="securityqid" id="sec-qid">
                            {foreach $securityQuestions as $question}
                                <option value="{$question->id}">{$question->question|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                    <div class="sec-field-row">
                        <div class="sec-field">
                            <label for="sec-ans1">{$LANG.clientareasecurityanswer|default:'Answer'}</label>
                            <input type="password" name="securityqans" id="sec-ans1" autocomplete="off">
                        </div>
                        <div class="sec-field">
                            <label for="sec-ans2">{$LANG.clientareasecurityconfanswer|default:'Confirm answer'}</label>
                            <input type="password" name="securityqans2" id="sec-ans2" autocomplete="off">
                        </div>
                    </div>
                    <button type="submit" name="submit" value="1" class="btn-primary">{$LANG.clientareasavechanges|default:'Save changes'}</button>
                </form>
            </div>
        </div>
        {/if}

        {* ── Linked accounts — third-party OAuth providers ── *}
        {if $hasProviders}
        <div class="card sec-card-inner">
            <div class="sec-header">
                <h2>{$LANG.remoteAuthn.titleLinkedAccounts|default:'Linked accounts'}</h2>
                <div class="sec-header-sub">{$LANG.remoteAuthn.mayHaveMultipleLinks|default:'Connect a third-party sign-in provider so you can log in with it.'}</div>
            </div>
            <div class="sec-providers">
                {foreach $linkableProviders as $provider}{$provider.code}{/foreach}
            </div>
            <div class="providerLinkingFeedback"></div>
        </div>
        {/if}

        {* ── Nothing enabled admin-side ── *}
        {if !$anyOption}
        <div class="card sec-card-inner">
            <div class="sec-empty">
                <div class="sec-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <p class="sec-empty-title">{$LANG.securitynooptionstitle|default:'No additional security options available'}</p>
                <p class="sec-empty-sub">{$LANG.securitynooptionssub|default:'Your administrator has not enabled any additional sign-in security features (such as two-factor authentication) for your account. Please contact support if you would like extra protection added.'}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-secondary">{$LANG.contactsupport|default:'Contact support'}</a>
            </div>
        </div>
        {/if}

    </div>
</div>

{* Two-factor enable/disable runs through WHMCS's modal flow: the routes are POST-only
   and return a modal fragment (not a full page). mytheme loads no jQuery/WHMCS modal
   JS, so this is a self-contained vanilla modal that AJAX-loads the fragment with the
   CSRF token, re-executes any inline scripts it carries, and drives its step forms. *}
{if $tfaAvail}
<script>{literal}
(function () {
    var triggers = document.querySelectorAll('[data-tfa-open]');
    if (!triggers.length) { return; }
    var holder = document.querySelector('[data-tfa-token]');
    var token = holder ? (holder.getAttribute('data-tfa-token') || '') : '';
    var modal, body, titleEl;

    function build() {
        modal = document.createElement('div');
        modal.className = 'tfa-modal';
        modal.innerHTML =
            '<div class="tfa-modal-backdrop" data-tfa-close></div>' +
            '<div class="tfa-modal-dialog" role="dialog" aria-modal="true">' +
            '<div class="tfa-modal-head"><span class="tfa-modal-title"></span>' +
            '<button type="button" class="tfa-modal-x" data-tfa-close aria-label="Close">&times;</button></div>' +
            '<div class="tfa-modal-body"></div></div>';
        document.body.appendChild(modal);
        body = modal.querySelector('.tfa-modal-body');
        titleEl = modal.querySelector('.tfa-modal-title');
        modal.addEventListener('click', function (e) { if (e.target.closest('[data-tfa-close]')) { hide(); } });
        document.addEventListener('keydown', function (e) { if (e.key === 'Escape') { hide(); } });
    }
    function show(title) { if (!modal) { build(); } titleEl.textContent = title || ''; modal.classList.add('open'); }
    function hide() { if (modal) { modal.classList.remove('open'); } }

    // WHMCS's 2FA fragments call dialogSubmit()/dialogClose() (provided by WHMCS's modal
    // JS, which we don't load) — supply vanilla equivalents that drive our AJAX flow.
    window.dialogSubmit = function () {
        var f = body ? body.querySelector('form') : null;
        if (!f) { return false; }
        post(f.getAttribute('action') || window.location.href, new URLSearchParams(new FormData(f)).toString());
        return false;
    };
    window.dialogClose = function () { hide(); window.location.reload(); };

    // Run non-jQuery inline scripts; skip jQuery-based ones (their only job here is
    // module switching, which we replicate vanilla in bindModules — avoids "$ undefined").
    function runScripts(container) {
        Array.prototype.forEach.call(container.querySelectorAll('script'), function (old) {
            if (old.src) { return; }
            if (/jquery|\$\(/.test(old.textContent || '')) { old.parentNode.removeChild(old); return; }
            var s = document.createElement('script');
            s.textContent = old.textContent;
            old.parentNode.replaceChild(s, old);
        });
    }
    // Method picker: clicking a .twofa-module selects it + checks its radio.
    function bindModules() {
        var mods = body.querySelectorAll('.twofa-module');
        Array.prototype.forEach.call(mods, function (mod) {
            mod.addEventListener('click', function () {
                Array.prototype.forEach.call(mods, function (m) { m.classList.remove('active'); });
                mod.classList.add('active');
                var radio = mod.querySelector('input[type="radio"]');
                if (radio) { radio.checked = true; }
            });
        });
    }
    function bindForms() {
        var forms = body.querySelectorAll('form');
        Array.prototype.forEach.call(forms, function (f) {
            f.addEventListener('submit', function (e) {
                e.preventDefault();
                post(f.getAttribute('action') || window.location.href, new URLSearchParams(new FormData(f)).toString());
            });
        });
        // No further form + an end signal => the flow is done; refresh the status card.
        if (!forms.length && /success|enabled|disabled|complete|backup code|turned on|turned off/i.test(body.textContent)) {
            setTimeout(function () { window.location.reload(); }, 1800);
        }
    }
    function inject(html) {
        body.innerHTML = html;
        runScripts(body);
        bindModules();
        bindForms();
    }
    function post(url, data) {
        body.innerHTML = '<div class="tfa-modal-loading">' + '…' + '</div>';
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
            body: data,
            credentials: 'same-origin'
        })
        .then(function (r) { if (r.redirected) { window.location.reload(); return null; } return r.text(); })
        .then(function (text) {
            if (text === null) { return; }
            // WHMCS returns JSON ({body, title}) for these modal steps; fall back to raw HTML.
            var html = text, title = null;
            try {
                var j = JSON.parse(text);
                if (j && typeof j === 'object') {
                    html = (j.body != null) ? j.body : ((j.modalbody != null) ? j.modalbody : text);
                    title = j.title || j.modaltitle || null;
                }
            } catch (e) { /* not JSON — treat as raw HTML */ }
            if (title) { titleEl.textContent = title; }
            inject(html);
        })
        .catch(function () { body.innerHTML = '<p class="tfa-modal-err">Something went wrong — please try again.</p>'; });
    }
    Array.prototype.forEach.call(triggers, function (t) {
        t.addEventListener('click', function () {
            show(t.getAttribute('data-tfa-title'));
            post(t.getAttribute('data-tfa-url'), 'token=' + encodeURIComponent(token));
        });
    });
})();
{/literal}</script>
{/if}
