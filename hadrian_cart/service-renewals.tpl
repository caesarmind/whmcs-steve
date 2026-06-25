{*
 * hadrian_cart/service-renewals.tpl
 *
 * Bulk service-renewal page. WHMCS routes /cart.php?a=renewals here
 * when a logged-in client wants to renew one or more hosting/addon
 * services. List on the left, sticky order-summary on the right.
 *
 * Variables WHMCS hands in:
 *   $renewableServices       array of service entities (see
 *                            service-renewal-item.tpl for shape)
 *   $totalResults            int, how many services are in the list
 *   $totalServiceCount       int, total count -- if > totalResults a
 *                            "showing X of Y" caption appears
 *
 * Contract preserved verbatim:
 *   - #serviceRenewals .service-renewals wrapper. scripts.min.js's
 *     filter input + hide-show button query inside this container.
 *   - #hideShowServiceRenewalButton + #serviceRenewalFilter ids.
 *     The .to-hide / .to-show spans inside the button are toggled
 *     by adding a class to the parent (toggle pattern).
 *   - #removeRenewalForm (POST to /cart.php with a=remove + r=… + i=…
 *     + rt=service) is the form that pops modalRemoveItem submits to.
 *   - #modalRemoveItem + .modal-remove-item Bootstrap-modal hooks.
 *   - #orderSummary > .order-summary > #orderSummaryLoader spinner
 *     + #producttotal placeholder div. recalculateRenewalTotals()
 *     populates #producttotal via AJAX.
 *   - <script>recalculateRenewalTotals();</script> at the bottom
 *     runs once on load so the summary fills in.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    <div class="row">
        <div class="cart-sidebar">
            {include file="orderforms/$carttpl/sidebar-categories.tpl"}
        </div>

        <div class="cart-body">

            <div class="header-lined row service-renewals-header">
                <div class="col-md-6 service-renewals-title">
                    <h1 class="font-size-36">
                        {if $totalResults > 1}
                            {lang key='renewService.titlePlural'}
                        {else}
                            {lang key='renewService.titleSingular'}
                        {/if}
                    </h1>
                </div>
                <div class="col-md-6 service-renewals-toolbar">
                    <button id="hideShowServiceRenewalButton"
                            class="btn btn-sm btn-default service-renewals-quick-filter">
                        <span class="to-hide">{lang key='renewService.hideShowServices.hide'}</span>
                        <span class="to-show">{lang key='renewService.hideShowServices.show'}</span>
                    </button>
                    {if $totalResults > 5}
                        <input id="serviceRenewalFilter"
                               type="search"
                               class="service-renewals-filter form-control"
                               placeholder="{lang key='renewService.searchPlaceholder'}">
                    {/if}
                </div>
            </div>

            {include file="orderforms/$carttpl/sidebar-categories-collapsed.tpl"}

            {if $totalServiceCount == 0}
                <div id="no-services"
                     class="alert alert-warning text-center service-renewals-empty"
                     role="alert">
                    <i class="fas fa-info-circle"></i>
                    {lang key='renewService.noServices'}
                </div>
                <p class="text-center">
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn btn-default">
                        <i class="fas fa-arrow-circle-left"></i>
                        {lang key='orderForm.returnToClientArea'}
                    </a>
                </p>
            {else}
                <div class="row">

                    <div class="secondary-cart-body">

                        {if $totalResults < $totalServiceCount}
                            <div class="text-center service-renewals-trim">
                                {lang key='renewService.showingServices' showing=$totalResults totalCount=$totalServiceCount}
                                <a id="linkShowAll" href="{routePath('service-renewals')}">
                                    {lang key='domainRenewal.showAll'}
                                </a>
                            </div>
                        {/if}

                        <div id="serviceRenewals" class="service-renewals">
                            {include file="orderforms/$carttpl/service-renewal-item.tpl" renewableItems=$renewableServices prefix=''}
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
    <form id="removeRenewalForm"
          method="post"
          action="{$WEB_ROOT}/cart.php"
          data-renew-type="service">
        <input type="hidden" name="a" value="remove">
        <input type="hidden" name="r" value="" id="inputRemoveItemType">
        <input type="hidden" name="i" value="" id="inputRemoveItemRef">
        <input type="hidden" name="rt" value="service" id="inputRemoveItemRenewalType">

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
