{* =========================================================================
   clientareadomaincontactinfo.tpl — WHOIS contact editor.
   Tabs: one per contact type (Registrant, Admin, Tech, Billing).
   ========================================================================= *}
{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}
{if $pending}{include file="$template/includes/alert.tpl" type="info" msg=$pendingMessage textcenter=true}{/if}
{if $domainInformation && !$pending && $domainInformation->getIsIrtpEnabled() && $domainInformation->isContactChangePending()}
    {if $domainInformation->getPendingSuspension()}
        {include file="$template/includes/alert.tpl" type="warning" msg="<strong>{lang key='domains.verificationRequired'}</strong><br>{lang key='domains.newRegistration'}" textcenter=true}
    {else}
        {include file="$template/includes/alert.tpl" type="info" msg="<strong>{lang key='domains.contactChangePending'}</strong><br>{lang key='domains.contactsChanged'}" textcenter=true}
    {/if}
{/if}
{if $error}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domaincontactinfo'}</h3></div>
    <div class="card-body">
        <p>{lang key='whoisContactWarning'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domaincontacts" id="frmDomainContactModification">
            <input type="hidden" name="sub" value="save">
            <input type="hidden" name="domainid" value="{$domainid}">

            <div class="filter-tabs" role="tablist">
                {foreach $contactdetails as $contactdetail => $values}
                    <a class="filter-tab{if $values@first} active{/if}" id="tabSelector{$contactdetail}" data-toggle="tab" href="#tab{$contactdetail}">{$contactdetail}</a>
                {/foreach}
            </div>

            <div class="tab-content">
                {foreach $contactdetails as $contactdetail => $values}
                    <div class="tab-pane fade{if $values@first} show active{/if}" id="tab{$contactdetail}" role="tabpanel">
                        <label class="radio-label"><input type="radio" name="wc[{$contactdetail}]" id="{$contactdetail}1" value="contact" onclick="useDefaultWhois(this.id)"> {lang key='domaincontactusexisting'}</label>
                        <div class="form-group">
                            <label for="{$contactdetail}3" class="form-label">{lang key='domaincontactchoose'}</label>
                            <input type="hidden" name="sel[{$contactdetail}]" value="">
                            <select id="{$contactdetail}3" class="form-input {$contactdetail}defaultwhois" name="sel[{$contactdetail}]" disabled>
                                <option value="u{$clientsdetails.userid}">{lang key='domaincontactprimary'}</option>
                                {foreach $contacts as $contact}
                                    <option value="c{$contact.id}">{$contact.name}</option>
                                {/foreach}
                            </select>
                        </div>
                        <label class="radio-label"><input type="radio" name="wc[{$contactdetail}]" id="{$contactdetail}2" value="custom" onclick="useCustomWhois(this.id)" checked> {lang key='domaincontactusecustom'}</label>
                        {foreach $values as $name => $value}
                            <div class="form-group">
                                <label class="form-label">{$contactdetailstranslations[$name]}</label>
                                <input type="text" name="contactdetails[{$contactdetail}][{$name}]" value="{$value}" data-original-value="{$value}" class="form-input {$contactdetail}customwhois{if array_key_exists($contactdetail, $irtpFields) && in_array($name, $irtpFields[$contactdetail])} irtp-field{/if}">
                            </div>
                        {/foreach}
                    </div>
                {/foreach}
            </div>

            {if $domainInformation && $irtpFields}
                <input id="irtpOptOut" type="hidden" name="irtpOptOut" value="0">
                <input id="irtpOptOutReason" type="hidden" name="irtpOptOutReason" value="">
            {/if}

            <div class="btn-group">
                <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
                <button type="reset" class="btn btn-secondary">{lang key='clientareacancel'}</button>
            </div>
        </form>
    </div>
</div>
