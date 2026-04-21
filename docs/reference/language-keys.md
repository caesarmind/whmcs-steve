# Language Keys Reference

Complete reference of WHMCS language keys used in the Nexus theme. Over **2,470 unique language keys** are used across the theme, organized into logical groups by feature area.

## How Language Keys Work

```smarty
{* Basic usage *}
{lang key='loginbutton'}
{* Output: "Login" *}

{* With parameters *}
{lang key='copyrightFooterNotice' year=$date_year company=$companyname}

{* Nested keys (dot notation) *}
{lang key='clientHomePanels.productsAndServices'}

{* With modifier *}
{lang|addslashes key="markdown.title"}

{* Dynamic key construction *}
{lang key="emailPreferences."|cat:$emailType}
```

Language files are located at `/lang/english.php` (and other language codes). Values are defined as:

```php
$_LANG['loginbutton'] = 'Login';
$_LANG['clientHomePanels']['productsAndServices'] = 'Products & Services';
```

## Adding Custom Language Keys

Create an override file to add custom keys:

```php
// /lang/overrides/english.php
$_LANG['myCustom']['welcome'] = 'Welcome to our site!';
$_LANG['myCustom']['cta'] = 'Get Started';
```

Then use in templates:
```smarty
{lang key='myCustom.welcome'}
```

---

## Client Area Generic Keys (clientarea*)

Most commonly used across all client area pages. **~45 keys.**

| Key | Typical English |
|-----|----------------|
| `clientareaemail` | Email Address |
| `clientareapassword` | Password |
| `clientareafirstname` | First Name |
| `clientarealastname` | Last Name |
| `clientareacompanyname` | Company Name |
| `clientareaaddress1` | Address Line 1 |
| `clientareaaddress2` | Address Line 2 |
| `clientareacity` | City |
| `clientareastate` | State |
| `clientareapostcode` | Postcode / ZIP |
| `clientareacountry` | Country |
| `clientareaphonenumber` | Phone Number |
| `clientarealanguage` | Language |
| `clientareanavdetails` | My Details |
| `clientareasavechanges` | Save Changes |
| `clientareaerrors` | The following errors occurred |
| `clientareaviewdetails` | View Details |
| `clientareabacklink` | Back |
| `clientareahostingregdate` | Registration Date |
| `clientareahostingnextduedate` | Next Due Date |
| `clientareaaddonpricing` | Pricing |
| `clientareastatus` | Status |
| `clientareacontactsemails` | Email Preferences |

## Navigation Keys (nav*)

Main navigation labels.

| Key | Typical English |
|-----|----------------|
| `navservices` | Services |
| `navdomains` | Domains |
| `navinvoices` | Invoices |
| `navtickets` | Support Tickets |
| `navdomainsearch` | Domain Search |
| `notifications` | Notifications |
| `nonotifications` | No Notifications |
| `notificationsnone` | You have no notifications at this time |

## Authentication & Security (login*, password*, twoFactor*)

### Login

| Key | Typical English |
|-----|----------------|
| `loginbutton` | Login |
| `loginrememberme` | Remember Me |
| `forgotpw` | Forgot Password? |
| `userLogin.signInToContinue` | Sign in to continue |
| `userLogin.notRegistered` | Not registered yet? |
| `userLogin.createAccount` | Create an account |

### Password

| Key | Typical English |
|-----|----------------|
| `pwstrength` | Password Strength |
| `pwstrengthrating` | Password Strength |
| `pwdoesnotmatch` | Passwords do not match |
| `passwordtips` | Tips for a good password |
| `generatePassword.title` | Generate Password |
| `generatePassword.pwLength` | Password Length |
| `generatePassword.generatedPw` | Generated Password |
| `generatePassword.generateNew` | Generate New |
| `generatePassword.copyAndInsert` | Copy and Insert |
| `generatePassword.copy` | Copy |
| `generatePassword.lengthValidationError` | Invalid length |
| `generatePassword.btnLabel` | Generate |

### Two-Factor Authentication

| Key | Typical English |
|-----|----------------|
| `twoFactor.*` | Various 2FA-related strings |
| `loginWithBackupCode` | Login with backup code |
| `backupCodeCancel` | Cancel |

---

## Email Preferences (emailPreferences.*)

Dynamic keys constructed at runtime:

```smarty
{lang key="emailPreferences."|cat:$emailType}
```

Example keys:
- `emailPreferences.general`
- `emailPreferences.product`
- `emailPreferences.domain`
- `emailPreferences.invoice`
- `emailPreferences.support`
- `emailPreferences.affiliate`

---

## Payment Methods (paymentMethods.*, paymentMethodsManage.*)

**~70 keys total** for payment method management.

### paymentMethods.*

| Key | Typical English |
|-----|----------------|
| `paymentMethods.cardDescription` | Card Description |
| `paymentMethods.descriptionInput` | Description |
| `paymentMethods.expired` | Expired |
| `paymentmethod` | Payment Method |
| `paymentmethoddefault` | Use Default Payment Method |
| `defaultbillingcontact` | Default Billing Contact |

### paymentMethodsManage.*

| Key | Typical English |
|-----|----------------|
| `paymentMethodsManage.unsupportedCardType` | Unsupported card type |
| `paymentMethodsManage.cardNumberNotValid` | Invalid card number |
| `paymentMethodsManage.expiryDateNotValid` | Invalid expiry date |
| `paymentMethodsManage.cvcNumberNotValid` | Invalid CVC |
| `paymentMethodsManage.addNewBillingAddress` | Add New Billing Address |
| `paymentMethodsManage.optional` | (Optional) |

### Credit Card (creditcard*)

| Key | Typical English |
|-----|----------------|
| `creditcardcardnumber` | Card Number |
| `creditcardcardexpires` | Expiry Date |
| `creditcardcardstart` | Start Date |
| `creditcardcardissuenum` | Issue Number |
| `creditcardcvvnumber` | CVV/CVC |
| `creditcardcvvwhere` | Where is this? |
| `creditCardStore` | Store card securely |
| `creditcard3dsecure` | 3D Secure Verification |

---

## Billing & Financial

### Invoices

| Key | Typical English |
|-----|----------------|
| `billingAddress` | Billing Address |
| `invoicesbacktoclientarea` | Back to Client Area |
| `cancel` | Cancel |
| `submit` | Submit |
| `loading` | Loading... |

### Order & Checkout

| Key | Typical English |
|-----|----------------|
| `orderproduct` | Product |
| `orderdomain` | Domain |
| `orderdesc` | Description |
| `orderprice` | Price |
| `ordersubtotal` | Subtotal |
| `ordertotalduetoday` | Total Due Today |
| `orderpaymentmethod` | Payment Method |
| `orderpaymenttermonetime` | One Time |
| `orderpromotioncode` | Promotion Code |
| `orderpromovalidatebutton` | Validate Code |
| `orderdontusepromo` | Don't use promo |
| `ordercontinuebutton` | Continue |
| `ordertos` | Terms of Service |
| `ordertosagreement` | I accept the TOS |
| `orderregisterdomain` | Register Domain |
| `orderfree` | Free |

### orderForm.*

| Key | Typical English |
|-----|----------------|
| `orderForm.continueShopping` | Continue Shopping |
| `orderForm.checkout` | Checkout |
| `orderForm.required` | Required |
| `orderForm.qty` | Quantity |
| `orderForm.years` | years |
| `orderForm.year` | year |
| `orderForm.shortPerYear` | /yr |
| `orderForm.shortPerYears` | /yrs |
| `orderForm.additionalInformation` | Additional Information |

---

## Store & Shopping (store.*)

**~50 keys** for the store system.

| Key | Typical English |
|-----|----------------|
| `store.choosePaymentTerm` | Choose Payment Term |
| `store.chooseDomain` | Choose a Domain |
| `store.chooseExistingDomain` | Use an existing domain |
| `store.subOfExisting` | Subdomain of existing |
| `store.domainAlreadyOwned` | I already own this domain |
| `store.noDomain` | No domain |
| `store.noDomainRequired` | No domain required |
| `store.addToExistingPackage` | to add to existing package |
| `store.login` | Login |
| `store.eligible` | Eligible |

### Cart (cart.*)

| Key | Typical English |
|-----|----------------|
| `carttitle` | Shopping Cart |

---

## Domains (domain*, domains*)

**~40+ keys** for domain management.

| Key | Typical English |
|-----|----------------|
| `orderdomain` | Domain |
| `domainstatus` | Status |
| `domainsautorenew` | Auto Renew |
| `domainsExpiringSoon` | Expiring Soon |
| `domaincurrentlyunlocked` | Currently Unlocked |
| `domaincurrentlyunlockedexp` | Your domain is unlocked... |
| `domainautorenewstatus` | Auto Renew Status |
| `domainautorenewinfo` | Auto renew information |
| `domainautorenewrecommend` | We recommend auto renew |
| `domainsautorenewenable` | Enable Auto Renew |
| `domainsautorenewdisable` | Disable Auto Renew |
| `domainreglockstatus` | Registry Lock Status |
| `domainreglockinfo` | Registry lock info |
| `domainreglockrecommend` | We recommend registry lock |
| `domainreglockenable` | Enable Lock |
| `domainreglockdisable` | Disable Lock |
| `domainmassrenew` | Mass Renew |
| `domainmanagens` | Manage Nameservers |
| `domaincontactinfoedit` | Edit Contact Information |
| `domaincontactusexisting` | Use existing contact |
| `domaincontactchoose` | Choose Contact |
| `domaincontactprimary` | Primary Contact |
| `domaincontactusecustom` | Use Custom |
| `domainregnotavailable` | Not available |
| `domainrenewalsdays` | Renewal period |
| `domainstransfer` | Transfer |
| `domainTldCategory.*` | TLD category names |
| `transferYourDomain` | Transfer Your Domain |
| `transferExtend` | Transfer and extend |
| `secureYourDomain` | Secure your domain |
| `secureYourDomainShort` | Secure your domain |

### Domain Pricing

| Key | Typical English |
|-----|----------------|
| `pricing.browseExtByCategory` | Browse by category |
| `pricing.register` | Register |
| `pricing.transfer` | Transfer |
| `pricing.renewal` | Renewal |
| `pricing.noExtensionsDefined` | No extensions |
| `viewAllPricing` | View All Pricing |
| `gracePeriod` | Grace Period |
| `redemptionPeriod` | Redemption Period |

---

## SSL & Security

| Key | Typical English |
|-----|----------------|
| `sslinvalidlink` | Invalid SSL link |
| `sslserverinfo` | Server Information |
| `sslserverinfodetails` | Server details |
| `sslservertype` | Server Type |
| `ssl.selectWebserver` | Select Webserver |
| `sslcsr` | Certificate Signing Request |
| `ssladmininfo` | Administrative Information |
| `ssladmininfodetails` | Admin details |
| `organizationname` | Organization Name |
| `jobtitle` | Job Title |
| `jobtitlereqforcompany` | Required for companies |
| `ssl.selectValidation` | Select Validation Method |
| `ssl.emailMethod` | Email Validation |
| `ssl.dnsMethod` | DNS Validation |
| `ssl.fileMethod` | File Validation |
| `ssl.emailMethodDescription` | Email method details |
| `ssl.selectEmail` | Select Approver Email |
| `ssl.dnsMethodDescription` | DNS method details |
| `ssl.fileMethodDescription` | File method details |
| `ssl.nextSteps` | Next Steps |
| `ssl.emailSteps` | Email validation steps |
| `ssl.dnsSteps` | DNS validation steps |
| `ssl.fileSteps` | File validation steps |
| `ssl.type` | Type |
| `ssl.host` | Host |
| `ssl.value` | Value |
| `ssl.url` | URL |
| `sslconfigcomplete` | Configuration Complete |
| `sslnoconfigurationpossible` | No configuration available |
| `sslState.sslInactiveDomain` | Inactive Domain |
| `sslState.sslInactiveService` | Inactive Service |

---

## Support & Tickets (supporttickets*, kb*)

### Tickets

| Key | Typical English |
|-----|----------------|
| `createNewSupportRequest` | New Support Request |
| `supportticketsheader` | Support Tickets |
| `supportticketsclientname` | Name |
| `supportticketsclientemail` | Email |
| `supportticketsticketsubject` | Subject |
| `supportticketsdepartment` | Department |
| `supportticketsstatus` | Status |
| `supportticketsticketlastupdated` | Last Updated |
| `supportticketspriority` | Priority |
| `supportticketsticketurgencyhigh` | High |
| `supportticketsticketurgencymedium` | Medium |
| `supportticketsticketurgencylow` | Low |
| `supportticketsticketattachments` | Attachments |
| `supportticketsallowedextensions` | Allowed extensions |
| `supportticketsticketsubmit` | Submit Ticket |
| `supportticketsticketcreated` | Ticket Created |
| `supportticketsticketcreateddesc` | Ticket creation description |
| `relatedservice` | Related Service |
| `nosupportdepartments` | No departments available |
| `contactmessage` | Message |

### Ticket Feedback

| Key | Typical English |
|-----|----------------|
| `feedbackclosed` | Feedback Closed |
| `returnclient` | Return to Client Area |
| `feedbackdone` | Feedback Submitted |
| `feedbackprovided` | Thank you for your feedback |
| `feedbackthankyou` | Thank you |
| `feedbackreceived` | Feedback received |
| `feedbackdesc` | Feedback description |
| `feedbackclickreview` | Click to review |
| `feedbackopenedat` | Opened at |
| `feedbacklastreplied` | Last replied |
| `feedbackstaffinvolved` | Staff involved |
| `feedbacktotalduration` | Total duration |
| `feedbackpleaserate1` | Please rate |
| `feedbackhandled` | Handled |
| `feedbackworst` | Worst |
| `feedbackbest` | Best |
| `feedbackpleasecomment1` | Please comment |
| `feedbackimprove` | Improve |

### Knowledge Base

| Key | Typical English |
|-----|----------------|
| `clientHomeSearchKb` | Search Knowledge Base |
| `searchOurKnowledgebase` | Search our knowledge base |
| `search` | Search |
| `knowledgebasepopular` | Popular Articles |
| `knowledgebasenoarticles` | No articles |
| `kbsuggestions` | KB Suggestions |
| `kbsuggestionsexplanation` | Suggestion explanation |
| `kbviewingarticlestagged` | Viewing articles tagged |
| `knowledgebasearticles` | Articles |
| `knowledgebase.numArticle` | article |
| `knowledgebase.numArticles` | articles |
| `knowledgebaserelated` | Related Articles |
| `knowledgebasehelpful` | Was this helpful? |
| `knowledgebaseyes` | Yes |
| `knowledgebaseno` | No |
| `knowledgebaseArticleRatingThanks` | Thanks for rating |

### Downloads

| Key | Typical English |
|-----|----------------|
| `downloadssearch` | Search Downloads |
| `downloadspopular` | Popular Downloads |
| `downloadsnone` | No downloads |
| `downloadsfiles` | Files |
| `downloadsfilesize` | File Size |
| `restricted` | Restricted |

---

## Announcements

| Key | Typical English |
|-----|----------------|
| `announcementstitle` | Announcements |
| `announcementscontinue` | Continue Reading |
| `noannouncements` | No announcements |

---

## User Management (userManagement.*)

**~25 keys** for sub-user/multi-account functionality.

| Key | Typical English |
|-----|----------------|
| `loggedInAs` | Logged In As |
| `admin.returnToAdmin` | Return to Admin |
| `adminmasqueradingasclient` | Admin masquerading |
| `adminloggedin` | Admin Logged In |
| `returntoadminarea` | Return to Admin Area |
| `logoutandreturntoadminarea` | Logout and return to admin |

### remoteAuthn.*

Social/OAuth linking keys:

| Key | Typical English |
|-----|----------------|
| `remoteAuthn.provider` | Provider |
| `remoteAuthn.name` | Name |
| `remoteAuthn.emailAddress` | Email |
| `remoteAuthn.actions` | Actions |
| `remoteAuthn.noLinkedAccounts` | No linked accounts |
| `remoteAuthn.unavailable` | is unavailable |
| `remoteAuthn.error` | Error |
| `remoteAuthn.connectError` | Connection error |
| `remoteAuthn.completeSignIn` | Complete sign in |
| `remoteAuthn.redirecting` | Redirecting... |
| `remoteAuthn.success` | Success |
| `remoteAuthn.accountNowLinked` | Account linked |
| `remoteAuthn.linkInitiated` | Link initiated |
| `remoteAuthn.saveTimeByLinking` | Save time by linking |
| `remoteAuthn.mayHaveMultipleLinks` | May have multiple links |
| `remoteAuthn.titleSignUpVerb` | Sign Up |
| `remoteAuthn.titleOr` | or |
| `remoteAuthn.completeRegistrationForm` | Complete registration |
| `remoteAuthn.completeNewAccountForm` | Complete new account form |
| `remoteAuthn.linkedToAnotherClient` | Linked to another client |
| `remoteAuthn.alreadyLinkedToYou` | Already linked to you |
| `remoteAuthn.oneTimeAuthRequired` | One-time auth required |

---

## Affiliates (affiliates*)

**~20 keys** for affiliate program.

| Key | Typical English |
|-----|----------------|
| `affiliatesdisabled` | Affiliates Disabled |
| `affiliatesactivate` | Activate Affiliate |
| `affiliatesclicks` | Clicks |
| `affiliatessignups` | Signups |
| `affiliatesconversionrate` | Conversion Rate |
| `affiliatesreferallink` | Referral Link |
| `affiliatescommissionspending` | Pending Commissions |
| `affiliatescommissionsavailable` | Available Balance |
| `affiliateswithdrawn` | Withdrawn |
| `affiliatesrequestwithdrawal` | Request Withdrawal |
| `affiliateWithdrawalSummary` | Withdrawal Summary |
| `affiliatesreferals` | Referrals |
| `affiliatessignupdate` | Signup Date |
| `affiliatesamount` | Amount |
| `affiliatescommission` | Commission |
| `affiliatesstatus` | Status |
| `affiliateslinktous` | Link to us |
| `affiliatesignuptitle` | Sign Up as Affiliate |
| `affiliatesignupintro` | Join our affiliate program |
| `affiliatesignupinfo1` | Info 1 |
| `affiliatesignupinfo2` | Info 2 |
| `affiliatesignupinfo3` | Info 3 |

---

## Network & Server Status

| Key | Typical English |
|-----|----------------|
| `networkstatustitle` | Network Status |
| `networkstatusnone` | No issues |
| `networkissuesaware` | We are aware of issues |
| `networkissuesscheduled` | Scheduled maintenance |
| `networkissuesstatusopen` | Open |
| `networkissuesaffecting` | Affecting |
| `networkissuestypeserver` | Server |
| `networkissueslastupdated` | Last Updated |
| `networkIssues.http` | HTTP |
| `networkIssues.ftp` | FTP |
| `networkIssues.pop3` | POP3 |
| `networkIssues.affectingYou` | Affecting You |
| `serverstatustitle` | Server Status |
| `serverstatusheadingtext` | Current server status |
| `serverstatusphpinfo` | PHP Info |
| `serverstatusserverload` | Server Load |
| `serverstatusuptime` | Uptime |
| `serverstatusnoservers` | No servers |
| `servername` | Server Name |
| `learnmore` | Learn More |

---

## Homepage & Dashboard

| Key | Typical English |
|-----|----------------|
| `homepage.submitTicket` | Submit Ticket |
| `homepage.yourAccount` | Your Account |
| `homepage.manageServices` | Manage Services |
| `homepage.manageDomains` | Manage Domains |
| `homepage.supportRequests` | Support Requests |
| `homepage.makeAPayment` | Make a Payment |
| `howCanWeHelp` | How can we help? |
| `browseProducts` | Browse Products |
| `clientHomePanels.productsAndServices` | Products & Services |
| `knowledgebasetitle` | Knowledge Base |
| `downloadstitle` | Downloads |

---

## Tables & DataTables (table*)

| Key | Typical English |
|-----|----------------|
| `tableshowing` | Showing _START_ to _END_ of _TOTAL_ entries |
| `tableempty` | No entries |
| `tablefiltered` | (filtered from _MAX_ total entries) |
| `tablelength` | Show _MENU_ entries |
| `tableloading` | Loading... |
| `tableprocessing` | Processing... |
| `tablepagesfirst` | First |
| `tablepageslast` | Last |
| `tablepagesnext` | Next |
| `tablepagesprevious` | Previous |
| `tableviewall` | All |
| `norecordsfound` | No records found |

---

## UI & Common Actions

| Key | Typical English |
|-----|----------------|
| `save` | Save |
| `cancel` | Cancel |
| `close` | Close |
| `closewindow` | Close Window |
| `edit` | Edit |
| `delete` | Delete |
| `submit` | Submit |
| `continue` | Continue |
| `back` | Back |
| `yes` | Yes |
| `no` | No |
| `apply` | Apply |
| `more` | More |
| `copy` | Copy |
| `print` | Print |
| `loading` | Loading |
| `default` | Default |
| `none` | None |
| `success` | Success |
| `error` | Error |
| `changessavedsuccessfully` | Changes saved successfully |

---

## Page Title Keys

| Key | Typical English |
|-----|----------------|
| `contactus` | Contact Us |
| `clientregistertitle` | Client Registration |
| `registerCreateAccount` | Create Account |
| `registerCreateAccountOrder` | Create Account & Order |
| `chooselanguage` | Choose Language |
| `choosecurrency` | Choose Currency |
| `changeCurrency` | Change Currency |
| `copyrightFooterNotice` | Copyright {$year} {$company}. All rights reserved. |

---

## Error Page Keys

| Key | Typical English |
|-----|----------------|
| `errorPage.404.title` | 404 |
| `errorPage.404.subtitle` | Page not found |
| `errorPage.404.description` | The page you're looking for doesn't exist |
| `errorPage.404.home` | Home |
| `errorPage.404.submitTicket` | Submit Ticket |

---

## OAuth

| Key | Typical English |
|-----|----------------|
| `oauth.currentlyLoggedInAs` | Currently logged in as {$firstName} {$lastName} |
| `oauth.notYou` | Not you? |
| `oauth.returnToApp` | Return to {$appName} |
| `oauth.copyrightFooter` | © {$dateYear} {$companyName} |

---

## Email Verification

| Key | Typical English |
|-----|----------------|
| `verifyEmailAddress` | Please verify your email address |
| `emailSent` | Email Sent |
| `resendEmail` | Resend Email |

---

## Fraud / Validation

| Key | Typical English |
|-----|----------------|
| `fraud.furtherValShort` | Further validation required |
| `fraud.submitDocs` | Submit Documents |

---

## Sitejet / Builder

| Key | Typical English |
|-----|----------------|
| `sitejetBuilder.chooseWebsite` | Choose Website |
| `sitejetBuilder.editWebsite` | Edit Website |
| `errorButTryAgain` | Error. Please try again. |

---

## Notifications

| Key | Typical English |
|-----|----------------|
| `emailMarketing.joinOurMailingList` | Join our mailing list |

---

## Markdown

| Key | Typical English |
|-----|----------------|
| `markdown.title` | Markdown Guide |
| `markdown.saved` | Saved |
| `markdown.saving` | Saving... |

---

## Captcha

| Key | Typical English |
|-----|----------------|
| `captchaverify` | Please verify you are human |

---

## Upgrades

| Key | Typical English |
|-----|----------------|
| `upgradeerroroverdueinvoice` | Overdue invoice |
| `upgradeexistingupgradeinvoice` | Existing upgrade invoice |
| `upgradeNotPossible` | Upgrade not possible |
| `upgradechoosepackage` | Choose Package |
| `upgradecurrentconfig` | Current Config |
| `upgradenewconfig` | New Config |
| `upgradenochange` | No Change |
| `upgradedowngradechooseproduct` | Choose Product |
| `upgradechooseconfigoptions` | Choose Config Options |
| `upgradeservice.serviceBeingUpgraded` | Service being upgraded |
| `upgradeservice.chooseNew` | Choose New |
| `upgradeservice.currentProduct` | Current Product |
| `upgradeservice.recommended` | Recommended |
| `upgradeservice.select` | Select |
| `submitticketdescription` | Description |
| `recurringpromodesc` | Recurring promo |
| `upgradeproductlogic` | Upgrade logic |
| `days` | days |
| `fromJust` | from just |
| `forJust` | for just |

---

## Finding Language Keys

**Strategy for finding the right key:**

1. **Search Nexus templates**: `grep -r "lang key" /path/to/nexus/` for real usage patterns
2. **Check language file**: `/lang/english.php` contains all available keys
3. **Use browser inspector**: View page HTML to see rendered strings
4. **Add `{debug}` to template**: Shows all available variables (but not lang keys specifically)

**Creating hierarchical keys:**

WHMCS supports both flat and hierarchical keys:

```php
// Flat
$_LANG['clientareaemail'] = 'Email Address';

// Hierarchical (dot notation in templates)
$_LANG['clientHomePanels']['productsAndServices'] = 'Products & Services';
// Used as: {lang key='clientHomePanels.productsAndServices'}
```

---

## Language Key Parameters

Some keys accept named parameters:

```php
$_LANG['copyrightFooterNotice'] = 'Copyright {year} {company}. All rights reserved.';
```

Usage:
```smarty
{lang key='copyrightFooterNotice' year=$date_year company=$companyname}
```

Parameter placeholders in the language file use `{paramName}` syntax.
