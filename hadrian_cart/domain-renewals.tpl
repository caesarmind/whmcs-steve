{*
 * hadrian_cart/domain-renewals.tpl
 *
 * Bulk domain-renewal page. WHMCS routes /cart.php?a=domainrenewals
 * here. Inline list of every renewable domain on the client account
 * with a period selector + add-to-cart button per row, sticky order
 * summary on the right.
 *
 * Variables WHMCS hands in:
 *   $renewalsData              array of domain entities, each with:
 *     .domain                  string (full FQDN)
 *     .id                      int
 *     .expiryDate              Carbon
 *     .daysUntilExpiry         int (may be negative if past expiry)
 *     .eligibleForRenewal      bool
 *     .freeDomainRenewal       bool (renews free with linked service)
 *     .beforeRenewLimit        bool (too far ahead of expiry)
 *     .beforeRenewLimitDays    int
 *     .pastGracePeriod         bool
 *     .pastRedemptionGracePeriod bool
 *     .inGracePeriod           bool
 *     .inRedemptionGracePeriod bool
 *     .renewalOptions          array of period+price entries
 *
 *   $totalDomainCount         total renewable count
 *   $totalResults             how many are in this view (paginated)
 *   $hasDomainsInGracePeriod  bool, controls footer asterisk note
 *
 * Contract preserved verbatim:
 *   - #domainRenewals .domain-renewals wrapper -- AJAX rebuilder
 *     queries inside it.
 *   - .domain-renewal per-row wrapper with data-domain="{$domain}".
 *   - .select-renewal-pricing select id="renewalPricing{id}"
 *     data-domain-id="{id}" -- the change handler in scripts.min.js
 *     updates the corresponding cart item's renewal period.
 *   - .btn-add-renewal-to-cart button id="renewDomain{id}"
 *     data-domain-id="{id}" -- same add-to-cart AJAX path as
 *     service-renewal-item.tpl uses.
 *   - .to-add / .added inner-span swap.
 *   - #orderSummary > .order-summary > #orderSummaryLoader +
 *     #producttotal.
 *   - #removeRenewalForm POST contract (a=remove, r=…, i=…).
 *   - <script>recalculateRenewalTotals();</script> at bottom.
 *
 * Apple visual layer:
 *   - .renewal-pill colour ramp: success / warning / info / danger /
 *     grey -- one status per row, matched to the original .label-*
 *     class so style.min.css can paint the right token.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/$carttpl/sidebar-categories.tpl"}
        </div>

        <div class="cart-body">

            <div class="header-lined domain-renewals-header">
                <h1 class="font-size-36">
                    {if $totalResults > 1}{lang key='navrenewdomains'}{else}{lang key='domainrenew'}{/if}
                    {if $totalResults > 5}
                        <div class="pull-right float-right domain-renewals-search">
                            <input id="domainRenewalFilter"
                                   type="search"
                                   class="domain-renewals-filter form-control input-inline-100"
                                   placeholder="{lang key='searchenterdomain'}">
                        </div>
                    {/if}
                </h1>
            </div>

            {include file="orderforms/$carttpl/sidebar-categories-collapsed.tpl"}

            {if $totalDomainCount == 0}
                <div id="no-domains"
                     class="alert alert-warning text-center domain-renewals-empty"
                     role="alert">
                    <i class="fas fa-info-circle"></i>
                    {$LANG.domainRenewal.noDomains}
                </div>
                <p class="text-center">
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn btn-default">
                        <i class="fas fa-arrow-circle-left"></i>
                        {$LANG.orderForm.returnToClientArea}
                    </a>
                </p>
            {else}
                <div class="row">

                    <div class="secondary-cart-body">

                        {if $totalResults < $totalDomainCount}
                            <div class="text-center domain-renewals-trim">
                                {lang key='domainRenewal.showingDomains' showing=$totalResults totalCount=$totalDomainCount}
                                <a id="linkShowAll" href="{routePath('cart-domain-renewals')}">
                                    {lang key='domainRenewal.showAll'}
                                </a>
                            </div>
                        {/if}

                        <div id="domainRenewals" class="domain-renewals">
                            {foreach $renewalsData as $renewalData}
                                <div class="domain-renewal" data-domain="{$renewalData.domain|escape}">

                                    <div class="domain-renewal-head">
                                        <div class="domain-renewal-title">
                                            <h3 class="font-size-24">{$renewalData.domain|escape}</h3>
                                            <p class="domain-renewal-expiry">
                                                {lang key='clientareadomainexpirydate'}:
                                                <span class="domain-renewal-expiry-date">{$renewalData.expiryDate->format('j M Y')}</span>
                                                <span class="domain-renewal-expiry-rel">({$renewalData.expiryDate->diffForHumans()})</span>
                                            </p>
                                        </div>

                                        <div class="domain-renewal-status pull-right float-right">
                                            {if !$renewalData.eligibleForRenewal}
                                                <span class="label label-info renewal-pill renewal-pill--muted">
                                                    {if $renewalData.freeDomainRenewal}
                                                        {lang key='domainRenewal.freeWithService'}
                                                    {else}
                                                        {lang key='domainRenewal.unavailable'}
                                                    {/if}
                                                </span>
                                            {elseif $renewalData.pastGracePeriod && $renewalData.pastRedemptionGracePeriod}
                                                <span class="label label-info renewal-pill renewal-pill--muted">
                                                    {lang key='domainrenewalspastgraceperiod'}
                                                </span>
                                            {elseif !$renewalData.beforeRenewLimit && $renewalData.daysUntilExpiry > 0}
                                                <span class="label label-{if $renewalData.daysUntilExpiry > 30}success renewal-pill renewal-pill--good{else}warning renewal-pill renewal-pill--warn{/if}">
                                                    {lang key='domainRenewal.expiringIn' days=$renewalData.daysUntilExpiry}
                                                </span>
                                            {elseif $renewalData.daysUntilExpiry === 0}
                                                <span class="label label-grey renewal-pill renewal-pill--muted">
                                                    {lang key='expiresToday'}
                                                </span>
                                            {elseif $renewalData.beforeRenewLimit}
                                                <span class="label label-info renewal-pill renewal-pill--muted">
                                                    {lang key='domainRenewal.maximumAdvanceRenewal' days=$renewalData.beforeRenewLimitDays}
                                                </span>
                                            {else}
                                                <span class="label label-danger renewal-pill renewal-pill--danger">
                                                    {lang key='domainRenewal.expiredDaysAgo' days=$renewalData.daysUntilExpiry*-1}
                                                </span>
                                            {/if}
                                        </div>
                                    </div>

                                    {if $renewalData.freeDomainRenewal}
                                        <p class="domain-renewal-desc">
                                            <i class="fas fa-info-circle"></i>
                                            {lang key='domainRenewal.freeWithServiceDesc'}
                                        </p>
                                    {/if}

                                    {if ($renewalData.pastGracePeriod && $renewalData.pastRedemptionGracePeriod) || !count($renewalData.renewalOptions)}
                                        {* No selectable periods -- nothing to render here *}
                                    {else}
                                        <form class="form-horizontal domain-renewal-form">
                                            <div class="form-group row">
                                                <label for="renewalPricing{$renewalData.id}"
                                                       class="control-label col-md-5 domain-renewal-period-label">
                                                    {lang key='domainRenewal.availablePeriods'}
                                                    {if $renewalData.inGracePeriod || $renewalData.inRedemptionGracePeriod}*{/if}
                                                </label>
                                                <div class="col-sm-6 col-md-7 domain-renewal-period-control">
                                                    <select class="form-control select-renewal-pricing"
                                                            id="renewalPricing{$renewalData.id}"
                                                            data-domain-id="{$renewalData.id}">
                                                        {foreach $renewalData.renewalOptions as $renewalOption}
                                                            <option value="{$renewalOption.period}">
                                                                {$renewalOption.period} {lang key='orderyears'} @ {$renewalOption.rawRenewalPrice}
                                                                {if $renewalOption.gracePeriodFee && $renewalOption.gracePeriodFee->toNumeric() != 0.00}
                                                                    + {$renewalOption.gracePeriodFee} {lang key='domainRenewal.graceFee'}
                                                                {/if}
                                                                {if $renewalOption.redemptionGracePeriodFee && $renewalOption.redemptionGracePeriodFee->toNumeric() != 0.00}
                                                                    + {$renewalOption.redemptionGracePeriodFee} {lang key='domainRenewal.redemptionFee'}
                                                                {/if}
                                                            </option>
                                                        {/foreach}
                                                    </select>
                                                </div>
                                            </div>
                                        </form>
                                    {/if}

                                    <div class="text-right domain-renewal-actions">
                                        {if !$renewalData.eligibleForRenewal || $renewalData.beforeRenewLimit || ($renewalData.pastGracePeriod && $renewalData.pastRedemptionGracePeriod)}
                                            {* Ineligible -- no CTA *}
                                        {else}
                                            <button id="renewDomain{$renewalData.id}"
                                                    class="btn btn-default btn-sm btn-add-renewal-to-cart"
                                                    data-domain-id="{$renewalData.id}">
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

                                </div>
                            {/foreach}
                        </div>

                        <div class="text-center domain-renewals-footnote">
                            <small>
                                {if $hasDomainsInGracePeriod}
                                    * {lang key='domainRenewal.graceRenewalPeriodDescription'}
                                {/if}
                            </small>
                        </div>

                    </div>

                    <div class="secondary-cart-sidebar" id="scrollingPanelContainer">

                        <div id="orderSummary">
                            <div class="order-summary">
                                <div class="loader" id="orderSummaryLoader">
                                    <i class="fas fa-fw fa-sync fa-spin"></i>
                                </div>
                                <h2 class="font-size-30">{lang key='ordersummary'}</h2>
                                <div class="summary-container" id="producttotal"></div>
                            </div>

                            <div class="text-center order-summary-actions">
                                <a id="btnGoToCart"
                                   class="btn btn-primary btn-lg"
                                   href="{$WEB_ROOT}/cart.php?a=view">
                                    {lang key='viewcart'}
                                    &nbsp;<i class="far fa-shopping-cart"></i>
                                </a>
                            </div>
                        </div>

                    </div>
                </div>
            {/if}

        </div>
    </div>

    {* ─── Remove-renewal modal + form (POST contract identical to standard_cart) ─── *}
    <form id="removeRenewalForm" method="post" action="{$WEB_ROOT}/cart.php">
        <input type="hidden" name="a" value="remove" />
        <input type="hidden" name="r" value="" id="inputRemoveItemType" />
        <input type="hidden" name="i" value="" id="inputRemoveItemRef" />

        <div class="modal fade modal-remove-item" id="modalRemoveItem" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-dialog-centered" role="document">
                <div class="modal-content">
                    <div class="modal-header d-block">
                        <h4 class="modal-title">
                            <button type="button"
                                    class="close"
                                    data-dismiss="modal"
                                    aria-label="{lang key='orderForm.close'}">
                                <span aria-hidden="true">&times;</span>
                            </button>
                            <i class="fas fa-times fa-3x"></i>
                            <span>{lang key='orderForm.removeItem'}</span>
                        </h4>
                    </div>
                    <div class="modal-body">
                        {lang key='cartremoveitemconfirm'}
                    </div>
                    <div class="modal-footer d-block">
                        <button type="button" class="btn btn-default" data-dismiss="modal">{lang key='no'}</button>
                        <button type="submit" class="btn btn-primary">{lang key='yes'}</button>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script>recalculateRenewalTotals();</script>
