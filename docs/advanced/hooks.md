# Hooks Reference

### Navigation & Sidebar Hooks

| Hook | Purpose | Parameter |
|------|---------|-----------|
| `ClientAreaPrimaryNavbar` | Customize primary navigation | `MenuItem $primaryNavbar` |
| `ClientAreaSecondarySidebar` | Customize secondary navigation | `MenuItem $secondaryNavbar` |
| `ClientAreaPrimarySidebar` | Customize primary sidebar | `MenuItem $primarySidebar` |
| `ClientAreaSecondarySidebar` | Customize secondary sidebar | `MenuItem $secondarySidebar` |

### Page Template Variables Hooks

Add custom variables to any template via `ClientAreaPageView*` hooks:

```php
<?php
add_hook('ClientAreaPageViewTicket', 1, function($vars) {
    $extraVars = [];
    
    $clientData = isset($vars['clientsdetails']) ? $vars['clientsdetails'] : null;
    
    if (is_array($clientData) && isset($clientData['id'])) {
        $extraVars['customVariable'] = 'custom value';
    }
    
    return $extraVars;
});
```

Variables returned become available as `{$customVariable}` in the template.

### Common Page Hooks

| Hook | Page |
|------|------|
| `ClientAreaPageHome` | Client area dashboard |
| `ClientAreaPageProductDetails` | Product details page |
| `ClientAreaPageDomainDetails` | Domain details page |
| `ClientAreaPageViewTicket` | View ticket page |
| `ClientAreaPageLogin` | Login page |
| `ClientAreaPageRegister` | Registration page |
| `ClientAreaPageCart` | Shopping cart |
| `ClientAreaPageInvoices` | Invoice list |
| `ClientAreaPageKnowledgebase` | Knowledge base |
| `ClientAreaPageAnnouncements` | Announcements |

### Hook File Location

Hooks should be placed as PHP files in `/includes/hooks/`:

```php
<?php
// /includes/hooks/custom_theme_hooks.php

use WHMCS\View\Menu\Item as MenuItem;

add_hook('ClientAreaPrimaryNavbar', 1, function (MenuItem $primaryNavbar) {
    // Navigation customization
});

add_hook('ClientAreaPrimarySidebar', 1, function (MenuItem $primarySidebar) {
    // Sidebar customization
});

add_hook('ClientAreaPageHome', 1, function($vars) {
    return ['myCustomVar' => 'value'];
});
```
