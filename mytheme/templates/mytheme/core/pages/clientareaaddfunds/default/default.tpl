{* Hostnodes — Add Funds (Apple-style).

   WHMCS standard variables on /clientarea.php?action=addfunds:
     $minimumamount      — minimum top-up
     $maximumamount      — maximum top-up
     $maximumbalance     — credit balance cap
     $currency           — currency code object with prefix/suffix
     $paymentmethods     — array of gateway: name, displayname
     $errormessage       — array/string of validation errors
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaaddfunds.css?v={$myTheme.version|default:'1.0'}">

<div class="af-wrap">
    <div class="card af-card">
        <h1 class="af-title">{$LANG.addfunds|default:'Add funds to account credit'}</h1>
        <p class="af-sub">{$LANG.addfundssub|default:'Top up your account balance for future invoices.'}</p>

        {if isset($errormessage) && $errormessage}
        <div class="af-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=addfunds" class="af-form">
            <div class="form-group">
                <label class="form-label" for="af-amount">{$LANG.amount|default:'Amount'}{if isset($currency.prefix)} ({$currency.prefix|escape}){/if}</label>
                <input type="number" step="0.01" min="{$minimumamount|default:0|escape}"{if isset($maximumamount) && $maximumamount} max="{$maximumamount|escape}"{/if} class="form-input af-amount-input" id="af-amount" name="amount" required autofocus>
                {if isset($minimumamount) && $minimumamount}<p class="af-help">{$LANG.minamount|default:'Minimum'}: {$currency.prefix|default:''}{$minimumamount|escape}{if isset($maximumamount) && $maximumamount} · {$LANG.maxamount|default:'Maximum'}: {$currency.prefix|default:''}{$maximumamount|escape}{/if}</p>{/if}
            </div>

            {if isset($paymentmethods) && $paymentmethods|@count > 0}
            <div class="form-group">
                <label class="form-label">{$LANG.paymentmethod|default:'Payment method'}</label>
                <div class="af-methods">
                    {foreach $paymentmethods as $pm}
                    <label class="af-method">
                        <input type="radio" name="paymentmethod" value="{$pm.module|default:$pm.name|escape}" {if $pm@first}checked{/if}>
                        <span class="af-method-name">{$pm.displayname|default:$pm.name|escape}</span>
                    </label>
                    {/foreach}
                </div>
            </div>
            {/if}

            <button type="submit" class="btn-primary af-submit">{$LANG.continue|default:'Continue to payment'}</button>
        </form>
    </div>
</div>
