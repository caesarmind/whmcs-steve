{* Hostnodes — Switch Account.

   WHMCS v9 data (verified against Nexus user-switch-account.tpl):
     $accounts                 — Eloquent Collection of WHMCS\Client\Client
       ->id                     (int)
       ->displayName            — "First Last" or company name fallback
       ->status                 — 'Active' | 'Closed' | …
       ->authedUserIsOwner()    — bool method; is logged-in user the owner?
     $token                    — CSRF token

   POST endpoint (the form):
     {routePath('user-accounts')}    — body has name="id" with target account id

   Nexus's UX: clicking a row submits the hidden POST form. No per-row form;
   one form below the list with a JS click-handler. Matched here.
*}

{assign var=acCount value=0}
{if isset($accounts)}{assign var=acCount value=$accounts->count()}{/if}
{if $acCount > 0}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-switch-account.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <h1>{$LANG.navSwitchAccount}</h1>
    <p class="page-subtitle">{$LANG.switchAccount.choose}</p>
</header>

<div class="sw-split">
    <div class="sw-main">

        {if $message = get_flash_message()}
            <div class="sw-error sw-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">
                {$message.text}
            </div>
        {/if}

        {if $acCount > 0}
            <div class="when-full sw-list">
                {foreach $accounts as $account}
                    {assign var=acStatus value=$account->status|default:''}
                    {assign var=acClosed value=false}
                    {if $acStatus == 'Closed'}{assign var=acClosed value=true}{/if}
                    {assign var=acName    value=$account->displayName|default:''}
                    {assign var=acInitial value=$acName|default:'?'|substr:0:1|upper}
                    {assign var=acIsOwner value=false}
                    {if $account->authedUserIsOwner()}{assign var=acIsOwner value=true}{/if}
                    <button type="button"
                            class="sw-row{if $acClosed} sw-row-disabled{/if}"
                            {if $acClosed}disabled aria-disabled="true"{else}data-sw-id="{$account->id|escape}"{/if}>
                        <span class="sw-row-avatar">{$acInitial|escape}</span>
                        <span class="sw-row-meta">
                            <span class="sw-row-name">
                                {$acName|escape}
                                {if $acIsOwner}<span class="sw-tag sw-tag-owner">{$LANG.clientOwner}</span>{/if}
                                {if $acClosed}<span class="sw-tag sw-tag-closed">{$acStatus|escape}</span>{/if}
                            </span>
                            <span class="sw-row-sub">{if $account->email}{$account->email|escape}{else}#{$account->id|escape}{/if}</span>
                        </span>
                        <span class="sw-row-action">
                            {if $acClosed}
                                <span class="sw-row-btn sw-row-btn-disabled">{$acStatus|escape}</span>
                            {else}
                                <span class="sw-row-btn">{$LANG.navSwitchAccount}</span>
                            {/if}
                        </span>
                    </button>
                {/foreach}
            </div>
        {/if}

        <div class="when-empty sw-empty">
            <div class="sw-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg></div>
            <p class="sw-empty-title">{$LANG.switchAccount.noneFound}</p>
            <p class="sw-empty-sub">{$LANG.switchAccount.createInstructions}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.orderForm.continueToClientArea}</a>
        </div>

    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.yourprofile|default:'Your Profile'}</div>
            <a href="{routePath('user-profile')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                {$LANG.yourprofile|default:'Your Profile'}
            </a>
            <a href="{routePath('user-accounts')}" class="subnav-item active">
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
</div>

{* Hidden form — clicking a row sets id and submits *}
<form method="post" action="{routePath('user-accounts')}" id="swForm" style="display:none">
    <input type="hidden" name="token" value="{$token|default:''|escape}">
    <input type="hidden" name="id" id="swId">
</form>

<script>{literal}
(function(){
    document.querySelectorAll('[data-sw-id]').forEach(function(b){
        b.addEventListener('click', function(){
            document.getElementById('swId').value = b.getAttribute('data-sw-id');
            document.getElementById('swForm').submit();
        });
    });
})();
{/literal}</script>
