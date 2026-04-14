# Template Variables Reference

### Global Variables (Available on Every Page)

#### Site Configuration

| Variable | Type | Description |
|----------|------|-------------|
| `{$companyname}` | string | Configured company name |
| `{$logo}` | string | Logo path |
| `{$assetLogoPath}` | string | Theme logo asset path |
| `{$systemurl}` | string | WHMCS system URL (SSL or non-SSL) |
| `{$systemsslurl}` | string | Configured SSL URL |
| `{$systemNonSSLURL}` | string | Configured non-SSL URL |
| `{$WEB_ROOT}` | string | Base WHMCS URL |

#### Asset Paths

| Variable | Type | Description |
|----------|------|-------------|
| `{$BASE_PATH_CSS}` | string | Common CSS assets path |
| `{$BASE_PATH_FONTS}` | string | Common fonts path |
| `{$BASE_PATH_IMG}` | string | Common images path |
| `{$BASE_PATH_JS}` | string | Common JavaScript path |
| `{$versionHash}` | string | Cache-busting version hash |

#### Client & Session

| Variable | Type | Description |
|----------|------|-------------|
| `{$loggedin}` | boolean | Whether a user is logged in |
| `{$client}` | object/null | Logged-in client object |
| `{$client.companyname}` | string | Client company name |
| `{$client.fullName}` | string | Client full name |
| `{$client.address1}` | string | Client address |
| `{$token}` | string | CSRF token for POST forms |
| `{$adminLoggedIn}` | boolean | Whether an admin is logged in |
| `{$adminMasqueradingAsClient}` | boolean | Admin viewing as client |

#### Page Information

| Variable | Type | Description |
|----------|------|-------------|
| `{$filename}` | string | Requested file base name |
| `{$templatefile}` | string | Current template file name |
| `{$pagetitle}` | string | Current page title |
| `{$template}` | string | Active theme directory name |
| `{$charset}` | string | Character set (usually UTF-8) |
| `{$language}` | string | Current display language |
| `{$breadcrumb}` | array | Breadcrumb items (link, label) |

#### Navigation Objects

| Variable | Type | Description |
|----------|------|-------------|
| `{$primaryNavbar}` | MenuItem | Primary navigation menu tree |
| `{$secondaryNavbar}` | MenuItem | Secondary navigation menu tree |
| `{$primarySidebar}` | MenuItem | Primary sidebar menu tree |
| `{$secondarySidebar}` | MenuItem | Secondary sidebar menu tree |

#### Date

| Variable | Type | Description |
|----------|------|-------------|
| `{$date_day}` | string | Current day |
| `{$date_month}` | string | Current month |
| `{$date_year}` | string | Current year |
| `{$todaysdate}` | string | Current date formatted |

#### Localization

| Variable | Type | Description |
|----------|------|-------------|
| `{$locales}` | array | Available locales |
| `{$activeLocale}` | object | Current locale |
| `{$activeLocale.countryCode}` | string | Current country code |
| `{$activeLocale.localisedName}` | string | Locale display name |
| `{$currencies}` | array | Available currencies |
| `{$activeCurrency}` | object | Current currency |
| `{$activeCurrency.id}` | int | Currency ID |
| `{$activeCurrency.code}` | string | Currency code (USD, EUR) |
| `{$activeCurrency.prefix}` | string | Currency symbol ($, etc.) |
| `{$languagechangeenabled}` | boolean | Whether language switching is enabled |

#### System Outputs

| Variable | Type | Description |
|----------|------|-------------|
| `{$headoutput}` | string | System-generated head HTML |
| `{$headeroutput}` | string | System-generated header HTML |
| `{$footeroutput}` | string | System-generated footer JS/HTML |
| `{$captcha}` | object | Captcha configuration object |
| `{$cartitemcount}` | int | Shopping cart item count |

#### Feature Flags

| Variable | Type | Description |
|----------|------|-------------|
| `{$registerdomainenabled}` | boolean | Domain registration enabled |
| `{$transferdomainenabled}` | boolean | Domain transfer enabled |
| `{$acceptTOS}` | boolean | TOS acceptance required |
| `{$tosURL}` | string | Terms of service URL |
| `{$condlinks.affiliates}` | boolean | Affiliate system enabled |
| `{$phoneNumberInputStyle}` | string | Phone number input style |

#### Footer

| Variable | Type | Description |
|----------|------|-------------|
| `{$socialAccounts}` | array | Social media accounts |
| `{$currentpagelinkback}` | string | Current page URL for lang/currency form |

### Page-Specific Variables

#### `homepage.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$productGroups}` | collection | Product group objects |
| `{$productGroup->name}` | string | Group name |
| `{$productGroup->tagline}` | string | Group tagline |
| `{$productGroup->getRoutePath()}` | string | Group URL |
| `{$numberOfDomains}` | int | Number of domains |
| `{$featuredTlds}` | array | Featured TLD info |
| `{$sitejetServices}` | array | Sitejet services for homepage panel |

#### `login.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$captcha}` | object | Captcha object |
| `{$captchaForm}` | string | Captcha form identifier |
| `{$linkableProviders}` | array | Social login providers |

#### `clientareahome.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$clientsstats}` | array | Client statistics |
| `{$clientsstats.productsnumactive}` | int | Active products count |
| `{$clientsstats.numactivedomains}` | int | Active domains count |
| `{$clientsstats.numactivetickets}` | int | Active tickets count |
| `{$clientsstats.numunpaidinvoices}` | int | Unpaid invoices count |
| `{$clientsstats.numdomains}` | int | Total domains |
| `{$clientsstats.isAffiliate}` | boolean | Is affiliate |
| `{$clientsstats.numaffiliatesignups}` | int | Affiliate signups |
| `{$clientsstats.numquotes}` | int | Quotes count |
| `{$clientAlerts}` | array | Client alert notifications |
| `{$panels}` | collection | Dashboard panel objects |
| `{$addons_html}` | array | Addon HTML outputs |
| `{$captchaError}` | string | Captcha error message |

#### `clientareaproducts.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$services}` | array | Service items |
| `{$service.id}` | int | Service ID |
| `{$service.product}` | string | Product name |
| `{$service.domain}` | string | Associated domain |
| `{$service.amount}` | string | Formatted amount |
| `{$service.amountnum}` | float | Numeric amount |
| `{$service.billingcycle}` | string | Billing cycle text |
| `{$service.nextduedate}` | string | Next due date |
| `{$service.normalisedNextDueDate}` | string | Sortable date |
| `{$service.status}` | string | Status code |
| `{$service.statustext}` | string | Status display text |
| `{$service.isActive}` | boolean | Is active |
| `{$service.sslStatus}` | object/null | SSL status info |
| `{$orderby}` | string | Sort column |
| `{$sort}` | string | Sort direction |

#### `clientareaproductdetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$id}` | int | Service/product ID |
| `{$type}` | string | Service type |
| `{$product}` | string | Product name |
| `{$groupname}` | string | Product group name |
| `{$domain}` | string | Associated domain |
| `{$status}` | string | Service status |
| `{$rawstatus}` | string | Raw status code |
| `{$regdate}` | string | Registration date |
| `{$firstpaymentamount}` | string | First payment amount |
| `{$recurringamount}` | string | Recurring amount |
| `{$billingcycle}` | string | Billing cycle |
| `{$nextduedate}` | string | Next due date |
| `{$paymentmethod}` | string | Payment method name |
| `{$suspendreason}` | string | Suspension reason |
| `{$dedicatedip}` | string | Dedicated IP address |
| `{$assignedips}` | string | Assigned IPs (newline-separated) |
| `{$ns1}` / `{$ns2}` | string | Nameservers |
| `{$serverdata.*}` | array | Server data (hostname, ip, etc.) |
| `{$diskpercent}` | int | Disk usage percentage |
| `{$diskusage}` | string | Disk usage amount |
| `{$disklimit}` | string | Disk limit |
| `{$bwpercent}` | int | Bandwidth usage percentage |
| `{$bwusage}` | string | Bandwidth usage |
| `{$bwlimit}` | string | Bandwidth limit |
| `{$lastupdate}` | string | Last usage update time |
| `{$configurableoptions}` | array | Configurable option details |
| `{$customfields}` | array | Custom fields |
| `{$downloads}` | array | Available downloads |
| `{$addons}` | array | Active addons |
| `{$addonsavailable}` | array | Available addon purchases |
| `{$moduleclientarea}` | string | Module client area HTML |
| `{$hookOutput}` | string | Hook output HTML |
| `{$tplOverviewTabOutput}` | string | Overview tab content |
| `{$pendingcancellation}` | boolean | Has pending cancellation |
| `{$unpaidInvoice}` | object/null | Unpaid invoice info |
| `{$unpaidInvoiceOverdue}` | boolean | Invoice is overdue |
| `{$showRenewServiceButton}` | boolean | Show renewal button |
| `{$showcancelbutton}` | boolean | Show cancel button |
| `{$packagesupgrade}` | boolean | Upgrades available |
| `{$quantity}` | int | Service quantity |
| `{$quantitySupported}` | boolean | Quantity is supported |
| `{$sslStatus}` | object | SSL status (getImagePath, getTooltipContent, getClass) |
| `{$modulecustombuttonresult}` | string | Custom button result message |
| `{$modulechangepwresult}` | string | Password change result |
| `{$modulechangepasswordmessage}` | string | Password change message |

#### `clientareadomains.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$domains}` | array | Domain items |
| `{$domain.id}` | int | Domain ID |
| `{$domain.domain}` | string | Domain name |
| `{$domain.registrationdate}` | string | Registration date |
| `{$domain.normalisedRegistrationDate}` | string | Sortable reg date |
| `{$domain.nextduedate}` | string | Next due date |
| `{$domain.autorenew}` | boolean | Auto-renew enabled |
| `{$domain.statusClass}` | string | CSS status class |
| `{$domain.statustext}` | string | Status text |
| `{$domain.sslStatus}` | object/null | SSL status |
| `{$domain.isActive}` | boolean | Is active |
| `{$domain.expiringSoon}` | boolean | Expiring soon flag |
| `{$warnings}` | string | Warning messages |
| `{$allowrenew}` | boolean | Renewal allowed |

#### `clientareadomaindetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$domain}` | string | Domain name |
| `{$domainid}` | int | Domain ID |
| `{$status}` | string | Domain status |
| `{$firstpaymentamount}` | string | First payment |
| `{$registrationdate}` | string | Registration date |
| `{$registrationperiod}` | int | Registration period years |
| `{$recurringamount}` | string | Recurring amount |
| `{$nextduedate}` | string | Next due date |
| `{$paymentmethod}` | string | Payment method |
| `{$lockstatus}` | string | Lock status ("unlocked" / "locked") |
| `{$autorenew}` | boolean | Auto-renew enabled |
| `{$canDomainBeManaged}` | boolean | Domain can be managed |
| `{$managementoptions}` | array | Management capabilities |
| `{$managementoptions.nameservers}` | boolean | NS management available |
| `{$managementoptions.contacts}` | boolean | Contact editing available |
| `{$managementoptions.locking}` | boolean | Lock management available |
| `{$defaultns}` | array | Default nameservers |
| `{$nameservers}` | array | Current nameservers [1-5] |
| `{$renew}` | boolean | Renewal available |
| `{$registrarclientarea}` | string | Registrar-specific HTML |
| `{$addons}` | array | Domain addons |
| `{$addonstatus}` | array | Addon statuses |
| `{$addonspricing}` | array | Addon pricing info |
| `{$registrarcustombuttonresult}` | string | Registrar button result |
| `{$changeAutoRenewStatusSuccessful}` | boolean | Auto-renew toggle success |
| `{$releaseDomainSuccessful}` | boolean | Domain release success |
| `{$systemStatus}` | string | System status |
| `{$alerts}` | array | Domain alerts |

#### `clientareadetails.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$clientfirstname}` | string | Client first name |
| `{$clientlastname}` | string | Client last name |
| `{$clientcompanyname}` | string | Company name |
| `{$clientemail}` | string | Email address |
| `{$clientaddress1}` | string | Address line 1 |
| `{$clientaddress2}` | string | Address line 2 |
| `{$clientcity}` | string | City |
| `{$clientstate}` | string | State |
| `{$clientpostcode}` | string | Postal code |
| `{$clientphonenumber}` | string | Phone number |
| `{$clientcountriesdropdown}` | string | Pre-rendered country dropdown |
| `{$clientLanguage}` | string | Client language preference |
| `{$clientTaxId}` | string | Tax ID |
| `{$uneditablefields}` | array | Fields that cannot be edited |
| `{$optionalFields}` | array | Fields that are optional |
| `{$paymentmethods}` | array | Available payment methods |
| `{$defaultpaymentmethod}` | string | Default payment method |
| `{$contacts}` | array | Client contacts |
| `{$billingcid}` | int | Default billing contact ID |
| `{$languages}` | array | Available languages |
| `{$customfields}` | array | Custom field definitions |
| `{$emailPreferencesEnabled}` | boolean | Email preferences enabled |
| `{$emailPreferences}` | array | Email preference settings |
| `{$showTaxIdField}` | boolean | Show tax ID field |
| `{$taxIdLabel}` | string | Tax ID field label key |
| `{$showMarketingEmailOptIn}` | boolean | Show marketing opt-in |
| `{$marketingEmailOptIn}` | boolean | Currently opted in |
| `{$marketingEmailOptInMessage}` | string | Opt-in message |
| `{$accountDetailsExtraFields}` | array | Extra fields for account |
| `{$successful}` | boolean | Form save successful |
| `{$errormessage}` | string | Error message HTML |

#### `clientregister.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$registrationDisabled}` | boolean | Registration is disabled |
| `{$remote_auth_prelinked}` | boolean | Pre-linked via OAuth |
| `{$clientfirstname}` | string | Pre-filled first name |
| `{$clientlastname}` | string | Pre-filled last name |
| `{$clientemail}` | string | Pre-filled email |
| `{$clientphonenumber}` | string | Pre-filled phone |
| `{$clientcompanyname}` | string | Pre-filled company |
| `{$clientaddress1}` | string | Pre-filled address |
| `{$clientcity}` | string | Pre-filled city |
| `{$clientstate}` | string | Pre-filled state |
| `{$clientpostcode}` | string | Pre-filled postcode |
| `{$clientcountry}` | string | Pre-filled country |
| `{$clientcountries}` | array | Available countries |
| `{$defaultCountry}` | string | Default country code |
| `{$password}` | string | Pre-filled password |
| `{$securityquestions}` | array | Security questions |
| `{$securityqid}` | int | Selected security question ID |
| `{$optionalFields}` | array | Optional field names |
| `{$accountDetailsExtraFields}` | array | Extra registration fields |
| `{$accepttos}` | boolean | TOS acceptance required |
| `{$tosurl}` | string | TOS URL |
| `{$pwStrengthErrorThreshold}` | int | Password strength error threshold |
| `{$pwStrengthWarningThreshold}` | int | Password strength warning threshold |
| `{$showTaxIdField}` | boolean | Show tax ID field |
| `{$taxLabel}` | string | Tax ID label |
| `{$clientTaxId}` | string | Pre-filled tax ID |

#### `supportticketslist.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$tickets}` | array | Ticket items |
| `{$ticket.tid}` | string | Ticket ID |
| `{$ticket.c}` | string | Ticket access code |
| `{$ticket.department}` | string | Department name |
| `{$ticket.subject}` | string | Ticket subject |
| `{$ticket.status}` | string | Status text |
| `{$ticket.statusClass}` | string | CSS status class |
| `{$ticket.statusColor}` | string/null | Custom status color |
| `{$ticket.lastreply}` | string | Last reply date |
| `{$ticket.normalisedLastReply}` | string | Sortable date |
| `{$ticket.unread}` | boolean | Has unread replies |

#### `viewticket.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$tid}` | string | Ticket ID number |
| `{$c}` | string | Ticket access key |
| `{$subject}` | string | Ticket subject |
| `{$descreplies}` | array | Ticket messages/replies |
| `{$reply.admin}` | boolean | Is admin reply |
| `{$reply.requestor}` | object | Requestor info |
| `{$reply.requestor->getName()}` | string | Requestor name |
| `{$reply.requestor->getType()}` | string | Requestor type |
| `{$reply.requestor->getNormalisedType()}` | string | CSS-safe type |
| `{$reply.date}` | string | Reply date |
| `{$reply.message}` | string | Reply message (HTML) |
| `{$reply.attachments}` | array | Reply attachments |
| `{$reply.attachments_removed}` | boolean | Attachments were removed |
| `{$reply.rating}` | int | Reply rating |
| `{$reply.id}` | int | Reply ID |
| `{$reply.ipaddress}` | string | Reply IP address |
| `{$showCloseButton}` | boolean | Show close ticket button |
| `{$closedticket}` | boolean | Ticket is closed |
| `{$invalidTicketId}` | boolean | Invalid ticket ID |
| `{$replyname}` | string | Reply form name |
| `{$replyemail}` | string | Reply form email |
| `{$replymessage}` | string | Reply form message |
| `{$allowedfiletypes}` | string | Allowed file types |
| `{$uploadMaxFileSize}` | int | Max upload size |
| `{$ratingenabled}` | boolean | Rating system enabled |

#### `announcements.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$announcements}` | array | Announcement items |
| `{$announcement.id}` | int | Announcement ID |
| `{$announcement.title}` | string | Title |
| `{$announcement.text}` | string | Full HTML text |
| `{$announcement.summary}` | string | Summary text |
| `{$announcement.timestamp}` | int | Unix timestamp |
| `{$announcement.urlfriendlytitle}` | string | URL slug |
| `{$announcement.editLink}` | string/null | Admin edit link |
| `{$carbon}` | object | Carbon date helper |
| `{$pagination}` | array | Pagination items |
| `{$prevpage}` | boolean | Has previous page |
| `{$nextpage}` | boolean | Has next page |
| `{$announcementsFbRecommend}` | boolean | Facebook recommend enabled |

#### `invoice-payment.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$invoiceid}` | int | Invoice ID |
| `{$showRemoteInput}` | boolean | Show remote payment input |
| `{$remoteInput}` | string | Remote payment HTML |
| `{$hasRemoteInput}` | boolean | Has remote input configured |
| `{$submitLocation}` | string | Form submit URL |
| `{$cardOrBank}` | string | Payment type ("card" or "bank") |
| `{$gateway}` | string | Payment gateway name |
| `{$servedOverSsl}` | boolean | Page served over SSL |
| `{$errormessage}` | string | Error message |

#### `store/order.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$product}` | object | Product object |
| `{$product->id}` | int | Product ID |
| `{$product->name}` | string | Product name |
| `{$product->description}` | string | Product description |
| `{$product->pricing()}` | object | Pricing object |
| `{$product->productKey}` | string | Product key identifier |
| `{$requireDomain}` | boolean | Domain required |
| `{$allowSubdomains}` | boolean | Subdomains allowed |
| `{$domains}` | array | Existing client domains |
| `{$selectedDomain}` | string | Pre-selected domain |
| `{$customDomain}` | string | Custom domain input |
| `{$requestedCycle}` | string | Requested billing cycle |
| `{$configurationFields}` | array | Config fields |
| `{$configFieldErrors}` | array | Config field errors |
| `{$upsellProduct}` | object/null | Upsell product |
| `{$promotion}` | object/null | Promotion data |

#### `store/dynamic/index.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$pageData}` | object | Dynamic page configuration |
| `{$pageData->branding}` | object | Branding colors |
| `{$pageData->branding->primaryColor}` | string | Primary color |
| `{$pageData->branding->secondaryColor}` | string | Secondary color |
| `{$pageData->branding->accentColor}` | string | Accent color |
| `{$pageData->branding->textColor}` | string | Text color |
| `{$pageData->branding->backgroundColor}` | string | Background color |
| `{$pageData->blocks->items}` | collection | Content blocks |
| `{$storeConfig->typography->p}` | string | Body font family |
| `{$products}` | array | Products for store |

#### `affiliates.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$inactive}` | boolean | Affiliate is inactive |
| `{$visitors}` | int | Total visitors |
| `{$signups}` | int | Total signups |
| `{$conversionrate}` | string | Conversion rate |
| `{$referrallink}` | string | Referral link URL |
| `{$pendingcommissions}` | string | Pending commissions |
| `{$balance}` | string | Available balance |
| `{$withdrawn}` | string | Total withdrawn |
| `{$withdrawlevel}` | string | Minimum withdrawal |
| `{$affiliatePayoutMinimum}` | string | Payout minimum |
| `{$referrals}` | array | Referral list |
| `{$affiliatelinkscode}` | string | HTML link code |
| `{$withdrawrequestsent}` | boolean | Withdrawal requested |

#### `serverstatus.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$opencount}` | int | Open issue count |
| `{$scheduledcount}` | int | Scheduled issue count |
| `{$servers}` | array | Server list |
| `{$server.name}` | string | Server name |
| `{$server.phpinfourl}` | string | PHP info URL |
| `{$issues}` | array | Network issues |
| `{$issue.title}` | string | Issue title |
| `{$issue.status}` | string | Issue status |
| `{$issue.rawPriority}` | string | Priority (Critical/Major/Minor) |
| `{$issue.priority}` | string | Priority display text |
| `{$issue.server}` | string | Affected server |
| `{$issue.affecting}` | string | Affected services |
| `{$issue.type}` | string | Issue type |
| `{$issue.startdate}` | string | Start date |
| `{$issue.enddate}` | string | End date |
| `{$issue.lastupdate}` | string | Last update |
| `{$issue.clientaffected}` | boolean | Current client affected |
| `{$issue.description}` | string | Issue description |
| `{$noissuesmsg}` | string | No issues message |

#### `upgrade.tpl` / `upgrade-configure.tpl` / `upgradesummary.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$overdueinvoice}` | boolean | Has overdue invoice |
| `{$existingupgradeinvoice}` | boolean | Has existing upgrade invoice |
| `{$upgradenotavailable}` | boolean | Upgrade not available |
| `{$upgradeinvalid}` | boolean | Invalid upgrade |
| `{$upgradeinvaliderror}` | string | Invalid upgrade error |
| `{$id}` | int | Service/product ID |
| `{$type}` | string | "package" or "configoptions" |
| `{$groupname}` | string | Product group |
| `{$productname}` | string | Current product |
| `{$domain}` | string | Service domain |
| `{$upgradepackages}` | array | Available upgrade packages |
| `{$configoptions}` | array | Configurable options |
| `{$serviceToBeUpgraded}` | object | Service being upgraded |
| `{$upgradeProducts}` | array | Available upgrade products |
| `{$recommendedProductKey}` | string | Recommended product key |
| `{$permittedBillingCycles}` | object | Permitted billing cycles |
| `{$upgrades}` | array | Upgrade summary items |
| `{$subtotal}` | string | Subtotal |
| `{$discount}` | string | Discount |
| `{$tax}` / `{$tax2}` | string | Tax amounts |
| `{$total}` | string | Total |
| `{$promocode}` | string | Promo code |
| `{$promodesc}` | string | Promo description |
| `{$gateways}` | array | Payment gateways |
| `{$selectedgateway}` | string | Selected gateway |
| `{$allowgatewayselection}` | boolean | Gateway selection allowed |

#### `domain-pricing.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$featuredTlds}` | array | Featured TLD list |
| `{$tldCategories}` | array | TLD category filters |
| `{$pricing}` | array | TLD pricing data |
| `{$extension}` | string | TLD extension name |
| `{$data.group}` | string | TLD group |
| `{$data.categories}` | array | TLD categories |
| `{$data.register}` | object/null | Registration pricing |
| `{$data.transfer}` | object/null | Transfer pricing |
| `{$data.renew}` | object/null | Renewal pricing |
| `{$data.grace_period}` | string | Grace period info |
| `{$data.redemption_period}` | string | Redemption period info |

#### `configuressl-stepone.tpl` / `configuressl-steptwo.tpl` / `configuressl-complete.tpl`

| Variable | Type | Description |
|----------|------|-------------|
| `{$cert}` | string | Certificate ID |
| `{$status}` | string | Certificate status |
| `{$webservertypes}` | array | Web server type options |
| `{$servertype}` | string | Selected server type |
| `{$csr}` | string | CSR content |
| `{$additionalfields}` | array | Additional field groups |
| `{$serviceid}` | int | Service ID |
| `{$approvalMethods}` | array | Validation methods (email, dns, file) |
| `{$approveremails}` | array | Approval email addresses |
| `{$authData}` | object/null | Authentication data |
| `{$authData->methodNameConstant()}` | string | Auth method (emailauth/dnsauth/fileauth) |
| `{$authData->email}` | string | Approval email |
| `{$authData->host}` | string | DNS host |
| `{$authData->value}` | string | DNS value |
| `{$authData->filePath()}` | string | File validation path |
| `{$authData->contents}` | string | File validation contents |

#### User & Account Management Pages

| Variable | Page | Description |
|----------|------|-------------|
| `{$user->firstName}` | user-profile.tpl | User first name |
| `{$user->lastName}` | user-profile.tpl | User last name |
| `{$user->email}` | user-profile.tpl | User email |
| `{$user->emailVerified()}` | user-profile.tpl | Email verified status |
| `{$user->hasSecurityQuestion()}` | user-security.tpl | Has security question |
| `{$user->hasTwoFactorAuthEnabled()}` | user-security.tpl | 2FA enabled |
| `{$twoFactorAuthAvailable}` | user-security.tpl | 2FA available |
| `{$twoFactorAuthEnabled}` | user-security.tpl | 2FA currently enabled |
| `{$twoFactorAuthRequired}` | user-security.tpl | 2FA required |
| `{$isSsoEnabled}` | clientareasecurity.tpl | SSO enabled |
| `{$showSsoSetting}` | clientareasecurity.tpl | Show SSO toggle |
| `{$invite}` | user-invite-accept.tpl | Invite object |
| `{$invite->getClientName()}` | user-invite-accept.tpl | Inviting client name |
| `{$invite->getSenderName()}` | user-invite-accept.tpl | Invite sender name |
| `{$invite->token}` | user-invite-accept.tpl | Invite token |
| `{$accounts}` | user-switch-account.tpl | Account list |
| `{$account->displayName}` | user-switch-account.tpl | Account display name |
| `{$account->status}` | user-switch-account.tpl | Account status |
| `{$account->authedUserIsOwner()}` | user-switch-account.tpl | User is owner |
| `{$challenge}` | two-factor-challenge.tpl | 2FA challenge HTML |
| `{$usingBackup}` | two-factor-challenge.tpl | Using backup code |
| `{$newbackupcode}` | two-factor-challenge.tpl | New backup code |
| `{$newBackupCode}` | two-factor-new-backup-code.tpl | Generated backup code |
| `{$innerTemplate}` | password-reset-container.tpl | Sub-template name |
| `{$securityQuestion}` | password-reset-security-prompt.tpl | Security question text |
| `{$users}` | account-user-management.tpl | User list |
| `{$invites}` | account-user-management.tpl | Pending invites |
| `{$permissions}` | account-user-permissions.tpl | Permission definitions |
| `{$userPermissions}` | account-user-permissions.tpl | User's current permissions |

#### Payment Method Management

| Variable | Type | Description |
|----------|------|-------------|
| `{$client->payMethods}` | collection | Client payment methods |
| `{$payMethod->id}` | int | Payment method ID |
| `{$payMethod->payment->getDisplayName()}` | string | Display name (Visa ending 1234) |
| `{$payMethod->description}` | string | User description |
| `{$payMethod->getStatus()}` | string | Method status |
| `{$payMethod->isDefaultPayMethod()}` | boolean | Is default |
| `{$payMethod->isExpired()}` | boolean | Is expired |
| `{$payMethod->getType()}` | string | Type (CreditCard/BankAccount) |
| `{$payMethod->getFontAwesomeIcon()}` | string | Card brand icon class |
| `{$existingCards}` | array | Existing saved cards |
| `{$existingAccounts}` | array | Existing bank accounts |
| `{$cardOnFile}` | boolean | Has card on file |
| `{$payMethodId}` | int | Selected payment method ID |
| `{$payMethodExpired}` | boolean | Selected method expired |
| `{$addingNewCard}` | boolean | Adding new card |
| `{$addingNew}` | boolean | Adding new method |
| `{$editMode}` | boolean | Edit mode |
| `{$supportedCardTypes}` | string | Supported card types JSON |
| `{$allowCreditCard}` | boolean | Credit cards allowed |
| `{$allowBankDetails}` | boolean | Bank accounts allowed |
| `{$allowClientsToRemoveCards}` | boolean | Card deletion allowed |
| `{$allowDelete}` | boolean | Method deletion allowed |

#### SSL Management (`managessl.tpl`)

| Variable | Type | Description |
|----------|------|-------------|
| `{$sslProducts}` | array | SSL product list |
| `{$sslProduct->addonId}` | int | Addon ID |
| `{$sslProduct->status}` | string | SSL status |
| `{$sslProduct->addon->service->domain}` | string | Associated domain |
| `{$sslProduct->validationType}` | string | DV/OV/EV |
| `{$sslProduct->wasInstantIssuanceAttempted()}` | boolean | Instant issuance attempted |
| `{$sslProduct->wasInstantIssuanceSuccessful()}` | boolean | Instant issuance succeeded |
| `{$sslProduct->getConfigurationUrl()}` | string | Configuration URL |
| `{$sslProduct->getUpgradeUrl()}` | string | Upgrade URL |

#### Other Page Variables

| Variable | Page | Description |
|----------|------|-------------|
| `{$ip}` | banned.tpl | Banned IP |
| `{$reason}` | banned.tpl | Ban reason |
| `{$expires}` | banned.tpl | Ban expiry |
| `{$allowedpermissions}` | access-denied.tpl | Required permissions list |
| `{$code}` | forwardpage.tpl | Payment redirect HTML |
| `{$departments}` | supportticketsubmit-stepone.tpl | Department list |
| `{$relatedservices}` | supportticketsubmit-steptwo.tpl | Related services list |
| `{$urgency}` | supportticketsubmit-steptwo.tpl | Selected urgency |
| `{$kbsuggestions}` | supportticketsubmit-steptwo.tpl | KB suggestions enabled |
| `{$kbarticles}` | supportticketsubmit-kbsuggestions.tpl | Suggested KB articles |
| `{$sent}` | contact.tpl | Contact form sent |
| `{$kbcats}` | knowledgebase.tpl | KB category list |
| `{$kbmostviews}` | knowledgebase.tpl | Most viewed articles |
| `{$kbarticle.voted}` | knowledgebasearticle.tpl | User has voted |
| `{$kbarticle.tags}` | knowledgebasearticle.tpl | Article tags |
| `{$kbarticle.useful}` | knowledgebasearticle.tpl | Useful vote count |
| `{$dlcats}` | downloads.tpl | Download categories |
| `{$mostdownloads}` | downloads.tpl | Most popular downloads |
| `{$twittertweet}` | viewannouncement.tpl | Twitter sharing enabled |
| `{$facebookrecommend}` | viewannouncement.tpl | Facebook recommend enabled |
| `{$facebookcomments}` | viewannouncement.tpl | Facebook comments enabled |
| `{$addfundsdisabled}` | clientareaaddfunds.tpl | Add funds disabled |
| `{$minimumamount}` | clientareaaddfunds.tpl | Minimum deposit |
| `{$maximumamount}` | clientareaaddfunds.tpl | Maximum deposit |
| `{$maximumbalance}` | clientareaaddfunds.tpl | Maximum balance |

### Debugging Variables

Add `{debug}` to any template to see a popup with all available variables in that template's context.
