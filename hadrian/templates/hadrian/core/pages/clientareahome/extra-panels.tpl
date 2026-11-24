{* Dashboard content from WHMCS and modules that no variant draws itself.

   Every clientareahome variant builds its own cards from $clientsstats and
   $dashboard, which covers WHMCS's built-in panels: Active Products/Services,
   Recent Support Tickets, Recent News, Unpaid / Overdue Invoices, Domains
   Expiring Soon, Register a New Domain and Your Info. Anything else in
   $panels used to vanish - the Affiliate Program panel, Sitejet Builder,
   MarketConnect panels (SiteLock, Weebly, SpamExperts logins...) and every
   panel an addon adds with the ClientAreaHomepagePanels hook - and so did
   $addons_html (ClientAreaHomepage hook output). This prints them, using the
   same menu-item API stock Nexus renders panels with (label, badge, body
   HTML, children, footer HTML, btn-link/btn-text extras). FontAwesome icon
   classes are skipped: Hadrian doesn't load FontAwesome. *}
{assign var=hnNativePanels value=['Active Products/Services','Recent Support Tickets','Recent News','Unpaid Invoices','Overdue Invoices','Domains Expiring Soon','Register a New Domain','Your Info']}
{assign var=hnHasExtraPanels value=false}
{if isset($panels) && $panels}
    {foreach $panels as $hnPanel}
        {if !in_array($hnPanel->getName(), $hnNativePanels)}{assign var=hnHasExtraPanels value=true}{break}{/if}
    {/foreach}
{/if}
{assign var=hnHasAddonsHtml value=false}
{if isset($addons_html) && $addons_html}{assign var=hnHasAddonsHtml value=true}{/if}

{if $hnHasExtraPanels || $hnHasAddonsHtml}
<style>{literal}
.hn-home-extra{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:20px;margin-top:24px;align-items:start}
.hn-home-extra>.hn-home-addon{grid-column:1/-1}
.hn-home-panel .card-header{display:flex;align-items:center;justify-content:space-between;gap:12px}
.hn-home-panel .hn-home-badge{display:inline-flex;align-items:center;min-width:20px;height:20px;padding:0 7px;margin-left:6px;border-radius:999px;background:var(--color-surface-secondary);color:var(--color-text-secondary);font-size:var(--text-xs);font-weight:var(--fw-semibold)}
.hn-home-list{display:flex;flex-direction:column}
.hn-home-list>a,.hn-home-list>div{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:12px 20px;border-top:.5px solid var(--color-border);color:var(--color-text-primary);font-size:var(--text-md);text-decoration:none}
.hn-home-list>a:hover{background:var(--color-surface-secondary)}
.hn-home-footer{padding:12px 20px;border-top:.5px solid var(--color-border);font-size:var(--text-sm);color:var(--color-text-secondary)}
.hn-home-footer:empty{display:none}
{/literal}</style>
<section class="hn-home-extra" aria-label="{$LANG.overview}">
    {if $hnHasAddonsHtml}
        {foreach $addons_html as $hnAddonHtml}
        <div class="hn-home-addon">{$hnAddonHtml}</div>
        {/foreach}
    {/if}
    {if $hnHasExtraPanels}
        {foreach $panels as $item}
            {if !in_array($item->getName(), $hnNativePanels)}
            <div class="card hn-home-panel{if $item->getClass()} {$item->getClass()}{/if}" menuItemName="{$item->getName()}"{if $item->getAttribute('id')} id="{$item->getAttribute('id')}"{/if}>
                <div class="card-header">
                    <h2 class="card-title">{$item->getLabel()}{if $item->hasBadge()}<span class="hn-home-badge">{$item->getBadge()}</span>{/if}</h2>
                    {if $item->getExtra('btn-link') && $item->getExtra('btn-text')}
                        <a href="{$item->getExtra('btn-link')}" class="btn-secondary">{$item->getExtra('btn-text')}</a>
                    {/if}
                </div>
                {if $item->hasBodyHtml()}
                    <div class="card-body">{$item->getBodyHtml()}</div>
                {/if}
                {if $item->hasChildren()}
                    <div class="hn-home-list">
                        {foreach $item->getChildren() as $childItem}
                            {if $childItem->getUri()}
                                <a menuItemName="{$childItem->getName()}" href="{$childItem->getUri()}"{if $childItem->getAttribute('target')} target="{$childItem->getAttribute('target')}"{/if} id="{$childItem->getId()}">
                                    <span>{$childItem->getLabel()}</span>{if $childItem->hasBadge()}<span class="hn-home-badge">{$childItem->getBadge()}</span>{/if}
                                </a>
                            {else}
                                <div menuItemName="{$childItem->getName()}" id="{$childItem->getId()}">
                                    <span>{$childItem->getLabel()}</span>{if $childItem->hasBadge()}<span class="hn-home-badge">{$childItem->getBadge()}</span>{/if}
                                </div>
                            {/if}
                        {/foreach}
                    </div>
                {/if}
                {if $item->hasFooterHtml()}
                    <div class="hn-home-footer">{$item->getFooterHtml()}</div>
                {/if}
            </div>
            {/if}
        {/foreach}
    {/if}
</section>
{/if}
