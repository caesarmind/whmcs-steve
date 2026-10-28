<?php
/**
 * Hadrian local stack - demo data seeder.
 *
 *   php scripts/local-stack/seed-demo-data.php              # seed
 *   php scripts/local-stack/seed-demo-data.php --force      # re-seed over existing demo data
 *   php scripts/local-stack/seed-demo-data.php --wipe       # remove demo data, seed nothing
 *   php scripts/local-stack/seed-demo-data.php --catalogue  # refresh product groups/products in place
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
 * directly, plus the product fields AddProduct does not take (tagline, sort
 * order) and the in-place updates --catalogue makes, which WHMCS has no API for.
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
$catalogueOnly = in_array('--catalogue', $argv, true);

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

/**
 * Product groups have no notes column, and their tagline is shown on the store
 * page, so the demo group ids are recorded in a tblconfiguration row instead.
 * Groups seeded before that carried the marker as their tagline; both count.
 */
const DEMO_GROUPS_SETTING = 'HadrianDemoProductGroups';

function demoGroupIds(): array
{
    $recorded = json_decode((string) Capsule::table('tblconfiguration')
        ->where('setting', DEMO_GROUPS_SETTING)->value('value'), true) ?: [];
    return Capsule::table('tblproductgroups')
        ->whereIn('id', array_map('intval', $recorded))
        ->orWhere('tagline', 'like', '%' . DEMO_MARKER . '%')
        ->orderBy('order')->pluck('id')->map(fn ($id) => (int) $id)->all();
}

function recordDemoGroupIds(array $ids): void
{
    $now = date('Y-m-d H:i:s');
    Capsule::table('tblconfiguration')->updateOrInsert(
        ['setting' => DEMO_GROUPS_SETTING],
        ['value' => json_encode(array_values($ids)), 'created_at' => $now, 'updated_at' => $now]
    );
}

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
    $groupIds = demoGroupIds();
    if ($groupIds) {
        $productIds = Capsule::table('tblproducts')->whereIn('gid', $groupIds)->pluck('id')->all();
        if ($productIds) {
            Capsule::table('tblpricing')->where('type', 'product')->whereIn('relid', $productIds)->delete();
            Capsule::table('tblproducts_slugs')->whereIn('product_id', $productIds)->delete();
            Capsule::table('tblproducts')->whereIn('id', $productIds)->delete();
        }
        Capsule::table('tblproductgroups')->whereIn('id', $groupIds)->delete();
        echo 'wiped ' . count($groupIds) . " demo product groups\n";
    }
    Capsule::table('tblconfiguration')->where('setting', DEMO_GROUPS_SETTING)->delete();
    Capsule::table('tblannouncements')->where('announcement', 'like', '%' . DEMO_MARKER . '%')->delete();
}

if ($wipe) { wipeDemo(); echo "done (wipe only)\n"; exit(0); }

if (!$catalogueOnly) {
    if (Capsule::table('tblproducts')->exists() && !$force) {
        fwrite(STDERR, "Products already exist. Re-run with --force to wipe demo data and re-seed,\n"
            . "or --catalogue to refresh just the product groups and products.\n");
        exit(1);
    }
    if ($force) { wipeDemo(); }
}

// ---------------------------------------------------------------- catalogue
/**
 * Product groups and their products, written the way an admin fills them in
 * so the order form has real content to lay out (Shared Hosting mirrors the
 * apple-client-area store.html mockup):
 *
 *   group tagline     -> the line under the category title
 *   product tagline   -> the line under the plan name. It opens the Description,
 *                        ahead of the list: WHMCS 9.0 passes the product's own
 *                        Tagline field to order forms empty, so hadrian_cart
 *                        reads the text before the list. The Tagline field is
 *                        filled too, for when WHMCS does pass it.
 *   features          -> the rest of the Description, a <ul><li> list the cart
 *                        renders with check marks. true = included, false =
 *                        shown muted (not in this plan).
 *
 * Shared Hosting's annual price is 20% under twelve months of monthly, so the
 * cart's "Save 20%" pill is true there; the other groups' annual price is ~10
 * months of monthly. Taglines use HTML entities because this file stays ASCII.
 */
$catalogue = [
    [
        'name' => 'Shared Hosting',
        'tagline' => 'Hosting is what makes your site visible on the web.',
        'products' => [
            ['name' => 'Single', 'tagline' => 'Everything you need to launch your first site.',
             'features' => ['<strong>1</strong> website' => true, '<strong>10 GB</strong> SSD storage' => true,
                            'Unlimited bandwidth' => true, 'Free domain included' => true,
                            'Free SSL certificate' => true, 'Daily backups' => false],
             'pricing' => ['monthly' => 3.74, 'annually' => 35.88, 'biennially' => 66.96]],
            ['name' => 'Professional', 'tagline' => 'Built for growing businesses with multiple sites.',
             'features' => ['<strong>10</strong> websites' => true, '<strong>25 GB</strong> SSD storage' => true,
                            'Unlimited bandwidth' => true, 'Free domain included' => true,
                            'Free SSL certificate' => true, 'Daily backups' => true],
             'pricing' => ['monthly' => 6.24, 'annually' => 59.88, 'biennially' => 107.76]],
            ['name' => 'Business', 'tagline' => 'No limits &mdash; perfect for agencies and large catalogues.',
             'features' => ['<strong>Unlimited</strong> websites' => true, '<strong>100 GB</strong> SSD storage' => true,
                            'Unlimited bandwidth' => true, 'Free domain included' => true,
                            'Free SSL certificate' => true, 'Daily backups &middot; Priority support' => true],
             'pricing' => ['monthly' => 12.49, 'annually' => 119.88, 'biennially' => 215.76]],
        ],
    ],
    [
        'name' => 'VPS Hosting',
        'tagline' => 'Root access, NVMe storage, deployed in under a minute.',
        'products' => [
            ['name' => 'VPS 2 GB', 'tagline' => 'For side projects and staging servers.',
             'features' => ['<strong>2</strong> vCPU' => true, '<strong>2 GB</strong> RAM' => true,
                            '<strong>50 GB</strong> NVMe storage' => true, '<strong>2 TB</strong> transfer' => true,
                            'Full root access' => true],
             'pricing' => ['monthly' => 12.00, 'annually' => 120.00]],
            ['name' => 'VPS 4 GB', 'tagline' => 'Room for production apps and databases.',
             'features' => ['<strong>4</strong> vCPU' => true, '<strong>4 GB</strong> RAM' => true,
                            '<strong>100 GB</strong> NVMe storage' => true, '<strong>4 TB</strong> transfer' => true,
                            'Full root access' => true],
             'pricing' => ['monthly' => 24.00, 'annually' => 240.00]],
            ['name' => 'VPS 8 GB', 'tagline' => 'For busy sites and heavier workloads.',
             'features' => ['<strong>8</strong> vCPU' => true, '<strong>8 GB</strong> RAM' => true,
                            '<strong>200 GB</strong> NVMe storage' => true, '<strong>8 TB</strong> transfer' => true,
                            'Full root access' => true],
             'pricing' => ['monthly' => 48.00, 'annually' => 480.00]],
        ],
    ],
    [
        'name' => 'Dedicated Servers',
        'tagline' => 'Single-tenant hardware with full IPMI access.',
        'products' => [
            ['name' => 'DS Entry', 'tagline' => 'A whole server for one workload.',
             'features' => ['<strong>Xeon</strong> E-2336' => true, '<strong>32 GB</strong> ECC RAM' => true,
                            '<strong>2 x 960 GB</strong> NVMe' => true, 'IPMI access' => true],
             'pricing' => ['monthly' => 89.00, 'annually' => 890.00, 'msetupfee' => 49.00, 'asetupfee' => 49.00]],
            ['name' => 'DS Pro', 'tagline' => 'Dual-socket power for demanding stacks.',
             'features' => ['<strong>Dual Xeon</strong> Silver 4314' => true, '<strong>128 GB</strong> ECC RAM' => true,
                            '<strong>4 x 2 TB</strong> NVMe' => true, 'IPMI access' => true],
             'pricing' => ['monthly' => 219.00, 'annually' => 2190.00, 'msetupfee' => 99.00, 'asetupfee' => 99.00]],
        ],
    ],
    [
        'name' => 'SSL Certificates',
        'tagline' => 'Issued and installed for you.',
        'products' => [
            ['name' => 'DV SSL', 'tagline' => 'Domain-validated, issued in minutes.',
             'features' => ['<strong>1</strong> domain' => true, 'Issued in minutes' => true,
                            'Browser padlock' => true, 'Installed for you' => true],
             'pricing' => ['annually' => 15.00]],
            ['name' => 'Wildcard SSL', 'tagline' => 'One certificate for every subdomain.',
             'features' => ['<strong>Unlimited</strong> subdomains' => true, 'Issued in minutes' => true,
                            'Browser padlock' => true, 'Installed for you' => true],
             'pricing' => ['annually' => 95.00]],
        ],
    ],
    [
        'name' => 'Managed WordPress',
        'tagline' => 'WordPress with updates, caching and backups handled.',
        'products' => [
            ['name' => 'WP Personal', 'tagline' => 'One WordPress site, fully managed.',
             'features' => ['<strong>1</strong> WordPress site' => true, 'Managed updates' => true,
                            'Built-in CDN' => true, 'Daily backups' => true],
             'pricing' => ['monthly' => 7.00, 'annually' => 70.00]],
            ['name' => 'WP Agency', 'tagline' => 'For studios running client sites.',
             'features' => ['<strong>25</strong> WordPress sites' => true, 'Staging environments' => true,
                            'White-label reports' => true, 'Daily backups' => true],
             'pricing' => ['monthly' => 39.00, 'annually' => 390.00]],
        ],
    ],
];

/** The product Description: the tagline, then one <li> per feature, muted when not included. */
function productDescription(string $tagline, array $features): string
{
    $items = [];
    foreach ($features as $html => $included) {
        $items[] = ($included ? '<li>' : '<li class="muted">') . $html . '</li>';
    }
    return $tagline . "\n<ul>\n" . implode("\n", $items) . "\n</ul>";
}

/**
 * A full tblpricing row: every cycle the product does not offer is -1.00
 * (WHMCS's "disabled"), every setup fee not given is 0.00.
 */
function pricingRow(array $pricing): array
{
    $row = [];
    foreach (['monthly', 'quarterly', 'semiannually', 'annually', 'biennially', 'triennially'] as $cycle) {
        $row[$cycle] = $pricing[$cycle] ?? -1.00;
    }
    foreach (['msetupfee', 'qsetupfee', 'ssetupfee', 'asetupfee', 'bsetupfee', 'tsetupfee'] as $fee) {
        $row[$fee] = $pricing[$fee] ?? 0.00;
    }
    return $row;
}

/**
 * Create the catalogue, or bring an existing demo catalogue up to date in
 * place. Groups match by name; products match by position within their group
 * (creation order), so a renamed plan keeps its id and the services, invoices
 * and tickets that point at it. Returns product name => id.
 */
function syncCatalogue(array $catalogue, int $currencyId): array
{
    $now = date('Y-m-d H:i:s');
    $existing = demoGroupIds();
    $groupIds = [];
    $productIds = [];

    // Slug rows of products that no longer exist only block the plain slugs.
    Capsule::table('tblproducts_slugs')
        ->whereNotIn('product_id', Capsule::table('tblproducts')->select('id'))->delete();

    foreach ($catalogue as $gi => $group) {
        $groupRow = [
            'name'       => $group['name'],
            'headline'   => null,   // the store page then titles the category with its name
            'tagline'    => $group['tagline'],
            'order'      => $gi,
            'updated_at' => $now,
        ];
        $gid = (int) Capsule::table('tblproductgroups')->whereIn('id', $existing)
            ->where('name', $group['name'])->value('id');
        if ($gid) {
            Capsule::table('tblproductgroups')->where('id', $gid)->update($groupRow);
            echo "  group: {$group['name']} (#{$gid}, updated)\n";
        } else {
            $gid = (int) Capsule::table('tblproductgroups')->insertGetId($groupRow + [
                'slug'        => strtolower(str_replace(' ', '-', $group['name'])),
                'orderfrmtpl' => '',
                'disabledgateways' => '',   // NOT NULL, no default
                'hidden'      => 0,
                'created_at'  => $now,
            ]);
            echo "  group: {$group['name']} (#{$gid})\n";
        }
        $groupIds[] = $gid;

        $current = Capsule::table('tblproducts')->where('gid', $gid)->orderBy('id')->pluck('id')->all();
        foreach ($group['products'] as $pi => $product) {
            $fields = [
                'name'        => $product['name'],
                'tagline'     => $product['tagline'],
                'description' => productDescription($product['tagline'], $product['features']),
                'paytype'     => 'recurring',
                'order'       => $pi,
            ];
            if (isset($current[$pi])) {
                $pid = (int) $current[$pi];
                Capsule::table('tblproducts')->where('id', $pid)->update($fields);
                syncProductSlug($pid, $gid, $product['name']);
                $verb = 'updated';
            } else {
                $r = api('AddProduct', [
                    'type'        => 'hostingaccount',
                    'gid'         => $gid,
                    'name'        => $product['name'],
                    'description' => $fields['description'],
                    'paytype'     => 'recurring',
                    'hidden'      => false,
                    'showdomainoptions' => in_array($group['name'], ['Shared Hosting', 'Managed WordPress'], true),
                    'pricing'     => [$currencyId => $product['pricing']],
                ]);
                $pid = (int) $r['pid'];
                // AddProduct takes no tagline or sort order.
                Capsule::table('tblproducts')->where('id', $pid)->update($fields);
                $verb = 'created';
            }
            Capsule::table('tblpricing')->updateOrInsert(
                ['type' => 'product', 'currency' => $currencyId, 'relid' => $pid],
                pricingRow($product['pricing'])
            );
            $productIds[$product['name']] = $pid;
            $from = $product['pricing']['monthly'] ?? $product['pricing']['annually'];
            echo "    product: {$product['name']} (#{$pid}, {$verb})  \$" . number_format($from, 2)
                . (isset($product['pricing']['monthly']) ? '/mo' : '/yr') . "\n";
        }
    }
    recordDemoGroupIds($groupIds);
    return $productIds;
}

/**
 * Point a product's store URL at its current name (/store/shared-hosting/single).
 * WHMCS keeps earlier slugs as inactive rows and links only the active one, and
 * appends "-1" when the plain slug is taken - which the leftover slug rows of
 * wiped products used to cause.
 */
function syncProductSlug(int $pid, int $gid, string $name): void
{
    $slug = trim((string) preg_replace('/[^a-z0-9]+/', '-', strtolower($name)), '-');
    $active = Capsule::table('tblproducts_slugs')->where('product_id', $pid)->where('active', 1)->value('slug');
    if ($active === null || $active === $slug) { return; }
    $groupSlug = (string) Capsule::table('tblproductgroups')->where('id', $gid)->value('slug');
    $taken = Capsule::table('tblproducts_slugs')->where('group_slug', $groupSlug)->where('slug', $slug)
        ->where('product_id', '!=', $pid)->exists();
    if ($taken) { return; }
    $now = date('Y-m-d H:i:s');
    Capsule::table('tblproducts_slugs')->where('product_id', $pid)->update(['active' => 0, 'updated_at' => $now]);
    $reused = Capsule::table('tblproducts_slugs')->where('product_id', $pid)->where('slug', $slug)
        ->update(['active' => 1, 'updated_at' => $now]);
    if (!$reused) {
        Capsule::table('tblproducts_slugs')->insert([
            'product_id' => $pid, 'group_id' => $gid, 'group_slug' => $groupSlug, 'slug' => $slug,
            'active' => 1, 'clicks' => 0, 'created_at' => $now, 'updated_at' => $now,
        ]);
    }
}

echo "== catalogue ==\n";
$productIds = syncCatalogue($catalogue, $currencyId);

if ($catalogueOnly) {
    echo "done (catalogue refreshed; clients, services and invoices untouched)\n";
    exit(0);
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
    [3,  'Single',        'monthly',   'estudiomirador.es',      'Active',      21],
    [4,  'WP Agency',     'annually',  'klitbureau.dk',          'Active',     144],
    [5,  'VPS 8 GB',      'monthly',   '',                       'Active',      28],
    [6,  'WP Personal',   'monthly',   'ameliafrost.au',         'Suspended',  -12],
    [7,  'Professional',  'monthly',   'atlascloud.fr',          'Active',       3],
    [8,  'VPS 2 GB',      'monthly',   'werkstattneun.de',       'Active',      17],
    [9,  'Single',        'annually',  'nunobarreto.pt',         'Cancelled',  -64],
    [10, 'DS Entry',      'monthly',   'pontedigitale.it',       'Active',      11],
    [11, 'Business',      'monthly',   'poldermedia.nl',         'Active',      25],
    [12, 'Professional',  'annually',  'kingsleyco.ca',          'Terminated', -148],
    [0,  'DV SSL',        'annually',  'riverbendstudio.co.uk',  'Active',     188],
    [2,  'VPS 2 GB',      'monthly',   '',                       'Pending',     30],
    [5,  'Single',        'monthly',   '',                       'Active',       9],
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
    [3,  'Migrate from old host',                      'I have a cPanel backup from my previous provider, about 6 GB. Can you restore it onto the Single plan?',                 'Open',     'Medium'],
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
