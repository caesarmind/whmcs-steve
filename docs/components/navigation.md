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

### Customizing Navigation via Hooks

```php
<?php
use WHMCS\View\Menu\Item as MenuItem;

add_hook('ClientAreaPrimaryNavbar', 1, function (MenuItem $primaryNavbar) {
    // Change a label
    $primaryNavbar->getChild('Store')
        ->setLabel('Our Products');
    
    // Change URL
    $primaryNavbar->getChild('Store')
        ->setUri('https://example.com/products');
    
    // Add new item
    $primaryNavbar->addChild('Custom Link')
        ->setLabel('Resources')
        ->setUri('/resources')
        ->setOrder(50);
    
    // Remove an item
    $primaryNavbar->removeChild('Announcements');
    
    // Reorder
    $primaryNavbar->getChild('Store')
        ->setOrder(10);
    // Or: ->moveUp(), ->moveDown(), ->moveToFront(), ->moveToBack()
    
    // Conditional based on login
    if (!is_null(Menu::context('client'))) {
        // Client is logged in
    }
});
```
