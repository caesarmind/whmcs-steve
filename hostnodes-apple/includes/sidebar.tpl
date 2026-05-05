{* =========================================================================
   Authenticated-area sidebar. Renders the WHMCS Menu object ($sidebar, which
   is normally $primarySidebar) using apple-theme classes.

   Top-level items act as "section labels" (unless they have no children, in
   which case the item itself is rendered as a link). Children are the actual
   clickable rows. Server-driven active detection via $childItem->isCurrent().

   Icon color is taken from the child item's `color` extra when set, otherwise
   from the parent item's `color` extra (both set by menu hooks). If neither is
   present the icon falls back to the neutral gray tone.
   ========================================================================= *}
{foreach $sidebar as $item}
    {assign var="sectionColor" value=$item->getExtra('color')}
    {if $item->hasChildren()}
        {if $item->getLabel()}
            <div menuItemName="{$item->getName()}" class="sidebar-section-label">
                {$item->getLabel()}
                {if $item->hasBadge()}<span class="sidebar-item-badge">{$item->getBadge()}</span>{/if}
            </div>
        {/if}
        {foreach $item->getChildren() as $childItem}
            {if $childItem->getUri()}
                {assign var="itemColor" value=$childItem->getExtra('color')}
                {if !$itemColor}{assign var="itemColor" value=$sectionColor}{/if}
                {if !$itemColor}{assign var="itemColor" value="gray"}{/if}
                <a menuItemName="{$childItem->getName()}"
                   href="{$childItem->getUri()}"
                   id="{$childItem->getId()}"
                   class="sidebar-item{if $childItem->isCurrent()} active{/if}{if $childItem->isDisabled()} disabled{/if}{if $childItem->getClass()} {$childItem->getClass()}{/if}"
                   {if $childItem->getAttribute('target')}target="{$childItem->getAttribute('target')}"{/if}>
                    <div class="sidebar-item-icon {$itemColor}">
                        {if $childItem->hasIcon()}
                            <i class="{$childItem->getIcon()}"></i>
                        {else}
                            <i class="fas fa-circle"></i>
                        {/if}
                    </div>
                    <span class="sidebar-item-label">{$childItem->getLabel()}</span>
                    {if $childItem->hasBadge()}<span class="sidebar-item-badge">{$childItem->getBadge()}</span>{/if}
                </a>
            {else}
                <div menuItemName="{$childItem->getName()}" class="sidebar-item disabled">
                    <div class="sidebar-item-icon gray">
                        {if $childItem->hasIcon()}<i class="{$childItem->getIcon()}"></i>{else}<i class="fas fa-circle"></i>{/if}
                    </div>
                    <span class="sidebar-item-label">{$childItem->getLabel()}</span>
                </div>
            {/if}
        {/foreach}
    {else}
        {if !$sectionColor}{assign var="sectionColor" value="gray"}{/if}
        {if $item->getUri()}
            <a menuItemName="{$item->getName()}"
               href="{$item->getUri()}"
               id="{$item->getId()}"
               class="sidebar-item{if $item->isCurrent()} active{/if}{if $item->getClass()} {$item->getClass()}{/if}">
                <div class="sidebar-item-icon {$sectionColor}">
                    {if $item->hasIcon()}<i class="{$item->getIcon()}"></i>{else}<i class="fas fa-circle"></i>{/if}
                </div>
                <span class="sidebar-item-label">{$item->getLabel()}</span>
                {if $item->hasBadge()}<span class="sidebar-item-badge">{$item->getBadge()}</span>{/if}
            </a>
        {/if}
    {/if}
{/foreach}
