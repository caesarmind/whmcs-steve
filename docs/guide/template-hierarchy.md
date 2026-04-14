# Template Hierarchy & Layout System

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
