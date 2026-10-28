<?php
/**
 * Unit test for VisibilityGate::decide() - the decision half of per-page
 * Visibility enforcement (Hooks::enforceVisibility is the I/O half; it only
 * gathers inputs and redirects, so the behaviour worth testing is all here).
 *
 * Runs the real class (plus the real Template class, whose ORDER_PAGES const
 * the gate reads) with no WHMCS and no stubs. Every guardrail from the class
 * docblock has a case, because each one is a lockout bug if it regresses.
 *
 *   php tests/static/test-visibility-gate.php
 */

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';

/* The anti-tamper hash table is a gitignored build artifact; load it the way
   the addon does (hooks.php) - the real one when present, the tracked stub
   otherwise. A checker that needed the generated file only ran on one machine. */
require is_file($admin . '/src/Helpers/IntegrityHashes.php')
    ? $admin . '/src/Helpers/IntegrityHashes.php'
    : $admin . '/src/Helpers/IntegrityHashes.fallback.php';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Template/Template.php';
require $admin . '/src/Helpers/VisibilityGate.php';

use Hadrian\Helpers\VisibilityGate;

$failures = 0;

/** @param array{0:?string,1:?string,2:string,3:bool,4:bool} $in */
function check(array $in, ?string $want, string $why): void
{
    global $failures;
    $got = VisibilityGate::decide(...$in);
    if ($got === $want) {
        echo "  ok    {$why}\n";
    } else {
        $failures++;
        echo "  FAIL  {$why} - wanted " . var_export($want, true) . ", got " . var_export($got, true) . "\n";
    }
}

// -- the common case: public and unset rows render for everyone -------------
check(['public',   'Public',      'contact',        false, false], null, 'public page renders for guests');
check([null,       'Client Area', 'clientareahome', false, false], null, 'null visibility fails open');
check(['',         'Client Area', 'clientareahome', false, false], null, 'blank visibility fails open');
check(['banana',   'Public',      'contact',        false, false], null, 'unknown value fails open');

// -- disabled: 404 for the world, preview for admins ------------------------
check(['disabled', 'Public',      'store-sitelock', false, false], VisibilityGate::NOT_FOUND, 'disabled page 404s for guests');
check(['disabled', 'Public',      'store-sitelock', true,  false], VisibilityGate::NOT_FOUND, 'disabled page 404s for signed-in clients too');
check(['disabled', 'Public',      'store-sitelock', false, true],  null, 'admin session bypasses disabled (preview)');

// -- auth: login redirect for guests only -----------------------------------
check(['auth',     'Client Area', 'affiliates',     false, false], VisibilityGate::LOGIN, 'auth page sends guests to login');
check(['auth',     'Client Area', 'affiliates',     true,  false], null, 'auth page renders for signed-in clients');
check(['auth',     'Client Area', 'affiliates',     false, true],  null, 'auth page renders for admins');

// -- guardrail: the Authentication group can never be gated -----------------
check(['auth',     'Authentication', 'login',                         false, false], null, 'auth on the login page would be a redirect loop - exempt');
check(['disabled', 'Authentication', 'password-reset-container',      false, false], null, 'disabling password reset locks out the locked-out - exempt');

// -- guardrail: the order flow can never be gated ----------------------------
check(['disabled', 'Order Process', 'checkout', false, false], null, 'checkout is exempt whatever the row says');
check(['auth',     'Order Process', 'viewcart', false, false], null, 'view cart is exempt whatever the row says');
check(['disabled', 'Order Process', 'products', false, false], null, 'the storefront entry is exempt');

// -- guardrail: WHMCS dead-end pages can never be gated ---------------------
check(['disabled', 'Public',      'banned',          false, false], null, 'banned page must render for the banned');
check(['disabled', 'Client Area', 'access-denied',   false, false], null, 'access-denied must render for the denied');
check(['auth',     'Shop',        'store-not-found', false, false], null, 'store-not-found must render for anyone');

// -- the exemptions do not leak to lookalike pages ---------------------------
check(['disabled', 'Shop',        'store-order',     false, false], VisibilityGate::NOT_FOUND, 'a non-exempt shop page still gates');
check(['auth',     'Account',     'clientareadetails', false, false], VisibilityGate::LOGIN, 'a non-exempt account page still gates');

echo $failures === 0 ? "\n  all checks passed\n" : "\n  {$failures} FAILURE(S)\n";
exit($failures === 0 ? 0 : 1);
