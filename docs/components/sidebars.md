# Sidebar System

### Structure

Sidebars use the same MenuItem class as navigation, rendered as Bootstrap cards:

```smarty
{foreach $sidebar as $item}
    <div menuItemName="{$item->getName()}" class="card card-sidebar">
        <div class="card-header">
            <h3 class="card-title">
                {$item->getLabel()}
                {if $item->hasBadge()}<span class="badge">{$item->getBadge()}</span>{/if}
            </h3>
        </div>
        
        {* Body HTML content *}
        {if $item->hasBodyHtml()}
            <div class="card-body">{$item->getBodyHtml()}</div>
        {/if}
        
        {* Children as list items *}
        {if $item->hasChildren()}
            <div class="list-group list-group-flush">
                {foreach $item->getChildren() as $childItem}
                    <a href="{$childItem->getUri()}" 
                       class="list-group-item{if $childItem->isCurrent()} active{/if}">
                        {$childItem->getLabel()}
                    </a>
                {/foreach}
            </div>
        {/if}
        
        {* Footer *}
        {if $item->hasFooterHtml()}
            <div class="card-footer">{$item->getFooterHtml()}</div>
        {/if}
    </div>
{/foreach}
```

### Mobile Select Mode

Sidebar items with `getExtra('mobileSelect')` render as a `<select>` dropdown on mobile:

```smarty
{if $item->getExtra('mobileSelect') and $item->hasChildren()}
    {* Desktop: card with links - hidden on mobile *}
    <div class="d-none d-md-block">...</div>
    
    {* Mobile: select dropdown - hidden on desktop *}
    <div class="d-block d-md-none">
        <select onchange="selectChangeNavigate(this)">
            {foreach $item->getChildren() as $childItem}
                <option value="{$childItem->getUri()}" {if $childItem->isCurrent()}selected{/if}>
                    {$childItem->getLabel()}
                </option>
            {/foreach}
        </select>
    </div>
{/if}
```

### Special Sidebar Attributes

| Method | Description |
|--------|-------------|
| `->getAttribute('dataToggleTab')` | Enables tab toggling |
| `->getAttribute('dataCustomAction')` | Custom action data (serviceid, identifier, active) |
| `->getAttribute('id')` | Custom HTML ID |
| `->getAttribute('target')` | Link target (_blank, etc.) |
| `->getExtra('mobileSelect')` | Render as select on mobile |

### Customizing Sidebars via Hooks

```php
add_hook('ClientAreaPrimarySidebar', 1, function (MenuItem $primarySidebar) {
    // Find sidebar items
    $myAccount = $primarySidebar->getChild('My Account');
    
    // Change label
    $myAccount->getChild('Billing Information')
        ->setLabel('Payment Details');
    
    // Change URL
    $myAccount->getChild('Billing Information')
        ->setUri('/custom-billing');
    
    // Reorder (defaults are 10, 20, 30...)
    $myAccount->getChild('Billing Information')
        ->setOrder(100);
    
    // Add new item
    $myAccount->addChild('Custom Item')
        ->setLabel('My Custom Page')
        ->setUri('/custom-page')
        ->setOrder(50);
    
    // Remove item
    $myAccount->removeChild('Billing Information');
});
```
