# Form Patterns & Reference

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

## Complete Form Actions Reference

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
