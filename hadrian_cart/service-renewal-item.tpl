{*
 * hadrian_cart/service-renewal-item.tpl
 *
 * Renderer for a single service-renewal row. Included twice:
 *   1. By service-renewals.tpl, iterating over $renewableServices,
 *      with prefix='' (top-level service rows).
 *   2. Recursively from inside itself for each addon, with prefix='a-'
 *      (so the remove-cart-line POST can tell service vs addon apart).
 *
 * Variables WHMCS hands in (as $renewableItems on first call,
 * effectively each $renewableItem when iterated):
 *   $renewableItem.product->name           string
 *   $renewableItem.serviceId               int
 *   $renewableItem.domain                  string (may be blank for addons)
 *   $renewableItem.renewable               bool
 *   $renewableItem.renewableCount          int (addons-only)
 *   $renewableItem.nextDueDate             Carbon|null
 *   $renewableItem.nextPayUntilDate        Carbon
 *   $renewableItem.price                   formatted string
 *   $renewableItem.reason                  string (when !renewable)
 *   $renewableItem.addons                  array (top-level only)
 *   $prefix                                ''|'a-'  -- service vs addon id namespace
 *
 * Contract preserved verbatim:
 *   - Outer .service-renewal wrapper with data-product-name +
 *     data-service-id + data-service-domain attrs. scripts.min.js's
 *     recalculateRenewalTotals() + the search filter both query by
 *     these.
 *   - Inline "display:none" + data-is-renewable="false" on
 *     non-renewable rows (the search-filter JS toggles between
 *     showing all and hiding non-renewable depending on the
 *     hide/show button state).
 *   - .btn-add-renewal-to-cart button id = "renewService{serviceId}"
 *     for the top-level call and "a-{addonId}" for the addons
 *     recursion. data-service-id="{$prefix}{$renewableItem.serviceId}"
 *     is what the AJAX add-to-cart handler keys off.
 *   - .to-add / .added inner-span swap inside the button (scripts.min.js
 *     toggles a parent class to flip between the two states).
 *   - .addon-renewals child wrapper with its own data-is-renewable.
 *
 * Apple visual layer:
 *   - Card surface, hairline border, light shadow inherited from
 *     style.min.css's .service-renewal restyling.
 *   - Status labels (.label-info / .label-warning) re-coloured as
 *     soft Apple status pills.
 *   - "Add to cart" button is restyled to the Apple secondary CTA.
 *}

{foreach $renewableItems as $renewableItem}
    <div class="service-renewal{if $renewableItem.renewable === false} is-unrenewable{/if}"
         data-product-name="{$renewableItem.product->name|escape}"
         data-service-id="{$renewableItem.serviceId}"
         data-service-domain="{$renewableItem.domain|escape}"
         {if $renewableItem.renewable === false}style="display: none;" data-is-renewable="false"{else}data-is-renewable="true"{/if}>

        <div class="service-renewal-head">
            <div class="service-renewal-titles">
                <h3 class="font-size-24 service-renewal-product">
                    {$renewableItem.product->name|escape}
                </h3>
                {if $renewableItem.domain}
                    <h4 class="font-size-22 service-renewal-domain">
                        {$renewableItem.domain|escape}
                    </h4>
                {/if}
            </div>

            <div class="service-renewal-status pull-right float-right">
                {if $renewableItem.renewable === false}
                    <span class="label label-info renewal-pill renewal-pill--muted">
                        {lang key='renewService.renewalUnavailable'}
                    </span>
                {else}
                    <span class="label label-warning renewal-pill renewal-pill--warn">
                        {lang key='renewService.renewingIn' days=$renewableItem.nextDueDate->diffInDays()}
                    </span>
                {/if}
            </div>
        </div>

        <p class="service-renewal-due">
            {if is_null($renewableItem.nextDueDate)}
                {lang key='renewService.serviceNextDueDateBasic' nextDueDate={lang key='na'}}
            {else}
                {lang key='renewService.serviceNextDueDateExtended' nextDueDate=$renewableItem.nextDueDate->toClientDateFormat() nextDueDateFormatted=$renewableItem.nextDueDate->diffForHumans()}
            {/if}
        </p>

        <div class="clearfix service-renewal-foot">
            <div class="pull-left float-left service-renewal-meta">
                {if $renewableItem.renewable === false}
                    <div class="div-renewal-ineligible">
                        <i class="fas fa-info-circle"></i>
                        <span>{$renewableItem.reason|escape}</span>
                    </div>
                {else}
                    <div class="div-renewal-period-label">
                        {lang key='renewService.renewalPeriodLabel'}
                    </div>
                    <div class="service-renewal-period">
                        {lang key='renewService.renewalPeriod' nextDueDate=$renewableItem.nextDueDate->toClientDateFormat() nextPayUntilDate=$renewableItem.nextPayUntilDate->toClientDateFormat() renewalPrice=$renewableItem.price}
                    </div>
                {/if}
            </div>

            {if $renewableItem.renewable === true}
                <button id="renewService{$renewableItem.serviceId}"
                        class="btn btn-default btn-add-renewal-to-cart pull-right float-right"
                        data-service-id="{$prefix}{$renewableItem.serviceId}">
                    <span class="to-add">
                        <i class="fas fa-fw fa-spinner fa-spin"></i>
                        {lang key='addtocart'}
                    </span>
                    <span class="added">
                        <i class="fas fa-check"></i>&nbsp;{lang key='domaincheckeradded'}
                    </span>
                </button>
            {/if}
        </div>

        {if !empty($renewableItem.addons)}
            <div class="addon-renewals"
                 {if $renewableItem.renewableCount <= 0}style="display: none;" data-is-renewable="false"{else}data-is-renewable="true"{/if}>
                <h4 class="font-size-22 addon-renewals-heading">{lang key='cartproductaddons'}</h4>
                <div class="addon-renewals-list">
                    {include file="orderforms/$carttpl/service-renewal-item.tpl" renewableItems=$renewableItem.addons prefix='a-'}
                </div>
            </div>
        {/if}

    </div>
{/foreach}
