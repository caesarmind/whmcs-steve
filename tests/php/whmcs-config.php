<?php
/**
 * Read or change ONE WHMCS setting (tblconfiguration) for the length of a test.
 *
 *   php tests/php/whmcs-config.php get <setting>          -> JSON value, or null if the row is absent
 *   php tests/php/whmcs-config.php set <setting> <value>
 *   php tests/php/whmcs-config.php unset <setting>        (absent = WHMCS's built-in default)
 *
 * A test reads the old value first and puts it back in a finally block. Used
 * by the sign-up flow to switch the registration CAPTCHA off for its own run:
 * a test cannot (and must not) solve a CAPTCHA, and the smoke tier still
 * renders the CAPTCHA on register.php. Refuses unless SystemURL is localhost.
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

[$cmd, $key, $value] = [$argv[1] ?? '', $argv[2] ?? '', $argv[3] ?? null];
if ($key === '' || $key === 'SystemURL') { fwrite(STDERR, "usage: whmcs-config.php get|set|unset <setting> [value]\n"); exit(1); }

switch ($cmd) {
    case 'get':
        echo json_encode(DB::table('tblconfiguration')->where('setting', $key)->value('value'));
        break;
    case 'set':
        DB::table('tblconfiguration')->updateOrInsert(['setting' => $key], ['value' => (string) $value]);
        echo "set\n";
        break;
    case 'unset':
        DB::table('tblconfiguration')->where('setting', $key)->delete();
        echo "unset\n";
        break;
    default:
        fwrite(STDERR, "usage: whmcs-config.php get|set|unset <setting> [value]\n");
        exit(1);
}
