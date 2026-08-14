<?php
declare(strict_types=1);
/**
 * Proves AddonHelper::ourOrderForms() discovers an order-form marker on the
 * LIVE directory layout: ROOTDIR/templates/orderforms/<slug>/core/<slug>.php.
 * (In the repo the cart lives at top-level mytheme_cart/, so we build a tiny
 * fixture with ROOTDIR pointed at it.)
 */
$tmp      = sys_get_temp_dir() . '/mt-of-test-' . getmypid();
$cartCore = $tmp . '/templates/orderforms/mytheme_cart/core';
mkdir($cartCore, 0777, true);
copy(__DIR__ . '/../../mytheme_cart/core/mytheme_cart.php', $cartCore . '/mytheme_cart.php');
define('ROOTDIR', $tmp);

require realpath(__DIR__ . '/../../mytheme/modules/addons/MyTheme/src') . '/Helpers/AddonHelper.php';
$forms = \MyTheme\Helpers\AddonHelper::ourOrderForms();

echo "ourOrderForms() discovery (fixture ROOTDIR)\n" . str_repeat('-', 56) . "\n";
printf("  discovered: %s\n", implode(', ', array_keys($forms)) ?: '(none)');
$ok = isset($forms['mytheme_cart']) && ($forms['mytheme_cart']['product'] ?? '') === 'mytheme';
printf("  %s\n", $ok ? 'OK — mytheme_cart found, product=mytheme' : 'BAD — not discovered');

// cleanup
@unlink($cartCore . '/mytheme_cart.php');
for ($p = $cartCore; strlen($p) > strlen($tmp) - 1; $p = dirname($p)) { @rmdir($p); }
exit($ok ? 0 : 1);
