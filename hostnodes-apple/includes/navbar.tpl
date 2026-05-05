{* =========================================================================
   Public-page navigation (apple .homepage-nav). Rendered by header.tpl when
   the user is not logged in. Takes $navbar (= $primaryNavbar) from WHMCS.
   ========================================================================= *}
{foreach $navbar as $item}
    {if $item->hasChildren()}
        <div menuItemName="{$item->getName()}" class="nav-item-dropdown">
            <a href="#" class="nav-dropdown-trigger">
                {if $item->hasIcon()}<i class="{$item->getIcon()}"></i> {/if}
                {$item->getLabel()}
                <i class="fas fa-chevron-down chevron"></i>
            </a>
            <div class="nav-mega-menu">
                <div class="nav-mega-inner">
                    <div class="nav-mega-col">
                        {foreach $item->getChildren() as $childItem}
                            <a href="{$childItem->getUri()}" class="nav-mega-item"{if $childItem->getAttribute('target')} target="{$childItem->getAttribute('target')}"{/if}>
                                <div class="name">
                                    {if $childItem->hasIcon()}<i class="{$childItem->getIcon()}"></i> {/if}
                                    {$childItem->getLabel()}
                                </div>
                                {if $childItem->getExtra('tag')}
                                    <div class="tag">{$childItem->getExtra('tag')}</div>
                                {/if}
                            </a>
                        {/foreach}
                    </div>
                </div>
            </div>
        </div>
    {else}
        <a menuItemName="{$item->getName()}" href="{$item->getUri()}"{if $item->getAttribute('target')} target="{$item->getAttribute('target')}"{/if}>
            {if $item->hasIcon()}<i class="{$item->getIcon()}"></i> {/if}
            {$item->getLabel()}
            {if $item->hasBadge()}<span class="nav-badge">{$item->getBadge()}</span>{/if}
        </a>
    {/if}
{/foreach}
