{* =========================================================================
   invoicepdf.tpl — print-friendly invoice layout (rendered server-side for PDF).
   ========================================================================= *}
<!DOCTYPE html>
<html>
<head>
    <meta charset="{$charset}">
    <title>{$companyname} — {lang key='invoicenumber'} #{$invoicenum}</title>
    <link href="{assetPath file='theme.min.css'}" rel="stylesheet">
</head>
<body class="invoice-page print-view">
<div class="invoice-container">
    <div class="invoice-detail-header">
        <div class="invoice-detail-brand">
            {if $logo}<img src="{$logo}" alt="{$companyname}">{else}<h2>{$companyname}</h2>{/if}
            <h3>{lang key='invoicenumber'} #{$invoicenum}</h3>
        </div>
        <div class="invoice-detail-status">
            <span class="status-pill {$status|strtolower}">{$status}</span>
            <div class="form-hint">{lang key='invoicesdatedue'}: {$datedue}</div>
        </div>
    </div>

    <div class="invoice-addresses">
        <div class="invoice-address invoice-address-from">
            <strong>{lang key='invoicespayto'}</strong>
            <address>{$payto|nl2br}</address>
        </div>
        <div class="invoice-address invoice-address-to">
            <strong>{lang key='invoicesinvoicedto'}</strong>
            <address>
                {if $clientsdetails.companyname}{$clientsdetails.companyname}<br>{/if}
                {$clientsdetails.firstname} {$clientsdetails.lastname}<br>
                {$clientsdetails.address1}<br>
                {$clientsdetails.city}, {$clientsdetails.state} {$clientsdetails.postcode}<br>
                {$clientsdetails.country}
            </address>
        </div>
    </div>

    <table class="table invoice-items-table">
        <thead>
            <tr><th>{lang key='invoicesdescription'}</th><th class="text-right">{lang key='invoicesamount'}</th></tr>
        </thead>
        <tbody>
            {foreach $invoiceitems as $item}
                <tr><td>{$item.description|nl2br}</td><td class="text-right">{$item.amount}</td></tr>
            {/foreach}
        </tbody>
        <tfoot>
            <tr><td class="text-right">{lang key='invoicessubtotal'}</td><td class="text-right">{$subtotal}</td></tr>
            {if $tax}<tr><td class="text-right">{$taxrate}% {$taxname}</td><td class="text-right">{$tax}</td></tr>{/if}
            <tr class="invoice-total-row grand"><td class="text-right">{lang key='invoicestotal'}</td><td class="text-right">{$total}</td></tr>
        </tfoot>
    </table>

    {if $transactions}
        <h3>{lang key='invoicestransactions'}</h3>
        <table class="table">
            <thead>
                <tr><th>{lang key='date'}</th><th>{lang key='gateway'}</th><th>{lang key='transid'}</th><th class="text-right">{lang key='amount'}</th></tr>
            </thead>
            <tbody>
                {foreach $transactions as $trans}
                    <tr><td>{$trans.date}</td><td>{$trans.gateway}</td><td>{$trans.transid}</td><td class="text-right">{$trans.amount}</td></tr>
                {/foreach}
            </tbody>
        </table>
    {/if}

    {if $notes}
        <div class="invoice-notes">
            <h3>{lang key='notes'}</h3>
            <p>{$notes|nl2br}</p>
        </div>
    {/if}
</div>
</body>
</html>
