{* =========================================================================
   masspay.tpl — single payment covering multiple invoices.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='masspay.title'}</h1></div>

<div class="card">
    <div class="card-body">
        <p>{lang key='masspay.description'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="invoiceids" value="{$invoiceids}">

            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='invoicenumber'}</th>
                            <th>{lang key='invoicesdatedue'}</th>
                            <th class="text-right">{lang key='amount'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $invoices as $invoice}
                            <tr>
                                <td>#{$invoice.invoicenum}</td>
                                <td>{$invoice.duedate}</td>
                                <td class="text-right">{$invoice.total}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                    <tfoot>
                        <tr class="invoice-total-row grand">
                            <td colspan="2" class="text-right"><strong>{lang key='invoicestotal'}</strong></td>
                            <td class="text-right"><strong>{$grandtotal}</strong></td>
                        </tr>
                    </tfoot>
                </table>
            </div>

            <div class="form-group">
                <label for="paymentmethod" class="form-label">{lang key='orderpaymentmethod'}</label>
                <select name="paymentmethod" id="paymentmethod" class="form-input">
                    {foreach $gateways as $gateway}
                        <option value="{$gateway.sysname}">{$gateway.name}</option>
                    {/foreach}
                </select>
            </div>

            <button type="submit" name="masspay" value="true" class="btn btn-primary btn-lg">{lang key='masspay.title'}</button>
        </form>
    </div>
</div>
