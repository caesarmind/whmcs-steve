{* =========================================================================
   viewquote.tpl — single quote view with line items and accept/decline.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='quotenumber'} #{$quote.id}</h1>
    <div class="btn-group">
        <a href="dl.php?type=q&amp;id={$quote.id}" class="btn btn-secondary"><i class="far fa-file-pdf"></i> {lang key='download'}</a>
        <button onclick="window.print()" class="btn btn-secondary"><i class="fas fa-print"></i> {lang key='print'}</button>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">{$quote.subject}</h3>
        <span class="status-pill {$quote.stage|strtolower}">{$quote.stage}</span>
    </div>
    <div class="card-body">
        <div class="invoice-meta">
            <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='datecreated'}</span><span class="invoice-meta-value">{$quote.datecreated}</span></div>
            <div class="invoice-meta-item"><span class="invoice-meta-label">{lang key='validuntil'}</span><span class="invoice-meta-value">{$quote.validuntil}</span></div>
        </div>

        <div class="invoice-items">
            <table class="table invoice-items-table">
                <thead>
                    <tr>
                        <th>{lang key='description'}</th>
                        <th class="text-right">{lang key='amount'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $quoteitems as $item}
                        <tr><td>{$item.description|nl2br}</td><td class="text-right">{$item.amount}</td></tr>
                    {/foreach}
                </tbody>
                <tfoot>
                    <tr><td class="text-right">{lang key='invoicessubtotal'}</td><td class="text-right">{$subtotal}</td></tr>
                    {if $tax}<tr><td class="text-right">{$taxrate}% {$taxname}</td><td class="text-right">{$tax}</td></tr>{/if}
                    <tr class="invoice-total-row grand"><td class="text-right">{lang key='invoicestotal'}</td><td class="text-right">{$total}</td></tr>
                </tfoot>
            </table>
        </div>

        {if $quote.customernotes}
            <div class="invoice-notes">
                <h4>{lang key='notes'}</h4>
                <p>{$quote.customernotes|nl2br}</p>
            </div>
        {/if}

        {if $quote.stage eq 'Delivered' || $quote.stage eq 'Draft'}
            <div class="btn-group mt-3">
                <a href="?id={$quote.id}&action=accept" class="btn btn-primary">{lang key='acceptquote'}</a>
            </div>
        {/if}
    </div>
</div>
