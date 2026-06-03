{* Hostnodes — Invoice Payment (standalone payment page).

   WHMCS standard variables on /invoice-payment:
     $invoiceid, $invoicenum, $total, $balance — invoice summary
     $paymentmethods                            — available gateways
     $errormessage                              — validation errors
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/invoice-payment.css?v={$myTheme.version|default:'1.0'}">

<div class="ip-wrap">
    <div class="card ip-card">
        <h1 class="ip-title">{$LANG.invoicepay}</h1>
        <p class="ip-sub">{$LANG.invoicestitle} #{$invoicenum|default:$invoiceid|escape}</p>

        {if isset($errormessage) && $errormessage}
        <div class="ip-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <div class="ip-summary">
            <div class="ip-summary-row">
                <span class="ip-summary-label">{$LANG.invoicesbalance}</span>
                <span class="ip-summary-value ip-amount">{$balance|default:$total|escape}</span>
            </div>
        </div>

        <form method="post" action="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid|default:0|escape}" class="ip-form">
            <input type="hidden" name="token" value="{$token}" />
            <input type="hidden" name="paynow" value="true">

            {if isset($paymentmethods) && $paymentmethods|@count > 0}
            <div class="form-group">
                <label class="form-label">{$LANG.orderpaymentmethod}</label>
                <div class="ip-methods">
                    {foreach $paymentmethods as $pm}
                    <label class="ip-method">
                        <input type="radio" name="paymentmethod" value="{$pm.module|default:$pm.name|escape}" {if $pm@first}checked{/if}>
                        <span class="ip-method-name">{$pm.displayname|default:$pm.name|escape}</span>
                    </label>
                    {/foreach}
                </div>
            </div>
            {/if}

            <button type="submit" class="btn-primary ip-submit">{$LANG.paynow}</button>
            <a href="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid|default:0|escape}" class="btn-secondary ip-cancel">{$LANG.cancel}</a>
        </form>
    </div>
</div>
