{* =========================================================================
   store/order.tpl — primary order/configure page for cart items.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='cartconfig'}</h1>
    <p class="page-subtitle">{lang key='cartconfiguredesc'}</p>
</div>

{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}
{if $successmessage}{include file="$template/includes/alert.tpl" type="success" msg=$successmessage textcenter=true}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="a" value="confproduct">
    <input type="hidden" name="i" value="{$cartitemid}">

    {if $product}
        <div class="callout info">
            <i class="fas fa-info-circle"></i>
            {lang key='orderingProduct'}: <strong>{$product.name}</strong>
        </div>
    {/if}

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='orderForm.productOptions'}</h3></div>
        <div class="card-body">
            <div class="form-group">
                <label for="billingcycle" class="form-label">{lang key='orderbillingcycle'}</label>
                <select name="billingcycle" id="billingcycle" class="form-input">
                    {foreach $pricingcycles as $cycle => $price}
                        <option value="{$cycle}"{if $cycle eq $selectedcycle} selected{/if}>{$cycle} &mdash; {$price}</option>
                    {/foreach}
                </select>
            </div>

            {if $domainRequired}
                <div class="form-group">
                    <label for="orderDomain" class="form-label">{lang key='orderdomain'}</label>
                    <input type="text" name="domain" id="orderDomain" value="{$domain}" class="form-input" required>
                </div>
            {/if}

            {if $configurableoptions}
                <div class="form-section">
                    <h4 class="form-section-title">{lang key='orderconfigpackage'}</h4>
                    {foreach $configurableoptions as $option}
                        <div class="form-group">
                            <label class="form-label">{$option.name}</label>
                            {$option.input}
                        </div>
                    {/foreach}
                </div>
            {/if}

            {if $customfields}
                <div class="form-section">
                    <h4 class="form-section-title">{lang key='orderForm.additionalInformation'}</h4>
                    {foreach $customfields as $customfield}
                        <div class="form-group">
                            <label class="form-label">{$customfield.name}</label>
                            {$customfield.input}
                        </div>
                    {/foreach}
                </div>
            {/if}

            {if $addons}
                <div class="form-section">
                    <h4 class="form-section-title">{lang key='orderForm.addOns'}</h4>
                    {foreach $addons as $addon}
                        <label class="checkbox-label">
                            <input type="checkbox" name="addons[{$addon.id}]" class="form-checkbox"{if $addon.selected} checked{/if}>
                            <span><strong>{$addon.name}</strong> &mdash; {$addon.pricing}<br><small class="form-hint">{$addon.description}</small></span>
                        </label>
                    {/foreach}
                </div>
            {/if}
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary btn-lg">{lang key='orderForm.continueShopping'}</button>
        <a href="{$WEB_ROOT}/cart.php?a=view" class="btn btn-secondary">{lang key='cartviewcart'}</a>
    </div>
</form>
