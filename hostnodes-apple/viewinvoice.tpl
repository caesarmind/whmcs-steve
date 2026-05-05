{* =========================================================================
   viewinvoice.tpl — single invoice view with line items, addresses, total.
   Standalone HTML document (like nexus/viewinvoice.tpl). Uses apple theme
   classes throughout.
   ========================================================================= *}
<!DOCTYPE html>
<html lang="{$activeLocale.language|default:'en'}">
<head>
    <meta charset="{$charset}">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$companyname} - {$pagetitle}</title>
    <link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome.min.css" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome-solid.min.css" rel="stylesheet">
    <link href="{$WEB_ROOT}/assets/fonts/css/fontawesome-regular.min.css" rel="stylesheet">
    {assetExists file="custom.css"}<link href="{$__assetPath__}" rel="stylesheet">{/assetExists}
    <script>var whmcsBaseUrl = "{$WEB_ROOT}";</script>
    <script src="{assetPath file='scripts.min.js'}?v={$versionHash}"></script>
</head>
<body class="invoice-page">

<div class="invoice-container">
    {if $invalidInvoiceIdRequested}
        {include file="$template/includes/alert.tpl" type="danger" title="{lang key='error'}" msg="{lang key='invoiceserror'}" textcenter=true}
    {else}
        <div class="invoice-detail-header">
            <div class="invoice-detail-brand">
                {if $logo}<img src="{$logo}" alt="{$companyname}">{else}<h2>{$companyname}</h2>{/if}
                <h3 class="invoice-title">{$pagetitle}</h3>
            </div>
            <div class="invoice-detail-status">
                {if $status eq "Draft"}<span class="status-pill warning">{lang key='invoicesdraft'}</span>
                {elseif $status eq "Unpaid"}<span class="status-pill unpaid">{lang key='invoicesunpaid'}</span>
                {elseif $status eq "Paid"}<span class="status-pill paid">{lang key='invoicespaid'}</span>
                {elseif $status eq "Refunded"}<span class="status-pill info">{lang key='invoicesrefunded'}</span>
                {elseif $status eq "Cancelled"}<span class="status-pill cancelled">{lang key='invoicescancelled'}</span>
                {elseif $status eq "Collections"}<span class="status-pill danger">{lang key='invoicescollections'}</span>
                {elseif $status eq "Payment Pending"}<span class="status-pill warning">{lang key='invoicesPaymentPending'}</span>{/if}

                {if $status eq "Unpaid" || $status eq "Draft"}
                    <div class="invoice-due-date form-hint">{lang key='invoicesdatedue'}: {$datedue}</div>
                    <div class="invoice-pay-btn d-print-none">{$paymentbutton}</div>
                {/if}
            </div>
        </div>

        {if isset($customAlert) && is_array($customAlert)}
            {include file="$template/includes/alert.tpl" type=$customAlert.type|escape title=$customAlert.title|escape msg=$customAlert.message|escape textcenter=true}
        {elseif $paymentSuccessAwaitingNotification}
            {include file="$template/includes/alert.tpl" type="success" title="{lang key='success'}" msg="{lang key='invoicePaymentSuccessAwaitingNotify'}" textcenter=true}
        {elseif $paymentSuccess}
            {include file="$template/includes/alert.tpl" type="success" title="{lang key='success'}" msg="{lang key='invoicepaymentsuccessconfirmation'}" textcenter=true}
        {elseif $paymentInititated}
            {include file="$template/includes/alert.tpl" type="info" title="{lang key='success'}" msg="{lang key='invoicePaymentInitiated'}" textcenter=true}
        {elseif $pendingReview}
            {include file="$template/includes/alert.tpl" type="info" title="{lang key='success'}" msg="{lang key='invoicepaymentpendingreview'}" textcenter=true}
        {elseif $paymentFailed}
            {include file="$template/includes/alert.tpl" type="danger" title="{lang key='error'}" msg="{lang key='invoicepaymentfailedconfirmation'}" textcenter=true}
        {elseif $offlineReview}
            {include file="$template/includes/alert.tpl" type="info" title="{lang key='success'}" msg="{lang key='invoiceofflinepaid'}" textcenter=true}
        {/if}

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
                    {if $clientsdetails.address2}{$clientsdetails.address2}<br>{/if}
                    {$clientsdetails.city}, {$clientsdetails.state} {$clientsdetails.postcode}<br>
                    {$clientsdetails.country}
                </address>
            </div>
        </div>

        <div class="invoice-meta">
            <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='invoicenumber'}</span><span class="invoice-meta-value">{$invoicenum}</span></div>
            <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='invoicesdatecreated'}</span><span class="invoice-meta-value">{$datecreated}</span></div>
            <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='invoicesdatedue'}</span><span class="invoice-meta-value">{$datedue}</span></div>
            {if $datepaid && $datepaid != '0000-00-00 00:00:00'}
                <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='invoicesdatepaid'}</span><span class="invoice-meta-value">{$datepaid}</span></div>
            {/if}
        </div>

        <div class="invoice-items">
            <table class="table invoice-items-table">
                <thead>
                    <tr>
                        <th>{lang key='invoicesdescription'}</th>
                        <th class="text-right">{lang key='invoicesamount'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $invoiceitems as $item}
                        <tr>
                            <td>{$item.description|nl2br}</td>
                            <td class="text-right">{$item.amount}</td>
                        </tr>
                    {/foreach}
                </tbody>
                <tfoot>
                    <tr><td class="text-right">{lang key='invoicessubtotal'}</td><td class="text-right">{$subtotal}</td></tr>
                    {if $tax && $tax != '0.00'}<tr><td class="text-right">{$taxrate}% {$taxname}</td><td class="text-right">{$tax}</td></tr>{/if}
                    {if $tax2 && $tax2 != '0.00'}<tr><td class="text-right">{$taxrate2}% {$taxname2}</td><td class="text-right">{$tax2}</td></tr>{/if}
                    {if $credit && $credit != '0.00'}<tr><td class="text-right">{lang key='invoicescredit'}</td><td class="text-right">{$credit}</td></tr>{/if}
                    <tr class="invoice-total-row grand"><td class="text-right">{lang key='invoicestotal'}</td><td class="text-right">{$total}</td></tr>
                    {if $balance && $balance != '0.00'}<tr class="invoice-total-row"><td class="text-right">{lang key='invoicesbalance'}</td><td class="text-right">{$balance}</td></tr>{/if}
                </tfoot>
            </table>
        </div>

        {if $transactions}
            <div class="invoice-transactions">
                <h3>{lang key='invoicestransactions'}</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='invoicestransdate'}</th>
                            <th>{lang key='invoicestransgateway'}</th>
                            <th>{lang key='invoicestransid'}</th>
                            <th class="text-right">{lang key='invoicestransamount'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $transactions as $trans}
                            <tr>
                                <td>{$trans.date}</td>
                                <td>{$trans.gateway}</td>
                                <td>{$trans.transid}</td>
                                <td class="text-right">{$trans.amount}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}

        {if $notes}
            <div class="invoice-notes">
                <h3>{lang key='invoicesnotes'}</h3>
                <p>{$notes|nl2br}</p>
            </div>
        {/if}

        <div class="invoice-actions d-print-none">
            <a href="clientarea.php?action=invoices" class="btn btn-secondary"><i class="fas fa-arrow-left"></i> {lang key='backtoinvoices'}</a>
            <a href="dl.php?type=i&amp;id={$invoiceid}" class="btn btn-secondary"><i class="far fa-file-pdf"></i> {lang key='invoicesdownload'}</a>
            <button type="button" onclick="window.print();" class="btn btn-secondary"><i class="fas fa-print"></i> {lang key='invoicesprint'}</button>
        </div>
    {/if}
</div>

</body>
</html>
