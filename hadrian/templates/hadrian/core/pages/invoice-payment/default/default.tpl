{* Hostnodes — Invoice Payment: the card / bank-account payment page
   (/index.php?rp=/invoice/<id>/pay) a merchant gateway sends the client to
   from the invoice.

   Same contract as stock nexus invoice-payment.tpl + payment/<card|bank>/*:
     $showRemoteInput, $remoteInput    gateway-hosted step (3-D Secure etc.):
                                        its form auto-posts into an iframe
     $submitLocation, $invoiceid        the payment form posts here
     $cardOrBank                        'card' or 'bank'
     $hasRemoteInput, $newCardRoute     the gateway collects new details
                                        itself (choosing "new" reloads there)
     card: $existingCards[] {paymethodid, billingcontactid, payMethod},
           $cardOnFile, $payMethodId, $addingNewCard, $supportedCardTypes,
           $ccnumber, $ccexpirydate, $showccissuestart, $ccstartdate,
           $ccissuenum, $cccvv, $allowClientsToRemoveCards
           -> fields ccinfo, ccnumber, ccexpirydate, ccstartdate, ccissuenum,
              cccvv, nostore, ccdescription
     bank: $existingAccounts[], $existingAccount, $addingNew, $accountType,
           $accountHolderName, $bankName, $routingNumber, $accountNumber,
           $description -> fields paymethod, account_type,
           account_holder_name, bank_name, routing_number, account_number,
           description
     billing: $client (+ contacts()), $billingContact, $billingcontact,
           $userDetailsValidationError, $firstname ... $phonenumber,
           $countries, $country -> fields billingcontact (0 | id | new) and
           the new address fields
     summary: $invoicenum, $invoiceitems, $invoice{subtotal, taxrate, tax,
           taxname, taxrate2, tax2, taxname2, credit, total, amountpaid},
           $balance
     $errormessage, $servedOverSsl, $gateway
   Stock drives the form with iCheck and twenty-one's scripts.js; here the
   show/hide and card checks are plain JS, and WHMCS.payment (the gateway
   hooks Stripe-style gateways register) loads from standard_cart's shared
   script, as on the payment-method page.
   (This used to be a form looping a never-set $paymentmethods that posted
   paynow=true back to the invoice - it could not take a payment.) *}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/invoice-payment.css?v={$hadrian.version|default:'1.0'}">
<style>{literal}
.ip-wrap.ip-wide{display:grid;grid-template-columns:minmax(0,1.5fr) minmax(0,1fr);gap:24px;align-items:start;max-width:1024px;margin:0 auto}
.ip-wide .ip-card{max-width:none}
@media (max-width:860px){.ip-wrap.ip-wide{grid-template-columns:1fr}}
.ip-choice{display:flex;flex-direction:column;gap:8px}
.ip-choice .ip-method[aria-disabled="true"]{opacity:.55;cursor:not-allowed}
.ip-method-sub{display:block;font-size:var(--text-sm);color:var(--color-text-tertiary);font-weight:var(--fw-regular,400)}
.ip-grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media (max-width:520px){.ip-grid2{grid-template-columns:1fr}}
.ip-form .field-error-msg{font-size:var(--text-sm);color:var(--color-red-text)}
.ip-form [aria-invalid="true"]{border-color:var(--color-red-text)}
.ip-note{font-size:var(--text-sm);color:var(--color-text-tertiary);margin:0}
.ip-sum-table{width:100%;border-collapse:collapse;font-size:var(--text-sm)}
.ip-sum-table td{padding:8px 0;border-bottom:.5px solid var(--color-border);color:var(--color-text-secondary);vertical-align:top}
.ip-sum-table td:last-child{text-align:right;white-space:nowrap;color:var(--color-text-primary);font-variant-numeric:tabular-nums}
.ip-sum-table tr.ip-total td{font-weight:var(--fw-semibold);color:var(--color-text-primary)}
.ip-remote{text-align:center}
{/literal}</style>

{if $showRemoteInput}
    {* The gateway's hosted step: its form posts itself into this frame. *}
    <div class="ip-wrap">
        <div class="card ip-card ip-remote" id="frmRemoteCardProcess" style="max-width:760px;">
            <h1 class="ip-title">{lang key="makepayment"}</h1>
            {$remoteInput}
            <iframe name="ccframe" class="auth3d-area" title="{lang key='makepayment'}" style="width:100%;height:600px;border:0;" src="about:blank"></iframe>
        </div>
    </div>
    <script>{literal}
    (function () {
        var box = document.getElementById('frmRemoteCardProcess');
        var f = box ? box.querySelector('form') : null;
        if (!f) return;
        f.setAttribute('target', 'ccframe');
        setTimeout(function () { f.submit(); }, 1000);
    })();
    {/literal}</script>
{else}
{assign var=ipIsCard value=($cardOrBank == 'card')}
<div class="ip-wrap ip-wide">
    <div class="card ip-card">
        <h1 class="ip-title">{lang key="makepayment"}</h1>
        <p class="ip-sub">{lang key="invoicenumber"}{if $invoicenum}{$invoicenum}{else}{$invoiceid}{/if}</p>

        {if $errormessage}
            {include file="`$template`/includes/alert.tpl" type="error" errorshtml=$errormessage}
        {/if}
        <div class="ip-error gateway-errors" hidden></div>

        <form id="frmPayment" method="post" action="{$submitLocation}" class="ip-form" role="form">
            <input type="hidden" name="invoiceid" value="{$invoiceid}" />

            <div class="form-group">
                <span class="form-label">{lang key='paymentmethod'}</span>
                <div class="ip-choice" id="paymentGatewayInput">
                    {if $ipIsCard}
                        {foreach $existingCards as $cardInfo}
                            {assign var=payMethod value=$cardInfo.payMethod nocache}
                            {assign var=ipExpired value=$payMethod->payment->isExpired()}
                            {assign var=ipUsable value=($cardOnFile && !$ipExpired)}
                            <label class="ip-method"{if !$ipUsable} aria-disabled="true"{/if}>
                                <input type="radio" name="ccinfo" value="{$cardInfo.paymethodid}" data-billing-contact-id="{$cardInfo.billingcontactid}"{if $ipUsable && $payMethodId eq $cardInfo.paymethodid} checked{/if}{if !$ipUsable} disabled{/if}>
                                <span class="ip-method-name">{$payMethod->payment->getDisplayName()}
                                    <span class="ip-method-sub">{$payMethod->getDescription()}{if $payMethod->payment->getExpiryDate()} &middot; {$payMethod->payment->getExpiryDate()->format('m/Y')}{/if}{if $ipExpired} &middot; {lang key='clientareaexpired'}{/if}</span>
                                </span>
                            </label>
                        {/foreach}
                        <label class="ip-method">
                            <input type="radio" name="ccinfo" value="new" id="newCCInfo"{if $payMethodId eq "new" || !$cardOnFile} checked{/if}>
                            <span class="ip-method-name">{lang key='creditcardenternewcard'}</span>
                        </label>
                    {else}
                        {foreach $existingAccounts as $bankAccount}
                            {assign var=payMethod value=$bankAccount.payMethod nocache}
                            <label class="ip-method"{if !$existingAccount} aria-disabled="true"{/if}>
                                <input type="radio" name="paymethod" value="{$bankAccount.paymethodid}" data-billing-contact-id="{$bankAccount.billingcontactid}"{if $existingAccount && $payMethodId eq $bankAccount.paymethodid} checked{/if}{if !$existingAccount} disabled{/if}>
                                <span class="ip-method-name">{$payMethod->payment->getDisplayName()}
                                    <span class="ip-method-sub">{$payMethod->getDescription()}</span>
                                </span>
                            </label>
                        {/foreach}
                        <label class="ip-method">
                            <input type="radio" name="paymethod" value="new" id="newAccountInfo"{if $payMethodId eq "new" || !$existingAccount} checked{/if}>
                            <span class="ip-method-name">{lang key='paymentMethods.addNewBank'}</span>
                        </label>
                    {/if}
                </div>
            </div>

            {if $ipIsCard}
                {if !$hasRemoteInput}
                <div data-ip-new>
                    <div class="form-group">
                        <label class="form-label" for="inputCardNumber">{lang key='creditcardcardnumber'}</label>
                        <input type="tel" name="ccnumber" id="inputCardNumber" class="form-input cc-number-field" autocomplete="cc-number" inputmode="numeric" value="{if $ccnumber}{$ccnumber}{/if}" data-supported-cards="{$supportedCardTypes}">
                        <span class="field-error-msg" hidden>{lang key='paymentMethodsManage.cardNumberNotValid'}</span>
                    </div>
                    <div class="ip-grid2">
                        {if $showccissuestart}
                        <div class="form-group">
                            <label class="form-label" for="inputCardStart">{lang key='creditcardcardstart'}</label>
                            <input type="tel" name="ccstartdate" id="inputCardStart" class="form-input" placeholder="MM / YY" value="{$ccstartdate}">
                        </div>
                        {/if}
                        <div class="form-group">
                            <label class="form-label" for="inputCardExpiry">{lang key='creditcardcardexpires'}</label>
                            <input type="tel" name="ccexpirydate" id="inputCardExpiry" class="form-input" placeholder="MM / YY" autocomplete="cc-exp" value="{$ccexpirydate}">
                            <span class="field-error-msg" hidden>{lang key='paymentMethodsManage.expiryDateNotValid'}</span>
                        </div>
                        {if $showccissuestart}
                        <div class="form-group">
                            <label class="form-label" for="inputIssueNum">{lang key='creditcardcardissuenum'}</label>
                            <input type="number" name="ccissuenum" id="inputIssueNum" class="form-input" value="{$ccissuenum}">
                        </div>
                        {/if}
                    </div>
                </div>
                {/if}
                <div class="form-group">
                    <label class="form-label" for="inputCardCvv">{lang key='creditcardcvvnumber'}</label>
                    <input type="tel" name="cccvv" id="inputCardCvv" class="form-input" autocomplete="cc-csc" inputmode="numeric" maxlength="4" value="{$cccvv}" style="max-width:140px;">
                    <span class="field-error-msg" hidden>{lang key='paymentMethodsManage.cvcNumberNotValid'}</span>
                </div>
                {if !$hasRemoteInput}
                <div data-ip-new>
                    {if $allowClientsToRemoveCards}
                    <label class="form-checkbox-row">
                        <input type="hidden" name="nostore" value="1">
                        <input type="checkbox" class="form-checkbox" name="nostore" id="inputNoStore" value="0" checked>
                        <span>{lang key='creditCardStore'}</span>
                    </label>
                    {/if}
                    <div class="form-group">
                        <label class="form-label" for="inputDescription">{lang key='paymentMethods.cardDescription'}</label>
                        <input type="text" class="form-input" id="inputDescription" name="ccdescription" autocomplete="off" placeholder="{lang key='paymentMethods.descriptionInput'} {lang key='paymentMethodsManage.optional'}">
                    </div>
                </div>
                {/if}
            {else}
                <div data-ip-new>
                    <div class="form-group">
                        <span class="form-label">{lang key='paymentMethodsManage.accountType'}</span>
                        <div style="display:flex;gap:16px;">
                            <label class="form-checkbox-row"><input type="radio" name="account_type" value="Checking"{if !$accountType || $accountType == 'Checking'} checked{/if}> {lang key='paymentMethodsManage.checking'}</label>
                            <label class="form-checkbox-row"><input type="radio" name="account_type" value="Savings"{if $accountType == 'Savings'} checked{/if}> {lang key='paymentMethodsManage.savings'}</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="inputBankAcctHolderName">{lang key='paymentMethodsManage.accountHolderName'}</label>
                        <input type="text" class="form-input" id="inputBankAcctHolderName" name="account_holder_name" autocomplete="off" value="{$accountHolderName}" data-ip-required>
                        <span class="field-error-msg" hidden>{lang key='paymentMethods.fieldRequired'}</span>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="inputBankName">{lang key='paymentMethodsManage.bankName'}</label>
                        <input type="text" class="form-input" id="inputBankName" name="bank_name" autocomplete="off" value="{$bankName}" data-ip-required>
                        <span class="field-error-msg" hidden>{lang key='paymentMethods.fieldRequired'}</span>
                    </div>
                    <div class="ip-grid2">
                        <div class="form-group">
                            <label class="form-label" for="inputBankRoutingNum">{lang key='paymentMethodsManage.sortCodeRoutingNumber'}</label>
                            <input type="tel" class="form-input" id="inputBankRoutingNum" name="routing_number" autocomplete="off" value="{$routingNumber}" data-ip-required>
                            <span class="field-error-msg" hidden>{lang key='paymentMethodsManage.routingNumberNotValid'}</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="inputBankAcctNum">{lang key='paymentMethodsManage.accountNumber'}</label>
                            <input type="tel" class="form-input" id="inputBankAcctNum" name="account_number" autocomplete="off" value="{$accountNumber}" data-ip-required>
                            <span class="field-error-msg" hidden>{lang key='paymentMethodsManage.accountNumberNotValid'}</span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="inputDescription">{lang key='paymentMethods.description'}</label>
                        <input type="text" class="form-input" id="inputDescription" name="description" autocomplete="off" value="{$description}" placeholder="{lang key='paymentMethodsManage.optional'}">
                    </div>
                </div>
            {/if}

            {* Billing address for a new card / account (stock payment/billing-address.tpl). *}
            {if !$ipIsCard || !$hasRemoteInput}
            <div data-ip-new>
                <div class="form-group" id="billingAddressChoice">
                    <span class="form-label">{lang key='billingAddress'}</span>
                    <div class="ip-choice">
                        <label class="ip-method billing-contact-0">
                            <input type="radio" name="billingcontact" value="0"{if !$billingContact} checked{/if}>
                            <span class="ip-method-name"><span class="name">{$client->fullName}</span>
                                <span class="ip-method-sub"><span class="address1">{$client->address1}</span>{if $client->address2}, <span class="address2">{$client->address2}</span>{/if}, <span class="city">{$client->city}</span>, <span class="state">{$client->state}</span>, <span class="postcode">{$client->postcode}</span>, <span class="country">{$client->country}</span></span>
                            </span>
                        </label>
                        {foreach $client->contacts()->orderBy('firstname', 'asc')->orderBy('lastname', 'asc')->get() as $contact}
                        <label class="ip-method billing-contact-{$contact->id}">
                            <input type="radio" name="billingcontact" value="{$contact->id}"{if $billingContact == $contact->id} checked{/if}>
                            <span class="ip-method-name"><span class="name">{$contact->fullName}</span>
                                <span class="ip-method-sub"><span class="address1">{$contact->address1}</span>{if $contact->address2}, <span class="address2">{$contact->address2}</span>{/if}, <span class="city">{$contact->city}</span>, <span class="state">{$contact->state}</span>, <span class="postcode">{$contact->postcode}</span>, <span class="country">{$contact->country}</span></span>
                            </span>
                        </label>
                        {/foreach}
                        <label class="ip-method">
                            <input type="radio" name="billingcontact" value="new"{if $billingContact === 'new'} checked{/if}>
                            <span class="ip-method-name">{lang key='paymentMethodsManage.addNewBillingAddress'}</span>
                        </label>
                    </div>
                </div>
                <div id="newBillingAddress"{if !$userDetailsValidationError && $billingcontact !== 'new'} hidden{/if}>
                    <div class="ip-grid2">
                        <div class="form-group"><label class="form-label" for="inputFirstName">{lang key='clientareafirstname'}</label><input type="text" name="firstname" id="inputFirstName" value="{$firstname}" class="form-input" autocomplete="given-name"></div>
                        <div class="form-group"><label class="form-label" for="inputLastName">{lang key='clientarealastname'}</label><input type="text" name="lastname" id="inputLastName" value="{$lastname}" class="form-input" autocomplete="family-name"></div>
                    </div>
                    <div class="form-group"><label class="form-label" for="inputAddress1">{lang key='clientareaaddress1'}</label><input type="text" name="address1" id="inputAddress1" value="{$address1}" class="form-input" autocomplete="address-line1"></div>
                    <div class="form-group"><label class="form-label" for="inputAddress2">{lang key='clientareaaddress2'}</label><input type="text" name="address2" id="inputAddress2" value="{$address2}" class="form-input" autocomplete="address-line2"></div>
                    <div class="ip-grid2">
                        <div class="form-group"><label class="form-label" for="inputCity">{lang key='clientareacity'}</label><input type="text" name="city" id="inputCity" value="{$city}" class="form-input" autocomplete="address-level2"></div>
                        <div class="form-group"><label class="form-label" for="inputState">{lang key='clientareastate'}</label><input type="text" name="state" id="inputState" value="{$state}" class="form-input" autocomplete="address-level1"></div>
                        <div class="form-group"><label class="form-label" for="inputPostcode">{lang key='clientareapostcode'}</label><input type="text" name="postcode" id="inputPostcode" value="{$postcode}" class="form-input" autocomplete="postal-code"></div>
                        <div class="form-group"><label class="form-label" for="country">{lang key='clientareacountry'}</label>
                            <select id="country" name="country" class="form-select" autocomplete="country">
                                {foreach $countries as $countryCode => $countryName}
                                    <option value="{$countryCode}"{if $countryCode == $country} selected{/if}>{$countryName}</option>
                                {/foreach}
                            </select>
                        </div>
                    </div>
                    <div class="form-group"><label class="form-label" for="inputPhone">{lang key='clientareaphonenumber'}</label><input type="text" name="phonenumber" id="inputPhone" value="{$phonenumber}" class="form-input" autocomplete="tel"></div>
                </div>
            </div>
            {/if}

            <button type="submit" class="btn-primary ip-submit" id="btnSubmit" value="{lang key='submitpayment'}">
                <span class="pay-text">{lang key='submitpayment'}</span>
                <span class="click-text" hidden>{lang key='pleasewait'}</span>
            </button>
            <a href="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid}" class="btn-secondary ip-cancel">{$LANG.cancel}</a>

            {if $servedOverSsl}
                <p class="ip-note">{lang key='creditcardsecuritynotice'}</p>
            {/if}
        </form>
    </div>

    {* Invoice summary (stock payment/invoice-summary.tpl) *}
    <aside class="card ip-card" id="invoiceIdSummary">
        <h2 class="ip-sub" style="margin-bottom:12px;">{lang key="invoicenumber"}{if $invoicenum}{$invoicenum}{else}{$invoiceid}{/if}</h2>
        <table class="ip-sum-table">
            {foreach $invoiceitems as $item}
                <tr><td>{$item.description}</td><td>{$item.amount}</td></tr>
            {/foreach}
            <tr><td>{lang key="invoicessubtotal"}</td><td>{$invoice.subtotal}</td></tr>
            {if $invoice.taxrate}<tr><td>{$invoice.taxrate}% {$invoice.taxname}</td><td>{$invoice.tax}</td></tr>{/if}
            {if $invoice.taxrate2}<tr><td>{$invoice.taxrate2}% {$invoice.taxname2}</td><td>{$invoice.tax2}</td></tr>{/if}
            <tr><td>{lang key="invoicescredit"}</td><td>{$invoice.credit}</td></tr>
            <tr class="ip-total"><td>{lang key="invoicestotaldue"}</td><td>{$invoice.total}</td></tr>
            <tr><td>{lang key="paymentstodate"}</td><td>{$invoice.amountpaid}</td></tr>
        </table>
        <div class="ip-summary" style="margin:16px 0 0;">
            <div class="ip-summary-row">
                <span class="ip-summary-label">{lang key="balancedue"}</span>
                <span class="ip-summary-value ip-amount">{$balance}</span>
            </div>
        </div>
    </aside>
</div>

{* WHMCS.payment (assets/js/whmcs/payment.js): gateways that tokenise in the
   browser (Stripe and the like) register their hooks on it. It needs jQuery
   and the WHMCS core, loaded by whmcs-core-js.tpl. Not standard_cart's
   scripts.min.js: that bundle doesn't define WHMCS.payment and throws on
   this page (it formats #inputCardNumber with jquery.payment). *}
{include file="`$template`/includes/partials/whmcs-core-js.tpl"}
<script src="{$WEB_ROOT}/assets/js/whmcs/payment.js"></script>
<script>
    var hnIp = {
        isCard: {if $ipIsCard}true{else}false{/if},
        remoteNew: {if $ipIsCard && $hasRemoteInput}true{else}false{/if},
        newRoute: '{$newCardRoute|default:''|escape:'javascript'}',
        gateway: '{$gateway|default:''|escape:'javascript'}'
    };
</script>
<script>{literal}
(function () {
    var form = document.getElementById('frmPayment');
    if (!form) return;
    var choiceName = hnIp.isCard ? 'ccinfo' : 'paymethod';
    var digits = function (v) { return (v || '').replace(/\D+/g, ''); };
    var luhn = function (n) {
        var s = 0, alt = false;
        for (var i = n.length - 1; i >= 0; i--) { var d = +n[i]; if (alt) { d *= 2; if (d > 9) d -= 9; } s += d; alt = !alt; }
        return n.length >= 12 && s % 10 === 0;
    };
    var fieldError = function (input, on) {
        if (!input) return;
        var msg = input.parentNode.querySelector('.field-error-msg');
        if (msg) msg.hidden = !on;
        input.setAttribute('aria-invalid', on ? 'true' : 'false');
    };

    /* New card / account fields show only while "new" is picked; with a
       gateway that collects new details itself, "new" reloads its page. */
    var sync = function () {
        var picked = form.querySelector('input[name="' + choiceName + '"]:checked');
        var isNew = !picked || picked.value === 'new';
        form.querySelectorAll('[data-ip-new]').forEach(function (g) { g.hidden = !isNew; });
        var addr = document.getElementById('newBillingAddress');
        var bc = form.querySelector('input[name="billingcontact"]:checked');
        if (addr) addr.hidden = !(isNew && bc && bc.value === 'new');
    };
    form.addEventListener('change', function (e) {
        if (e.target.name === choiceName && e.target.value === 'new' && hnIp.remoteNew && hnIp.newRoute) {
            window.location = hnIp.newRoute + (hnIp.newRoute.indexOf('?') === -1 ? '?' : '&') + 'ccinfo=new';
            return;
        }
        if (e.target.name === choiceName || e.target.name === 'billingcontact') sync();
    });
    sync();

    var num = document.getElementById('inputCardNumber');
    if (num) num.addEventListener('input', function () {
        num.value = digits(num.value).slice(0, 19).replace(/(\d{4})(?=\d)/g, '$1 ');
    });
    ['inputCardExpiry', 'inputCardStart'].forEach(function (id) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('input', function () {
            var d = digits(el.value).slice(0, 4);
            el.value = d.length > 2 ? d.slice(0, 2) + ' / ' + d.slice(2) : d;
        });
    });
    var first = document.getElementById('inputCardCvv');
    if (first && first.offsetParent) first.focus();

    var jq = window.jQuery;
    var events = function () { return window.WHMCS && WHMCS.payment && WHMCS.payment.event; };
    if (events() && events().gatewayInit && jq) {
        events().gatewayInit({ _source: 'invoice-pay' }, hnIp.gateway);
    }

    /* The checks stock does with jquery.payment; WHMCS validates again. Named
       validateCreditCardInput / validateBankAccountInput and bound through
       jQuery like stock, because a gateway that collects card details in
       its own frame turns them off with
       jQuery('#frmPayment').off('submit', validateCreditCardInput). */
    var validate = function (e) {
        form.querySelectorAll('.field-error-msg').forEach(function (m) { m.hidden = true; });
        var picked = form.querySelector('input[name="' + choiceName + '"]:checked');
        var isNew = !picked || picked.value === 'new';
        var bad = false;
        if (hnIp.isCard) {
            if (isNew && num && !luhn(digits(num.value))) { fieldError(num, true); bad = true; }
            var exp = document.getElementById('inputCardExpiry');
            if (isNew && exp && !/^\d{2} \/ \d{2}$/.test(exp.value)) { fieldError(exp, true); bad = true; }
            var cvv = document.getElementById('inputCardCvv');
            if (cvv && !/^\d{3,4}$/.test(cvv.value)) { fieldError(cvv, true); bad = true; }
        } else if (isNew) {
            form.querySelectorAll('[data-ip-required]').forEach(function (i) { if (!i.value.trim()) { fieldError(i, true); bad = true; } });
        }
        if (bad) { e.preventDefault(); if (e.stopImmediatePropagation) e.stopImmediatePropagation(); return false; }
    };
    window[hnIp.isCard ? 'validateCreditCardInput' : 'validateBankAccountInput'] = validate;
    var lock = function (e) {
        if (e.isDefaultPrevented ? e.isDefaultPrevented() : e.defaultPrevented) return;
        var btn = document.getElementById('btnSubmit');
        if (btn) { btn.disabled = true; btn.querySelector('.pay-text').hidden = true; btn.querySelector('.click-text').hidden = false; }
        if (events() && events().checkoutFormSubmit && jq) {
            events().checkoutFormSubmit({ _source: 'invoice-pay', event: e }, hnIp.gateway, jq(form));
        }
    };
    if (jq) {
        jq(form).on('submit', validate);
        jq(form).on('submit.paymentjs', lock);
    } else {
        form.addEventListener('submit', validate);
        form.addEventListener('submit', lock);
    }
})();
{/literal}</script>
{/if}
