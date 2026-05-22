{* Hostnodes - Edit payment method (Apple-style).

   WHMCS v9 data (verified against shipped account-paymentmethods.tpl / Nexus):
     $payMethod  - the method being edited: ->id, ->description,
                   ->payment->getDisplayName(), ->getType(), ->isDefaultPayMethod(), ->isExpired()
   Routes: {routePath('account-paymentmethods-view', $payMethod->id)} (edit form target),
           {routePath('account-paymentmethods-add')}, {routePath('account-paymentmethods-delete', $payMethod->id)}
   NOTE: card-capture fields are gateway-dependent (tokenized gateways inject their own
   form). The manual fields below are the standard fallback; verify against the active
   gateway on deploy. Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=pmHas value=false}
{if isset($payMethod) && $payMethod}{assign var=pmHas value=true}{/if}

{assign var=pmDemo value=false}
{if !$pmHas && $isPreview}{assign var=pmDemo value=true}{/if}

{assign var=pmFull value=false}
{if $pmHas || $pmDemo}{assign var=pmFull value=true}{/if}
{if $pmFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{assign var=pmName value='Visa ending in 4242'}
{assign var=pmSub value='Arshile Gogia - Expires 12 / 2027'}
{assign var=pmBrand value='VISA'}
{assign var=pmIsDefault value=true}
{if $pmHas}
    {assign var=pmName value=$payMethod->description|default:''}
    {if !$pmName && isset($payMethod->payment)}{assign var=pmName value=$payMethod->payment->getDisplayName()}{/if}
    {assign var=pmSub value=''}
    {assign var=pmIsDefault value=false}
    {if $payMethod->isDefaultPayMethod()}{assign var=pmIsDefault value=true}{/if}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-paymentmethods-manage.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.paymentMethods.manage|default:'Manage payment method'}</h1>
    <p class="page-subtitle">{$LANG.paymentMethods.manageintro|default:'Update card details, change the default, or remove this payment method.'}</p>
</header>

<div class="pm-split">
    <div class="pm-main">
        {if $message = get_flash_message()}
            <div class="pm-alert pm-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">{$message.text}</div>
        {/if}

        {if $pmFull}
        <div class="when-full">
            <div class="card">
                <div class="pm-hero">
                    <div class="pm-hero-visual">{$pmBrand|escape}</div>
                    <div class="pm-hero-meta">
                        <div class="pm-hero-name"><span>{$pmName|escape}</span>{if $pmIsDefault}<span class="pm-hero-pill">{$LANG.paymentMethods.default|default:'Default'}</span>{/if}</div>
                        {if $pmSub}<div class="pm-hero-sub">{$pmSub|escape}</div>{/if}
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header"><h2 class="card-title">{$LANG.paymentMethods.updateCard|default:'Update card details'}</h2></div>
                <div class="card-body">
                    <form method="post" action="{if $pmHas}{routePath('account-paymentmethods-view', $payMethod->id)}{else}{routePath('account-paymentmethods-add')}{/if}">
                        <input type="hidden" name="token" value="{$token|default:''|escape}">

                        <h3 class="pm-section-title">{$LANG.creditcardenterdetails|default:'Card'}</h3>
                        <div class="form-group">
                            <label class="form-label" for="pm-cardname">{$LANG.creditcardcardholdername|default:'Cardholder name'}</label>
                            <input type="text" class="form-input" id="pm-cardname" name="ccname" autocomplete="cc-name" value="{$ccinfo.cardnum|default:''|escape}">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="pm-cardnum">{$LANG.creditcardcardnumber|default:'Card number'}</label>
                            <input type="text" class="form-input" id="pm-cardnum" name="ccnumber" inputmode="numeric" autocomplete="cc-number" placeholder="1234 1234 1234 1234">
                        </div>
                        <div class="pm-grid">
                            <div class="form-group">
                                <label class="form-label" for="pm-exp">{$LANG.creditcardcardexpires|default:'Expiration'}</label>
                                <input type="text" class="form-input" id="pm-exp" name="ccexpiry" inputmode="numeric" autocomplete="cc-exp" placeholder="MM / YY">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="pm-cvv">{$LANG.creditcardcvvnumber|default:'CVV'}</label>
                                <input type="text" class="form-input" id="pm-cvv" name="cccvv" inputmode="numeric" autocomplete="cc-csc" maxlength="4" placeholder="123">
                            </div>
                        </div>

                        <h3 class="pm-section-title">{$LANG.invoicespayto|default:'Billing address'}</h3>
                        <div class="form-group">
                            <label class="form-label" for="pm-street">{$LANG.clientareaaddress1|default:'Street address'}</label>
                            <input type="text" class="form-input" id="pm-street" name="address1" autocomplete="street-address">
                        </div>
                        <div class="pm-grid">
                            <div class="form-group">
                                <label class="form-label" for="pm-city">{$LANG.clientareacity|default:'City'}</label>
                                <input type="text" class="form-input" id="pm-city" name="city" autocomplete="address-level2">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="pm-state">{$LANG.clientareastate|default:'State / region'}</label>
                                <input type="text" class="form-input" id="pm-state" name="state" autocomplete="address-level1">
                            </div>
                        </div>
                        <div class="pm-grid">
                            <div class="form-group">
                                <label class="form-label" for="pm-zip">{$LANG.clientareapostcode|default:'Postcode'}</label>
                                <input type="text" class="form-input" id="pm-zip" name="postcode" autocomplete="postal-code">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="pm-country">{$LANG.clientareacountry|default:'Country'}</label>
                                {if isset($countriesdropdown)}{$countriesdropdown}{else}<input type="text" class="form-input" id="pm-country" name="country">{/if}
                            </div>
                        </div>

                        <label class="pm-check">
                            <input type="checkbox" name="set_default" value="1"{if $pmIsDefault} checked{/if}>
                            {$LANG.paymentMethods.setAsDefault|default:'Default payment method'}
                        </label>

                        <div class="page-actions" style="margin-top: 20px; display:flex; gap:10px;">
                            <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareasavechanges|default:'Save changes'}</button>
                            <a href="{routePath('account-paymentmethods')}" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                        </div>
                    </form>
                </div>
            </div>

            {if $pmHas}
            <div class="card">
                <div class="pm-danger">
                    <p class="pm-danger-title">{$LANG.paymentMethods.removeTitle|default:'Remove this payment method'}</p>
                    <p class="pm-danger-sub">{$LANG.paymentMethods.removeSub|default:'This payment method will be deleted and can no longer be used for automatic payments.'}</p>
                    <form method="post" action="{routePath('account-paymentmethods-delete', $payMethod->id)}" onsubmit="return confirm('{$LANG.paymentMethods.removeConfirm|default:'Remove this payment method?'}');">
                        <input type="hidden" name="token" value="{$token|default:''|escape}">
                        <button type="submit" class="btn-danger">{$LANG.paymentMethods.delete|default:'Delete payment method'}</button>
                    </form>
                </div>
            </div>
            {/if}
        </div>
        {/if}

        {if !$pmFull}
        <div class="when-empty">
            <div class="card">
                <div class="pm-empty">
                    <div class="pm-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                    </div>
                    <p class="pm-empty-title">{$LANG.paymentMethods.noneSelected|default:'No payment method selected'}</p>
                    <p class="pm-empty-sub">{$LANG.paymentMethods.noneSelectedSub|default:'Choose a saved method to edit, or add a new one.'}</p>
                    <a href="{routePath('account-paymentmethods-add')}" class="btn-primary">{$LANG.paymentMethods.add|default:'Add payment method'}</a>
                </div>
            </div>
        </div>
        {/if}
    </div>

    <aside>
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
            <a href="{routePath('account-paymentmethods-billing-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.paymentMethods.billingContacts|default:'Billing Contacts'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
        </div>
    </aside>
</div>
