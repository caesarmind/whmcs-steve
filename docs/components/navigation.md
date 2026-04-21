# Navigation System

### Structure

The navigation system has two tiers rendered in the header:

- **Primary Navigation** (`$primaryNavbar`) - Main menu items (left-aligned)
- **Secondary Navigation** (`$secondaryNavbar`) - User links (right-aligned, shows login/account)

### Navbar Template (`includes/navbar.tpl`)

The navbar template iterates over menu items and renders them with dropdowns:

```smarty
{foreach $navbar as $item}
    <li menuItemName="{$item->getName()}" 
        class="d-block{if $item->hasChildren()} dropdown{/if}{if $item->getClass()} {$item->getClass()}{/if}">
        
        <a class="{if $item->hasChildren()} dropdown-toggle{/if}" 
           href="{if $item->hasChildren()}#{else}{$item->getUri()}{/if}"
           {if $item->getAttribute('target')} target="{$item->getAttribute('target')}"{/if}>
            {if $item->hasIcon()}<i class="{$item->getIcon()}"></i>{/if}
            {$item->getLabel()}
            {if $item->hasBadge()}<span class="badge">{$item->getBadge()}</span>{/if}
        </a>
        
        {if $item->hasChildren()}
            <ul class="dropdown-menu{if isset($rightDrop) && $rightDrop} dropdown-menu-right{/if}">
                {foreach $item->getChildren() as $childItem}
                    {* Dividers and items *}
                {/foreach}
            </ul>
        {/if}
    </li>
{/foreach}
```

The navbar also includes a collapsible "More" dropdown for overflow items on smaller screens.

### Include Usage

```smarty
{* Primary nav (left side) *}
<ul id="nav" class="navbar-nav mr-auto">
    {include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
</ul>

{* Secondary nav (right side, with right-aligned dropdowns) *}
<ul class="navbar-nav ml-auto">
    {include file="$template/includes/navbar.tpl" navbar=$secondaryNavbar rightDrop=true}
</ul>
```

### MenuItem Object Methods

| Method | Return | Description |
|--------|--------|-------------|
| `->getName()` | string | Internal item name |
| `->getId()` | string | HTML element ID |
| `->getLabel()` | string | Display text |
| `->getUri()` | string | Link URL |
| `->hasChildren()` | boolean | Has submenu |
| `->getChildren()` | collection | Submenu items |
| `->hasIcon()` | boolean | Has icon |
| `->getIcon()` | string | FontAwesome icon class |
| `->hasBadge()` | boolean | Has badge |
| `->getBadge()` | string | Badge text/count |
| `->isCurrent()` | boolean | Is current/active page |
| `->isDisabled()` | boolean | Is disabled |
| `->getClass()` | string | Custom CSS class |
| `->getAttribute('key')` | mixed | Custom HTML attribute |
| `->getExtra('key')` | mixed | Extra data (color, btn-link, etc.) |
| `->hasBodyHtml()` | boolean | Has panel body HTML |
| `->getBodyHtml()` | string | Panel body HTML content |
| `->hasFooterHtml()` | boolean | Has footer HTML |
| `->getFooterHtml()` | string | Footer HTML content |
| `->getChildrenAttribute('class')` | string | Children container class |

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

### Customizing Navigation via Hooks

```php
<?php
use WHMCS\View\Menu\Item as MenuItem;
use WHMCS\View\Menu;

add_hook('ClientAreaPrimaryNavbar', 1, function (MenuItem $menu) {
    // Modify existing
    $menu->getChild('Store')
        ->setLabel('Our Products')
        ->setUri('https://example.com/products')
        ->setIcon('fas fa-store')
        ->setOrder(10);
    
    // Add new with badge
    $menu->addChild('resources')
        ->setLabel('Resources')
        ->setUri('/resources')
        ->setIcon('fas fa-book')
        ->setBadge('New')
        ->setOrder(50);
    
    // Add nested menu
    $menu->addChild('tools')
        ->setLabel('Tools')
        ->setOrder(60)
        ->addChild('calculator')
            ->setLabel('Hosting Calculator')
            ->setUri('/calculator');
    
    // Reorder
    $menu->getChild('Support')->moveToFront();
    $menu->getChild('Home')->moveToBack();
    
    // Conditional based on login
    if (Menu::context('client')) {
        $menu->addChild('vip')
            ->setLabel('VIP Area')
            ->setUri('/vip');
    }
    
    // Remove
    $menu->removeChild('Announcements');
    
    // Hide without removing
    $menu->getChild('Affiliates')->setHidden(true);
});
```

## Menu Context

Use static methods on `Menu::` for conditional logic:

```php
use WHMCS\View\Menu;

// Check if client is logged in
if (Menu::context('client')) {
    // Client logged in - show client-only items
}

// Check other contexts
Menu::context('admin');  // Admin logged in
```
