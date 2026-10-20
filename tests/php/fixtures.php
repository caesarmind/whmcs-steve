<?php
/**
 * Test fixtures - make sure every persona the suite logs in as exists, and
 * write the ids the routes need to tests/.local/fixtures.json.
 *
 *   php tests/php/fixtures.php
 *
 * Idempotent: it ENSURES records, it never resets them, so running it against
 * a local install you have been clicking around in changes nothing you made.
 * (A full reset is run.mjs --fresh, which restores a DB dump instead.)
 *
 * Credentials are test values for this local install only. They are generated
 * here, kept in tests/.local/credentials.json (gitignored), and never printed.
 * Refuses to run unless SystemURL is localhost.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
$localDir  = dirname(__DIR__) . '/.local';
@mkdir($localDir, 0777, true);

chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule;

$systemUrl = (string) Capsule::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

// The seeder's fixture password for demo clients. Kept in one place there;
// mirrored here because the seeder is a CLI script, not an includable library.
const DEMO_CLIENT_PASSWORD = 'HadrianDemo!2026';
const TEST_ADMIN_USERNAME  = 'hadrian-test';
const DEMO_DOMAIN          = '@demo.hadrian.test';

$credFile = $localDir . '/credentials.json';
$creds = is_file($credFile) ? (json_decode((string) file_get_contents($credFile), true) ?: []) : [];

// ------------------------------------------------------------------ test admin
// Bcrypt, the same as the installer writes into BOTH columns (verified against
// the installer-created admin: password and passwordhash are both $2y$10$...).
// run.mjs proves it works by logging in, so a format change in a future WHMCS
// shows up as a failed preflight rather than as 40 confusing admin failures.
$adminPass = $creds['admin']['password'] ?? rtrim(strtr(base64_encode(random_bytes(18)), '+/', 'Aa'), '=');
$hash = password_hash($adminPass, PASSWORD_BCRYPT);
$now = date('Y-m-d H:i:s');
$admin = Capsule::table('tbladmins')->where('username', TEST_ADMIN_USERNAME)->first();
if ($admin) {
    // Re-sync the hash every run: cheap, and it heals a password someone
    // changed by hand in the admin UI.
    Capsule::table('tbladmins')->where('id', $admin->id)->update([
        'password' => $hash, 'passwordhash' => $hash, 'disabled' => 0, 'loginattempts' => 0, 'updated_at' => $now,
    ]);
    $adminId = (int) $admin->id;
} else {
    $roleId = (int) Capsule::table('tbladminroles')->where('name', 'Full Administrator')->value('id')
        ?: (int) Capsule::table('tbladminroles')->orderBy('id')->value('id');
    $adminId = (int) Capsule::table('tbladmins')->insertGetId([
        'uuid' => sprintf('%04x%04x-%04x-4%03x-%04x-%04x%04x%04x',
            random_int(0, 0xffff), random_int(0, 0xffff), random_int(0, 0xffff), random_int(0, 0xfff),
            random_int(0, 0x3fff) | 0x8000, random_int(0, 0xffff), random_int(0, 0xffff), random_int(0, 0xffff)),
        'roleid' => $roleId, 'username' => TEST_ADMIN_USERNAME,
        'password' => $hash, 'passwordhash' => $hash, 'authmodule' => '', 'authdata' => '',
        'firstname' => 'Hadrian', 'lastname' => 'Test Suite', 'email' => 'test-admin' . DEMO_DOMAIN,
        'signature' => '', 'notes' => 'Automated test account (tests/php/fixtures.php). Safe to delete.',
        'template' => 'blend', 'language' => '', 'disabled' => 0, 'loginattempts' => 0,
        'supportdepts' => '', 'ticketnotifications' => '', 'homewidgets' => '',
        'password_reset_key' => '', 'password_reset_data' => '', 'password_reset_expiry' => $now,
        'hidden_widgets' => '', 'widget_order' => '', 'mixpanel_tracking_enabled' => 0,
        'created_at' => $now, 'updated_at' => $now,
    ]);
}

// ------------------------------------------------- clean up after flow tests
// tests/e2e/flows.spec.mjs creates real records: a new customer per checkout
// run (flow+<n>@demo.hadrian.test) and tickets titled "[flow] ...". Remove the
// previous run's, so they never pile up or leak into the personas.
foreach (Capsule::table('tblclients')->where('email', 'like', 'flow+%' . DEMO_DOMAIN)->pluck('id') as $cid) {
    localAPI('DeleteClient', ['clientid' => (int) $cid, 'deleteusers' => true, 'deletetransactions' => true], TEST_ADMIN_USERNAME);
}
Capsule::table('tblusers')->where('email', 'like', 'flow+%' . DEMO_DOMAIN)->delete();
$flowTickets = Capsule::table('tbltickets')->where('title', 'like', '[flow]%')->pluck('id')->all();
if ($flowTickets) {
    Capsule::table('tblticketreplies')->whereIn('tid', $flowTickets)->delete();
    Capsule::table('tbltickets')->whereIn('id', $flowTickets)->delete();
}
// ...and their notification emails, which otherwise keep linking (in the
// client's email history) to tickets that no longer exist.
Capsule::table('tblemails')->where('subject', 'like', '%[flow]%')->delete();

// --------------------------------------------------------------------- clients
function clientByEmail(string $email): ?object
{
    return Capsule::table('tblclients')->where('email', $email)->first();
}

$full = clientByEmail('mara.okonkwo' . DEMO_DOMAIN);
if (!$full) {
    fwrite(STDERR, "Demo data missing - run: php scripts/local-stack/seed-demo-data.php\n");
    exit(3);
}

// The empty persona exists so every page's when-empty state gets rendered:
// an active client with no services, domains, invoices or tickets.
$emptyEmail = 'empty.client' . DEMO_DOMAIN;
$empty = clientByEmail($emptyEmail);
if (!$empty) {
    $r = localAPI('AddClient', [
        'firstname' => 'Erin', 'lastname' => 'Empty', 'email' => $emptyEmail,
        'address1' => '1 Fixture Lane', 'city' => 'London', 'state' => 'Greater London',
        'postcode' => 'EC1A 1BB', 'country' => 'GB', 'phonenumber' => '+44 20 7946 0000',
        'password2' => DEMO_CLIENT_PASSWORD, 'notes' => 'hadrian-demo', 'noemail' => true, 'skipvalidation' => true,
    ], TEST_ADMIN_USERNAME);
    if (($r['result'] ?? '') !== 'success') {
        fwrite(STDERR, 'AddClient (empty persona) failed: ' . json_encode($r) . "\n");
        exit(4);
    }
    $empty = clientByEmail($emptyEmail);
}

// The suspended persona: a client whose service is Suspended (the seeder's
// Amelia Frost), so suspension banners and disabled actions get exercised.
$susp = Capsule::table('tblclients as c')
    ->join('tblhosting as h', 'h.userid', '=', 'c.id')
    ->where('h.domainstatus', 'Suspended')->where('c.email', 'like', '%' . DEMO_DOMAIN)
    ->select('c.*')->first();

// A gateway that can STORE payment methods. With only bank transfer active,
// WHMCS bounces /account/paymentmethods to the account-details page, so the
// payment-methods templates would never render under test. Offline Credit
// Card is a stock WHMCS gateway and takes no real card data on a local box.
if (!Capsule::table('tblpaymentgateways')->where('gateway', 'offlinecc')->exists()) {
    $order = (int) Capsule::table('tblpaymentgateways')->max('order') + 1;
    foreach (['name' => 'Credit Card (offline, test)', 'type' => 'CC', 'visible' => 'on'] as $k => $v) {
        Capsule::table('tblpaymentgateways')->insert(['gateway' => 'offlinecc', 'setting' => $k, 'value' => $v, 'order' => $order]);
    }
}

// The full persona is an affiliate, so /affiliates.php renders the affiliate
// dashboard (core/pages/affiliates) for it and the sign-up page for 'empty'.
// That dashboard rendered blank for months (e6547a5) - it needs a persona.
if (!Capsule::table('tblaffiliates')->where('clientid', $full->id)->exists()) {
    $r = localAPI('AffiliateActivate', ['userid' => (int) $full->id], TEST_ADMIN_USERNAME);
    if (($r['result'] ?? '') !== 'success') {
        fwrite(STDERR, 'AffiliateActivate failed: ' . json_encode($r) . "\n");
        exit(5);
    }
}

// ------------------------------------------------------- ids the routes need
$uid = (int) $full->id;
$firstId = fn(string $table, array $where, string $col = 'id') =>
    ($q = Capsule::table($table)->where($where)->orderBy('id')->value($col)) !== null ? $q : null;

$ticket = Capsule::table('tbltickets')->where('userid', $uid)->orderBy('id')->first();
$ids = [
    'serviceId'      => $firstId('tblhosting', [['userid', '=', $uid], ['domainstatus', '=', 'Active']]),
    'domainId'       => $firstId('tbldomains', [['userid', '=', $uid]]),
    'invoiceId'      => $firstId('tblinvoices', [['userid', '=', $uid]]),
    'unpaidInvoiceId'=> $firstId('tblinvoices', [['userid', '=', $uid], ['status', '=', 'Unpaid']]),
    'ticketTid'      => $ticket->tid ?? null,
    'ticketC'        => $ticket->c ?? null,
    'announcementId' => Capsule::table('tblannouncements')->where('published', 1)->orderBy('id')->value('id'),
    'productGroupSlug' => Capsule::table('tblproductgroups')->orderBy('order')->value('slug'),
    'productId'      => Capsule::table('tblproducts')->orderBy('id')->value('id'),
    // WHMCS 8+ keeps store URLs in tblproducts_slugs, not tblproducts.slug.
    'productPath'    => ($s = Capsule::table('tblproducts_slugs')->where('active', 1)->orderByDesc('id')->first()) ? $s->group_slug . '/' . $s->slug : null,
    'deptId'         => Capsule::table('tblticketdepartments')->orderBy('order')->value('id'),
    'suspendedServiceId' => $susp ? Capsule::table('tblhosting')->where('userid', $susp->id)->where('domainstatus', 'Suspended')->value('id') : null,
];

// Users (the login identities) are separate from clients in WHMCS 8+.
$loginOf = fn(?object $c) => $c ? (string) Capsule::table('tblusers')->where('email', $c->email)->value('email') : null;

$creds = [
    'admin' => ['username' => TEST_ADMIN_USERNAME, 'password' => $adminPass, 'id' => $adminId],
    'personas' => [
        'full'      => ['email' => $loginOf($full),  'password' => DEMO_CLIENT_PASSWORD, 'clientId' => (int) $full->id],
        'empty'     => ['email' => $loginOf($empty), 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => (int) $empty->id],
        'suspended' => $susp ? ['email' => $loginOf($susp), 'password' => DEMO_CLIENT_PASSWORD, 'clientId' => (int) $susp->id] : null,
    ],
];
file_put_contents($credFile, json_encode($creds, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
file_put_contents($localDir . '/fixtures.json', json_encode([
    'systemUrl' => $systemUrl,
    'generatedAt' => date('c'),
    'ids' => $ids,
    'personas' => array_map(fn($p) => $p ? ['clientId' => $p['clientId']] : null, $creds['personas']),
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

// Summary without secrets.
printf("test admin: %s (id %d)\n", TEST_ADMIN_USERNAME, $adminId);
foreach ($creds['personas'] as $name => $p) {
    printf("persona %-9s %s\n", $name, $p ? "client #{$p['clientId']}" : 'MISSING');
}
foreach ($ids as $k => $v) { printf("  %-16s %s\n", $k, $v === null ? '(none)' : $v); }
echo "wrote tests/.local/fixtures.json and credentials.json\n";
