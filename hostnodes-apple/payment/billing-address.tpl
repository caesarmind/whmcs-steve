{* =========================================================================
   payment/billing-address.tpl — billing address fields used alongside card/
   bank inputs on paymentmethod forms.
   ========================================================================= *}
<h4 class="form-section-title">{lang key='billingAddress'}</h4>

<div class="form-group">
    <label for="billingaddress1" class="form-label">{lang key='clientareaaddress1'}</label>
    <input type="text" name="billingaddress[address1]" id="billingaddress1" class="form-input" value="{$billingcontact.address1}" required>
</div>
<div class="form-group">
    <label for="billingaddress2" class="form-label">{lang key='clientareaaddress2'}</label>
    <input type="text" name="billingaddress[address2]" id="billingaddress2" class="form-input" value="{$billingcontact.address2}">
</div>
<div class="form-row">
    <div class="form-group">
        <label for="billingcity" class="form-label">{lang key='clientareacity'}</label>
        <input type="text" name="billingaddress[city]" id="billingcity" class="form-input" value="{$billingcontact.city}" required>
    </div>
    <div class="form-group">
        <label for="billingstate" class="form-label">{lang key='clientareastate'}</label>
        <input type="text" name="billingaddress[state]" id="billingstate" class="form-input" value="{$billingcontact.state}">
    </div>
</div>
<div class="form-row">
    <div class="form-group">
        <label for="billingpostcode" class="form-label">{lang key='clientareapostcode'}</label>
        <input type="text" name="billingaddress[postcode]" id="billingpostcode" class="form-input" value="{$billingcontact.postcode}" required>
    </div>
    <div class="form-group">
        <label for="billingcountry" class="form-label">{lang key='clientareacountry'}</label>
        <select name="billingaddress[country]" id="billingcountry" class="form-input">
            {foreach $clientcountries as $code => $name}
                <option value="{$code}"{if $code eq $billingcontact.country} selected{/if}>{$name}</option>
            {/foreach}
        </select>
    </div>
</div>
