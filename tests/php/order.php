<?php
/**
 * Data the order-form spec (tests/e2e/order.spec.mjs) needs and the fixtures
 * do not provide: throwaway customers with account credit, saved cards and a
 * renewable domain, read-backs of the orders and invoices a checkout created,
 * a short-lived flip of one catalogue flag, and a promo code that discounts.
 *
 *   php tests/php/order.php buyer [--credit=N] [--country=US] [--card] [--expired-card] [--closed-account] [--domain=name.com]
 *        A new client flow+buyer<n>@demo.hadrian.test whose password is read from
 *        the ORDER_BUYER_PASSWORD environment variable (never printed), with the
 *        credit, saved Offline CC cards and a second, Closed account its user can
 *        also see, and a registered .com expiring in 20 days (renewable). Prints
 *        {clientId, email, payMethodId, expiredPayMethodId, closedClientId, domainId}.
 *   php tests/php/order.php credit <clientid> <amount>     add account credit
 *   php tests/php/order.php client <clientid>             {credit, country, status} + custom field values
 *   php tests/php/order.php invoice <invoiceid>           {status, subtotal, tax, credit, total, balance, items[]}
 *   php tests/php/order.php order <orderid>               {invoiceid, status, notes, nameservers, promocode, amount}
 *   php tests/php/order.php orders <clientid>             the client's orders, newest first
 *   php tests/php/order.php product <pid> <field> [value] read (and optionally set) one of
 *        is_featured | stockcontrol | qty on tblproducts; prints the value before the change
 *   php tests/php/order.php promo <ORDERSPEC...> <percent> <appliesto>
 *        create/replace a percentage promo code that discounts the named items
 *        (product ids, "A<addon id>", "D.<tld>"); promo-delete <code> removes it
 *   php tests/php/order.php delete <clientid>...          delete clients (and their users)
 *   php tests/php/order.php cleanup                       delete every flow+buyer... client and ORDERSPEC... code
 *
 * Everything it creates is named flow+...@demo.hadrian.test, which
 * tests/php/fixtures.php deletes on every full run as well.
 * Refuses unless SystemURL is localhost.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$systemUrl = (string) DB::table('tblconfiguration')->where('setting', 'SystemURL')->value('value');
if (!preg_match('~^https?://(localhost|127\.0\.0\.1)([:/]|$)~i', $systemUrl)) {
    fwrite(STDERR, "REFUSING TO RUN: SystemURL is '{$systemUrl}', which is not a local install.\n");
    exit(2);
}

const TEST_ADMIN = 'hadrian-test';
const BUYER_DOMAIN = '@demo.hadrian.test';

function ordOut($v): void { echo json_encode($v, JSON_UNESCAPED_SLASHES), "\n"; }
function ordFail(string $msg, int $code = 1): void { fwrite(STDERR, $msg . "\n"); exit($code); }
function ordApi(string $cmd, array $p): array
{
    $r = localAPI($cmd, $p, TEST_ADMIN);
    if (($r['result'] ?? '') !== 'success') ordFail("$cmd failed: " . json_encode($r), 6);
    return $r;
}
function ordOpts(array $argv): array
{
    $o = [];
    foreach ($argv as $a) {
        if (preg_match('/^--([a-z-]+)(?:=(.*))?$/', $a, $m)) $o[$m[1]] = $m[2] ?? true;
    }
    return $o;
}
function ordIsTestClient(int $id): bool
{
    $email = (string) DB::table('tblclients')->where('id', $id)->value('email');
    return str_starts_with($email, 'flow+') && str_ends_with($email, BUYER_DOMAIN);
}
function ordDeleteClient(int $id): void
{
    if (!ordIsTestClient($id)) ordFail("client $id is not a flow+...@demo.hadrian.test test client");
    $userIds = DB::table('tblusers_clients')->where('client_id', $id)->pluck('auth_user_id')->all();
    localAPI('DeleteClient', ['clientid' => $id, 'deleteusers' => true, 'deletetransactions' => true], TEST_ADMIN);
    // A buyer's user can also be linked to its closed second account; drop the
    // user once no account is left for it.
    foreach ($userIds as $uid) {
        if (!DB::table('tblusers_clients')->where('auth_user_id', $uid)->exists()) {
            DB::table('tblusers')->where('id', $uid)->where('email', 'like', 'flow+%' . BUYER_DOMAIN)->delete();
        }
    }
}

$cmd = $argv[1] ?? '';
$args = array_values(array_filter(array_slice($argv, 2), fn($a) => !str_starts_with($a, '--')));
$o = ordOpts(array_slice($argv, 2));

switch ($cmd) {
    case 'buyer': {
        $password = (string) getenv('ORDER_BUYER_PASSWORD');
        if (strlen($password) < 10) ordFail('set ORDER_BUYER_PASSWORD (10+ characters)');
        $stamp = (string) (int) (microtime(true) * 1000);
        $email = "flow+buyer{$stamp}" . BUYER_DOMAIN;
        $gb = strtoupper((string) ($o['country'] ?? 'US')) === 'GB';
        $r = ordApi('AddClient', [
            'firstname' => 'Bea', 'lastname' => 'Buyer', 'email' => $email,
            'address1' => $gb ? '5 Fixture Row' : '1 Test Street', 'city' => $gb ? 'Bristol' : 'Austin',
            'state' => $gb ? 'Bristol' : 'Texas', 'postcode' => $gb ? 'BS1 4DJ' : '78701', 'country' => $gb ? 'GB' : 'US',
            'phonenumber' => $gb ? '+44.1179460002' : '+1.2025550143', 'password2' => $password,
            'notes' => 'order.spec throwaway buyer', 'noemail' => true, 'skipvalidation' => true,
        ]);
        $clientId = (int) $r['clientid'];
        DB::table('tblusers')->where('email', $email)->update(['email_verified_at' => date('Y-m-d H:i:s')]);
        $credit = (float) ($o['credit'] ?? 0);
        if ($credit > 0) ordApi('AddCredit', ['clientid' => $clientId, 'description' => 'order.spec credit', 'amount' => $credit]);
        $res = ['clientId' => $clientId, 'email' => $email, 'payMethodId' => null, 'expiredPayMethodId' => null, 'closedClientId' => null];
        if (!empty($o['card'])) {
            $pm = ordApi('AddPayMethod', [
                'clientid' => $clientId, 'type' => 'CreditCard', 'description' => 'order.spec card',
                'card_number' => '4111111111111111', 'card_expiry' => '12' . date('y', strtotime('+3 years')),
                'gateway_module' => 'offlinecc', 'set_as_default' => true,
            ]);
            $res['payMethodId'] = (int) $pm['paymethodid'];
        }
        if (!empty($o['expired-card'])) {
            $pm = ordApi('AddPayMethod', [
                'clientid' => $clientId, 'type' => 'CreditCard', 'description' => 'order.spec expired card',
                'card_number' => '4111111111111111', 'card_expiry' => '0120', 'gateway_module' => 'offlinecc',
            ]);
            $res['expiredPayMethodId'] = (int) $pm['paymethodid'];
        }
        if (!empty($o['domain']) && is_string($o['domain'])) {
            // A registered domain that expires in 20 days: inside the renewal
            // window, so the domain-renewals page offers it. Deleted with the client.
            $now = date('Y-m-d H:i:s');
            $expiry = date('Y-m-d', strtotime('+20 days'));
            $res['domainId'] = (int) DB::table('tbldomains')->insertGetId([
                'userid' => $clientId, 'orderid' => 0, 'type' => 'Register', 'registrationdate' => date('Y-m-d', strtotime('-345 days')),
                'domain' => strtolower($o['domain']), 'firstpaymentamount' => 12.99, 'recurringamount' => 13.99, 'registrar' => 'hadriantest',
                'registrationperiod' => 1, 'expirydate' => $expiry, 'subscriptionid' => '', 'promoid' => 0, 'status' => 'Active',
                'nextduedate' => $expiry, 'nextinvoicedate' => $expiry, 'additionalnotes' => '', 'paymentmethod' => 'banktransfer',
                'dnsmanagement' => 0, 'emailforwarding' => 0, 'idprotection' => 0, 'donotrenew' => 0, 'reminders' => '', 'synced' => 0,
                'created_at' => $now, 'updated_at' => $now,
            ]);
        }
        if (!empty($o['closed-account'])) {
            // A second account the buyer's user may also act for, Closed: the
            // checkout's account picker must list it, disabled.
            $closedEmail = "flow+buyerclosed{$stamp}" . BUYER_DOMAIN;
            $c = ordApi('AddClient', [
                'firstname' => 'Cleo', 'lastname' => 'Closed', 'companyname' => 'Closed Account Ltd', 'email' => $closedEmail,
                'address1' => '2 Test Street', 'city' => 'Austin', 'state' => 'Texas', 'postcode' => '78701', 'country' => 'US',
                'phonenumber' => '+1.2025550144', 'password2' => $password, 'noemail' => true, 'skipvalidation' => true,
            ]);
            $closedId = (int) $c['clientid'];
            ordApi('UpdateClient', ['clientid' => $closedId, 'status' => 'Closed', 'skipvalidation' => true]);
            $userId = (int) DB::table('tblusers')->where('email', $email)->value('id');
            $now = date('Y-m-d H:i:s');
            DB::table('tblusers_clients')->updateOrInsert(['auth_user_id' => $userId, 'client_id' => $closedId], [
                'invite_id' => 0, 'owner' => 0, 'created_at' => $now, 'updated_at' => $now,
                'permissions' => 'profile,contacts,products,manageproducts,productsso,domains,managedomains,invoices,quotes,tickets,affiliates,emails,orders',
            ]);
            $res['closedClientId'] = $closedId;
        }
        ordOut($res);
        break;
    }
    case 'credit': {
        [$id, $amount] = [(int) ($args[0] ?? 0), (float) ($args[1] ?? 0)];
        if (!ordIsTestClient($id)) ordFail("client $id is not a test client");
        ordApi('AddCredit', ['clientid' => $id, 'description' => 'order.spec credit', 'amount' => $amount]);
        ordOut(['credit' => (float) DB::table('tblclients')->where('id', $id)->value('credit')]);
        break;
    }
    case 'client': {
        $id = (int) ($args[0] ?? 0);
        $c = DB::table('tblclients')->where('id', $id)->first();
        if (!$c) ordFail("no client $id");
        $fields = DB::table('tblcustomfieldsvalues as v')->join('tblcustomfields as f', 'f.id', '=', 'v.fieldid')
            ->where('f.type', 'client')->where('v.relid', $id)->pluck('v.value', 'f.fieldname');
        ordOut(['credit' => (float) $c->credit, 'country' => $c->country, 'status' => $c->status, 'email' => $c->email,
             'phonenumber' => $c->phonenumber, 'marketingOptIn' => (bool) ($c->marketing_emails_opt_in ?? false),
             'customFields' => $fields]);
        break;
    }
    case 'invoice': {
        $id = (int) ($args[0] ?? 0);
        $i = DB::table('tblinvoices')->where('id', $id)->first();
        if (!$i) ordFail("no invoice $id");
        $paid = (float) DB::table('tblaccounts')->where('invoiceid', $id)->sum('amountin');
        $items = DB::table('tblinvoiceitems')->where('invoiceid', $id)->orderBy('id')->get(['type', 'relid', 'description', 'amount', 'taxed'])
            ->map(fn($r) => ['type' => $r->type, 'relid' => (int) $r->relid, 'description' => $r->description, 'amount' => (float) $r->amount, 'taxed' => (bool) $r->taxed])->all();
        ordOut([
            'userid' => (int) $i->userid, 'status' => $i->status, 'paymentmethod' => $i->paymentmethod,
            'subtotal' => (float) $i->subtotal, 'tax' => (float) $i->tax, 'tax2' => (float) $i->tax2, 'taxrate' => (float) $i->taxrate,
            'credit' => (float) $i->credit, 'total' => (float) $i->total, 'paid' => $paid,
            'balance' => round((float) $i->total - $paid, 2), 'items' => $items,
        ]);
        break;
    }
    case 'order': {
        $id = (int) ($args[0] ?? 0);
        $r = DB::table('tblorders')->where('id', $id)->first();
        if (!$r) ordFail("no order $id");
        ordOut(['id' => (int) $r->id, 'userid' => (int) $r->userid, 'invoiceid' => (int) $r->invoiceid, 'status' => $r->status,
             'notes' => $r->notes, 'nameservers' => $r->nameservers, 'promocode' => $r->promocode, 'amount' => (float) $r->amount,
             'paymentmethod' => $r->paymentmethod]);
        break;
    }
    case 'orders': {
        $id = (int) ($args[0] ?? 0);
        ordOut(DB::table('tblorders')->where('userid', $id)->orderByDesc('id')->get(['id', 'invoiceid', 'status', 'amount', 'paymentmethod', 'notes'])
            ->map(fn($r) => ['id' => (int) $r->id, 'invoiceid' => (int) $r->invoiceid, 'status' => $r->status, 'amount' => (float) $r->amount,
                             'paymentmethod' => $r->paymentmethod, 'notes' => $r->notes])->all());
        break;
    }
    case 'product': {
        [$pid, $field] = [(int) ($args[0] ?? 0), (string) ($args[1] ?? '')];
        if (!in_array($field, ['is_featured', 'stockcontrol', 'qty'], true)) ordFail('field must be is_featured, stockcontrol or qty');
        $before = DB::table('tblproducts')->where('id', $pid)->value($field);
        if ($before === null) ordFail("no product $pid");
        if (array_key_exists(2, $args)) DB::table('tblproducts')->where('id', $pid)->update([$field => (int) $args[2]]);
        ordOut((int) $before);
        break;
    }
    case 'promo': {
        // The fixture HADRIAN10 applies to nothing (empty "applies to"), so it
        // only ever shows "no items qualify". A spec-owned code that discounts
        // named items; appliesto = product ids, "A<addonid>", "D.<tld>".
        [$code, $percent, $appliesTo] = [(string) ($args[0] ?? ''), (float) ($args[1] ?? 10), (string) ($args[2] ?? '')];
        if (!preg_match('/^ORDERSPEC[A-Z0-9]*$/', $code)) ordFail('promo codes made here start with ORDERSPEC');
        DB::table('tblpromotions')->updateOrInsert(['code' => $code], [
            'type' => 'Percentage', 'recurring' => 0, 'value' => $percent, 'cycles' => '', 'appliesto' => $appliesTo, 'requires' => '',
            'requiresexisting' => 0, 'startdate' => '0000-00-00', 'expirationdate' => '0000-00-00', 'maxuses' => 0, 'uses' => 0,
            'lifetimepromo' => 0, 'applyonce' => 0, 'newsignups' => 0, 'existingclient' => 0, 'onceperclient' => 0, 'recurfor' => 0,
            'upgrades' => 0, 'upgradeconfig' => '', 'notes' => 'order.spec temporary code (tests/php/order.php)',
        ]);
        ordOut(['code' => $code]);
        break;
    }
    case 'promo-delete': {
        $code = (string) ($args[0] ?? '');
        if (!str_starts_with($code, 'ORDERSPEC')) ordFail('only ORDERSPEC... codes');
        ordOut(['deleted' => DB::table('tblpromotions')->where('code', $code)->delete()]);
        break;
    }
    case 'delete': {
        foreach ($args as $id) ordDeleteClient((int) $id);
        ordOut(['deleted' => array_map('intval', $args)]);
        break;
    }
    case 'cleanup': {
        $ids = DB::table('tblclients')->where('email', 'like', 'flow+buyer%' . BUYER_DOMAIN)->pluck('id')->all();
        foreach ($ids as $id) ordDeleteClient((int) $id);
        DB::table('tblusers')->where('email', 'like', 'flow+buyer%' . BUYER_DOMAIN)->delete();
        DB::table('tblpromotions')->where('code', 'like', 'ORDERSPEC%')->delete();
        ordOut(['deleted' => array_map('intval', $ids)]);
        break;
    }
    default:
        ordFail("usage: order.php buyer|credit|client|invoice|order|orders|product|promo|promo-delete|delete|cleanup ...");
}
