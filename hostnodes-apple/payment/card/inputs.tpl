{* =========================================================================
   payment/card/inputs.tpl — credit-card input fields. Included inline by any
   page that collects card details.
   ========================================================================= *}
<div class="form-group">
    <label for="cchldrname" class="form-label">{lang key='creditcardcardholdername'}</label>
    <input type="text" name="ccinputs[cchldrname]" id="cchldrname" class="form-input" autocomplete="cc-name" value="{$carddata.cchldrname}" required>
</div>

<div class="form-group">
    <label for="ccnumber" class="form-label">{lang key='creditcardnumber'}</label>
    <input type="text" name="ccinputs[ccnumber]" id="ccnumber" class="form-input" autocomplete="cc-number" value="{$carddata.ccnumber}" required>
</div>

<div class="form-row">
    <div class="form-group">
        <label for="ccexpires" class="form-label">{lang key='creditcardexpires'}</label>
        <input type="text" name="ccinputs[ccexpires]" id="ccexpires" class="form-input" autocomplete="cc-exp" placeholder="MM/YY" value="{$carddata.ccexpires}" required>
    </div>
    <div class="form-group">
        <label for="cccvv" class="form-label">{lang key='creditcardcvv'}</label>
        <input type="text" name="ccinputs[cccvv]" id="cccvv" class="form-input" autocomplete="cc-csc" maxlength="4" value="{$carddata.cccvv}" required>
    </div>
</div>

{if $startDate}
    <div class="form-row">
        <div class="form-group">
            <label for="ccstartdate" class="form-label">{lang key='creditcardstartdate'}</label>
            <input type="text" name="ccinputs[ccstartdate]" id="ccstartdate" class="form-input" placeholder="MM/YY" value="{$carddata.ccstartdate}">
        </div>
        <div class="form-group">
            <label for="ccissuenumber" class="form-label">{lang key='creditcardissuenumber'}</label>
            <input type="text" name="ccinputs[ccissuenumber]" id="ccissuenumber" class="form-input" value="{$carddata.ccissuenumber}">
        </div>
    </div>
{/if}
