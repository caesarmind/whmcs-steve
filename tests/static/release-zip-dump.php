<?php
/**
 * Reads a release zip with PHP's own ZipArchive and prints what
 * check-release-package.mjs judges, as JSON.
 *
 * A second implementation on purpose: the zip is written by hand-rolled code
 * in hadrian/scripts/package.mjs, so reading it back with that same code would
 * prove nothing. ZipArchive is what a buyer's server would use.
 *
 *   php tests/static/release-zip-dump.php <zip>
 */

declare(strict_types=1);

$zip = new ZipArchive();
if (($argv[1] ?? '') === '' || $zip->open($argv[1]) !== true) {
    fwrite(STDERR, "cannot open the zip\n");
    exit(1);
}

$wanted = [
    'modules/addons/Hadrian/Hadrian.php',
    'modules/addons/Hadrian/release.json',
    'modules/addons/Hadrian/src/Helpers/IntegrityHashes.php',
    'templates/hadrian/core/hadrian.php',
    'templates/hadrian/theme.json',
    'templates/hadrian/release.json',
    'templates/orderforms/hadrian_cart/release.json',
];

$entries  = [];
$contents = [];
$crlf     = [];
for ($i = 0; $i < $zip->numFiles; $i++) {
    $name = (string) $zip->getNameIndex($i);
    $data = $zip->getFromIndex($i);
    if ($data === false) {
        fwrite(STDERR, "cannot read {$name}\n");
        exit(1);
    }
    $entries[$name] = hash('sha256', $data);
    if (in_array($name, $wanted, true)) {
        $contents[$name] = $data;
    }
    // The license files are shipped byte for byte; everything else that is
    // text is stored with LF.
    if (!str_starts_with($name, 'includes/hooks/') && preg_match('/\.(php|tpl|css|js|json|yaml)$/', $name) && str_contains($data, "\r\n")) {
        $crlf[] = $name;
    }
}

// What the Setup page will look for on the buyer's server.
$helpers = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src/Helpers';
require $helpers . '/ThemeSwitch.php';
require $helpers . '/SetupProbe.php';
$consts = (new ReflectionClass(Hadrian\Helpers\SetupProbe::class))->getConstants();

echo json_encode([
    'entries'  => $entries,
    'contents' => $contents,
    'crlf'     => $crlf,
    'probe'    => [
        'theme' => array_map(static fn(string $f): string => 'templates/' . Hadrian\Helpers\ThemeSwitch::THEME . '/' . $f, $consts['THEME_FILES']),
        'cart'  => array_map(static fn(string $f): string => 'templates/orderforms/' . Hadrian\Helpers\ThemeSwitch::CART . '/' . $f, $consts['CART_FILES']),
        'hook'  => $consts['HOOK'],
    ],
]);
