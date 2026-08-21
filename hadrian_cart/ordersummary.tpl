{*
 * hadrian_cart/ordersummary.tpl
 *
 * Server-side partial — NOT a standalone page. WHMCS renders this
 * inside configureproduct.tpl's #producttotal div whenever the live
 * recalctotals() AJAX call returns. Keeping the exact markup ensures
 * scripts.min.js + recalctotals() can find the .clearfix rows + the
 * .total-due-today block they expect.
 *
 * Styling comes from core-layout.css scoped via
 * body[data-tpl="configureproduct"] / [data-tpl="viewcart"], etc.
 *
 * Contract preserved: removeItem('r', id, type) inline handlers,
 * #cartServiceRenewal{id}, #cartServiceAddonRenewal{id},
 * #cartDomainRenewal{id}, #linkCartRemoveServiceRenewal{id}, etc.,
 * .product-name / .product-group / .summary-totals / .total-due-today
 * / .amt class hooks.
 *}

{if $producttotals}
    <span class="product-name">{if $producttotals.allowqty && $producttotals.qty > 1}{$producttotals.qty} x {/if}{$producttotals.productinfo.name}</span>
    <span class="product-group">{$producttotals.productinfo.groupname}</span>

    <div class="clearfix summary-row">
        <span class="pull-left float-left">{$producttotals.productinfo.name}</span>
        <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$producttotals.pricing.baseprice}</span>
    </div>

    {foreach $producttotals.configoptions as $configoption}
        {if $configoption}
            <div class="clearfix summary-row summary-row-sub">
                <span class="pull-left float-left">&nbsp;&raquo; {$configoption.name}: {$configoption.optionname}</span>
                <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$configoption.recurring}{if $configoption.setup} + {$configoption.setup} {$LANG.ordersetupfee}{/if}</span>
            </div>
        {/if}
    {/foreach}

    {foreach $producttotals.addons as $addon}
        <div class="clearfix summary-row summary-row-sub">
            <span class="pull-left float-left">+ {$addon.name}</span>
            <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$addon.recurring}</span>
        </div>
    {/foreach}

    {if $producttotals.pricing.setup || $producttotals.pricing.recurring || $producttotals.pricing.addons}
        <div class="summary-totals">
            {if $producttotals.pricing.setup}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$LANG.cartsetupfees}:</span>
                    <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$producttotals.pricing.setup}</span>
                </div>
            {/if}
            {foreach from=$producttotals.pricing.recurringexcltax key=cycle item=recurring}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$cycle}:</span>
                    <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$recurring}</span>
                </div>
            {/foreach}
            {if $producttotals.pricing.tax1}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                    <span class="pull-right float-right">{$producttotals.pricing.tax1}</span>
                </div>
            {/if}
            {if $producttotals.pricing.tax2}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$carttotals.taxname2} @ {$carttotals.taxrate2}%:</span>
                    <span class="pull-right float-right">{$producttotals.pricing.tax2}</span>
                </div>
            {/if}
        </div>
    {/if}

    <div class="total-due-today">
        <span class="amt">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$producttotals.pricing.totaltoday}</span>
        <span>{$LANG.ordertotalduetoday}</span>
    </div>

{elseif !empty($renewals) || !empty($serviceRenewals)}

    {if !empty($serviceRenewals)}
        {if !empty($carttotals.renewalsByType.services)}
            <span class="product-name">{lang key='renewService.titleAltPlural'}</span>
            {foreach $carttotals.renewalsByType.services as $serviceId => $serviceRenewal}
                <div class="clearfix summary-row" id="cartServiceRenewal{$serviceId}">
                    <div class="pull-left float-left">
                        <div>{$serviceRenewal.name}</div>
                        <div>{$serviceRenewal.domainName}</div>
                    </div>
                    <div class="pull-right float-right">
                        <div>{$serviceRenewal.billingCycle}</div>
                        <div>
                            {include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$serviceRenewal.recurringBeforeTax}
                            <a onclick="removeItem('r','{$serviceId}','service'); return false;" href="#" id="linkCartRemoveServiceRenewal{$serviceId}">
                                <i class="fas fa-fw fa-trash-alt"></i>
                            </a>
                        </div>
                    </div>
                </div>
            {/foreach}
        {/if}
        {if !empty($carttotals.renewalsByType.addons)}
            <span class="product-name">{lang key='renewServiceAddon.titleAltPlural'}</span>
            {foreach $carttotals.renewalsByType.addons as $serviceAddonId => $serviceAddonRenewal}
                <div class="clearfix summary-row" id="cartServiceAddonRenewal{$serviceAddonId}">
                    <div class="pull-left float-left">
                        <div>{$serviceAddonRenewal.name}</div>
                        <div>{$serviceAddonRenewal.domainName}</div>
                    </div>
                    <div class="pull-right float-right">
                        <div>{$serviceAddonRenewal.billingCycle}</div>
                        <div>
                            {include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$serviceAddonRenewal.recurringBeforeTax}
                            <a onclick="removeItem('r','{$serviceAddonId}','addon'); return false;" href="#" id="linkCartRemoveServiceAddonRenewal{$serviceAddonId}">
                                <i class="fas fa-fw fa-trash-alt"></i>
                            </a>
                        </div>
                    </div>
                </div>
            {/foreach}
        {/if}
    {elseif !empty($renewals) && !empty($carttotals.renewalsByType.domains)}
        <span class="product-name">{lang key='domainrenewals'}</span>
        {foreach $carttotals.renewalsByType.domains as $domainId => $renewal}
            <div class="clearfix summary-row" id="cartDomainRenewal{$domainId}">
                <span class="pull-left float-left">
                    {$renewal.domain} - {$renewal.regperiod} {if $renewal.regperiod == 1}{lang key='orderForm.year'}{else}{lang key='orderForm.years'}{/if}
                </span>
                <span class="pull-right float-right">
                    {include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$renewal.priceBeforeTax}
                    <a onclick="removeItem('r','{$domainId}','domain'); return false;" href="#" id="linkCartRemoveDomainRenewal{$domainId}">
                        <i class="fas fa-fw fa-trash-alt"></i>
                    </a>
                </span>
            </div>
            {if $renewal.dnsmanagement}
                <div class="clearfix summary-row summary-row-sub">
                    <span class="pull-left float-left">+ {lang key='domaindnsmanagement'}</span>
                </div>
            {/if}
            {if $renewal.emailforwarding}
                <div class="clearfix summary-row summary-row-sub">
                    <span class="pull-left float-left">+ {lang key='domainemailforwarding'}</span>
                </div>
            {/if}
            {if $renewal.idprotection}
                <div class="clearfix summary-row summary-row-sub">
                    <span class="pull-left float-left">+ {lang key='domainidprotection'}</span>
                </div>
            {/if}
            {if $renewal.hasGracePeriodFee}
                <div class="clearfix summary-row summary-row-sub">
                    <span class="pull-left float-left">+ {lang key='domainRenewal.graceFee'}</span>
                </div>
            {/if}
            {if $renewal.hasRedemptionGracePeriodFee}
                <div class="clearfix summary-row summary-row-sub">
                    <span class="pull-left float-left">+ {lang key='domainRenewal.redemptionFee'}</span>
                </div>
            {/if}
        {/foreach}
    {/if}

    <div class="summary-totals">
        <div class="clearfix summary-row">
            <span class="pull-left float-left">{lang key='ordersubtotal'}:</span>
            <span class="pull-right float-right">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$carttotals.subtotal}</span>
        </div>
        {if ($carttotals.taxrate && $carttotals.taxtotal) || ($carttotals.taxrate2 && $carttotals.taxtotal2)}
            {if $carttotals.taxrate}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$carttotals.taxname} @ {$carttotals.taxrate}%:</span>
                    <span class="pull-right float-right">{$carttotals.taxtotal}</span>
                </div>
            {/if}
            {if $carttotals.taxrate2}
                <div class="clearfix summary-row">
                    <span class="pull-left float-left">{$carttotals.taxname2} @ {$carttotals.taxrate2}%:</span>
                    <span class="pull-right float-right">{$carttotals.taxtotal2}</span>
                </div>
            {/if}
        {/if}
    </div>

    <div class="total-due-today">
        <span class="amt">{include file="orderforms/{$carttpl|default:'hadrian_cart'}/includes/free-price.tpl" hnPrice=$carttotals.total}</span>
        <span>{lang key='ordertotalduetoday'}</span>
    </div>

{/if}
