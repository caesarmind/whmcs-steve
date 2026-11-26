#!/usr/bin/env node
// scripts/inject-integrity-hashes.mjs
//
// Computes sha256 of every protected PHP file and writes the resulting map
// into modules/addons/Hadrian/src/Helpers/IntegrityHashes.php.
//
// The hashes must describe the files exactly as they reach the buyer, so run it
// on the tree that ships, after the last change to it: scripts/package.mjs
// calls writeIntegrityHashes() on its staging folder once the release version
// is stamped in. Anything that rewrites a protected file afterwards (an
// encoder included) makes the hashes wrong, and the site then blocks itself.
//
// Run: npm run build:integrity            the working tree (rarely what you want:
//                                         the next PHP edit trips the check)
//      node scripts/inject-integrity-hashes.mjs --root <dir>

import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, dirname, relative } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

/**
 * Hash the protected files under `root` (a folder laid out like hadrian/, or
 * like a WHMCS root) and write IntegrityHashes.php there.
 *
 * @returns {number} how many files were hashed
 * @throws when a protected file is missing
 */
export function writeIntegrityHashes(root, log = console.log) {
// Targets — paths relative to ROOTDIR (the WHMCS install root, where this addon
// gets dropped into modules/addons/Hadrian/).
const TARGETS_FILE = resolve(__dirname, 'integrity-targets.json');
const targets = JSON.parse(readFileSync(TARGETS_FILE, 'utf8'));

log('Computing integrity hashes...');

const hashes = {};
for (const relativePath of targets) {
  const abs = resolve(root, relativePath);
  let buf;
  try {
    buf = readFileSync(abs);
  } catch (e) {
    throw new Error(`Integrity target is missing: ${relativePath}`);
  }
  const hash = createHash('sha256').update(buf).digest('hex');
  hashes[relativePath] = hash;
  log(`  ${relativePath} → ${hash.slice(0, 16)}...`);
}

const phpEntries = Object.entries(hashes)
  .map(([path, hash]) => `        '${path.replaceAll('\\', '/')}' => '${hash}',`)
  .join('\n');

const phpContent = `<?php
declare(strict_types=1);

namespace Hadrian\\Helpers;

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
<p>File integrity check failed (reason: {$reason}). Reinstall Hadrian or contact support.</p>
<code>{$safe}</code></body></html>
HTML;
        exit(503);
    }
}
`;

const outFile = resolve(root, 'modules/addons/Hadrian/src/Helpers/IntegrityHashes.php');
writeFileSync(outFile, phpContent);
log(`\n✓ Wrote ${relative(root, outFile)} (${Object.keys(hashes).length} hashes)`);
return Object.keys(hashes).length;
}

// Run directly (not imported by package.mjs).
if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const at = process.argv.indexOf('--root');
  const root = at >= 0 && process.argv[at + 1] ? resolve(process.argv[at + 1]) : resolve(__dirname, '..');
  try {
    writeIntegrityHashes(root);
  } catch (e) {
    console.error(`  ${e.message}`);
    process.exit(1);
  }
}
