{* Hostnodes — Payment Methods (Apple-style).

   WHMCS v9 data (verified against Nexus account-paymentmethods.tpl):
     $client                   — WHMCS\Client\Client model; payment methods live
                                  under $client->payMethods (Collection)
                                  Use $client->payMethods->validateGateways() to
                                  iterate (filters out methods whose gateway is
                                  no longer enabled).
     $payMethod                — each item in the foreach. Methods:
       ->id
       ->description           (user-given description; may be empty)
       ->getFontAwesomeIcon()
       ->payment->getDisplayName()   (gateway display name, e.g. "Stripe")
       ->getType()             ('CreditCard' | 'BankAccount' | 'RemoteBankAccount' | …)
       ->getStatus()
       ->isDefaultPayMethod()
       ->isExpired()
     $allowCreditCard, $allowBankDetails, $allowDelete  — feature toggles

   Result flags (set after a recent action):
     $createSuccess, $createFailed
     $saveSuccess,   $saveFailed
     $setDefaultResult  — true/false/null
     $deleteResult      — true/false/null

   Routes:
     {routePath('account-paymentmethods-add')}
     {routePathWithQuery('account-paymentmethods-add', null, 'type=bankacct')}
     {routePath('account-paymentmethods-view', $payMethod->id)}
     {routePath('account-paymentmethods-setdefault', $payMethod->id)}
     {routePath('account-paymentmethods-delete', $payMethod->id)}
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-paymentmethods.css?v={$myTheme.version|default:'1.0'}">

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <h1>{$LANG.paymentMethods.title|default:'Payment Methods'}</h1>
            <p class="page-subtitle">{$LANG.paymentMethods.intro|default:'Cards and bank accounts you have saved for fast checkout.'}</p>
        </div>
    </div>
</header>

<div class="pm-split">
    <div class="pm-main">

        {if $message = get_flash_message()}
            <div class="pm-alert pm-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">
                {$message.text}
            </div>
        {/if}
        {if !empty($createSuccess)}<div class="pm-alert pm-alert-success">{$LANG.paymentMethods.addedSuccess|default:'Payment method added.'}</div>{/if}
        {if !empty($createFailed)}<div class="pm-alert pm-alert-warn">{$LANG.paymentMethods.addFailed|default:'Could not add the payment method.'}</div>{/if}
        {if !empty($saveSuccess)}<div class="pm-alert pm-alert-success">{$LANG.paymentMethods.updateSuccess|default:'Payment method updated.'}</div>{/if}
        {if !empty($saveFailed)}<div class="pm-alert pm-alert-warn">{$LANG.paymentMethods.saveFailed|default:'Could not save the changes.'}</div>{/if}
        {if isset($setDefaultResult) && $setDefaultResult === true}<div class="pm-alert pm-alert-success">{$LANG.paymentMethods.defaultUpdateSuccess|default:'Default payment method updated.'}</div>{/if}
        {if isset($setDefaultResult) && $setDefaultResult === false}<div class="pm-alert pm-alert-warn">{$LANG.paymentMethods.defaultUpdateFailed|default:'Could not change the default.'}</div>{/if}
        {if isset($deleteResult) && $deleteResult === true}<div class="pm-alert pm-alert-success">{$LANG.paymentMethods.deleteSuccess|default:'Payment method removed.'}</div>{/if}
        {if isset($deleteResult) && $deleteResult === false}<div class="pm-alert pm-alert-warn">{$LANG.paymentMethods.deleteFailed|default:'Could not remove the payment method.'}</div>{/if}

        {assign var=pmList value=null}
        {if isset($client) && isset($client->payMethods)}{assign var=pmList value=$client->payMethods->validateGateways()}{/if}
        {assign var=pmCount value=0}
        {if $pmList}{assign var=pmCount value=$pmList->count()}{/if}

        {if $pmCount > 0}
        <div class="pm-list when-full">
            {foreach $pmList as $payMethod}
                {assign var=pmType   value=$payMethod->getType()|default:''}
                {assign var=pmKind   value='generic'}
                {if $pmType == 'BankAccount' || $pmType == 'RemoteBankAccount'}{assign var=pmKind value='bank'}{/if}
                {assign var=pmIsDefault value=false}
                {if $payMethod->isDefaultPayMethod()}{assign var=pmIsDefault value=true}{/if}
                {assign var=pmExpired value=false}
                {if $payMethod->isExpired()}{assign var=pmExpired value=true}{/if}
                <div class="pm-row{if $pmIsDefault} pm-row-default{/if}{if $pmExpired} pm-row-expired{/if}">
                    <div class="pm-row-logo pm-logo-{$pmKind|escape}">
                        <i class="{$payMethod->getFontAwesomeIcon()|default:'fa fa-credit-card'}"></i>
                    </div>
                    <div class="pm-row-meta">
                        <div class="pm-row-title">
                            {$payMethod->payment->getDisplayName()|default:$pmType|escape}
                            {if $pmIsDefault}<span class="pm-tag pm-tag-default">{$LANG.paymentMethods.default|default:'Default'}</span>{/if}
                            {if $pmExpired}<span class="pm-tag pm-tag-expired">{$LANG.paymentMethods.expired|default:'Expired'}</span>{/if}
                        </div>
                        <div class="pm-row-sub">
                            {if $payMethod->description}{$payMethod->description|escape}{else}<span class="pm-row-status">{$payMethod->getStatus()|default:''|escape}</span>{/if}
                        </div>
                    </div>
                    <div class="pm-row-actions">
                        {if !$pmIsDefault && !$pmExpired}
                            <a href="{routePath('account-paymentmethods-setdefault', $payMethod->id)}" class="pm-row-btn">{$LANG.paymentMethods.setAsDefault|default:'Set default'}</a>
                        {/if}
                        {if $pmType != 'RemoteBankAccount'}
                            <a href="{routePath('account-paymentmethods-view', $payMethod->id)}" class="pm-row-btn">{$LANG.paymentMethods.edit|default:'Edit'}</a>
                        {/if}
                        {if !empty($allowDelete)}
                            <a href="{routePath('account-paymentmethods-delete', $payMethod->id)}" class="pm-row-btn pm-row-btn-danger" data-pm-confirm-delete>{$LANG.paymentMethods.delete|default:'Delete'}</a>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>
        {/if}

        <div class="pm-add">
            {if !empty($allowCreditCard)}
                <a href="{routePath('account-paymentmethods-add')}" class="btn-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    {$LANG.paymentMethods.addNewCC|default:'Add new credit card'}
                </a>
            {/if}
            {if !empty($allowBankDetails)}
                <a href="{routePathWithQuery('account-paymentmethods-add', null, 'type=bankacct')}" class="btn-secondary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18M3 10h18M5 6l7-3 7 3"/><path d="M4 10v11M20 10v11M8 14v3M12 14v3M16 14v3"/></svg>
                    {$LANG.paymentMethods.addNewBank|default:'Add bank account'}
                </a>
            {/if}
        </div>

        {if $pmCount == 0}
        <div class="pm-empty when-empty">
            <div class="pm-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg></div>
            <p class="pm-empty-title">{$LANG.paymentMethods.noPaymentMethodsCreated|default:'No payment methods yet'}</p>
            <p class="pm-empty-sub">{$LANG.paymentMethods.intro|default:'Add a card or bank account for faster checkout next time you pay an invoice.'}</p>
        </div>
        {/if}

    </div>

    <aside class="pm-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-users')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                {$LANG.usermanagement|default:'User Management'}
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

<script>{literal}
(function(){
    document.querySelectorAll('[data-pm-confirm-delete]').forEach(function(a){
        a.addEventListener('click', function(e){
            if (!confirm('Remove this payment method? This cannot be undone.')) e.preventDefault();
        });
    });
})();
{/literal}</script>
