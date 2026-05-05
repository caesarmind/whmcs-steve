{* =========================================================================
   clientareadetails.tpl — edit primary account/profile details.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='clientareanavdetails'}</h1></div>

{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='clientareaupdatesuccessful'}" textcenter=true}{/if}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="token" value="{$token}">
    <input type="hidden" name="sub" value="save">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='orderForm.personalInformation'}</h3></div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="inputFirstName" class="form-label">{lang key='clientareafirstname'}</label>
                    <input type="text" name="firstname" id="inputFirstName" value="{$clientsdetails.firstname}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputLastName" class="form-label">{lang key='clientarealastname'}</label>
                    <input type="text" name="lastname" id="inputLastName" value="{$clientsdetails.lastname}" class="form-input" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="inputEmail" class="form-label">{lang key='clientareaemail'}</label>
                    <input type="email" name="email" id="inputEmail" value="{$clientsdetails.email}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputPhone" class="form-label">{lang key='clientareaphonenumber'}</label>
                    <input type="tel" name="phonenumber" id="inputPhone" value="{$clientsdetails.phonenumber}" class="form-input">
                </div>
            </div>
            <div class="form-group">
                <label for="inputCompanyName" class="form-label">{lang key='clientareacompanyname'}</label>
                <input type="text" name="companyname" id="inputCompanyName" value="{$clientsdetails.companyname}" class="form-input">
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='clientareaaddress'}</h3></div>
        <div class="card-body">
            <div class="form-group">
                <label for="inputAddress1" class="form-label">{lang key='clientareaaddress1'}</label>
                <input type="text" name="address1" id="inputAddress1" value="{$clientsdetails.address1}" class="form-input" required>
            </div>
            <div class="form-group">
                <label for="inputAddress2" class="form-label">{lang key='clientareaaddress2'}</label>
                <input type="text" name="address2" id="inputAddress2" value="{$clientsdetails.address2}" class="form-input">
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="inputCity" class="form-label">{lang key='clientareacity'}</label>
                    <input type="text" name="city" id="inputCity" value="{$clientsdetails.city}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputState" class="form-label">{lang key='clientareastate'}</label>
                    <input type="text" name="state" id="inputState" value="{$clientsdetails.state}" class="form-input">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="inputPostcode" class="form-label">{lang key='clientareapostcode'}</label>
                    <input type="text" name="postcode" id="inputPostcode" value="{$clientsdetails.postcode}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputCountry" class="form-label">{lang key='clientareacountry'}</label>
                    <select name="country" id="inputCountry" class="form-input">
                        {foreach $clientcountries as $countryCode => $countryName}
                            <option value="{$countryCode}"{if $countryCode eq $clientsdetails.country} selected{/if}>{$countryName}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            {if $showTaxIdField}
                <div class="form-group">
                    <label for="inputTaxId" class="form-label">{$taxLabel}</label>
                    <input type="text" name="tax_id" id="inputTaxId" value="{$clientsdetails.tax_id}" class="form-input">
                </div>
            {/if}
        </div>
    </div>

    {if $customfields}
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='orderForm.additionalInformation'}</h3></div>
            <div class="card-body">
                {foreach $customfields as $customfield}
                    <div class="form-group">
                        <label class="form-label">{$customfield.name}</label>
                        {$customfield.input}
                        {if $customfield.description}<div class="form-hint">{$customfield.description}</div>{/if}
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
        <a href="clientarea.php" class="btn btn-secondary">{lang key='cancel'}</a>
    </div>
</form>
