{* store/promos/upsell.tpl — cross-sell prompt shown during order flow. *}
{if $upsells}
    <div class="upsell-panel card">
        <div class="card-header"><h3 class="card-title">{lang key='store.promos.addToOrder'}</h3></div>
        <div class="card-body">
            {foreach $upsells as $upsell}
                <div class="upsell-item">
                    {if $upsell.icon}<div class="upsell-icon"><i class="{$upsell.icon}"></i></div>{/if}
                    <div class="upsell-info">
                        <strong>{$upsell.name}</strong>
                        <p>{$upsell.description}</p>
                        <div class="upsell-price">{$upsell.price}</div>
                    </div>
                    <button type="submit" name="add_upsell" value="{$upsell.id}" class="btn btn-primary btn-sm">{lang key='store.promos.add'}</button>
                </div>
            {/foreach}
        </div>
    </div>
{/if}
