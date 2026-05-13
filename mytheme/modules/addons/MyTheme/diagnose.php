<?php
/**
 * MyTheme front-end diagnostic. Hit this URL in a browser to dump the
 * full hook chain so we can see exactly where $myTheme stops populating.
 *
 *   /modules/addons/MyTheme/diagnose.php
 *
 * This file is brand new and therefore not present in any PHP opcache —
 * so even if opcache is serving stale bytecode for Hooks.php, this
 * script runs fresh code paths and reports what they return.
 *
 * SAFE TO DELETE once the bug is diagnosed. Returns plain text only,
 * no DB writes.
 */

declare(strict_types=1);

// Locate the WHMCS root: this file is at <root>/modules/addons/MyTheme/diagnose.php
$whmcsRoot = realpath(__DIR__ . '/../../..');
if ($whmcsRoot === false || !file_exists($whmcsRoot . '/init.php')) {
    header('Content-Type: text/plain; charset=utf-8');
    echo "ERROR: could not locate WHMCS root from " . __DIR__ . "\n";
    echo "Looked for /init.php at: " . ($whmcsRoot ?: '(realpath failed)') . "\n";
    exit(1);
}

define('WHMCS', true);
require_once $whmcsRoot . '/init.php';
require_once __DIR__ . '/autoload.php';

use MyTheme\Helpers\AddonHelper;
use MyTheme\Service\Hooks as HookService;
use MyTheme\Models\Settings;
use MyTheme\Menu\Audience;

header('Content-Type: text/plain; charset=utf-8');

echo "=================================================================\n";
echo " MyTheme Diagnostic — " . date('Y-m-d H:i:s') . "\n";
echo "=================================================================\n\n";

// ─── 1. Addon active? ─────────────────────────────────────────────────
echo "[1] AddonHelper::isActive(): "
   . (AddonHelper::isActive() ? 'TRUE' : 'FALSE')
   . "\n";

// ─── 2. Active template name ──────────────────────────────────────────
$activeName = AddonHelper::getActiveTemplateName();
echo "[2] AddonHelper::getActiveTemplateName(): '" . $activeName . "'\n";

// ─── 3. Template object ───────────────────────────────────────────────
$template = null;
try {
    $template = AddonHelper::getTemplate();
    if ($template === null) {
        echo "[3] AddonHelper::getTemplate(): NULL"
           . " (Template constructor threw and was swallowed)\n";
    } else {
        echo "[3] AddonHelper::getTemplate(): Template(slug='"
           . $template->getName() . "', version='"
           . $template->getVersion() . "')\n";
    }
} catch (\Throwable $e) {
    echo "[3] EXCEPTION getting template: " . $e->getMessage()
       . " (" . $e->getFile() . ':' . $e->getLine() . ")\n";
}

// ─── 4. canActivate() ─────────────────────────────────────────────────
if ($template !== null) {
    try {
        $can = $template->canActivate();
        echo "[4] \$template->canActivate(): " . ($can ? 'TRUE' : 'FALSE') . "\n";
        try {
            $license = $template->license();
            echo "    license->isActive(): " . ($license->isActive() ? 'TRUE' : 'FALSE') . "\n";
            echo "    license->isDevMode(): " . ($license->isDevMode() ? 'TRUE' : 'FALSE') . "\n";
        } catch (\Throwable $e) {
            echo "    license inspection threw: " . $e->getMessage() . "\n";
        }
    } catch (\Throwable $e) {
        echo "[4] canActivate() EXCEPTION: " . $e->getMessage() . "\n";
    }
}

// ─── 5. Audience::current() ───────────────────────────────────────────
echo "[5] Audience::current(): '" . Audience::current() . "'\n";

// ─── 6. Raw settings rows ─────────────────────────────────────────────
echo "\n[6] mytheme_settings rows (layout-related):\n";
try {
    $rows = \WHMCS\Database\Capsule::table('mytheme_settings')
        ->where('setting', 'LIKE', '%layout%')
        ->orWhere('setting', 'LIKE', '%footer%')
        ->orderBy('setting')
        ->get(['setting', 'value', 'updated_at']);
    foreach ($rows as $r) {
        echo "    " . str_pad($r->setting, 50) . " = "
           . str_pad((string)$r->value, 15)
           . " (updated " . $r->updated_at . ")\n";
    }
    if (count($rows) === 0) {
        echo "    (no rows)\n";
    }
} catch (\Throwable $e) {
    echo "    DB read EXCEPTION: " . $e->getMessage() . "\n";
}

// ─── 7. Settings::all() output ────────────────────────────────────────
echo "\n[7] Settings::all() returned keys (filtered to layout/footer):\n";
try {
    $all = Settings::all();
    echo "    total rows: " . count($all) . "\n";
    foreach ($all as $k => $v) {
        if (str_contains($k, 'layout') || str_contains($k, 'footer')) {
            $vRender = is_string($v) ? $v : json_encode($v);
            echo "    " . str_pad($k, 50) . " = " . $vRender . "\n";
        }
    }
} catch (\Throwable $e) {
    echo "    Settings::all() EXCEPTION: " . $e->getMessage() . "\n";
}

// ─── 8. Full dispatch ──────────────────────────────────────────────────
echo "\n[8] HookService::instance()->dispatch('ClientAreaPage', …):\n";
try {
    $result = HookService::instance()->dispatch(
        'ClientAreaPage',
        ['templatefile' => 'homepage', 'language' => 'english']
    );
    if ($result === null) {
        echo "    RETURNED NULL\n";
        echo "    → If template is non-null and method exists, this means\n";
        echo "      either the canActivate gate is still in place on the\n";
        echo "      server, or clientAreaPage threw silently.\n";
    } elseif (is_array($result)) {
        echo "    RETURNED array with keys: " . implode(', ', array_keys($result)) . "\n";
        if (isset($result['myTheme'])) {
            $mt = $result['myTheme'];
            echo "    myTheme.name:    " . ($mt['name'] ?? '<missing>') . "\n";
            echo "    myTheme.version: " . ($mt['version'] ?? '<missing>') . "\n";
            echo "    myTheme.layouts.main-menu.name: "
               . ($mt['layouts']['main-menu']['name'] ?? '<missing>') . "\n";
            echo "    myTheme.layouts.footer.name:    "
               . ($mt['layouts']['footer']['name'] ?? '<missing>') . "\n";
            echo "    myTheme.license.canRender: "
               . (isset($mt['license']['canRender']) ? var_export($mt['license']['canRender'], true) : '<missing>') . "\n";
            echo "    myTheme.addonSettings count: "
               . (isset($mt['addonSettings']) ? count($mt['addonSettings']) : '<missing>') . "\n";
        }
    }
} catch (\Throwable $e) {
    echo "    EXCEPTION: " . $e->getMessage() . "\n";
    echo "    at " . $e->getFile() . ':' . $e->getLine() . "\n";
    echo "    trace:\n" . $e->getTraceAsString() . "\n";
}

// ─── 9. File on disk vs git origin/main ───────────────────────────────
echo "\n[9] Hooks.php first 5 lines of dispatch() on disk:\n";
$hooksPath = __DIR__ . '/src/Service/Hooks.php';
if (file_exists($hooksPath)) {
    $contents = file_get_contents($hooksPath);
    $offset   = strpos($contents, 'function dispatch');
    if ($offset !== false) {
        $snippet = substr($contents, $offset, 800);
        echo "    " . str_replace("\n", "\n    ", trim($snippet)) . "\n";
    } else {
        echo "    'function dispatch' not found in file\n";
    }
} else {
    echo "    Hooks.php not found at $hooksPath\n";
}

echo "\n=================================================================\n";
echo " Diagnostic complete. Paste this output back so we can read it.\n";
echo " Delete this file once we're done: $hooksPath\n";
echo "=================================================================\n";
