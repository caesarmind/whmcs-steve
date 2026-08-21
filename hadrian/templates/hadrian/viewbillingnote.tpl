{* Hostnodes - View Billing Note (credit / debit note).

   Reached from the invoice ledger reference links (/index.php/billing/credit/{id}
   and /billing/debit/{id}). This WHMCS route does NOT supply the client-area nav /
   auth context ($loggedin is false here), so including the normal header/footer
   chrome renders an EMPTY guest sidebar. Stock nexus avoids this by making the
   billing note a self-contained document with no sidebar - we do the same, theme-
   styled: load the theme CSS directly and render a clean, centred note. (hadrian
   previously shipped no viewbillingnote.tpl at all, so the route was a blank page.)

   Variables (verified against stock nexus viewbillingnote.tpl - all OBJECTS):
     $billingNote->lineItems  (each ->description, ->isTaxed, ->amount)
     $billingNote->subTotal / ->taxes (each ->rate, ->name, ->price) / ->total / ->balance
     $transactions            (each ->clientDate, ->typeLabel, ->clientReferenceId, ->amount)
     $logo, $issuedBy, $taxCode, $taxIdLabel, $itemTableTitle, $dateIssued, $notes
     $companyname, $pagetitle, $clientsdetails
*}<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$companyname|default:''|escape} - {$pagetitle|escape}</title>
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/core-theme.css?v={$hadrian.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/core-layout.css?v={$hadrian.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewinvoice.css?v={$hadrian.version|default:'1.0'}">
    <style>{literal}
        body { background: var(--color-bg); margin: 0; min-height: 100vh; }
        .vbn-doc { max-width: 880px; margin: 0 auto; padding: 36px 20px 56px; }
        .vbn-brand { display: flex; align-items: center; gap: 10px; margin-bottom: 24px; }
        .vbn-brand img { max-height: 40px; width: auto; }
        .vbn-brand .vbn-brand-name { font-size: var(--text-lg); font-weight: var(--fw-semibold); color: var(--color-text-primary); letter-spacing: -0.014em; }
        .vbn-stack { display: flex; flex-direction: column; gap: 16px; }
        .vbn-actions { display: flex; gap: 10px; margin-top: 20px; }
        @media print { .vbn-actions { display: none !important; } body { background: #fff; } }
    {/literal}</style>
</head>
<body>
<div class="vbn-doc">

    <div class="vbn-brand">
        {if isset($logo) && $logo}
            <img src="{$logo}" alt="{$companyname|default:''|escape}">
        {else}
            <span class="vbn-brand-name">{$companyname|default:''|escape}</span>
        {/if}
    </div>

    <header class="page-header">
        <p class="page-eyebrow">{$itemTableTitle|default:$hadrianLang.billing.billingNoteEyebrow|escape}</p>
        <h1>{$pagetitle|escape}</h1>
        {if isset($dateIssued) && $dateIssued}<p class="page-subtitle">{$LANG.billing.issuedate} {$dateIssued|escape}</p>{/if}
    </header>

    <div class="vbn-stack">

        {* Issued by / Issued to *}
        <div class="card">
            <div class="inv-addr">
                <div>
                    <div class="inv-addr-label">{$LANG.billing.issuedby}</div>
                    <div class="inv-addr-text">
                        <strong>{$companyname|default:''|escape}</strong>
                        {if isset($issuedBy) && $issuedBy}<br>{$issuedBy}{/if}
                        {if isset($taxCode) && $taxCode}<br>{$taxIdLabel|default:$hadrianLang.billing.taxIdFallback|escape}: {$taxCode|escape}{/if}
                    </div>
                </div>
                <div>
                    <div class="inv-addr-label">{$LANG.billing.issuedto}</div>
                    <div class="inv-addr-text">
                        {if isset($clientsdetails.companyname) && $clientsdetails.companyname}{$clientsdetails.companyname|escape}<br>{/if}
                        {if isset($clientsdetails.firstname)}<strong>{$clientsdetails.firstname|escape} {$clientsdetails.lastname|escape}</strong><br>{/if}
                        {if isset($clientsdetails.address1)}{$clientsdetails.address1|escape}<br>{/if}
                        {if isset($clientsdetails.address2) && $clientsdetails.address2}{$clientsdetails.address2|escape}<br>{/if}
                        {if isset($clientsdetails.city)}{$clientsdetails.city|escape}, {$clientsdetails.state|escape} {$clientsdetails.postcode|escape}<br>{/if}
                        {if isset($clientsdetails.country)}{$clientsdetails.country|escape}{/if}
                    </div>
                </div>
            </div>
        </div>

        {* Line items + totals *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$itemTableTitle|default:$hadrianLang.billing.detailsFallback|escape}</h2></div>
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col" style="width: 70%;">{$LANG.invoicesdescription}</th>
                        <th scope="col" style="text-align: right;">{$LANG.invoicesamount}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $billingNote->lineItems as $item}
                    <tr>
                        <td class="desc">{$item->description}{if $item->isTaxed eq "true"} *{/if}</td>
                        <td class="amount">{$item->amount}</td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
            <div class="inv-totals">
                <div class="inv-total-row muted"><span>{$LANG.invoicessubtotal}</span><span>{$billingNote->subTotal}</span></div>
                {foreach $billingNote->taxes as $tax}
                <div class="inv-total-row muted"><span>{$tax->rate} {$tax->name}</span><span>{$tax->price}</span></div>
                {/foreach}
                <div class="inv-total-row grand"><span>{$LANG.invoicestotal}</span><span class="amt">{$billingNote->total}</span></div>
            </div>
        </div>

        {* Ledger *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.billing.ledger.title}</h2></div>
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col">{$LANG.billing.ledger.date}</th>
                        <th scope="col">{$LANG.billing.ledger.type}</th>
                        <th scope="col">{$LANG.billing.ledger.reference}</th>
                        <th scope="col" style="text-align: right;">{$LANG.invoicestransamount}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $transactions as $transaction}
                    <tr>
                        <td class="period">{$transaction->clientDate}</td>
                        <td class="period">{$transaction->typeLabel}</td>
                        <td class="period">{$transaction->clientReferenceId}</td>
                        <td class="amount">{$transaction->amount}</td>
                    </tr>
                    {foreachelse}
                    <tr>
                        <td colspan="4" style="text-align:center;color:var(--color-text-tertiary);">{$LANG.invoicestransnonefound}</td>
                    </tr>
                    {/foreach}
                    <tr>
                        <td colspan="3" style="text-align:right;font-weight:var(--fw-semibold);color:var(--color-text-primary);border-top:0.5px solid var(--color-border);">{$LANG.invoicesbalance}</td>
                        <td class="amount" style="font-weight:var(--fw-semibold);border-top:0.5px solid var(--color-border);">{$billingNote->balance}</td>
                    </tr>
                </tbody>
            </table>
        </div>

        {if isset($notes) && $notes}
        <div class="card"><div style="padding:18px 24px;font-size:var(--text-base);color:var(--color-text-secondary);letter-spacing:-0.008em;line-height:1.6;">{$notes}</div></div>
        {/if}

    </div>

    <div class="vbn-actions">
        <a href="javascript:window.print()" class="btn-secondary">{$LANG.print}</a>
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-secondary">{$LANG.invoicesbacktoclientarea}</a>
    </div>

</div>
</body>
</html>
