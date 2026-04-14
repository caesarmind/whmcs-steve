# JavaScript Integration

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

### WHMCS JavaScript API Reference

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
