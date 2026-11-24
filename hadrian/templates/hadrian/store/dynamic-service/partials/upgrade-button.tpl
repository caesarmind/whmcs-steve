{* WHMCS 9 dynamic MarketConnect service: the upgrade card, posting to the
   upgrade route with what $parameters names (product vs addon, service id).
   Ported from stock twenty-one. *}
<div class="card" style="margin-bottom:20px;">
    <div class="card-header"><h2 class="card-title">{lang key='upgrade'}</h2></div>
    <div class="card-body">
        <p style="margin:0 0 14px;color:var(--color-text-secondary);">{lang key='upgradeService.chooseNew'}</p>
        <form method="post" action="{routePath('upgrade')}">
            <input type="hidden" name="isproduct" value="{$parameters->isProduct()}">
            <input type="hidden" name="serviceid" value="{$parameters->getUpgradeServiceId()}">
            <button type="submit" class="btn-primary">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="17 11 12 6 7 11"/><line x1="12" y1="6" x2="12" y2="18"/></svg>
                {lang key='upgrade'}
            </button>
        </form>
    </div>
</div>
