{*
 * mytheme_cart/includes/product-recommendations.tpl
 *
 * Cross-sell rail. Included in two places:
 *   1. recommendations-modal.tpl    (modal body, after a cart action)
 *   2. complete.tpl                 (inline at order-confirmation bottom)
 *
 * Two visual modes driven by $templatefile + $recommendStyle:
 *   - "Last product added" mini-card at the top (only when
 *     $lastProduct populated -- i.e., right after add-to-cart).
 *   - Recommendation grid below, looping by category. On complete.tpl
 *     headings split between "Based on your order" and "Based on your
 *     products" sections.
 *
 * Variables WHMCS hands in:
 *   $lastProduct                assoc; last added product + pricing
 *   $productRecommendations     map: categoryKey -> [categoryRecs]
 *                               each rec has .recommendations[]
 *   $recommendStyle             bool; "by-product" style vs generic
 *   $templatefile               'viewcart' | 'checkout' | 'complete' | 'configureproduct' | …
 *
 * Contract preserved verbatim:
 *   - .product-added-panel.panel.card wrapper with .product-name +
 *     .product-group + .product-price + .product-cycle classes
 *     (scripts.min.js targets these).
 *   - .product-recommendations-container > .product-recommendations
 *     outer wrappers.
 *   - .product-recommendation per-card structure (header > cta >
 *     price/btn-add > arrow/text). data-color + inline border-color
 *     style remain on the card; the colored .price + .arrow + button
 *     background-color survive (it's the colour metaphor of the
 *     recommendation -- WHMCS Marketplace data-driven).
 *   - .breakdown-price + .setup-fee span order required.
 *   - .truncate class on .headline and .tagline.
 *   - Pricing string emitted via $price->price()->toFull() or
 *     $price->breakdownPrice() depending on cycle.
 *
 * Apple visual layer comes from style.min.css restyling
 * .product-recommendation, .product-added-panel, .btn-add. No new
 * class hooks are required here.
 *}

{if !empty($lastProduct)}
    <div class="product-added-panel panel card">
        <div class="panel-body card-body">
            <span class="text-muted product-added-eyebrow">
                <i class="far fa-check-circle"></i>&nbsp;{lang key="recommendations.productAdded"}
            </span>
            <div class="product-added-row">
                <span class="product-name">&nbsp;{$lastProduct.product.name|escape}</span>
                <span class="product-group">&nbsp;{$lastProduct.product.productGroup.name|escape}</span>
            </div>
            <div class="product-added-row">
                <span class="product-price">
                    {if !$lastProduct.pricing->isFree()}
                        &nbsp;{$lastProduct.pricing->price()->toFull()}
                        {if $lastProduct.pricing->setup() && $lastProduct.pricing->setup()->toNumeric() > 0}
                            + {$lastProduct.pricing->setup()->toFull()} {lang key="ordersetupfee"}
                        {/if}
                    {/if}
                </span>
                <span class="product-cycle">&nbsp;{lang key='orderpaymentterm'|cat:$lastProduct.pricing->cycle()}</span>
            </div>
        </div>
    </div>
{/if}

<div class="product-recommendations-container">
    <div class="product-recommendations">

        {* ── Intro copy varies by templatefile + recommendation style ── *}
        {if !in_array($templatefile, ['viewcart', 'checkout', 'complete'])}
            <p class="recommendations-intro">{lang key="recommendations.explain.product"}</p>
        {elseif !$recommendStyle && $templatefile != 'complete'}
            <p class="recommendations-intro">{lang key="recommendations.explain.generic"}</p>
        {elseif $templatefile == 'complete'}
            <div class="recommendations-heading">
                <h4 class="float-left pull-left">{lang key="recommendations.title.generic"}</h4>
                <h4 class="text-muted float-right pull-right">
                    <small>
                        {if !empty($productRecommendations.order)}
                            {lang key="recommendations.title.yourOrder"}
                        {else}
                            {lang key="recommendations.title.yourProducts"}
                        {/if}
                    </small>
                </h4>
                <div class="clearfix"></div>
            </div>
        {/if}

        {if $productRecommendations}
            {foreach $productRecommendations as $categoryKey => $categoryRecommendations}

                {if $templatefile == 'complete' && $categoryKey == 'own' && !empty($productRecommendations.own) && !empty($productRecommendations.order)}
                    <h4 class="text-muted float-right pull-right recommendations-subhead">
                        <small>{lang key="recommendations.title.yourProducts"}</small>
                    </h4>
                    <div class="clearfix"></div>
                {/if}

                {foreach $categoryRecommendations as $categoryRecommendation}

                    {if $recommendStyle && $templatefile != 'complete'}
                        <p class="recommendations-intro">
                            {lang key="recommendations.explain.ordered" productName=$categoryRecommendation.name}
                        </p>
                    {/if}

                    {foreach $categoryRecommendation.recommendations as $recommendation}
                        {assign var="price" value=$recommendation->pricing()->first()}

                        <div class="product-recommendation"
                             data-color="{$recommendation.color|escape}"
                             style="border-color:{$recommendation->color};">

                            <div class="header{if !$recommendation.shortDescription} header-static{/if}">

                                <div class="cta">
                                    <div class="price" style="color:{$recommendation->color};">
                                        <span {if !$recommendation->isFree()}class="w-hidden hidden"{/if}>{lang key="orderfree"}</span>
                                        {if !$recommendation->isFree() && $price}
                                            <span class="breakdown-price">
                                                {if $price->isOneTime()}
                                                    {$price->price()->toFull()}
                                                {elseif $price->isRecurring()}
                                                    {$price->breakdownPrice()}
                                                {/if}
                                            </span>
                                        {/if}
                                        {if !$recommendation->isFree() && !is_null($price->setup()) && $price->setup()->toNumeric() > 0}
                                            <span class="setup-fee">
                                                <small>{$price->setup()->toFull()}&nbsp;{lang key="ordersetupfee"}</small>
                                            </span>
                                        {/if}
                                    </div>

                                    <a type="button"
                                       class="btn btn-sm btn-add btn-primary"
                                       href="{$recommendation->getRecommendationRoutePath($categoryRecommendation.id)}"
                                       role="button"
                                       style="background-color:{$recommendation->color};">
                                        <span class="text">{lang key="addtocart"}</span>
                                        <span class="arrow" style="background-color:{$recommendation->color};">
                                            <i class="fas fa-chevron-right"></i>
                                        </span>
                                    </a>
                                </div>

                                <div class="expander" style="color:{$recommendation->color};">
                                    {if $recommendation.shortDescription}
                                        <i class="fas fa-chevron-right rotate"
                                           data-toggle="tooltip"
                                           data-placement="right"
                                           title="{lang key='recommendations.learnMore'}"></i>
                                    {else}
                                        <i class="fas fa-square fa-xs"></i>
                                    {/if}
                                </div>

                                <div class="content">
                                    <div class="headline truncate">
                                        {$recommendation.productGroup.name|escape} - {$recommendation.name|escape}
                                    </div>
                                    <div class="tagline truncate">
                                        {if empty($recommendation.tagline)}
                                            {lang key="recommendations.taglinePlaceholder"}
                                        {else}
                                            {$recommendation.tagline|escape}
                                        {/if}
                                    </div>
                                </div>

                            </div>

                            <div class="body clearfix">
                                <p>{$recommendation.shortDescription}</p>
                            </div>

                        </div>
                    {/foreach}

                {/foreach}
            {/foreach}
        {/if}

    </div>
</div>
