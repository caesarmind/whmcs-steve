{* =========================================================================
   payment/invoice-summary.tpl — summary block rendered during checkout /
   invoice-payment flows.
   ========================================================================= *}
<div class="invoice-summary card">
    <div class="card-header"><h3 class="card-title">{lang key='invoicestitle'} #{$invoice.id}</h3></div>
    <div class="card-body">
        <div class="product-meta-grid">
            <div class="product-meta-item"><div class="product-meta-label">{lang key='invoicestotal'}</div><div class="product-meta-value"><strong>{$invoice.total}</strong></div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='invoicesdatedue'}</div><div class="product-meta-value">{$invoice.datedue}</div></div>
        </div>

        <h4 class="form-section-title">{lang key='invoiceitems'}</h4>
        <ul class="invoice-summary-items">
            {foreach $invoice.items as $item}
                <li>
                    <span>{$item.description|truncate:60:"..."}</span>
                    <span class="invoice-item-amount">{$item.amount}</span>
                </li>
            {/foreach}
        </ul>
    </div>
</div>
