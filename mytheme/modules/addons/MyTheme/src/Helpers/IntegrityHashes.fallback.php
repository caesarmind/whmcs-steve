<?php
declare(strict_types=1);

namespace MyTheme\Helpers;

/**
 * No-op fallback used when the build-time-generated
 * src/Helpers/IntegrityHashes.php is absent — which is the normal state in
 * source-tree deploys (the real file is .gitignore'd because it's overwritten
 * by `npm run build:integrity` at release time).
 *
 * Three callers (License, LicenseHelper, Template) call verifyOrDie() from
 * their constructors. Without this stub, those classes throw 'class not
 * found' and the addon fatals before the license tab can even load.
 *
 * MyTheme.php picks ONE of {real, fallback} based on file_exists; both
 * declare the same fully-qualified class so callers don't care which.
 *
 * Production releases ship the real file (which still defines the same
 * class but with the actual hash map and verification logic) — this
 * fallback is only loaded in dev / source-tree installs.
 */
final class IntegrityHashes
{
    public static function verifyOrDie(string $callerFile): void
    {
        // No-op in dev. The real generated file checks sha256_file()
        // against a build-time hash map and exits on mismatch.
    }
}
