{* Billing address chooser for a payment method - a FRAGMENT, not a page.

   WHMCS contract (twenty-one account-paymentmethods-billing-contacts.tpl):
   account-paymentmethods-manage {include}s it inside its form, and reloads it
   over AJAX from routePath('account-paymentmethods-billing-contacts', $id)
   after a contact is added. It used to be built as a full "Billing contacts"
   page linked from the sub-nav: that link opened an unstyled fragment with an
   empty heading ($hadrianLang is not assigned on an AJAX response), and the
   payment-method form had no billing-address chooser at all.

     $client            WHMCS\User\Client: ->fullName, ->address1/2, ->city,
                        ->state, ->postcode, ->country, ->billingContactId,
                        ->contacts()
     $payMethod         the method being edited: ->contactType ('Client' |
                        'Contact' | null for a new one), ->getContactId()
     $selectedContactId a contact just created (AJAX reload)

   A new method with no billing contact on the client defaults to the client
   itself (!billingContactId, not === 0: WHMCS hands back null or "0").

   The <label class="billing-contact-N"> spans (.name .address1 ...) are part of
   the contract: the manage form copies them into its billing_* hidden inputs.
   Only WHMCS language strings here: this also renders as an AJAX response. *}
<div id="innerBillingContactsContainer" class="pm-bc-list">
    <label class="pm-bc-option billing-contact-0">
        <input type="radio" name="billingcontact" value="0"
            {if $payMethod->contactType == 'Client' || ($payMethod->contactType === null && !$client->billingContactId)} checked{/if}>
        <span class="pm-bc-text">
            <strong class="name">{$client->fullName|escape}</strong>
            <span class="pm-bc-addr"><span class="address1">{$client->address1|escape}</span>,
            {if $client->address2}<span class="address2">{$client->address2|escape}</span>,{/if}
            <span class="city">{$client->city|escape}</span>,
            <span class="state">{$client->state|escape}</span>,
            <span class="postcode">{$client->postcode|escape}</span>,
            <span class="country">{$client->country|escape}</span></span>
        </span>
    </label>
    {foreach $client->contacts()->orderBy('firstname', 'asc')->orderBy('lastname', 'asc')->get() as $contact}
        <label class="pm-bc-option billing-contact-{$contact->id}">
            <input type="radio" name="billingcontact" value="{$contact->id}"
                {if $payMethod->contactType == 'Contact' && $contact->id == $payMethod->getContactId()} checked
                {elseif $payMethod->contactType === null && $client->billingContactId > 0}{if $contact->id == $client->billingContactId || $contact->id == $selectedContactId} checked{/if}
                {/if}>
            <span class="pm-bc-text">
                <strong class="name">{$contact->fullName|escape}</strong>
                <span class="pm-bc-addr"><span class="address1">{$contact->address1|escape}</span>,
                {if $contact->address2}<span class="address2">{$contact->address2|escape}</span>,{/if}
                <span class="city">{$contact->city|escape}</span>,
                <span class="state">{$contact->state|escape}</span>,
                <span class="postcode">{$contact->postcode|escape}</span>,
                <span class="country">{$contact->country|escape}</span></span>
            </span>
        </label>
    {/foreach}
</div>
