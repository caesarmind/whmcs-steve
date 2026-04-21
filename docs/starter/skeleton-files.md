# Skeleton Files Reference

Complete directory structure for a WHMCS theme. Use this as a blueprint when building from scratch or understanding what a theme needs.

## Full Theme Directory Structure

```
templates/mytheme/
├── theme.yaml                              # Theme config (REQUIRED)
├── index.php                               # Security redirect
│
├── css/
│   ├── all.css                             # Compiled base CSS (Bootstrap + base)
│   ├── all.min.css                         # Minified base
│   ├── theme.css                           # Theme-specific CSS (from SCSS)
│   ├── theme.min.css                       # Minified theme CSS
│   ├── custom.css                          # User overrides (loaded last)
│   ├── invoice.css                         # Invoice styling
│   ├── invoice.min.css                     # Minified invoice CSS
│   ├── oauth.css                           # OAuth page styling
│   └── store.css                           # Store/marketplace CSS
│
├── js/
│   ├── scripts.js                          # Main theme JavaScript
│   ├── scripts.min.js                      # Minified main scripts
│   └── whmcs.js                            # WHMCS utility functions
│
├── sass/                                   # SCSS source files (build-time)
│   ├── theme.scss                          # Main compilation entry
│   ├── invoice.scss                        # Invoice entry
│   ├── _global.scss
│   ├── _layout.scss
│   ├── _colors.scss
│   ├── _forms.scss
│   ├── _buttons.scss
│   ├── _tables.scss
│   ├── _tabs.scss
│   ├── _sidebar.scss
│   ├── _pagination.scss
│   ├── _home.scss
│   ├── _client-home.scss
│   ├── _products.scss
│   ├── _product-details.scss
│   ├── _payments.scss
│   ├── _billing-address.scss
│   ├── _cart.scss
│   ├── _registration.scss
│   ├── _support.scss
│   ├── _affiliate.scss
│   ├── _upgrades.scss
│   ├── _view-invoice.scss
│   ├── _two-factor.scss
│   ├── _email-verification.scss
│   ├── _popover.scss
│   ├── _socials.scss
│   ├── _marketconnect.scss
│   ├── _markdown.scss
│   ├── _tlds.scss
│   └── _captcha.scss
│
├── images/                                 # Shared images
│   ├── close.png
│   ├── loading.gif
│   ├── next.png
│   └── prev.png
│
├── img/                                    # Theme-specific images
│   ├── flags.png                           # Country flag sprite
│   ├── flags@2x.png                        # Retina flags
│   ├── globe.png
│   ├── loader.gif
│   ├── shadow-left.png
│   └── worldmap.png
│
├── header.tpl                              # Page header (REQUIRED)
├── footer.tpl                              # Page footer (REQUIRED)
│
├── includes/                               # Reusable partials
│   ├── head.tpl                            # <head> assets (REQUIRED)
│   ├── navbar.tpl                          # Navigation (REQUIRED)
│   ├── sidebar.tpl                         # Sidebar (REQUIRED)
│   ├── breadcrumb.tpl                      # Breadcrumb (REQUIRED)
│   ├── alert.tpl                           # Alert component (REQUIRED)
│   ├── flashmessage.tpl                    # Flash messages (REQUIRED)
│   ├── modal.tpl                           # Modal component (REQUIRED)
│   ├── panel.tpl                           # Panel component
│   ├── tablelist.tpl                       # DataTables wrapper
│   ├── captcha.tpl                         # CAPTCHA (REQUIRED)
│   ├── domain-search.tpl                   # Domain search widget
│   ├── validateuser.tpl                    # User validation banner
│   ├── verifyemail.tpl                     # Email verification banner
│   ├── linkedaccounts.tpl                  # OAuth linked accounts
│   ├── social-accounts.tpl                 # Social media links
│   ├── generate-password.tpl               # Password generator modal
│   ├── pwstrength.tpl                      # Password strength meter
│   ├── confirmation.tpl                    # Confirmation modal
│   ├── network-issues-notifications.tpl    # Network status alerts
│   ├── active-products-services-item.tpl   # Service list item
│   └── sitejet/
│       └── homepagepanel.tpl               # Sitejet panel
│
├── error/                                  # Error pages
│   ├── page-not-found.tpl                  # 404 (REQUIRED)
│   ├── internal-error.tpl                  # 500 (REQUIRED)
│   ├── rate-limit-exceeded.tpl             # 429
│   └── unknown-routepath.tpl               # Unknown route
│
├── oauth/                                  # OAuth flow
│   ├── layout.tpl                          # OAuth layout
│   ├── login.tpl                           # OAuth login
│   ├── login-twofactorauth.tpl             # OAuth 2FA
│   ├── authorize.tpl                       # Authorization
│   └── error.tpl                           # OAuth error
│
├── payment/                                # Payment templates
│   ├── billing-address.tpl                 # Billing address form
│   ├── invoice-summary.tpl                 # Invoice summary
│   ├── card/
│   │   ├── select.tpl                      # Card selection
│   │   ├── inputs.tpl                      # Card input fields
│   │   └── validate.tpl                    # Card validation
│   └── bank/
│       ├── select.tpl                      # Bank selection
│       ├── inputs.tpl                      # Bank input fields
│       └── validate.tpl                    # Bank validation
│
├── store/                                  # Store/marketplace
│   ├── order.tpl                           # Product order page
│   ├── not-found.tpl                       # Store 404
│   ├── addon/                              # Add-on products
│   │   ├── wp-toolkit-cpanel.tpl
│   │   └── wp-toolkit-plesk.tpl
│   ├── config-fields/                      # Product config fields
│   │   ├── boolean.tpl
│   │   ├── input.tpl
│   │   ├── select.tpl
│   │   └── textarea.tpl
│   ├── dynamic/                            # Dynamic store
│   │   ├── index.tpl
│   │   ├── assets/
│   │   │   ├── dynamic-store.css
│   │   │   └── dynamic-store.js
│   │   └── partial/
│   │       ├── header.tpl
│   │       ├── grid_of_cards.tpl
│   │       ├── price_comparison.tpl
│   │       ├── product_preview.tpl
│   │       ├── faq.tpl
│   │       ├── free_form.tpl
│   │       └── video.tpl
│   ├── ssl/                                # SSL certificate store
│   │   ├── index.tpl
│   │   ├── dv.tpl, ov.tpl, ev.tpl, wildcard.tpl
│   │   ├── competitive-upgrade.tpl
│   │   └── shared/
│   │       ├── certificate-item.tpl
│   │       ├── certificate-pricing.tpl
│   │       ├── currency-chooser.tpl
│   │       ├── features.tpl
│   │       ├── logos.tpl
│   │       └── nav.tpl
│   └── [provider]/                         # Per-provider templates
│       └── index.tpl
│
└── [page templates]                        # Root-level page templates
    ├── homepage.tpl                        # Public homepage (REQUIRED)
    ├── login.tpl                           # Login (REQUIRED)
    ├── clientregister.tpl                  # Registration (REQUIRED)
    ├── 3dsecure.tpl                        # 3DS verification
    ├── access-denied.tpl
    ├── banned.tpl
    ├── forwardpage.tpl                     # Payment redirect
    ├── markdown-guide.tpl
    │
    # Client area
    ├── clientareahome.tpl                  # Dashboard (REQUIRED)
    ├── clientareadetails.tpl               # Profile (REQUIRED)
    ├── clientareasecurity.tpl              # Security settings
    ├── clientareaemails.tpl                # Email history
    │
    # Products/Services
    ├── clientareaproducts.tpl              # Service list (REQUIRED)
    ├── clientareaproductdetails.tpl        # Service details (REQUIRED)
    ├── clientareaproductusagebilling.tpl   # Usage billing
    ├── upgrade.tpl                         # Upgrade list
    ├── upgrade-configure.tpl               # Upgrade config
    ├── upgradesummary.tpl                  # Upgrade summary
    ├── subscription-manage.tpl             # Subscription management
    │
    # Domains
    ├── clientareadomains.tpl               # Domain list (REQUIRED)
    ├── clientareadomaindetails.tpl         # Domain details (REQUIRED)
    ├── clientareadomainaddons.tpl
    ├── clientareadomaincontactinfo.tpl
    ├── clientareadomaindns.tpl
    ├── clientareadomainemailforwarding.tpl
    ├── clientareadomaingetepp.tpl
    ├── clientareadomainregisterns.tpl
    ├── bulkdomainmanagement.tpl
    ├── domain-pricing.tpl
    ├── managessl.tpl
    │
    # Financial
    ├── clientareainvoices.tpl              # Invoices (REQUIRED)
    ├── invoice-payment.tpl                 # Payment (REQUIRED)
    ├── invoicepdf.tpl                      # Invoice PDF
    ├── quotepdf.tpl                        # Quote PDF
    ├── clientareaquotes.tpl
    ├── clientareaaddfunds.tpl
    ├── masspay.tpl
    │
    # Support
    ├── supportticketslist.tpl              # Ticket list (REQUIRED)
    ├── supportticketsubmit-stepone.tpl
    ├── supportticketsubmit-steptwo.tpl
    ├── supportticketsubmit-customfields.tpl
    ├── supportticketsubmit-kbsuggestions.tpl
    ├── supportticketsubmit-confirm.tpl
    ├── ticketfeedback.tpl
    ├── viewticket.tpl                      # Ticket view (REQUIRED)
    │
    # User/Account
    ├── user-profile.tpl
    ├── user-password.tpl
    ├── user-security.tpl
    ├── user-verify-email.tpl
    ├── user-invite-accept.tpl
    ├── user-switch-account.tpl
    ├── user-switch-account-forced.tpl
    ├── two-factor-challenge.tpl
    ├── two-factor-new-backup-code.tpl
    ├── password-reset-container.tpl
    ├── password-reset-change-prompt.tpl
    ├── password-reset-email-prompt.tpl
    ├── password-reset-security-prompt.tpl
    ├── account-contacts-manage.tpl
    ├── account-contacts-new.tpl
    ├── account-paymentmethods.tpl
    ├── account-paymentmethods-manage.tpl
    ├── account-paymentmethods-billing-contacts.tpl
    ├── account-user-management.tpl
    ├── account-user-permissions.tpl
    │
    # Public
    ├── contact.tpl                         # Contact form (REQUIRED)
    ├── announcements.tpl                   # Announcements (REQUIRED)
    ├── viewannouncement.tpl
    ├── knowledgebase.tpl                   # KB (REQUIRED)
    ├── knowledgebasearticle.tpl
    ├── knowledgebasecat.tpl
    ├── downloads.tpl
    ├── downloadscat.tpl
    ├── downloaddenied.tpl
    ├── serverstatus.tpl
    │
    # SSL
    ├── configuressl-stepone.tpl
    ├── configuressl-steptwo.tpl
    ├── configuressl-complete.tpl
    │
    # Other
    ├── affiliates.tpl
    ├── affiliatessignup.tpl
    ├── clientareacancelrequest.tpl
    ├── viewemail.tpl
    └── viewbillingnote.tpl
```

**Total file count:** ~175 files for a complete standalone theme.

---

## Minimum Child Theme

If using a parent theme, this is enough:

```
templates/mytheme/
├── theme.yaml
└── css/
    └── custom.css
```

**That's it.** Everything else inherits from the parent.

---

## Security File: index.php

Every directory should have an `index.php` that redirects to prevent directory browsing:

```php
<?php
header("Location: ../index.php");
exit;
?>
```

This applies to:
- `/css/index.php`
- `/js/index.php`
- `/images/index.php`
- `/img/index.php`
- `/includes/index.php`
- `/error/index.php`
- `/oauth/index.php`
- `/payment/index.php` (and all subdirectories)
- `/store/index.php` (and all subdirectories)

---

## Asset Organization

### CSS Structure

```
css/
├── all.css / all.min.css       # Bootstrap + vendor libs (don't edit)
├── theme.css / theme.min.css   # Compiled from sass/
└── custom.css                  # User-editable overrides (highest specificity)
```

**Load order in `head.tpl`:**
1. `all.min.css`
2. `theme.min.css`
3. Font Awesome
4. `custom.css` (if exists)

### SASS Structure

The Nexus theme uses modular SCSS:

```scss
/* sass/theme.scss - Main entry point */
@import "../../../node_modules/bootstrap-four/scss/bootstrap";
@import "global";
@import "layout";
@import "colors";
/* ...etc */
```

**Compile with:**
```bash
node-sass sass/theme.scss css/theme.css
cleancss -o css/theme.min.css css/theme.css
```

### JS Structure

```
js/
├── scripts.js              # Main theme JS
├── scripts.min.js          # Minified
└── whmcs.js                # WHMCS utilities
```

---

## Language Files

Language files live OUTSIDE the theme directory:

```
/lang/
├── english.php             # Default language
├── spanish.php
├── french.php
├── overrides/
│   ├── english.php         # Your custom strings
│   └── spanish.php
```

Don't put language files in your theme — they're system-wide.

---

## Hook Files

Like language files, hooks live outside the theme:

```
/includes/hooks/
├── custom_theme_hooks.php
├── my_navigation.php
└── my_sidebar.php
```

Theme-related hooks customize menus, add template variables, inject output, etc. See [Hooks Reference](/reference/hooks.md).

---

## Theme vs Application Structure

```
WHMCS Root
├── admin/                  # Admin area (don't touch)
├── assets/                 # Shared WHMCS assets
├── includes/               # Core includes
│   └── hooks/              # Your hooks go here
├── lang/                   # Language files
│   └── overrides/          # Your language overrides
├── modules/                # Module system
├── resources/              # WHMCS resources
├── templates/              # ← YOUR THEMES LIVE HERE
│   ├── nexus/              # Default theme (don't modify)
│   ├── twenty-one/         # Old default
│   ├── six/                # Legacy
│   └── mytheme/            # ← YOUR CUSTOM THEME
├── templates_c/            # Compiled templates (auto-generated)
└── vendor/                 # Composer dependencies
```

---

## Next Steps

- [Minimum Theme](/starter/minimum-theme.md) — Quick-start guide
- [Header Template](/starter/header-template.md) — Complete `header.tpl` walkthrough
- [Footer Template](/starter/footer-template.md) — Complete `footer.tpl` walkthrough
- [Template Fallback](/starter/template-fallback.md) — How resolution works
