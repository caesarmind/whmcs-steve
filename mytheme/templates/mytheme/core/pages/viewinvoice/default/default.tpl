{* Hostnodes — View Invoice (Apple-style).

   WHMCS standard variables expected:
     $invoiceid, $invoicenum, $status, $datecreated, $datedue, $datepaid
     $invoicedata        — array: total, subtotal, tax, tax2, credit,
                           taxrate, taxrate2, notes
     $lineitems          — array of line items: description, amount
     $transactions       — payment transactions
     $companyname
     $clientsdetails     — firstname, lastname, address1, etc.
     $paymentmethods     — available payment methods
*}

{if !isset($invoiceid) || !$invoiceid}
    {assign var=dashIsEmpty value='empty'}
{else}
    {assign var=dashIsEmpty value='full'}
{/if}
{assign var=invStatusLower value=$status|default:''|lower}
{if isset($invoicenum) && $invoicenum}{assign var=invDisplayNum value=$invoicenum}{else}{assign var=invDisplayNum value=$invoiceid}{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewinvoice.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <p class="page-eyebrow">{$LANG.invoicenum|default:'Invoice'}</p>
            <h1>{$LANG.invoicenum|default:'Invoice'} #{$invDisplayNum|escape}</h1>
            <p class="page-subtitle">
                {if isset($datecreated)}{$LANG.invoicedatecreated|default:'Issued'} {$datecreated|escape}{/if}
                {if isset($datedue)} · {$LANG.invoicedatedue|default:'Due'} {$datedue|escape}{/if}
            </p>
        </div>
        {if $status}<span class="status-pill {$invStatusLower}">{$status|escape}</span>{/if}
    </div>
</header>

<div class="when-full"><div class="inv-split">

    {* ══ MAIN ══ *}
    <div class="inv-main">

        <div class="svc-table-card" aria-hidden="true"></div>

        {* Invoice summary (Total / Due date / Issued) *}
        <div class="card">
            <div class="inv-head">
                <div class="inv-head-block">
                    <div class="label">{if $invStatusLower == 'paid'}{$LANG.invoicestotal|default:'Total'}{else}{$LANG.amountdue|default:'Amount due'}{/if}</div>
                    <div class="value big{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}">{if isset($invoicedata.total)}{$invoicedata.total|escape}{/if}</div>
                </div>
                <div class="inv-head-block">
                    <div class="label">{$LANG.invoicedatedue|default:'Due date'}</div>
                    <div class="value">{$datedue|default:'-'|escape}</div>
                </div>
                <div class="inv-head-block">
                    <div class="label">{$LANG.invoicedatecreated|default:'Invoice date'}</div>
                    <div class="value">{$datecreated|default:'-'|escape}</div>
                    <div class="sub">#{$invDisplayNum|escape}</div>
                </div>
            </div>
        </div>

        {* Addresses *}
        <div class="card">
            <div class="inv-addr">
                <div>
                    <div class="inv-addr-label">{$LANG.invoicefrom|default:'From'}</div>
                    <div class="inv-addr-text">
                        <strong>{$companyname|default:''|escape}</strong>
                    </div>
                </div>
                <div>
                    <div class="inv-addr-label">{$LANG.invoicebillto|default:'Bill to'}</div>
                    <div class="inv-addr-text">
                        {if isset($clientsdetails.firstname)}<strong>{$clientsdetails.firstname|escape} {$clientsdetails.lastname|escape}</strong><br>{/if}
                        {if isset($clientsdetails.companyname) && $clientsdetails.companyname}{$clientsdetails.companyname|escape}<br>{/if}
                        {if isset($clientsdetails.address1)}{$clientsdetails.address1|escape}<br>{/if}
                        {if isset($clientsdetails.address2) && $clientsdetails.address2}{$clientsdetails.address2|escape}<br>{/if}
                        {if isset($clientsdetails.city)}{$clientsdetails.city|escape}, {$clientsdetails.state|escape} {$clientsdetails.postcode|escape}<br>{/if}
                        {if isset($clientsdetails.country)}{$clientsdetails.country|escape}{/if}
                    </div>
                </div>
            </div>
        </div>

        {* Line items *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.invoicedetails|default:'Invoice details'}</h2></div>
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col" style="width: 70%;">{$LANG.invoicesdescription|default:'Description'}</th>
                        <th scope="col" style="text-align: right;">{$LANG.amount|default:'Amount'}</th>
                    </tr>
                </thead>
                <tbody>
                    {if isset($lineitems) && $lineitems|count > 0}
                        {foreach $lineitems as $item}
                        <tr>
                            <td class="desc">{$item.description|escape}</td>
                            <td class="amount">{$item.amount|escape}</td>
                        </tr>
                        {/foreach}
                    {/if}
                </tbody>
            </table>

            <div class="inv-totals">
                {if isset($invoicedata.subtotal)}
                <div class="inv-total-row muted"><span>{$LANG.invoicessubtotal|default:'Subtotal'}</span><span>{$invoicedata.subtotal|escape}</span></div>
                {/if}
                {if isset($invoicedata.taxrate) && $invoicedata.taxrate}
                <div class="inv-total-row muted"><span>{$LANG.invoicestax|default:'Tax'} ({$invoicedata.taxrate|escape}%)</span><span>{$invoicedata.tax|escape}</span></div>
                {/if}
                {if isset($invoicedata.taxrate2) && $invoicedata.taxrate2}
                <div class="inv-total-row muted"><span>{$LANG.invoicestax|default:'Tax'} 2 ({$invoicedata.taxrate2|escape}%)</span><span>{$invoicedata.tax2|escape}</span></div>
                {/if}
                {if isset($invoicedata.credit) && $invoicedata.credit}
                <div class="inv-total-row muted"><span>{$LANG.invoicescredit|default:'Credit applied'}</span><span>−{$invoicedata.credit|escape}</span></div>
                {/if}
                <div class="inv-total-row grand"><span>{if $invStatusLower == 'paid'}{$LANG.invoicestotal|default:'Total'}{else}{$LANG.totaldue|default:'Total due'}{/if}</span><span class="amt">{if isset($invoicedata.total)}{$invoicedata.total|escape}{/if}</span></div>
            </div>
        </div>

        {* Transactions (history) *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.invoicestransactions|default:'Transactions'}</h2></div>
            {if isset($transactions) && $transactions|count > 0}
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col">{$LANG.invoicestransdate|default:'Date'}</th>
                        <th scope="col">{$LANG.invoicestransgateway|default:'Gateway'}</th>
                        <th scope="col">{$LANG.invoicestranstransid|default:'Transaction ID'}</th>
                        <th scope="col" style="text-align: right;">{$LANG.amount|default:'Amount'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $transactions as $tx}
                    <tr>
                        <td class="period">{$tx.date|default:''|escape}</td>
                        <td class="period">{$tx.gateway|default:''|escape}</td>
                        <td class="period">{$tx.transid|default:''|escape}</td>
                        <td class="amount">{$tx.amount|default:''|escape}</td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
            {else}
            <div class="inv-tx-empty">{$LANG.invoicesnotrans|default:'No payments have been recorded for this invoice yet.'}</div>
            {/if}
        </div>

        {* Payment *}
        {if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.invoicemakepayment|default:'Make a payment'}</h2></div>
            <form method="post" action="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid}">
                <input type="hidden" name="paynow" value="true">
                <div class="inv-pay">
                    <div class="inv-pay-method-list">
                        {if isset($paymentmethods) && $paymentmethods|count > 0}
                            {foreach $paymentmethods as $pm}
                            <label class="inv-pay-method">
                                <input type="radio" name="paymentmethod" value="{$pm.module|default:''|escape}"{if $pm@first} checked{/if}>
                                <span class="inv-pay-method-logo">{$pm.shortname|default:'PAY'|escape|truncate:4:""}</span>
                                <div class="inv-pay-method-meta">
                                    <div class="inv-pay-method-name">{$pm.displayname|default:$pm.module|escape}</div>
                                </div>
                            </label>
                            {/foreach}
                        {/if}
                    </div>
                    <button type="submit" class="btn-primary inv-pay-btn">{$LANG.invoicepay|default:'Pay'} {if isset($invoicedata.total)}{$invoicedata.total|escape}{/if}</button>
                </div>
            </form>
        </div>
        {/if}
    </div>

    {* ══ RIGHT: Actions sidebar ══ *}
    <aside class="inv-aside">
        <div class="card inv-aside-card">
            <div class="inv-aside-heading">{$LANG.summary|default:'Summary'}</div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{$LANG.invoicesstatus|default:'Status'}</div>
                <div class="inv-aside-summary-value"><span class="status-pill {$invStatusLower}">{$status|escape}</span></div>
            </div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{if $invStatusLower == 'paid'}{$LANG.invoicestotal|default:'Total'}{else}{$LANG.amountdue|default:'Amount due'}{/if}</div>
                <div class="inv-aside-summary-value{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}">{if isset($invoicedata.total)}{$invoicedata.total|escape}{/if}</div>
            </div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{$LANG.invoicedatedue|default:'Due date'}</div>
                <div class="inv-aside-summary-value">{$datedue|default:'-'|escape}</div>
            </div>
        </div>

        <div class="card inv-aside-card">
            <div class="inv-aside-heading">{$LANG.actions|default:'Actions'}</div>
            <div class="inv-actions-card-inner">
                <a href="{$WEB_ROOT}/dl.php?type=i&id={$invoiceid}" class="inv-action" download>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    {$LANG.invoicedownload|default:'Download'}
                </a>
            </div>
        </div>

        {* Billing sub-nav *}
        <div class="card subnav-card">
            <div class="subnav-heading-row">{$LANG.billing|default:'Billing'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item-row active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.myinvoices|default:'My Invoices'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item-row">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.myquotes|default:'My Quotes'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="subnav-item-row">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/></svg>
                {$LANG.masspayment|default:'Mass Payment'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="subnav-item-row">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.addfunds|default:'Add Funds'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=paymentmethods" class="subnav-item-row">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
        </div>
    </aside>
</div></div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
        </svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$LANG.invoicenotfound|default:'Invoice not found'}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$LANG.invoicenotfoundsub|default:"This invoice doesn't exist or has been removed from your account."}</p>
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.allinvoices|default:'All invoices'}</a>
</div>
