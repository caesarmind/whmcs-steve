# Footer Template (footer.tpl) Complete Reference

The `footer.tpl` closes the page layout that `header.tpl` opens. It's responsible for closing the main content wrapper, rendering the footer, system modals, overlays, and injecting all the JavaScript WHMCS needs via `{$footeroutput}`.

## Rendering Flow

```
                 [PAGE CONTENT ENDS]

┌─────────────────────────────────────────┐
│         </div>  (primary-content)       │
│         [Secondary sidebar - mobile]    │
│       </div>  (row)                     │
│     </div>  (container)                 │
│   </section>  (#main-body)              │
│                                         │
│   <footer id="footer">                  │
│     [Social accounts]                   │
│     [Language/Currency button]          │
│     [Footer navigation links]           │
│     [Copyright notice]                  │
│   </footer>                             │
│                                         │
│   [Fullpage overlay (loading states)]   │
│   [System AJAX modal]                   │
│   [Language/Currency chooser modal]     │
│   [Admin return button (if applicable)] │
│   [Generate password modal]             │
│                                         │
│   {$footeroutput}  ← CRITICAL           │
│ </body>                                 │
│ </html>                                 │
└─────────────────────────────────────────┘
```

## Complete footer.tpl

```smarty
                    </div> {* Close primary-content *}

                    {if !$inShoppingCart && $secondarySidebar->hasChildren()}
                        <div class="d-lg-none sidebar sidebar-secondary">
                            {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                        </div>
                    {/if}

                <div class="clearfix"></div>
            </div> {* Close .row *}
        </div> {* Close .container *}
    </section> {* Close #main-body *}

    <footer id="footer" class="footer">
        <div class="container">
            {* SOCIAL ACCOUNTS + LANGUAGE/CURRENCY BUTTON *}
            <ul class="list-inline text-center float-lg-right">
                {include file="$template/includes/social-accounts.tpl"}

                {if $languagechangeenabled && count($locales) > 1 || $currencies}
                    <li class="list-inline-item">
                        <button type="button" class="btn btn-sm btn-outline-light" 
                                data-toggle="modal" data-target="#modalChooseLanguage">
                            <div class="d-inline-block align-middle">
                                <div class="iti-flag {if $activeLocale.countryCode === '001'}us{else}{$activeLocale.countryCode|lower}{/if}"></div>
                            </div>
                            {$activeLocale.localisedName}
                            /
                            {$activeCurrency.prefix}
                            {$activeCurrency.code}
                        </button>
                    </li>
                {/if}
            </ul>

            {* FOOTER LINKS *}
            <ul class="nav justify-content-center justify-content-lg-start">
                <li class="nav-item">
                    <a class="nav-link" href="{$WEB_ROOT}/contact.php">
                        {lang key='contactus'}
                    </a>
                </li>
                {if $acceptTOS}
                    <li class="nav-item">
                        <a class="nav-link" href="{$tosURL}" target="_blank">
                            {lang key='ordertos'}
                        </a>
                    </li>
                {/if}
            </ul>

            <p class="copyright mb-0">
                {lang key="copyrightFooterNotice" year=$date_year company=$companyname}
            </p>
        </div>
    </footer>

    {* FULLPAGE LOADING OVERLAY *}
    <div id="fullpage-overlay" class="w-hidden">
        <div class="outer-wrapper">
            <div class="inner-wrapper">
                <img src="{$WEB_ROOT}/assets/img/overlay-spinner.svg" alt="">
                <br>
                <span class="msg"></span>
            </div>
        </div>
    </div>

    {* SYSTEM AJAX MODAL *}
    <div class="modal system-modal fade" id="modalAjax" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"></h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">&times;</span>
                        <span class="sr-only">{lang key='close'}</span>
                    </button>
                </div>
                <div class="modal-body">
                    {lang key='loading'}
                </div>
                <div class="modal-footer">
                    <div class="float-left loader">
                        <i class="fas fa-circle-notch fa-spin"></i>
                        {lang key='loading'}
                    </div>
                    <button type="button" class="btn btn-default" data-dismiss="modal">
                        {lang key='close'}
                    </button>
                    <button type="button" class="btn btn-primary modal-submit">
                        {lang key='submit'}
                    </button>
                </div>
            </div>
        </div>
    </div>

    {* LANGUAGE/CURRENCY CHOOSER MODAL *}
    <form method="get" action="{$currentpagelinkback}">
        <div class="modal modal-localisation" id="modalChooseLanguage" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-body">
                        <button type="button" class="close text-light" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>

                        {if $languagechangeenabled && count($locales) > 1}
                            <h5 class="h5 pt-5 pb-3">{lang key='chooselanguage'}</h5>
                            <div class="row item-selector">
                                <input type="hidden" name="language" data-current="{$language}" value="{$language}" />
                                {foreach $locales as $locale}
                                    <div class="col-4">
                                        <a href="#" class="item{if $language == $locale.language} active{/if}" data-value="{$locale.language}">
                                            {$locale.localisedName}
                                        </a>
                                    </div>
                                {/foreach}
                            </div>
                        {/if}

                        {if !$loggedin && $currencies}
                            <p class="h5 pt-5 pb-3">{lang key='choosecurrency'}</p>
                            <div class="row item-selector">
                                <input type="hidden" name="currency" data-current="{$activeCurrency.id}" value="">
                                {foreach $currencies as $selectCurrency}
                                    <div class="col-4">
                                        <a href="#" class="item{if $activeCurrency.id == $selectCurrency.id} active{/if}" data-value="{$selectCurrency.id}">
                                            {$selectCurrency.prefix} {$selectCurrency.code}
                                        </a>
                                    </div>
                                {/foreach}
                            </div>
                        {/if}
                    </div>
                    <div class="modal-footer">
                        <button type="submit" class="btn btn-default">{lang key='apply'}</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    {* ADMIN RETURN BUTTON - For non-logged-in pages *}
    {if !$loggedin && $adminLoggedIn}
        <a href="{$WEB_ROOT}/logout.php?returntoadmin=1" class="btn btn-return-to-admin" 
           data-toggle="tooltip" data-placement="bottom" 
           title="{if $adminMasqueradingAsClient}{lang key='adminmasqueradingasclient'} {lang key='logoutandreturntoadminarea'}{else}{lang key='adminloggedin'} {lang key='returntoadminarea'}{/if}">
            <i class="fas fa-redo-alt"></i>
            <span class="d-none d-md-inline-block">{lang key="admin.returnToAdmin"}</span>
        </a>
    {/if}

    {* PASSWORD GENERATOR MODAL *}
    {include file="$template/includes/generate-password.tpl"}

    {* CRITICAL - MUST BE INCLUDED *}
    {$footeroutput}

</body>
</html>
```

---

## Block-by-Block Walkthrough

### 1. Closing the Content Wrapper

```smarty
                    </div> {* primary-content *}

                    {if !$inShoppingCart && $secondarySidebar->hasChildren()}
                        <div class="d-lg-none sidebar sidebar-secondary">
                            {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                        </div>
                    {/if}

                <div class="clearfix"></div>
            </div> {* .row *}
        </div> {* .container *}
    </section> {* #main-body *}
```

**Important:** The footer MUST close these elements exactly matching what `header.tpl` opened:
- `<div class="primary-content">`
- `<div class="row">`
- `<div class="container">`
- `<section id="main-body">`

**Mobile secondary sidebar:** Shows the secondary sidebar below content on mobile (`d-lg-none` means hidden on large+ screens).

### 2. Footer Element

```smarty
<footer id="footer" class="footer">
    <div class="container">
        {* Social + Language/Currency *}
        <ul class="list-inline text-center float-lg-right">
            {include file="$template/includes/social-accounts.tpl"}
            
            {if $languagechangeenabled || $currencies}
                <li class="list-inline-item">
                    <button data-toggle="modal" data-target="#modalChooseLanguage">
                        <div class="iti-flag {$activeLocale.countryCode|lower}"></div>
                        {$activeLocale.localisedName}
                        / {$activeCurrency.code}
                    </button>
                </li>
            {/if}
        </ul>

        {* Footer links *}
        <ul class="nav">
            <li><a href="{$WEB_ROOT}/contact.php">{lang key='contactus'}</a></li>
            {if $acceptTOS}
                <li><a href="{$tosURL}" target="_blank">{lang key='ordertos'}</a></li>
            {/if}
        </ul>

        {* Copyright *}
        <p>{lang key='copyrightFooterNotice' year=$date_year company=$companyname}</p>
    </div>
</footer>
```

**Key variables:**
- `$languagechangeenabled` — Bool, language switching is enabled
- `$locales` — Array of available languages
- `$currencies` — Array of available currencies
- `$activeLocale` — Current locale object (`countryCode`, `localisedName`, `language`)
- `$activeCurrency` — Current currency object (`id`, `code`, `prefix`)
- `$acceptTOS` — Bool, TOS enabled
- `$tosURL` — URL to terms of service

### 3. Fullpage Overlay

```smarty
<div id="fullpage-overlay" class="w-hidden">
    <div class="outer-wrapper">
        <div class="inner-wrapper">
            <img src="{$WEB_ROOT}/assets/img/overlay-spinner.svg" alt="">
            <br>
            <span class="msg"></span>
        </div>
    </div>
</div>
```

**Purpose:** JavaScript-controlled loading overlay. Starts hidden (`w-hidden` = `display: none`). Shown by core WHMCS JavaScript during AJAX operations.

**Trigger from JS:**
```javascript
// Show
jQuery('#fullpage-overlay').removeClass('w-hidden').find('.msg').text('Processing...');

// Hide
jQuery('#fullpage-overlay').addClass('w-hidden');
```

### 4. System AJAX Modal

```smarty
<div class="modal system-modal fade" id="modalAjax">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"></h5>
                <button type="button" class="close" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body">{lang key='loading'}</div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{lang key='close'}</button>
                <button type="button" class="btn btn-primary modal-submit">{lang key='submit'}</button>
            </div>
        </div>
    </div>
</div>
```

**Purpose:** Generic modal used by WHMCS JavaScript for various AJAX operations (cancel service, confirm actions, etc.). Must be present on every page.

### 5. Language/Currency Modal

Bootstrap modal opened by the button in the footer:

```smarty
<form method="get" action="{$currentpagelinkback}">
    <div class="modal" id="modalChooseLanguage">
        <!-- Modal with language grid and currency grid -->
    </div>
</form>
```

**Form submits to:** `{$currentpagelinkback}` — Returns to same page with new language/currency params.

**Works via JavaScript:** Clicking language/currency items sets the hidden input value before form submission.

### 6. Admin Return Button

Shown when admin is logged in but viewing from client perspective:

```smarty
{if !$loggedin && $adminLoggedIn}
    <a href="{$WEB_ROOT}/logout.php?returntoadmin=1" class="btn btn-return-to-admin">
        <i class="fas fa-redo-alt"></i> {lang key="admin.returnToAdmin"}
    </a>
{/if}
```

**Note:** This is ONLY for non-logged-in pages. When logged in, the return button appears in the topbar instead.

### 7. Password Generator Modal

```smarty
{include file="$template/includes/generate-password.tpl"}
```

Includes the self-contained password generation modal used by password fields throughout the theme.

### 8. `{$footeroutput}` — CRITICAL

```smarty
{$footeroutput}
```

**This single line is the most important in the entire footer.**

**What it injects:**
- jQuery library (if not present)
- jQuery UI
- Bootstrap JS
- WHMCS JavaScript API (`WHMCS.http`, `WHMCS.payment`, `WHMCS.utils`)
- CSRF token setup
- Language string globals
- DataTables (if page uses tables)
- Analytics code
- Hook output from `ClientAreaFooterOutput`

**Without it:** The client area will be completely broken:
- Cart functions don't work
- Forms don't validate
- Modals don't open
- DataTables don't load
- All JavaScript breaks

---

## Required vs Optional Elements

### MANDATORY

- Closing tags matching header.tpl opens:
  - `</div>` (primary-content)
  - `</div>` (row)
  - `</div>` (container)
  - `</section>` (#main-body)
- `{$footeroutput}` — **ABSOLUTELY REQUIRED**
- System AJAX modal (`#modalAjax`)
- Fullpage overlay (`#fullpage-overlay`)

### HIGHLY RECOMMENDED

- `<footer>` element with copyright
- Language/currency modal (if multilingual site)
- Password generator modal include
- Admin return button (for admin UX)

### OPTIONAL

- Social media links
- Custom footer links (Contact, TOS)
- Additional modals

---

## Customization Patterns

### Custom footer with multiple columns

```smarty
<footer id="footer" class="footer">
    <div class="container">
        <div class="row">
            <div class="col-md-3">
                <h5>Company</h5>
                <ul>
                    <li><a href="{$WEB_ROOT}/contact.php">About</a></li>
                    <li><a href="{$WEB_ROOT}/contact.php">Contact</a></li>
                </ul>
            </div>
            <div class="col-md-3">
                <h5>Support</h5>
                <ul>
                    <li><a href="{routePath('knowledgebase-index')}">Knowledge Base</a></li>
                    <li><a href="{$WEB_ROOT}/submitticket.php">Open Ticket</a></li>
                </ul>
            </div>
            <div class="col-md-3">
                <h5>Legal</h5>
                <ul>
                    {if $acceptTOS}
                        <li><a href="{$tosURL}">Terms of Service</a></li>
                    {/if}
                    <li><a href="/privacy">Privacy Policy</a></li>
                </ul>
            </div>
            <div class="col-md-3">
                <h5>Connect</h5>
                <ul class="list-inline">
                    {include file="$template/includes/social-accounts.tpl"}
                </ul>
            </div>
        </div>
        <hr>
        <p class="copyright text-center">
            {lang key='copyrightFooterNotice' year=$date_year company=$companyname}
        </p>
    </div>
</footer>

{* ...modals and overlays... *}
{$footeroutput}
```

### Dark themed footer

```smarty
<footer id="footer" class="footer bg-dark text-white">
    <div class="container py-5">
        <!-- content -->
    </div>
</footer>
```

### Add custom chat widget

Better done via hook but can add before `{$footeroutput}`:

```smarty
{* Chat widget before footeroutput *}
<script>
    // Your chat widget code
</script>

{$footeroutput}
</body>
```

**Better approach via hook:**

```php
// /includes/hooks/chat_widget.php
add_hook('ClientAreaFooterOutput', 1, function($vars) {
    return '<script>/* Chat widget code */</script>';
});
```

---

## Common Mistakes

### ❌ Missing `{$footeroutput}` — SITE BREAKS

```smarty
<footer>Copyright 2026</footer>
</body>
</html>
{* MISSING $footeroutput - entire client area stops working *}
```

### ❌ Wrong closing tag order

```smarty
{* Breaks layout - doesn't match header.tpl structure *}
</section>
</div>
</div>
{* vs correct: *}
</div>  {* primary-content *}
</div>  {* row *}
</div>  {* container *}
</section>  {* main-body *}
```

### ❌ Placing `{$footeroutput}` in wrong location

```smarty
{* WRONG - footeroutput must be last thing before </body> *}
{$footeroutput}
<footer>...</footer>
</body>
```

### ✅ Correct placement

```smarty
<footer>...</footer>
{* modals *}
{$footeroutput}
</body>
```

### ❌ Removing the modalAjax element

```smarty
{* System functions expect #modalAjax to exist *}
{* Removing it breaks cancellation, confirmation dialogs, etc. *}
```

### ❌ Loading jQuery yourself

```smarty
{* BAD - $footeroutput already loads jQuery 1.12.4 *}
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
{$footeroutput}
```

---

## Testing Your footer.tpl

After modifications:

1. **Cart page** — Cart JavaScript works (add/remove items)
2. **Product details** — Module buttons functional
3. **Login page** — Password reveal toggles, form submission works
4. **Any page with table** — DataTables initializes
5. **Any modal** — Opens and closes properly
6. **Mobile** — Secondary sidebar visible below content
7. **Language switch** — Modal opens, form submits, language changes
8. **Admin masquerade** — Return button visible on non-logged pages

**Browser console check:**
- No JavaScript errors
- `jQuery`, `WHMCS` globals defined
- No 404 for scripts/CSS

---

## Template Variables Reference

| Variable | Type | Used For |
|----------|------|----------|
| `$inShoppingCart` | bool | Hide sidebar on cart |
| `$secondarySidebar` | MenuItem | Mobile sidebar |
| `$languagechangeenabled` | bool | Show language chooser |
| `$locales` | array | Available locales |
| `$currencies` | array | Available currencies |
| `$activeLocale` | object | Current locale |
| `$activeLocale.countryCode` | string | Country code for flag |
| `$activeLocale.localisedName` | string | Locale display name |
| `$activeLocale.language` | string | Language code |
| `$activeCurrency` | object | Current currency |
| `$activeCurrency.id` | int | Currency ID |
| `$activeCurrency.code` | string | Currency code |
| `$activeCurrency.prefix` | string | Currency symbol |
| `$acceptTOS` | bool | TOS required |
| `$tosURL` | string | TOS page URL |
| `$currentpagelinkback` | string | Current URL for forms |
| `$adminLoggedIn` | bool | Admin is logged in |
| `$adminMasqueradingAsClient` | bool | Admin masquerading |

---

## Next Steps

- [Header Template](/starter/header-template.md) — Complete `header.tpl` walkthrough
- [System Output Variables](/reference/system-output.md) — What `{$footeroutput}` contains
- [Template Fallback](/starter/template-fallback.md) — How resolution works
- [Include Components](/components/includes.md) — All reusable partials
