<?php
/**
 * Scenario data - the records the seeder never creates, so that pages render
 * their FULL states and not only their empty ones.
 *
 * Included by fixtures.php after the personas exist ($full, $empty, $creds...).
 * Same contract as fixtures.php: it ENSURES, it never wipes. Every row it
 * owns is findable by a marker (a "[fixture]" title, a hadrian-test name, a
 * @demo.hadrian.test email), so a second run finds and reuses it.
 *
 * What each block unlocks is named next to it; tests/e2e/coverage.mjs lists
 * the same pages. The ids the routes need are returned in $scenarioIds.
 */

declare(strict_types=1);

use WHMCS\Database\Capsule as DB;

/** Find a row by $where, insert $where + $values when absent. Returns the id. */
function ensureRow(string $table, array $where, array $values = []): int
{
    $q = DB::table($table);
    foreach ($where as $k => $v) $q->where($k, $v);
    $id = $q->value('id');
    if ($id) return (int) $id;
    return (int) DB::table($table)->insertGetId($where + $values);
}

function setConfig(string $setting, string $value): void
{
    DB::table('tblconfiguration')->updateOrInsert(['setting' => $setting], ['value' => $value]);
}

$api = fn(string $cmd, array $p) => localAPI($cmd, $p, TEST_ADMIN_USERNAME);
$apiOk = function (string $cmd, array $p) use ($api): array {
    $r = $api($cmd, $p);
    if (($r['result'] ?? '') !== 'success') {
        fwrite(STDERR, "$cmd failed: " . json_encode($r) . "\n");
        exit(6);
    }
    return $r;
};

$uid = (int) $full->id;
$currencyUsd = (int) DB::table('tblcurrencies')->where('default', 1)->value('id');
$now = date('Y-m-d H:i:s');
$today = date('Y-m-d');
$ids = [];

// ------------------------------------------------------------- global switches
// Add Funds (clientareaaddfunds renders its form, not "disabled"), email
// verification (the verify banner + user-verify-email), domain lookups through
// the stub registrar (no live WHOIS from the test box), tax for GB addresses
// (the tax lines of viewcart / checkout / viewinvoice).
setConfig('AddFundsEnabled', 'on');
setConfig('AddFundsRequireOrder', '');
setConfig('EnableEmailVerification', 'on');
setConfig('domainLookupRegistrar', 'hadriantest');
setConfig('TaxEnabled', 'on');
setConfig('CCAllowCustomerDelete', 'on');   // the payment-methods list's Delete action
// Cards the payment-method flow added on an earlier run.
foreach (DB::table('tblpaymethods')->where('userid', $uid)->where('description', 'like', 'flow card%')->whereNull('deleted_at')->pluck('id') as $pmId) {
    $api('DeletePayMethod', ['clientid' => $uid, 'paymethodid' => (int) $pmId]);
}
ensureRow('tbltax', ['name' => 'VAT (hadrian-test)'], ['level' => 1, 'state' => '', 'country' => 'GB', 'taxrate' => 20.00]);

// ------------------------------------------------------------- stub registrar
// Unlocks clientareadomaindns / getepp / registerns / emailforwarding / addons.
$regDir = $whmcsRoot . '/modules/registrars/hadriantest';
@mkdir($regDir, 0777, true);
copy(dirname(__DIR__) . '/stubs/registrars/hadriantest/hadriantest.php', $regDir . '/hadriantest.php');
if (!DB::table('tblregistrars')->where('registrar', 'hadriantest')->exists()) {
    DB::table('tblregistrars')->insert(['registrar' => 'hadriantest', 'setting' => 'FriendlyName', 'value' => encrypt('Hadrian Test Registrar')]);
}
$domainId = (int) DB::table('tbldomains')->where('userid', $uid)->orderBy('id')->value('id');
DB::table('tbldomains')->where('id', $domainId)->update([
    'registrar' => 'hadriantest', 'dnsmanagement' => 1, 'emailforwarding' => 1, 'idprotection' => 1, 'status' => 'Active',
]);

// ------------------------------------------------------------- domain pricing
// The seeder creates none, so domain-pricing, domainregister, domaintransfer
// and the renewals page only ever showed "no TLDs". Columns msetupfee..
// biennially are 1..10 years; -1 = not offered.
$tlds = [
    ['.com', 12.99, 'Popular'], ['.net', 14.49, ''], ['.org', 13.99, ''],
    ['.co.uk', 8.99, 'Sale'], ['.io', 39.00, 'New'], ['.dev', 15.00, ''],
];
foreach ($tlds as $i => [$ext, $price, $group]) {
    $tid = ensureRow('tbldomainpricing', ['extension' => $ext], [
        'dnsmanagement' => 1, 'emailforwarding' => 1, 'idprotection' => 1, 'eppcode' => $ext === '.co.uk' ? 0 : 1,
        'autoreg' => 'hadriantest', 'order' => $i + 1, 'group' => strtolower($group), 'grace_period' => -1,
        'grace_period_fee' => -1, 'redemption_grace_period' => -1, 'redemption_grace_period_fee' => -1,
        'created_at' => $now, 'updated_at' => $now,
    ]);
    foreach (['domainregister' => $price, 'domaintransfer' => $price, 'domainrenew' => $price + 1] as $type => $p) {
        ensureRow('tblpricing', ['type' => $type, 'currency' => $currencyUsd, 'relid' => $tid], [
            'msetupfee' => $p, 'qsetupfee' => $p * 2, 'ssetupfee' => $p * 3, 'asetupfee' => -1, 'bsetupfee' => -1,
            'tsetupfee' => 0, 'monthly' => -1, 'quarterly' => -1, 'semiannually' => -1, 'annually' => -1, 'biennially' => -1, 'triennially' => 0,
        ]);
    }
}
// Domain addons (DNS management / email forwarding / ID protection prices).
ensureRow('tblpricing', ['type' => 'domainaddons', 'currency' => $currencyUsd, 'relid' => 0], [
    'msetupfee' => 2.00, 'qsetupfee' => 1.50, 'ssetupfee' => 4.00, 'asetupfee' => 0, 'bsetupfee' => 0, 'tsetupfee' => 0,
    'monthly' => 0, 'quarterly' => 0, 'semiannually' => 0, 'annually' => 0, 'biennially' => 0, 'triennially' => 0,
]);

// --------------------------------------------- server products
// The seeder made VPS and dedicated plans "hostingaccount". As "server" they
// get WHMCS's hostname / root password / nameserver step on configureproduct,
// which is what the Order Process settings (op_*) act on.
$serverGroups = DB::table('tblproductgroups')->whereIn('slug', ['vps-hosting', 'dedicated-servers'])->pluck('id')->all();
DB::table('tblproducts')->whereIn('gid', $serverGroups)->update(['type' => 'server']);
$ids['serverProductId'] = (int) DB::table('tblproducts')->whereIn('gid', $serverGroups)->orderBy('id')->value('id');
$ids['serverGroupId'] = (int) ($serverGroups[0] ?? 0);

// --------------------------------------------- configurable options + upgrades
// Professional (14) and Business (15) get a config-option group: the option
// rows of configureproduct, the upgrade-configure page and the order summary.
$cgid = ensureRow('tblproductconfiggroups', ['name' => 'hadrian-test options'], ['description' => 'Test fixture (tests/php/scenarios.php)']);
$opt = function (string $name, int $type, array $subs, int $order) use ($cgid, $currencyUsd): void {
    $oid = ensureRow('tblproductconfigoptions', ['gid' => $cgid, 'optionname' => $name],
        ['optiontype' => $type, 'qtyminimum' => $type === 4 ? 0 : 0, 'qtymaximum' => $type === 4 ? 10 : 0, 'order' => $order, 'hidden' => 0]);
    foreach ($subs as $i => [$label, $monthly]) {
        $sid = ensureRow('tblproductconfigoptionssub', ['configid' => $oid, 'optionname' => $label], ['sortorder' => $i, 'hidden' => 0]);
        ensureRow('tblpricing', ['type' => 'configoptions', 'currency' => $currencyUsd, 'relid' => $sid], [
            'msetupfee' => 0, 'qsetupfee' => 0, 'ssetupfee' => 0, 'asetupfee' => 0, 'bsetupfee' => 0, 'tsetupfee' => 0,
            'monthly' => $monthly, 'quarterly' => $monthly * 3, 'semiannually' => $monthly * 6, 'annually' => $monthly * 12,
            'biennially' => $monthly * 24, 'triennially' => $monthly * 36,
        ]);
    }
};
$opt('Data centre', 1, [['London', 0], ['Frankfurt', 0], ['New York', 2]], 1);     // dropdown
$opt('Daily backups', 3, [['Yes', 3]], 2);                                          // yes/no
$opt('Extra IPv4 addresses', 4, [['IP', 1.5]], 3);                                  // quantity
foreach ([14, 15] as $pid) ensureRow('tblproductconfiglinks', ['gid' => $cgid, 'pid' => $pid]);
foreach ([[14, 15], [15, 14]] as [$from, $to]) {
    ensureRow('tblproduct_upgrade_products', ['product_id' => $from, 'upgrade_product_id' => $to], ['created_at' => $now, 'updated_at' => $now]);
}
DB::table('tblproducts')->whereIn('id', [14, 15])->update(['configoptionsupgrade' => 1]);

// ------------------------------------------------------------- custom fields
// Optional on purpose: the checkout flows must keep working without them.
ensureRow('tblcustomfields', ['type' => 'product', 'relid' => 15, 'fieldname' => 'Project name'], [
    'fieldtype' => 'text', 'description' => 'Shown on your invoices', 'fieldoptions' => '', 'regexpr' => '', 'adminonly' => '',
    'required' => '', 'showorder' => 'on', 'showinvoice' => 'on', 'sortorder' => 0, 'created_at' => $now, 'updated_at' => $now,
]);
ensureRow('tblcustomfields', ['type' => 'client', 'relid' => 0, 'fieldname' => 'How did you hear about us?'], [
    'fieldtype' => 'dropdown', 'description' => '', 'fieldoptions' => 'Search engine,A friend,Social media', 'regexpr' => '', 'adminonly' => '',
    'required' => '', 'showorder' => 'on', 'showinvoice' => '', 'sortorder' => 0, 'created_at' => $now, 'updated_at' => $now,
]);

// ------------------------------------------------------------- product addon
// The addons page (cart.php?gid=addons) and the service page's addon list.
$addonId = ensureRow('tbladdons', ['name' => 'Priority support (hadrian-test)'], [
    'packages' => '13,14,15', 'description' => 'Replies within one hour, around the clock.', 'billingcycle' => 'recurring',
    'allowqty' => 0, 'tax' => 0, 'showorder' => 1, 'hidden' => 0, 'retired' => 0, 'downloads' => '', 'autoactivate' => '',
    'suspendproduct' => 0, 'welcomeemail' => 0, 'type' => '', 'module' => '', 'server_group_id' => 0, 'prorate' => 0, 'weight' => 0,
    'autolinkby' => '', 'created_at' => $now, 'updated_at' => $now,
]);
ensureRow('tblpricing', ['type' => 'addon', 'currency' => $currencyUsd, 'relid' => $addonId], [
    'msetupfee' => 0, 'qsetupfee' => 0, 'ssetupfee' => 0, 'asetupfee' => 0, 'bsetupfee' => 0, 'tsetupfee' => 0,
    'monthly' => 9.00, 'quarterly' => 27.00, 'semiannually' => 54.00, 'annually' => 99.00, 'biennially' => -1, 'triennially' => -1,
]);
$serviceId = (int) DB::table('tblhosting')->where('userid', $uid)->where('domainstatus', 'Active')->orderBy('id')->value('id');
ensureRow('tblhostingaddons', ['hostingid' => $serviceId, 'addonid' => $addonId], [
    'orderid' => 0, 'userid' => $uid, 'server' => 0, 'name' => '', 'qty' => 1, 'firstpaymentamount' => 9.00, 'setupfee' => 0,
    'recurring' => 9.00, 'billingcycle' => 'Monthly', 'tax' => '', 'status' => 'Active', 'regdate' => $today,
    'nextduedate' => date('Y-m-d', strtotime('+20 days')), 'nextinvoicedate' => date('Y-m-d', strtotime('+20 days')),
    'termination_date' => '0000-00-00', 'proratadate' => '0000-00-00', 'paymentmethod' => 'banktransfer', 'notes' => '',
    'subscriptionid' => '', 'upsell_from_products' => '', 'created_at' => $now, 'updated_at' => $now,
]);

// ------------------------------------------------------------- promo code
ensureRow('tblpromotions', ['code' => 'HADRIAN10'], [
    'type' => 'Percentage', 'recurring' => 0, 'value' => 10, 'cycles' => '', 'appliesto' => '', 'requires' => '', 'requiresexisting' => 0,
    'startdate' => '0000-00-00', 'expirationdate' => '0000-00-00', 'maxuses' => 0, 'uses' => 0, 'lifetimepromo' => 0, 'applyonce' => 0,
    'newsignups' => 0, 'existingclient' => 0, 'onceperclient' => 0, 'recurfor' => 0, 'upgrades' => 0, 'upgradeconfig' => '',
    'notes' => 'Test fixture (tests/php/scenarios.php)',
]);

// ------------------------------------------------------------- knowledgebase
$kbCat = ensureRow('tblknowledgebasecats', ['name' => 'Getting started'], ['parentid' => 0, 'description' => 'First steps with your hosting account.', 'hidden' => '', 'catid' => 0, 'language' => '']);
$kbSub = ensureRow('tblknowledgebasecats', ['name' => 'Email'], ['parentid' => $kbCat, 'description' => 'Mailboxes, forwarders and DNS.', 'hidden' => '', 'catid' => 0, 'language' => '']);
foreach ([
    [$kbCat, 'How do I point my domain at my hosting?', '<p>Set your nameservers to <code>ns1.example.com</code> and <code>ns2.example.com</code>. Changes can take up to 24 hours.</p><ol><li>Open Domains</li><li>Choose Nameservers</li><li>Save</li></ol>'],
    [$kbCat, 'Uploading your website with SFTP', '<p>Use any SFTP client with the details from your welcome email.</p>'],
    [$kbSub, 'Setting up email on your phone', '<p>Use IMAP on port 993 and SMTP on port 465.</p>'],
] as $i => [$cat, $title, $body]) {
    $aid = ensureRow('tblknowledgebase', ['title' => $title], ['article' => $body, 'views' => 10 * ($i + 1), 'useful' => $i, 'votes' => $i + 1, 'private' => '', 'order' => $i, 'parentid' => 0, 'language' => '']);
    ensureRow('tblknowledgebaselinks', ['categoryid' => $cat, 'articleid' => $aid]);
    $ids['kbArticleId'] ??= $aid;
}
$ids['kbCategoryId'] = $kbCat;

// ------------------------------------------------------------- downloads
// One public download, one only for owners of DS Pro (20) - which the full
// persona does not own, so it gets downloaddenied.
$dlDir = $whmcsRoot . '/downloads';
file_put_contents($dlDir . '/hadrian-test-guide.txt', "Hadrian test download (tests/php/scenarios.php)\n");
$dlCat = ensureRow('tbldownloadcats', ['name' => 'Guides'], ['parentid' => 0, 'description' => 'Setup guides and checklists.', 'hidden' => 0, 'created_at' => $now, 'updated_at' => $now]);
$dlPublic = ensureRow('tbldownloads', ['title' => 'Getting started guide'], [
    'category' => $dlCat, 'type' => 'zip', 'description' => 'A one-page checklist.', 'downloads' => 3, 'location' => 'hadrian-test-guide.txt',
    'clientsonly' => 0, 'hidden' => 0, 'productdownload' => 0, 'created_at' => $now, 'updated_at' => $now,
]);
$dlRestricted = ensureRow('tbldownloads', ['title' => 'Dedicated server toolkit'], [
    'category' => $dlCat, 'type' => 'zip', 'description' => 'Only for DS Pro owners.', 'downloads' => 0, 'location' => 'hadrian-test-guide.txt',
    'clientsonly' => 1, 'hidden' => 0, 'productdownload' => 1, 'created_at' => $now, 'updated_at' => $now,
]);
ensureRow('tblproduct_downloads', ['product_id' => 20, 'download_id' => $dlRestricted], ['created_at' => $now, 'updated_at' => $now]);
$ids['downloadCategoryId'] = $dlCat;
$ids['downloadId'] = $dlPublic;
$ids['restrictedDownloadId'] = $dlRestricted;

// ------------------------------------------------------------- network status
// serverstatus.tpl branches on issue type/status/priority; the seeder adds none.
foreach ([
    ['Scheduled maintenance: London storage', 'Server', 'Scheduled', 'Low', '+2 days'],
    ['Degraded email delivery', 'System', 'Investigating', 'High', '-1 hour'],
    ['Network outage in Frankfurt', 'Other', 'Resolved', 'Critical', '-3 days'],
] as [$title, $type, $status, $prio, $start]) {
    ensureRow('tblnetworkissues', ['title' => $title], [
        'description' => '<p>' . $title . ' (test fixture).</p>', 'type' => $type, 'affecting' => 'hadrian-test',
        'server' => 0, 'priority' => $prio, 'startdate' => date('Y-m-d H:i:s', strtotime($start)),
        'enddate' => $status === 'Resolved' ? date('Y-m-d H:i:s', strtotime($start . ' +4 hours')) : null,
        'status' => $status, 'lastupdate' => $now, 'created_at' => $now, 'updated_at' => $now,
    ]);
}

// ------------------------------------------------------------- full persona's records
// A second, overdue invoice (mass pay needs two; overdue is its own state).
if (!DB::table('tblinvoiceitems')->where('userid', $uid)->where('description', 'like', '[fixture]%')->exists()) {
    $apiOk('CreateInvoice', [
        'userid' => $uid, 'status' => 'Unpaid', 'sendinvoice' => false, 'paymentmethod' => 'banktransfer',
        'date' => date('Y-m-d', strtotime('-40 days')), 'duedate' => date('Y-m-d', strtotime('-10 days')),
        'itemdescription1' => '[fixture] Overdue: extra storage', 'itemamount1' => 15.00, 'itemtaxed1' => false,
    ]);
}
$ids['overdueInvoiceId'] = (int) DB::table('tblinvoiceitems')->where('userid', $uid)->where('description', 'like', '[fixture]%')->value('invoiceid');

// A quote (viewquote, the quotes list's full state).
$quoteId = (int) DB::table('tblquotes')->where('userid', $uid)->where('subject', '[fixture] Website redesign hosting')->value('id');
if (!$quoteId) {
    $r = $apiOk('CreateQuote', [
        'subject' => '[fixture] Website redesign hosting', 'stage' => 'Delivered', 'validuntil' => date('Y-m-d', strtotime('+30 days')),
        'userid' => $uid, 'proposal' => 'Hosting for the redesigned site, billed annually.', 'customernotes' => 'Prices include setup.',
        'lineitems' => base64_encode(serialize([
            ['desc' => 'Business hosting (12 months)', 'qty' => 1, 'up' => 155.88, 'discount' => 0, 'taxable' => false],
            ['desc' => 'Migration from the old host', 'qty' => 2, 'up' => 40.00, 'discount' => 10, 'taxable' => false],
        ])),
    ]);
    $quoteId = (int) $r['quoteid'];
}
$ids['quoteId'] = $quoteId;

// A contact (account-contacts-manage with a contact to edit).
$contactId = (int) DB::table('tblcontacts')->where('userid', $uid)->where('email', 'contact.fixture' . DEMO_DOMAIN)->value('id');
if (!$contactId) {
    $r = $apiOk('AddContact', [
        'clientid' => $uid, 'firstname' => 'Theo', 'lastname' => 'Contact', 'email' => 'contact.fixture' . DEMO_DOMAIN,
        'address1' => '12 Riverside Walk', 'city' => 'Bristol', 'state' => 'Bristol', 'postcode' => 'BS1 4DJ', 'country' => 'GB',
        'phonenumber' => '+44.1179460001', 'invoiceemails' => true,
    ]);
    $contactId = (int) $r['contactid'];
}
$ids['contactId'] = $contactId;

// Two emails in the client's history (clientareaemails list + viewemail).
foreach (['Welcome to Hostnodes', 'Invoice payment confirmation'] as $i => $subject) {
    ensureRow('tblemails', ['userid' => $uid, 'subject' => '[fixture] ' . $subject], [
        'message' => '<p>Hello Mara,</p><p>' . $subject . ' (test fixture).</p>', 'date' => date('Y-m-d H:i:s', strtotime("-{$i} days")),
        'to' => 'mara.okonkwo' . DEMO_DOMAIN, 'cc' => '', 'bcc' => '', 'attachments' => '', 'pending' => 0, 'message_data' => '',
        'failed' => 0, 'failure_reason' => '', 'retry_count' => 0, 'created_at' => $now, 'updated_at' => $now, 'campaign_id' => 0,
    ]);
}
$ids['emailId'] = (int) DB::table('tblemails')->where('userid', $uid)->where('subject', 'like', '[fixture]%')->orderBy('id')->value('id');

// A closed ticket in a department that asks for feedback (ticketfeedback +
// the closed-ticket states of viewticket and the tickets list).
$feedbackDept = (int) DB::table('tblticketdepartments')->orderBy('order')->value('id');
DB::table('tblticketdepartments')->where('id', $feedbackDept)->update(['feedback_request' => 1]);
$closed = DB::table('tbltickets')->where('userid', $uid)->where('title', '[fixture] Closed: migrate my site')->first();
if (!$closed) {
    $r = $apiOk('OpenTicket', [
        'deptid' => $feedbackDept, 'clientid' => $uid, 'subject' => '[fixture] Closed: migrate my site',
        'message' => 'Please migrate my site from the old host.', 'priority' => 'Low', 'noemail' => true,
    ]);
    $apiOk('AddTicketReply', ['ticketid' => $r['id'], 'adminusername' => 'Hadrian Test', 'message' => 'Done - your site is live on the new server.', 'noemail' => true]);
    $apiOk('UpdateTicket', ['ticketid' => $r['id'], 'status' => 'Closed']);
    $closed = DB::table('tbltickets')->where('id', $r['id'])->first();
}
DB::table('tblticketfeedback')->where('ticketid', $closed->id)->delete();   // so the form shows, not "thank you"
$ids['closedTicketTid'] = $closed->tid;
$ids['closedTicketC'] = $closed->c;

// An SSL certificate order on the SSL service (managessl's full state).
$sslService = (int) DB::table('tblhosting')->where('userid', $uid)->where('packageid', 21)->value('id');
if ($sslService) {
    ensureRow('tblsslorders', ['userid' => $uid, 'serviceid' => $sslService], [
        'addon_id' => 0, 'remoteid' => 'hadrian-test-1', 'module' => 'thesslstore', 'certtype' => 'Domain Validation',
        'configdata' => '', 'authdata' => '', 'completiondate' => $now, 'status' => 'Completed',
        'certificate_expiry_date' => date('Y-m-d', strtotime('+200 days')), 'created_at' => $now, 'updated_at' => $now,
    ]);
}

// Email verification. full is verified (no banner). empty is NOT and has no
// token, so its "verify your email" banner is stable. The verify LINK
// consumes its token, so it gets a throwaway user of its own, re-armed here
// every run (user-verify-email).
DB::table('tblusers')->where('email', $creds['personas']['full']['email'])->update(['email_verified_at' => $now]);
DB::table('tblusers')->where('email', $creds['personas']['empty']['email'])->update(['email_verified_at' => null, 'email_verification_token' => '']);
$verifyEmail = 'verify.target' . DEMO_DOMAIN;
if (!DB::table('tblusers')->where('email', $verifyEmail)->exists()) {
    $apiOk('AddUser', ['firstname' => 'Vera', 'lastname' => 'Verify', 'email' => $verifyEmail, 'password2' => DEMO_CLIENT_PASSWORD, 'language' => '']);
}
$verifyToken = hash('sha256', 'hadrian-test-verify');
DB::table('tblusers')->where('email', $verifyEmail)->update([
    'email_verified_at' => null, 'email_verification_token' => $verifyToken,
    'email_verification_token_expiry' => date('Y-m-d H:i:s', strtotime('+2 days')),
]);
$ids['verifyToken'] = $verifyToken;

// ------------------------------------------------------------- extra users
// A sub-user on the full persona's account WITHOUT invoice access:
// account-user-permissions (as the owner) and access-denied (as the sub-user).
$subEmail = 'sub.user' . DEMO_DOMAIN;
$subUser = DB::table('tblusers')->where('email', $subEmail)->first();
if (!$subUser) {
    $apiOk('AddUser', ['firstname' => 'Sam', 'lastname' => 'Subuser', 'email' => $subEmail, 'password2' => DEMO_CLIENT_PASSWORD, 'language' => '']);
    $subUser = DB::table('tblusers')->where('email', $subEmail)->first();
}
DB::table('tblusers')->where('id', $subUser->id)->update(['email_verified_at' => $now]);
DB::table('tblusers_clients')->updateOrInsert(
    ['auth_user_id' => $subUser->id, 'client_id' => $uid],
    ['invite_id' => 0, 'owner' => 0, 'permissions' => 'profile,contacts,products,manageproducts,domains,managedomains,tickets', 'created_at' => $now, 'updated_at' => $now]
);
$ids['subUserId'] = (int) $subUser->id;

// A user on TWO accounts (full persona's and the suspended client's): signing
// in lands on the account chooser, and opening the other account's invoice
// asks to switch (user-switch-account-forced).
$multiEmail = 'multi.account' . DEMO_DOMAIN;
$multi = DB::table('tblusers')->where('email', $multiEmail)->first();
if (!$multi) {
    $apiOk('AddUser', ['firstname' => 'Max', 'lastname' => 'Multi', 'email' => $multiEmail, 'password2' => DEMO_CLIENT_PASSWORD, 'language' => '']);
    $multi = DB::table('tblusers')->where('email', $multiEmail)->first();
}
DB::table('tblusers')->where('id', $multi->id)->update(['email_verified_at' => $now]);
$allPerms = 'profile,contacts,products,manageproducts,productsso,domains,managedomains,invoices,quotes,tickets,affiliates,emails,orders';
foreach (array_filter([$uid, $susp->id ?? null]) as $cid) {
    DB::table('tblusers_clients')->updateOrInsert(['auth_user_id' => $multi->id, 'client_id' => $cid],
        ['invite_id' => 0, 'owner' => 0, 'permissions' => $allPerms, 'created_at' => $now, 'updated_at' => $now]);
}
$ids['suspendedInvoiceId'] = isset($susp) ? (int) DB::table('tblinvoices')->where('userid', $susp->id)->orderBy('id')->value('id') : null;

// A pending invite to the full persona's account (user-invite-accept).
$inviteToken = hash('sha256', 'hadrian-test-invite-' . $uid);   // WHMCS-shaped: 64 hex
DB::table('tbluser_invites')->where('email', 'invitee' . DEMO_DOMAIN)->where('token', '!=', $inviteToken)->delete();
DB::table('tbluser_invites')->updateOrInsert(['token' => $inviteToken], [
    'email' => 'invitee' . DEMO_DOMAIN, 'client_id' => $uid, 'invited_by' => (int) DB::table('tblusers')->where('email', $creds['personas']['full']['email'])->value('id'),
    'invited_by_admin' => 0, 'permissions' => 'profile,products', 'accepted_at' => null, 'deleted_at' => null, 'created_at' => $now, 'updated_at' => $now,
]);
$ids['inviteToken'] = $inviteToken;

// A persona for the two-factor flows. Reset to "no 2FA" every run: the flow
// turns TOTP on through the security page, signs in again and uses it.
$tfaEmail = 'twofactor' . DEMO_DOMAIN;
$tfa = clientByEmail($tfaEmail);
if (!$tfa) {
    $apiOk('AddClient', [
        'firstname' => 'Tess', 'lastname' => 'Twofactor', 'email' => $tfaEmail, 'address1' => '3 Fixture Lane', 'city' => 'Leeds',
        'state' => 'West Yorkshire', 'postcode' => 'LS1 1AA', 'country' => 'GB', 'phonenumber' => '+44.1130000000',
        'password2' => DEMO_CLIENT_PASSWORD, 'notes' => 'hadrian-demo', 'noemail' => true, 'skipvalidation' => true,
    ]);
    $tfa = clientByEmail($tfaEmail);
}
DB::table('tblusers')->where('email', $tfaEmail)->update(['second_factor' => '', 'second_factor_config' => '', 'email_verified_at' => $now]);

// A client for the password-reset flow, which changes its password: put the
// known one back every run so the next run can sign in before resetting.
$resetEmail = 'reset.flow' . DEMO_DOMAIN;
$resetClient = clientByEmail($resetEmail);
if (!$resetClient) {
    $apiOk('AddClient', [
        'firstname' => 'Rhys', 'lastname' => 'Reset', 'email' => $resetEmail, 'address1' => '4 Fixture Lane', 'city' => 'York',
        'state' => 'North Yorkshire', 'postcode' => 'YO1 7HH', 'country' => 'GB', 'phonenumber' => '+44.1904000000',
        'password2' => DEMO_CLIENT_PASSWORD, 'notes' => 'hadrian-demo', 'noemail' => true, 'skipvalidation' => true,
    ]);
    $resetClient = clientByEmail($resetEmail);
}
$apiOk('UpdateClient', ['clientid' => (int) $resetClient->id, 'password2' => DEMO_CLIENT_PASSWORD, 'skipvalidation' => true]);
DB::table('tblusers')->where('email', $resetEmail)->update(['email_verified_at' => $now, 'reset_token' => '']);

// ------------------------------------------------------------- custom page entry
// hadrian/custom-page.php is the buyer-installed entry file for the shipped
// custom-page example (docs 07c). Copy it into the local install's root.
copy(dirname(__DIR__, 2) . '/hadrian/custom-page.php', $whmcsRoot . '/custom-page.php');

// ------------------------------------------------------------- personas + ids out
$scenarioPersonas = [
    'subuser'   => ['email' => $subEmail, 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => $uid],
    'twofactor' => ['email' => $tfaEmail, 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => (int) $tfa->id],
    'multi'     => ['email' => $multiEmail, 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => $uid],
    // The password-reset flow changes this one's password; reset above every run.
    'resettable' => ['email' => $resetEmail, 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => (int) $resetClient->id],
];
$ids['domainId'] = $domainId;
$ids['addonId'] = $addonId;
$scenarioIds = $ids;
