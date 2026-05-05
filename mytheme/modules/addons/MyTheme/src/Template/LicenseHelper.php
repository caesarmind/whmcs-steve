<?php
declare(strict_types=1);

namespace MyTheme\Template;

use MyTheme\Helpers\IntegrityHashes;

/**
 * Per-request License singleton. Avoids duplicate remote checks within a request.
 */
final class LicenseHelper
{
    /** @var array<string, License> */
    private static array $instances = [];

    public static function getInstance(string $licenseKeyName, string $secretKey, Template $template): License
    {
        IntegrityHashes::verifyOrDie(__FILE__);
        return self::$instances[$licenseKeyName] ??= new License($licenseKeyName, $secretKey, $template);
    }

    private function __construct() {}
    private function __clone() {}
}
