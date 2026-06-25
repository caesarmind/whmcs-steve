{*
 * hadrian_cart/recommendations-modal.tpl
 *
 * Cross-sell modal. Triggered automatically by scripts.min.js after
 * certain cart actions (configure-product save, view-cart load) when
 * WHMCS' recommendations engine has matches.
 *
 * Two trigger surfaces depend on $templatefile:
 *   - configureproduct / configureproductdomain: a hidden flag div
 *     (#divProductHasRecommendations) tells the inline JS in those
 *     pages whether to even open the modal.
 *   - viewcart / complete / checkout: modal opens directly with the
 *     "generic" cross-sell heading.
 *
 * Contract preserved verbatim:
 *   - #recommendationsModal Bootstrap-modal id + tabindex/role attrs.
 *   - .modal-dialog > .modal-content > .modal-header / .modal-body /
 *     .modal-footer structure.
 *   - #btnContinueRecommendationsModal CTA + .w-hidden.hidden spinner
 *     swap inside it.
 *   - .product-recommendation.clonable.w-hidden.hidden TEMPLATE node
 *     at the modal's root -- scripts.min.js .clone()s this into the
 *     modal body for each AJAX-returned recommendation, then unhides.
 *     Class names + nested .header > .cta > .price / .btn-add structure
 *     are queried by selector and CANNOT be renamed.
 *
 * Apple visual layer:
 *   - Modal surface restyled in style.min.css (rounded 14px, light
 *     border, subtle backdrop).
 *   - Heading typography lifted to Apple font-weight 600 / -0.024em.
 *   - Inline .product-recommendation cards reuse the same shell as
 *     the inline ones in product-recommendations.tpl.
 *}

{if in_array($templatefile, ['configureproductdomain', 'configureproduct'])}
    <div class="hidden w-hidden" id="divProductHasRecommendations" data-value="{$productinfo.hasRecommendations}"></div>
{/if}

<div class="modal fade recommendations-modal" id="recommendationsModal" tabindex="-1" role="dialog" aria-labelledby="recommendationsModalTitle">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content recommendations-modal-content">

            <div class="modal-header recommendations-modal-header">
                <h4 id="recommendationsModalTitle" class="modal-title float-left pull-left">
                    {if in_array($templatefile, ['viewcart', 'complete', 'checkout'])}
                        {lang key="recommendations.title.generic"}
                    {else}
                        {lang key="recommendations.title.addedTo"}
                    {/if}
                </h4>
                <button type="button"
                        class="close recommendations-modal-close"
                        data-dismiss="modal"
                        aria-label="{$LANG.orderForm.close}">
                    <span aria-hidden="true">&times;</span>
                </button>
                <div class="clearfix"></div>
            </div>

            <div class="modal-body recommendations-modal-body">
                {include file="orderforms/$carttpl/includes/product-recommendations.tpl"}
            </div>

            <div class="modal-footer recommendations-modal-footer">
                <a class="btn btn-primary"
                   href="#"
                   id="btnContinueRecommendationsModal"
                   data-dismiss="modal"
                   role="button">
                    <span class="w-hidden hidden">
                        <i class="fas fa-spinner fa-spin"></i>&nbsp;
                    </span>
                    {lang key="continue"}
                </a>
            </div>

        </div>
    </div>

    {* ─── Clonable template node used by scripts.min.js ─── *}
    <div class="product-recommendation clonable w-hidden hidden">
        <div class="header">
            <div class="cta">
                <div class="price">
                    <span class="w-hidden hidden">{lang key="orderfree"}</span>
                    <span class="breakdown-price"></span>
                    <span class="setup-fee">
                        <small>&nbsp;{lang key="ordersetupfee"}</small>
                    </span>
                </div>
                <button type="button" class="btn btn-sm btn-add btn-primary">
                    <span class="text">{lang key="addtocart"}</span>
                    <span class="arrow"><i class="fas fa-chevron-right"></i></span>
                </button>
            </div>
            <div class="expander">
                <i class="fas fa-chevron-right rotate"
                   data-toggle="tooltip"
                   data-placement="right"
                   title="{lang key='recommendations.learnMore'}"></i>
            </div>
            <div class="content">
                <div class="headline truncate"></div>
                <div class="tagline truncate">{lang key="recommendations.taglinePlaceholder"}</div>
            </div>
        </div>
        <div class="body clearfix">
            <p></p>
        </div>
    </div>

</div>
