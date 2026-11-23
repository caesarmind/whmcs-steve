<?php
/**
 * Hadrian test registrar - a stand-in for a real registrar on the LOCAL stack.
 *
 * WHMCS only renders the domain-management pages (nameservers, EPP code,
 * child nameservers, email forwarding, DNS, addons) when the domain belongs to
 * an active registrar module that answers those calls. A real one needs an
 * account and talks to the internet, so tests/php/scenarios.php copies this
 * stub into modules/registrars/ and assigns the full persona's domain to it.
 *
 * Every answer is canned and nothing is stored: "save" calls succeed and the
 * next read returns the same fixture data, which keeps every run identical.
 * Never deployed (the deploy Action ships hadrian/** and hadrian_cart/** only).
 */

if (!defined('WHMCS')) {
    die('This file cannot be accessed directly');
}

function hadriantest_MetaData()
{
    return ['DisplayName' => 'Hadrian Test Registrar (local fixtures)', 'APIVersion' => '1.1'];
}

function hadriantest_getConfigArray()
{
    return [
        'FriendlyName' => ['Type' => 'System', 'Value' => 'Hadrian Test Registrar'],
        'Description'  => ['Type' => 'System', 'Value' => 'Canned answers for the local test suite. Never use on a real install.'],
    ];
}

function hadriantest_RegisterDomain($params) { return ['success' => true]; }
function hadriantest_TransferDomain($params) { return ['success' => true]; }
function hadriantest_RenewDomain($params)    { return ['success' => true]; }

function hadriantest_GetNameservers($params)
{
    return ['ns1' => 'ns1.hadrian-test.example', 'ns2' => 'ns2.hadrian-test.example', 'ns3' => '', 'ns4' => '', 'ns5' => ''];
}
function hadriantest_SaveNameservers($params) { return ['success' => true]; }

function hadriantest_GetRegistrarLock($params) { return 'locked'; }
function hadriantest_SaveRegistrarLock($params) { return ['success' => true]; }

function hadriantest_GetContactDetails($params)
{
    $c = [
        'First Name' => 'Mara', 'Last Name' => 'Okonkwo', 'Company Name' => 'Riverbend Studio',
        'Email Address' => 'mara.okonkwo@demo.hadrian.test', 'Address 1' => '12 Riverside Walk', 'Address 2' => '',
        'City' => 'Bristol', 'State' => 'Bristol', 'Postcode' => 'BS1 4DJ', 'Country' => 'GB', 'Phone Number' => '+44.1179460000',
    ];
    return ['Registrant' => $c, 'Technical' => $c, 'Billing' => $c, 'Admin' => $c];
}
function hadriantest_SaveContactDetails($params) { return ['success' => true]; }

function hadriantest_GetEPPCode($params) { return ['eppcode' => 'HADRIAN-TEST-EPP-0000']; }

function hadriantest_RegisterNameserver($params) { return ['success' => true]; }
function hadriantest_ModifyNameserver($params)   { return ['success' => true]; }
function hadriantest_DeleteNameserver($params)   { return ['success' => true]; }

function hadriantest_GetEmailForwarding($params)
{
    return [
        ['prefix' => 'hello', 'forwardto' => 'mara.okonkwo@demo.hadrian.test'],
        ['prefix' => 'billing', 'forwardto' => 'accounts@demo.hadrian.test'],
    ];
}
function hadriantest_SaveEmailForwarding($params) { return ['success' => true]; }

function hadriantest_GetDNS($params)
{
    return [
        ['hostname' => '@', 'type' => 'A', 'address' => '192.0.2.10', 'priority' => 'N/A'],
        ['hostname' => 'www', 'type' => 'CNAME', 'address' => 'riverbendstudio.co.uk', 'priority' => 'N/A'],
        ['hostname' => '@', 'type' => 'MX', 'address' => 'mail.riverbendstudio.co.uk', 'priority' => '10'],
    ];
}
function hadriantest_SaveDNS($params) { return ['success' => true]; }

function hadriantest_IDProtectToggle($params) { return ['success' => true]; }

function hadriantest_Sync($params)
{
    return ['active' => true, 'expirydate' => date('Y-m-d', strtotime('+300 days'))];
}
function hadriantest_TransferSync($params) { return ['completed' => true, 'expirydate' => date('Y-m-d', strtotime('+365 days'))]; }

function hadriantest_CheckAvailability($params)
{
    // Every name is available except anything containing "taken".
    $results = new \WHMCS\Domains\DomainLookup\ResultsList();
    foreach ((array)($params['tldsToInclude'] ?? []) as $tld) {
        $r = new \WHMCS\Domains\DomainLookup\SearchResult($params['searchTerm'], $tld);
        $r->setStatus(stripos((string)$params['searchTerm'], 'taken') !== false
            ? \WHMCS\Domains\DomainLookup\SearchResult::STATUS_REGISTERED
            : \WHMCS\Domains\DomainLookup\SearchResult::STATUS_NOT_REGISTERED);
        $results->append($r);
    }
    return $results;
}
