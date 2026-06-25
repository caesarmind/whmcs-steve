<?php
/**
 * Hadrian theme - consolidated CUSTOM language strings (DRAFT).
 *
 * Produced by consolidating the 17 i18n audit reports in this directory
 * (B01..B14b). Contains ONLY genuine CUSTOM strings: no native WHMCS $_LANG
 * key covers them. Rows a report classified WHMCS, and "invented key that has
 * a real WHMCS twin" recommendations, were dropped (see _CONSOLIDATION-NOTES.md
 * -> "Dropped from custom"). Deduped by group.key; the same English reused
 * across batches collapses to ONE key.
 *
 * This is a SUPERSET ready to become the real lang file: the legacy groups from
 * core/lang/english.php (footer / error / license / admin, currently surfaced as
 * $rslang.*) are merged in at the top. In Phase B the access namespace becomes
 * $hadrianLang.<group>.<key>.
 *
 * Conventions:
 *   - %s placeholders for interpolated values.
 *   - ASCII only (no smart quotes / box-drawing / en-dashes); literal "--" / "-"
 *     used where the source copy had an em/en dash.
 *   - Single quotes in PHP values escaped as \'.
 *   - The devchip group holds dev-only state-chip / "Variant A-H" labels so they
 *     are trivial to drop before shipping; they are NOT mixed into real groups.
 */

return [

    // ---------------------------------------------------------------------
    // LEGACY groups carried over from core/lang/english.php (the $rslang set).
    // Kept verbatim so this draft is a superset. allRightsReserved / poweredBy
    // already live here -> reuse, never mint a new footer.allRightsReserved.
    // ---------------------------------------------------------------------
    'footer' => [
        'allRightsReserved' => 'All rights reserved.',
        'poweredBy'         => 'Powered by',
        // New (B08b extended-info footer fallback; only when admin brand desc unset):
        'tagline'           => 'Premium web hosting on Google Cloud. A genuinely free plan, isolated environments, no cPanel clutter.',
    ],

    'error' => [
        'notFound' => [
            'title' => 'Page not found',
            'body'  => 'We couldn\'t find the page you were looking for.',
        ],
        'serverError' => [
            'title' => 'Something went wrong',
            'body'  => 'An unexpected error occurred. Please try again or contact support.',
        ],
        'backHome' => 'Back to home',
    ],

    'license' => [
        'banner' => [
            'expiringIn' => 'Your Hadrian license expires in %d days.',
            'expired'    => 'Your Hadrian license has expired.',
            'invalid'    => 'Your Hadrian license is invalid. Please contact support.',
            'renew'      => 'Renew now',
            'contact'    => 'Contact support',
        ],
    ],

    'admin' => [
        'styles'          => 'Styles',
        'layouts'         => 'Layouts',
        'pages'           => 'Pages',
        'license'         => 'License',
        'save'            => 'Save changes',
        'select'          => 'Select',
        'currentlyActive' => 'Currently active',
    ],

    // ---------------------------------------------------------------------
    // COMMON - shared chrome, table/pager affixes, generic words.
    // ---------------------------------------------------------------------
    'common' => [
        // License-gate (B08 header.tpl + B08b error/license-required.tpl).
        // Collision resolved: header "Theme License Required" (Title case) wins.
        'licenseRequiredTitle' => 'Theme License Required',
        'licenseRequiredBody'  => 'This commercial theme cannot render until the Hadrian addon is active and a valid license is available.',

        // Theme / a11y labels (B08).
        'darkMode'    => 'Dark Mode',
        'toggleTheme' => 'Toggle theme',
        'page'        => 'Page',

        // Locale picker (B08b) - combined "language & currency" phrase has no single WHMCS key.
        'localeChoose'  => 'Choose language & currency',
        'cookieNotice'  => 'Cookie notice',
        'cookieMessage' => 'We use cookies to improve your experience. By continuing to browse, you agree to our use of cookies.',

        // Generic button reused across auth password generator (B06).
        'cancel' => 'Cancel',

        // Generic single words / state labels (B13b downloadscat, serverstatus preview).
        'open'    => 'Open',
        'preview' => 'Preview',
        'copied'  => 'Copied',

        // Filter + DataTables affixes - shared across services/domains/billing/
        // support/account list pages (B10/B11/B12/B13a/B13b/B14a). Deduped to ONE set.
        'filterAll'        => 'All',
        'tableShow'        => 'Show',
        'tableEntries'     => 'entries',
        'tableShowing'     => 'Showing',
        'tableOf'          => 'of',
        'tableShowingRange' => 'Showing %s-%s of %s',
        'rowsPerPage'      => 'Rows per page',
        'previousPage'     => 'Previous page',
        'nextPage'         => 'Next page',

        // Sort controls (B13b downloadscat).
        'sortBy'     => 'Sort by',
        'sortRecent' => 'Most recent',
        'sortAlpha'  => 'Alphabetical',
    ],

    // ---------------------------------------------------------------------
    // NAV - chrome partials (B08). Landmark a11y names intentionally omitted.
    // ---------------------------------------------------------------------
    'nav' => [
        'openNavigation' => 'Open navigation',
        'itemsInCart'    => '%s items in cart',
        'configureMenu'  => 'Configure menu...',
        'portalHome'     => 'Portal Home',
    ],

    // ---------------------------------------------------------------------
    // AUTH - login / register / password reset / 2FA (B06, B07).
    // ---------------------------------------------------------------------
    'auth' => [
        // Login (B06).
        'account'              => 'Account',
        'signInTitle'          => 'Sign in',
        'signIn'               => 'Sign in',
        'welcomeBack'          => 'Welcome back. Enter your credentials to access your account.',
        'logoutSuccessful'     => 'You have been logged out. See you next time.',
        'loginDetailsIncorrect' => 'The email address or password you entered is incorrect. Please try again.',
        'verifyLinkExpired'    => 'This email-verification link has expired. Sign in to request a new one.',
        'pwResetSuccess'       => 'Your password has been reset. Sign in with your new password.',
        'passwordPlaceholder'  => 'Enter your password',
        'togglePassword'       => 'Show or hide password',
        'forgotPassword'       => 'Forgot password?',
        'orContinueWith'       => 'or continue with',
        'continueSso'          => 'Continue',
        'dontHaveAccount'      => 'Don\'t have an account?',
        'createAccountLink'    => 'Create one',
        'loginWelcomeSub'      => 'Manage your services, domains, invoices and support -- all from one control panel.',
        'latestAnnouncements'  => 'Latest announcements',
        'noAnnouncements'      => 'You\'re all caught up -- no announcements right now.',
        'loginIntro'           => 'Use your account email and password.',

        // Register (B06).
        'createAccountTitle'  => 'Create your account',
        'alreadyHaveAccount'  => 'Already have an account?',
        'marketingOptInLabel' => 'Yes, send me product news and special offers',
        'generateNewShort'    => 'New',

        // Password reset (B07).
        'pwresetCheckEmailTitle' => 'Check your email',
        'backToLogin'            => 'Back to sign in',
        'pwresetSecurityTitle'   => 'Verify your identity',
        'yourAnswer'             => 'Your answer',
        'pwresetNewTitle'        => 'Choose a new password',

        // Two-factor (B07).
        'backupCodePlaceholder' => 'xxxx-xxxx-xxxx',
        'useTotpInstead'        => 'Use authenticator code instead',
        'useBackupCode'         => 'Use a backup code',
        'backupCodesTitle'      => 'Backup codes',
        'backupCodesSub'        => 'Save these codes somewhere safe. Each one can be used once to sign in if you lose access to your authenticator device.',
        'done'                  => 'Done',
        'backupCodesWarn'       => 'These codes will not be shown again. Once you leave this page they are gone.',
        'copied'                => 'Copied',
    ],

    // ---------------------------------------------------------------------
    // DASHBOARD - client home + public homepage (B09).
    // ---------------------------------------------------------------------
    'dashboard' => [
        // Overdue-invoice / domain-expiry banner fragments (client home).
        'youHave'        => 'You have',
        'overdueInvoice' => 'overdue invoice',
        'overdueInvoices' => 'overdue invoices',
        'withTotalOf'    => 'with a total of',
        'due'            => 'due',
        'dismiss'        => 'Dismiss',
        'domainSingular' => 'domain',
        'domainPlural'   => 'domains',
        'expireWithin45' => 'expires in the next 45 days',
        'toKeepActive'   => 'to keep active',

        // Empty-state greeting fragments.
        'welcomeTo'           => 'Welcome to',
        'startBy'             => 'Start by',
        'orderingAService'    => 'ordering a service',
        'registeringADomain'  => 'registering a domain',

        // Empty states (client home).
        'noServicesTitle'   => 'No services yet',
        'noServicesSub'     => 'You don\'t have any active products. Browse our catalogue to get started.',
        'noTicketsTitle'    => 'No tickets yet',
        'noTicketsSub'      => 'Need a hand with something? We\'re here to help.',
        'noAnnouncements'   => 'No announcements',
        'noAnnouncementsSub' => 'Product updates and network notices will appear here.',
        'updated'           => 'Updated',
        'opened'            => 'Opened',

        // Public homepage marketing copy.
        'heroTitle'           => 'Secure your domain name.',
        'heroSubtitle'        => 'Search, register, and transfer -- all in one place.',
        'heroDomainSubtitle'  => 'Find the perfect name for your project.',
        'section1Title'       => 'Browse our products.',
        'productCard1Title'   => 'WordPress Hosting',
        'productCard1Desc'    => 'Managed WordPress built for speed, backed by automatic updates.',
        'selfService'         => 'Self-service',
    ],

    // ---------------------------------------------------------------------
    // SERVICES - product list, details, upgrade, usage, subscription (B10).
    // ---------------------------------------------------------------------
    'services' => [
        // clientareaproducts.
        'productsServicesSub' => 'Manage your active services, upgrades, and add-ons.',
        'orderAService'       => 'Order a service',
        'serviceLower'        => 'service',
        'servicesLower'       => 'services',
        'onThisAccount'       => 'on this account',
        'colName'             => 'Name',
        'serviceFallback'     => 'Service',
        'emptyTitle'          => 'No services yet',
        'emptySub'            => 'You don\'t have any products or services on this account. Browse our catalogue to get started.',
        'placeAnOrder'        => 'Place an order',
        // Status pills (invented; WHMCS clientarea* twins exist - see notes "needs verification").
        'statusActive'        => 'Active',
        'statusPending'       => 'Pending',
        'statusSuspended'     => 'Suspended',
        'statusTerminated'    => 'Terminated',
        'statusCancelled'     => 'Cancelled',
        'statusFraud'         => 'Fraud',

        // clientareaproductdetails.
        'unpaidInvoice'             => 'This service has an unpaid invoice.',
        'loginCpanel'               => 'Log in to cPanel',
        'loginWebmail'              => 'Log in to Webmail',
        'usageNotAvailable'         => 'Usage statistics are not available for this service yet.',
        'cpPendingNotice'           => 'This service is still being set up -- control-panel access will be available once it goes active.',
        'cpUnavailableTerminated'   => 'This service has been %s; control-panel access is no longer available.',
        'cpUnavailableStatus'       => 'Control-panel access (cPanel / Webmail) is unavailable while this service is %s.',
        'cpPayOverdue'              => 'Pay the overdue invoice to reactivate it.',
        'upgradeSublabel'           => 'Change your hosting plan',
        'renewSublabel'             => 'Extend your service term',
        'changePwSublabel'          => 'Set a new control-panel password',
        'cancelSublabel'            => 'Schedule this service to be cancelled',
        // cPanel quick-shortcut labels (module $LANG.cPanel.* not loaded on theme page).
        'scEmailAccounts'    => 'Email Accounts',
        'scForwarders'       => 'Forwarders',
        'scAutoresponders'   => 'Autoresponders',
        'scFileManager'      => 'File Manager',
        'scBackup'           => 'Backup',
        'scSubdomains'       => 'Subdomains',
        'scAddonDomains'     => 'Addon Domains',
        'scCronJobs'         => 'Cron Jobs',
        'scMysql'            => 'MySQL Databases',
        'scPendingNotice'    => 'Shortcuts will be available once this service is active.',
        'scUnavailableStatus' => 'cPanel shortcuts are unavailable while this service is %s.',

        // upgrade.
        'upgradeIntro'    => 'Change your plan size or feature tier. Changes are prorated.',
        // Enabled/Disabled (TRAP: $LANG.yes/no = "Yes"/"No" - keep custom).
        'enabledState'    => 'Enabled',
        'disabledState'   => 'Disabled',
        // Cycle abbreviations (TRAP: $LANG.monthly.. = full words - keep custom shorts).
        'cycleMonthlyShort'      => 'mo',
        'cycleQuarterlyShort'    => 'qtr',
        'cycleSemiannuallyShort' => '6 mo',
        'cycleAnnuallyShort'     => 'yr',
        'cycleBienniallyShort'   => '2 yr',
        'cycleTrienniallyShort'  => '3 yr',
        'backToMyService'        => 'Back to my service',
        'backToServices'         => 'Back to services',
        'upgradeNotAvailTitle'   => 'Upgrade not available',
        'noUpgradeTitle'         => 'No upgrade available',

        // upgrade-configure.
        'upgradeConfigureIntro' => 'Pick your new plan and review the prorated amount before confirming.',
        'proratedCredit'        => 'Prorated credit',
        'upgradePickFirstTitle' => 'Start an upgrade',
        'upgradePickFirstSub'   => 'Choose a service and a target plan to configure your upgrade.',

        // upgradesummary.
        'upgradeSummaryIntro'   => 'Confirm the changes and amount due before checkout.',
        'promoFallback'         => 'Promo',
        'upgradeNoSummaryTitle' => 'Nothing to confirm',
        'upgradeNoSummarySub'   => 'Start an upgrade from one of your services to see the summary here.',

        // subscription-manage.
        'emailSubscriptions'        => 'Email preferences',
        'subscriptionManage'        => 'Email subscription',
        'subscriptionUpdated'       => 'Subscription updated',
        'newsletterSubscribedSub'   => 'You will now receive our product news and updates by email.',
        'newsletterResubscribeText' => 'You will no longer receive marketing emails.',
        'newsletterResubscribeLink' => 'Resubscribe in account settings',
        'subscriptionManageSub'     => 'Manage how we contact you from your account settings.',
        'accountSettings'           => 'Open account settings',

        // usagebillingpricing.
        'usagePricingIntro'    => 'What you\'ll pay per unit beyond your included quotas.',
        'metricResource'       => 'Resource',
        'metricOverageRate'    => 'Overage rate',
        'metricFrom'           => 'from %s',
        'usagePricingHowTitle' => 'How billing works.',
        'usagePricingHow'      => 'Usage is metered continuously and totaled at the end of each billing cycle. Overages appear as line items on your next invoice.',
        'metricViewUsage'      => 'View my usage',
        'usagePricingNoneTitle' => 'Pricing unavailable',
        'usagePricingNoneSub'  => 'We couldn\'t load usage tiers for this product right now.',
    ],

    // ---------------------------------------------------------------------
    // DOMAINS - client-area domain pages (B11) + transfer marketing (B04).
    // ---------------------------------------------------------------------
    'domains' => [
        // clientareadomains list.
        'manageSub'        => 'Manage your registrations, renewals, and DNS.',
        'singular'         => 'domain',
        'plural'           => 'domains',
        'expireWithin30'   => 'expiring in the next 30 days.',
        'renewNow'         => 'Renew now',
        'transferredAway'  => 'Transferred Away',
        'expires'          => 'Expires',
        'emptyTitle'       => 'No domains yet',
        'emptySub'         => 'Register a new domain or transfer one you already own -- it\'ll appear here once the order is processed.',
        'rowsPerPage'      => 'Rows per page',
        'myDomains'        => 'My Domains',
        'bulkManagement'   => 'Bulk Management',
        'domainPricing'    => 'Domain Pricing',
        'whoisLookup'      => 'WHOIS Lookup',

        // clientareadomaindetails.
        'unpaidInvoice'   => 'This domain has an unpaid invoice.',
        'allDomains'      => 'All domains',
        'eppCode'         => 'EPP code',
        'whoisContact'    => 'WHOIS contact',
        'domainDetails'   => 'Domain details',

        // clientareadomaindns.
        'dnsExternal'  => 'DNS for this domain is managed externally by the registrar.',
        'dnsHelpTitle' => 'Common record types',
        'dnsHelpA'     => 'IPv4 address (e.g. 192.0.2.1)',
        'dnsHelpAaaa'  => 'IPv6 address (e.g. 2001:db8::1)',
        'dnsHelpCname' => 'Alias to another hostname',
        'dnsHelpMx'    => 'Mail server with priority',
        'dnsHelpTxt'   => 'Verification / SPF / DKIM strings',

        // clientareadomaincontactinfo.
        'contactPending'   => 'A contact change is pending registry confirmation.',
        'noContactDetails' => 'No contact details available for this domain.',

        // clientareadomainemailforwarding.
        'emailAt' => 'At',

        // clientareadomaingetepp.
        'eppWarning'       => 'Keep this code private. Anyone with it can initiate a transfer of your domain.',
        'howTransferWorks' => 'How a transfer works',
        'eppStep1'         => 'Unlock the domain at the current registrar.',
        'eppStep2'         => 'Request the EPP/auth code on this page.',
        'eppStep3'         => 'Submit a transfer request at the gaining registrar with that code.',
        'eppStep4'         => 'Approve the transfer email from the current registrar (usually within 5 days).',
        'copied'           => 'Copied',

        // clientareadomainregisterns.
        'delete' => 'Delete',

        // bulkdomainmanagement.
        'bulkIntro'       => 'Apply a change to all the domains you selected at once.',
        'bulkContactInfo' => 'WHOIS contact details are managed per domain. Open a domain to update its registrant, admin, tech and billing contacts.',
        'goToMyDomains'   => 'Go to my domains',
        'bulkNoneTitle'   => 'No domains selected',
        'bulkNoneSub'     => 'Select one or more domains from your domains list, then choose a bulk action.',

        // domain-pricing.
        'pricingIntro'      => 'Registration, transfer and renewal prices for every extension we offer.',
        'searchExtensions'  => 'Search extensions, e.g. .com',
        'pricingEmptyTitle' => 'Pricing unavailable',
        'pricingEmptySub'   => 'Domain pricing could not be loaded right now. Please check back shortly.',

        // domaintransfer marketing + empty-state (B04).
        'transferStepsTitle'      => 'Transfer in 3 steps',
        'transferStepsDesc'       => 'Simple, fast, and we\'ll guide you through each step.',
        'transferStep1Title'      => '1. Unlock your domain',
        'transferStep1Desc'       => 'At your current registrar, disable the transfer lock so we can pull it over.',
        'transferStep2Title'      => '2. Get your auth code',
        'transferStep2Desc'       => 'Your current registrar will email you a transfer authorization (EPP) code.',
        'transferStep3Title'      => '3. Submit and done',
        'transferStep3Desc'       => 'Enter the domain and code above. We handle the rest -- you\'ll see confirmation within 24 hours.',
        'transferWhyTitle'        => 'Why transfer to us',
        'transferWhyExtendTitle'  => '+1 free year',
        'transferWhyExtendDesc'   => 'Every transfer includes an additional year of registration at no extra cost.',
        'transferWhy24Title'      => '24-hour transfer',
        'transferWhy24Desc'       => 'Most transfers complete within 24 hours -- no downtime for your site.',
        'transferWhyPrivacyTitle' => 'Free WHOIS privacy',
        'transferWhyPrivacyDesc'  => 'Included with every transfer, on every eligible TLD. Keep your info private.',
        'transferEmptyTitle'      => 'Enter a domain to transfer',
        'transferEmptyDesc'       => 'Type your existing domain above and we\'ll start the transfer flow.',
        'transferEmptyCta'        => 'Start a transfer',
    ],

    // ---------------------------------------------------------------------
    // BILLING - invoices, quotes, add funds, mass pay, cancel, payment methods
    // (B12) + 3D Secure (B06).
    // ---------------------------------------------------------------------
    'billing' => [
        // 3D Secure (B06).
        'paymentEyebrow'      => 'Payment',
        'verifyPaymentTitle'  => 'Verify your payment',
        'verifyLoading'       => 'Waiting for the verification challenge...',

        // Shared subnav heading - bare literal, DO NOT switch to {$LANG.billing}
        // (that key is an ARRAY on this install -> renders "Array").
        'sidebarHeading' => 'Billing',
        'summary'        => 'Summary',

        // clientareainvoices.
        'invoicesSubtitle'      => 'Pay unpaid invoices, download PDFs, and review past payments.',
        'payAllUnpaid'          => 'Pay all unpaid',
        'unpaidInvoiceSingular' => 'unpaid invoice',
        'unpaidInvoicePlural'   => 'unpaid invoices',
        'noInvoicesTitle'       => 'No invoices yet',
        'noInvoicesSub'         => 'When you purchase a service or a new billing cycle begins, your invoices will appear here.',
        'browseServices'        => 'Browse services',
        'viewInvoice'           => 'View Invoice',
        'payInvoice'            => 'Pay Invoice',

        // viewinvoice.
        'issuedOn'             => 'Issued',
        'dueOn'                => 'Due',
        'amountDue'            => 'Amount due',
        'invoiceNotFoundTitle' => 'Invoice not found',
        'invoiceNotFoundSub'   => 'This invoice doesn\'t exist or has been removed from your account.',

        // clientareaquotes / viewquote.
        'quotesSubtitle'         => 'Review delivered proposals, accept to convert into an invoice, or download as PDF.',
        'quoteDeliveredSingular' => 'quote awaiting your decision',
        'quoteDeliveredPlural'   => 'quotes awaiting your decision',
        'noQuotesTitle'          => 'No quotes yet',
        'noQuotesSub'            => 'When our team prepares a proposal for you, it will show up here.',
        'contactSales'           => 'Contact sales',
        'viewQuote'              => 'View Quote',
        'quoteNumberHash'        => '#',
        'quoteUnavailableTitle'  => 'Quote unavailable',
        'quoteUnavailableSub'    => 'This quote has expired or is no longer available. Visit My Quotes to see your active proposals.',
        'backToQuotes'           => 'Back to quotes',

        // clientareaaddfunds.
        'addFundsSubtitle'  => 'Top up your account credit to cover upcoming invoices automatically.',
        'creditBalanceLabel' => 'Your credit balance is',
        'creditAppliesNext' => 'Applied automatically to new invoices',
        'makeDeposit'       => 'Make a deposit',
        'presetAmounts'     => 'Preset amounts',
        'currentBalance'    => 'Current balance',
        'deposit'           => 'Deposit',
        'newBalance'        => 'New balance',

        // masspay.
        'noUnpaidInvoicesSub' => 'You are all caught up -- no balance due.',

        // viewbillingnote (fallbacks on WHMCS vars).
        'billingNoteEyebrow' => 'Billing note',
        'detailsFallback'    => 'Details',
        'taxIdFallback'      => 'Tax ID',

        // clientareacancelrequest.
        'cancelRequestTitle'     => 'Request cancellation',
        'cancelRequestSubtitle'  => 'Tell us how and when you want this service cancelled.',
        'cancelConfirmationSub'  => 'Your cancellation request has been received. The service will be cancelled as scheduled.',
        'cancelInvalidTitle'     => 'Nothing to cancel',
        'cancelWarning'          => 'Cancelling this service permanently removes all associated data including files, databases, and email accounts.',
        'cancelReasonPlaceholder' => 'Let us know why you are cancelling...',
        'keepService'            => 'Keep service',

        // Payment methods (account-paymentmethods*).
        'pmExpired'           => 'Expired',
        'pmDeleteConfirm'     => 'Remove this payment method? This cannot be undone.',
        'pmManageTitle'       => 'Manage payment method',
        'pmManageIntro'       => 'Update card details, change the default, or remove this payment method.',
        'pmUpdateCard'        => 'Update card details',
        'pmRemoveTitle'       => 'Remove this payment method',
        'pmRemoveSub'         => 'This payment method will be deleted and can no longer be used for automatic payments.',
        'pmNoneSelected'      => 'No payment method selected',
        'pmNoneSelectedSub'   => 'Choose a saved method to edit, or add a new one.',
        'pmAdd'               => 'Add payment method',
        'billingContacts'     => 'Billing Contacts',
        'billingContactsIntro' => 'Recipients copied on invoice and payment receipt emails.',
        'noBillingContacts'   => 'No billing contacts',
        'noBillingContactsSub' => 'Add a contact to copy them on invoice and receipt emails.',
    ],

    // ---------------------------------------------------------------------
    // SUPPORT - tickets + KB / announcements / downloads / contact / markdown
    // (B13a, B13b).
    // ---------------------------------------------------------------------
    'support' => [
        // supporttickets list + submit flow (B13a).
        'ticketsListSub'             => 'Open conversations with our team -- filter by status or start a new ticket.',
        'ticketSingular'             => 'ticket',
        'ticketPlural'               => 'tickets',
        'newReplyBanner'             => 'has a new reply from our team.',
        'viewReplies'                => 'View replies',
        'noTicketsTitle'             => 'No tickets yet',
        'noTicketsSub'               => 'You haven\'t opened any support tickets. Need a hand with something? Our team is here to help.',
        'myTickets'                  => 'My tickets',
        'submitSub'                  => 'Tell us what you need help with -- our team will reply by email.',
        'step1of2'                   => 'Step 1 of 2',
        'step2of2'                   => 'Step 2 of 2',
        'chooseDepartment'           => 'Choose a department',
        'chooseDepartmentSub'        => 'Pick the team best suited to help -- your message reaches them directly.',
        'ticketDetails'              => 'Ticket details',
        'replyingVia'                => 'Replying via',
        'optional'                   => 'optional',
        'attachmentsAllowedFallback' => 'Allowed extensions: .jpg, .gif, .jpeg, .png, .txt, .pdf - Max file size: 64MB',
        'noDepartmentsTitle'         => 'No departments available',
        'noDepartmentsSub'           => 'No support departments have been configured. Please contact the site administrator.',
        'viewTicketBtn'              => 'View ticket',
        'additionalInfoTitle'        => 'Additional details',
        'customFieldsIntro'          => 'A few department-specific details to help us route and resolve your ticket faster.',
        'noCustomFieldsTitle'        => 'No additional fields',
        'noCustomFieldsSub'          => 'This department has no extra fields. Continue with your ticket.',
        'kbSuggestionsTitle'         => 'Before you submit',
        'kbSuggestionsContinue'      => 'None of these helped, continue',
        'kbNoSuggestionsTitle'       => 'No matching articles',
        'kbNoSuggestionsSub'         => 'We couldn\'t find a related article. Go ahead and open your ticket.',
        'conversation'               => 'Conversation',
        'noTicketReplies'            => 'No conversation yet -- be the first to reply.',
        'ticketSettings'             => 'Ticket Settings',
        'writeYourReply'             => 'Write your reply...',
        'sendMessage'                => 'Send Message',
        'requestor'                  => 'Requestor',
        'ticketNotAvailableTitle'    => 'Ticket not available',
        'ticketNotAvailableSub'      => 'This ticket may be closed, archived, or no longer accessible.',
        'allTickets'                 => 'All tickets',
        'feedbackTitle'              => 'Ticket feedback',
        'feedbackClosedTitle'        => 'Feedback not available yet',
        'feedbackCommentsPlaceholder' => 'Your feedback...',

        // KB / announcements / downloads / contact / markdown (B13b).
        'kbSubtitle'             => 'Setup guides, troubleshooting and answers to frequently asked questions.',
        'views'                  => 'views',
        'kbHeroSub'              => 'Search the knowledgebase or browse by category below.',
        'articlesCount'          => 'articles',
        'kbEmptySub'             => 'When our team publishes setup guides and troubleshooting articles, they will appear here.',
        'kbArticleSubtitle'      => 'Read the full article and rate it.',
        'helpfulVotes'           => 'people found this helpful',
        'didnt'                  => 'didn\'t',
        'articleNotFound'        => 'Article not found',
        'articleNotFoundSub'     => 'This article may have been removed or is no longer accessible.',
        'allCategories'          => 'All categories',
        'kbCatSubtitle'          => 'Browse articles in this category or search to narrow down.',
        'searchInCategory'       => 'Search in this category...',
        'kbNoResults'            => 'No matching articles',
        'kbNoResultsSub'         => 'Try a broader search or browse all categories.',
        'announcementsSubtitle'  => 'Product updates, network notices, and news from Hostnodes.',
        'viewRss'                => 'View RSS feed',
        'announcementsNoneSub'   => 'Product updates, network notices and news will appear here. Subscribe to the RSS feed to be notified when new posts arrive.',
        'subscribeRss'           => 'Subscribe to RSS',
        'viewAnnouncementSubtitle' => 'Read the full announcement and related news.',
        'allAnnouncements'       => 'All announcements',
        'copyLink'               => 'Copy link',
        'copied'                 => 'Copied',
        'announcementNotFound'   => 'Announcement not found',
        'announcementNotFoundSub' => 'This announcement may have been removed or is no longer accessible.',
        'contactSentSub'         => 'Thanks -- our team will reply by email as soon as possible.',
        'contactSubtitle'        => 'Send us a message and our team will follow up.',
        'downloadsIntro'         => 'Software, guides and templates for your Hostnodes account. Browse by category or search.',
        'loginRequired'          => 'Login required',
        'downloadsCatIntro'      => 'Files in this category. Search, filter by type, or download directly.',
        'downloadsCatBanner'     => 'Documents and tools in this category, ready to download.',
        'downloadsSearchInCat'   => 'Search in this category...',
        'otherType'              => 'Other',
        'showingCount'           => 'Showing',
        'allDownloads'           => 'All downloads',
        'downloadsNoneInCat'     => 'No downloads in this category',
        'downloadsCatEmpty'      => 'This category doesn\'t have any downloads yet.',
        'downloadDeniedTitle'    => 'Download denied',
        'downloadDeniedSub'      => 'You don\'t have access to this download.',
        'downloadDeniedHeading'  => 'You don\'t have permission to download this file',
        'downloadDeniedBody'     => 'It may require an active service subscription, or your account may not have the required role. Contact support if you believe this is an error.',
        'downloadDeniedNoneTitle' => 'No download in progress',
        'downloadDeniedNoneSub'  => 'There\'s no protected download to deny right now.',
        'markdownGuideIntro'     => 'Format your ticket replies and messages with simple markdown syntax.',
        'markdownStrikethrough'  => 'strikethrough',
        'markdownTablesNote'     => 'Columns do not need to line up in the source -- markdown handles the alignment.',
    ],

    // ---------------------------------------------------------------------
    // ACCOUNT - details, contacts, users, permissions, email history (B14a)
    // + user-profile / security / password / invite / verify / affiliates (B14b).
    // ---------------------------------------------------------------------
    'account' => [
        // clientareadetails (B14a).
        'accountDetailsSub'  => 'Your personal information, billing address and email preferences.',
        // Hand-rolled email-preference rows (no WHMCS per-row label+description).
        'generalEmails'      => 'General emails',
        'generalEmailsSub'   => 'All account-related emails and password reminders',
        'invoiceEmails'      => 'Invoice emails',
        'invoiceEmailsSub'   => 'New invoices, reminders, and overdue notices',
        'supportEmails'      => 'Support emails',
        'supportEmailsSub'   => 'Receive a CC of all support ticket communications',
        'productEmails'      => 'Product emails',
        'productEmailsSub'   => 'Welcome emails, suspensions and other lifecycle notifications',
        'domainEmails'       => 'Domain emails',
        'domainEmailsSub'    => 'Registration, transfer confirmations and renewal notices',
        'affiliateEmails'    => 'Affiliate emails',
        'affiliateEmailsSub' => 'Notifications about your affiliate account and payouts',
        'profileNotSetup'    => 'Profile not yet set up',
        'profileNotSetupSub' => 'Complete your account profile to keep your billing and contact info up to date.',
        'setupProfile'       => 'Set up profile',

        // contacts (B14a).
        'contactsSub'    => 'Additional people authorised to manage parts of this account.',
        'contactsNewSub' => 'Add another person who can manage parts of this account.',

        // user management / permissions (B14a).
        'userManagementSub' => 'Invite people to access this account and choose what they can do.',
        'invitePending'     => 'Pending',
        'noUserSelected'    => 'No user selected',
        'selectUserSub'     => 'Choose a user from user management to edit their permissions.',

        // email history (B14a).
        'emailsIntro'      => 'Messages we have sent to your account email address.',
        'showEntries'      => 'Show',
        'showEntriesAria'  => 'Show entries',
        'entries'          => 'entries',
        'emailsEmptyTitle' => 'No emails yet',
        'emailsEmptySub'   => 'Messages we send to your account email will be listed here.',
        'dtShowing'        => 'Showing',
        'dtOf'             => 'of',
        'dtNoMatch'        => 'No matching emails',
        'dtFiltered'       => 'filtered from',

        // user-profile (B14b).
        'profileSub'               => 'Personal information attached to your sign-in account.',
        'emailUsedToSignIn'        => 'Used to sign in to your account.',
        'existingPasswordRequired' => 'Required to confirm an email address change.',

        // user-security / clientareasecurity (B14b).
        'securitySettingsSub'      => 'Two-factor authentication and account-security options.',
        'twoFactorSub'             => 'Require a second step to sign in to your account.',
        'twoFactorEnabledDesc'     => 'Two-factor authentication is active. Sign-ins require both your password and a code from your second factor.',
        'securityQuestionSub'      => 'A backup verification step used when recovering your account.',
        'linkedAccountsSub'        => 'Connect a third-party sign-in provider so you can log in with it.',
        'securityNoOptionsTitle'   => 'No additional security options available',
        'securityNoOptionsSub'     => 'Your administrator has not enabled any additional sign-in security features (such as two-factor authentication) for your account. Please contact support if you would like extra protection added.',
        'securityNoOptionsSsoSub'  => 'Your administrator has not enabled any additional sign-in security features (such as single sign-on, linked accounts, or two-factor authentication) for your account. Please contact support if you would like extra protection added.',
        'tfaModalError'            => 'Something went wrong -- please try again.',
        'securitySettingsSsoSub'   => 'Single sign-on and connected third-party accounts for your login.',
        'ssoSummary'               => 'Move between connected areas without signing in again.',
        'ssoDisableNotice'         => 'You can turn this off at any time.',

        // user-password (B14b).
        'changePasswordSub'   => 'Pick a strong new password -- minimum 8 characters with mixed case and numbers.',
        'pwStrengthVeryWeak'  => 'Very weak',
        'pwStrengthTooWeak'   => 'Too weak',
        'pwStrengthWeak'      => 'Weak',
        'pwStrengthFair'      => 'Fair',
        'pwStrengthGood'      => 'Good',
        'pwStrengthStrong'    => 'Strong',
        'passwordsMatch'      => 'Passwords match',
        'passwordsNoMatch'    => 'Passwords do not match',
        'togglePasswordVisibility' => 'Show or hide password',

        // user-invite-accept (B14b).
        'inviteInvalidSub' => 'This invitation link is no longer valid or has already been used.',

        // user-verify-email (B14b).
        'emailVerifiedSub' => 'Your email address is confirmed. You\'re all set.',
        'emailNotFoundSub' => 'We couldn\'t find this verification request. It may have been completed already, or the link is malformed.',

        // affiliates / affiliatessignup (B14b).
        'affiliatesSub'             => 'Earn commission for every customer you refer to Hostnodes. Track your clicks, signups and payouts here.',
        'affiliatesDisabledSub'     => 'Please check back later or contact support if you believe this is an error.',
        'affiliatesNoReferrals'     => 'No referrals yet',
        'affiliatesNoReferralsSub'  => 'Share your referral link above to start earning commission. Every signup that comes through your link will appear here.',
    ],

    // ---------------------------------------------------------------------
    // SSL - managessl + configuressl-step{one,two}-complete (B14b).
    // (ssl.* method/field strings were real WHMCS keys and were dropped.)
    // ---------------------------------------------------------------------
    'ssl' => [
        'manageIntro'         => 'View status, configure, or renew the certificates on your account.',
        'orderNew'            => 'Order new certificate',
        'browse'              => 'Browse SSL',
        'noCertificates'      => 'No certificates yet',
        'noCertificatesSub'   => 'Once you order an SSL certificate it\'ll show up here for management.',
        'configureTitle'      => 'Configure your SSL certificate',
        'configIntro'         => 'Provide your server type and certificate signing request, then confirm the administrative contact.',
        'stepConfig'          => 'Configuration',
        'stepValidate'        => 'Validation',
        'stepComplete'        => 'Complete',
        'noConfigPossibleSub' => 'Its current status does not allow configuration. Open the service to review its state.',
        'invalidLinkSub'      => 'This configuration link is invalid or has expired. Open the service to start again.',
        'verifyTitle'         => 'Verify domain ownership',
        'validationIntro'     => 'Choose how you want to prove control of the domain so the certificate authority can issue your certificate.',
        'step1Incomplete'     => 'Configuration not complete',
        'step1IncompleteSub'  => 'Finish the certificate configuration step before choosing a validation method.',
        'requestSubmittedTitle' => 'Certificate request submitted',
        'completeIntro'       => 'Complete the validation step below so the certificate authority can issue your certificate.',
        'completedForPrefix'  => 'Your certificate request for',
        'completedForSuffix'  => 'has been submitted.',
        'completedGeneric'    => 'Your certificate request has been submitted.',
        'configFailed'        => 'Configuration could not be completed',
        'configFailedSub'     => 'Something went wrong while submitting your certificate request. Try again or contact support.',
    ],

    // ---------------------------------------------------------------------
    // NETWORK - serverstatus (B13b).
    // ---------------------------------------------------------------------
    'network' => [
        'allOperational'      => 'All systems operational',
        'noIncidents'         => 'No incidents reported. Every monitored service is responding normally.',
        'noServersTitle'      => 'No servers are being monitored yet',
        'noServersSub'        => 'When network monitoring is enabled, each server and its services will appear here with live uptime indicators.',
        'reportProblem'       => 'Report a problem',
        'oneIncident'         => '1 active incident',
        'incidents'           => '%s active incidents',
        'investigating'       => 'Our team is engaged and posting updates below.',
        'maintenance'         => 'Scheduled maintenance planned',
        'maintenanceSub'      => 'All services are operational. See the planned work below.',
        'serversSectionTitle' => 'Network & servers',
        'servicesCol'         => 'Services',
        'legendUp'            => 'Operational',
        'legendDown'          => 'Disrupted',
        'legendChecking'      => 'Checking',
    ],

    // ---------------------------------------------------------------------
    // CART - order form (B01-B04). cart.* keys are shared across cart pages;
    // deduped to one per English string (stepper, trust, last-chance, etc).
    // ---------------------------------------------------------------------
    'cart' => [
        // Step strip (shared viewcart / configureproduct / configureproductdomain /
        // configuredomains / checkout).
        'stepChoosePlan'   => 'Choose plan',
        'stepChooseDomain' => 'Choose a domain',
        'stepDomain'       => 'Domain',
        'stepConfigure'    => 'Configure',
        'stepCart'         => 'Cart',
        'stepCheckout'     => 'Checkout',
        'checkoutProgress' => 'Checkout progress',

        // viewcart (B01).
        'itemCount'         => 'item',
        'itemCountPlural'   => 'items',
        'configuration'     => 'Configuration',
        'includedAddons'    => 'Included addons',
        'billingCycle'      => 'Billing cycle',
        'registrationPeriod' => 'Registration period',
        'lastChance'        => 'Last chance',
        'lastChanceTitle'   => 'Protect your services and add value',
        'oneClickAdd'       => 'One-click add. Remove anytime.',
        'trustSsl'          => '256-bit SSL - PCI-DSS Level 1',
        'trustMoneyBack'    => '30-day money-back guarantee',
        'emptySub'          => 'Browse our plans and add something to get started. Everything comes with a 30-day money-back guarantee.',
        'registerDomain'    => 'Register a domain',
        // Sidebar fallback labels (low-conf; may be real WHMCS keys - see notes).
        'categories'        => 'Categories',
        'renewDomains'      => 'Renew Domains',
        'registerNewDomain' => 'Register a New Domain',
        'transferDomain'    => 'Transfer in a Domain',

        // checkout (B02).
        'checkoutSubtitle'  => 'Almost there. Enter your details, choose how you\'d like to pay, and complete your order.',
        'backToCart'        => 'Back to cart',
        'includedWithOrder' => 'included with your order',
        'yourAccount'       => 'Your account',
        'orSignUpWith'      => 'or sign up with',
        'signupApple'       => 'Sign up with Apple',
        'signupGoogle'      => 'Sign up with Google',
        'gatewaySubStripe'  => 'Cards are processed securely by Stripe.',
        'gatewaySubCard'    => 'Visa - Mastercard - Amex -- processed securely.',
        'gatewaySubPaypal'  => 'You\'ll be redirected to authorise the charge.',
        'gatewaySubBank'    => 'Direct debit or bank transfer, depending on gateway setup.',
        'gatewaySubGeneric' => 'Pay securely using this gateway.',
        'recurringTotal'    => 'Recurring',

        // configureproduct (B03).
        'configSubtitle'    => 'Pick your billing cycle, server region and any add-ons -- we\'ll total it up on the right.',
        'selectedPlan'      => 'Selected plan',
        'changePlan'        => 'Change plan',
        'domainIncluded'    => 'Included',
        'changeDomain'      => 'Change',
        'billingCycleSub'   => 'Longer commitments = bigger discounts. You can upgrade or switch later.',
        'billedMonthly'     => 'Billed every month',
        'billedQuarterly'   => 'Billed every 3 months',
        'billedSemiannually' => 'Billed every 6 months',
        'billedAnnually'    => 'Billed once per year',
        'billedBiennially'  => 'Billed every 2 years',
        'billedTriennially' => 'Billed every 3 years',
        'serverInfoSub'     => 'Set the hostname, root password, and nameserver prefixes for your server.',
        'configOptionsSub'  => 'Customize storage, CPU, region, and other options for this plan.',
        'addonsSub'         => 'Optional extras to enhance your plan. Add or remove anytime.',
        'summaryReassurance' => 'Cancel anytime - 30-day money-back guarantee.',
        'reviewCart'        => 'Review cart',
        'backToDomain'      => 'Back to domain',
        'securedNote'       => 'Secured by 256-bit SSL - PCI-DSS Level 1',
        // pw-strength meter (js-string).
        'pwWeak'            => 'Weak',
        'pwModerate'        => 'Moderate',
        'pwStrong'          => 'Strong',
        // promo / network js-strings.
        'savePercent'           => 'Save %s%%',
        'recalculatingPromo'    => 'Recalculating promo...',
        'promoNoLongerApplies'  => 'Promotion no longer applies to this configuration.',
        'promoCodeTitle'        => 'Promo code',
        'promoApplied'          => 'Promo: %s',
        'networkError'          => 'Network error -- please try again.',

        // configureproductdomain (B03).
        'chooseDomainSubtitle'    => 'Register something new, transfer one you already own, or point an existing domain at our nameservers.',
        'domainOptionGroupLabel'  => 'How you\'ll provide a domain',
        'useIncartDesc'           => 'Use a domain that\'s already in your cart.',
        'registerDesc'            => 'Search and register a brand-new domain name.',
        'transferDesc'            => 'Move your domain to us -- usually includes a free year extension.',
        'owndomainDesc'           => 'Keep it with your current registrar and point DNS at us.',
        'subdomainDesc'           => 'Use a subdomain on one of our shared domains.',
        'incartPanelHint'         => 'Pick from the domains already in your cart.',
        'registerPanelHint'       => '<strong>Search by domain.</strong> We\'ll check availability across our registrar partners.',
        'registerSldPlaceholder'  => 'example',
        'freeDomainOn'            => 'Free domain on:',
        'transferPanelHint'       => '<strong>Transfer your domain from another registrar.</strong> Most transfers add a <strong>free extra year</strong> to your registration.',
        'transferSldPlaceholder'  => 'mydomain',
        'transferRequirements'    => 'Before transferring: domain must be <strong>unlocked</strong>, registered for at least <strong>60 days</strong>, and you\'ll need the <strong>auth / EPP code</strong> from your current registrar.',
        'owndomainPanelHint'      => '<strong>I\'ll use my existing domain and update my nameservers.</strong> Tell us which domain you\'d like to use - after checkout we\'ll email you the nameservers to set at your current registrar.',
        'subdomainPanelHint'      => '<strong>Use a subdomain.</strong> Pick a parent domain and enter the prefix you\'d like.',
        'subdomainSldPlaceholder' => 'yourname',
        'whoisPrivacyNote'        => 'Your domain details stay private -- WHOIS privacy included on every TLD that supports it.',

        // configuredomains empty-state (B03).
        'noDomainsToConfigure'    => 'No domains to configure',
        'noDomainsToConfigureDesc' => 'It looks like you haven\'t added any domains to your cart yet. Pick a plan and choose a domain to continue.',
        'browsePlans'             => 'Browse plans',

        // addons (B03).
        'addonsPageSubtitle'      => 'Add-ons extend an existing service. Pick the service you\'d like to attach each one to.',

        // domainregister (B04).
        'order'                => 'Order',
        'searchModeLabel'      => 'Search mode',
        'aiGenerator'          => 'AI Generator',
        'classicSearch'        => 'Classic Search',
        'filters'              => 'Filters',
        'noMatches'            => 'No matches',
        'mostPopularTlds'      => 'Most popular',
        'popularTldsHint'      => 'A handful of the best-known extensions for your domain.',
        'suggestedDomainsHint' => 'Availability is checked in real time when you add to the cart.',
        'searchDomainTitle'    => 'Search a domain',
        'searchDomainHint'     => 'Type a domain name in the search box above to check availability.',

        // products (B04).
        'orderServicesTagline' => 'Browse our plans and add the ones you need to your cart. All plans come with a 30-day money-back guarantee.',
        'plansHeading'         => 'Available plans',
        'cycleMonthly'         => 'Monthly',
        'cycleAnnual'          => 'Annual',
        'cycleBiennial'        => 'Biennial',
        'cycleSaving'          => 'Save 20%',
        'mostPopular'          => 'Most popular',
        // Cycle-short abbreviations (real WHMCS pricingCycleShort.* lacks leading slash - kept custom).
        'cycleShortMonthly'      => '/mo',
        'cycleShortQuarterly'    => '/qtr',
        'cycleShortSemiannually' => '/6mo',
        'cycleShortAnnually'     => '/yr',
        'cycleShortBiennially'   => '/2yr',
        'cycleShortTriennially'  => '/3yr',
        'comparePlans'         => 'Not sure which plan is right for you?',
        'compareAll'           => 'Compare all features',
        'pricesIn'             => 'Prices in',
        'emptyGroupTitle'      => 'No packages in this category yet',
        'emptyGroupDesc'       => 'We\'re preparing plans for this service. Browse another category or get in touch -- our team can put together a custom quote for you.',
        'requestQuote'         => 'Request a quote',
        'browseAll'            => 'Browse all categories',
        'moneyBack'            => '30-day money back',
        'moneyBackSub'         => 'Full refund if you\'re not happy -- no questions asked.',
        'support247'           => '24/7 support',
        'support247Sub'        => 'Reach a human engineer any time via chat or ticket.',
        'uptime'               => '99.99% uptime SLA',
        'uptimeSub'            => 'Backed by global anycast and redundant power.',
        'pickCategoryTitle'    => 'Choose a category to get started',
        'pickCategoryDesc'     => 'Browse our plans by service. All plans come with a 30-day money-back guarantee.',
        'viewPlans'            => 'View plans',
    ],

    // ---------------------------------------------------------------------
    // DEVCHIP - developer-only state-chip / tile-variant labels. NOT
    // customer-facing (state-chip renders only under ?preview=1). Kept in a
    // separate group so they are trivial to drop before shipping. (B04, B09.)
    // ---------------------------------------------------------------------
    'devchip' => [
        // products.tpl plan-grid variant labels (B04).
        'cartVariantA' => 'Variant A - 3-up - feature list',
        'cartVariantB' => 'Variant B - 4-up - minimal cards',
        'cartVariantC' => 'Variant C - horizontal rows',
        'cartVariantD' => 'Variant D - comparison table',
        'cartVariantE' => 'Variant E - bento (hero + minis)',
        'cartVariantF' => 'Variant F - segmented bar',
        'cartVariantG' => 'Variant G - spec matrix',
        'cartVariantH' => 'Variant H - addon cards with radio tiers',
        // clientareahome tile-variant labels (B09).
        'dashVariantA' => 'Variant A - vertical',
        'dashVariantB' => 'Variant B - horizontal',
        'dashVariantC' => 'Variant C - tinted',
        'dashVariantD' => 'Variant D - list',
        'dashVariantE' => 'Variant E - rings',
        'dashVariantF' => 'Variant F - list (horizontal)',
    ],

];
