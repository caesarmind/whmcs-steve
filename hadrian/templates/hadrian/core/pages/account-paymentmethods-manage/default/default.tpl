{* Hostnodes - Add / edit a payment method.

   Built to WHMCS 9's own contract (templates/twenty-one/account-paymentmethods-manage.tpl).
   The page it replaces was a mockup: it posted every save to the edit route
   with no id (/account/paymentmethods/), showed a Remove card on the ADD page
   that posted to /account/paymentmethods//delete, named its fields ccname /
   cccvv / address1... which WHMCS does not read, and had no payment-type or
   billing-address choice - so no card could be added or edited through it.

   WHMCS data:
     $editMode                 true when editing $payMethod, false when adding
     $payMethod                ->id, ->description, ->contactType, ->isCreditCard(),
                               ->isTokenised(), ->gateway_name, ->isDefaultPayMethod()
     $enabledTypes             [tokenGateways, localCreditCard, bankAccount] => bool
     $tokenGateways            gateway system names; $gatewayDisplayNames[name]
     $paymentMethodType        'bankacct' when the add form was asked for a bank account
     $creditCard               ->getMaskedCardNumber(), ->getCardType(), ->getExpiryDate(), ...
     $bankAccount              ->getAccountType(), ->getAccountHolderName(), ...
     $creditCard{Number,Expiry,Cvc}FieldEnabled, $startDateEnabled, $issueNumberEnabled
     $supportedCardTypes, $remoteUpdate (a gateway's own update form, edit only)
   POST fields: type, description, ccnumber, ccstart, ccexpiry, ccissuenum,
   cardcvv, bankaccttype, bankacctholdername, bankname, bankroutingnum,
   bankacctnum, billingcontact, billing_* (copied from the chosen contact).

   Local cards and bank accounts need no JavaScript library. A tokenised
   gateway (Stripe and the like) hands its own fields to the page over AJAX and
   drives them through WHMCS.payment, so for those - and only those - jQuery and
   WHMCS's shared scripts.min.js are loaded, as on twenty-one. *}

{assign var=pmEdit value=$editMode|default:false}
{assign var=pmTypes value=$enabledTypes|default:[]}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-paymentmethods-manage.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{if $pmEdit}{$LANG.paymentMethodsManage.editPaymentMethod}{else}{$LANG.paymentMethodsManage.addPaymentMethod}{/if}</h1>
    <p class="page-subtitle">{$hadrianLang.billing.pmManageIntro}</p>
</header>

<div class="pm-split">
    <div class="pm-main">
        {if $message = get_flash_message()}
            <div class="pm-alert pm-alert-{if $message.type == 'error'}error{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warn{else}info{/if}">{$message.text}</div>
        {/if}

        {if $pmEdit}
        <div class="card">
            <div class="pm-hero">
                <div class="pm-hero-visual">{if $payMethod->isCreditCard()}{$creditCard->getCardType()|default:'CARD'|upper|escape}{else}{$LANG.paymentMethodsManage.bankAccount|escape}{/if}</div>
                <div class="pm-hero-meta">
                    <div class="pm-hero-name"><span>{if $payMethod->description}{$payMethod->description|escape}{else}{$payMethod->payment->getDisplayName()|escape}{/if}</span>{if $payMethod->isDefaultPayMethod()}<span class="pm-hero-pill">{$LANG.paymentMethods.default}</span>{/if}</div>
                </div>
            </div>
        </div>
        {/if}

        <div class="card">
            <div class="card-body">
                <form id="frmManagePaymentMethod" class="frm-credit-card-input" method="post" action="{if $pmEdit}{routePath('account-paymentmethods-save', $payMethod->id)}{else}{routePath('account-paymentmethods-add')}{/if}">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <div class="pm-alert pm-alert-error gateway-errors assisted-cc-input-feedback" hidden>{$LANG.paymentMethodsManage.invalidCardDetails}</div>

                    <h3 class="pm-section-title">{$LANG.paymentMethods.type}</h3>
                    <div class="pm-types" role="radiogroup">
                        {if !empty($pmTypes.tokenGateways)}
                            {foreach $tokenGateways as $tokenGateway}
                                <label class="pm-type"><input type="radio" name="type" value="token_{$tokenGateway|escape}" data-tokenised="true" data-gateway="{$tokenGateway|escape}"{if $pmEdit && $payMethod->isCreditCard() && $payMethod->gateway_name == $tokenGateway} checked{/if}{if $pmEdit} disabled{/if}> {$gatewayDisplayNames[$tokenGateway]|escape}</label>
                            {/foreach}
                        {/if}
                        {if !empty($pmTypes.localCreditCard)}
                            <label class="pm-type"><input type="radio" name="type" value="localcard"{if ($pmEdit && $payMethod->isCreditCard() && !$payMethod->isTokenised()) || (!$pmEdit && $paymentMethodType|default:'' != 'bankacct')} checked{/if}{if $pmEdit} disabled{/if}> {$LANG.paymentMethodsManage.creditCard}</label>
                        {/if}
                        {if !empty($pmTypes.bankAccount)}
                            <label class="pm-type"><input type="radio" name="type" value="bankacct"{if ($pmEdit && !$payMethod->isCreditCard()) || ($paymentMethodType|default:'' == 'bankacct')} checked{/if}{if $pmEdit} disabled{/if}> {$LANG.paymentMethodsManage.bankAccount}</label>
                        {/if}
                    </div>

                    <div class="fieldgroup-auxfields"{if $remoteUpdate|default:false} hidden{/if}>
                        <div class="form-group">
                            <label class="form-label" for="inputDescription">{$LANG.paymentMethods.description} <span class="pm-optional">({$LANG.paymentMethodsManage.optional})</span></label>
                            <input type="text" class="form-input" id="inputDescription" name="description" autocomplete="off" value="{$payMethod->description|default:''|escape}">
                        </div>
                    </div>

                    <div class="fieldgroup-loading" hidden><p class="pm-loading">{$LANG.pleasewait}</p></div>
                    <div id="paymentGatewayInput"></div>

                    <div class="fieldgroup-creditcard"{if ($pmEdit && !$payMethod->isCreditCard()) || $paymentMethodType|default:'' == 'bankacct' || $remoteUpdate|default:false} hidden{/if}>
                        <h3 class="pm-section-title">{$LANG.creditcardenterdetails|default:$LANG.paymentMethodsManage.creditCard}</h3>
                        <div class="form-group">
                            <label class="form-label" for="inputCardNumber">{$LANG.creditcardcardnumber}</label>
                            <input type="tel" class="form-input cc-number-field {$creditCard->getCardType()|default:''|lower|escape}" id="inputCardNumber" name="ccnumber" autocomplete="cc-number" inputmode="numeric" value="{$creditCard->getMaskedCardNumber()|default:''|escape}"{if !$creditCardNumberFieldEnabled} disabled{/if} data-message-invalid="{$LANG.paymentMethodsManage.cardNumberNotValid|escape}" data-supported-cards="{$supportedCardTypes|default:''|escape}">
                            <span class="field-error-msg" hidden>{$LANG.paymentMethodsManage.cardNumberNotValid}</span>
                        </div>
                        <div class="pm-grid">
                            {if $startDateEnabled}
                            <div class="form-group">
                                <label class="form-label" for="inputCardStart">{$LANG.creditcardcardstart}</label>
                                <input type="tel" class="form-input" id="inputCardStart" name="ccstart" autocomplete="off" placeholder="MM / YY" value="{if $creditCard->getStartDate()}{$creditCard->getStartDate()->format('m / y')}{/if}">
                            </div>
                            {/if}
                            <div class="form-group">
                                <label class="form-label" for="inputCardExpiry">{$LANG.creditcardcardexpires}</label>
                                <input type="tel" class="form-input" id="inputCardExpiry" name="ccexpiry" autocomplete="cc-exp" placeholder="MM / YY" value="{if $creditCard->getExpiryDate()}{$creditCard->getExpiryDate()->format('m / y')}{/if}"{if !$creditCardExpiryFieldEnabled} disabled{/if}>
                                <span class="field-error-msg" hidden>{$LANG.paymentMethodsManage.expiryDateNotValid}</span>
                            </div>
                            {if $issueNumberEnabled}
                            <div class="form-group">
                                <label class="form-label" for="inputCardIssue">{$LANG.creditcardcardissuenum}</label>
                                <input type="tel" class="form-input" id="inputCardIssue" name="ccissuenum" autocomplete="off" value="{$creditCard->getIssueNumber()|escape}">
                            </div>
                            {/if}
                            {if $creditCardCvcFieldEnabled}
                            <div class="form-group">
                                <label class="form-label" for="inputCardCvc">{$LANG.creditcardcvvnumber}</label>
                                <input type="tel" class="form-input" id="inputCardCvc" name="cardcvv" autocomplete="cc-csc" inputmode="numeric" maxlength="4">
                                <span class="field-error-msg" hidden>{$LANG.paymentMethodsManage.cvcNumberNotValid}</span>
                            </div>
                            {/if}
                        </div>
                        <div id="tokenGatewayAssistedOutput"></div>
                    </div>

                    <div class="fieldgroup-bankaccount"{if $remoteUpdate|default:false || ($pmEdit && $payMethod->isCreditCard()) || ($paymentMethodType|default:'' != 'bankacct' && !$pmEdit)} hidden{/if}>
                        <h3 class="pm-section-title">{$LANG.paymentMethodsManage.bankAccount}</h3>
                        <div class="form-group">
                            <span class="form-label">{$LANG.paymentMethodsManage.accountType}</span>
                            <div class="pm-types">
                                <label class="pm-type"><input type="radio" name="bankaccttype" value="Checking"{if !$bankAccount->getAccountType() || $bankAccount->getAccountType() == 'Checking'} checked{/if}> {$LANG.paymentMethodsManage.checking}</label>
                                <label class="pm-type"><input type="radio" name="bankaccttype" value="Savings"{if $bankAccount->getAccountType() == 'Savings'} checked{/if}> {$LANG.paymentMethodsManage.savings}</label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="inputBankAcctHolderName">{$LANG.paymentMethodsManage.accountHolderName}</label>
                            <input type="text" class="form-input" id="inputBankAcctHolderName" name="bankacctholdername" autocomplete="off" value="{$bankAccount->getAccountHolderName()|escape}" data-required>
                            <span class="field-error-msg" hidden>{$LANG.paymentMethods.fieldRequired}</span>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="inputBankName">{$LANG.paymentMethodsManage.bankName}</label>
                            <input type="text" class="form-input" id="inputBankName" name="bankname" autocomplete="off" value="{$bankAccount->getBankName()|escape}" data-required>
                            <span class="field-error-msg" hidden>{$LANG.paymentMethods.fieldRequired}</span>
                        </div>
                        <div class="pm-grid">
                            <div class="form-group">
                                <label class="form-label" for="inputBankRoutingNum">{$LANG.paymentMethodsManage.sortCodeRoutingNumber}</label>
                                <input type="tel" class="form-input" id="inputBankRoutingNum" name="bankroutingnum" autocomplete="off" inputmode="numeric" value="{$bankAccount->getRoutingNumber()|escape}" data-required>
                                <span class="field-error-msg" hidden>{$LANG.paymentMethodsManage.routingNumberNotValid}</span>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="inputBankAcctNum">{$LANG.paymentMethodsManage.accountNumber}</label>
                                <input type="tel" class="form-input" id="inputBankAcctNum" name="bankacctnum" autocomplete="off" inputmode="numeric" value="{$bankAccount->getAccountNumber()|escape}" data-required>
                                <span class="field-error-msg" hidden>{$LANG.paymentMethodsManage.accountNumberNotValid}</span>
                            </div>
                        </div>
                    </div>

                    <div class="fieldgroup-auxfields"{if $remoteUpdate|default:false} hidden{/if}>
                        <h3 class="pm-section-title">{$LANG.billingAddress}</h3>
                        <div id="billingContactsContainer">
                            {include file="$template/account-paymentmethods-billing-contacts.tpl"}
                        </div>
                        <p class="pm-bc-add"><a href="{routePath('account-contacts')}">{$LANG.paymentMethodsManage.addNewAddress}</a></p>

                        <div class="page-actions submit-container" style="margin-top:20px;display:flex;gap:10px;">
                            <button type="submit" name="submit" id="btnSubmit" class="btn-primary">{$LANG.clientareasavechanges}</button>
                            <a href="{routePath('account-paymentmethods')}" class="btn-secondary">{$LANG.cancel}</a>
                        </div>
                    </div>
                    <input type="hidden" name="billing_name" id="inputBillingName" value="">
                    <input type="hidden" name="billing_address_1" id="inputBillingAddress1" value="">
                    <input type="hidden" name="billing_address_2" id="inputBillingAddress2" value="">
                    <input type="hidden" name="billing_city" id="inputBillingCity" value="">
                    <input type="hidden" name="billing_state" id="inputBillingState" value="">
                    <input type="hidden" name="billing_postcode" id="inputBillingPostcode" value="">
                    <input type="hidden" name="billing_country" id="inputBillingCountry" value="">
                </form>

                <div class="fieldgroup-remoteinput"{if !($pmEdit && $remoteUpdate|default:false)} hidden{/if}>
                    {if $remoteUpdate|default:false}
                        <div id="tokenGatewayRemoteUpdateOutput">{$remoteUpdate}</div>
                    {else}
                        <div id="tokenGatewayRemoteInputOutput"></div>
                        <iframe name="ccframe" class="auth3d-area" title="{$LANG.paymentMethodsManage.creditCard|escape}" style="width:100%;height:600px;border:0" src="about:blank"></iframe>
                    {/if}
                </div>
            </div>
        </div>

        {* Only where WHMCS lets clients delete (CCAllowCustomerDelete -> $allowDelete). *}
        {if $pmEdit && !empty($allowDelete)}
        <div class="card">
            <div class="pm-danger">
                <p class="pm-danger-title">{$hadrianLang.billing.pmRemoveTitle}</p>
                <p class="pm-danger-sub">{$hadrianLang.billing.pmRemoveSub}</p>
                <form method="post" action="{routePath('account-paymentmethods-delete', $payMethod->id)}" onsubmit="return confirm('{$LANG.paymentMethods.deletePaymentMethodConfirm|escape:'javascript'}');">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <button type="submit" class="btn-danger">{$LANG.paymentMethods.delete}</button>
                </form>
            </div>
        </div>
        {/if}
    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item active">
                <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentMethods.title}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
        </div>
    </aside>
</div>

{* Tokenised gateways only: their AJAX-delivered fields and WHMCS.payment events
   need jQuery + the WHMCS JS core + assets/js/whmcs/payment.js, which the
   client area does not load. (standard_cart's scripts.min.js was used before:
   it doesn't define WHMCS.payment, and it throws on this page because it
   formats #inputCardNumber with the jquery.payment plugin.) *}
{if !empty($pmTypes.tokenGateways)}
{include file="`$template`/includes/partials/whmcs-core-js.tpl"}
<script src="{$WEB_ROOT}/assets/js/whmcs/payment.js"></script>
{/if}

<script>
var mtPm = {
    initTokenUrl: '{routePath('account-paymentmethods-inittoken')|escape:'javascript'}',
    token: '{$token|default:''|escape:'javascript'}',
    numberEnabled: {if $creditCardNumberFieldEnabled}true{else}false{/if},
    expiryEnabled: {if $creditCardExpiryFieldEnabled}true{else}false{/if},
    cvcEnabled: {if $creditCardCvcFieldEnabled}true{else}false{/if}
};
</script>
<script>{literal}
(function () {
    var form = document.getElementById('frmManagePaymentMethod');
    if (!form) { return; }
    var groups = function (sel) { return document.querySelectorAll(sel); };
    var show = function (sel, on) { groups(sel).forEach(function (g) { g.hidden = !on; }); };
    var meta = { _source: 'payment-method-add' };
    var payEvents = function () { return window.WHMCS && WHMCS.payment && WHMCS.payment.event; };

    /* Card number / expiry formatting and the checks twenty-one does with jquery.payment. */
    var digits = function (v) { return (v || '').replace(/\D+/g, ''); };
    var luhn = function (n) {
        var s = 0, alt = false;
        for (var i = n.length - 1; i >= 0; i--) { var d = +n[i]; if (alt) { d *= 2; if (d > 9) d -= 9; } s += d; alt = !alt; }
        return n.length >= 12 && s % 10 === 0;
    };
    var num = document.getElementById('inputCardNumber'), exp = document.getElementById('inputCardExpiry');
    if (num) num.addEventListener('input', function () {
        if (num.value.indexOf('*') !== -1) return;   // a masked, stored number
        num.value = digits(num.value).slice(0, 19).replace(/(\d{4})(?=\d)/g, '$1 ');
    });
    [exp, document.getElementById('inputCardStart')].forEach(function (el) {
        if (el) el.addEventListener('input', function () {
            var d = digits(el.value).slice(0, 4);
            el.value = d.length > 2 ? d.slice(0, 2) + ' / ' + d.slice(2) : d;
        });
    });
    var fieldError = function (input, on) {
        var msg = input && input.parentNode.querySelector('.field-error-msg');
        if (msg) msg.hidden = !on;
        if (input) input.setAttribute('aria-invalid', on ? 'true' : 'false');
    };

    /* Billing address: copy the chosen contact into the billing_* fields. */
    var fillBilling = function () {
        var picked = form.querySelector('input[name="billingcontact"]:checked');
        if (!picked) return;
        var c = form.querySelector('.billing-contact-' + picked.value);
        var txt = function (cls) { var e = c && c.querySelector('.' + cls); return e ? e.textContent.trim() : ''; };
        document.getElementById('inputBillingName').value = txt('name');
        document.getElementById('inputBillingAddress1').value = txt('address1');
        document.getElementById('inputBillingAddress2').value = txt('address2');
        document.getElementById('inputBillingCity').value = txt('city');
        document.getElementById('inputBillingState').value = txt('state');
        document.getElementById('inputBillingPostcode').value = txt('postcode');
        document.getElementById('inputBillingCountry').value = txt('country');
    };
    form.addEventListener('change', function (e) { if (e.target.name === 'billingcontact') fillBilling(); });
    fillBilling();

    /* Payment type: which field group is shown; tokenised gateways fetch their own. */
    var onType = function (input) {
        var ev = payEvents();
        if (ev && ev.gatewayUnselected) ev.gatewayUnselected(meta);
        if (window.WHMCS && WHMCS.payment && WHMCS.payment.display && WHMCS.payment.display.errorClear) WHMCS.payment.display.errorClear();
        show('.fieldgroup-creditcard, .fieldgroup-bankaccount, .fieldgroup-remoteinput, .fieldgroup-auxfields', false);
        var assisted = document.getElementById('tokenGatewayAssistedOutput');
        if (assisted) assisted.innerHTML = '';
        if (input.getAttribute('data-tokenised') === 'true') {
            var module = input.getAttribute('data-gateway');
            show('.fieldgroup-loading', true);
            fetch(mtPm.initTokenUrl, { method: 'POST', credentials: 'same-origin',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' },
                body: 'token=' + encodeURIComponent(mtPm.token) + '&gateway=' + encodeURIComponent(module)
            }).then(function (r) { return r.json(); }).then(function (res) {
                show('.fieldgroup-loading', false);
                if (res.remoteInputForm) {
                    var box = document.getElementById('tokenGatewayRemoteInputOutput');
                    box.innerHTML = res.remoteInputForm;
                    var f = box.querySelector('form');
                    if (f) { f.setAttribute('target', 'ccframe'); setTimeout(function () { f.submit(); }, 1000); }
                    show('.fieldgroup-remoteinput', true);
                } else if (res.assistedOutput) {
                    show('.fieldgroup-creditcard', true);
                    /* jQuery's html() runs the gateway's inline scripts; innerHTML would not. */
                    if (window.jQuery) { jQuery('#tokenGatewayAssistedOutput').html(res.assistedOutput); } else { assisted.innerHTML = res.assistedOutput; }
                    var ev2 = payEvents();
                    if (ev2) {
                        mtPm.inited = mtPm.inited || {};
                        var el = window.jQuery ? jQuery(input) : input;
                        if (!mtPm.inited[module]) { ev2.gatewayInit && ev2.gatewayInit(meta, module, el); ev2.gatewayOptionInit && ev2.gatewayOptionInit(meta, module, el); mtPm.inited[module] = true; }
                        ev2.gatewaySelected && ev2.gatewaySelected(meta, module, el);
                    }
                    show('.fieldgroup-auxfields', true);
                } else if (res.gatewayType === 'Bank') {
                    show('.fieldgroup-bankaccount, .fieldgroup-auxfields', true);
                } else {
                    show('.fieldgroup-creditcard, .fieldgroup-auxfields', true);
                }
            }).catch(function () {
                show('.fieldgroup-loading', false);
                var err = form.querySelector('.gateway-errors'); if (err) err.hidden = false;
            });
        } else if (input.value === 'bankacct') {
            show('.fieldgroup-bankaccount, .fieldgroup-auxfields', true);
        } else {
            show('.fieldgroup-creditcard, .fieldgroup-auxfields', true);
        }
    };
    form.querySelectorAll('input[name="type"]').forEach(function (r) {
        r.addEventListener('change', function () { if (r.checked) onType(r); });
    });
    if (!form.querySelector('input[name="type"]:checked')) {
        var first = form.querySelector('input[name="type"]:not([disabled])');
        if (first) { first.checked = true; onType(first); }
    }

    /* Client-side checks before WHMCS's own (the server validates everything again). */
    form.addEventListener('submit', function (e) {
        form.querySelectorAll('.field-error-msg').forEach(function (m) { m.hidden = true; });
        var type = form.querySelector('input[name="type"]:checked');
        var bad = false;
        if (type && type.value === 'bankacct') {
            form.querySelectorAll('.fieldgroup-bankaccount [data-required]').forEach(function (i) { if (!i.value.trim()) { fieldError(i, true); bad = true; } });
        } else if (type && type.value === 'localcard') {
            if (mtPm.numberEnabled && num && num.value.indexOf('*') === -1 && !luhn(digits(num.value))) { fieldError(num, true); bad = true; }
            if (mtPm.expiryEnabled && exp && !/^\d{2} \/ \d{2}$/.test(exp.value)) { fieldError(exp, true); bad = true; }
            var cvc = document.getElementById('inputCardCvc');
            if (mtPm.cvcEnabled && cvc && !/^\d{3,4}$/.test(cvc.value)) { fieldError(cvc, true); bad = true; }
        }
        if (bad) { e.preventDefault(); return; }
        var ev = payEvents();
        if (ev && ev.addPayMethodFormSubmit) {
            ev.addPayMethodFormSubmit(Object.assign({}, meta, { event: e }), ev.previouslySelected && ev.previouslySelected.module,
                window.jQuery ? jQuery(document.getElementById('btnSubmit')) : document.getElementById('btnSubmit'));
        }
    });
})();
{/literal}</script>
