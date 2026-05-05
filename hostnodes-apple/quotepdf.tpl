{* =========================================================================
   quotepdf.tpl — print-friendly quote layout (rendered server-side for PDF).
   ========================================================================= *}
<!DOCTYPE html>
<html>
<head>
    <meta charset="{$charset}">
    <title>{$companyname} — {lang key='quotenumber'} #{$quote.id}</title>
    <link href="{assetPath file='theme.min.css'}" rel="stylesheet">
</head>
<body class="invoice-page print-view">
<div class="invoice-container">
    <div class="invoice-detail-header">
        <div class="invoice-detail-brand">
            {if $logo}<img src="{$logo}" alt="{$companyname}">{else}<h2>{$companyname}</h2>{/if}
            <h3>{lang key='quotenumber'} #{$quote.id}</h3>
        </div>
        <div class="invoice-detail-status">
            <span class="status-pill {$quote.stage|strtolower}">{$quote.stage}</span>
        </div>
    </div>

    <div class="invoice-addresses">
        <div class="invoice-address invoice-address-from">
            <strong>{lang key='from'}</strong>
            <address>{$payto|nl2br}</address>
        </div>
        <div class="invoice-address invoice-address-to">
            <strong>{lang key='to'}</strong>
            <address>
                {if $quote.companyname}{$quote.companyname}<br>{/if}
                {$quote.firstname} {$quote.lastname}<br>
                {$quote.address1}<br>
                {$quote.city}, {$quote.state} {$quote.postcode}<br>
                {$quote.country}
            </address>
        </div>
    </div>

    <table class="table invoice-items-table">
        <thead>
            <tr><th>{lang key='description'}</th><th class="text-right">{lang key='amount'}</th></tr>
        </thead>
        <tbody>
            {foreach $quoteitems as $item}
                <tr><td>{$item.description|nl2br}</td><td class="text-right">{$item.amount}</td></tr>
            {/foreach}
        </tbody>
        <tfoot>
            <tr><td class="text-right">{lang key='invoicessubtotal'}</td><td class="text-right">{$subtotal}</td></tr>
            <tr class="invoice-total-row grand"><td class="text-right">{lang key='invoicestotal'}</td><td class="text-right">{$total}</td></tr>
        </tfoot>
    </table>
</div>
</body>
</html>
