<?php
/**
 * Records and restores for tests/e2e/client-area.spec.mjs.
 *
 *   php tests/php/client-area.php make-client <email> <password>   -> {"clientId","userId"}
 *   php tests/php/client-area.php add-service <clientId>           -> {"serviceId"}
 *   php tests/php/client-area.php make-invoice <clientId> <gateway> [amount] -> {"invoiceId"}
 *   php tests/php/client-area.php make-quote <clientId>            -> {"quoteId"}
 *   php tests/php/client-area.php add-credit <clientId> <amount>   -> {"credit"}
 *   php tests/php/client-area.php add-contact <clientId>           -> {"contactId"}
 *   php tests/php/client-area.php send-unsubscribe <clientId>      -> {"sent":true}
 *   php tests/php/client-area.php client <clientId>                -> a few tblclients / tblusers columns
 *   php tests/php/client-area.php delete-client <clientId>
 *   php tests/php/client-area.php reset-verify <email>             (unverified again, no pending token)
 *   php tests/php/client-area.php domain <domainId>                -> donotrenew + addon flags
 *   php tests/php/client-area.php set-domain <domainId> <json>
 *   php tests/php/client-area.php kb <articleId>                   -> useful / votes / views
 *   php tests/php/client-area.php set-kb <articleId> <json>
 *   php tests/php/client-area.php download <downloadId>            -> downloads count
 *   php tests/php/client-area.php set-download <downloadId> <count>
 *   php tests/php/client-area.php delete-feedback <ticketTid>
 *
 * Every record the spec creates belongs to a throwaway customer named
 * flow+ca-<n>@demo.hadrian.test, so delete-client removes it, and
 * tests/php/fixtures.php removes any the next run finds (a test that died
 * before its finally block). Everything else here reads a value so the spec
 * can put it back. Refuses unless SystemURL is localhost.
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

const ADMIN = 'hadrian-test';
const THROWAWAY = '~^flow\+ca-[a-z0-9-]+@demo\.hadrian\.test$~';

$args = array_slice($argv, 1);
$cmd = array_shift($args) ?? '';
$out = fn($v) => print(json_encode($v, JSON_UNESCAPED_SLASHES) . "\n");
$fail = function (string $msg): void { fwrite(STDERR, $msg . "\n"); exit(1); };
$api = function (string $c, array $p) use ($fail): array {
    $r = localAPI($c, $p, ADMIN);
    if (($r['result'] ?? '') !== 'success') $fail("$c failed: " . json_encode($r));
    return $r;
};
/** Only ever touch a client the spec created. */
$throwaway = function (int $clientId) use ($fail): object {
    $c = DB::table('tblclients')->where('id', $clientId)->first();
    if (!$c || !preg_match(THROWAWAY, (string) $c->email)) $fail("client $clientId is not a flow+ca- throwaway");
    return $c;
};
$now = date('Y-m-d H:i:s');

switch ($cmd) {
    case 'make-client':
        [$email, $password] = $args + ['', ''];
        if (!preg_match(THROWAWAY, $email) || strlen($password) < 8) $fail('usage: make-client flow+ca-<n>@demo.hadrian.test <password>');
        $r = $api('AddClient', [
            'firstname' => 'Casey', 'lastname' => 'Flowtest', 'email' => $email, 'companyname' => '',
            'address1' => '5 Fixture Lane', 'city' => 'Austin', 'state' => 'TX', 'postcode' => '78701', 'country' => 'US',
            'phonenumber' => '+1.2025550143', 'password2' => $password, 'notes' => 'client-area.spec throwaway',
            'noemail' => true, 'skipvalidation' => true, 'marketingoptin' => true,
        ]);
        $userId = (int) DB::table('tblusers')->where('email', $email)->value('id');
        $out(['clientId' => (int) $r['clientid'], 'userId' => $userId]);
        break;

    case 'add-service':
        $c = $throwaway((int) ($args[0] ?? 0));
        // A plain row, not an order: no module call, no provisioning, no email.
        $pid = (int) DB::table('tblhosting')->where('id', 1)->value('packageid') ?: 15;
        $id = (int) DB::table('tblhosting')->insertGetId([
            'userid' => $c->id, 'orderid' => 0, 'packageid' => $pid, 'server' => 0, 'regdate' => date('Y-m-d'),
            'domain' => 'casey-flowtest.example', 'paymentmethod' => 'banktransfer', 'qty' => 1, 'firstpaymentamount' => 9.99,
            'amount' => 9.99, 'billingcycle' => 'Monthly', 'nextduedate' => date('Y-m-d', strtotime('+20 days')),
            'nextinvoicedate' => date('Y-m-d', strtotime('+20 days')), 'termination_date' => '0000-00-00',
            'completed_date' => '0000-00-00', 'domainstatus' => 'Active', 'username' => '', 'password' => '',
            'notes' => '', 'subscriptionid' => '', 'promoid' => 0, 'suspendreason' => '', 'overideautosuspend' => 0,
            'overidesuspenduntil' => '0000-00-00', 'dedicatedip' => '', 'assignedips' => '', 'ns1' => '', 'ns2' => '',
            'diskusage' => 0, 'disklimit' => 0, 'bwusage' => 0, 'bwlimit' => 0, 'lastupdate' => '0000-00-00 00:00:00',
            'created_at' => $now, 'updated_at' => $now,
        ]);
        $out(['serviceId' => $id]);
        break;

    case 'make-invoice':
        $c = $throwaway((int) ($args[0] ?? 0));
        $gateway = (string) ($args[1] ?? 'banktransfer');
        $amount = (float) ($args[2] ?? 12.50);
        $r = $api('CreateInvoice', [
            'userid' => $c->id, 'status' => 'Unpaid', 'sendinvoice' => false, 'paymentmethod' => $gateway,
            'date' => date('Y-m-d'), 'duedate' => date('Y-m-d', strtotime('+7 days')),
            'itemdescription1' => 'client-area.spec test charge', 'itemamount1' => $amount, 'itemtaxed1' => false,
        ]);
        $out(['invoiceId' => (int) $r['invoiceid']]);
        break;

    case 'make-quote':
        $c = $throwaway((int) ($args[0] ?? 0));
        $r = $api('CreateQuote', [
            'subject' => 'client-area.spec quote', 'stage' => 'Delivered', 'validuntil' => date('Y-m-d', strtotime('+30 days')),
            'userid' => $c->id, 'proposal' => 'A quote for the client-area spec.', 'customernotes' => '',
            'lineitems' => base64_encode(serialize([['desc' => 'Spec hosting (12 months)', 'qty' => 1, 'up' => 120.00, 'discount' => 0, 'taxable' => false]])),
        ]);
        $out(['quoteId' => (int) $r['quoteid']]);
        break;

    case 'add-contact':
        $c = $throwaway((int) ($args[0] ?? 0));
        $r = $api('AddContact', [
            'clientid' => $c->id, 'firstname' => 'Pat', 'lastname' => 'Contact', 'email' => 'flow+ca-contact' . $c->id . '@demo.hadrian.test',
            'address1' => '1 Spec Street', 'city' => 'Leeds', 'state' => 'West Yorkshire', 'postcode' => 'LS1 1AA', 'country' => 'GB',
            'phonenumber' => '+44.7400123456',
        ]);
        $out(['contactId' => (int) $r['contactid']]);
        break;

    case 'add-credit':
        $c = $throwaway((int) ($args[0] ?? 0));
        $api('AddCredit', ['clientid' => $c->id, 'description' => 'client-area.spec credit', 'amount' => (float) ($args[1] ?? 5)]);
        $out(['credit' => (float) DB::table('tblclients')->where('id', $c->id)->value('credit')]);
        break;

    case 'send-unsubscribe':
        // WHMCS builds the signed opt-out link itself; mail it so the spec reads it from Mailpit.
        $c = $throwaway((int) ($args[0] ?? 0));
        $api('SendEmail', [
            'id' => $c->id, 'customtype' => 'general', 'customsubject' => 'client-area.spec marketing',
            'custommessage' => '<p>Unsubscribe: {$unsubscribe_url}</p>',
        ]);
        $out(['sent' => true]);
        break;

    case 'client':
        $c = $throwaway((int) ($args[0] ?? 0));
        $u = DB::table('tblusers')->where('email', $c->email)->first();
        $out([
            'address2' => $c->address2, 'marketing' => (int) $c->marketing_emails_opt_in, 'language' => $c->language,
            'firstname' => $u->first_name ?? null, 'verified' => !empty($u->email_verified_at), 'secondFactor' => $u->second_factor ?? '',
            'affiliate' => DB::table('tblaffiliates')->where('clientid', $c->id)->exists(),
            'contacts' => DB::table('tblcontacts')->where('userid', $c->id)->count(),
            'invites' => DB::table('tbluser_invites')->where('client_id', $c->id)->whereNull('accepted_at')->whereNull('deleted_at')->count(),
            'cancelRequests' => DB::table('tblcancelrequests')->whereIn('relid', DB::table('tblhosting')->where('userid', $c->id)->pluck('id'))->count(),
            'quoteStage' => DB::table('tblquotes')->where('userid', $c->id)->orderByDesc('id')->value('stage'),
        ]);
        break;

    case 'delete-client':
        $c = $throwaway((int) ($args[0] ?? 0));
        $hosting = DB::table('tblhosting')->where('userid', $c->id)->pluck('id')->all();
        if ($hosting) DB::table('tblcancelrequests')->whereIn('relid', $hosting)->delete();
        DB::table('tbluser_invites')->where('client_id', $c->id)->delete();
        DB::table('tblemails')->where('userid', $c->id)->delete();
        // DeleteClient leaves quotes behind.
        $quotes = DB::table('tblquotes')->where('userid', $c->id)->pluck('id')->all();
        if ($quotes) {
            DB::table('tblquoteitems')->whereIn('quoteid', $quotes)->delete();
            DB::table('tblquotes')->whereIn('id', $quotes)->delete();
        }
        localAPI('DeleteClient', ['clientid' => (int) $c->id, 'deleteusers' => true, 'deletetransactions' => true], ADMIN);
        DB::table('tblusers')->where('email', 'like', 'flow+ca-%@demo.hadrian.test')->where('email', $c->email)->delete();
        $out(['deleted' => (int) $c->id]);
        break;

    case 'reset-verify':
        $email = (string) ($args[0] ?? '');
        if (!str_ends_with($email, '@demo.hadrian.test')) $fail('demo users only');
        DB::table('tblusers')->where('email', $email)->update(['email_verified_at' => null, 'email_verification_token' => '']);
        $out(['reset' => $email]);
        break;

    case 'domain':
        $d = DB::table('tbldomains')->where('id', (int) ($args[0] ?? 0))->first(['donotrenew', 'dnsmanagement', 'emailforwarding', 'idprotection']);
        $out($d);
        break;

    case 'set-domain':
        $vals = json_decode((string) ($args[1] ?? '{}'), true) ?: [];
        $vals = array_intersect_key($vals, array_flip(['donotrenew', 'dnsmanagement', 'emailforwarding', 'idprotection']));
        if ($vals) DB::table('tbldomains')->where('id', (int) $args[0])->update($vals);
        $out(['set' => $vals]);
        break;

    case 'kb':
        $out(DB::table('tblknowledgebase')->where('id', (int) ($args[0] ?? 0))->first(['useful', 'votes', 'views']));
        break;

    case 'set-kb':
        $vals = array_intersect_key(json_decode((string) ($args[1] ?? '{}'), true) ?: [], array_flip(['useful', 'votes', 'views']));
        if ($vals) DB::table('tblknowledgebase')->where('id', (int) $args[0])->update($vals);
        $out(['set' => $vals]);
        break;

    case 'download':
        $out(['downloads' => (int) DB::table('tbldownloads')->where('id', (int) ($args[0] ?? 0))->value('downloads')]);
        break;

    case 'set-download':
        DB::table('tbldownloads')->where('id', (int) ($args[0] ?? 0))->update(['downloads' => (int) ($args[1] ?? 0)]);
        $out(['set' => (int) ($args[1] ?? 0)]);
        break;

    case 'delete-feedback':
        $tid = (string) ($args[0] ?? '');
        $id = DB::table('tbltickets')->where('tid', $tid)->value('id');
        if ($id) DB::table('tblticketfeedback')->where('ticketid', $id)->delete();
        $out(['ticket' => $id]);
        break;

    default:
        $fail("unknown command '$cmd' (see the header of tests/php/client-area.php)");
}
