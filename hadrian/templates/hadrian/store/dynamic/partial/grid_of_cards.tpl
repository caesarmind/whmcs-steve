<section class="pricing-section {if $elementIndex % 2 == 0}background-light{else}background-main{/if}" role="region"
         aria-labelledby="pricing-title-{$smarty.foreach.blocks.index}">
    <div class="pricing-container">
        {if $config->title}
            <h2 class="pricing-title" id="pricing-title-{$smarty.foreach.blocks.index}">
                {$config->title}
            </h2>
        {/if}

        {if $config->subtitle}
            <p class="pricing-subtitle">
                {$config->subtitle}
            </p>
        {/if}
        {if $hasPlan}
        <div class="pricing-grid">
            {foreach $config->services as $service}
                {$plan = $products[$service['slug']]}
                {if !$plan}{continue}{/if}
                <div class="pricing-card">
                    <div class="pricing-header">
                        <h3 class="plan-name">{$plan.name}</h3>
                        <div class="plan-price">
                                <span class="price-amount">
                                {if $plan->isFree()}
                                    {lang key="orderpaymenttermfree"}
                                {else}
                                    {$plan->pricing()->first()->toPrefixedString()}
                                {/if}
                                </span>
                        </div>
                        {if $plan.description}
                            <p class="plan-description">{$plan.description}</p>
                        {/if}
                    </div>

                    <ul class="plan-features">
                        {foreach $service['features'] as $feature => $value}
                            <li class="feature-item">
                                {if is_bool($value)}
                                    {$feature}:
                                    {if $value === true}
                                        <svg class="feature-check" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    {else}
                                        <svg class="feature-cross" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                    {/if}
                                {else}
                                    <span>{$feature}: <b>{$value}</b></span>
                                {/if}
                            </li>
                        {/foreach}
                    </ul>

                    <div class="plan-action">
                        <form method="post" action="{routePath('cart-order')}">
                            <input type="hidden" name="checkout" value="1">
                            <input type="hidden" name="pid" value="{$plan.id}">
                            <button class="plan-button">{lang key='store.getstarted'}</button>
                        </form>
                    </div>
                </div>
            {/foreach}
            {else}
            <div class="service-link">
                <a href="{$WEB_ROOT}/contact.php" class="btn btn-info">
                    {lang key="learnmore"}
                </a>
            </div>
        </div>
        {/if}
    </div>
</section>
