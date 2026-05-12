{* Hostnodes — Payment Methods (Apple-style).

   WHMCS standard variables on /clientarea.php?action=paymentmethods:
     $paymentmethods  — array, each: id, type ("CreditCard"|"BankAccount"|...),
                        description, cardLastFour, cardExpiryDate, isDefault
     $availableGateways — array of gateway names that can be added
     $errormessage    — array/string of validation errors
*}

{if isset($paymentmethods) && $paymentmethods|@count > 0}
    {assign var=pmCount value=$paymentmethods|@count}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=pmCount value=0}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-paymentmethods.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <h1>{$LANG.paymentmethods|default:'Payment Methods'}</h1>
            <p class="page-subtitle">{$LANG.paymentmethodssub|default:'Cards and bank accounts you have saved for fast checkout.'}</p>
        </div>
        <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods&sub=manage" class="page-header-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.addnewpaymentmethod|default:'Add payment method'}
        </a>
    </div>
</header>

<div class="pm-split">
    <div class="pm-main">

        {if isset($errormessage) && $errormessage}
        <div class="pm-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <div class="pm-list when-full">
            {if $pmCount > 0}
                {foreach $paymentmethods as $pm}
                {assign var=pmType value=$pm.type|default:''|lower}
                {assign var=cardKind value=''}
                {if isset($pm.cardType)}{assign var=cardKind value=$pm.cardType|lower}{/if}
                <div class="pm-row">
                    <div class="pm-row-logo pm-logo-{if $pmType == 'bankaccount'}bank{elseif $cardKind == 'visa'}visa{elseif $cardKind == 'mastercard'}mc{elseif $cardKind == 'amex'}amex{else}generic{/if}">
                        {if $pmType == 'bankaccount'}
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="3" y1="21" x2="21" y2="21"/><line x1="3" y1="10" x2="21" y2="10"/><polyline points="5 6 12 3 19 6"/><line x1="4" y1="10" x2="4" y2="21"/><line x1="20" y1="10" x2="20" y2="21"/><line x1="8" y1="14" x2="8" y2="17"/><line x1="12" y1="14" x2="12" y2="17"/><line x1="16" y1="14" x2="16" y2="17"/></svg>
                        {else}
                            <span class="pm-logo-text">{if $cardKind == 'visa'}VISA{elseif $cardKind == 'mastercard'}MC{elseif $cardKind == 'amex'}AMEX{else}CARD{/if}</span>
                        {/if}
                    </div>
                    <div class="pm-row-meta">
                        <div class="pm-row-title">{$pm.description|default:$pm.type|escape}{if !empty($pm.isDefault)} <span class="pm-default-tag">{$LANG.default|default:'Default'}</span>{/if}</div>
                        <div class="pm-row-sub">
                            {if !empty($pm.cardLastFour)}•••• {$pm.cardLastFour|escape}{/if}
                            {if !empty($pm.cardExpiryDate)} · {$LANG.expires|default:'Expires'} {$pm.cardExpiryDate|escape}{/if}
                        </div>
                    </div>
                    <div class="pm-row-actions">
                        <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods&sub=manage&id={$pm.id|escape}" class="pm-row-btn">{$LANG.edit|default:'Edit'}</a>
                        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=paymentmethods&sub=remove&id={$pm.id|escape}" style="display:inline" onsubmit="return confirm('{$LANG.removeconfirm|default:'Remove this payment method?'}');">
                            <button type="submit" class="pm-row-btn pm-row-btn-danger">{$LANG.remove|default:'Remove'}</button>
                        </form>
                    </div>
                </div>
                {/foreach}
            {/if}
        </div>

        <div class="pm-empty when-empty">
            <div class="pm-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg></div>
            <p class="pm-empty-title">{$LANG.nopaymentmethods|default:'No payment methods yet'}</p>
            <p class="pm-empty-sub">{$LANG.nopaymentmethodssub|default:'Add a card or bank account for faster checkout next time you pay an invoice.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods&sub=manage" class="btn-primary">{$LANG.addnewpaymentmethod|default:'Add payment method'}</a>
        </div>

    </div>

    <aside class="pm-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.securitysettings|default:'Security'}
            </a>
        </div>
    </aside>
</div>
