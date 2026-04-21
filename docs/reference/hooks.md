# Complete Hook Reference

Complete reference of all 382+ WHMCS 9 hooks. Hooks are the primary extension point for customizing WHMCS behavior without modifying core code. They're the ONLY future-proof way to add PHP logic to your theme.

## How Hooks Work

```php
<?php
// File location: /includes/hooks/yourhook.php

add_hook('HookName', 1, function($vars) {
    // Your logic here
    return $returnValue; // If applicable
});
```

- **Hook name**: Event name (must match exactly)
- **Priority**: Lower numbers run first (default 1)
- **Callback**: Function receiving event data

Hook files go in `/includes/hooks/` — they're loaded automatically.

---

## Client Area Interface Hooks (68 hooks)

### Page-Specific Hooks

Every client area page has a `ClientAreaPage[PageName]` hook that fires when that page renders. Use these to add page-specific template variables.

```php
add_hook('ClientAreaPageHome', 1, function($vars) {
    return [
        'myCustomVar' => 'Hello from hook!',
        'featuredProduct' => getFeaturedProduct(),
    ];
});
```

The returned array is merged into template variables: `{$myCustomVar}`.

**All ClientAreaPage hooks:**

| Hook | Page |
|------|------|
| `ClientAreaPageHome` | Client dashboard |
| `ClientAreaPageProductsServices` | Services list |
| `ClientAreaPageProductDetails` | Service details |
| `ClientAreaPageDomains` | Domains list |
| `ClientAreaPageDomainDetails` | Domain details |
| `ClientAreaPageDomainContacts` | Domain contacts |
| `ClientAreaPageDomainDNSManagement` | DNS management |
| `ClientAreaPageDomainEmailForwarding` | Email forwarding |
| `ClientAreaPageDomainAddons` | Domain addons |
| `ClientAreaPageDomainEPPCode` | EPP code |
| `ClientAreaPageDomainRegisterNameservers` | Register NS |
| `ClientAreaPageBulkDomainManagement` | Bulk domain |
| `ClientAreaPageInvoices` | Invoice list |
| `ClientAreaPageViewInvoice` | Invoice view |
| `ClientAreaPageQuotes` | Quote list |
| `ClientAreaPageViewQuote` | Quote view |
| `ClientAreaPageMassPay` | Mass payment |
| `ClientAreaPageAddFunds` | Add funds |
| `ClientAreaPageCreditCard` | Credit card management |
| `ClientAreaPageCreditCardCheckout` | CC checkout |
| `ClientAreaPageSupportTickets` | Ticket list |
| `ClientAreaPageViewTicket` | Ticket view |
| `ClientAreaPageSubmitTicket` | Submit ticket |
| `ClientAreaPageKnowledgebase` | KB index |
| `ClientAreaPageAnnouncements` | Announcements |
| `ClientAreaPageDownloads` | Downloads |
| `ClientAreaPageServerStatus` | Server status |
| `ClientAreaPageNetworkIssues` | Network issues |
| `ClientAreaPageContact` | Contact form |
| `ClientAreaPageContacts` | Contacts list |
| `ClientAreaPageAddContact` | Add contact |
| `ClientAreaPageProfile` | Profile |
| `ClientAreaPageChangePassword` | Password change |
| `ClientAreaPageSecurity` | Security settings |
| `ClientAreaPageEmails` | Email history |
| `ClientAreaPageViewEmail` | View email |
| `ClientAreaPageAffiliates` | Affiliates |
| `ClientAreaPageAddonModule` | Addon modules |
| `ClientAreaPageLogin` | Login page |
| `ClientAreaPageRegister` | Registration |
| `ClientAreaPageLogout` | Logout |
| `ClientAreaPagePasswordReset` | Password reset |
| `ClientAreaPageCart` | Shopping cart |
| `ClientAreaPageCancellation` | Cancellation |
| `ClientAreaPageUpgrade` | Upgrade |
| `ClientAreaPageConfigureSSL` | SSL config |
| `ClientAreaPageBanned` | Banned page |
| `ClientAreaPageUnsubscribe` | Unsubscribe |

### Navigation & Sidebar Hooks

Control menu/sidebar rendering. These receive a `MenuItem` object to manipulate.

| Hook | Purpose |
|------|---------|
| `ClientAreaPrimaryNavbar` | Main top navigation |
| `ClientAreaSecondaryNavbar` | Secondary navigation (user menu) |
| `ClientAreaPrimarySidebar` | Primary sidebar (most pages) |
| `ClientAreaSecondarySidebar` | Secondary sidebar (below body) |
| `ClientAreaSidebars` | Both sidebars (composite) |
| `ClientAreaNavbars` | Both navbars (composite) |

```php
use WHMCS\View\Menu\Item as MenuItem;

add_hook('ClientAreaPrimaryNavbar', 1, function (MenuItem $menu) {
    $menu->addChild('custom')
        ->setLabel('Custom Link')
        ->setUri('/custom')
        ->setOrder(100);
});
```

See [Object API: MenuItem](/reference/object-api.md#menuitem--viewmenuitem) for complete MenuItem API.

### Special Client Area Hooks

| Hook | Purpose | Parameters |
|------|---------|------------|
| `ClientAreaHomepage` | Homepage rendering | Standard template vars |
| `ClientAreaHomepagePanels` | Before panels render | Standard template vars |
| `ClientAreaPaymentMethods` | Payment methods display | Standard template vars |
| `ClientAreaProductDetails` | Product details page | Standard template vars |
| `ClientAreaProductDetailsPreModuleTemplate` | Pre-module template | Standard template vars |
| `ClientAreaDomainDetails` | Domain details page | Domain-related vars |
| `ClientAreaRegister` | Post-registration | Standard template vars |

---

## Output Hooks (15 hooks)

These hooks return HTML that gets injected into specific page locations.

```php
add_hook('ClientAreaHeadOutput', 1, function($vars) {
    return '<meta name="custom" content="value">
            <link rel="stylesheet" href="/custom.css">';
});
```

### Client Area Output

| Hook | Purpose | Parameters |
|------|---------|------------|
| `ClientAreaHeadOutput` | Inject into `<head>` | template, language, charset, pagetitle, BASE_PATH vars |
| `ClientAreaHeaderOutput` | Inject into header | filename, template, LANG, todaysdate, token |
| `ClientAreaFooterOutput` | Inject into footer | companyname, template, language, LANG, token, servedOverSsl |

### Specialized Output Hooks

| Hook | Purpose | Parameters |
|------|---------|------------|
| `ClientAreaDomainDetailsOutput` | Domain details page | domain object, client data, status |
| `ClientAreaProductDetailsOutput` | Product details | service object, orderId |
| `ShoppingCartCheckoutOutput` | Checkout page | cartData |
| `ShoppingCartViewCartOutput` | View cart page | cartData |
| `ShoppingCartConfigureProductAddonsOutput` | Addon config | billingCycle, selectedAddons |
| `FormatDateForClientAreaOutput` | Date formatting | date (Carbon) |
| `FormatDateTimeForClientAreaOutput` | DateTime formatting | date (Carbon) |

### Admin Area Output

| Hook | Purpose | Parameters |
|------|---------|------------|
| `AdminAreaHeadOutput` | Admin head | adminid, template, charset, jscode |
| `AdminAreaHeaderOutput` | Admin header | adminid, filename, pagetitle |
| `AdminAreaFooterOutput` | Admin footer | adminid, filename, pagetitle |
| `AdminInvoicesControlsOutput` | Invoice controls | invoiceid, userid, total |
| `ReportViewPreOutput` | Before report | report, moduleType, moduleName |
| `ReportViewPostOutput` | After report | report, moduleType, moduleName |

---

## Authentication Hooks (3 hooks)

| Hook | When | Parameters |
|------|------|------------|
| `UserLogin` | User logs in | user (WHMCS\User\User object) |
| `UserLogout` | User logs out | user (WHMCS\User\User object) |
| `ClientLoginShare` | During login if user doesn't exist | username, password — can return user data |

```php
add_hook('UserLogin', 1, function($vars) {
    $user = $vars['user'];
    logActivity("User {$user->email} logged in");
});
```

---

## Client Hooks (9 hooks)

| Hook | When | Key Parameters |
|------|------|----------------|
| `ClientAdd` | Client added | client_id, user_id, firstname, lastname, email, address*, country, phonenumber, customFields |
| `ClientEdit` | Client updated | userid, uuid, firstname, lastname, email, address*, currency, notes, status |
| `ClientChangePassword` | Password changed | userid, password |
| `ClientClose` | Client closed | userid |
| `ClientDelete` | Client deleted (deprecated, use PreDeleteClient) | userid |
| `PreDeleteClient` | Before deletion | userid |
| `AfterClientMerge` | Merge complete | toUserID, fromUserID |
| `ClientAlert` | Alerts defined | Client model |
| `ClientDetailsValidation` | Validate details | All form POST data |

---

## User Hooks (5 hooks)

| Hook | When | Parameters |
|------|------|------------|
| `PreUserAdd` | Before user add | user_id, firstname, lastname, email, password, language |
| `UserAdd` | User added | user_id, firstname, lastname, email, password, language |
| `UserChangePassword` | Password changed | userid, password |
| `UserEdit` | User updated | user_id, firstname, lastname, email, olddata |
| `UserEmailVerificationComplete` | Email verified | userId |

---

## Contact Hooks (4 hooks)

| Hook | When | Parameters |
|------|------|------------|
| `ContactAdd` | Contact added | userid, contactid, name/email/address fields |
| `ContactEdit` | Contact edited | userid, contactid, name/email/address + olddata |
| `ContactDelete` | Contact deleted | userid, contactid |
| `ContactDetailsValidation` | Validate contact | All form POST data |

---

## Invoice & Quote Hooks (24 hooks)

### Invoice Lifecycle

| Hook | When | Parameters |
|------|------|------------|
| `InvoiceCreation` | Invoice first created | source, user, invoiceid, status |
| `InvoiceCreationPreEmail` | Created in admin (pre-email) | source, user, invoiceid, status |
| `InvoiceCreationAdminArea` | Created in admin | source, user, invoiceid, status |
| `InvoiceCreated` | Exits Draft status | source, user, invoiceid, status |
| `UpdateInvoiceTotal` | Invoice total updated | invoiceid |
| `AfterInvoicingGenerateInvoiceItems` | After generation | — |
| `PreInvoicingGenerateInvoiceItems` | Before generation | — |
| `InvoicePaidPreEmail` | Paid (pre-email) | invoiceid |
| `InvoicePaid` | Paid (post-automation) | invoiceid, invoice object |
| `InvoiceUnpaid` | Marked unpaid | invoiceid |
| `InvoiceRefunded` | Refunded | invoiceid |
| `InvoiceCancelled` | Cancelled | invoiceid |
| `InvoiceSplit` | Split | originalinvoiceid, newinvoiceid |
| `PreInvoiceAutomaticCancellation` | Before auto-cancel | invoiceid |
| `InvoiceChangeGateway` | Gateway changed | invoiceid, paymentmethod |
| `AddInvoicePayment` | Payment applied | invoiceid |
| `AddInvoiceLateFee` | Late fee added | invoiceid |
| `InvoicePaymentReminder` | Reminder sent | invoiceid, type |
| `ViewInvoiceDetailsPage` | Viewed by client | invoiceid |

### Transactions

| Hook | When | Parameters |
|------|------|------------|
| `AddTransaction` | Transaction created | id, userid, currency, gateway, date, description, amountin, fees, amountout, rate, transid, invoiceid, refundid |
| `LogTransaction` | Gateway callback logged | gateway, data, result |
| `ManualRefund` | Manual refund | transid, amount |

### Quotes

| Hook | When | Parameters |
|------|------|------------|
| `QuoteCreated` | Quote created | quoteid, status |
| `QuoteStatusChange` | Status updated | quoteid, status |
| `AcceptQuote` | Client accepts | quoteid, invoiceid |

---

## Shopping Cart Hooks (29 hooks)

### Cart Totals & Validation

| Hook | When | Parameters |
|------|------|------------|
| `PreCalculateCartTotals` | Before calculation | products, domains |
| `AfterCalculateCartTotals` | After calculation | total (Price object) |
| `CartTotalAdjustment` | Order total adjusted | products, domains |
| `CartItemsTax` | Tax calculated | clientData, cartData |
| `PreShoppingCartCheckout` | Before checkout | products, domains |
| `ShoppingCartValidateCheckout` | Validation phase | Payment method, CC, customer type, client ID, contact, custom fields |
| `ShoppingCartValidateDomain` | Domain validation | domainoption, sld, tld |
| `ShoppingCartValidateDomainsConfig` | Domain update | REQUEST vars |
| `ShoppingCartValidateProductUpdate` | Product update | REQUEST vars |
| `ShoppingCartValidateUpgrade` | Upgrade validation | id, pid |
| `CartSubdomainValidation` | Subdomain check | subdomain, domain |
| `OverrideOrderNumberGeneration` | Pre-checkout | products, domains |
| `AfterShoppingCartCheckout` | Checkout complete | OrderID, ServiceIDs, AddonIDs, DomainIDs, PaymentMethod, InvoiceID, TotalDue |
| `ShoppingCartCheckoutCompletePage` | Complete page | orderid, invoiceid, amount |

### Order Management

| Hook | When | Parameters |
|------|------|------------|
| `AcceptOrder` | Order accepted | orderid |
| `CancelOrder` | Cancel requested | orderid |
| `DeleteOrder` | Deletion requested | orderid |
| `PendingOrder` | Set to pending | orderid |
| `FraudOrder` | Marked fraud | orderid |
| `OrderPaid` | First invoice paid | orderId, userId, invoiceId |
| `CancelAndRefundOrder` | Cancel + refund | orderid |

### Fraud

| Hook | When | Parameters |
|------|------|------------|
| `PreFraudCheck` | Before check | varies |
| `RunFraudCheck` | Module check | orderid, userid |
| `AfterFraudCheck` | After check | orderid, invoiceid, fraudresults, isfraud |
| `FraudCheckPassed` | Check passed | orderid, isfraud |
| `FraudCheckFailed` | Check failed | orderid, isfraud |
| `FraudCheckAwaitingUserInput` | Awaiting user | orderid, isfraud |

### Pricing Overrides

| Hook | When | Parameters |
|------|------|------------|
| `OrderProductPricingOverride` | Product price | key, pid, proddata |
| `OrderAddonPricingOverride` | Addon price | key, pid, addonid, proddata, serviceid |
| `OrderDomainPricingOverride` | Domain price | type, domain, eppcode, regperiod, dnsmanagement, etc. |
| `OrderProductUpgradeOverride` | Upgrade price | oldproductid, newproductid, days, price |
| `PreUpgradeCheckout` | Upgrade checkout | clientId, upgradeId, serviceId, amount |
| `PremiumPriceOverride` | Premium domain | domainName, tld, sld, register/transfer/renew prices |
| `PremiumPriceRecalculationOverride` | Premium recalc | domainName, tld, sld, renew price |

---

## Module Hooks (40 hooks)

### Provisioning Module Lifecycle

**Pre-execution (can abort):**
- `PreModuleCreate`, `PreModuleChangePackage`, `PreModuleChangePassword`
- `PreModuleCustom`, `PreModuleSuspend`, `PreModuleUnsuspend`, `PreModuleTerminate`, `PreModuleRenew`
- `PreModuleProvisionAddOnFeature`, `PreModuleDeprovisionAddOnFeature`
- `PreModuleSuspendAddOnFeature`, `PreModuleUnsuspendAddOnFeature`

**Post-execution success:**
- `AfterModuleCreate`, `AfterModuleChangePackage`, `AfterModuleChangePassword`
- `AfterModuleCustom`, `AfterModuleSuspend`, `AfterModuleUnsuspend`, `AfterModuleTerminate`
- `AfterModuleProvisionAddOnFeature`, `AfterModuleDeprovisionAddOnFeature`
- `AfterModuleSuspendAddOnFeature`, `AfterModuleUnsuspendAddOnFeature`

**Post-execution failure:**
- `AfterModuleCreateFailed`, `AfterModuleChangePackageFailed`, `AfterModuleChangePasswordFailed`
- `AfterModuleCustomFailed`, `AfterModuleSuspendFailed`, `AfterModuleUnsuspendFailed`, `AfterModuleTerminateFailed`
- `AfterModuleProvisionAddOnFeatureFailed`, `AfterModuleDeprovisionAddOnFeatureFailed`
- `AfterModuleSuspendAddOnFeatureFailed`, `AfterModuleUnsuspendAddOnFeatureFailed`

**Utility:**
- `OverrideModuleUsernameGeneration` | params
- `AddonModuleConfigSave`

All module hooks receive: `$params` (module parameters array).

---

## Domain Hooks (14 hooks)

| Hook | When | Parameters |
|------|------|------------|
| `DomainValidation` | Domain validation | sld, tld |
| `DomainEdit` | Admin edit | userid, domainid |
| `DomainDelete` | Deleted | userid, domainid |
| `DomainTransferCompleted` | Transfer complete | domainId, domain, registrar |
| `DomainTransferFailed` | Transfer failed | domainId, domain, registrar |
| `PreDomainRegister` | Pre-registration | domain |
| `PreDomainTransfer` | Pre-transfer | params |
| `PreRegistrarRegisterDomain` | Pre-register (can abort) | params → can return abortWithSuccess/abortWithError |
| `PreRegistrarRenewDomain` | Pre-renewal (can abort) | params |
| `PreRegistrarTransferDomain` | Pre-transfer (can abort) | params |
| `TopLevelDomainAdd` | TLD added | tld, supports* |
| `TopLevelDomainDelete` | TLD deleted | tld |
| `TopLevelDomainUpdate` | TLD config changed | modifiedTlds |
| `TopLevelDomainPricingUpdate` | TLD pricing | tld |

---

## Registrar Module Hooks (24 hooks)

**After hooks** (all receive: params, results, functionExists, functionSuccessful):
- `AfterRegistrarRegister`, `AfterRegistrarRegistration`, `AfterRegistrarRegistrationFailed`
- `AfterRegistrarRenew`, `AfterRegistrarRenewal`, `AfterRegistrarRenewalFailed`
- `AfterRegistrarTransfer`, `AfterRegistrarTransferFailed`
- `AfterRegistrarGetContactDetails`, `AfterRegistrarSaveContactDetails`
- `AfterRegistrarGetDNS`, `AfterRegistrarSaveDNS`
- `AfterRegistrarGetEPPCode`
- `AfterRegistrarGetNameservers`, `AfterRegistrarSaveNameservers`
- `AfterRegistrarRequestDelete`

**Pre hooks** (can return abort arrays):
- `PreRegistrarGetContactDetails`, `PreRegistrarSaveContactDetails`
- `PreRegistrarGetDNS`, `PreRegistrarSaveDNS`
- `PreRegistrarGetEPPCode`
- `PreRegistrarGetNameservers`, `PreRegistrarSaveNameservers`
- `PreRegistrarRequestDelete`

---

## Ticket Hooks (27 hooks)

### Ticket Lifecycle

| Hook | When |
|------|------|
| `TicketOpen` | User opens ticket |
| `TicketOpenAdmin` | Admin opens ticket |
| `TicketOpenValidation` | Submission validation |
| `TicketUserReply` | User replies |
| `TicketAdminReply` | Admin replies |
| `TicketClose` | Ticket closed |
| `TicketDelete` | Deleted |
| `TicketDeleteReply` | Reply deleted |
| `TicketMerge` | Tickets merged |
| `TicketSplit` | Replies split |

### Ticket Updates

| Hook | When |
|------|------|
| `TicketStatusChange` | Status changed |
| `TicketDepartmentChange` | Department changed |
| `TicketPriorityChange` | Priority changed |
| `TicketSubjectChange` | Subject changed |
| `TicketFlagged` | Flagged |
| `TicketAddNote` | Note added |

### Ticket System

| Hook | When |
|------|------|
| `TicketPiping` | Imported from email |
| `TransliterateTicketText` | Text import |
| `SubmitTicketAnswerSuggestions` | KB lookup |
| `AdminAreaViewTicketPage` | Admin views |
| `AdminAreaViewTicketPageSidebar` | Admin sidebar |
| `AdminSupportTicketPagePreTickets` | Pre-listing |
| `ClientAreaPageSubmitTicket` | Client submission |
| `ClientAreaPageSupportTickets` | Client overview |
| `ClientAreaPageViewTicket` | Client views |

---

## Service Hooks (5 hooks)

| Hook | When | Parameters |
|------|------|------------|
| `ServiceEdit` | Service edited (post) | userid, serviceid |
| `PreServiceEdit` | Before save | serviceid |
| `ServiceDelete` | Service deleted | userid, serviceid |
| `CancellationRequest` | Cancel requested | userid, relid, reason, type |
| `ServiceRecurringCompleted` | Recurring limit reached | serviceid, recurringinvoices |

---

## Addon Hooks (16 hooks)

| Hook | When |
|------|------|
| `AddonAdd` | Added to service |
| `AddonEdit` | Modified |
| `AddonConfig` | Configuration displayed |
| `AddonConfigSave` | Configuration saved |
| `AddonDeleted` | Deleted |
| `AddonActivation` | Becomes active |
| `AddonActivated` | Status → Active |
| `AddonRenewal` | Auto-renewed |
| `AddonSuspended` | Suspended |
| `AddonUnsuspended` | Unsuspended |
| `AddonTerminated` | Terminated |
| `AddonCancelled` | Cancelled |
| `AddonFraud` | Marked fraud |
| `AfterAddonUpgrade` | Upgrade processed |
| `LicensingAddonReissue` | License reissued |
| `LicensingAddonVerify` | Remote check |
| `ProductAddonDelete` | Product addon deleted |

All addon hooks receive: `id, userid, serviceid, addonid`.

---

## Admin Area Hooks (23 hooks)

### Page Hooks

| Hook | When |
|------|------|
| `AdminAreaPage` | Every admin page load |
| `AdminHomepage` | Admin homepage |
| `AdminAreaClientSummaryPage` | Client summary |
| `AdminAreaClientSummaryActionLinks` | Action links |
| `AdminAreaViewTicketPage` | Ticket view |
| `AdminAreaViewQuotePage` | Quote view |
| `ViewOrderDetailsPage` | Order details |
| `AdminPredefinedAddons` | Addon creation |

### Tab Hooks (display + save pairs)

| Display | Save |
|---------|------|
| `AdminClientProfileTabFields` | `AdminClientProfileTabFieldsSave` |
| `AdminClientServicesTabFields` | `AdminClientServicesTabFieldsSave` |
| `AdminClientDomainsTabFields` | `AdminClientDomainsTabFieldsSave` |
| `AdminProductConfigFields` | `AdminProductConfigFieldsSave` |

### Auth & Actions

| Hook | When |
|------|------|
| `AdminLogin` | Admin authenticates |
| `AdminLogout` | Admin logs out |
| `AuthAdmin` | Password auth |
| `AuthAdminApi` | API auth |
| `AdminClientFileUpload` | File uploaded |
| `AdminServiceEdit` | Service edit (post) |
| `PreAdminServiceEdit` | Service edit (pre) |
| `InvoiceCreationAdminArea` | Invoice in admin |

---

## Cron Hooks (7 hooks)

| Hook | When |
|------|------|
| `PreCronJob` | Before daily cron |
| `DailyCronJob` | End of daily cron |
| `DailyCronJobPreEmail` | After tasks, pre-email (return true to suppress) |
| `AfterCronJob` | After each cron call |
| `PopEmailCollectionCronCompleted` | POP collection done |
| `PreAutomationTask` | Before automation task |
| `PostAutomationTask` | After automation task |

---

## Support Tools Hooks (8 hooks)

### Announcements

| Hook | When |
|------|------|
| `AnnouncementAdd` | Announcement created |
| `AnnouncementEdit` | Announcement modified |

### Network Issues

| Hook | When |
|------|------|
| `NetworkIssueAdd` | Issue created |
| `NetworkIssueEdit` | Issue edited |
| `NetworkIssueClose` | Issue resolved |
| `NetworkIssueReopen` | Issue reopened |
| `NetworkIssueDelete` | Issue deleted |

### Other

| Hook | When |
|------|------|
| `FileDownload` | File downloaded |

---

## Affiliate Hooks

| Hook | When | Parameters |
|------|------|------------|
| `AffiliateActivation` | Affiliate activated | affid, userid |
| `AffiliateClickthru` | Link clicked | affiliateId |
| `AffiliateCommission` | Commission applied | affiliateId, referralId, serviceId, commissionAmount, clearingDate |
| `AffiliateWithdrawalRequest` | Withdrawal requested | affiliateId, userId, clientId, balance |
| `CalcAffiliateCommission` | Calculated | affid, relid, amount, commission |

---

## Everything Else Hooks (27 hooks)

### Email

| Hook | When |
|------|------|
| `EmailPreSend` | Before send | messagename, relid, mergefields |
| `EmailPreLog` | Before logging | userid, date, to, cc, bcc, subject, message, attachments |
| `EmailTplMergeFields` | Template editing | type |
| `PreEmailSendReduceRecipients` | Before client email | messagename, relid, recipients |

### Custom Fields

| Hook | When |
|------|------|
| `CustomFieldLoad` | Fields loaded | fieldid, relid, value |
| `CustomFieldSave` | Fields saved | fieldid, relid, value |

### Products & Services Admin

| Hook | When |
|------|------|
| `ProductEdit` | Product edited | — |
| `ProductDelete` | Product deleted | — |
| `ServerAdd` | Server added | — |
| `ServerEdit` | Server edited | — |
| `ServerDelete` | Server deleted | — |

### System

| Hook | When |
|------|------|
| `LogActivity` | Activity logged | description, user, userid, ipaddress |
| `IntelligentSearch` | Search completed | searchTerm, numResults |
| `LinkTracker` | link.php accessed | linkid |
| `FetchCurrencyExchangeRates` | Rates updated | USD, GBP values |

### Notifications

| Hook | When |
|------|------|
| `NotificationPreSend` | Before send | eventType, eventName, rule, hookParameters, notification |

### Payment

| Hook | When |
|------|------|
| `CCUpdate` | CC details stored | userid, cardtype, cardnum, cardcvv, expdate |
| `PayMethodMigration` | Legacy method migrated | client |

### Config Options Upgrade

| Hook | When |
|------|------|
| `AfterConfigOptionsUpgrade` | Upgrade processed | upgradeid |

### VAT

| Hook | When |
|------|------|
| `VatNumberVerification` | VAT verification | vatNumber |

---

## Return Values

Different hooks expect different returns:

### Template Variable Hooks

Return an associative array — keys become template variables:

```php
add_hook('ClientAreaPageHome', 1, function($vars) {
    return [
        'customMessage' => 'Welcome!',
        'featuredCount' => 5,
    ];
});
```

### Output Hooks

Return HTML string (appended to output):

```php
add_hook('ClientAreaHeadOutput', 1, function($vars) {
    return '<script>console.log("Hello");</script>';
});
```

### Abort Hooks

Some pre-hooks can abort the operation:

```php
add_hook('PreRegistrarRegisterDomain', 1, function($params) {
    if (someCondition()) {
        return [
            'abortWithError' => 'Registration not allowed',
        ];
    }
    // Or
    return [
        'abortWithSuccess' => 'Skipped successfully',
    ];
});
```

### Event Hooks

Most hooks are fire-and-forget — no return value needed:

```php
add_hook('InvoicePaid', 1, function($vars) {
    logActivity('Invoice paid: ' . $vars['invoiceid']);
    // No return
});
```

---

## Further Reading

- Official hook reference: [developers.whmcs.com/hooks-reference/](https://developers.whmcs.com/hooks-reference/)
- Hook index: [developers.whmcs.com/hooks/hook-index/](https://developers.whmcs.com/hooks/hook-index/)
- Class documentation: [classdocs.whmcs.com/9.0/](https://classdocs.whmcs.com/9.0/)
