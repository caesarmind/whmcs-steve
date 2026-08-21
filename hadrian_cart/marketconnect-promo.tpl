{*
 * hadrian_cart/marketconnect-promo.tpl
 *
 * A single MarketConnect promo card, injected by WHMCS from
 * scripts.min.js (which clones #promo_{$product->productKey} after an
 * AJAX call to /cart.php?marketconnect=...). Typically appears beneath
 * a hosting addon to upsell SSL, SiteLock, Weebly, etc.
 *
 * Variables WHMCS hands in (these are PHP objects, not arrays):
 *   $promotion        MarketConnect promotion entity
 *   $product          MarketConnect product entity
 *   $cartItem         the cart line this promo is attached to (assoc)
 *
 * Contract preserved verbatim:
 *   - Outer .mc-promo wrapper with id="promo_{$product->productKey}"
 *     and $promotion->getClass() concatenated -- scripts.min.js queries
 *     "#promo_{productKey}" + appends a clone for each cart row.
 *   - .btn-add button with data-product-key + data-upsell-from
 *     attributes. The .text + .arrow inner spans are required for the
 *     expand/collapse animation.
 *   - .expander > .rotate icon -- toggled by scripts.min.js to flip
 *     between collapsed/expanded body.
 *   - .header / .body / .body > ul structure unchanged.
 *
 * Visual layer:
 *   - Card surface (rounded, hairline border, light shadow) inherited
 *     from style.min.css's .mc-promo restyling.
 *   - .mc-feature-grid wraps the feature <ul> so we can lay it out as
 *     a 2-column grid on wide viewports; the left/right helper class
 *     legacy is kept on each <li> for the .col-md fallback when JS
 *     reflow doesn't happen.
 *}

<div class="mc-promo {$promotion->getClass()|escape}" id="promo_{$product->productKey|escape}">

    <div class="header mc-promo-header">

        <div class="cta mc-promo-cta">
            <div class="price mc-promo-price">
                {if $product->isFree()}
                    {lang key="orderfree"}
                {elseif $product->pricing()->first()}
                    {$product->pricing()->setQuantity($cartItem.qty)->first()->breakdownPrice()}
                {/if}
            </div>
            <button type="button"
                    class="btn btn-sm btn-add btn-primary"
                    data-product-key="{$product->productKey|escape}"
                    data-upsell-from="{if isset($cartItem.productKey)}{$cartItem.productKey|escape}{/if}">
                <span class="text">{lang key="addtocart"}</span>
                <span class="arrow">
                    <i class="fas fa-chevron-right"></i>
                </span>
            </button>
        </div>

        <div class="expander mc-promo-expander">
            <i class="fas fa-chevron-right rotate"
               data-toggle="tooltip"
               data-placement="right"
               title="{lang key='recommendations.learnMore'}"></i>
        </div>

        <div class="icon mc-promo-icon">
            <img src="{$promotion->getImagePath()}" alt="{$promotion->getHeadline()|escape}">
        </div>

        <div class="content mc-promo-content">
            <div class="headline truncate">{$promotion->getHeadline()|escape}</div>
            <div class="tagline truncate">{$promotion->getTagline()|escape}</div>
        </div>

    </div>

    <div class="body clearfix mc-promo-body">
        {if $promotion->hasFeatures()}
            <ul class="mc-feature-grid">
                {assign "promotionFeatures" $promotion->getFeatures()}
                {foreach $promotionFeatures as $key=>$feature}
                    <li class="mc-feature{if $key < ($promotionFeatures|@count / 2)} left{else} right{/if}">
                        <i class="fas fa-check"></i>
                        <span>{$feature|escape}</span>
                    </li>
                {/foreach}
            </ul>
        {/if}
    </div>

</div>
