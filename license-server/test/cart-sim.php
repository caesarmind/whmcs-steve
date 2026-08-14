<?php
declare(strict_types=1);
/**
 * Cart (order-form) licensing: verifies the marker parses and that the shared
 * product-license decision (AddonHelper::isProductLicensed) flips correctly.
 * The ClientAreaPage hook reverts OrderFormTemplate->standard_cart whenever this
 * returns false.
 *
 *   node ../server.mjs        # must be running
 *   php cart-sim.php
 */
namespace MyTheme\Models {
    final class Configuration {
        public static array $store = [];
        public static function getValue(string $k): ?string { return self::$store[$k] ?? null; }
        public static function setValue(string $k, string $v): void { self::$store[$k] = $v; }
        public static function deleteValue(string $k): void { unset(self::$store[$k]); }
    }
}

namespace {
    use MyTheme\Template\Template;
    use MyTheme\Template\License;
    use MyTheme\Helpers\AddonHelper;

    $_SERVER['SERVER_NAME'] = 'bill.hostnodes.com';
    $base = realpath(__DIR__ . '/../../mytheme/modules/addons/MyTheme/src');
    foreach ([
        '/Helpers/IntegrityHashes.php', '/Helpers/ThemeManifest.php',
        '/Template/LicenseState.php', '/Template/License.php', '/Template/LicenseHelper.php',
        '/Template/Template.php', '/Helpers/AddonHelper.php',
    ] as $f) {
        require $base . $f;
    }
    License::$licenseServerUrl = getenv('LICENSE_URL') ?: 'http://127.0.0.1:8787/check';

    echo "Cart (order-form) licensing\n" . str_repeat('-', 60) . "\n";

    // 1. Marker parses
    $m = include __DIR__ . '/../../mytheme_cart/core/mytheme_cart.php';
    $okMarker = is_array($m) && ($m['type'] ?? '') === 'orderform' && ($m['product'] ?? '') === 'mytheme';
    printf("  marker parse                 %s (type=%s, product=%s)\n",
        $okMarker ? 'OK ' : 'BAD', $m['type'] ?? '?', $m['product'] ?? '?');

    // 2. Shared product-license decision (drives OrderFormTemplate revert)
    $lic = (new Template('mytheme'))->license();

    $lic->setLicenseKey('HOSTNODES-DEV-ACTIVE-0001'); $lic->refreshNow();
    printf("  product Active               isProductLicensed=%-5s -> cart stays mytheme_cart\n",
        AddonHelper::isProductLicensed('mytheme') ? 'true' : 'false');

    $lic->setLicenseKey('HOSTNODES-DEV-CANCELLED'); $lic->refreshNow();
    printf("  product Cancelled            isProductLicensed=%-5s -> cart reverts to standard_cart\n",
        AddonHelper::isProductLicensed('mytheme') ? 'true' : 'false');

    printf("  product template missing     isProductLicensed=%-5s -> cart reverts to standard_cart\n",
        AddonHelper::isProductLicensed('not-installed') ? 'true' : 'false');

    echo str_repeat('-', 60) . "\nExpected: marker OK, Active=true, Cancelled=false, missing=false\n";
}
