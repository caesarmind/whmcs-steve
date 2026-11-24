<section class="faq-section {if $elementIndex % 2 == 0}background-light{else}background-main{/if}" role="region">
    <div class="faq-container">
        {if $config->title}
            <h2 class="faq-title">
                {$config->title}
            </h2>
        {/if}

        {if $config->subtitle}
            <p class="faq-subtitle">
                {$config->subtitle}
            </p>
        {/if}

        {if $config->items}
            <div class="faq-accordion">
                {foreach from=$config->items item=faq name=faqs}
                    <div class="faq-item" data-faq-index="{$smarty.foreach.faqs.index}">
                        <input type="checkbox"
                               id="faq-{$smarty.foreach.faqs.index}"
                               class="faq-toggle"
                               {if $smarty.foreach.faqs.first}checked{/if}>

                        <label for="faq-{$smarty.foreach.faqs.index}"
                               class="faq-question"
                               role="button"
                               aria-expanded="{if $smarty.foreach.faqs.first}true{else}false{/if}"
                               tabindex="0">
                            <span class="faq-question-text">{$faq->question}</span>
                            <span class="faq-icon" aria-hidden="true">
                                <svg class="faq-icon-plus" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                <svg class="faq-icon-minus" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            </span>
                        </label>

                        <div class="faq-answer" role="region" aria-labelledby="faq-{$smarty.foreach.faqs.index}">
                            <div class="faq-answer-content">
                                {$faq->answer}
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {/if}
    </div>
</section>
