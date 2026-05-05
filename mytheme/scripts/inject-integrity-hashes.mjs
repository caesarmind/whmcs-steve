#!/usr/bin/env node
// scripts/inject-integrity-hashes.mjs
//
// Computes sha256 of every protected PHP file and writes the resulting map
// into modules/addons/MyTheme/src/Helpers/IntegrityHashes.php.
//
// Run AFTER any PHP edit, BEFORE encoding.
//
// Run: npm run build:integrity

import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, '..');

// Targets — paths relative to ROOTDIR (the WHMCS install root, where this addon
// gets dropped into modules/addons/MyTheme/).
const TARGETS_FILE = resolve(__dirname, 'integrity-targets.json');
const targets = JSON.parse(readFileSync(TARGETS_FILE, 'utf8'));

console.log('Computing integrity hashes...');

const hashes = {};
for (const relativePath of targets) {
  const abs = resolve(root, relativePath);
  try {
    const buf = readFileSync(abs);
    const hash = createHash('sha256').update(buf).digest('hex');
    hashes[relativePath] = hash;
    console.log(`  ${relativePath} → ${hash.slice(0, 16)}...`);
  } catch (e) {
    console.error(`  MISSING: ${relativePath}`);
    process.exit(1);
  }
}

const phpEntries = Object.entries(hashes)
  .map(([path, hash]) => `        '${path.replaceAll('\\', '/')}' => '${hash}',`)
  .join('\n');

const phpContent = `<?php
declare(strict_types=1);

namespace MyTheme\\Helpers;

/**
 * Anti-tamper file-integrity verifier — GENERATED.
 *
 * This file is overwritten by scripts/inject-integrity-hashes.mjs.
 * Do not edit by hand.
 */
final class IntegrityHashes
{
    /** @var array<string, string> */
    private const HASHES = [
${phpEntries}
    ];

    private static bool $verified = false;

    public static function verifyOrDie(string $callerFile): void
    {
        if (self::$verified) {
            return;
        }
        if (self::HASHES === [] || !defined('ROOTDIR')) {
            self::$verified = true;
            return;
        }

        foreach (self::HASHES as $relPath => $expected) {
            $abs = ROOTDIR . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relPath);
            if (!file_exists($abs)) {
                self::block(reason: 'missing', file: $relPath);
            }
            $actual = (string)hash_file('sha256', $abs);
            if (!hash_equals($expected, $actual)) {
                self::block(reason: 'modified', file: $relPath);
            }
        }

        self::$verified = true;
    }

    private static function block(string $reason, string $file): never
    {
        if (function_exists('ob_clean')) {
            @ob_clean();
        }
        http_response_code(503);
        $safe = htmlspecialchars($file, ENT_QUOTES);
        echo <<<HTML
<!DOCTYPE html><html><head><title>Access blocked</title>
<style>body{font-family:system-ui,sans-serif;max-width:640px;margin:80px auto;padding:24px;color:#333}
h1{color:#c00}code{background:#fceeef;padding:8px 12px;border-radius:4px;display:block;margin-top:16px}</style>
</head><body><h1>Access has been blocked</h1>
<p>File integrity check failed (reason: {$reason}). Reinstall MyTheme or contact support.</p>
<code>{$safe}</code></body></html>
HTML;
        exit(503);
    }
}
`;

const outFile = resolve(root, 'modules/addons/MyTheme/src/Helpers/IntegrityHashes.php');
writeFileSync(outFile, phpContent);
console.log(`\n✓ Wrote ${relative(root, outFile)} (${Object.keys(hashes).length} hashes)`);
