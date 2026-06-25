{*
 * Domain registrant contact (only rendered when $domainsinorder).
 *
 * Server contract preserved:
 *   - name="contact" select with options for each existing $domaincontacts
 *     entry plus "addingnew" to expose the full inline registrant form.
 *   - domaincontact* fields (firstname, lastname, email, phone,
 *     companyname, address1, address2, city, state, postcode, country,
 *     tax_id) become $domaincontact.* on submit.
 *
 * Mirrors lagom2's /includes/viewcart/form-domain-details.tpl as a
 * self-contained block.
 *}

{if $domainsinorder}

    <div class="sub-heading">
        <span class="primary-bg-color">{$LANG.domainregistrantinfo}</span>
    </div>

    <p class="small text-muted">{$LANG.orderForm.domainAlternativeContact}</p>

    <div class="row margin-bottom">
        <div class="col-sm-6 col-sm-offset-3 offset-sm-3">
            <select name="contact" id="inputDomainContact" class="field form-control">
                <option value="">{$LANG.usedefaultcontact}</option>
                {foreach $domaincontacts as $domcontact}
                    <option value="{$domcontact.id}"{if $contact == $domcontact.id} selected{/if}>
                        {$domcontact.name}
                    </option>
                {/foreach}
                <option value="addingnew"{if $contact == "addingnew"} selected{/if}>
                    {$LANG.clientareanavaddcontact}...
                </option>
            </select>
        </div>
    </div>

    <div{if $contact neq "addingnew"} class="w-hidden"{/if}>
        <div class="row" id="domainRegistrantInputFields">
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputDCFirstName" class="field-icon">
                        <i class="fas fa-user"></i>
                    </label>
                    <input type="text" name="domaincontactfirstname" id="inputDCFirstName" class="field form-control" placeholder="{$LANG.orderForm.firstName}" value="{$domaincontact.firstname}">
                </div>
            </div>
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputDCLastName" class="field-icon">
                        <i class="fas fa-user"></i>
                    </label>
                    <input type="text" name="domaincontactlastname" id="inputDCLastName" class="field form-control" placeholder="{$LANG.orderForm.lastName}" value="{$domaincontact.lastname}">
                </div>
            </div>
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputDCEmail" class="field-icon">
                        <i class="fas fa-envelope"></i>
                    </label>
                    <input type="email" name="domaincontactemail" id="inputDCEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$domaincontact.email}">
                </div>
            </div>
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputDCPhone" class="field-icon">
                        <i class="fas fa-phone"></i>
                    </label>
                    <input type="tel" name="domaincontactphonenumber" id="inputDCPhone" class="field form-control" placeholder="{$LANG.orderForm.phoneNumber}" value="{$domaincontact.phonenumber}">
                </div>
            </div>
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputDCCompanyName" class="field-icon">
                        <i class="fas fa-building"></i>
                    </label>
                    <input type="text" name="domaincontactcompanyname" id="inputDCCompanyName" class="field form-control" placeholder="{$LANG.orderForm.companyName} ({$LANG.orderForm.optional})" value="{$domaincontact.companyname}">
                </div>
            </div>
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputDCAddress1" class="field-icon">
                        <i class="far fa-building"></i>
                    </label>
                    <input type="text" name="domaincontactaddress1" id="inputDCAddress1" class="field form-control" placeholder="{$LANG.orderForm.streetAddress}" value="{$domaincontact.address1}">
                </div>
            </div>
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputDCAddress2" class="field-icon">
                        <i class="fas fa-map-marker-alt"></i>
                    </label>
                    <input type="text" name="domaincontactaddress2" id="inputDCAddress2" class="field form-control" placeholder="{$LANG.orderForm.streetAddress2}" value="{$domaincontact.address2}">
                </div>
            </div>
            <div class="col-sm-4">
                <div class="form-group prepend-icon">
                    <label for="inputDCCity" class="field-icon">
                        <i class="far fa-building"></i>
                    </label>
                    <input type="text" name="domaincontactcity" id="inputDCCity" class="field form-control" placeholder="{$LANG.orderForm.city}" value="{$domaincontact.city}">
                </div>
            </div>
            <div class="col-sm-5">
                <div class="form-group prepend-icon">
                    <label for="inputDCState" class="field-icon">
                        <i class="fas fa-map-signs"></i>
                    </label>
                    <input type="text" name="domaincontactstate" id="inputDCState" class="field form-control" placeholder="{$LANG.orderForm.state}" value="{$domaincontact.state}">
                </div>
            </div>
            <div class="col-sm-3">
                <div class="form-group prepend-icon">
                    <label for="inputDCPostcode" class="field-icon">
                        <i class="fas fa-certificate"></i>
                    </label>
                    <input type="text" name="domaincontactpostcode" id="inputDCPostcode" class="field form-control" placeholder="{$LANG.orderForm.postcode}" value="{$domaincontact.postcode}">
                </div>
            </div>
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputDCCountry" class="field-icon" id="inputCountryIcon">
                        <i class="fas fa-globe"></i>
                    </label>
                    <select name="domaincontactcountry" id="inputDCCountry" class="field form-control">
                        {foreach $countries as $countrycode => $countrylabel}
                            <option value="{$countrycode}"{if (!$domaincontact.country && $countrycode == $defaultcountry) || $countrycode eq $domaincontact.country} selected{/if}>
                                {$countrylabel}
                            </option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <div class="col-sm-12">
                <div class="form-group prepend-icon">
                    <label for="inputDCTaxId" class="field-icon">
                        <i class="fas fa-building"></i>
                    </label>
                    <input type="text" name="domaincontacttax_id" id="inputDCTaxId" class="field form-control" placeholder="{$taxLabel}" value="{$domaincontact.tax_id}" autocomplete="off">
                </div>
            </div>
        </div>
    </div>

{/if}
