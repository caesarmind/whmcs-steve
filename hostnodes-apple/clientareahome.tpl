{* =========================================================================
   clientareahome.tpl — the authenticated dashboard.
   Greeting, summary tiles, services/invoices/tickets/announcements cards.
   ========================================================================= *}
{include file="$template/includes/flashmessage.tpl"}

<div class="greeting">
    <h1 class="greeting-title" id="greetingTitle">{lang key='hellotitle'}, {$client.firstname}.</h1>
    <p class="greeting-subtitle">{lang key='clientareahome.accountOverview'}</p>
</div>

<div class="summary-tiles">
    <a href="{$WEB_ROOT}/clientarea.php?action=services" class="tile">
        <div class="tile-icon blue"><i class="fas fa-cube"></i></div>
        <div class="tile-value">{$clientsstats.productsnumactive}</div>
        <div class="tile-label">{lang key='navservices'}</div>
    </a>
    {if $clientsstats.numdomains || $registerdomainenabled || $transferdomainenabled}
        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="tile">
            <div class="tile-icon green"><i class="fas fa-globe"></i></div>
            <div class="tile-value">{$clientsstats.numactivedomains}</div>
            <div class="tile-label">{lang key='navdomains'}</div>
        </a>
    {/if}
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="tile">
        <div class="tile-icon orange"><i class="far fa-file-invoice-dollar"></i></div>
        <div class="tile-value">{$clientsstats.numunpaidinvoices}</div>
        <div class="tile-label">{lang key='navinvoices'}</div>
    </a>
    <a href="{$WEB_ROOT}/supporttickets.php" class="tile">
        <div class="tile-icon red"><i class="far fa-comments"></i></div>
        <div class="tile-value">{$clientsstats.numactivetickets}</div>
        <div class="tile-label">{lang key='navtickets'}</div>
    </a>
</div>

{foreach $addons_html as $addon_html}
    <div class="addon-panel">{$addon_html}</div>
{/foreach}

{if $captchaError}
    {include file="$template/includes/alert.tpl" type="error" msg=$captchaError}
{/if}

<div class="client-home-panels">
    {foreach $panels as $item}
        <div menuItemName="{$item->getName()}" class="card{if $item->getExtra('color')} card-accent-{$item->getExtra('color')}{/if}{if $item->getClass()} {$item->getClass()}{/if}"{if $item->getAttribute('id')} id="{$item->getAttribute('id')}"{/if}>
            <div class="card-header">
                <h3 class="card-title">
                    {if $item->hasIcon()}<i class="{$item->getIcon()}"></i> {/if}
                    {$item->getLabel()}
                    {if $item->hasBadge()}<span class="card-badge">{$item->getBadge()}</span>{/if}
                </h3>
                {if $item->getExtra('btn-link') && $item->getExtra('btn-text')}
                    <a href="{$item->getExtra('btn-link')}" class="card-action">
                        {if $item->getExtra('btn-icon')}<i class="{$item->getExtra('btn-icon')}"></i> {/if}
                        {$item->getExtra('btn-text')}
                    </a>
                {/if}
            </div>
            {if $item->hasBodyHtml()}<div class="card-body">{$item->getBodyHtml()}</div>{/if}
            {if $item->hasChildren()}
                <div class="card-body">
                    {foreach $item->getChildren() as $childItem}
                        {if $childItem->getUri()}
                            <a menuItemName="{$childItem->getName()}" href="{$childItem->getUri()}"
                               class="service-item{if $childItem->getClass()} {$childItem->getClass()}{/if}{if $childItem->isCurrent()} active{/if}"
                               id="{$childItem->getId()}"
                               {if $childItem->getAttribute('target')} target="{$childItem->getAttribute('target')}"{/if}>
                                {if $childItem->hasIcon()}
                                    <div class="service-icon"><i class="{$childItem->getIcon()}"></i></div>
                                {/if}
                                <div class="service-info">
                                    <div class="service-name">{$childItem->getLabel()}</div>
                                </div>
                                <div class="service-meta">
                                    {if $childItem->hasBadge()}<span class="status-pill">{$childItem->getBadge()}</span>{/if}
                                    <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
                                </div>
                            </a>
                        {else}
                            <div menuItemName="{$childItem->getName()}" class="service-item disabled" id="{$childItem->getId()}">
                                {if $childItem->hasIcon()}<div class="service-icon"><i class="{$childItem->getIcon()}"></i></div>{/if}
                                <div class="service-info"><div class="service-name">{$childItem->getLabel()}</div></div>
                                {if $childItem->hasBadge()}<span class="status-pill">{$childItem->getBadge()}</span>{/if}
                            </div>
                        {/if}
                    {/foreach}
                </div>
            {/if}
            {if $item->hasFooterHtml()}<div class="card-footer">{$item->getFooterHtml()}</div>{/if}
        </div>
    {/foreach}
</div>
