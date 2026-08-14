<?php
/**
 * License diagnostic + cache/opcache tool. Upload to WHMCS ROOT, open in browser,
 * then DELETE it.
 */
header('Content-Type: text/plain; charset=utf-8');

// --- A. What is ACTUALLY in the live hook file on disk? ----------------------
$hook = __DIR__ . '/includes/hooks/hostnodes_theme_license.php';
echo "=== LIVE HOOK FILE ===\n";
echo "path  : {$hook}\n";
if (is_file($hook)) {
    echo "mtime : " . date('Y-m-d H:i:s', filemtime($hook)) . "  (when it was last uploaded)\n";
    $src = (string) file_get_contents($hook);
    foreach (['HOSTNODES_VERIFY_URL', 'HOSTNODES_LICENSE_SECRET', 'HOSTNODES_CHECK_TTL'] as $c) {
        if (preg_match('/const\s+' . $c . '\s*=\s*([^;]+);/', $src, $m)) {
            $v = trim($m[1], " \t'\"");
            if ($c === 'HOSTNODES_LICENSE_SECRET' && strlen($v) > 10) {
                $v = substr($v, 0, 6) . '...' . substr($v, -4);
            }
            echo "{$c} = {$v}\n";
        } else {
            echo "{$c} = (not found)\n";
        }
    }
} else {
    echo "!!! NOT FOUND at this path — the hook isn't where it should be.\n";
}

// --- B. OPcache: report + force-invalidate the hook (and reset if allowed) ---
echo "\n=== OPCACHE ===\n";
echo "opcache.enable             : " . ini_get('opcache.enable') . "\n";
echo "opcache.validate_timestamps: " . ini_get('opcache.validate_timestamps') . "\n";
if (function_exists('opcache_invalidate') && is_file($hook)) {
    echo "invalidate hook file       : " . (@opcache_invalidate($hook, true) ? 'OK (forces recompile)' : 'failed') . "\n";
}
echo "opcache_reset()            : " . (function_exists('opcache_reset') ? (@opcache_reset() ? 'OK' : 'returned false') : 'unavailable') . "\n";

// --- C. Clear the license cache ---------------------------------------------
echo "\n=== LICENSE CACHE ===\n";
$f = sys_get_temp_dir() . '/hn_theme_license.json';
echo "file  : {$f}\n";
if (is_file($f)) {
    echo "before: " . file_get_contents($f) . "\n";
    echo "delete: " . (@unlink($f) ? 'CLEARED' : 'FAILED') . "\n";
} else {
    echo "(none — next load does a fresh check)\n";
}

echo "\n>> Reload your client area, then DELETE this file.\n";
