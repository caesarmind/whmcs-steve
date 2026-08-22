{* Hostnodes — Mass Payment.

   REAL WHMCS variables on /clientarea.php?action=masspay, verified against
   stock six/masspay.tpl. The previous version of this file invented all of
   them, so the page could only ever render its empty state:

     WRONG (invented)      RIGHT (WHMCS)
     $invoices             $invoiceitems   keyed by invoice id; each entry is
                                           that invoice's LINE ITEMS, not a
                                           single invoice row
     $inv.invoicenum       $invoiceitem.0.invoicenum
     $totalamount          $total
     $paymentmethods       $gateways       with .sysname / .name
     name="invoices[]"     name="invoiceids[]"
     name="paynow"         name="geninvoice"

   Mass Pay generates ONE invoice covering everything listed, so every invoice
   is submitted via a hidden input exactly as stock does. The old per-row
   checkboxes implied you could pay a subset, but nothing recomputed the total
   when you unticked one — the summary kept showing the full amount while the
   form submitted less. Removed rather than half-built.
*}

{if isset($invoiceitems) && $invoiceitems|@count > 0}
    {assign var=mpCount value=$invoiceitems|@count}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=mpCount value=0}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/masspay.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); } })();
</script>

<header class="page-header">
    <h1>{$LANG.masspaytitle}</h1>
    <p class="page-subtitle">{$LANG.masspaydescription}</p>
</header>

<div class="mp-wrap">
    {if isset($errormessage) && $errormessage}
    <div class="mp-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
    {/if}

    <div class="when-full">
        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=masspay" class="mp-form">
            <input type="hidden" name="token" value="{$token}" />
            <input type="hidden" name="geninvoice" value="true">

            <div class="card mp-table-card">
                <table class="mp-table">
                    <thead>
                        <tr>
                            <th class="mp-col-invoice">{$LANG.invoicesdescription}</th>
                            <th class="mp-col-amount">{$LANG.invoicesamount}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $invoiceitems as $invid => $invoiceitem}
                        <tr class="mp-invoice-head">
                            <td colspan="2">
                                <strong>{$LANG.invoicenumber} {if $invoiceitem.0.invoicenum}{$invoiceitem.0.invoicenum|escape}{else}{$invid|escape}{/if}</strong>
                                <input type="hidden" name="invoiceids[]" value="{$invid|escape}">
                            </td>
                        </tr>
                            {foreach $invoiceitem as $item}
                            <tr class="mp-line">
                                <td class="mp-col-invoice">{$item.description|escape}</td>
                                <td class="mp-col-amount">{$item.amount|escape}</td>
                            </tr>
                            {/foreach}
                        {/foreach}
                    </tbody>
                </table>
            </div>

            <div class="mp-summary">
                <div class="mp-summary-row">
                    <span class="mp-summary-label">{$LANG.invoicestotaldue}</span>
                    <span class="mp-summary-value">{$total|default:''|escape}</span>
                </div>
            </div>

            {if isset($gateways) && $gateways|@count > 0}
            <div class="card mp-pay-card">
                <div class="card-body">
                    <h2 class="mp-pay-title">{$LANG.masspaymentselectgateway}</h2>
                    <div class="mp-methods">
                        {foreach $gateways as $gateway}
                        <label class="mp-method">
                            <input type="radio" name="paymentmethod" value="{$gateway.sysname|escape}" {if $gateway@first}checked{/if}>
                            <span class="mp-method-name">{$gateway.name|escape}</span>
                        </label>
                        {/foreach}
                    </div>
                </div>
            </div>
            {/if}

            <button type="submit" class="btn-primary mp-submit">{$LANG.masspaymakepayment}</button>
        </form>
    </div>

    <div class="when-empty mp-empty">
        <div class="mp-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg></div>
        <p class="mp-empty-title">{$LANG.nounpaidinvoices|default:'No unpaid invoices'}</p>
        <p class="mp-empty-sub">{$hadrianLang.billing.noUnpaidInvoicesSub}</p>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-secondary">{$LANG.navinvoices}</a>
    </div>
</div>
