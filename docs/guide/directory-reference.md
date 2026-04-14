# Directory & File Reference

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
