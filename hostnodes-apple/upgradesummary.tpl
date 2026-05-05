{* =========================================================================
   upgradesummary.tpl — final review before committing an upgrade.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='upgradesummary'}</h1></div>

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='upgradesummaryreview'}</h3></div>
    <div class="card-body">
        <div class="product-meta-grid">
            <div class="product-meta-item"><div class="product-meta-label">{lang key='currentpackage'}</div><div class="product-meta-value">{$oldproduct}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='newpackage'}</div><div class="product-meta-value">{$newproduct}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='orderbillingcycle'}</div><div class="product-meta-value">{$billingcycle}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='upgradecharge'}</div><div class="product-meta-value"><strong>{$upgradeprice}</strong></div></div>
        </div>

        <form method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="confirm" value="true">
            <input type="hidden" name="id" value="{$id}">

            <div class="form-group mt-3">
                <label for="paymentmethod" class="form-label">{lang key='orderpaymentmethod'}</label>
                <select name="paymentmethod" id="paymentmethod" class="form-input">
                    {foreach $gateways as $gateway}
                        <option value="{$gateway.sysname}">{$gateway.name}</option>
                    {/foreach}
                </select>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn btn-primary btn-lg">{lang key='confirmupgrade'}</button>
                <a href="clientarea.php?action=productdetails&id={$id}" class="btn btn-secondary">{lang key='cancel'}</a>
            </div>
        </form>
    </div>
</div>
