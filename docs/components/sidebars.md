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

### MenuItem Writer Methods

These methods are used in hooks to modify the navigation. They support chaining (return self).

| Method | Description |
|--------|-------------|
| `->setLabel($text)` | Set display text |
| `->setUri($url)` | Set link URL |
| `->setOrder($int)` | Set numeric position (defaults: 10, 20, 30...) |
| `->setIcon($class)` | Set FontAwesome icon class |
| `->setBadge($text)` | Set badge text |
| `->setHidden($bool)` | Hide/show item |
| `->setDisabled($bool)` | Disable/enable item |
| `->setClass($class)` | Set CSS class |
| `->setExtra($key, $value)` | Set extra data (color, btn-link, etc.) |
| `->setAttribute($key, $value)` | Set HTML attribute |
| `->addChild($name, $config = [])` | Add child item (returns new MenuItem, chainable) |
| `->removeChild($name)` | Remove child by name |
| `->getChild($name)` | Get child by name (null if not found) |
| `->moveUp()` | Move one position up |
| `->moveDown()` | Move one position down |
| `->moveToFront()` | Move to first position |
| `->moveToBack()` | Move to last position |

### Customizing Sidebars via Hooks

```php
<?php
use WHMCS\View\Menu\Item as MenuItem;

add_hook('ClientAreaPrimarySidebar', 1, function (MenuItem $primarySidebar) {
    $myAccount = $primarySidebar->getChild('My Account');
    
    // Customize existing items
    $myAccount->getChild('Billing Information')
        ->setLabel('Payment Details')
        ->setUri('/custom-billing')
        ->setOrder(5);
    
    // Add new item with icon
    $myAccount->addChild('loyalty')
        ->setLabel('Loyalty Rewards')
        ->setUri('/rewards')
        ->setIcon('fas fa-gift')
        ->setBadge('5');
    
    // Remove default item
    $myAccount->removeChild('Change Password');
    
    // Mobile select rendering
    $myAccount->setExtra('mobileSelect', true);
});
```
