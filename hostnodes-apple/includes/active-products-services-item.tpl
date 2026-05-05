{* =========================================================================
   Single service row — used inside the "Active Services" card on the client
   home and anywhere else services are iterated. Apple .service-item layout.
   ========================================================================= *}
<a href="{$WEB_ROOT}/clientarea.php?action=productdetails&id={$service->id}" class="service-item"
   {if !empty($buttonData) || !empty($primaryServiceBtn) || !empty($accentPrimaryServiceBtns)}data-has-actions="true"{/if}>
    <div class="service-icon">
        {if $service->product->productGroup->icon}
            <i class="{$service->product->productGroup->icon}"></i>
        {else}
            <i class="fas fa-cube"></i>
        {/if}
    </div>
    <div class="service-info">
        <div class="service-name">
            {$service->product->productGroup->name} &mdash; {$service->product->name}
        </div>
        {if $service->domain}
            <div class="service-domain">{$service->domain}</div>
        {/if}
    </div>
    <div class="service-meta">
        <span class="status-pill {$statusProperties[$service->domainStatus]['modifier']}"
              title="{$statusProperties[$service->domainStatus]['translation']}">
            {$statusProperties[$service->domainStatus]['translation']}
        </span>
        {if $service->nextDueDate}
            <div class="service-due">
                <div>{$service->nextDueDate}</div>
                <div class="service-due-label">{lang key='nextduedate'}</div>
            </div>
        {/if}
        <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
    </div>
</a>
