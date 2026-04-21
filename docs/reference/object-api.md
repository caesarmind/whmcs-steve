# Object API Reference

Complete reference of all WHMCS object methods and properties accessed in Smarty templates. This is the critical reference developers need when customizing page templates or creating new ones.

## Overview

WHMCS exposes PHP objects directly in Smarty templates. You can call methods and access properties using:
- `{$object->property}` - Property access
- `{$object->method()}` - Method call
- `{$object->method($arg)}` - Method with argument
- `{$object->chain()->method()}` - Method chaining (fluent API)

All objects documented below are drawn from actual Nexus theme usage and official WHMCS class documentation.

---

## `$client` — User\Client

The currently-authenticated client. Available globally when `$loggedin` is true.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Client ID |
| `->firstName` | string | First name |
| `->lastName` | string | Last name |
| `->fullName` | string | Combined first + last name |
| `->email` | string | Email address |
| `->companyName` | string | Company name |
| `->address1` | string | Address line 1 |
| `->address2` | string | Address line 2 |
| `->city` | string | City |
| `->state` | string | State/province |
| `->postcode` | string | Postal code |
| `->country` | string | Country code (2-letter) |
| `->phonenumber` | string | Phone number |
| `->currency` | object | Currency object |
| `->language` | string | Preferred language |
| `->status` | string | Account status |
| `->billingContactId` | int | Default billing contact ID |
| `->payMethods` | Collection | Payment methods collection |

### Methods

```smarty
{* Eloquent-style queries *}
{$client->contacts()->orderBy('firstname', 'asc')->get()}
{$client->payMethods->validateGateways()}
{$client->currency->prefix}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->contacts()` | QueryBuilder | Eloquent relationship to contacts |
| `->contacts()->orderBy($col, $dir)->get()` | Collection | Ordered contact list |
| `->payMethods()` | Collection | All payment methods |
| `->payMethods->validateGateways()` | Collection | Valid payment methods |

---

## `$product` — Product\Product

A product or service offering. Used in store templates, order pages, upgrade flows.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Product ID |
| `->name` | string | Display name |
| `->description` | string | HTML description |
| `->productKey` | string | URL-friendly identifier |
| `->features` | array | Feature list |
| `->siteFeatures` | array | Website builder features |
| `->ecommerceFeatures` | array | E-commerce features |
| `->configoption1` | string | Configurable option 1 |
| `->diskSpace` | string | Disk space allocation |
| `->idealFor` | string | Target audience text |
| `->isFeatured` | boolean | Is featured product |
| `->eligibleForUpgrade` | boolean | Can be upgraded |
| `->formattedProductFeatures` | object | Formatted features object |
| `->formattedProductFeatures.featuresDescription` | string | Features as HTML |
| `->productGroup` | ProductGroup | Parent product group |

### Methods

```smarty
{$product->pricing()->first()->toFullString()}
{$product->pricing()->best()->monthlyPrice()}

{foreach $product->pricing()->allAvailableCycles() as $cycle}
    {$cycle->cycle()} - {$cycle->monthlyPrice()}
{/foreach}

{if $product->isFree()}{lang key='free'}{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->pricing()` | PricingCollection | Pricing fluent API (chainable) |
| `->pricing()->first()` | Pricing | First/default pricing |
| `->pricing()->best()` | Pricing | Best/primary pricing |
| `->pricing()->annual()` | Pricing | Annual cycle pricing |
| `->pricing()->annually()` | Pricing | Alias for annual |
| `->pricing()->biennial()` | Pricing | 2-year pricing |
| `->pricing()->triennial()` | Pricing | 3-year pricing |
| `->pricing()->allAvailableCycles()` | Collection | All billing cycles |
| `->isFree()` | boolean | Is free product |

---

## `$pricing` — Product\Pricing

A single billing cycle's pricing. Returned from `$product->pricing()` methods.

### Methods

```smarty
{* Get cycle information *}
{$pricing->cycle()}                {* Returns: monthly, annually, biennially, etc. *}
{$pricing->cycleInMonths()}        {* Returns: 1, 3, 6, 12, 24, 36 *}
{$pricing->cycleInYears()}         {* Returns: 1, 2, 3 *}

{* Boolean checks *}
{if $pricing->isRecurring()}{lang key='recurring'}{/if}
{if $pricing->isYearly()}{lang key='yearly'}{/if}
{if $pricing->isOneTime()}{lang key='oneTime'}{/if}

{* Formatted prices *}
{$pricing->monthlyPrice()}          {* e.g. "$9.99" *}
{$pricing->yearlyPrice()}           {* e.g. "$99.00" *}
{$pricing->oneTimePrice()}          {* e.g. "$49.00" *}
{$pricing->toFullString()}          {* e.g. "$99.00 / year" *}
{$pricing->toPrefixedString()}      {* With currency prefix *}
{$pricing->breakdownPrice()}        {* Breakdown display *}

{* Comparison *}
{$pricing->calculatePercentageDifference($otherPrice)}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->cycle()` | string | Cycle code (monthly, annually, etc.) |
| `->cycleInMonths()` | int | Cycle length in months |
| `->cycleInYears()` | int | Cycle length in years |
| `->isRecurring()` | boolean | Is recurring subscription |
| `->isYearly()` | boolean | Is yearly cycle |
| `->isOneTime()` | boolean | Is one-time payment |
| `->monthlyPrice()` | string | Formatted monthly price |
| `->yearlyPrice()` | string | Formatted yearly price |
| `->oneTimePrice()` | string | Formatted one-time price |
| `->price()` | string | Raw price |
| `->toFullString()` | string | Full formatted price with cycle |
| `->toPrefixedString()` | string | Price with currency prefix |
| `->breakdownPrice()` | string | Price breakdown for display |
| `->calculatePercentageDifference($price)` | float | Percentage difference calculation |
| `->getShortCycle()` | string | Short cycle abbreviation |

---

## `$service` — Service\Service

A client's active product/service instance.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Service ID |
| `->domain` | string | Associated domain |
| `->domainStatus` | string | Domain status |
| `->status` | string | Service status |
| `->regdate` | string | Registration date |
| `->nextduedate` | string | Next due date |
| `->amount` | string | Recurring amount |
| `->billingcycle` | string | Billing cycle |
| `->isActive` | boolean | Is active |
| `->sslStatus` | SslStatus/null | SSL certificate status |
| `->product` | Product | Parent product object |
| `->product->productGroup` | ProductGroup | Product group |
| `->product->productGroup->name` | string | Group display name |
| `->product->name` | string | Product name |
| `->productAddon` | Addon | Addon (when applicable) |

---

## `$pay­Method` — Billing\Payment\PayMethod

A saved payment method (card or bank account).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Payment method ID |
| `->contactType` | string | 'Client', 'Contact', or null |
| `->description` | string | User-friendly description |
| `->payment` | object | Nested payment details |
| `->gateway_name` | string | Gateway name |

### Methods

```smarty
{if $payMethod->isDefaultPayMethod()}
    <span class="badge">{lang key='default'}</span>
{/if}

<i class="{$payMethod->getFontAwesomeIcon()}"></i>
{$payMethod->payment->getDisplayName()}

{if $payMethod->isExpired()}
    {lang key='paymentMethods.expired'}
{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->getContactId()` | int | Associated contact ID |
| `->getFontAwesomeIcon()` | string | FA icon class (e.g., `fab fa-cc-visa`) |
| `->getStatus()` | string | Status text |
| `->getType()` | string | Type (CreditCard, BankAccount, RemoteBankAccount, etc.) |
| `->getDescription()` | string | Description text |
| `->isDefaultPayMethod()` | boolean | Is default method |
| `->isExpired()` | boolean | Is expired |
| `->isCreditCard()` | boolean | Is a credit card |
| `->isTokenised()` | boolean | Is tokenized (remote) |

### `->payment` Nested Object

| Method | Returns | Description |
|--------|---------|-------------|
| `->payment->getDisplayName()` | string | e.g., "Visa ending 4242" |

---

## `$sslStatus` — Domain\SslStatus

SSL certificate status. Available on services/domains when SSL is present.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->startDate` | Carbon | Certificate start date |
| `->expiryDate` | Carbon | Certificate expiry date |
| `->issuerName` | string | Certificate issuer (CA) |

### Methods

```smarty
{if $sslStatus->isActive()}
    <img src="{$sslStatus->getImagePath()}"
         class="{$sslStatus->getClass()}"
         title="{$sslStatus->getTooltipContent()}">
    {$sslStatus->getStatusDisplayLabel()}
{/if}

{if $sslStatus->needsResync()}
    <button class="btn btn-warning">Resync</button>
{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->isActive()` | boolean | Certificate is active |
| `->isInactive()` | boolean | Certificate is inactive |
| `->needsResync()` | boolean | Status needs refresh |
| `->getImagePath()` | string | Status icon image URL |
| `->getClass()` | string | CSS class for styling |
| `->getTooltipContent()` | string | Tooltip HTML content |
| `->getStatusDisplayLabel()` | string | Translated status label |

---

## `$alert` — User\Alert

Client notification alert. Iterated via `$clientAlerts` in header.

### Methods

```smarty
{foreach $clientAlerts as $alert}
    <a href="{$alert->getLink()}">
        <i class="fas fa-{if $alert->getSeverity() == 'danger'}exclamation{/if}"></i>
        {$alert->getMessage()}
    </a>
{/foreach}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->getLink()` | string | URL for alert action |
| `->getMessage()` | string | Alert message text |
| `->getSeverity()` | string | `danger`, `warning`, `info`, or `success` |

---

## `$user` — User\User

The authenticated user (separate from client - users can own multiple clients).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | User ID |
| `->email` | string | Email address |
| `->firstName` | string | First name |
| `->lastName` | string | Last name |
| `->pivot` | object | Pivot table (for client relationships) |
| `->pivot->owner` | boolean | Is account owner |

### Methods

```smarty
{if $user->hasTwoFactorAuthEnabled()}
    <span class="badge badge-success">2FA</span>
{/if}

{if $user->pivot->hasLastLogin()}
    Last seen: {$user->pivot->getLastLogin()->diffForHumans()}
{/if}

{if !$user->emailVerified()}
    {lang key='user.emailNotVerified'}
{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->hasTwoFactorAuthEnabled()` | boolean | 2FA is active |
| `->hasSecurityQuestion()` | boolean | Has security question set |
| `->getSecurityQuestion()` | string | Security question text |
| `->emailVerified()` | boolean | Email address verified |
| `->needsToCompleteEmailVerification()` | boolean | Verification pending |
| `->pivot->hasLastLogin()` | boolean | Has login history |
| `->pivot->getLastLogin()` | Carbon | Last login timestamp |

---

## `$contact` — User\Contact

A client's additional contact person.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Contact ID |
| `->fullName` | string | Full name |
| `->firstName` | string | First name |
| `->lastName` | string | Last name |
| `->email` | string | Email address |
| `->address1` | string | Address line 1 |
| `->address2` | string | Address line 2 |
| `->city` | string | City |
| `->state` | string | State/province |
| `->postcode` | string | Postal code |
| `->country` | string | Country code |

---

## `$carbon` — Carbon (Laravel date library)

Carbon date helper for formatting timestamps. Global `$carbon` variable available in templates using dates.

### Methods

```smarty
{* Create from Unix timestamp *}
{$carbon->createFromTimestamp($announcement.timestamp)->format('jS F Y')}

{* Diff for humans *}
{$date->diffForHumans()}  {* "2 hours ago", "in 3 days" *}

{* Standard PHP format *}
{$date->format('Y-m-d H:i:s')}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->createFromTimestamp($ts)` | Carbon | Create from Unix timestamp |
| `->format($format)` | string | PHP date format |
| `->diffForHumans()` | string | Relative time ("2 hours ago") |

---

## `$billingNote` — Billing\BillingNote

Billing note / statement object (used in `viewbillingnote.tpl`).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->lineItems` | Collection | Line items |
| `->lineItems[]->description` | string | Item description |
| `->lineItems[]->isTaxed` | boolean | Is taxable item |
| `->lineItems[]->amount` | string | Item amount |
| `->taxes` | Collection | Tax breakdown |
| `->taxes[]->name` | string | Tax name |
| `->taxes[]->rate` | float | Tax rate % |
| `->taxes[]->price` | string | Tax amount |
| `->subTotal` | string | Subtotal |
| `->total` | string | Total amount |
| `->balance` | string | Outstanding balance |

---

## `$productGroup` — Product\Group

Product group (category). Used on homepage and product listing pages.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->name` | string | Display name |
| `->tagline` | string | Tagline text |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `->getRoutePath()` | string | URL to product group page |

---

## `$promotion` — Store\Promotion

Promotional banner/upsell offer.

### Methods

```smarty
<div class="promo {$promotion->getClass()}">
    <img src="{$promotion->getImagePath()}">
    <h3>{$promotion->getHeadline()}</h3>
    <h4>{$promotion->getTagline()}</h4>
    <p>{$promotion->getDescription()}</p>

    {if $promotion->hasFeatures()}
        <ul>
        {foreach $promotion->getFeatures() as $feature}
            <li>{$feature}</li>
        {/foreach}
        </ul>
    {/if}

    <a href="{$promotion->getLearnMoreRoute()}" class="btn">
        {$promotion->getCta()}
    </a>
</div>
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->getImagePath()` | string | Promo image URL |
| `->getHeadline()` | string | Main headline |
| `->getTagline()` | string | Sub-headline |
| `->getDescription()` | string | Description text |
| `->hasFeatures()` | boolean | Has feature list |
| `->getFeatures()` | array | Feature list |
| `->getCta()` | string | Call-to-action text |
| `->getClass()` | string | CSS class |
| `->getLearnMoreRoute()` | string | Learn more URL |

---

## `$sslProduct` — Store\Ssl\SslProduct

SSL certificate product (used in managessl.tpl).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->addonId` | int | Addon ID |
| `->serviceId` | int | Service ID |
| `->status` | string | SSL status |
| `->validationType` | string | 'DV', 'OV', or 'EV' |
| `->addon` | object | Addon details |
| `->addon->service` | object | Associated service |
| `->addon->service->domain` | string | Domain name |
| `->addon->nextDueDateProperties` | object | Next due date info |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `->getConfigurationUrl()` | string | Config page URL |
| `->getUpgradeUrl()` | string | Upgrade URL |
| `->wasInstantIssuanceAttempted()` | boolean | Instant issuance was attempted |
| `->wasInstantIssuanceSuccessful()` | boolean | Instant issuance succeeded |

---

## `$bankAccount` — Billing\Payment\BankAccount

Bank account payment details.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `->getAccountHolderName()` | string | Account holder name |
| `->getAccountNumber()` | string | Account number |
| `->getAccountType()` | string | Checking/Savings |
| `->getBankName()` | string | Bank name |
| `->getRoutingNumber()` | string | Routing number |

---

## `$creditCard` — Billing\Payment\CreditCard

Credit card details.

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `->getExpiryDate()` | Carbon | Expiry date |
| `->getMaskedCardNumber()` | string | Masked number (e.g., `•••• 4242`) |
| `->getStartDate()` | Carbon | Start date (if applicable) |
| `->getIssueNumber()` | string | Issue number (if applicable) |

---

## `$invite` — User\Invite

Account invitation object (user-invite-accept.tpl).

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `->token` | string | Invite token |
| `->id` | int | Invite ID |
| `->email` | string | Invited email |
| `->created_at` | Carbon | Invite creation time |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `->getClientName()` | string | Inviting client name |
| `->getSenderName()` | string | Invite sender name |

---

## `$captcha` — Captcha

CAPTCHA configuration object. Available globally on all pages.

### Methods

```smarty
{if $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
    {$captcha->getMarkup()}
    <script>{$captcha->getPageJs()}</script>
{/if}

<button class="btn btn-primary{$captcha->getButtonClass($captchaForm)}">Submit</button>

{if $captcha->recaptcha->isEnabled() && !$captcha->recaptcha->isInvisible()}
    <div id="google-recaptcha"></div>
{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->isEnabled()` | boolean | CAPTCHA globally enabled |
| `->isEnabledForForm($form)` | boolean | Enabled for specific form |
| `->getMarkup()` | string | HTML markup |
| `->getPageJs()` | string | JavaScript code |
| `->getButtonClass($form)` | string | CSS class for submit button |

### `->recaptcha` Nested Object

| Method | Returns | Description |
|--------|---------|-------------|
| `->recaptcha->isEnabled()` | boolean | reCAPTCHA is active |
| `->recaptcha->isInvisible()` | boolean | Invisible reCAPTCHA mode |

---

## `$announcement` / `$kbarticle` / `$download`

Content objects for announcements, KB articles, and downloads.

### $announcement

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Announcement ID |
| `->title` | string | Title |
| `->text` | string | Full HTML body |
| `->summary` | string | Summary/excerpt |
| `->timestamp` | int | Unix timestamp |
| `->urlfriendlytitle` | string | URL slug |
| `->editLink` | string | Admin edit URL |

### $kbarticle

| Property | Type | Description |
|----------|------|-------------|
| `->id` | int | Article ID |
| `->title` | string | Title |
| `->text` | string | HTML content |
| `->urlfriendlytitle` | string | URL slug |
| `->tags` | string | Tag list |
| `->useful` | int | Useful vote count |
| `->voted` | boolean | User has voted |
| `->editLink` | string | Admin edit URL |

---

## Eloquent Query Builder in Templates

WHMCS allows Eloquent ORM queries directly in Smarty templates. This is unusual but used extensively in Nexus:

```smarty
{* Get ordered contacts *}
{foreach $client->contacts()
    ->orderBy('firstname', 'asc')
    ->orderBy('lastname', 'asc')
    ->get() as $contact}
    {$contact->fullName}
{/foreach}

{* Filtered payment methods *}
{foreach $client->payMethods->validateGateways() as $payMethod}
    {$payMethod->description}
{/foreach}
```

**Common Eloquent methods available:**
- `->orderBy($column, $direction)`
- `->where($column, $operator, $value)`
- `->get()`
- `->first()`
- `->count()`
- `->pluck($column)`

Use carefully - these execute database queries during rendering.

---

## MenuItem — View\Menu\Item

Navigation menu item object. Both a READER (in templates) and WRITER (in hooks).

### Reader Methods (used in templates)

```smarty
{$item->getName()}
{$item->getLabel()}
{$item->getUri()}
{if $item->hasChildren()}
    {foreach $item->getChildren() as $child}{/foreach}
{/if}
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->getName()` | string | Internal name |
| `->getId()` | string | HTML ID |
| `->getLabel()` | string | Display text |
| `->getUri()` | string | Link URL |
| `->hasChildren()` | boolean | Has submenu |
| `->getChildren()` | Collection | Submenu items |
| `->hasIcon()` | boolean | Has icon |
| `->getIcon()` | string | Icon class |
| `->hasBadge()` | boolean | Has badge |
| `->getBadge()` | string | Badge text |
| `->isCurrent()` | boolean | Is current page |
| `->isDisabled()` | boolean | Is disabled |
| `->getClass()` | string | CSS class |
| `->getAttribute($key)` | mixed | Custom attribute |
| `->getExtra($key)` | mixed | Extra data |
| `->hasBodyHtml()` | boolean | Has body HTML |
| `->getBodyHtml()` | string | Body HTML content |
| `->hasFooterHtml()` | boolean | Has footer HTML |
| `->getFooterHtml()` | string | Footer HTML content |
| `->getChildrenAttribute($attr)` | string | Children container attribute |

### Writer Methods (used in hooks)

```php
<?php
use WHMCS\View\Menu\Item as MenuItem;

add_hook('ClientAreaPrimaryNavbar', 1, function (MenuItem $menu) {
    // Modify existing item
    $menu->getChild('Store')
        ->setLabel('Our Products')
        ->setUri('https://example.com/products')
        ->setOrder(10);

    // Add new child
    $menu->addChild('resources')
        ->setLabel('Resources')
        ->setUri('/resources')
        ->setIcon('fas fa-book')
        ->setBadge('New')
        ->setOrder(50);

    // Remove item
    $menu->removeChild('Announcements');

    // Reorder
    $menu->getChild('Support')->moveToFront();
    $menu->getChild('Home')->moveToBack();
});
```

| Method | Returns | Description |
|--------|---------|-------------|
| `->setLabel($text)` | self | Set display text |
| `->setUri($url)` | self | Set link URL |
| `->setOrder($int)` | self | Set numeric order (defaults: 10, 20, 30...) |
| `->setIcon($class)` | self | Set FontAwesome icon class |
| `->setBadge($text)` | self | Set badge text |
| `->setHidden($bool)` | self | Hide/show item |
| `->setDisabled($bool)` | self | Disable/enable item |
| `->setClass($class)` | self | Set CSS class |
| `->setExtra($key, $value)` | self | Set extra data |
| `->setAttribute($key, $value)` | self | Set HTML attribute |
| `->addChild($name, $config = [])` | MenuItem | Add child item (chainable) |
| `->removeChild($name)` | self | Remove child item |
| `->getChild($name)` | MenuItem/null | Get child by name |
| `->moveUp()` | self | Move one position up |
| `->moveDown()` | self | Move one position down |
| `->moveToFront()` | self | Move to first position |
| `->moveToBack()` | self | Move to last position |

### Menu Context (Static)

```php
use WHMCS\View\Menu;

// Get login state for conditional manipulation
if (Menu::context('client')) {
    // Client is logged in
}
```

---

## WHMCS Class/Namespace Reference

Complete WHMCS 9 namespaces (from official classdocs.whmcs.com/9.0/):

| Namespace | Purpose |
|-----------|---------|
| `WHMCS\Announcement` | Announcements |
| `WHMCS\Authentication` | Auth system |
| `WHMCS\Billing` | Billing, invoices |
| `WHMCS\Billing\Payment` | Payment methods |
| `WHMCS\Billing\Payment\Dispute` | Disputes |
| `WHMCS\Billing\Payment\Transaction` | Transactions |
| `WHMCS\Billing\Quote` | Quotes |
| `WHMCS\Billing\VAT` | VAT handling |
| `WHMCS\Cart` | Shopping cart |
| `WHMCS\Cart\Item` | Cart items |
| `WHMCS\Config` | Configuration |
| `WHMCS\CustomField` | Custom fields |
| `WHMCS\Domain` | Domains |
| `WHMCS\Domain\Registrar` | Registrar integration |
| `WHMCS\Domains\Pricing` | Domain pricing |
| `WHMCS\Download` | Downloads |
| `WHMCS\Log` | Logging |
| `WHMCS\Mail` | Email |
| `WHMCS\Module` | Modules |
| `WHMCS\Module\Addon` | Addon modules |
| `WHMCS\Module\Gateway` | Payment gateways |
| `WHMCS\Module\Server` | Server modules |
| `WHMCS\Network` | Network issues |
| `WHMCS\Notification` | Notifications |
| `WHMCS\Product` | Products |
| `WHMCS\Product\Pricing` | Product pricing |
| `WHMCS\Scheduling` | Scheduled tasks |
| `WHMCS\Service` | Services |
| `WHMCS\UsageBilling` | Usage-based billing |
| `WHMCS\User` | Users, clients, contacts |
| `WHMCS\User\Client` | Client-specific |
| `WHMCS\View` | View layer |
| `WHMCS\View\Menu` | Menu system |
| `WHMCS\View\Template` | Template engine |

Full class documentation: [classdocs.whmcs.com/9.0/](https://classdocs.whmcs.com/9.0/)
