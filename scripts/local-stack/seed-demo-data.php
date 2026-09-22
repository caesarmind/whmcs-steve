<?php
/**
 * Hadrian local stack - demo data seeder.
 *
 *   php scripts/local-stack/seed-demo-data.php            # seed
 *   php scripts/local-stack/seed-demo-data.php --force    # re-seed over existing demo data
 *   php scripts/local-stack/seed-demo-data.php --wipe     # remove demo data, seed nothing
 *
 * Fills a freshly installed local WHMCS with plausible catalogue and customer
 * data so the theme can be exercised against real pages: populated tables,
 * paginated lists, mixed statuses, overdue invoices, expiring domains.
 *
 * Everything goes through WHMCS's own local API wherever one exists (AddClient,
 * AddProduct, AddOrder, AcceptOrder, OpenTicket), so pricing rows, service
 * records, invoice items and totals are built by WHMCS itself rather than by
 * hand-written INSERTs that would drift from the schema. Only objects with no
 * API - product groups, ticket departments, announcements - are inserted
 * directly.
 *
 * ALL PEOPLE AND COMPANIES BELOW ARE FICTIONAL. The client logins exist so the
 * client area can be viewed with data in it; they are local fixtures and the
 * shared password is printed at the end. Never point this script at anything
 * but a local install.
 */

declare(strict_types=1);

$whmcsRoot = 'C:/laragon/www/whmcs';
$force = in_array('--force', $argv, true);
$wipe  = in_array('--wipe', $argv, true);

// Fixture password for the demo client logins. Local-only.
const DEMO_CLIENT_PASSWORD = 'HadrianDemo!2026';

if (!is_file($whmcsRoot . '/init.php')) {
    fwrite(STDERR, "WHMCS not found at {$whmcsRoot}\n");
    exit(1);
}

// A hard stop: this script writes a lot of rows and must never touch production.
$host = strtolower((string) ($_SERVER['HTTP_HOST'] ?? 'localhost'));
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule;

$systemUrl = (string) Capsule::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(1);
}

// ---------------------------------------------------------------- prerequisites
$adminUser = (string) Capsule::table('tbladmins')->orderBy('id')->value('username');
if ($adminUser === '') {
    fwrite(STDERR, "No admin account exists yet - finish the WHMCS installer first.\n");
    exit(1);
}
echo "admin user: {$adminUser}\n";

// NB: the flag column is literally named `default` (a reserved word), not
// `default_currency` - it has to be back-quoted in raw SQL.
if (!Capsule::table('tblcurrencies')->exists()) {
    Capsule::table('tblcurrencies')->insert([
        'code' => 'USD', 'prefix' => '$', 'suffix' => ' USD', 'format' => 1,
        'rate' => '1.00000', 'default' => 1,
    ]);
    echo "created default currency USD\n";
}
$currencyId = (int) Capsule::table('tblcurrencies')->where('default', 1)->value('id');
if (!$currencyId) { $currencyId = (int) Capsule::table('tblcurrencies')->orderBy('id')->value('id'); }
echo "currency id: {$currencyId}\n";

/** Call the WHMCS local API and fail loudly. */
function api(string $command, array $values = []): array
{
    global $adminUser;
    $r = localAPI($command, $values, $adminUser);
    if (($r['result'] ?? '') !== 'success') {
        throw new RuntimeException($command . ' failed: ' . json_encode($r));
    }
    return $r;
}

// ---------------------------------------------------------------- wipe
/** Demo rows are identified by the marker below, so a wipe never eats real data. */
const DEMO_MARKER = 'hadrian-demo';

function wipeDemo(): void
{
    $clientIds = Capsule::table('tblclients')->where('notes', 'like', '%' . DEMO_MARKER . '%')->pluck('id')->all();
    if ($clientIds) {
        $invoiceIds = Capsule::table('tblinvoices')->whereIn('userid', $clientIds)->pluck('id')->all();
        if ($invoiceIds) {
            Capsule::table('tblinvoiceitems')->whereIn('invoiceid', $invoiceIds)->delete();
            Capsule::table('tblaccounts')->whereIn('invoiceid', $invoiceIds)->delete();
            Capsule::table('tblinvoices')->whereIn('id', $invoiceIds)->delete();
        }
        $ticketIds = Capsule::table('tbltickets')->whereIn('userid', $clientIds)->pluck('id')->all();
        if ($ticketIds) {
            Capsule::table('tblticketreplies')->whereIn('tid', $ticketIds)->delete();
            Capsule::table('tbltickets')->whereIn('id', $ticketIds)->delete();
        }
        Capsule::table('tblhosting')->whereIn('userid', $clientIds)->delete();
        Capsule::table('tbldomains')->whereIn('userid', $clientIds)->delete();
        Capsule::table('tblorders')->whereIn('userid', $clientIds)->delete();
        Capsule::table('tblclients')->whereIn('id', $clientIds)->delete();
        Capsule::table('tblusers')->where('email', 'like', '%@demo.hadrian.test')->delete();
        echo 'wiped ' . count($clientIds) . " demo clients and their records\n";
    }
    $groupIds = Capsule::table('tblproductgroups')->where('tagline', 'like', '%' . DEMO_MARKER . '%')->pluck('id')->all();
    if ($groupIds) {
        $productIds = Capsule::table('tblproducts')->whereIn('gid', $groupIds)->pluck('id')->all();
        if ($productIds) {
            Capsule::table('tblpricing')->where('type', 'product')->whereIn('relid', $productIds)->delete();
            Capsule::table('tblproducts')->whereIn('id', $productIds)->delete();
        }
        Capsule::table('tblproductgroups')->whereIn('id', $groupIds)->delete();
        echo 'wiped ' . count($groupIds) . " demo product groups\n";
    }
    Capsule::table('tblannouncements')->where('announcement', 'like', '%' . DEMO_MARKER . '%')->delete();
}

if ($wipe) { wipeDemo(); echo "done (wipe only)\n"; exit(0); }

if (Capsule::table('tblproducts')->exists() && !$force) {
    fwrite(STDERR, "Products already exist. Re-run with --force to wipe demo data and re-seed.\n");
    exit(1);
}
if ($force) { wipeDemo(); }

// ---------------------------------------------------------------- catalogue
/**
 * Product groups and their products. Prices are plain monthly/annual figures;
 * annual is deliberately ~10 months of monthly so the cart's "save" maths has
 * something real to show.
 */
$catalogue = [
    [
        'name' => 'Shared Hosting',
        'headline' => 'Fast, managed hosting for sites that need to just work',
        'products' => [
            ['Starter',      'Single site, 10 GB NVMe, free SSL, daily backups.',            4.00,  40.00,  0.00],
            ['Professional', '10 sites, 50 GB NVMe, staging areas, priority support.',       9.00,  90.00,  0.00],
            ['Business',     'Unlimited sites, 150 GB NVMe, dedicated IP, 24/7 support.',   19.00, 190.00, 15.00],
        ],
    ],
    [
        'name' => 'VPS Hosting',
        'headline' => 'Root access, NVMe storage, deployed in under a minute',
        'products' => [
            ['VPS 2 GB',  '2 vCPU, 2 GB RAM, 50 GB NVMe, 2 TB transfer.',    12.00, 120.00, 0.00],
            ['VPS 4 GB',  '4 vCPU, 4 GB RAM, 100 GB NVMe, 4 TB transfer.',   24.00, 240.00, 0.00],
            ['VPS 8 GB',  '8 vCPU, 8 GB RAM, 200 GB NVMe, 8 TB transfer.',   48.00, 480.00, 0.00],
        ],
    ],
    [
        'name' => 'Dedicated Servers',
        'headline' => 'Single-tenant hardware with full IPMI access',
        'products' => [
            ['DS Entry', 'Xeon E-2336, 32 GB ECC, 2 x 960 GB NVMe.',        89.00,  890.00, 49.00],
            ['DS Pro',   'Dual Xeon Silver 4314, 128 GB ECC, 4 x 2 TB NVMe.', 219.00, 2190.00, 99.00],
        ],
    ],
    [
        'name' => 'SSL Certificates',
        'headline' => 'Issued and installed for you',
        'products' => [
            ['DV SSL',       'Domain-validated certificate, issued in minutes.',  0.00,  15.00, 0.00],
            ['Wildcard SSL', 'Covers a domain and every first-level subdomain.',  0.00,  95.00, 0.00],
        ],
    ],
    [
        'name' => 'Managed WordPress',
        'headline' => 'WordPress with updates, caching and backups handled',
        'products' => [
            ['WP Personal', 'One WordPress site, managed updates, CDN.',        7.00,  70.00, 0.00],
            ['WP Agency',   '25 WordPress sites, staging, white-label reports.', 39.00, 390.00, 0.00],
        ],
    ],
];

echo "== catalogue ==\n";
$productIds = [];   // name => id
$order = 0;
foreach ($catalogue as $group) {
    $gid = (int) Capsule::table('tblproductgroups')->insertGetId([
        'name'        => $group['name'],
        'slug'        => strtolower(str_replace(' ', '-', $group['name'])),
        'headline'    => $group['headline'],
        'tagline'     => DEMO_MARKER,
        'orderfrmtpl' => '',
        'disabledgateways' => '',   // NOT NULL, no default
        'hidden'      => 0,
        'order'       => $order++,
        'created_at'  => date('Y-m-d H:i:s'),
        'updated_at'  => date('Y-m-d H:i:s'),
    ]);
    echo "  group: {$group['name']} (#{$gid})\n";

    foreach ($group['products'] as [$name, $desc, $monthly, $annually, $setup]) {
        $values = [
            'type'        => 'hostingaccount',
            'gid'         => $gid,
            'name'        => $name,
            'description' => $desc,
            'paytype'     => $monthly > 0 ? 'recurring' : 'onetime',
            'hidden'      => false,
            'showdomainoptions' => in_array($group['name'], ['Shared Hosting', 'Managed WordPress'], true),
        ];
        if ($monthly > 0) {
            $values['pricing'] = [$currencyId => ['monthly' => $monthly, 'annually' => $annually, 'msetupfee' => $setup]];
        } else {
            $values['pricing'] = [$currencyId => ['annually' => $annually]];
        }
        $r = api('AddProduct', $values);
        $productIds[$name] = (int) $r['pid'];
        echo "    product: {$name} (#{$r['pid']})  \$" . number_format($monthly, 2) . "/mo\n";
    }
}

// ---------------------------------------------------------------- clients
/** Fictional customers, deliberately spread across countries and states. */
$clients = [
    ['Mara',   'Okonkwo',   'Riverbend Studio',      'mara.okonkwo',   'GB', 'London',        'Greater London', 'EC2A 4NE', '20 Bishopsgate',      '+44 20 7946 0112'],
    ['Tomas',  'Lindqvist', 'Nordlys AB',            'tomas.lindqvist','SE', 'Gothenburg',    'Vastra Gotaland','411 03',   'Kungsportsavenyn 14', '+46 31 123 456'],
    ['Priya',  'Raghunath', 'Kestrel Analytics',     'priya.raghunath','US', 'Austin',        'TX',             '78701',    '600 Congress Ave',    '+1 512 555 0148'],
    ['Diego',  'Fuentes',   'Estudio Mirador',       'diego.fuentes',  'ES', 'Valencia',      'Valencia',       '46002',    'Carrer de Colon 32',  '+34 96 123 45 67'],
    ['Hanne',  'Vestergaard','Klit Bureau',          'hanne.v',        'DK', 'Aarhus',        'Midtjylland',    '8000',     'Store Torv 5',        '+45 86 12 34 56'],
    ['Kenji',  'Watanabe',   'Hibiya Works',         'kenji.watanabe', 'JP', 'Tokyo',         'Tokyo',          '100-0006', '1-2-3 Marunouchi',    '+81 3 1234 5678'],
    ['Amelia', 'Frost',      '',                     'amelia.frost',   'AU', 'Melbourne',     'VIC',            '3000',     '120 Collins Street',  '+61 3 9000 1234'],
    ['Youssef','Benali',     'Atlas Cloud',          'youssef.benali', 'FR', 'Lyon',          'Auvergne-Rhone-Alpes', '69002','12 Rue de la Republique', '+33 4 72 00 11 22'],
    ['Greta',  'Hoffmann',   'Werkstatt Neun',       'greta.hoffmann', 'DE', 'Leipzig',       'Sachsen',        '04109',    'Katharinenstrasse 9', '+49 341 998 7654'],
    ['Nuno',   'Barreto',    '',                     'nuno.barreto',   'PT', 'Porto',         'Porto',          '4050-253', 'Rua de Cedofeita 88', '+351 22 123 4567'],
    ['Sofia',  'Marchetti',  'Ponte Digitale',       'sofia.marchetti','IT', 'Bologna',       'Emilia-Romagna', '40121',    'Via Ugo Bassi 15',    '+39 051 123 456'],
    ['Ruth',   'Vandermeer', 'Polder Media',         'ruth.v',         'NL', 'Utrecht',       'Utrecht',        '3511 LN',  'Oudegracht 210',      '+31 30 123 4567'],
    ['Oliver', 'Kingsley',   'Kingsley & Co',        'oliver.kingsley','CA', 'Toronto',       'ON',             'M5H 2N2',  '100 King Street West','+1 416 555 0190'],
    ['Ines',   'Cardoso',    '',                     'ines.cardoso',   'BR', 'Sao Paulo',     'SP',             '01310-100','Av. Paulista 1000',   '+55 11 91234 5678'],
];

echo "== clients ==\n";
$clientIds = [];
foreach ($clients as $i => [$first, $last, $company, $handle, $country, $city, $state, $zip, $addr, $phone]) {
    $r = api('AddClient', [
        'firstname'   => $first,
        'lastname'    => $last,
        'companyname' => $company,
        'email'       => $handle . '@demo.hadrian.test',
        'address1'    => $addr,
        'city'        => $city,
        'state'       => $state,
        'postcode'    => $zip,
        'country'     => $country,
        'phonenumber' => $phone,
        'password2'   => DEMO_CLIENT_PASSWORD,
        'currency'    => $currencyId,
        'notes'       => DEMO_MARKER,
        'noemail'     => true,
        'skipvalidation' => true,
    ]);
    $clientIds[] = (int) $r['clientid'];
    echo "    {$first} {$last}" . ($company ? " ({$company})" : '') . " -> #{$r['clientid']}\n";
}

// A couple of non-active clients so status filters have something to filter.
Capsule::table('tblclients')->where('id', $clientIds[12])->update(['status' => 'Inactive']);
Capsule::table('tblclients')->where('id', $clientIds[13])->update(['status' => 'Closed']);

// ---------------------------------------------------------------- services
/**
 * Orders placed through the API so WHMCS builds the service + invoice rows.
 * Statuses and dates are adjusted afterwards to spread the data across the
 * lifecycle: active, pending, suspended, cancelled, and due-soon.
 */
echo "== orders & services ==\n";
$plan = [
    // [client index, product name, billing cycle, domain, service status, days until due]
    [0,  'Business',      'annually',  'riverbendstudio.co.uk',  'Active',     212],
    [0,  'VPS 4 GB',      'monthly',   '',                       'Active',      14],
    [1,  'Professional',  'annually',  'nordlys.se',             'Active',      96],
    [2,  'DS Pro',        'monthly',   '',                       'Active',       6],
    [2,  'Wildcard SSL',  'annually',  'kestrelanalytics.com',   'Active',     301],
    [3,  'Starter',       'monthly',   'estudiomirador.es',      'Active',      21],
    [4,  'WP Agency',     'annually',  'klitbureau.dk',          'Active',     144],
    [5,  'VPS 8 GB',      'monthly',   '',                       'Active',      28],
    [6,  'WP Personal',   'monthly',   'ameliafrost.au',         'Suspended',  -12],
    [7,  'Professional',  'monthly',   'atlascloud.fr',          'Active',       3],
    [8,  'VPS 2 GB',      'monthly',   'werkstattneun.de',       'Active',      17],
    [9,  'Starter',       'annually',  'nunobarreto.pt',         'Cancelled',  -64],
    [10, 'DS Entry',      'monthly',   'pontedigitale.it',       'Active',      11],
    [11, 'Business',      'monthly',   'poldermedia.nl',         'Active',      25],
    [12, 'Professional',  'annually',  'kingsleyco.ca',          'Terminated', -148],
    [0,  'DV SSL',        'annually',  'riverbendstudio.co.uk',  'Active',     188],
    [2,  'VPS 2 GB',      'monthly',   '',                       'Pending',     30],
    [5,  'Starter',       'monthly',   '',                       'Active',       9],
];

$createdInvoices = [];
foreach ($plan as [$ci, $productName, $cycle, $domain, $status, $dueInDays]) {
    if (!isset($productIds[$productName])) { continue; }
    $values = [
        'clientid'      => $clientIds[$ci],
        'pid'           => [$productIds[$productName]],
        'billingcycle'  => [$cycle],
        'paymentmethod' => 'banktransfer',
        'noemail'       => true,
        'noinvoiceemail'=> true,
    ];
    if ($domain !== '') { $values['domain'] = [$domain]; }

    $r = api('AddOrder', $values);
    $orderId = (int) $r['orderid'];
    if (!empty($r['invoiceid'])) { $createdInvoices[] = (int) $r['invoiceid']; }

    // Accepting turns the order into a live service.
    if ($status !== 'Pending') {
        try {
            api('AcceptOrder', ['orderid' => $orderId, 'autosetup' => false, 'sendemail' => false]);
        } catch (RuntimeException $e) {
            echo "    (accept skipped for order #{$orderId}: " . $e->getMessage() . ")\n";
        }
    }

    $svcId = (int) Capsule::table('tblhosting')->where('orderid', $orderId)->orderBy('id', 'desc')->value('id');
    if ($svcId) {
        $regdate = date('Y-m-d', strtotime('-' . random_int(30, 900) . ' days'));
        Capsule::table('tblhosting')->where('id', $svcId)->update([
            'domainstatus' => $status === 'Pending' ? 'Pending' : $status,
            'regdate'      => $regdate,
            'nextduedate'  => date('Y-m-d', strtotime($dueInDays . ' days')),
            'nextinvoicedate' => date('Y-m-d', strtotime($dueInDays . ' days')),
        ]);
    }
    echo "    client #{$clientIds[$ci]}  {$productName}  {$cycle}  {$status}"
        . ($domain ? "  {$domain}" : '') . "\n";
}

// ---------------------------------------------------------------- domains
echo "== domains ==\n";
$domains = [
    [0,  'riverbendstudio.co.uk', 'Active',   1,  412],
    [1,  'nordlys.se',            'Active',   1,   96],
    [2,  'kestrelanalytics.com',  'Active',   2,  301],
    [3,  'estudiomirador.es',     'Active',   1,   47],
    [4,  'klitbureau.dk',         'Active',   1,  144],
    [6,  'ameliafrost.au',        'Expired',  1,  -22],
    [7,  'atlascloud.fr',         'Active',   1,   19],
    [8,  'werkstattneun.de',      'Active',   1,  233],
    [10, 'pontedigitale.it',      'Active',   1,  168],
    [11, 'poldermedia.nl',        'Active',   3,  505],
    [12, 'kingsleyco.ca',         'Cancelled',1, -210],
    [5,  'hibiyaworks.jp',        'Active',   1,   64],
];
foreach ($domains as [$ci, $name, $status, $years, $expiresInDays]) {
    $exists = Capsule::table('tbldomains')->where('domain', $name)->exists();
    if ($exists) { continue; }
    $price = $name === 'poldermedia.nl' ? 34.00 : 14.00;
    Capsule::table('tbldomains')->insert([
        'userid'         => $clientIds[$ci],
        'orderid'        => 0,
        'type'           => 'Register',
        'registrationdate' => date('Y-m-d', strtotime('-' . ($years * 365 - max($expiresInDays, 0)) . ' days')),
        'domain'         => $name,
        'firstpaymentamount' => $price,
        'recurringamount'=> $price,
        'registrar'      => 'enom',
        'registrationperiod' => $years,
        'expirydate'     => date('Y-m-d', strtotime($expiresInDays . ' days')),
        'nextduedate'    => date('Y-m-d', strtotime($expiresInDays . ' days')),
        'nextinvoicedate'=> date('Y-m-d', strtotime($expiresInDays . ' days')),
        'status'         => $status,
        'paymentmethod'  => 'banktransfer',
        // These are NOT NULL with no default in tbldomains, so pass them explicitly.
        'subscriptionid' => '',
        'promoid'        => 0,
        'additionalnotes'=> '',
        'dnsmanagement'  => 1,
        'emailforwarding'=> 0,
        'idprotection'   => (int) ($ci % 2 === 0),
        'donotrenew'     => 0,
        'reminders'      => '',
        'synced'         => 0,
    ]);
    echo "    {$name}  {$status}  expires " . date('Y-m-d', strtotime($expiresInDays . ' days')) . "\n";
}

// ---------------------------------------------------------------- invoices
/**
 * Spread invoice states: most paid, a few unpaid, two pushed into the past so
 * they read as overdue, and one cancelled.
 */
echo "== invoices ==\n";
$invoices = Capsule::table('tblinvoices')->whereIn('userid', $clientIds)->orderBy('id')->pluck('id')->all();
foreach ($invoices as $i => $invId) {
    $mod = $i % 7;
    if ($mod <= 3) {
        $paidOn = date('Y-m-d', strtotime('-' . random_int(2, 240) . ' days'));
        Capsule::table('tblinvoices')->where('id', $invId)->update([
            'status' => 'Paid', 'datepaid' => $paidOn . ' ' . sprintf('%02d:%02d:00', random_int(8, 19), random_int(0, 59)),
            'date' => $paidOn, 'duedate' => $paidOn,
            'paymentmethod' => 'banktransfer',
        ]);
    } elseif ($mod === 4) {
        $due = date('Y-m-d', strtotime('-' . random_int(6, 40) . ' days'));
        Capsule::table('tblinvoices')->where('id', $invId)->update([
            'status' => 'Unpaid', 'date' => date('Y-m-d', strtotime($due . ' -14 days')), 'duedate' => $due,
        ]);
    } elseif ($mod === 5) {
        $due = date('Y-m-d', strtotime('+' . random_int(3, 21) . ' days'));
        Capsule::table('tblinvoices')->where('id', $invId)->update([
            'status' => 'Unpaid', 'date' => date('Y-m-d'), 'duedate' => $due,
        ]);
    } else {
        Capsule::table('tblinvoices')->where('id', $invId)->update(['status' => 'Cancelled']);
    }
}
$counts = Capsule::table('tblinvoices')->whereIn('userid', $clientIds)
    ->selectRaw('status, COUNT(*) as n')->groupBy('status')->pluck('n', 'status')->all();
foreach ($counts as $status => $n) { echo "    {$status}: {$n}\n"; }

// ---------------------------------------------------------------- tickets
echo "== tickets ==\n";
$deptId = (int) Capsule::table('tblticketdepartments')->orderBy('id')->value('id');
if (!$deptId) {
    // host/port/login/password are the POP import settings: NOT NULL with no
    // default, so they have to be written even though we leave them empty.
    $mailCols = ['host' => '', 'port' => '', 'login' => '', 'password' => ''];
    $deptId = (int) Capsule::table('tblticketdepartments')->insertGetId(array_merge([
        'name' => 'Technical Support', 'description' => 'Help with services and servers',
        'email' => 'support@demo.hadrian.test', 'clientsonly' => '', 'piperepliesonly' => '',
        'noautoresponder' => '', 'hidden' => '', 'order' => 0,
    ], $mailCols));
    Capsule::table('tblticketdepartments')->insert(array_merge([
        'name' => 'Billing', 'description' => 'Invoices, payments and refunds',
        'email' => 'billing@demo.hadrian.test', 'clientsonly' => '', 'piperepliesonly' => '',
        'noautoresponder' => '', 'hidden' => '', 'order' => 1,
    ], $mailCols));
    echo "    created ticket departments\n";
}
$deptIds = Capsule::table('tblticketdepartments')->pluck('id')->all();

$tickets = [
    [0,  'SSL certificate not renewing automatically', 'The wildcard certificate on riverbendstudio.co.uk expired last night even though auto-renew is on. Can you take a look?', 'Open',     'High'],
    [2,  'Increase disk on DS Pro',                    'We are at 84% on the primary array. What are the options for adding a pair of 2 TB NVMe drives?',                        'Answered', 'Medium'],
    [3,  'Migrate from old host',                      'I have a cPanel backup from my previous provider, about 6 GB. Can you restore it onto the Starter plan?',                'Open',     'Medium'],
    [7,  'Invoice 1042 paid twice',                    'It looks like the bank transfer went through twice this month. Could you credit the second one?',                        'Customer-Reply', 'Medium'],
    [10, 'IPMI console keeps dropping',                'The remote console disconnects after roughly 30 seconds. Firmware is current.',                                          'In Progress', 'High'],
    [1,  'Add a staging site',                         'How do I spin up a staging copy on the Professional plan?',                                                              'Closed',   'Low'],
    [11, 'DNS propagation question',                   'Changed the A record two hours ago, still seeing the old IP from some locations. Normal?',                               'Closed',   'Low'],
];
foreach ($tickets as $i => [$ci, $subject, $message, $status, $priority]) {
    try {
        $r = api('OpenTicket', [
            'clientid' => $clientIds[$ci],
            'deptid'   => $deptIds[$i % count($deptIds)],
            'subject'  => $subject,
            'message'  => $message,
            'priority' => $priority,
            'noemail'  => true,
        ]);
        $tid = (int) $r['id'];
        Capsule::table('tbltickets')->where('id', $tid)->update([
            'status' => $status,
            'date'   => date('Y-m-d H:i:s', strtotime('-' . random_int(1, 45) . ' days')),
        ]);
        echo "    [{$status}] {$subject}\n";
    } catch (RuntimeException $e) {
        echo "    (ticket skipped: " . $e->getMessage() . ")\n";
    }
}

// ---------------------------------------------------------------- announcements
/**
 * WHMCS announcements carry a title, a date and a body - no categories or tags.
 */
echo "== announcements ==\n";
$announcements = [
    ['Scheduled maintenance: Frankfurt (FRA1)', '-3 days',
     "We will be replacing a core switch in FRA1 on Sunday between 02:00 and 04:00 UTC. Traffic will fail over to the secondary path; brief packet loss of under a minute is possible during the cutover."],
    ['NVMe upgrade completed across shared hosting', '-18 days',
     "All shared hosting nodes have moved to NVMe storage. No action is needed. Average time-to-first-byte on the fleet dropped by roughly 40%."],
    ['New: 8 GB VPS plan', '-41 days',
     "The VPS range now goes up to 8 vCPU / 8 GB RAM with 200 GB of NVMe. Existing VPS customers can upgrade in place from the client area with no reinstall."],
    ['TLS 1.0 and 1.1 retirement', '-76 days',
     "Both protocols are now disabled on all customer-facing endpoints. Modern browsers and clients are unaffected."],
];
foreach ($announcements as [$title, $when, $body]) {
    Capsule::table('tblannouncements')->insert([
        'date'         => date('Y-m-d H:i:s', strtotime($when)),
        'title'        => $title,
        'announcement' => $body . "\n\n<!-- " . DEMO_MARKER . " -->",
        'published'    => 1,
        // NOT NULL with no default.
        'parentid'     => 0,
        'language'     => '',
        'created_at'   => date('Y-m-d H:i:s'),
        'updated_at'   => date('Y-m-d H:i:s'),
    ]);
    echo "    {$title}\n";
}

// ---------------------------------------------------------------- summary
echo "\n== seeded ==\n";
$summary = [
    'product groups' => Capsule::table('tblproductgroups')->count(),
    'products'       => Capsule::table('tblproducts')->count(),
    'clients'        => Capsule::table('tblclients')->count(),
    'services'       => Capsule::table('tblhosting')->count(),
    'domains'        => Capsule::table('tbldomains')->count(),
    'invoices'       => Capsule::table('tblinvoices')->count(),
    'tickets'        => Capsule::table('tbltickets')->count(),
    'announcements'  => Capsule::table('tblannouncements')->count(),
];
foreach ($summary as $what => $n) { printf("  %-16s %d\n", $what, $n); }

echo "\nDemo client logins (local fixtures):\n";
echo "  email:    <handle>@demo.hadrian.test  e.g. mara.okonkwo@demo.hadrian.test\n";
echo '  password: ' . DEMO_CLIENT_PASSWORD . "\n";
echo "\nRe-run with --force to reset, or --wipe to remove the demo data.\n";
