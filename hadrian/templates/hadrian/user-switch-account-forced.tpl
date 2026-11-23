{* Forced account switch - a link (an invoice in an email, a ticket) belongs to
   one of the user's OTHER accounts, so WHMCS asks before switching to it.

   WHMCS data (twenty-one contract):
     $requiredClient  WHMCS\User\Client: ->id, ->fullName, ->companyName, ->email
   POST {routePath('user-accounts')} with name="id" switches; WHMCS then
   continues to the page that was asked for. *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/user-switch-account.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <h1>{$LANG.navSwitchAccount}</h1>
</header>

<div class="card" style="max-width:540px">
    <div class="card-body" style="display:flex;flex-direction:column;gap:18px">
        <p style="margin:0">{$LANG.switchAccount.forcedSwitchRequest}</p>
        <div style="padding:14px 16px;border-radius:var(--radius-md);background:var(--color-fill-tertiary, rgba(120,120,128,.08))">
            <strong>{$requiredClient->fullName|escape}{if $requiredClient->companyName} ({$requiredClient->companyName|escape}){/if}</strong><br>
            <span style="color:var(--color-text-secondary)">{$requiredClient->email|escape}</span>
        </div>
        <form method="post" action="{routePath('user-accounts')}" style="display:flex;gap:12px;flex-wrap:wrap">
            <input type="hidden" name="id" value="{$requiredClient->id|escape}">
            <button type="submit" class="btn-primary">{$LANG.continue}</button>
            <a href="{routePath('clientarea-home')}" class="btn-secondary">{$LANG.switchAccount.cancelAndReturn}</a>
        </form>
    </div>
</div>
