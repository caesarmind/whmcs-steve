{* =========================================================================
   payment/bank/inputs.tpl — ACH / direct debit input fields.
   ========================================================================= *}
<div class="form-group">
    <label for="bankaccttype" class="form-label">{lang key='bankAccountType'}</label>
    <select name="bankinputs[bankaccttype]" id="bankaccttype" class="form-input">
        <option value="Checking">{lang key='bankaccounttype.checking'}</option>
        <option value="Savings">{lang key='bankaccounttype.savings'}</option>
    </select>
</div>
<div class="form-group">
    <label for="bankname" class="form-label">{lang key='bankName'}</label>
    <input type="text" name="bankinputs[bankname]" id="bankname" class="form-input" value="{$bankdata.bankname}" required>
</div>
<div class="form-row">
    <div class="form-group">
        <label for="bankroutingno" class="form-label">{lang key='bankroutingno'}</label>
        <input type="text" name="bankinputs[bankroutingno]" id="bankroutingno" class="form-input" value="{$bankdata.bankroutingno}" required>
    </div>
    <div class="form-group">
        <label for="bankacctno" class="form-label">{lang key='bankacctno'}</label>
        <input type="text" name="bankinputs[bankacctno]" id="bankacctno" class="form-input" value="{$bankdata.bankacctno}" required>
    </div>
</div>
