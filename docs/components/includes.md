# Include Components

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
