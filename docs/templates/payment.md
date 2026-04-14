# Payment Templates

### Payment Flow Architecture

```
payment/
├── billing-address.tpl       # Billing address selection/entry
├── invoice-summary.tpl       # Invoice details display
├── card/
│   ├── select.tpl            # Select existing card or add new
│   ├── inputs.tpl            # Card number, expiry, CVV fields
│   └── validate.tpl          # Card validation UI
└── bank/
    ├── select.tpl            # Select existing bank account
    ├── inputs.tpl            # Bank account fields
    └── validate.tpl          # Bank validation UI
```

### Card Input Template

The `payment/card/inputs.tpl` renders credit card fields:

```smarty
<div class="form-group cc-details row">
    <label class="col-sm-4 text-md-right col-form-label">{lang key='creditcardcardnumber'}</label>
    <div class="col-sm-7">
        <input type="tel" name="ccnumber" id="inputCardNumber" 
               autocomplete="off" class="form-control newccinfo cc-number-field"
               data-message-unsupported="{lang key='paymentMethodsManage.unsupportedCardType'}"
               data-message-invalid="{lang key='paymentMethodsManage.cardNumberNotValid'}"
               data-supported-cards="{$supportedCardTypes}"/>
    </div>
</div>
```

**Key variables:**
- `{$addingNewCard}` - Whether adding a new card
- `{$ccnumber}`, `{$ccexpirydate}`, `{$cccvv}` - Pre-filled values
- `{$showccissuestart}` - Show start date/issue number
- `{$supportedCardTypes}` - Supported card type list
- `{$allowClientsToRemoveCards}` - Card removal allowed

### Billing Address Template

Renders address selection with existing addresses and new address form. Uses Eloquent query directly in template:

```smarty
{foreach $client->contacts()->orderBy('firstname', 'asc')->get() as $contact}
    <label class="billing-contact-{$contact->id}">
        <input type="radio" name="billingcontact" value="{$contact->id}"
               {if $billingContact == $contact->id} checked{/if}>
        <strong>{$contact->fullName}</strong>
        {$contact->address1}, {$contact->city}, {$contact->state}
    </label>
{/foreach}
```

### Card Payment Flow

The card payment process uses these templates in sequence:

```
1. card/select.tpl      → Select existing card or "New Card"
2. card/inputs.tpl      → Card number, expiry, CVV fields
3. billing-address.tpl  → Billing address selection
4. card/validate.tpl    → Client-side validation JavaScript
```

#### `card/select.tpl` - Card Selection

```smarty
{if count($existingCards) > 0}
    {foreach $existingCards as $cardInfo}
        <label>
            <input type="radio" name="paymentmethod_id" 
                   value="{$cardInfo.paymethodid}"
                   data-paymethod-id="{$cardInfo.paymethodid}"
                   data-billing-contact-id="{$cardInfo.billingcontactid}"
                   {if $payMethodId eq $cardInfo.paymethodid} checked{/if} />
            {$cardInfo.payMethod}
        </label>
    {/foreach}
    <label>
        <input type="radio" name="paymentmethod_id" value="new" id="newCCInfo" />
        {lang key='creditcardenteraliascard'}
    </label>
{/if}
```

#### `card/validate.tpl` - Validation Logic

Key JavaScript validation functions:

```javascript
// Card type detection
var cardType = jQuery.payment.cardType(cardNumber);

// Card number validation
var isValidNumber = jQuery.payment.validateCardNumber(cardNumber);

// Expiry validation
var isValidExpiry = jQuery.payment.validateCardExpiry(month, year);

// CVV validation
var isValidCVC = jQuery.payment.validateCardCVC(cvc, cardType);

// Input formatting
jQuery('#inputCardNumber').payment('formatCardNumber');
jQuery('#inputCardExpiry').payment('formatCardExpiry');
jQuery('#inputCardCvv').payment('formatCardCVC');
```

### Bank Payment Flow

```
1. bank/select.tpl      → Select existing bank account or "New Account"
2. bank/inputs.tpl      → Account type, holder name, bank, routing, account number
3. billing-address.tpl  → Billing address selection
4. bank/validate.tpl    → Client-side validation
```

#### `bank/inputs.tpl` Fields

| Field | Name | Type |
|-------|------|------|
| Account Type | `account_type` | Radio (Checking/Savings) |
| Account Holder | `account_holder_name` | Text |
| Bank Name | `bank_name` | Text |
| Routing Number | `routing_number` | Tel |
| Account Number | `account_number` | Tel |
| Description | `description` | Text |

### `invoice-summary.tpl` Variables

```smarty
{foreach $invoiceitems as $item}
    {$item.description} - {$item.amount}
{/foreach}

Subtotal: {$invoice.subtotal}
Tax ({$invoice.taxname} @ {$invoice.taxrate}%): {$invoice.tax}
Tax ({$invoice.taxname2} @ {$invoice.taxrate2}%): {$invoice.tax2}
Credit: {$invoice.credit}
Total: {$invoice.total}
Amount Paid: {$invoice.amountpaid}
Balance: {$balance}
```
