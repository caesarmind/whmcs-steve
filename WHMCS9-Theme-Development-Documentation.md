# WHMCS 9 Theme Development - Complete Documentation

> Comprehensive reference for building WHMCS 9 themes based on the Nexus theme architecture.
> Derived from analysis of all 279 Nexus theme files and official WHMCS developer documentation.

---

## Table of Contents

1. [Overview & Architecture](#1-overview--architecture)
2. [Getting Started](#2-getting-started)
3. [Directory & File Reference](#3-directory--file-reference)
4. [Template Hierarchy & Layout System](#4-template-hierarchy--layout-system)
5. [Smarty Template Patterns Reference](#5-smarty-template-patterns-reference)
6. [Custom WHMCS Smarty Functions](#6-custom-whmcs-smarty-functions)
7. [Template Variables Reference](#7-template-variables-reference)
8. [Navigation System](#8-navigation-system)
9. [Sidebar System](#9-sidebar-system)
10. [Reusable Include Components](#10-reusable-include-components)
11. [CSS & SASS Architecture](#11-css--sass-architecture)
12. [JavaScript Integration](#12-javascript-integration)
13. [Form Patterns](#13-form-patterns)
14. [Store & Marketplace Templates](#14-store--marketplace-templates)
15. [Payment Templates](#15-payment-templates)
16. [OAuth Templates](#16-oauth-templates)
17. [Error Templates](#17-error-templates)
18. [Cart Theme (nexus_cart)](#18-cart-theme-nexus_cart)
19. [Hooks Reference](#19-hooks-reference)
20. [Best Practices & Common Pitfalls](#20-best-practices--common-pitfalls)
21. [Additional Smarty Patterns](#21-additional-smarty-patterns-supplement-to-section-5)
22. [Complete Page-Specific Variables Reference](#22-complete-page-specific-variables-reference-supplement-to-section-7)
23. [JavaScript Deep Reference](#23-javascript-deep-reference-supplement-to-section-12)
24. [Payment Flow Details](#24-payment-flow-details-supplement-to-section-15)
25. [PDF Templates (Non-Smarty)](#25-pdf-templates-non-smarty)
26. [Error Template Details](#26-error-template-details-supplement-to-section-17)
27. [Cart Theme Deep Reference](#27-cart-theme-deep-reference-supplement-to-section-18)
28. [Dynamic Store Block Variables](#28-dynamic-store-block-variables-supplement-to-section-14)
29. [OAuth Template Variables](#29-oauth-template-variables-supplement-to-section-16)
30. [Complete Form Actions Reference](#30-complete-form-actions-reference)
31. [CSS Component Classes Reference](#31-css-component-classes-reference)

---

## 1. Overview & Architecture

### Theme Types

WHMCS supports three types of themes:

| Type | Description | Use Case |
|------|-------------|----------|
| **Parent Theme** | Complete standalone theme | Base for child themes |
| **Child Theme** | Inherits from parent, overrides selectively | Recommended for customization |
| **Order Form Template** | Controls shopping cart/product display | Cart customization |

### Available Parent Themes (WHMCS 9)

- **Nexus** - Default theme for WHMCS 9.0+ (Bootstrap 4.5.3, jQuery 1.12.4, FontAwesome 5.10.1)
- **Twenty-One** - Default for WHMCS 8.1+
- **Six** - Legacy theme

### Theme Directory Naming Rules

- Single words only (no spaces)
- Lowercase letters and numbers only
- Child themes can also use hyphens and underscores
- Location: `/templates/yourthemename/`

### Asset Loading Chain

The asset loading order is critical for CSS specificity:

```
1. Open Sans font CSS (loaded via PHP helper)
2. all.min.css (Bootstrap 4.5.3 + base styles)
3. theme.min.css (Nexus theme-specific overrides)
4. FontAwesome CSS (solid, regular, light, brands, duotone)
5. custom.css (user customizations - loaded last, highest priority)
6. scripts.min.js (main theme JavaScript)
```

This chain is defined in `includes/head.tpl`:

```smarty
{\WHMCS\View\Asset::fontCssInclude('open-sans-family.css')}
<link href="{assetPath file='all.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{$WEB_ROOT}/assets/fonts/css/fontawesome.min.css" rel="stylesheet">
{assetExists file="custom.css"}
<link href="{$__assetPath__}" rel="stylesheet">
{/assetExists}
<script src="{assetPath file='scripts.min.js'}?v={$versionHash}"></script>
```

### theme.yaml Configuration

The `theme.yaml` file is the central configuration for every theme:

**Nexus theme.yaml:**
```yaml
name: "Nexus"
description: "The Default Theme for WHMCS 9.0"
author: "WHMCS Limited"
properties:
  serverSidePagination: false   # Client-side pagination via DataTables
provides:
  bootstrap: 4.5.3
  jquery: 1.12.4
  fontawesome: 5.10.1
```

**Parameters reference:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Display name in admin area |
| `description` | string | Theme explanation |
| `author` | string | Attribution |
| `config.parent` | string | Parent theme directory name (child themes only) |
| `properties.serverSidePagination` | boolean | Whether server handles pagination |
| `dependencies` | object | Required assets from parent theme |
| `provides` | object | Assets this theme provides to children |

Version flexibility: Missing version segments are assumed compatible (e.g., `fontawesome: 5` matches `5.10.1`).

---

## 2. Getting Started

### Creating a Child Theme (Recommended)

**Step 1: Create the directory**

```
/templates/mytheme/
```

**Step 2: Create `theme.yaml`**

```yaml
name: "My Custom Theme"
description: "Custom theme for my hosting company"
author: "Your Company"
config:
  parent: nexus
```

**Step 3: Create `css/custom.css`**

```css
/* Loads after all parent styles - highest specificity */
.primary-bg-color {
    background-color: #your-brand-color;
}
```

**Step 4: Copy only templates you want to customize**

Copy individual `.tpl` files from the parent theme. Uncustomized files automatically fall through to the parent version. Essential files to copy for structural changes:
- `header.tpl`
- `footer.tpl`

**Step 5: Preview your theme**

```
https://yourdomain.com/whmcs/?systpl=mytheme
```

**Step 6: Activate**

Configuration > System Settings > General Settings > System Theme dropdown.

### Loading Custom Assets

Use the `{assetPath}` function to reference theme-local assets:

```html
<link href="{assetPath file='mycssfile.css'}" rel="stylesheet">
<script src="{assetPath file='myjsfile.js'}"></script>
```

For assets in subdirectories (like the dynamic store):

```html
<link href="{assetPath ns='store/dynamic/assets' file='dynamic-store.css'}" rel="stylesheet">
```

---

## 3. Directory & File Reference

### Complete Nexus Theme Structure

```
nexus/
├── theme.yaml                              # Theme configuration
├── index.php                               # Security redirect
│
├── [ROOT TEMPLATES - 46+ .tpl files]       # Page-level templates
│   ├── header.tpl                          # Page header wrapper (opens layout)
│   ├── footer.tpl                          # Page footer wrapper (closes layout)
│   ├── homepage.tpl                        # Public homepage
│   ├── login.tpl                           # Login page
│   ├── clientareahome.tpl                  # Client dashboard
│   ├── clientarea*.tpl                     # Client area pages (20+ files)
│   ├── account-*.tpl                       # Account management pages
│   ├── user-*.tpl                          # User profile/security pages
│   ├── support*.tpl                        # Support ticket pages
│   ├── announcement*.tpl                   # Announcement pages
│   ├── knowledgebase*.tpl                  # KB pages
│   ├── domain-pricing.tpl                  # Domain pricing table
│   ├── upgrade*.tpl                        # Service upgrade pages
│   ├── configuressl-*.tpl                  # SSL configuration pages
│   └── ...                                 # Other page templates
│
├── includes/                               # Reusable partial templates
│   ├── head.tpl                            # CSS/JS asset loading
│   ├── navbar.tpl                          # Navigation bar renderer
│   ├── sidebar.tpl                         # Sidebar renderer
│   ├── breadcrumb.tpl                      # Breadcrumb navigation
│   ├── alert.tpl                           # Alert/notification component
│   ├── flashmessage.tpl                    # Flash message component
│   ├── modal.tpl                           # Modal dialog component
│   ├── panel.tpl                           # Card/panel component
│   ├── tablelist.tpl                       # DataTables list component
│   ├── captcha.tpl                         # CAPTCHA integration
│   ├── domain-search.tpl                   # Homepage domain search
│   ├── validateuser.tpl                    # User validation banner
│   ├── verifyemail.tpl                     # Email verification banner
│   ├── linkedaccounts.tpl                  # OAuth/social login links
│   ├── social-accounts.tpl                 # Social media footer links
│   ├── generate-password.tpl               # Password generator modal
│   ├── pwstrength.tpl                      # Password strength meter
│   ├── confirmation.tpl                    # Confirmation modal
│   ├── network-issues-notifications.tpl    # Network status alerts
│   ├── active-products-services-item.tpl   # Service list item
│   └── sitejet/
│       └── homepagepanel.tpl               # Sitejet website builder panel
│
├── css/                                    # Compiled stylesheets
│   ├── all.css / all.min.css               # Bootstrap + base styles
│   ├── theme.css / theme.min.css           # Theme-specific styles
│   ├── custom.css                          # User customizations
│   ├── invoice.css / invoice.min.css       # Invoice styling
│   ├── oauth.css                           # OAuth page styling
│   └── store.css                           # Marketplace store styling
│
├── sass/                                   # SCSS source files (30 files)
│   ├── theme.scss                          # Main compilation entry
│   ├── invoice.scss                        # Invoice compilation entry
│   ├── _global.scss                        # Base styles, typography
│   ├── _layout.scss                        # Grid, header, footer layout
│   ├── _colors.scss                        # Color classes & status colors
│   ├── _forms.scss                         # Form element styles
│   ├── _buttons.scss                       # Button variants
│   ├── _tables.scss                        # Table styles
│   ├── _tabs.scss                          # Tab component
│   ├── _sidebar.scss                       # Sidebar navigation
│   ├── _pagination.scss                    # Pagination component
│   ├── _home.scss                          # Public homepage
│   ├── _client-home.scss                   # Client dashboard
│   ├── _products.scss                      # Product listing
│   ├── _product-details.scss               # Product detail page
│   ├── _payments.scss                      # Payment forms
│   ├── _billing-address.scss               # Billing address
│   ├── _cart.scss                          # Shopping cart
│   ├── _registration.scss                  # Registration form
│   ├── _support.scss                       # Support tickets
│   ├── _affiliate.scss                     # Affiliate program
│   ├── _upgrades.scss                      # Upgrade pages
│   ├── _view-invoice.scss                  # Invoice view
│   ├── _two-factor.scss                    # 2FA pages
│   ├── _email-verification.scss            # Email verification
│   ├── _popover.scss                       # Popover component
│   ├── _socials.scss                       # Social media
│   ├── _marketconnect.scss                 # MarketConnect
│   ├── _markdown.scss                      # Markdown editor
│   ├── _tlds.scss                          # TLD/domain styles
│   └── _captcha.scss                       # CAPTCHA styles
│
├── js/                                     # JavaScript files
│   ├── scripts.js / scripts.min.js         # Main theme JS
│   └── whmcs.js                            # WHMCS utility functions
│
├── images/                                 # Theme images
│   ├── close.png, loading.gif
│   ├── next.png, prev.png
│
├── img/                                    # Additional images
│   ├── flags.png / flags@2x.png            # Country flag sprites
│   ├── globe.png, loader.gif
│   ├── shadow-left.png, worldmap.png
│
├── error/                                  # Error page templates
│   ├── internal-error.tpl
│   ├── page-not-found.tpl
│   ├── rate-limit-exceeded.tpl
│   └── unknown-routepath.tpl
│
├── oauth/                                  # OAuth flow templates
│   ├── layout.tpl                          # OAuth page wrapper
│   ├── login.tpl                           # OAuth login
│   ├── login-twofactorauth.tpl             # OAuth 2FA
│   ├── authorize.tpl                       # OAuth authorization
│   └── error.tpl                           # OAuth error
│
├── payment/                                # Payment processing templates
│   ├── billing-address.tpl                 # Billing address form
│   ├── invoice-summary.tpl                 # Invoice summary display
│   ├── card/                               # Credit card payments
│   │   ├── select.tpl                      # Card selection
│   │   ├── inputs.tpl                      # Card number/CVV fields
│   │   └── validate.tpl                    # Card validation
│   └── bank/                               # Bank transfer payments
│       ├── select.tpl                      # Bank selection
│       ├── inputs.tpl                      # Bank details fields
│       └── validate.tpl                    # Bank validation
│
└── store/                                  # Marketplace/store templates
    ├── order.tpl                           # Product order page
    ├── not-found.tpl                       # Store 404
    ├── addon/                              # Add-on products
    │   ├── wp-toolkit-cpanel.tpl
    │   └── wp-toolkit-plesk.tpl
    ├── config-fields/                      # Configuration field types
    │   ├── boolean.tpl
    │   ├── input.tpl
    │   ├── select.tpl
    │   └── textarea.tpl
    ├── dynamic/                            # Dynamic store system
    │   ├── index.tpl                       # Dynamic store entry
    │   ├── assets/
    │   │   ├── dynamic-store.css
    │   │   └── dynamic-store.js
    │   └── partial/                        # Dynamic block partials
    │       ├── header.tpl
    │       ├── grid_of_cards.tpl
    │       ├── price_comparison.tpl
    │       ├── product_preview.tpl
    │       ├── faq.tpl
    │       ├── free_form.tpl
    │       └── video.tpl
    ├── ssl/                                # SSL certificate store
    │   ├── index.tpl, dv.tpl, ov.tpl, ev.tpl, wildcard.tpl
    │   ├── competitive-upgrade.tpl
    │   └── shared/                         # Shared SSL components
    │       ├── certificate-item.tpl
    │       ├── certificate-pricing.tpl
    │       ├── currency-chooser.tpl
    │       ├── features.tpl, logos.tpl, nav.tpl
    └── [provider]/                         # Per-provider integrations
        ├── codeguard/, marketgoo/, nordvpn/
        ├── ox/, sitebuilder/, sitelock/
        ├── sitelockvpn/, socialbee/
        ├── spamexperts/, threesixtymonitoring/
        ├── weebly/, xovinow/
        └── promos/upsell.tpl
```

### Root Template Files - Complete List

#### Authentication & Access
| File | Purpose |
|------|---------|
| `login.tpl` | Login form with social login |
| `clientregister.tpl` | New client registration |
| `3dsecure.tpl` | 3D Secure payment verification |
| `access-denied.tpl` | Access denied page |
| `banned.tpl` | Banned user page |
| `password-reset-container.tpl` | Password reset wrapper |
| `password-reset-email-prompt.tpl` | Email entry for reset |
| `password-reset-change-prompt.tpl` | New password entry |
| `password-reset-security-prompt.tpl` | Security question prompt |

#### Client Dashboard
| File | Purpose |
|------|---------|
| `clientareahome.tpl` | Client area dashboard with stats tiles and panels |
| `clientareadetails.tpl` | Edit account details form |
| `clientareasecurity.tpl` | Security settings |
| `clientareaemails.tpl` | Email history list |

#### Products & Services
| File | Purpose |
|------|---------|
| `clientareaproducts.tpl` | Products/services list with DataTable |
| `clientareaproductdetails.tpl` | Individual product details |
| `clientareaproductusagebilling.tpl` | Usage-based billing details |
| `upgrade.tpl` | Service upgrade selection |
| `upgrade-configure.tpl` | Upgrade configuration |
| `upgradesummary.tpl` | Upgrade summary/confirmation |
| `subscription-manage.tpl` | Subscription management |

#### Domains
| File | Purpose |
|------|---------|
| `clientareadomains.tpl` | Domain list with DataTable |
| `clientareadomaindetails.tpl` | Individual domain management |
| `clientareadomainaddons.tpl` | Domain addon services |
| `clientareadomaincontactinfo.tpl` | Domain WHOIS contact info |
| `clientareadomaindns.tpl` | DNS management |
| `clientareadomainemailforwarding.tpl` | Email forwarding |
| `clientareadomaingetepp.tpl` | Get EPP/auth code |
| `clientareadomainregisterns.tpl` | Register nameservers |
| `bulkdomainmanagement.tpl` | Bulk domain operations |
| `domain-pricing.tpl` | Domain pricing table |
| `managessl.tpl` | SSL certificate management |

#### Financial
| File | Purpose |
|------|---------|
| `clientareainvoices.tpl` | Invoice list |
| `invoice-payment.tpl` | Invoice payment page |
| `invoicepdf.tpl` | Invoice PDF template |
| `quotepdf.tpl` | Quote PDF template |
| `clientareaquotes.tpl` | Quotes list |
| `clientareaaddfunds.tpl` | Add funds to account |
| `masspay.tpl` | Mass payment page |

#### Support
| File | Purpose |
|------|---------|
| `supportticketslist.tpl` | Support tickets list |
| `supportticketsubmit-stepone.tpl` | Submit ticket - department selection |
| `supportticketsubmit-steptwo.tpl` | Submit ticket - details form |
| `supportticketsubmit-customfields.tpl` | Custom field rendering |
| `supportticketsubmit-kbsuggestions.tpl` | KB suggestions while typing |
| `supportticketsubmit-confirm.tpl` | Ticket submission confirmation |
| `viewticket.tpl` | View/reply to ticket |
| `ticketfeedback.tpl` | Ticket satisfaction feedback |

#### User Profile
| File | Purpose |
|------|---------|
| `user-profile.tpl` | User profile settings |
| `user-password.tpl` | Change password |
| `user-security.tpl` | Security settings (2FA) |
| `user-verify-email.tpl` | Email verification |
| `user-invite-accept.tpl` | Accept account invitation |
| `user-switch-account.tpl` | Switch between accounts |
| `user-switch-account-forced.tpl` | Forced account switch |
| `two-factor-challenge.tpl` | 2FA challenge page |
| `two-factor-new-backup-code.tpl` | New 2FA backup codes |

#### Account Management
| File | Purpose |
|------|---------|
| `account-contacts-manage.tpl` | Manage contacts |
| `account-contacts-new.tpl` | Add new contact |
| `account-paymentmethods.tpl` | Payment methods list |
| `account-paymentmethods-manage.tpl` | Add/edit payment method |
| `account-paymentmethods-billing-contacts.tpl` | Billing contacts |
| `account-user-management.tpl` | User management |
| `account-user-permissions.tpl` | User permissions |

#### Public Pages
| File | Purpose |
|------|---------|
| `homepage.tpl` | Public homepage |
| `contact.tpl` | Contact form |
| `announcements.tpl` | Announcements list |
| `viewannouncement.tpl` | Single announcement |
| `knowledgebase.tpl` | Knowledge base index |
| `knowledgebasearticle.tpl` | KB article |
| `knowledgebasecat.tpl` | KB category |
| `downloads.tpl` | Downloads index |
| `downloadscat.tpl` | Download category |
| `downloaddenied.tpl` | Download access denied |
| `serverstatus.tpl` | Server status page |
| `forwardpage.tpl` | URL forwarding page |

#### Other
| File | Purpose |
|------|---------|
| `affiliates.tpl` | Affiliate dashboard |
| `affiliatessignup.tpl` | Affiliate signup |
| `clientareacancelrequest.tpl` | Cancellation request |
| `configuressl-stepone.tpl` | SSL config step 1 |
| `configuressl-steptwo.tpl` | SSL config step 2 |
| `configuressl-complete.tpl` | SSL config complete |
| `viewemail.tpl` | View single email |
| `viewbillingnote.tpl` | View billing note |
| `markdown-guide.tpl` | Markdown editing guide |

---

## 4. Template Hierarchy & Layout System

### Page Rendering Flow

Every page in WHMCS follows this rendering structure:

```
header.tpl
  ├── <head> section
  │   └── includes/head.tpl (CSS, JS, fonts)
  ├── {$headoutput} (WHMCS system head output)
  ├── <header>
  │   ├── Topbar (logged-in user info, notifications)
  │   ├── Navbar (logo, search, cart)
  │   │   ├── includes/navbar.tpl (primary navigation)
  │   │   └── includes/navbar.tpl (secondary navigation)
  │   └── Breadcrumb (includes/breadcrumb.tpl)
  ├── includes/network-issues-notifications.tpl
  ├── includes/validateuser.tpl
  ├── includes/verifyemail.tpl
  ├── Domain search (homepage only)
  ├── <section id="main-body">
  │   ├── Sidebar (if applicable)
  │   │   ├── includes/sidebar.tpl (primary)
  │   │   └── includes/sidebar.tpl (secondary, desktop)
  │   └── Primary content area
  │       └── [PAGE TEMPLATE CONTENT HERE]
  │
footer.tpl
  ├── Secondary sidebar (mobile)
  ├── </section> (closes main-body)
  ├── <footer>
  │   ├── includes/social-accounts.tpl
  │   ├── Language/currency selector modal
  │   └── Footer links
  ├── Fullpage overlay (loading states)
  ├── modalAjax (system AJAX modal)
  ├── Language/currency chooser modal
  ├── Admin return-to-admin button
  ├── includes/generate-password.tpl
  └── {$footeroutput} (WHMCS system footer output)
```

### Layout Grid System

The Nexus theme uses Bootstrap 4's grid system for layout:

```smarty
{* From header.tpl - the main layout grid *}
<section id="main-body">
    <div class="{if !$skipMainBodyContainer}container{/if}">
        <div class="row">
            {* Sidebar column - only shown when sidebars have content *}
            {if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}
                <div class="col-lg-4 col-xl-3">
                    {include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}
                </div>
            {/if}

            {* Main content column - adjusts width based on sidebar presence *}
            <div class="{if !$inShoppingCart && ($primarySidebar->hasChildren() || $secondarySidebar->hasChildren())}col-lg-8 col-xl-9{else}col-12{/if} primary-content">
                {* Page template renders here *}
            </div>
        </div>
    </div>
</section>
```

**Key layout variables:**

| Variable | Type | Purpose |
|----------|------|---------|
| `$skipMainBodyContainer` | boolean | Removes `.container` wrapper for full-width pages |
| `$inShoppingCart` | boolean | Hides sidebars on cart pages |
| `$primarySidebar` | object | Primary sidebar menu object |
| `$secondarySidebar` | object | Secondary sidebar menu object |

### Include Chain

The template include hierarchy from top to bottom:

```
header.tpl
  └── includes/head.tpl           (assets: CSS, JS, fonts, CSRF token)
  └── includes/navbar.tpl         (primary + secondary navigation)
  └── includes/breadcrumb.tpl     (breadcrumb trail)
  └── includes/network-issues-notifications.tpl
  └── includes/validateuser.tpl   (user validation banner)
  └── includes/verifyemail.tpl    (email verification banner)
  └── includes/domain-search.tpl  (homepage only)
  └── includes/sidebar.tpl        (primary + secondary sidebars)

[PAGE CONTENT]
  └── includes/flashmessage.tpl   (per-page flash messages)
  └── includes/alert.tpl          (per-page alerts)
  └── includes/tablelist.tpl      (DataTable integration)
  └── includes/captcha.tpl        (CAPTCHA on forms)
  └── includes/modal.tpl          (modals as needed)

footer.tpl
  └── includes/social-accounts.tpl (footer social links)
  └── includes/generate-password.tpl (password generator modal)
```

---

## 5. Smarty Template Patterns Reference

### Variable Access

```smarty
{* Simple variable *}
{$companyname}

{* Array/object property access *}
{$client.companyname}
{$client.fullName}
{$service.id}
{$ticket.department}

{* Object method calls *}
{$item->getName()}
{$item->getUri()}
{$item->hasChildren()}
{$alert->getSeverity()}
{$alert->getMessage()}
{$productGroup->getRoutePath()}
{$product->pricing()->allAvailableCycles()}
{$pricing->cycle()}
{$pricing->isRecurring()}

{* Smarty special variables *}
{$smarty.capture.variableName}
{$smarty.server.PHP_SELF}

{* Loop iteration properties *}
{$item@first}        {* true on first iteration *}
{$item@last}         {* true on last iteration *}
{$item@iteration}    {* current iteration number (1-based) *}
```

### Modifiers (Pipe Syntax)

```smarty
{* String modifiers *}
{$variable|strtolower}
{$variable|lower}
{$variable|ucfirst}
{$variable|escape}
{$variable|strip_tags}
{$variable|addslashes}

{* Chained modifiers *}
{$announcement.text|strip_tags|strlen}

{* String replacement *}
{$variable|replace:'old':'new'}

{* Array count *}
{$array|count}
{* Or as function: *}
{count($array)}

{* Concatenation modifier *}
{lang key="emailPreferences."|cat:$emailType}

{* Modifier on custom functions *}
{lang|addslashes key="markdown.title"}
{{lang key='more'}|lower}
```

### Conditional Patterns

```smarty
{* Basic if/else *}
{if $loggedin}
    Welcome back
{else}
    Please log in
{/if}

{* Comparison operators *}
{if $type eq "error"}danger{/if}
{if $lockstatus eq "unlocked"}...{/if}
{if $service.status|strtolower}...{/if}

{* Logical operators *}
{if $loggedin && $adminLoggedIn}...{/if}
{if $registerdomainenabled || $transferdomainenabled}...{/if}

{* Array functions *}
{if in_array('firstname', $optionalFields)}...{/if}
{if is_array($customActionData)}...{/if}
{if count($locales) > 1}...{/if}

{* Object method checks *}
{if $item->hasChildren()}...{/if}
{if $item->isCurrent()}...{/if}
{if $primarySidebar->hasChildren() || $secondarySidebar->hasChildren()}...{/if}

{* Null/empty checks *}
{if $client.companyname}...{/if}
{if !empty($productGroups)}...{/if}
{if isset($headerTitle)}...{/if}

{* Nested ternary-style *}
{if $alert->getSeverity() == 'danger'}exclamation-circle
{elseif $alert->getSeverity() == 'warning'}exclamation-triangle
{elseif $alert->getSeverity() == 'info'}info-circle
{else}check-circle{/if}

{* Iteration checks *}
{if $item@first}...{/if}
{if $item@last}...{/if}
{if $item@iteration is odd}...{/if}
{if $item@iteration is even}...{/if}

{* File existence check *}
{if file_exists("templates/$template/includes/alert.tpl")}...{/if}

{* Null coalescing via is_null *}
{if is_null($ticket.statusColor)}status-{$ticket.statusClass}"{else}status-custom" style="background-color:{$ticket.statusColor}"{/if}
```

### Loop Patterns

```smarty
{* Basic foreach *}
{foreach $services as $service}
    {$service.product} - {$service.domain}
{/foreach}

{* Foreach with else (empty array) *}
{foreach $clientAlerts as $alert}
    {$alert->getMessage()}
{foreachelse}
    {lang key='notificationsnone'}
{/foreach}

{* Nested foreach *}
{foreach $item->getChildren() as $childItem}
    {$childItem->getLabel()}
{/foreach}

{* Iteration checks within loops *}
{foreach $panels as $item}
    {if $item@iteration is odd}
        {outputHomePanels}
    {/if}
{/foreach}

{* First/last item checks *}
{foreach $breadcrumb as $item}
    <li class="breadcrumb-item{if $item@last} active{/if}">
        {if !$item@last}<a href="{$item.link}">{/if}
        {$item.label}
        {if !$item@last}</a>{/if}
    </li>
{/foreach}

{* Limiting iterations *}
{foreach $featuredTlds as $num => $tldinfo}
    {if $num < 3}
        ...
    {/if}
{/foreach}

{* Object method iteration *}
{foreach $product->pricing()->allAvailableCycles() as $pricing}
    {$pricing->cycle()} - {$pricing->monthlyPrice()}
{/foreach}

{* Eloquent-style query in template *}
{foreach $client->contacts()->orderBy('firstname', 'asc')->get() as $contact}
    {$contact->fullName}
{/foreach}
```

### Capture Blocks

Capture blocks store rendered content in a variable for later use:

```smarty
{capture name="domainUnlockedMsg"}
    <strong>{lang key='domaincurrentlyunlocked'}</strong><br />
    {lang key='domaincurrentlyunlockedexp'}
{/capture}

{* Use the captured content *}
{include file="$template/includes/alert.tpl" type="error" msg=$smarty.capture.domainUnlockedMsg}
```

### Variable Assignment

```smarty
{* Assign a variable *}
{assign "customActionData" $childItem->getAttribute('dataCustomAction')}

{* Assign from method return *}
{$blockType = $brandingBlock->getBlockType()}
{$blockLink = "$template/store/dynamic/partial/$blockType.tpl"}

{* Remove from collection *}
{assign "panels" $panels->removeChild($item->getName())}
```

### Function Definitions

You can define reusable template functions within a template:

```smarty
{function name=outputHomePanels}
    <div menuItemName="{$item->getName()}" class="card card-accent-{$item->getExtra('color')}">
        <div class="card-header">
            <h3 class="card-title m-0">
                {$item->getLabel()}
            </h3>
        </div>
        {if $item->hasBodyHtml()}
            <div class="card-body">
                {$item->getBodyHtml()}
            </div>
        {/if}
    </div>
{/function}

{* Call the function *}
{foreach $panels as $item}
    {outputHomePanels}
{/foreach}
```

### Literal Blocks

Prevents Smarty from parsing content (useful for JavaScript with curly braces):

```smarty
{literal}
    {...whmcsPaymentModuleMetadata, ...{event: e}}
{/literal}
```

### Dynamic Include Paths

```smarty
{* Variable-based template path *}
{$blockType = $brandingBlock->getBlockType()}
{$blockLink = "$template/store/dynamic/partial/$blockType.tpl"}
{include file=$blockLink config=$brandingBlock}
```

---

## 6. Custom WHMCS Smarty Functions

### `{assetPath}` - Theme Asset URL

Returns the URL path to a theme asset file.

```smarty
{* Basic usage *}
{assetPath file='all.min.css'}
{assetPath file='scripts.min.js'}
{assetPath file='theme.min.css'}

{* With version hash for cache busting *}
{assetPath file='all.min.css'}?v={$versionHash}

{* With namespace for subdirectory assets *}
{assetPath ns='store/dynamic/assets' file='dynamic-store.css'}
{assetPath ns='store/dynamic/assets' file='dynamic-store.js'}
```

### `{assetExists}` - Conditional Asset Loading

Block tag that only renders content if the asset file exists. Sets `{$__assetPath__}` inside the block:

```smarty
{assetExists file="custom.css"}
    <link href="{$__assetPath__}" rel="stylesheet">
{/assetExists}
```

### `{routePath}` - Route URL Generation

Generates URLs for named WHMCS routes:

```smarty
{* Simple route *}
{routePath('knowledgebase-search')}
{routePath('announcement-index')}
{routePath('knowledgebase-index')}
{routePath('download-index')}
{routePath('domain-pricing')}
{routePath('user-accounts')}
{routePath('login-validate')}
{routePath('password-reset-begin')}
{routePath('cart-order-login')}
{routePath('cart-order-addtocart')}
{routePath('cart-order-validate')}
{routePath('cart-order')}
{routePath('account-contacts')}
{routePath('dismiss-user-validation')}
{routePath('dismiss-email-verification')}
{routePath('user-email-verification-resend')}

{* Route with parameters *}
{routePath('announcement-view', $announcement.id, $announcement.urlfriendlytitle)}
{routePath('clientarea-sitejet-get-preview', $sitejetServices[0]->id)}
```

### `{lang}` - Language String

Outputs a translated language string:

```smarty
{* Basic usage *}
{lang key='loginbutton'}
{lang key='notifications'}
{lang key='clientareaemail'}

{* With modifier *}
{lang|addslashes key="markdown.title"}

{* With parameters *}
{lang key='copyrightFooterNotice' year=$date_year company=$companyname}
{lang key='passwordtips' maximum_length=$maximumPasswordLength}
{lang key='oauth.currentlyLoggedInAs' firstName=$userInfo.firstName lastName=$userInfo.lastName}

{* Nested key patterns *}
{lang key='clientHomePanels.productsAndServices'}
{lang key='userLogin.signInToContinue'}
{lang key='homepage.submitTicket'}
{lang key='store.choosePaymentTerm'}
{lang key='errorPage.404.title'}
{lang key='emailPreferences.general'}

{* Dynamic key construction *}
{lang key="emailPreferences."|cat:$emailType}
```

### `{include}` - Template Inclusion

Includes another template file with optional parameter passing:

```smarty
{* Basic include *}
{include file="$template/includes/head.tpl"}
{include file="$template/includes/flashmessage.tpl"}

{* Include with parameters *}
{include file="$template/includes/alert.tpl" type="success" msg="Changes saved"}
{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
{include file="$template/includes/alert.tpl" type="info" msg=$customMessage textcenter=true}

{* Include with object parameters *}
{include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
{include file="$template/includes/navbar.tpl" navbar=$secondaryNavbar rightDrop=true}
{include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}

{* Include with DataTable config *}
{include file="$template/includes/tablelist.tpl" 
    tableName="ServicesList" 
    filterColumn="4" 
    noSortColumns="0"}

{include file="$template/includes/tablelist.tpl" 
    tableName="DomainsList" 
    noSortColumns="0, 1" 
    startOrderCol="2" 
    filterColumn="5"}

{* Include with dynamic path *}
{include file=$blockLink config=$brandingBlock products=$products}
```

### `{get_flash_message}` - Flash Message Retrieval

Custom function to retrieve flash messages from the session:

```smarty
{if $message = get_flash_message()}
    <div class="alert alert-{$message.type}">
        {$message.text}
    </div>
{/if}
```

### PHP Class Methods in Templates

WHMCS exposes some PHP helpers directly:

```smarty
{* Asset helper *}
{\WHMCS\View\Asset::fontCssInclude('open-sans-family.css')}

{* Environment helper *}
{\WHMCS\Utility\Environment\WebHelper::getBaseUrl()}

{* Carbon date formatting *}
{$carbon->createFromTimestamp($announcement.timestamp)->format('jS F Y')}

{* Captcha methods *}
{$captcha->getMarkup()}
{$captcha->getPageJs()}
{$captcha->isEnabled()}
{$captcha->isEnabledForForm($captchaForm)}
{$captcha->getButtonClass($captchaForm)}
```

---

## 7. Template Variables Reference

### Global Variables (Available on Every Page)

#### Site Configuration

| Variable | Type | Description |
|----------|------|-------------|
| `{$companyname}` | string | Configured company name |
| `{$logo}` | string | Logo path |
| `{$assetLogoPath}` | string | Theme logo asset path |
| `{$systemurl}` | string | WHMCS system URL (SSL or non-SSL) |
| `{$systemsslurl}` | string | Configured SSL URL |
| `{$systemNonSSLURL}` | string | Configured non-SSL URL |
| `{$WEB_ROOT}` | string | Base WHMCS URL |

#### Asset Paths

| Variable | Type | Description |
|----------|------|-------------|
| `{$BASE_PATH_CSS}` | string | Common CSS assets path |
| `{$BASE_PATH_FONTS}` | string | Common fonts path |
| `{$BASE_PATH_IMG}` | string | Common images path |
| `{$BASE_PATH_JS}` | string | Common JavaScript path |
| `{$versionHash}` | string | Cache-busting version hash |

#### Client & Session

| Variable | Type | Description |
|----------|------|-------------|
| `{$loggedin}` | boolean | Whether a user is logged in |
| `{$client}` | object/null | Logged-in client object |
| `{$client.companyname}` | string | Client company name |
| `{$client.fullName}` | string | Client full name |
| `{$client.address1}` | string | Client address |
| `{$token}` | string | CSRF token for POST forms |
| `{$adminLoggedIn}` | boolean | Whether an admin is logged in |
| `{$adminMasqueradingAsClient}` | boolean | Admin viewing as client |

#### Page Information

| Variable | Type | Description |
|----------|------|-------------|
| `{$filename}` | string | Requested file base name |
| `{$templatefile}` | string | Current template file name |
| `{$pagetitle}` | string | Current page title |
| `{$template}` | string | Active theme directory name |
| `{$charset}` | string | Character set (usually UTF-8) |
| `{$language}` | string | Current display language |
| `{$breadcrumb}` | array | Breadcrumb items (link, label) |

#### Navigation Objects

| Variable | Type | Description |
|----------|------|-------------|
| `{$primaryNavbar}` | MenuItem | Primary navigation menu tree |
| `{$secondaryNavbar}` | MenuItem | Secondary navigation menu tree |
| `{$primarySidebar}` | MenuItem | Primary sidebar menu tree |
| `{$secondarySidebar}` | MenuItem | Secondary sidebar menu tree |

#### Date

| Variable | Type | Description |
|----------|------|-------------|
| `{$date_day}` | string | Current day |
| `{$date_month}` | string | Current month |
| `{$date_year}` | string | Current year |
| `{$todaysdate}` | string | Current date formatted |

#### Localization

| Variable | Type | Description |
|----------|------|-------------|
| `{$locales}` | array | Available locales |
| `{$activeLocale}` | object | Current locale |
| `{$activeLocale.countryCode}` | string | Current country code |
| `{$activeLocale.localisedName}` | string | Locale display name |
| `{$currencies}` | array | Available currencies |
| `{$activeCurrency}` | object | Current currency |
| `{$activeCurrency.id}` | int | Currency ID |
| `{$activeCurrency.code}` | string | Currency code (USD, EUR) |
| `{$activeCurrency.prefix}` | string | Currency symbol ($, etc.) |
| `{$languagechangeenabled}` | boolean | Whether language switching is enabled |

#### System Outputs

| Variable | Type | Description |
|----------|------|-------------|
| `{$headoutput}` | string | System-generated head HTML |
| `{$headeroutput}` | string | System-generated header HTML |
| `{$footeroutput}` | string | System-generated footer JS/HTML |
| `{$captcha}` | object | Captcha configuration object |
| `{$cartitemcount}` | int | Shopping cart item count |

#### Feature Flags

| Variable | Type | Description |
|----------|------|-------------|
| `{$registerdomainenabled}` | boolean | Domain registration enabled |
| `{$transferdomainenabled}` | boolean | Domain transfer enabled |
| `{$acceptTOS}` | boolean | TOS acceptance required |
| `{$tosURL}` | string | Terms of service URL |
| `{$condlinks.affiliates}` | boolean | Affiliate system enabled |
| `{$phoneNumberInputStyle}` | string | Phone number input style |

#### Footer

| Variable | Type | Description |
|----------|------|-------------|
| `{$socialAccounts}` | array | Social media accounts |
| `{$currentpagelinkback}` | string | Current page URL for lang/currency form |

### Page-Specific Variables

#### `homepage.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$productGroups}` | collection | Product group objects |
| `{$productGroup->name}` | string | Group name |
| `{$productGroup->tagline}` | string | Group tagline |
| `{$productGroup->getRoutePath()}` | string | Group URL |
| `{$numberOfDomains}` | int | Number of domains |
| `{$featuredTlds}` | array | Featured TLD info |
| `{$sitejetServices}` | array | Sitejet services for homepage panel |

#### `login.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$captcha}` | object | Captcha object |
| `{$captchaForm}` | string | Captcha form identifier |
| `{$linkableProviders}` | array | Social login providers |

#### `clientareahome.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$clientsstats}` | array | Client statistics |
| `{$clientsstats.productsnumactive}` | int | Active products count |
| `{$clientsstats.numactivedomains}` | int | Active domains count |
| `{$clientsstats.numactivetickets}` | int | Active tickets count |
| `{$clientsstats.numunpaidinvoices}` | int | Unpaid invoices count |
| `{$clientsstats.numdomains}` | int | Total domains |
| `{$clientsstats.isAffiliate}` | boolean | Is affiliate |
| `{$clientsstats.numaffiliatesignups}` | int | Affiliate signups |
| `{$clientsstats.numquotes}` | int | Quotes count |
| `{$clientAlerts}` | array | Client alert notifications |
| `{$panels}` | collection | Dashboard panel objects |
| `{$addons_html}` | array | Addon HTML outputs |
| `{$captchaError}` | string | Captcha error message |

#### `clientareaproducts.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$services}` | array | Service items |
| `{$service.id}` | int | Service ID |
| `{$service.product}` | string | Product name |
| `{$service.domain}` | string | Associated domain |
| `{$service.amount}` | string | Formatted amount |
| `{$service.amountnum}` | float | Numeric amount |
| `{$service.billingcycle}` | string | Billing cycle text |
| `{$service.nextduedate}` | string | Next due date |
| `{$service.normalisedNextDueDate}` | string | Sortable date |
| `{$service.status}` | string | Status code |
| `{$service.statustext}` | string | Status display text |
| `{$service.isActive}` | boolean | Is active |
| `{$service.sslStatus}` | object/null | SSL status info |
| `{$orderby}` | string | Sort column |
| `{$sort}` | string | Sort direction |

#### `clientareadomains.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$domains}` | array | Domain items |
| `{$domain.id}` | int | Domain ID |
| `{$domain.domain}` | string | Domain name |
| `{$domain.registrationdate}` | string | Registration date |
| `{$domain.normalisedRegistrationDate}` | string | Sortable reg date |
| `{$domain.nextduedate}` | string | Next due date |
| `{$domain.autorenew}` | boolean | Auto-renew enabled |
| `{$domain.statusClass}` | string | CSS status class |
| `{$domain.statustext}` | string | Status text |
| `{$domain.sslStatus}` | object/null | SSL status |
| `{$domain.isActive}` | boolean | Is active |
| `{$domain.expiringSoon}` | boolean | Expiring soon flag |
| `{$warnings}` | string | Warning messages |
| `{$allowrenew}` | boolean | Renewal allowed |

#### `supportticketslist.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$tickets}` | array | Ticket items |
| `{$ticket.tid}` | string | Ticket ID |
| `{$ticket.c}` | string | Ticket access code |
| `{$ticket.department}` | string | Department name |
| `{$ticket.subject}` | string | Ticket subject |
| `{$ticket.status}` | string | Status text |
| `{$ticket.statusClass}` | string | CSS status class |
| `{$ticket.statusColor}` | string/null | Custom status color |
| `{$ticket.lastreply}` | string | Last reply date |
| `{$ticket.normalisedLastReply}` | string | Sortable date |
| `{$ticket.unread}` | boolean | Has unread replies |

#### `clientareadetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$clientfirstname}` | string | Client first name |
| `{$clientlastname}` | string | Client last name |
| `{$clientcompanyname}` | string | Company name |
| `{$clientemail}` | string | Email address |
| `{$clientaddress1}` | string | Address line 1 |
| `{$clientaddress2}` | string | Address line 2 |
| `{$clientcity}` | string | City |
| `{$clientstate}` | string | State |
| `{$clientpostcode}` | string | Postal code |
| `{$clientphonenumber}` | string | Phone number |
| `{$clientcountriesdropdown}` | string | Pre-rendered country dropdown |
| `{$clientLanguage}` | string | Client language preference |
| `{$clientTaxId}` | string | Tax ID |
| `{$uneditablefields}` | array | Fields that cannot be edited |
| `{$optionalFields}` | array | Fields that are optional |
| `{$paymentmethods}` | array | Available payment methods |
| `{$defaultpaymentmethod}` | string | Default payment method |
| `{$contacts}` | array | Client contacts |
| `{$billingcid}` | int | Default billing contact ID |
| `{$languages}` | array | Available languages |
| `{$customfields}` | array | Custom field definitions |
| `{$emailPreferencesEnabled}` | boolean | Email preferences enabled |
| `{$emailPreferences}` | array | Email preference settings |
| `{$showTaxIdField}` | boolean | Show tax ID field |
| `{$taxIdLabel}` | string | Tax ID field label key |
| `{$showMarketingEmailOptIn}` | boolean | Show marketing opt-in |
| `{$marketingEmailOptIn}` | boolean | Currently opted in |
| `{$marketingEmailOptInMessage}` | string | Opt-in message |
| `{$accountDetailsExtraFields}` | array | Extra fields for account |
| `{$successful}` | boolean | Form save successful |
| `{$errormessage}` | string | Error message HTML |

#### `announcements.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$announcements}` | array | Announcement items |
| `{$announcement.id}` | int | Announcement ID |
| `{$announcement.title}` | string | Title |
| `{$announcement.text}` | string | Full HTML text |
| `{$announcement.summary}` | string | Summary text |
| `{$announcement.timestamp}` | int | Unix timestamp |
| `{$announcement.urlfriendlytitle}` | string | URL slug |
| `{$announcement.editLink}` | string/null | Admin edit link |
| `{$carbon}` | object | Carbon date helper |
| `{$pagination}` | array | Pagination items |
| `{$prevpage}` | boolean | Has previous page |
| `{$nextpage}` | boolean | Has next page |
| `{$announcementsFbRecommend}` | boolean | Facebook recommend enabled |

#### `store/order.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$product}` | object | Product object |
| `{$product->id}` | int | Product ID |
| `{$product->name}` | string | Product name |
| `{$product->description}` | string | Product description |
| `{$product->pricing()}` | object | Pricing object |
| `{$product->productKey}` | string | Product key identifier |
| `{$requireDomain}` | boolean | Domain required |
| `{$allowSubdomains}` | boolean | Subdomains allowed |
| `{$domains}` | array | Existing client domains |
| `{$selectedDomain}` | string | Pre-selected domain |
| `{$customDomain}` | string | Custom domain input |
| `{$requestedCycle}` | string | Requested billing cycle |
| `{$configurationFields}` | array | Config fields |
| `{$configFieldErrors}` | array | Config field errors |
| `{$upsellProduct}` | object/null | Upsell product |
| `{$promotion}` | object/null | Promotion data |

#### `store/dynamic/index.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$pageData}` | object | Dynamic page configuration |
| `{$pageData->branding}` | object | Branding colors |
| `{$pageData->branding->primaryColor}` | string | Primary color |
| `{$pageData->branding->secondaryColor}` | string | Secondary color |
| `{$pageData->branding->accentColor}` | string | Accent color |
| `{$pageData->branding->textColor}` | string | Text color |
| `{$pageData->branding->backgroundColor}` | string | Background color |
| `{$pageData->blocks->items}` | collection | Content blocks |
| `{$storeConfig->typography->p}` | string | Body font family |
| `{$products}` | array | Products for store |

### Debugging Variables

Add `{debug}` to any template to see a popup with all available variables in that template's context.

---

## 8. Navigation System

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

---

## 9. Sidebar System

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

---

## 10. Reusable Include Components

### `alert.tpl` - Alert/Notification

Renders Bootstrap alert messages.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | yes | Alert type: `success`, `error`, `warning`, `info` |
| `msg` | string | conditional | Message content (HTML supported) |
| `errorshtml` | string | conditional | Error list HTML (renders as `<ul>`) |
| `title` | string | no | Alert heading |
| `textcenter` | boolean | no | Center-align text |
| `additionalClasses` | string | no | Extra CSS classes |
| `hide` | boolean | no | Initially hidden (w-hidden class) |
| `idname` | string | no | HTML element ID |

**Usage examples:**

```smarty
{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}

{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}

{include file="$template/includes/alert.tpl" type="warning" msg=$warnings textcenter=true}

{include file="$template/includes/alert.tpl" type="info" msg="<small><i class='fa fa-info-circle'></i> {lang key='passwordtips'}</small>"}
```

**Note:** `type="error"` maps to Bootstrap's `alert-danger` class.

### `flashmessage.tpl` - Flash Messages

Renders session flash messages. No parameters needed - retrieves message from session automatically.

```smarty
{include file="$template/includes/flashmessage.tpl"}
```

Internally uses `{get_flash_message()}` which returns `{type, text}`.

### `modal.tpl` - Modal Dialog

Renders a Bootstrap modal.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | yes | Modal identifier (used in ID) |
| `title` | string | yes | Modal title |
| `content` | string | no | Modal body text |
| `submitAction` | string | no | onclick JS for submit button |
| `submitLabel` | string | no | Submit button text |
| `closeLabel` | string | no | Close button text |

**Usage:**

```smarty
{include file="$template/includes/modal.tpl" 
    name="MyModal" 
    title="Confirm Action" 
    content="Are you sure?"
    submitAction="doSomething()"
    submitLabel="Confirm"}
```

**Opening the modal:**
```html
<button data-toggle="modal" data-target="#modalMyModal">Open</button>
```

### `panel.tpl` - Card/Panel

Renders a simple Bootstrap card.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | no | Card header background color class |
| `headerTitle` | string | no | Card header text |
| `bodyContent` | string | no | Card body HTML |
| `bodyTextCenter` | boolean | no | Center body text |
| `footerContent` | string | no | Card footer HTML |
| `footerTextCenter` | boolean | no | Center footer text |

### `tablelist.tpl` - DataTables Integration

Initializes jQuery DataTables with filtering, pagination, and sorting.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tableName` | string | yes | Table identifier (without `table` prefix) |
| `filterColumn` | int | no | Column index for sidebar filter buttons |
| `noSortColumns` | string | no | Comma-separated column indices to disable sorting |
| `startOrderCol` | int | no | Default sort column index (default: 0) |
| `noPagination` | boolean | no | Disable pagination |
| `noInfo` | boolean | no | Disable info text |
| `noSearch` | boolean | no | Disable search |
| `noOrdering` | boolean | no | Disable all ordering |
| `dontControlActiveClass` | boolean | no | Don't manage active class on filter buttons |

**Usage pattern:**

```smarty
{* Include the tablelist component *}
{include file="$template/includes/tablelist.tpl" 
    tableName="ServicesList" 
    filterColumn="4" 
    noSortColumns="0"}

{* Custom sort logic after initialization *}
<script>
jQuery(document).ready(function() {
    var table = jQuery('#tableServicesList').show().DataTable();
    {if $orderby == 'product'}
        table.order([1, '{$sort}'], [4, 'asc']);
    {/if}
    table.draw();
    jQuery('#tableLoading').hide();
});
</script>

{* The actual HTML table *}
<table id="tableServicesList" class="table table-list w-hidden">
    <thead>...</thead>
    <tbody>...</tbody>
</table>
<div id="tableLoading"><i class="fas fa-spinner fa-spin"></i> {lang key='loading'}</div>
```

**Important:** The table HTML must use `id="table{$tableName}"` and start with `class="w-hidden"`. The loading div is shown while DataTables initializes, then hidden.

### `captcha.tpl` - CAPTCHA Integration

Renders CAPTCHA (reCAPTCHA or default image CAPTCHA).

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `captchaForm` | string | context | Form identifier for captcha |
| `containerClass` | string | no | Container CSS class override |

**Usage:**

```smarty
{if $captcha->isEnabled()}
    {include file="$template/includes/captcha.tpl"}
{/if}
```

### `breadcrumb.tpl` - Breadcrumb Navigation

Renders breadcrumb trail from `$breadcrumb` array. No parameters - uses global `$breadcrumb` variable.

```smarty
{* Each item has: link, label *}
<ol class="breadcrumb">
    {foreach $breadcrumb as $item}
        <li class="breadcrumb-item{if $item@last} active{/if}">
            {if !$item@last}<a href="{$item.link}">{/if}
            {$item.label}
            {if !$item@last}</a>{/if}
        </li>
    {/foreach}
</ol>
```

### `domain-search.tpl` - Homepage Domain Search

Full domain search form with register/transfer buttons, CAPTCHA, and featured TLDs. Only shown on homepage:

```smarty
{if $templatefile == 'homepage'}
    {if $registerdomainenabled || $transferdomainenabled}
        {include file="$template/includes/domain-search.tpl"}
    {/if}
{/if}
```

### `confirmation.tpl` - Confirmation Modal

Button + modal pattern for confirming actions.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `modalId` | string | yes | Unique modal identifier |
| `buttonTitle` | string | yes | Trigger button text |
| `modalTitle` | string | yes | Modal heading |
| `modalBody` | string | yes | Confirmation message |
| `targetUrl` | string | yes | Action URL |
| `saveBtnTitle` | string | yes | Confirm button text |
| `saveBtnIcon` | string | no | Confirm button icon class |
| `closeBtnTitle` | string | yes | Cancel button text |
| `closeBtnIcon` | string | no | Cancel button icon class |

### `validateuser.tpl` - User Validation Banner

Shows document validation banner. Uses `$showUserValidationBanner` and `$userValidationUrl`.

### `verifyemail.tpl` - Email Verification Banner

Shows email verification banner. Uses `$showEmailVerificationBanner`.

### `social-accounts.tpl` - Social Media Links

Renders footer social media icons from `$socialAccounts` array.

### `network-issues-notifications.tpl` - Network Status

Shows alerts for open/scheduled network issues. Uses `$openNetworkIssueCounts.open` and `$openNetworkIssueCounts.scheduled`.

### `generate-password.tpl` - Password Generator

Modal with password generation controls. Self-contained with its own JavaScript.

### `pwstrength.tpl` - Password Strength Meter

Progress bar with JavaScript strength calculation. Uses `$maximumPasswordLength`, `$pwStrengthErrorThreshold`, `$pwStrengthWarningThreshold`.

### `linkedaccounts.tpl` - Social/OAuth Login

Renders social login buttons and linked accounts table.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `linkContext` | string | Context: `login`, `registration`, `checkout-existing`, `checkout-new`, `clientsecurity`, `linktable` |
| `customFeedback` | boolean | Use custom feedback container |

### `active-products-services-item.tpl` - Service List Item

Renders a single service item with status, domain, and action buttons for the client dashboard.

### `sitejet/homepagepanel.tpl` - Sitejet Panel

Renders the Sitejet website builder panel on the client homepage. Uses `$sitejetServices`.

---

## 11. CSS & SASS Architecture

### SCSS Compilation

The main SCSS entry point is `sass/theme.scss`, which imports all partials:

```scss
@import "../../../node_modules/bootstrap-four/scss/bootstrap";
@import "global";
@import "forms";
@import "layout";
@import "buttons";
@import "colors";
@import "tabs";
@import "pagination";
@import "sidebar";
@import "home";
@import "client-home";
@import "two-factor";
@import "popover";
@import "captcha";
@import "email-verification";
@import "markdown";
@import "marketconnect";
@import "socials";
@import "upgrades";
@import "affiliate";
@import "support";
@import "registration";
@import "payments";
@import "product-details";
@import "tlds";
@import "tables";
@import "products";
@import "cart";
```

This compiles to `css/theme.css` and `css/theme.min.css`.

A separate `sass/invoice.scss` compiles to `css/invoice.css`.

### SCSS Partial Purposes

| Partial | Purpose |
|---------|---------|
| `_global.scss` | Base typography, body styles, utility classes, overlay, form error states, print styles |
| `_layout.scss` | Header, footer, navbar, main-body section, grid layout |
| `_colors.scss` | Card accent colors, background colors, label colors, status colors |
| `_forms.scss` | Form controls, input groups, validation states |
| `_buttons.scss` | Button variants and overrides |
| `_tables.scss` | Table styles, DataTables overrides |
| `_tabs.scss` | Tab navigation component |
| `_pagination.scss` | Pagination component |
| `_sidebar.scss` | Sidebar cards, list groups, mobile select |
| `_home.scss` | Public homepage styles (hero, domain search, action icons) |
| `_client-home.scss` | Client dashboard tiles, stats, panels |
| `_products.scss` | Product listing pages |
| `_product-details.scss` | Individual product detail page |
| `_payments.scss` | Payment form styles |
| `_billing-address.scss` | Billing address form |
| `_cart.scss` | Shopping cart pages |
| `_registration.scss` | Client registration form |
| `_support.scss` | Support ticket pages |
| `_affiliate.scss` | Affiliate program pages |
| `_upgrades.scss` | Upgrade/renewal pages |
| `_view-invoice.scss` | Invoice viewing page |
| `_two-factor.scss` | Two-factor authentication pages |
| `_email-verification.scss` | Email verification UI |
| `_popover.scss` | Popover UI component |
| `_socials.scss` | Social media/linked accounts |
| `_marketconnect.scss` | MarketConnect store integration |
| `_markdown.scss` | Markdown editor/preview |
| `_tlds.scss` | TLD/domain pricing styles |
| `_captcha.scss` | CAPTCHA styling |

### CSS Variables System

The Nexus theme uses CSS custom properties (variables) extensively. Override them in `custom.css`:

```css
:root {
    /* Neutral shades (50-950 scale) */
    --neutral-50: #value;
    --neutral-100: #value;
    /* ... through --neutral-950 */

    /* Semantic colors */
    --primary-color: #your-brand-color;
    --secondary: #value;
    --success: #value;
    --info: #value;
    --notice: #value;
    --warning: #value;
    --error: #value;

    /* Text colors */
    --text: #value;
    --text-lifted: #value;
    --text-accented: #value;
    --text-muted: #value;
    --text-inverted: #value;

    /* Border colors */
    --border: #value;
    --border-lifted: #value;
    --border-accented: #value;
    --border-muted: #value;

    /* Background colors */
    --bg-lifted: #value;
    --bg-accented: #value;
    --bg-inverted: #value;

    /* Typography */
    --font-size-xs: #value;
    --font-size-sm: #value;
    --font-size-md: #value;
    --font-size-lg: #value;

    /* Spacing */
    --spacing-sm: #value;
    --spacing-md: #value;
    --spacing-lg: #value;

    /* Rounding */
    --rounding-sm: #value;
    --rounding-md: #value;
    --rounding-lg: #value;

    /* Other */
    --letter-spacing: #value;
    --disabled-opacity: #value;
}
```

### Color Accent Classes

Defined in `_colors.scss`, these classes are used throughout the theme:

```scss
/* Card accent colors (top border) */
.card-accent-gold      { border-top: 3px solid var(--yellow-300); }
.card-accent-green     { border-top: 3px solid var(--success-accented); }
.card-accent-red       { border-top: 3px solid var(--error); }
.card-accent-blue      { border-top: 3px solid var(--info); }
.card-accent-teal      { border-top: 3px solid var(--teal-300); }
/* ... and more (see full list in _colors.scss) */

/* Background color classes */
.bg-color-gold   { background-color: var(--yellow-300); }
.bg-color-green  { background-color: var(--success); }
.bg-color-red    { background-color: var(--error); }
.bg-color-blue   { background-color: var(--info); }
/* ... */

/* Status colors */
.status-active, .status-open, .status-completed { background-color: var(--success); }
.status-pending          { background-color: var(--warning); }
.status-suspended        { background-color: var(--yellow-300); }
.status-terminated       { background-color: var(--neutral); }
.status-unpaid           { background-color: var(--error); }
.status-paid             { background-color: var(--success); }
/* ... full list in _colors.scss */
```

### Customizing with `custom.css`

The `css/custom.css` file loads last and overrides everything. Best practice for style-only modifications:

```css
/* Override brand colors */
:root {
    --primary-color: #2563eb;
    --success: #16a34a;
}

/* Override specific elements */
.header {
    background-color: #1e293b;
}

.navbar-brand img {
    max-height: 50px;
}

/* Custom homepage styling */
.home-domain-search {
    background: linear-gradient(135deg, #667eea, #764ba2);
}
```

---

## 12. JavaScript Integration

### Asset Files

| File | Purpose |
|------|---------|
| `js/scripts.js` / `js/scripts.min.js` | Main theme JavaScript (Bootstrap, UI interactions) |
| `js/whmcs.js` | WHMCS utility functions (AJAX, HTTP client) |
| `store/dynamic/assets/dynamic-store.js` | Dynamic store interactivity |

### Global JavaScript Variables

Set in `includes/head.tpl`:

```javascript
var csrfToken = '{$token}';                    // CSRF token for AJAX
var markdownGuide = '{lang|addslashes key="markdown.title"}';
var locale = '{if !empty($mdeLocale)}{$mdeLocale}{else}en{/if}';
var saved = '{lang|addslashes key="markdown.saved"}';
var saving = '{lang|addslashes key="markdown.saving"}';
var whmcsBaseUrl = "{\WHMCS\Utility\Environment\WebHelper::getBaseUrl()}";
```

### WHMCS JavaScript API

The `WHMCS` global object provides utilities:

```javascript
// HTTP client for AJAX
WHMCS.http.jqClient.post(url, data, callback, 'json');

// Route URL generation
WHMCS.utils.getRouteUrl('/clientarea/sitejet/service/' + serviceId + '/preview');
```

### DataTables Integration Pattern

Every list page follows this pattern:

```smarty
{* 1. Include the tablelist component (filter + DataTables init) *}
{include file="$template/includes/tablelist.tpl" tableName="ServicesList" filterColumn="4" noSortColumns="0"}

{* 2. Custom sort logic *}
<script>
jQuery(document).ready(function() {
    var table = jQuery('#tableServicesList').show().DataTable();
    {if $orderby == 'product'}
        table.order([1, '{$sort}'], [4, 'asc']);
    {elseif $orderby == 'amount'}
        table.order(2, '{$sort}');
    {/if}
    table.draw();
    jQuery('#tableLoading').hide();
});
</script>

{* 3. HTML table (initially hidden) *}
<div class="table-container clearfix">
    <table id="tableServicesList" class="table table-list w-hidden">
        <thead>
            <tr>
                <th>{lang key='orderproduct'}</th>
                <th>{lang key='clientareaaddonpricing'}</th>
            </tr>
        </thead>
        <tbody>
            {foreach $services as $service}
                <tr onclick="clickableSafeRedirect(event, 'clientarea.php?action=productdetails&amp;id={$service.id}', false)">
                    <td>{$service.product}</td>
                    <td>{$service.amount}</td>
                </tr>
            {/foreach}
        </tbody>
    </table>
    {* 4. Loading indicator *}
    <div class="text-center" id="tableLoading">
        <p><i class="fas fa-spinner fa-spin"></i> {lang key='loading'}</p>
    </div>
</div>
```

### Common JavaScript Patterns

**Clickable table rows:**
```html
<tr onclick="clickableSafeRedirect(event, 'clientarea.php?action=productdetails&amp;id={$service.id}', false)">
```

**Select-based navigation:**
```html
<select onchange="selectChangeNavigate(this)">
```

**AJAX domain validation:**
```javascript
WHMCS.http.jqClient.post('{routePath('cart-order-validate')}', 'domain=' + domainName, function(data) {
    if (data.valid) {
        // Valid domain
    } else {
        // Invalid domain
    }
}, 'json');
```

**Debounced input validation:**
```javascript
var delay = (function(){
    var timer = 0;
    return function(callback, ms){
        clearTimeout(timer);
        timer = setTimeout(callback, ms);
    };
})();

jQuery('.domain-input').keyup(function() {
    delay(function(){
        // Validate after 1 second of no typing
    }, 1000);
});
```

---

## 13. Form Patterns

### Standard Form Structure

```smarty
<form method="post" action="{routePath('account-contacts')}" role="form">
    {* Form group with label and input *}
    <div class="form-group">
        <label for="inputFirstName" class="col-form-label">{lang key='clientareafirstname'}</label>
        <input type="text" name="firstname" id="inputFirstName" 
               value="{$clientfirstname}"
               {if in_array('firstname', $uneditablefields)} disabled="disabled"{/if}
               class="form-control" />
    </div>

    {* Select dropdown *}
    <div class="form-group">
        <label for="inputPaymentMethod" class="col-form-label">{lang key='paymentmethod'}</label>
        <select name="paymentmethod" id="inputPaymentMethod" class="form-control custom-select">
            <option value="none">{lang key='paymentmethoddefault'}</option>
            {foreach $paymentmethods as $method}
                <option value="{$method.sysname}"
                    {if $method.sysname eq $defaultpaymentmethod} selected="selected"{/if}>
                    {$method.name}
                </option>
            {/foreach}
        </select>
    </div>

    {* Checkbox *}
    <div class="form-check">
        <input type="checkbox" class="form-check-input" name="rememberme" />
        {lang key='loginrememberme'}
    </div>

    {* Submit buttons *}
    <input class="btn btn-primary" type="submit" name="save" value="{lang key='clientareasavechanges'}" />
    <input class="btn btn-default" type="reset" value="{lang key='cancel'}" />
</form>
```

### Conditional Field Attributes

```smarty
{* Disabled field *}
<input type="text" name="firstname" value="{$clientfirstname}"
    {if in_array('firstname', $uneditablefields)} disabled="disabled"{/if}
    class="form-control" />

{* Required field *}
<input type="text" name="firstname"
    {if !in_array('firstname', $optionalFields)}required{/if}
    class="form-control" />
```

### Custom Fields Rendering

```smarty
{if $customfields}
    {foreach $customfields as $customfield}
        <div class="form-group">
            <label for="customfield{$customfield.id}">{$customfield.name}</label>
            <div class="control">
                {$customfield.input} {$customfield.description}
            </div>
        </div>
    {/foreach}
{/if}
```

### Input Group Pattern (Login)

```smarty
<div class="input-group input-group-merge">
    <div class="input-group-prepend">
        <span class="input-group-text"><i class="fas fa-user"></i></span>
    </div>
    <input type="email" class="form-control" name="username" id="inputEmail" 
           placeholder="name@example.com" autofocus>
</div>
```

### Password with Reveal Button

```smarty
<div class="input-group input-group-merge">
    <div class="input-group-prepend">
        <span class="input-group-text"><i class="fas fa-key"></i></span>
    </div>
    <input type="password" class="form-control pw-input" name="password" autocomplete="off">
    <div class="input-group-append">
        <button class="btn btn-default btn-reveal-pw" type="button" tabindex="-1">
            <i class="fas fa-eye"></i>
        </button>
    </div>
</div>
```

### Toggle Switch Pattern

```smarty
<input type="hidden" name="nostore" value="1">
<input type="checkbox" class="toggle-switch-success" data-size="mini" 
       checked="checked" name="nostore" id="inputNoStore" value="0" 
       data-on-text="{lang key='yes'}" data-off-text="{lang key='no'}">
```

### Email Preferences Pattern

```smarty
{foreach $emailPreferences as $emailType => $value}
    <label>
        <input type="hidden" name="email_preferences[{$emailType}]" value="0">
        <input type="checkbox" class="form-check-input" 
               name="email_preferences[{$emailType}]" 
               value="1"
               {if $value} checked="checked"{/if} />
        {lang key="emailPreferences."|cat:$emailType}
    </label>
{/foreach}
```

### CSRF Token

All POST forms should include the CSRF token. It's set as a JavaScript global:

```javascript
var csrfToken = '{$token}';
```

For AJAX requests, include it in the POST data.

---

## 14. Store & Marketplace Templates

### Store Architecture

The store system uses two approaches:

1. **Static store pages** (`store/{provider}/index.tpl`) - Provider-specific templates
2. **Dynamic store system** (`store/dynamic/`) - Data-driven pages built from content blocks

### Dynamic Store System

The dynamic store renders pages from configuration data:

```smarty
{* store/dynamic/index.tpl *}
<div class="dynamic-landing-page"
     style="
        --primary-color: {$pageData->branding->primaryColor};
        --secondary-color: {$pageData->branding->secondaryColor};
        --accent-color: {$pageData->branding->accentColor};
        --text-color: {$pageData->branding->textColor};
        --bg-color: {$pageData->branding->backgroundColor};
        font-family: {$storeConfig->typography->p};
     ">
    {foreach $pageData->blocks->items as $brandingBlock}
        {$blockType = $brandingBlock->getBlockType()}
        {include file="$template/store/dynamic/partial/$blockType.tpl"
            config=$brandingBlock
            products=$products}
    {/foreach}
</div>
```

### Dynamic Block Partials

| Partial | Purpose |
|---------|---------|
| `partial/header.tpl` | Hero section with heading and tagline |
| `partial/grid_of_cards.tpl` | Card grid layout for features |
| `partial/price_comparison.tpl` | Pricing comparison table |
| `partial/product_preview.tpl` | Product preview card |
| `partial/faq.tpl` | FAQ accordion section |
| `partial/free_form.tpl` | Free-form HTML content |
| `partial/video.tpl` | Video embed section |

### Configuration Fields

Product configuration fields are rendered via specialized templates:

```smarty
{foreach $configurationFields as $field}
    <div class="form-group">
        <label>{$field.label} {if $field.required}<span class="text-danger">*</span>{/if}</label>
        
        {if $field.type == 'select'}
            {include file="$template/store/config-fields/select.tpl" field=$field}
        {elseif $field.type == 'textarea'}
            {include file="$template/store/config-fields/textarea.tpl" field=$field}
        {elseif $field.type == 'boolean'}
            {include file="$template/store/config-fields/boolean.tpl" field=$field}
        {else}
            {include file="$template/store/config-fields/input.tpl" field=$field}
        {/if}
    </div>
{/foreach}
```

### Product Order Page (`store/order.tpl`)

The main product order page includes:
1. Product name and description
2. Billing cycle selector
3. Domain selection (tabs: existing, subdomain, custom, or none)
4. Configuration fields
5. Add to cart / checkout buttons
6. Upsell product promotion

### Marketplace Provider Templates

Each provider integration has:
- `{provider}/index.php` - Security redirect
- `{provider}/index.tpl` - Main product landing page
- `{provider}/manage.tpl` (optional) - Product management page

**Providers included:** CodeGuard, MarketGoo, NordVPN, Open-Xchange, Sitebuilder, Sitelock, SitelockVPN, SocialBee, SpamExperts, 360 Monitoring, Weebly, XoviNow

### SSL Certificate Store

The SSL store has its own structure:

```
store/ssl/
├── index.tpl                   # SSL store main page
├── dv.tpl                      # Domain Validation certificates
├── ov.tpl                      # Organization Validation
├── ev.tpl                      # Extended Validation
├── wildcard.tpl                # Wildcard certificates
├── competitive-upgrade.tpl     # Competitive upgrade offer
└── shared/                     # Shared components
    ├── certificate-item.tpl    # Certificate card
    ├── certificate-pricing.tpl # Pricing display
    ├── currency-chooser.tpl    # Currency selector
    ├── features.tpl            # Feature list
    ├── logos.tpl               # Trust logos
    └── nav.tpl                 # SSL store navigation
```

---

## 15. Payment Templates

### Payment Flow Architecture

```
payment/
├── billing-address.tpl       # Billing address selection/entry
├── invoice-summary.tpl       # Invoice details display
├── card/
│   ├── select.tpl            # Select existing card or add new
│   ├── inputs.tpl            # Card number, expiry, CVV fields
│   └── validate.tpl          # Card validation UI
└── bank/
    ├── select.tpl            # Select existing bank account
    ├── inputs.tpl            # Bank account fields
    └── validate.tpl          # Bank validation UI
```

### Card Input Template

The `payment/card/inputs.tpl` renders credit card fields:

```smarty
<div class="form-group cc-details row">
    <label class="col-sm-4 text-md-right col-form-label">{lang key='creditcardcardnumber'}</label>
    <div class="col-sm-7">
        <input type="tel" name="ccnumber" id="inputCardNumber" 
               autocomplete="off" class="form-control newccinfo cc-number-field"
               data-message-unsupported="{lang key='paymentMethodsManage.unsupportedCardType'}"
               data-message-invalid="{lang key='paymentMethodsManage.cardNumberNotValid'}"
               data-supported-cards="{$supportedCardTypes}"/>
    </div>
</div>
```

**Key variables:**
- `{$addingNewCard}` - Whether adding a new card
- `{$ccnumber}`, `{$ccexpirydate}`, `{$cccvv}` - Pre-filled values
- `{$showccissuestart}` - Show start date/issue number
- `{$supportedCardTypes}` - Supported card type list
- `{$allowClientsToRemoveCards}` - Card removal allowed

### Billing Address Template

Renders address selection with existing addresses and new address form. Uses Eloquent query directly in template:

```smarty
{foreach $client->contacts()->orderBy('firstname', 'asc')->get() as $contact}
    <label class="billing-contact-{$contact->id}">
        <input type="radio" name="billingcontact" value="{$contact->id}"
               {if $billingContact == $contact->id} checked{/if}>
        <strong>{$contact->fullName}</strong>
        {$contact->address1}, {$contact->city}, {$contact->state}
    </label>
{/foreach}
```

---

## 16. OAuth Templates

### OAuth Layout

The OAuth flow uses a separate layout (`oauth/layout.tpl`) that doesn't use the main header/footer:

```smarty
<!DOCTYPE html>
<html lang="en">
<head>
    <link href="{assetPath file='all.min.css'}" rel="stylesheet">
    <link href="{assetPath file='theme.min.css'}" rel="stylesheet">
    <link href="{assetPath file='oauth.css'}" rel="stylesheet">
</head>
<body>
    <section id="header">
        <img src="{$logo}" />
        {* Login/logout controls *}
    </section>
    <section id="content">
        {$content}  {* OAuth page content injected here *}
    </section>
    <section id="footer">
        {lang key='oauth.copyrightFooter' dateYear=$date_year companyName=$companyname}
    </section>
</body>
</html>
```

### OAuth Templates

| Template | Purpose | Key Variables |
|----------|---------|---------------|
| `oauth/login.tpl` | OAuth login form | `$username`, `$errors` |
| `oauth/login-twofactorauth.tpl` | 2FA during OAuth | `$errors` |
| `oauth/authorize.tpl` | App authorization prompt | `$appName`, `$scopes`, `$request_hash` |
| `oauth/error.tpl` | OAuth error display | `$error`, `$errorDescription` |

---

## 17. Error Templates

Located in `error/`, these templates display error pages:

| Template | Purpose | Key Variables |
|----------|---------|---------------|
| `error/page-not-found.tpl` | 404 Not Found | `{$systemurl}` |
| `error/internal-error.tpl` | 500 Internal Error | `{$systemurl}` |
| `error/rate-limit-exceeded.tpl` | Rate Limiting | |
| `error/unknown-routepath.tpl` | Unknown Route | |

### Error Page Pattern

```smarty
<div class="container">
    <div class="text-center p-5">
        <i class="fas fa-exclamation-circle display-1 text-primary"></i>
        <h1 class="display-1 font-weight-bold text-primary">{lang key="errorPage.404.title"}</h1>
        <h3>{lang key="errorPage.404.subtitle"}</h3>
        <p>{lang key="errorPage.404.description"}</p>
        <a href="{$systemurl}" class="btn btn-primary">{lang key="errorPage.404.home"}</a>
        <a href="{$systemurl}contact.php" class="btn btn-info">{lang key="errorPage.404.submitTicket"}</a>
    </div>
</div>
```

---

## 18. Cart Theme (nexus_cart)

### Overview

The Nexus cart theme is a separate order form template that controls the shopping cart pages.

**Key constraint:** The layout of Nexus SPA (Single Page Application) pages cannot be modified - only CSS customization is allowed.

### Structure

```
nexus_cart/
├── theme.yaml              # Parent: standard_cart
├── css/
│   ├── custom.css          # CSS variable overrides
│   └── style.min.css       # Compiled cart styles
├── js/
│   └── main.min.js         # Cart JavaScript
├── domainregister.tpl      # Domain registration page
├── viewcart.tpl            # View cart page
├── images/
│   └── tldLogos/           # TLD logo images (19 files)
└── thumbnail.gif           # Theme preview
```

### Configuration

```yaml
# nexus_cart/theme.yaml
config:
  parent: standard_cart
```

### CSS Customization

The Nexus Cart supports CSS variable overrides in `css/custom.css`:

```css
:root {
    /* Neutral shades */
    --neutral-50: #value;
    /* through --neutral-950 */

    /* Semantic colors */
    --primary-color: #value;
    --secondary: #value;
    --success: #value;
    --info: #value;
    --notice: #value;
    --warning: #value;
    --error: #value;

    /* Text, border, background variants */
    --text: #value;
    --text-lifted: #value;
    --text-accented: #value;
    --border: #value;
    --bg-lifted: #value;

    /* Typography */
    --font-size-xs: #value;
    --font-size-sm: #value;
    --font-size-md: #value;
    --font-size-lg: #value;

    /* Spacing & rounding */
    --spacing-sm: #value;
    --rounding-sm: #value;
    --letter-spacing: #value;
    --disabled-opacity: #value;
}
```

### SPA Pages (CSS-Only Customization)

- Domain pricing page
- Domain search results
- View cart page
- Checkout flow

### Preview Cart Theme

```
https://yourdomain.com/whmcs/cart.php?carttpl=nexus_cart
```

### Activation

Configuration > System Settings > General Settings > Ordering tab, or per product group.

---

## 19. Hooks Reference

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

---

## 20. Best Practices & Common Pitfalls

### DO

1. **Use child themes** - Never modify parent theme files directly
2. **Override CSS in `custom.css`** - Loads last, highest specificity
3. **Use hooks for PHP logic** - The only future-proof method
4. **Maintain all WHMCS template includes** - Missing includes break functionality
5. **Use `{$template}` in include paths** - Ensures correct theme resolution:
   ```smarty
   {include file="$template/includes/alert.tpl"}
   ```
6. **Use `{assetPath}` for asset URLs** - Resolves correct paths for child themes
7. **Use `{routePath()}` for URLs** - Generates correct WHMCS routes
8. **Use `{lang}` for all user-facing text** - Enables localization
9. **Test with `?systpl=mytheme`** - Preview before activating
10. **Use version control** - Fork the official GitHub repositories
11. **Keep `{$headoutput}` and `{$footeroutput}`** - Required for WHMCS operation
12. **Use `{$token}` in forms** - CSRF protection

### DON'T

1. **Never remove footer JavaScript** - The `{$footeroutput}` in footer.tpl is essential for client area operation
2. **Never use `{php}` blocks** - Deprecated, use hooks instead
3. **Never modify parent theme files** - Will be overwritten on update
4. **Don't remove `{$headeroutput}`** - Required for system functionality
5. **Don't hardcode URLs** - Use `{$WEB_ROOT}` or `{routePath()}`
6. **Don't hardcode text** - Use `{lang key='...'}` for translations
7. **Don't skip CSRF tokens** - POST forms need `{$token}`
8. **Don't change `theme.yaml` structure** - Follow the exact format
9. **Don't use spaces in theme directory names** - Only lowercase letters, numbers, hyphens, underscores
10. **Don't modify `all.min.css`** - Override in `theme.css` or `custom.css`

### Debugging

1. **See all template variables:** Add `{debug}` to any template file
2. **Check error logs:** Configuration > System Logs > Activity Log
3. **Isolate theme issues:** Switch to default theme to confirm the issue is theme-related
4. **Enable PHP tags (if needed):** Configuration > System Settings > General Settings > Security > "Allow Smarty PHP Tags"

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Blank page | Smarty syntax error | Check activity log, fix syntax |
| Missing sidebar | `$primarySidebar` not passed | Ensure header.tpl includes sidebar |
| Broken layout | Missing Bootstrap classes | Verify Bootstrap 4 class usage |
| JS errors | Missing `{$footeroutput}` | Restore footer output variable |
| Assets 404 | Wrong path | Use `{assetPath}` function |
| Forms broken | Missing CSRF token | Include `{$token}` in forms |

### Performance Tips

1. Use minified CSS/JS (`*.min.css`, `*.min.js`)
2. Use `{$versionHash}` for cache busting
3. Keep `serverSidePagination: false` for small datasets, switch to `true` for large ones
4. Optimize images in `/images/` and `/img/` directories
5. Use CSS variables for consistent theming (single source of truth)

---

## Appendix: Quick Reference

### Creating a New Page Template

1. Create `yourpage.tpl` in your child theme root
2. Content renders between header.tpl and footer.tpl automatically
3. Use standard includes:

```smarty
{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body">
        <h3 class="card-title">{lang key='yourPageTitle'}</h3>
        {* Your content here *}
    </div>
</div>
```

### Template Variable Debug Cheatsheet

```smarty
{* Show all variables *}
{debug}

{* Check specific variable *}
{if isset($myVar)}exists{else}not set{/if}

{* Dump array contents *}
{foreach $myArray as $key => $value}
    {$key}: {$value}<br>
{/foreach}

{* Check object type *}
{if is_array($var)}array{/if}
{if is_object($var)}object{/if}
```

### Common Route Names

```smarty
{routePath('knowledgebase-search')}
{routePath('knowledgebase-index')}
{routePath('announcement-index')}
{routePath('announcement-view', $id, $slug)}
{routePath('download-index')}
{routePath('domain-pricing')}
{routePath('login-validate')}
{routePath('password-reset-begin')}
{routePath('user-accounts')}
{routePath('cart-order')}
{routePath('cart-order-addtocart')}
{routePath('cart-order-validate')}
{routePath('cart-order-login')}
{routePath('account-contacts')}
{routePath('dismiss-user-validation')}
{routePath('dismiss-email-verification')}
{routePath('user-email-verification-resend')}
{routePath('login-two-factor-challenge-verify')}
{routePath('login-two-factor-challenge-backup-verify')}
{routePath('user-profile-save')}
{routePath('user-profile-email-save')}
{routePath('user-password')}
{routePath('user-security-question')}
{routePath('account-security-two-factor-enable')}
{routePath('account-security-two-factor-disable')}
{routePath('invite-validate', $invite->token)}
{routePath('account-users-permissions')}
{routePath('account-users-permissions-save', $user->id)}
{routePath('account-users-invite')}
{routePath('account-users-invite-resend')}
{routePath('account-users-invite-cancel')}
{routePath('account-users-remove')}
{routePath('account-paymentmethods-add')}
{routePath('account-contacts-save')}
{routePath('account-contacts-new')}
{routePath('password-reset-validate-email')}
{routePath('password-reset-change-perform')}
{routePath('password-reset-security-verify')}
{routePath('upgrade-add-to-cart')}
{routePath('download-search')}
{routePath('knowledgebase-article-view', $id, $slug)}
{routePath('knowledgebase-category-view', $id, $name)}
{routePath('clientarea-ssl-certificates-resend-approver-email')}
{routePath('announcement-view', $id, $slug)}
{routePath('fqdnRoutePath-announcement-view', $id, $slug)}  {* Fully qualified domain route *}
```

---

## 21. Additional Smarty Patterns (Supplement to Section 5)

### `{for}` Loop

The `{for}` construct is used for numeric iteration (e.g., nameserver fields, star ratings):

```smarty
{* Nameserver fields 1-5 *}
{for $num=1 to 5}
    <input type="text" name="ns{$num}" value="{$nameservers[$num]}" class="form-control" />
{/for}

{* Star rating 1-5 *}
{for $rating=1 to 5}
    <span class="star" data-rate="{$rating}">
        <i class="fas fa-star"></i>
    </span>
{/for}
```

### Additional Modifiers

| Modifier | Usage | Description |
|----------|-------|-------------|
| `\|truncate:100:"..."` | `{$article\|truncate:100:"..."}` | Truncate string with ellipsis |
| `\|nl2br` | `{$message\|nl2br}` | Convert newlines to `<br>` |
| `\|substr:0:-1` | `{$string\|substr:0:-1}` | PHP substr equivalent |
| `\|sprintf2:$param` | `{lang key='key'\|sprintf2:$value}` | String format with parameters |
| `\|escape` | `{$ticket.subject\|escape}` | HTML entity escaping |
| `\|count` | `{$array\|count}` | Array element count |

### Alternative `{assign}` Syntax

```smarty
{* Named parameter syntax *}
{assign var="approvalMethods" value=[]}
{assign var="customActionData" value=$childItem->getAttribute('dataCustomAction')}

{* Shorthand syntax *}
{$blockType = $brandingBlock->getBlockType()}
```

### `{$smarty.server}` Access

```smarty
{* PHP $_SERVER superglobal access *}
{$smarty.server.PHP_SELF}

{* Common usage in form actions *}
<form method="post" action="{$smarty.server.PHP_SELF}?action=details">
```

### `{$smarty.foreach}` Named Loop Properties

```smarty
{foreach from=$config->items item=faq name=faqs}
    {$smarty.foreach.faqs.index}    {* 0-based index *}
    {$smarty.foreach.faqs.first}    {* true on first *}
    {$smarty.foreach.faqs.last}     {* true on last *}
    {$smarty.foreach.faqs.total}    {* total count *}
{/foreach}
```

### Dynamic Include with `password-reset-container.tpl`

```smarty
{* Dynamic template inclusion based on variable *}
{include file="$template/password-reset-$innerTemplate.tpl"}
```

---

## 22. Complete Page-Specific Variables Reference (Supplement to Section 7)

### `clientareaproductdetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$id}` | int | Service/product ID |
| `{$type}` | string | Service type |
| `{$product}` | string | Product name |
| `{$groupname}` | string | Product group name |
| `{$domain}` | string | Associated domain |
| `{$status}` | string | Service status |
| `{$rawstatus}` | string | Raw status code |
| `{$regdate}` | string | Registration date |
| `{$firstpaymentamount}` | string | First payment amount |
| `{$recurringamount}` | string | Recurring amount |
| `{$billingcycle}` | string | Billing cycle |
| `{$nextduedate}` | string | Next due date |
| `{$paymentmethod}` | string | Payment method name |
| `{$suspendreason}` | string | Suspension reason |
| `{$dedicatedip}` | string | Dedicated IP address |
| `{$assignedips}` | string | Assigned IPs (newline-separated) |
| `{$ns1}` / `{$ns2}` | string | Nameservers |
| `{$serverdata.*}` | array | Server data (hostname, ip, etc.) |
| `{$diskpercent}` | int | Disk usage percentage |
| `{$diskusage}` | string | Disk usage amount |
| `{$disklimit}` | string | Disk limit |
| `{$bwpercent}` | int | Bandwidth usage percentage |
| `{$bwusage}` | string | Bandwidth usage |
| `{$bwlimit}` | string | Bandwidth limit |
| `{$lastupdate}` | string | Last usage update time |
| `{$configurableoptions}` | array | Configurable option details |
| `{$customfields}` | array | Custom fields |
| `{$downloads}` | array | Available downloads |
| `{$addons}` | array | Active addons |
| `{$addonsavailable}` | array | Available addon purchases |
| `{$moduleclientarea}` | string | Module client area HTML |
| `{$hookOutput}` | string | Hook output HTML |
| `{$tplOverviewTabOutput}` | string | Overview tab content |
| `{$pendingcancellation}` | boolean | Has pending cancellation |
| `{$unpaidInvoice}` | object/null | Unpaid invoice info |
| `{$unpaidInvoiceOverdue}` | boolean | Invoice is overdue |
| `{$showRenewServiceButton}` | boolean | Show renewal button |
| `{$showcancelbutton}` | boolean | Show cancel button |
| `{$packagesupgrade}` | boolean | Upgrades available |
| `{$quantity}` | int | Service quantity |
| `{$quantitySupported}` | boolean | Quantity is supported |
| `{$sslStatus}` | object | SSL status (getImagePath, getTooltipContent, getClass) |
| `{$modulecustombuttonresult}` | string | Custom button result message |
| `{$modulechangepwresult}` | string | Password change result |
| `{$modulechangepasswordmessage}` | string | Password change message |

### `clientareadomaindetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$domain}` | string | Domain name |
| `{$domainid}` | int | Domain ID |
| `{$status}` | string | Domain status |
| `{$firstpaymentamount}` | string | First payment |
| `{$registrationdate}` | string | Registration date |
| `{$registrationperiod}` | int | Registration period years |
| `{$recurringamount}` | string | Recurring amount |
| `{$nextduedate}` | string | Next due date |
| `{$paymentmethod}` | string | Payment method |
| `{$lockstatus}` | string | Lock status ("unlocked" / "locked") |
| `{$autorenew}` | boolean | Auto-renew enabled |
| `{$canDomainBeManaged}` | boolean | Domain can be managed |
| `{$managementoptions}` | array | Management capabilities |
| `{$managementoptions.nameservers}` | boolean | NS management available |
| `{$managementoptions.contacts}` | boolean | Contact editing available |
| `{$managementoptions.locking}` | boolean | Lock management available |
| `{$defaultns}` | array | Default nameservers |
| `{$nameservers}` | array | Current nameservers [1-5] |
| `{$renew}` | boolean | Renewal available |
| `{$registrarclientarea}` | string | Registrar-specific HTML |
| `{$addons}` | array | Domain addons |
| `{$addonstatus}` | array | Addon statuses |
| `{$addonspricing}` | array | Addon pricing info |
| `{$registrarcustombuttonresult}` | string | Registrar button result |
| `{$changeAutoRenewStatusSuccessful}` | boolean | Auto-renew toggle success |
| `{$releaseDomainSuccessful}` | boolean | Domain release success |
| `{$systemStatus}` | string | System status |
| `{$alerts}` | array | Domain alerts |

### `viewticket.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$tid}` | string | Ticket ID number |
| `{$c}` | string | Ticket access key |
| `{$subject}` | string | Ticket subject |
| `{$descreplies}` | array | Ticket messages/replies |
| `{$reply.admin}` | boolean | Is admin reply |
| `{$reply.requestor}` | object | Requestor info |
| `{$reply.requestor->getName()}` | string | Requestor name |
| `{$reply.requestor->getType()}` | string | Requestor type |
| `{$reply.requestor->getNormalisedType()}` | string | CSS-safe type |
| `{$reply.date}` | string | Reply date |
| `{$reply.message}` | string | Reply message (HTML) |
| `{$reply.attachments}` | array | Reply attachments |
| `{$reply.attachments_removed}` | boolean | Attachments were removed |
| `{$reply.rating}` | int | Reply rating |
| `{$reply.id}` | int | Reply ID |
| `{$reply.ipaddress}` | string | Reply IP address |
| `{$showCloseButton}` | boolean | Show close ticket button |
| `{$closedticket}` | boolean | Ticket is closed |
| `{$invalidTicketId}` | boolean | Invalid ticket ID |
| `{$replyname}` | string | Reply form name |
| `{$replyemail}` | string | Reply form email |
| `{$replymessage}` | string | Reply form message |
| `{$allowedfiletypes}` | string | Allowed file types |
| `{$uploadMaxFileSize}` | int | Max upload size |
| `{$ratingenabled}` | boolean | Rating system enabled |

### `clientregister.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$registrationDisabled}` | boolean | Registration is disabled |
| `{$remote_auth_prelinked}` | boolean | Pre-linked via OAuth |
| `{$clientfirstname}` | string | Pre-filled first name |
| `{$clientlastname}` | string | Pre-filled last name |
| `{$clientemail}` | string | Pre-filled email |
| `{$clientphonenumber}` | string | Pre-filled phone |
| `{$clientcompanyname}` | string | Pre-filled company |
| `{$clientaddress1}` | string | Pre-filled address |
| `{$clientcity}` | string | Pre-filled city |
| `{$clientstate}` | string | Pre-filled state |
| `{$clientpostcode}` | string | Pre-filled postcode |
| `{$clientcountry}` | string | Pre-filled country |
| `{$clientcountries}` | array | Available countries |
| `{$defaultCountry}` | string | Default country code |
| `{$password}` | string | Pre-filled password |
| `{$securityquestions}` | array | Security questions |
| `{$securityqid}` | int | Selected security question ID |
| `{$optionalFields}` | array | Optional field names |
| `{$accountDetailsExtraFields}` | array | Extra registration fields |
| `{$accepttos}` | boolean | TOS acceptance required |
| `{$tosurl}` | string | TOS URL |
| `{$pwStrengthErrorThreshold}` | int | Password strength error threshold |
| `{$pwStrengthWarningThreshold}` | int | Password strength warning threshold |
| `{$showTaxIdField}` | boolean | Show tax ID field |
| `{$taxLabel}` | string | Tax ID label |
| `{$clientTaxId}` | string | Pre-filled tax ID |

### `invoice-payment.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$invoiceid}` | int | Invoice ID |
| `{$showRemoteInput}` | boolean | Show remote payment input |
| `{$remoteInput}` | string | Remote payment HTML |
| `{$hasRemoteInput}` | boolean | Has remote input configured |
| `{$submitLocation}` | string | Form submit URL |
| `{$cardOrBank}` | string | Payment type ("card" or "bank") |
| `{$gateway}` | string | Payment gateway name |
| `{$servedOverSsl}` | boolean | Page served over SSL |
| `{$errormessage}` | string | Error message |

### `affiliates.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$inactive}` | boolean | Affiliate is inactive |
| `{$visitors}` | int | Total visitors |
| `{$signups}` | int | Total signups |
| `{$conversionrate}` | string | Conversion rate |
| `{$referrallink}` | string | Referral link URL |
| `{$pendingcommissions}` | string | Pending commissions |
| `{$balance}` | string | Available balance |
| `{$withdrawn}` | string | Total withdrawn |
| `{$withdrawlevel}` | string | Minimum withdrawal |
| `{$affiliatePayoutMinimum}` | string | Payout minimum |
| `{$referrals}` | array | Referral list |
| `{$affiliatelinkscode}` | string | HTML link code |
| `{$withdrawrequestsent}` | boolean | Withdrawal requested |

### `serverstatus.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$opencount}` | int | Open issue count |
| `{$scheduledcount}` | int | Scheduled issue count |
| `{$servers}` | array | Server list |
| `{$server.name}` | string | Server name |
| `{$server.phpinfourl}` | string | PHP info URL |
| `{$issues}` | array | Network issues |
| `{$issue.title}` | string | Issue title |
| `{$issue.status}` | string | Issue status |
| `{$issue.rawPriority}` | string | Priority (Critical/Major/Minor) |
| `{$issue.priority}` | string | Priority display text |
| `{$issue.server}` | string | Affected server |
| `{$issue.affecting}` | string | Affected services |
| `{$issue.type}` | string | Issue type |
| `{$issue.startdate}` | string | Start date |
| `{$issue.enddate}` | string | End date |
| `{$issue.lastupdate}` | string | Last update |
| `{$issue.clientaffected}` | boolean | Current client affected |
| `{$issue.description}` | string | Issue description |
| `{$noissuesmsg}` | string | No issues message |

### `upgrade.tpl` / `upgrade-configure.tpl` / `upgradesummary.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$overdueinvoice}` | boolean | Has overdue invoice |
| `{$existingupgradeinvoice}` | boolean | Has existing upgrade invoice |
| `{$upgradenotavailable}` | boolean | Upgrade not available |
| `{$upgradeinvalid}` | boolean | Invalid upgrade |
| `{$upgradeinvaliderror}` | string | Invalid upgrade error |
| `{$id}` | int | Service/product ID |
| `{$type}` | string | "package" or "configoptions" |
| `{$groupname}` | string | Product group |
| `{$productname}` | string | Current product |
| `{$domain}` | string | Service domain |
| `{$upgradepackages}` | array | Available upgrade packages |
| `{$configoptions}` | array | Configurable options |
| `{$serviceToBeUpgraded}` | object | Service being upgraded |
| `{$upgradeProducts}` | array | Available upgrade products |
| `{$recommendedProductKey}` | string | Recommended product key |
| `{$permittedBillingCycles}` | object | Permitted billing cycles |
| `{$upgrades}` | array | Upgrade summary items |
| `{$subtotal}` | string | Subtotal |
| `{$discount}` | string | Discount |
| `{$tax}` / `{$tax2}` | string | Tax amounts |
| `{$total}` | string | Total |
| `{$promocode}` | string | Promo code |
| `{$promodesc}` | string | Promo description |
| `{$gateways}` | array | Payment gateways |
| `{$selectedgateway}` | string | Selected gateway |
| `{$allowgatewayselection}` | boolean | Gateway selection allowed |

### `domain-pricing.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$featuredTlds}` | array | Featured TLD list |
| `{$tldCategories}` | array | TLD category filters |
| `{$pricing}` | array | TLD pricing data |
| `{$extension}` | string | TLD extension name |
| `{$data.group}` | string | TLD group |
| `{$data.categories}` | array | TLD categories |
| `{$data.register}` | object/null | Registration pricing |
| `{$data.transfer}` | object/null | Transfer pricing |
| `{$data.renew}` | object/null | Renewal pricing |
| `{$data.grace_period}` | string | Grace period info |
| `{$data.redemption_period}` | string | Redemption period info |

### `configuressl-stepone.tpl` / `configuressl-steptwo.tpl` / `configuressl-complete.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$cert}` | string | Certificate ID |
| `{$status}` | string | Certificate status |
| `{$webservertypes}` | array | Web server type options |
| `{$servertype}` | string | Selected server type |
| `{$csr}` | string | CSR content |
| `{$additionalfields}` | array | Additional field groups |
| `{$serviceid}` | int | Service ID |
| `{$approvalMethods}` | array | Validation methods (email, dns, file) |
| `{$approveremails}` | array | Approval email addresses |
| `{$authData}` | object/null | Authentication data |
| `{$authData->methodNameConstant()}` | string | Auth method (emailauth/dnsauth/fileauth) |
| `{$authData->email}` | string | Approval email |
| `{$authData->host}` | string | DNS host |
| `{$authData->value}` | string | DNS value |
| `{$authData->filePath()}` | string | File validation path |
| `{$authData->contents}` | string | File validation contents |

### User & Account Management Pages

| Variable | Page | Description |
|----------|------|-------------|
| `{$user->firstName}` | user-profile.tpl | User first name |
| `{$user->lastName}` | user-profile.tpl | User last name |
| `{$user->email}` | user-profile.tpl | User email |
| `{$user->emailVerified()}` | user-profile.tpl | Email verified status |
| `{$user->hasSecurityQuestion()}` | user-security.tpl | Has security question |
| `{$user->hasTwoFactorAuthEnabled()}` | user-security.tpl | 2FA enabled |
| `{$twoFactorAuthAvailable}` | user-security.tpl | 2FA available |
| `{$twoFactorAuthEnabled}` | user-security.tpl | 2FA currently enabled |
| `{$twoFactorAuthRequired}` | user-security.tpl | 2FA required |
| `{$isSsoEnabled}` | clientareasecurity.tpl | SSO enabled |
| `{$showSsoSetting}` | clientareasecurity.tpl | Show SSO toggle |
| `{$invite}` | user-invite-accept.tpl | Invite object |
| `{$invite->getClientName()}` | user-invite-accept.tpl | Inviting client name |
| `{$invite->getSenderName()}` | user-invite-accept.tpl | Invite sender name |
| `{$invite->token}` | user-invite-accept.tpl | Invite token |
| `{$accounts}` | user-switch-account.tpl | Account list |
| `{$account->displayName}` | user-switch-account.tpl | Account display name |
| `{$account->status}` | user-switch-account.tpl | Account status |
| `{$account->authedUserIsOwner()}` | user-switch-account.tpl | User is owner |
| `{$challenge}` | two-factor-challenge.tpl | 2FA challenge HTML |
| `{$usingBackup}` | two-factor-challenge.tpl | Using backup code |
| `{$newbackupcode}` | two-factor-challenge.tpl | New backup code |
| `{$newBackupCode}` | two-factor-new-backup-code.tpl | Generated backup code |
| `{$innerTemplate}` | password-reset-container.tpl | Sub-template name |
| `{$securityQuestion}` | password-reset-security-prompt.tpl | Security question text |
| `{$users}` | account-user-management.tpl | User list |
| `{$invites}` | account-user-management.tpl | Pending invites |
| `{$permissions}` | account-user-permissions.tpl | Permission definitions |
| `{$userPermissions}` | account-user-permissions.tpl | User's current permissions |

### Payment Method Management

| Variable | Type | Description |
|----------|------|-------------|
| `{$client->payMethods}` | collection | Client payment methods |
| `{$payMethod->id}` | int | Payment method ID |
| `{$payMethod->payment->getDisplayName()}` | string | Display name (Visa ending 1234) |
| `{$payMethod->description}` | string | User description |
| `{$payMethod->getStatus()}` | string | Method status |
| `{$payMethod->isDefaultPayMethod()}` | boolean | Is default |
| `{$payMethod->isExpired()}` | boolean | Is expired |
| `{$payMethod->getType()}` | string | Type (CreditCard/BankAccount) |
| `{$payMethod->getFontAwesomeIcon()}` | string | Card brand icon class |
| `{$existingCards}` | array | Existing saved cards |
| `{$existingAccounts}` | array | Existing bank accounts |
| `{$cardOnFile}` | boolean | Has card on file |
| `{$payMethodId}` | int | Selected payment method ID |
| `{$payMethodExpired}` | boolean | Selected method expired |
| `{$addingNewCard}` | boolean | Adding new card |
| `{$addingNew}` | boolean | Adding new method |
| `{$editMode}` | boolean | Edit mode |
| `{$supportedCardTypes}` | string | Supported card types JSON |
| `{$allowCreditCard}` | boolean | Credit cards allowed |
| `{$allowBankDetails}` | boolean | Bank accounts allowed |
| `{$allowClientsToRemoveCards}` | boolean | Card deletion allowed |
| `{$allowDelete}` | boolean | Method deletion allowed |

### SSL Management (`managessl.tpl`)

| Variable | Type | Description |
|----------|------|-------------|
| `{$sslProducts}` | array | SSL product list |
| `{$sslProduct->addonId}` | int | Addon ID |
| `{$sslProduct->status}` | string | SSL status |
| `{$sslProduct->addon->service->domain}` | string | Associated domain |
| `{$sslProduct->validationType}` | string | DV/OV/EV |
| `{$sslProduct->wasInstantIssuanceAttempted()}` | boolean | Instant issuance attempted |
| `{$sslProduct->wasInstantIssuanceSuccessful()}` | boolean | Instant issuance succeeded |
| `{$sslProduct->getConfigurationUrl()}` | string | Configuration URL |
| `{$sslProduct->getUpgradeUrl()}` | string | Upgrade URL |

### Other Page Variables

| Variable | Page | Description |
|----------|------|-------------|
| `{$ip}` | banned.tpl | Banned IP |
| `{$reason}` | banned.tpl | Ban reason |
| `{$expires}` | banned.tpl | Ban expiry |
| `{$allowedpermissions}` | access-denied.tpl | Required permissions list |
| `{$code}` | forwardpage.tpl | Payment redirect HTML |
| `{$departments}` | supportticketsubmit-stepone.tpl | Department list |
| `{$relatedservices}` | supportticketsubmit-steptwo.tpl | Related services list |
| `{$urgency}` | supportticketsubmit-steptwo.tpl | Selected urgency |
| `{$kbsuggestions}` | supportticketsubmit-steptwo.tpl | KB suggestions enabled |
| `{$kbarticles}` | supportticketsubmit-kbsuggestions.tpl | Suggested KB articles |
| `{$sent}` | contact.tpl | Contact form sent |
| `{$kbcats}` | knowledgebase.tpl | KB category list |
| `{$kbmostviews}` | knowledgebase.tpl | Most viewed articles |
| `{$kbarticle.voted}` | knowledgebasearticle.tpl | User has voted |
| `{$kbarticle.tags}` | knowledgebasearticle.tpl | Article tags |
| `{$kbarticle.useful}` | knowledgebasearticle.tpl | Useful vote count |
| `{$dlcats}` | downloads.tpl | Download categories |
| `{$mostdownloads}` | downloads.tpl | Most popular downloads |
| `{$twittertweet}` | viewannouncement.tpl | Twitter sharing enabled |
| `{$facebookrecommend}` | viewannouncement.tpl | Facebook recommend enabled |
| `{$facebookcomments}` | viewannouncement.tpl | Facebook comments enabled |
| `{$addfundsdisabled}` | clientareaaddfunds.tpl | Add funds disabled |
| `{$minimumamount}` | clientareaaddfunds.tpl | Minimum deposit |
| `{$maximumamount}` | clientareaaddfunds.tpl | Maximum deposit |
| `{$maximumbalance}` | clientareaaddfunds.tpl | Maximum balance |

---

## 23. JavaScript Deep Reference (Supplement to Section 12)

### `whmcs.js` - Core Theme Functions

The `whmcs.js` file provides these key functions and initializations:

#### Navigation Auto-Collapse
```javascript
// Automatically collapses nav items that don't fit into a "More" dropdown
autoCollapse('#nav', 30);
```

#### Popover Initialization
```javascript
// Account notifications popover
jQuery('#accountNotifications').popover({
    placement: 'bottom',
    html: true,
    content: function() {
        return jQuery('#accountNotificationsContent').html();
    }
});

// Generic popovers
jQuery('[data-toggle="popover"]').popover({ html: true });
```

#### Card Minimization
```javascript
// Sidebar card collapse/expand
jQuery('.card-minimise').click(function() {
    jQuery(this).closest('.card-sidebar').find('.collapsable-card-body').slideToggle();
    jQuery(this).toggleClass('fa-chevron-up fa-chevron-down');
});
```

#### Password Reveal Toggle
```javascript
jQuery('.btn-reveal-pw').click(function() {
    var input = jQuery(this).closest('.input-group').find('.pw-input');
    input.attr('type', input.attr('type') === 'password' ? 'text' : 'password');
});
```

#### Bootstrap Switch
```javascript
// Toggle switch initialization
jQuery('.toggle-switch-success').bootstrapSwitch({
    onSwitchChange: function(event, state) { /* handler */ }
});
```

#### Internal Tab Selection via URL Hash
```javascript
// Select tab based on URL hash
if (!disableInternalTabSelection && window.location.hash) {
    jQuery('[href="' + window.location.hash + '"]').click();
}
```

#### Bulk Domain Actions
```javascript
jQuery('.setBulkAction').click(function() {
    var action = jQuery(this).attr('id');
    jQuery('#bulkaction').val(action);
    jQuery('#domainForm').submit();
});
```

### WHMCS JavaScript API

```javascript
// HTTP Client
WHMCS.http.jqClient.post(url, data, callback, 'json');
WHMCS.http.jqClient.get(url, callback, 'json');

// Payment Events
WHMCS.payment.event.gatewayInit();

// Route URL Generation
WHMCS.utils.getRouteUrl('/path/to/resource');

// Auto-Submit Form
autoSubmitFormByContainer('frmPayment');

// Clickable Row Navigation
clickableSafeRedirect(event, url, openInNewTab);

// Select Navigation
selectChangeNavigate(selectElement);

// Popup Window
popupWindow(url, title, width, height);

// Smooth Scroll
smoothScroll(target);
```

### jQuery Plugins Used

| Plugin | Purpose | Usage |
|--------|---------|-------|
| **jQuery Payment** | Card validation & formatting | `jQuery.payment.cardType()`, `.payment('formatCardNumber')` |
| **DataTables** | Sortable/filterable tables | `jQuery('#table').DataTable({...})` |
| **Bootstrap Switch** | Toggle switch UI | `.bootstrapSwitch({...})` |
| **iCheck** | Styled checkboxes/radios | `.icheck-button` class |
| **jQuery Knob** | Circular dials (disk/BW usage) | `.knob({...})` |
| **Lightbox** | Image lightbox | `lightbox.init()` |
| **Clipboard.js** | Copy to clipboard | `.copy-to-clipboard` class |

### Data Attributes Used in JavaScript

| Attribute | Purpose |
|-----------|---------|
| `data-toggle="popover"` | Bootstrap popover |
| `data-toggle="tooltip"` | Bootstrap tooltip |
| `data-toggle="modal"` | Bootstrap modal |
| `data-toggle="tab"` | Bootstrap tab |
| `data-toggle="collapse"` | Bootstrap collapse |
| `data-toggle="dropdown"` | Bootstrap dropdown |
| `data-toggle="list"` | List tab toggle |
| `data-target` | Modal/collapse target |
| `data-dismiss="modal"` | Modal close |
| `data-placement` | Tooltip/popover placement |
| `data-auto-save-name` | Auto-save identifier for textareas |
| `data-clipboard-target` | Copy-to-clipboard source |
| `data-paymethod-id` | Payment method identifier |
| `data-billing-contact-id` | Billing contact |
| `data-loaded-paymethod` | Pre-loaded payment method |
| `data-supported-cards` | Supported card types JSON |
| `data-message-unsupported` | Unsupported card message |
| `data-message-invalid` | Invalid card message |
| `data-error-threshold` | Password strength error threshold |
| `data-warning-threshold` | Password strength warning threshold |
| `data-serviceid` | Service ID for custom actions |
| `data-identifier` | Action identifier |
| `data-active` | Action active state |
| `data-domain-action` | Domain action type |
| `data-category` | Category filter value |
| `data-order` | DataTables sort value |
| `data-original-value` | Original field value for change detection |
| `data-url` | AJAX endpoint URL |
| `data-id` | Element identifier |
| `data-email-sent` | Email sent message |
| `data-error-msg` | Error message |
| `data-uri` | Action URI |

---

## 24. Payment Flow Details (Supplement to Section 15)

### Card Payment Flow

The card payment process uses these templates in sequence:

```
1. card/select.tpl      → Select existing card or "New Card"
2. card/inputs.tpl      → Card number, expiry, CVV fields
3. billing-address.tpl  → Billing address selection
4. card/validate.tpl    → Client-side validation JavaScript
```

#### `card/select.tpl` - Card Selection

```smarty
{if count($existingCards) > 0}
    {foreach $existingCards as $cardInfo}
        <label>
            <input type="radio" name="paymentmethod_id" 
                   value="{$cardInfo.paymethodid}"
                   data-paymethod-id="{$cardInfo.paymethodid}"
                   data-billing-contact-id="{$cardInfo.billingcontactid}"
                   {if $payMethodId eq $cardInfo.paymethodid} checked{/if} />
            {$cardInfo.payMethod}
        </label>
    {/foreach}
    <label>
        <input type="radio" name="paymentmethod_id" value="new" id="newCCInfo" />
        {lang key='creditcardenteraliascard'}
    </label>
{/if}
```

#### `card/validate.tpl` - Validation Logic

Key JavaScript validation functions:

```javascript
// Card type detection
var cardType = jQuery.payment.cardType(cardNumber);

// Card number validation
var isValidNumber = jQuery.payment.validateCardNumber(cardNumber);

// Expiry validation
var isValidExpiry = jQuery.payment.validateCardExpiry(month, year);

// CVV validation
var isValidCVC = jQuery.payment.validateCardCVC(cvc, cardType);

// Input formatting
jQuery('#inputCardNumber').payment('formatCardNumber');
jQuery('#inputCardExpiry').payment('formatCardExpiry');
jQuery('#inputCardCvv').payment('formatCardCVC');
```

### Bank Payment Flow

```
1. bank/select.tpl      → Select existing bank account or "New Account"
2. bank/inputs.tpl      → Account type, holder name, bank, routing, account number
3. billing-address.tpl  → Billing address selection
4. bank/validate.tpl    → Client-side validation
```

#### `bank/inputs.tpl` Fields

| Field | Name | Type |
|-------|------|------|
| Account Type | `account_type` | Radio (Checking/Savings) |
| Account Holder | `account_holder_name` | Text |
| Bank Name | `bank_name` | Text |
| Routing Number | `routing_number` | Tel |
| Account Number | `account_number` | Tel |
| Description | `description` | Text |

### `invoice-summary.tpl` Variables

```smarty
{foreach $invoiceitems as $item}
    {$item.description} - {$item.amount}
{/foreach}

Subtotal: {$invoice.subtotal}
Tax ({$invoice.taxname} @ {$invoice.taxrate}%): {$invoice.tax}
Tax ({$invoice.taxname2} @ {$invoice.taxrate2}%): {$invoice.tax2}
Credit: {$invoice.credit}
Total: {$invoice.total}
Amount Paid: {$invoice.amountpaid}
Balance: {$balance}
```

---

## 25. PDF Templates (Non-Smarty)

### `invoicepdf.tpl` - Invoice PDF Generation

This file uses **PHP with HTML**, not Smarty templates. It generates PDFs via the TCPDF library.

**Key PHP variables:**
```php
$status              // Invoice status (Paid/Unpaid/etc.)
$companyaddress      // Company address text
$taxCode             // Company tax code
$taxIdLabel          // Tax ID label
$pagetitle           // Invoice title
$datecreated         // Creation date
$duedate             // Due date
$clientsdetails[]    // Client info array
$customfields[]      // Custom field values
$invoiceitems[]      // Line items
$subtotal            // Subtotal
$taxname / $taxrate  // Tax level 1
$tax / $tax2         // Tax amounts
$credit              // Applied credit
$total               // Total amount
$transactions[]      // Payment transactions
$balance             // Outstanding balance
$notes               // Invoice notes
$invoiceQrHtml       // QR code HTML
$pdfFont             // PDF font name
$_LANG[]             // Language strings array
```

### `quotepdf.tpl` - Quote PDF Generation

Similar PHP/HTML structure:

```php
$quotenumber         // Quote number
$subject             // Quote subject
$datecreated         // Creation date
$validuntil          // Validity date
$proposal            // Proposal text
$lineitems[]         // Quote line items
$subtotal            // Subtotal
$taxlevel1 / $tax1   // Tax level 1
$taxlevel2 / $tax2   // Tax level 2
$total               // Total amount
$notes               // Quote notes
```

**Important:** These templates use `$_LANG['key']` for language strings instead of `{lang key='key'}`.

### `viewbillingnote.tpl` - Standalone Invoice View

This is a **standalone full HTML page** (not wrapped by header/footer). It has its own asset loading:

```smarty
<link href="{assetPath file='all.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='invoice.min.css'}?v={$versionHash}" rel="stylesheet">
```

**Key variables:**
- `{$billingNote->lineItems}` - Line items collection
- `{$billingNote->taxes}` - Tax collection
- `{$billingNote->subTotal}` - Subtotal
- `{$billingNote->total}` - Total
- `{$billingNote->balance}` - Balance
- `{$transactions}` - Transaction history
- `{$issuedBy}` - Issuing entity name

### `viewemail.tpl` - Standalone Email View

Another standalone HTML page rendered in a popup:

```smarty
<iframe class="email-body" srcdoc="{$message}"></iframe>
```

Uses `window.close()` for the close button.

---

## 26. Error Template Details (Supplement to Section 17)

### `error/internal-error.tpl` - Non-Smarty Template

This template uses **double-curly-brace placeholders** instead of Smarty:

```html
<!-- NOT Smarty syntax - PHP string replacement -->
<a href="mailto:{{email}}">{{email}}</a>
<a href="{{systemurl}}">{{systemurl}}</a>
{{environmentIssues}}
{{adminHelp}}
{{stacktrace}}
```

**Important:** If creating custom error pages, the internal error template does NOT use the Smarty engine because it displays when the system itself has failed.

### `error/unknown-routepath.tpl`

This template includes the 404 page and adds referrer info:

```smarty
{include file="$template/error/page-not-found.tpl"}
{* Also uses: $referrer|escape *}
```

---

## 27. Cart Theme Deep Reference (Supplement to Section 18)

### Nexus Cart SPA Architecture

The cart templates use a **Single Page Application** approach with Vue.js:

```smarty
{* domainregister.tpl *}
<div id="order-standard_cart">
    <div data-app="domain-module" data-init="{getNexusData}"></div>
</div>
<script src="{assetPath file='main.min.js'}"></script>
```

```smarty
{* viewcart.tpl *}
<div id="order-standard_cart">
    {if $checkout}
        {include file="orderforms/{$carttpl}/checkout.tpl"}
    {else}
        <div data-app="cart-module" data-init="{getNexusData}"></div>
    {/if}
</div>
```

**Key patterns:**
- `{getNexusData}` - Custom Smarty function that outputs JSON configuration
- `data-app` - Identifies which Vue component to mount
- Parent template: `standard_cart` (inherited via theme.yaml)
- Includes from parent: `orderforms/standard_cart/common.tpl`

### Cart CSS Variables (Shadow DOM Prefix)

The cart uses `--vl-` prefixed CSS variables (different from main theme):

```css
:root {
    /* Primary color variations */
    --vl-primary: #value;
    --vl-primary-lifted: #value;
    --vl-primary-accented: #value;

    /* Secondary */
    --vl-secondary: #value;
    --vl-secondary-lifted: #value;
    --vl-secondary-accented: #value;

    /* Status colors - each with lifted/accented variants */
    --vl-success: #value;
    --vl-info: #value;
    --vl-notice: #value;
    --vl-warning: #value;
    --vl-error: #value;

    /* Grayscale/Neutral */
    --vl-grayscale: #value;
    --vl-neutral: #value;

    /* Text hierarchy */
    --vl-text-inverted: #value;
    --vl-text-muted: #value;
    --vl-text-lifted: #value;
    --vl-text-accented: #value;
    --vl-text: #value;

    /* Border hierarchy */
    --vl-border-muted: #value;
    --vl-border: #value;
    --vl-border-lifted: #value;
    --vl-border-accented: #value;

    /* Background hierarchy */
    --vl-bg: #value;
    --vl-bg-muted: #value;
    --vl-bg-lifted: #value;
    --vl-bg-accented: #value;
    --vl-bg-inverted: #value;

    /* Typography */
    --vl-text-xs: #value;
    --vl-text-sm: #value;
    --vl-text-md: #value;
    --vl-text-lg: #value;

    /* Spacing */
    --vl-outline-sm: #value;
    --vl-outline-md: #value;
    --vl-outline-lg: #value;

    /* Rounding */
    --vl-rounding-sm: #value;
    --vl-rounding-md: #value;
    --vl-rounding-lg: #value;

    /* Other */
    --vl-letter-spacing: #value;
    --vl-disabled-opacity: #value;
}
```

**Important:** The cart CSS variables use `--vl-` prefix while the main theme uses plain names (e.g., `--primary-color`, `--success`). These are different variable systems.

### Cart Template Inline Overrides

The `viewcart.tpl` includes inline CSS to override main theme layout:

```html
<style>
    /* Hide main navigation on cart pages */
    .navbar { display: none; }
    /* Override main body background */
    section#main-body { background: white; }
</style>
```

---

## 28. Dynamic Store Block Variables (Supplement to Section 14)

### `partial/header.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->logo}` | Logo image URL |
| `{$config->title}` | Hero title text |
| `{$config->subtitle}` | Hero subtitle |
| `{$config->shortDescription}` | Description text |
| `{$elementIndex}` | Block iteration index (for alternating backgrounds) |

### `partial/grid_of_cards.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Service/product list |
| `{$service['slug']}` | Product slug identifier |
| `{$service['features']}` | Feature list array |
| `{$products[$slug]}` | Product object from products map |
| `{$plan->isFree()}` | Is free plan |
| `{$plan->pricing()->first()->toPrefixedString()}` | Formatted price |
| `{$hasPlan}` | Whether plan data exists |

### `partial/price_comparison.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Services to compare |
| `{$config->title}` | Table title |
| Feature values can be: `boolean` (check/cross), `string`, `numeric` |

### `partial/faq.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->items}` | FAQ items (question/answer pairs) |
| `{$faq->question}` | FAQ question text |
| `{$faq->answer}` | FAQ answer text |
| `{$smarty.foreach.faqs.index}` | FAQ index for IDs |

### `partial/video.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->url}` | Video embed URL |
| `{$config->title}` | Video section title |

### `partial/free_form.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->content}` | Free-form HTML content |

### `partial/product_preview.tpl`

| Variable | Description |
|----------|-------------|
| `{$config->services}` | Products to preview |
| `{$plan.name}` | Product name |
| `{$plan.description}` | Product description |
| `{$plan->pricing()}` | Pricing object |

---

## 29. OAuth Template Variables (Supplement to Section 16)

### `oauth/login.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$appLogo}` | string | Application logo URL |
| `{$appName}` | string | Application name |
| `{$issuerurl}` | string | OAuth issuer URL |
| `{$incorrect}` | boolean | Login credentials incorrect |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/login-twofactorauth.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$challenge}` | string | 2FA challenge HTML |
| `{$backupcode}` | boolean | Using backup code |
| `{$incorrect}` | boolean | Code was incorrect |
| `{$error}` | string | Error message |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/authorize.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$appLogo}` | string | Application logo URL |
| `{$appName}` | string | Application name |
| `{$requestedPermissions}` | array | Permissions list |
| `{$requestedAuthorizations}` | array | Authorization scopes |
| `{$request_hash}` | string | OAuth request hash |

### `oauth/error.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$error}` | string | Error message text |

---

## 30. Complete Form Actions Reference

Every form in the theme and its action URL:

### Authentication Forms
| Template | Form Action |
|----------|-------------|
| `login.tpl` | `{routePath('login-validate')}` |
| `clientregister.tpl` | `{$smarty.server.PHP_SELF}` |
| `password-reset-email-prompt.tpl` | `{routePath('password-reset-validate-email')}` |
| `password-reset-security-prompt.tpl` | `{routePath('password-reset-security-verify')}` |
| `password-reset-change-prompt.tpl` | `{routePath('password-reset-change-perform')}` |
| `two-factor-challenge.tpl` | `{routePath('login-two-factor-challenge-verify')}` |
| `user-invite-accept.tpl` | `{routePath('invite-validate', $token)}` |

### Account Forms
| Template | Form Action |
|----------|-------------|
| `clientareadetails.tpl` | `?action=details` |
| `user-profile.tpl` | `{routePath('user-profile-save')}` |
| `user-password.tpl` | `{routePath('user-password')}` |
| `user-security.tpl` | `{routePath('user-security-question')}` |
| `account-contacts-manage.tpl` | `{routePath('account-contacts-save')}` |
| `account-contacts-new.tpl` | `{routePath('account-contacts-new')}` |
| `account-user-management.tpl` | `{routePath('account-users-invite')}` |
| `account-user-permissions.tpl` | `{routePath('account-users-permissions-save', $user->id)}` |

### Product/Service Forms
| Template | Form Action |
|----------|-------------|
| `clientareaproductdetails.tpl` | `{$smarty.server.PHP_SELF}?action=productdetails` |
| `clientareacancelrequest.tpl` | `clientarea.php?action=cancel&id={$id}` |
| `upgrade.tpl` | `{$smarty.server.PHP_SELF}` |
| `upgrade-configure.tpl` | `{routePath('upgrade-add-to-cart')}` |
| `upgradesummary.tpl` | `{$smarty.server.PHP_SELF}` |
| `subscription-manage.tpl` | Current page |

### Domain Forms
| Template | Form Action |
|----------|-------------|
| `clientareadomains.tpl` | `clientarea.php?action=bulkdomain` |
| `clientareadomaindetails.tpl` | `clientarea.php?action=domaindetails` |
| `clientareadomainaddons.tpl` | `clientarea.php?action=domainaddons` |
| `clientareadomaincontactinfo.tpl` | `clientarea.php?action=domaincontacts` |
| `clientareadomaindns.tpl` | `clientarea.php?action=domaindns` |
| `clientareadomainemailforwarding.tpl` | `clientarea.php?action=domainemailforwarding` |
| `clientareadomainregisterns.tpl` | `clientarea.php?action=domainregisterns` |
| `bulkdomainmanagement.tpl` | `{$smarty.server.PHP_SELF}?action=bulkdomain` |

### Support Forms
| Template | Form Action |
|----------|-------------|
| `supportticketsubmit-steptwo.tpl` | `{$smarty.server.PHP_SELF}?step=3` |
| `viewticket.tpl` | `clientarea.php?tid={$tid}&c={$c}&postreply=true` |
| `ticketfeedback.tpl` | `{$smarty.server.PHP_SELF}?tid={$tid}&c={$c}&feedback=1` |
| `contact.tpl` | `contact.php` |

### Financial Forms
| Template | Form Action |
|----------|-------------|
| `invoice-payment.tpl` | `{$submitLocation}` |
| `clientareaaddfunds.tpl` | `clientarea.php?action=addfunds` |
| `masspay.tpl` | `clientarea.php?action=masspay` |

### Store Forms
| Template | Form Action |
|----------|-------------|
| `store/order.tpl` | `{routePath('cart-order-addtocart')}` |
| `configuressl-stepone.tpl` | `{$smarty.server.PHP_SELF}?cert={$cert}&step=2` |
| `configuressl-steptwo.tpl` | `{$smarty.server.PHP_SELF}?cert={$cert}&step=3` |

### Search Forms
| Template | Form Action |
|----------|-------------|
| `header.tpl` | `{routePath('knowledgebase-search')}` |
| `knowledgebase.tpl` | `{routePath('knowledgebase-search')}` |
| `downloads.tpl` | `{routePath('download-search')}` |

### Other Forms
| Template | Form Action |
|----------|-------------|
| `affiliates.tpl` | `{$smarty.server.PHP_SELF}` |
| `affiliatessignup.tpl` | `affiliates.php` |
| `domain-search.tpl` | `domainchecker.php` |
| `footer.tpl` (lang/currency) | `{$currentpagelinkback}` |

---

## 31. CSS Component Classes Reference

### Status Badge Classes

Used throughout for service, domain, invoice, and ticket status:

```css
.status                    /* Base status badge */
.status-active             /* Active service/domain */
.status-open               /* Open ticket */
.status-completed          /* Completed */
.status-pending            /* Pending */
.status-pending-transfer   /* Domain pending transfer */
.status-suspended          /* Suspended */
.status-customer-reply     /* Ticket awaiting customer */
.status-fraud              /* Fraud flagged */
.status-answered           /* Ticket answered */
.status-expired            /* Expired */
.status-transferred-away   /* Domain transferred */
.status-pending-registration /* Domain pending reg */
.status-redemption         /* Domain in redemption */
.status-grace              /* Domain in grace */
.status-terminated         /* Terminated */
.status-onhold             /* On hold */
.status-inprogress         /* In progress */
.status-closed             /* Closed */
.status-paid               /* Paid invoice */
.status-unpaid             /* Unpaid invoice */
.status-cancelled          /* Cancelled */
.status-collections        /* In collections */
.status-refunded           /* Refunded */
.status-payment-pending    /* Payment pending */
.status-delivered          /* Delivered */
.status-accepted           /* Accepted quote */
.status-lost / .status-dead /* Lost/dead quote */
.status-custom             /* Custom status with inline color */
```

### Requestor Type Badges (Tickets)

```css
.requestor-type-operator
.requestor-type-owner
.requestor-type-authorizeduser
.requestor-type-registereduser
.requestor-type-subaccount
.requestor-type-guest
```

### Responsive Tabs Pattern

Used in product details, domain details, and bulk management:

```html
<ul class="nav nav-tabs responsive-tabs-sm">
    <li class="nav-item"><a class="nav-link active" data-toggle="tab">Tab 1</a></li>
    <li class="nav-item"><a class="nav-link" data-toggle="tab">Tab 2</a></li>
</ul>
<div class="responsive-tabs-sm-connector">
    <div class="channel"></div>
    <div class="bottom-border"></div>
</div>
<div class="tab-content">
    <div class="tab-pane fade show active">Content 1</div>
    <div class="tab-pane fade">Content 2</div>
</div>
```

### Utility Classes

```css
.w-hidden           /* display: none (WHMCS utility) */
.w-text-09           /* font-size: 0.9em */
.width-fixed-20      /* width: 20px */
.width-fixed-60      /* width: 60px */
.extra-padding        /* Extra card body padding */
.mw-540              /* max-width: 540px (login card) */
.show-on-hover       /* Visible only on parent hover */
.show-on-card-hover  /* Visible only on card hover */
.disable-on-click    /* Disabled after click */
.no-icheck           /* Prevent iCheck styling */
.input-inline        /* Inline input display */
.input-inline-100    /* 100px wide inline input */
.using-password-strength  /* Wraps password with strength meter */
```

### Active Products/Services Card

```css
.div-service-item           /* Service list item container */
.div-service-status         /* Status badge area */
.div-service-name           /* Name/domain area */
.div-service-buttons        /* Action buttons area */
.btn-custom-action          /* Custom module action button */
.btn-view-details           /* View details button */
```

### Client Dashboard Tiles

```css
.tiles                      /* Tile container */
.tile                       /* Individual stat tile */
.tile .stat                 /* Stat number */
.tile .title                /* Stat label */
.tile .highlight            /* Bottom colored border */
.client-home-cards          /* Card panel container */
```

### Domain Search (Homepage)

```css
.home-domain-search         /* Search section container */
.input-group-wrapper        /* Input wrapper */
.tld-logos                  /* Featured TLD logos */
.tld-logos li               /* Individual TLD */
```
