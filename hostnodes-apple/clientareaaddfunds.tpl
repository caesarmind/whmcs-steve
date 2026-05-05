{* =========================================================================
   clientareaaddfunds.tpl — add credit to the client account.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='addfunds'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<div class="card">
    <div class="card-body">
        <p>{lang key='addfundsdesc'}</p>
        <p class="form-hint">{lang key='addfundsmin'}: <strong>{$minimumamount}</strong></p>
        <p class="form-hint">{lang key='addfundsmax'}: <strong>{$maximumbalance}</strong></p>

        <form method="post" action="{$smarty.server.PHP_SELF}">
            <div class="form-row">
                <div class="form-group">
                    <label for="inputAmount" class="form-label">{lang key='addfundsamount'}</label>
                    <input type="text" name="amount" id="inputAmount" class="form-input" value="{$amount}" required>
                </div>
                <div class="form-group">
                    <label for="inputPaymentMethod" class="form-label">{lang key='orderpaymentmethod'}</label>
                    <select name="paymentmethod" id="inputPaymentMethod" class="form-input">
                        {foreach $gateways as $gateway}
                            <option value="{$gateway.sysname}"{if $gateway.sysname eq $paymentmethod} selected{/if}>{$gateway.name}</option>
                        {/foreach}
                    </select>
                </div>
            </div>
            <button type="submit" name="addfunds" value="true" class="btn btn-primary btn-lg">{lang key='addfunds'}</button>
        </form>
    </div>
</div>
