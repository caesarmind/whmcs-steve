{* Hostnodes — Mass Payment (Apple-style).

   WHMCS standard variables on /clientarea.php?action=masspay:
     $invoices      — array of unpaid invoices: id, invoicenum, datedue, total
     $totalamount   — sum of selected invoices
     $paymentmethods — available gateways
     $errormessage  — validation errors
     $currency      — currency formatter
*}

{if isset($invoices) && $invoices|@count > 0}
    {assign var=mpCount value=$invoices|@count}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=mpCount value=0}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/masspay.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); } })();
</script>

<header class="page-header">
    <h1>{$LANG.masspayment|default:'Mass payment'}</h1>
    <p class="page-subtitle">{$LANG.masspaymentsub|default:'Pay multiple unpaid invoices in one transaction.'}</p>
</header>

<div class="mp-wrap">
    {if isset($errormessage) && $errormessage}
    <div class="mp-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
    {/if}

    <div class="when-full">
        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=masspay" class="mp-form">
            <input type="hidden" name="paynow" value="true">

            <div class="card mp-table-card">
                <table class="mp-table">
                    <thead>
                        <tr>
                            <th class="mp-col-check"><input type="checkbox" id="mp-all" checked></th>
                            <th class="mp-col-invoice">{$LANG.invoicenum|default:'Invoice'}</th>
                            <th class="mp-col-due">{$LANG.invoicedatedue|default:'Due date'}</th>
                            <th class="mp-col-amount">{$LANG.amount|default:'Amount'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {if $mpCount > 0}
                        {foreach $invoices as $inv}
                        <tr>
                            <td class="mp-col-check"><input type="checkbox" name="invoices[]" value="{$inv.id|escape}" checked class="mp-row-check"></td>
                            <td class="mp-col-invoice">#{$inv.invoicenum|default:$inv.id|escape}</td>
                            <td class="mp-col-due">{$inv.duedate|default:$inv.datedue|escape}</td>
                            <td class="mp-col-amount">{$inv.total|escape}</td>
                        </tr>
                        {/foreach}
                        {/if}
                    </tbody>
                </table>
            </div>

            <div class="mp-summary">
                <div class="mp-summary-row">
                    <span class="mp-summary-label">{$LANG.total|default:'Total'}</span>
                    <span class="mp-summary-value" data-mp-total>{$totalamount|default:''|escape}</span>
                </div>
            </div>

            {if isset($paymentmethods) && $paymentmethods|@count > 0}
            <div class="card mp-pay-card">
                <div class="card-body">
                    <h2 class="mp-pay-title">{$LANG.paymentmethod|default:'Payment method'}</h2>
                    <div class="mp-methods">
                        {foreach $paymentmethods as $pm}
                        <label class="mp-method">
                            <input type="radio" name="paymentmethod" value="{$pm.module|default:$pm.name|escape}" {if $pm@first}checked{/if}>
                            <span class="mp-method-name">{$pm.displayname|default:$pm.name|escape}</span>
                        </label>
                        {/foreach}
                    </div>
                </div>
            </div>
            {/if}

            <button type="submit" class="btn-primary mp-submit">{$LANG.paynow|default:'Pay now'}</button>
        </form>
    </div>

    <div class="when-empty mp-empty">
        <div class="mp-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
        <p class="mp-empty-title">{$LANG.nounpaidinvoices|default:'No unpaid invoices'}</p>
        <p class="mp-empty-sub">{$LANG.nounpaidinvoicessub|default:'You are all caught up — no balance due.'}</p>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-secondary">{$LANG.viewinvoices|default:'View all invoices'}</a>
    </div>
</div>

<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
    var all = document.getElementById('mp-all');
    var rows = document.querySelectorAll('.mp-row-check');
    if (!all || rows.length === 0) return;
    all.addEventListener('change', function () {
        rows.forEach(function (cb) { cb.checked = all.checked; });
    });
    rows.forEach(function (cb) {
        cb.addEventListener('change', function () {
            all.checked = Array.prototype.every.call(rows, function (r) { return r.checked; });
        });
    });
});
{/literal}
</script>
