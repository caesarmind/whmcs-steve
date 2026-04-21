# Header Template (header.tpl) Complete Reference

The `header.tpl` is the most important file in a WHMCS theme. It renders the page's `<head>` section, opens `<body>`, and wraps every page with navigation, breadcrumbs, notifications, and the main content container.

## Rendering Flow

```
header.tpl opens:
┌─────────────────────────────────────────┐
│ <!doctype html>                         │
│ <html>                                  │
│ <head>                                  │
│   [includes/head.tpl - CSS, JS, fonts]  │
│   {$headoutput}                         │
│ </head>                                 │
│ <body>                                  │
│   {$captcha->getMarkup()}               │
│   {$headeroutput}                       │
│                                         │
│   <header>                              │
│     [Topbar - logged-in users]          │
│     [Logo + Search + Cart]              │
│     [Main navbar collapse]              │
│   </header>                             │
│                                         │
│   [Network issues alert]                │
│   [Breadcrumb]                          │
│   [User validation banner]              │
│   [Email verification banner]           │
│   [Domain search (homepage only)]       │
│                                         │
│   <section id="main-body">              │
│     <div class="container">             │
│       <div class="row">                 │
│         [Sidebar column (if present)]   │
│         <div class="primary-content">   │
└─────────────────────────────────────────┘

          [PAGE CONTENT RENDERS HERE]

┌─────────────────────────────────────────┐
│         </div>  (primary-content)       │
│       </div>  (row)                     │
│     </div>  (container)                 │
│   </section>                            │
│                                         │
│   [Footer content]                      │
│   [Modals, overlays]                    │
│   {$footeroutput}                       │
│ </body>                                 │
│ </html>                                 │
└─────────────────────────────────────────┘
footer.tpl closes
```

## Complete Minimum Viable header.tpl

```smarty
<!doctype html>
<html lang="en">
<head>
    <meta charset="{$charset}" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>{if $kbarticle.title}{$kbarticle.title} - {/if}{$pagetitle} - {$companyname}</title>
    {include file="$template/includes/head.tpl"}
    {$headoutput}
</head>
<body>
    {if $captcha}{$captcha->getMarkup()}{/if}
    {$headeroutput}

    <header id="header" class="header">
        {* TOPBAR - shown only when logged in *}
        {if $loggedin}
            <div class="topbar">
                <div class="container">
                    <div class="d-flex">
                        {* NOTIFICATIONS *}
                        <div class="mr-auto">
                            <button type="button" class="btn" data-toggle="popover" id="accountNotifications" data-placement="bottom">
                                <i class="far fa-flag"></i>
                                {if count($clientAlerts) > 0}
                                    {count($clientAlerts)}
                                    <span>{lang key='notifications'}</span>
                                {else}
                                    <span>{lang key='nonotifications'}</span>
                                {/if}
                            </button>
                            <div id="accountNotificationsContent" class="w-hidden">
                                <ul class="client-alerts">
                                    {foreach $clientAlerts as $alert}
                                        <li>
                                            <a href="{$alert->getLink()}">
                                                <i class="fas fa-fw fa-{if $alert->getSeverity() == 'danger'}exclamation-circle{elseif $alert->getSeverity() == 'warning'}exclamation-triangle{else}info-circle{/if}"></i>
                                                <div class="message">{$alert->getMessage()}</div>
                                            </a>
                                        </li>
                                    {foreachelse}
                                        <li class="none">{lang key='notificationsnone'}</li>
                                    {/foreach}
                                </ul>
                            </div>
                        </div>

                        {* ACTIVE CLIENT INFO *}
                        <div class="ml-auto">
                            <div class="input-group active-client">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">{lang key='loggedInAs'}:</span>
                                </div>
                                <div class="btn-group">
                                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="btn btn-active-client">
                                        <span>
                                            {if $client.companyname}
                                                {$client.companyname}
                                            {else}
                                                {$client.fullName}
                                            {/if}
                                        </span>
                                    </a>
                                    <a href="{routePath('user-accounts')}" class="btn" title="Switch Account">
                                        <i class="fad fa-random"></i>
                                    </a>
                                    {if $adminMasqueradingAsClient || $adminLoggedIn}
                                        <a href="{$WEB_ROOT}/logout.php?returntoadmin=1" class="btn btn-return-to-admin">
                                            <i class="fas fa-redo-alt"></i>
                                            <span>{lang key="admin.returnToAdmin"}</span>
                                        </a>
                                    {/if}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        {/if}

        {* MAIN NAVBAR - Logo, Search, Cart *}
        <div class="navbar navbar-light">
            <div class="container mt-2 mb-2">
                <a class="navbar-brand" href="{$WEB_ROOT}/index.php">
                    {if $assetLogoPath}
                        <img src="{$assetLogoPath}" alt="{$companyname}" class="logo-img">
                    {else}
                        {$companyname}
                    {/if}
                </a>

                {* KNOWLEDGE BASE SEARCH *}
                <form method="post" action="{routePath('knowledgebase-search')}" class="form-inline ml-auto d-none d-xl-block mr-2">
                    <div class="input-group search">
                        <div class="input-group-prepend">
                            <button class="btn btn-default" type="submit">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                        <input class="form-control" type="text" name="search" 
                               placeholder="{lang key='searchOurKnowledgebase'}...">
                    </div>
                </form>

                {* CART + MOBILE MENU TOGGLE *}
                <ul class="navbar-nav toolbar">
                    <li class="nav-item">
                        <a class="btn nav-link cart-btn" href="{$WEB_ROOT}/cart.php?a=view">
                            <i class="far fa-shopping-cart fa-fw"></i>
                            <span id="cartItemCount" class="badge badge-dark badge-pill">{$cartitemcount}</span>
                            <span class="sr-only">{lang key='carttitle'}</span>
                        </a>
                    </li>
                    <li class="nav-item ml-2 d-xl-none">
                        <button class="btn nav-link" type="button" data-toggle="collapse" data-target="#mainNavbar">
                            <span class="fas fa-bars fa-fw"></span>
                        </button>
                    </li>
                </ul>
            </div>
        </div>

        {* COLLAPSIBLE MAIN NAVIGATION *}
        <div class="navbar navbar-expand-xl main-navbar-wrapper">
            <div class="container">
                <div class="collapse navbar-collapse" id="mainNavbar">
                    <ul id="nav" class="navbar-nav mr-auto">
                        {include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
                    </ul>
                    <ul class="navbar-nav ml-auto">
                        {include file="$template/includes/navbar.tpl" navbar=$secondaryNavbar rightDrop=true}
                    </ul>
                </div>
            </div>
        </div>
    </header>

    {* NETWORK ISSUES NOTIFICATION *}
    {include file="$template/includes/network-issues-notifications.tpl"}

    {* BREADCRUMB *}
    <nav class="master-breadcrumb" aria-label="breadcrumb">
        <div class="container">
            {include file="$template/includes/breadcrumb.tpl"}
        </div>
    </nav>

    {* USER VALIDATION + EMAIL VERIFICATION BANNERS *}
    {include file="$template/includes/validateuser.tpl"}
    {include file="$template/includes/verifyemail.tpl"}

    {* DOMAIN SEARCH - Homepage only *}
    {if $templatefile == 'homepage'}
        {if $registerdomainenabled || $transferdomainenabled}
            {include file="$template/includes/domain-search.tpl"}
        {/if}
    {/if}

    {* MAIN BODY CONTAINER *}
    <section id="main-body">
        <div class="{if !$skipMainBodyContainer}container{/if}">
            <div class="row">
                {* SIDEBAR COLUMN *}
                {if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}
                    <div class="col-lg-4 col-xl-3">
                        <div class="sidebar">
                            {include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}
                        </div>
                        {if $secondarySidebar->hasChildren()}
                            <div class="d-none d-lg-block sidebar">
                                {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                            </div>
                        {/if}
                    </div>
                {/if}

                {* PRIMARY CONTENT - page template renders after this *}
                <div class="{if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}col-lg-8 col-xl-9{else}col-12{/if} primary-content">
```

**Note:** header.tpl does NOT close the `<div class="primary-content">`, the `.row`, or `#main-body`. Those are closed in `footer.tpl`.

---

## Block-by-Block Walkthrough

### 1. `<head>` Section

```smarty
<head>
    <meta charset="{$charset}" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{$pagetitle} - {$companyname}</title>
    {include file="$template/includes/head.tpl"}
    {$headoutput}
</head>
```

**Required elements:**
- `{$charset}` — Character encoding (usually UTF-8)
- Viewport meta — For mobile responsiveness
- `{include file="$template/includes/head.tpl"}` — Loads your CSS/JS
- `{$headoutput}` — **MANDATORY** — Injects CAPTCHA, module CSS, hooks

**Title pattern:**
```smarty
<title>{if $kbarticle.title}{$kbarticle.title} - {/if}{$pagetitle} - {$companyname}</title>
```

The KB article check prefixes the article title on KB pages for better SEO.

### 2. `<body>` Opening

```smarty
<body data-phone-cc-input="{$phoneNumberInputStyle}">
    {if $captcha}{$captcha->getMarkup()}{/if}
    {$headeroutput}
```

**Required:**
- `{$captcha->getMarkup()}` if CAPTCHA is configured (injects script tags)
- `{$headeroutput}` — Header-specific hooks/modules

**Optional data attribute:**
- `data-phone-cc-input` — Phone country code picker style

### 3. Topbar (Logged-in Users)

The topbar appears above the logo only when the user is logged in.

```smarty
{if $loggedin}
    <div class="topbar">
        {* Notifications popover + Active client info *}
    </div>
{/if}
```

**Contains:**
- **Notifications popover** — Shows `$clientAlerts` count and dropdown
- **Active client switcher** — Shows current client, account switch link
- **Admin return button** — If admin is masquerading

**The notifications popover works via Bootstrap popover:**

```html
<button id="accountNotifications" data-toggle="popover">
    <i class="far fa-flag"></i> {count($clientAlerts)}
</button>
<div id="accountNotificationsContent" class="w-hidden">
    <!-- Hidden content copied to popover -->
</div>
```

JavaScript from `whmcs.js` handles:
```javascript
jQuery('#accountNotifications').popover({
    html: true,
    content: () => jQuery('#accountNotificationsContent').html()
});
```

### 4. Main Navbar

The primary navbar with logo, search, and cart:

```smarty
<div class="navbar navbar-light">
    <div class="container">
        {* Logo *}
        <a class="navbar-brand" href="{$WEB_ROOT}/index.php">
            {if $assetLogoPath}
                <img src="{$assetLogoPath}" alt="{$companyname}" class="logo-img">
            {else}
                {$companyname}
            {/if}
        </a>

        {* Search *}
        <form method="post" action="{routePath('knowledgebase-search')}">
            <!-- search input -->
        </form>

        {* Cart + Mobile toggle *}
        <ul class="navbar-nav toolbar">
            <li><a href="{$WEB_ROOT}/cart.php?a=view">
                <i class="far fa-shopping-cart"></i>
                <span class="badge">{$cartitemcount}</span>
            </a></li>
            <li class="d-xl-none">
                <button data-toggle="collapse" data-target="#mainNavbar">☰</button>
            </li>
        </ul>
    </div>
</div>
```

**Key variables:**
- `{$assetLogoPath}` — Logo path (falls back to company name text)
- `{$cartitemcount}` — Items in cart (integer)
- `{$companyname}` — For logo alt text

### 5. Collapsible Navigation

The actual menu items are rendered via `includes/navbar.tpl`:

```smarty
<div class="navbar navbar-expand-xl">
    <div class="container">
        <div class="collapse navbar-collapse" id="mainNavbar">
            <ul id="nav" class="navbar-nav mr-auto">
                {include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
            </ul>
            <ul class="navbar-nav ml-auto">
                {include file="$template/includes/navbar.tpl" navbar=$secondaryNavbar rightDrop=true}
            </ul>
        </div>
    </div>
</div>
```

- **Primary** (`$primaryNavbar`) — Main menu items, left-aligned
- **Secondary** (`$secondaryNavbar`) — User menu, right-aligned

`rightDrop=true` makes dropdowns open to the right.

### 6. Breadcrumb

```smarty
<nav class="master-breadcrumb">
    <div class="container">
        {include file="$template/includes/breadcrumb.tpl"}
    </div>
</nav>
```

Renders the `$breadcrumb` array as `<ol class="breadcrumb">`.

### 7. Notification Banners

```smarty
{include file="$template/includes/network-issues-notifications.tpl"}
{include file="$template/includes/validateuser.tpl"}
{include file="$template/includes/verifyemail.tpl"}
```

Each is conditionally shown:
- **Network issues** — If `$openNetworkIssueCounts.open > 0`
- **User validation** — If `$showUserValidationBanner`
- **Email verification** — If `$showEmailVerificationBanner`

### 8. Domain Search (Homepage)

Shown only on the public homepage:

```smarty
{if $templatefile == 'homepage'}
    {if $registerdomainenabled || $transferdomainenabled}
        {include file="$template/includes/domain-search.tpl"}
    {/if}
{/if}
```

### 9. Main Body Container

The content wrapper that opens in `header.tpl` and closes in `footer.tpl`:

```smarty
<section id="main-body">
    <div class="container">
        <div class="row">
            {* Sidebar column (conditional) *}
            <div class="col-lg-4 col-xl-3">
                {include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}
            </div>
            {* Primary content column *}
            <div class="col-lg-8 col-xl-9 primary-content">
                {* Page template renders here *}
```

**The sidebar is only shown when:**
1. NOT in shopping cart (`!$inShoppingCart`)
2. AND sidebars have children (`hasChildren()`)

**Column widths:**
- With sidebar: `col-lg-8 col-xl-9` (8/12 on large, 9/12 on xl)
- Without sidebar: `col-12` (full width)

---

## Required vs Optional Elements

### MANDATORY

These must be present or WHMCS features break:

- `<meta charset="{$charset}">` — Character encoding
- `{$headoutput}` — System head injection
- `{$headeroutput}` — System header injection
- `{$captcha->getMarkup()}` (if captcha enabled)
- `{include file="$template/includes/head.tpl"}` — Asset loading

### HIGHLY RECOMMENDED

Breaking these will lose significant functionality:

- Logo link to `{$WEB_ROOT}/index.php`
- `{$primaryNavbar}` rendering via navbar include
- `{$secondaryNavbar}` for user menu
- `{$primarySidebar}` rendering on applicable pages
- Breadcrumb include
- Network issues include
- Validate user / verify email includes
- Cart button with `{$cartitemcount}` badge

### OPTIONAL

Safe to remove/modify:

- Topbar (logged-in user info display)
- KB search form
- Mobile menu toggle style
- Admin masquerade button (but must exist somewhere)

---

## Customization Patterns

### Add a custom topbar message

```smarty
{if $loggedin}
    <div class="topbar">
        <div class="container">
            <div class="custom-message">
                Welcome back, {$client.firstName}!
            </div>
            {* ...existing topbar content... *}
        </div>
    </div>
{/if}
```

### Change logo to always use image

```smarty
<a class="navbar-brand" href="{$WEB_ROOT}/index.php">
    <img src="{$WEB_ROOT}/assets/img/logo.png" alt="{$companyname}" class="logo-img">
</a>
```

### Remove search from header

Simply delete the `<form method="post" action="{routePath('knowledgebase-search')}">` block.

### Add custom header banner above navbar

```smarty
<header id="header">
    <div class="header-announcement bg-primary text-white text-center py-2">
        Summer Sale - 50% off all hosting! <a href="/sale">Learn more</a>
    </div>
    {* ...existing header content... *}
</header>
```

---

## Common Mistakes

### ❌ Missing `{$headoutput}`

```smarty
<head>
    <title>{$pagetitle}</title>
    {include file="$template/includes/head.tpl"}
    {* MISSING {$headoutput} - CAPTCHA, modules, hooks all break *}
</head>
```

### ❌ Not closing primary-content

```smarty
{* Missing closing tags - footer.tpl expects these open *}
<section id="main-body">
    <div class="container">
        {* No <div class="row"> or primary-content div *}
```

### ❌ Hardcoding navigation

```smarty
{* Hardcoded navigation breaks hooks and extensibility *}
<ul>
    <li><a href="/home">Home</a></li>
    <li><a href="/products">Products</a></li>
</ul>
```

### ✅ Use navbar include

```smarty
<ul id="nav" class="navbar-nav">
    {include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
</ul>
```

---

## Testing Your header.tpl

After modifications, test:

1. **Homepage** - `/` - Should show domain search
2. **Client dashboard** - `/clientarea.php` - Should show topbar + sidebar
3. **Cart** - `/cart.php` - Sidebar should be hidden
4. **Login page** - `/login.php` - Should NOT show topbar
5. **Mobile viewport** - Navbar should collapse
6. **Admin masquerade** - Should show return-to-admin button
7. **With notifications** - Popover should show alert list
8. **Network issue active** - Banner should appear

---

## Next Steps

- [Footer Template](/starter/footer-template.md) — Complete `footer.tpl` walkthrough
- [Navigation System](/components/navigation.md) — MenuItem API
- [Include Components](/components/includes.md) — All reusable partials
- [System Output Variables](/reference/system-output.md) — What `$headoutput` contains
