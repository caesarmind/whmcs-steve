<?php
/**
 * Tier 2 - compile every Hadrian template with WHMCS's OWN Smarty.
 *
 *   php tests/compile/compile-all.php [--json]
 *
 * Why this and not .dashbuild/smarty-lint.mjs: the lint is a regex over the
 * source ("we can't compile Smarty without WHMCS"). With the local stack we
 * can, so this asks the real compiler - WHMCS\Smarty, carrying WHMCS's custom
 * modifiers and its security policy. A template that passes here is one
 * production will accept; one that fails here is one that would have fallen
 * the live site back to Six and poisoned templates_c on deploy.
 *
 * Compile, not render: Smarty compiles a whole file regardless of which
 * {if} branch a request would take, so this covers branches no crawl reaches.
 * Output goes to a throwaway compile dir, never the live templates_c.
 */

declare(strict_types=1);

$json = in_array('--json', $argv, true);
$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
if (!is_file($whmcsRoot . '/init.php')) {
    fwrite(STDERR, "WHMCS not found at {$whmcsRoot} (set WHMCS_ROOT)\n");
    exit(2);
}
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

// Each tree is compiled with the Smarty flavour that renders it in production:
// client templates and the order form through the client-area instance, the
// addon's admin views through the admin one.
$trees = [
    ['label' => 'theme',     'dir' => $whmcsRoot . '/templates/hadrian',                  'admin' => false],
    ['label' => 'orderform', 'dir' => $whmcsRoot . '/templates/orderforms/hadrian_cart', 'admin' => false],
    ['label' => 'admin',     'dir' => $whmcsRoot . '/modules/addons/Hadrian/views',      'admin' => true],
];

$compileDir = rtrim(sys_get_temp_dir(), '/\\') . '/hadrian-compile-' . getmypid();
@mkdir($compileDir, 0777, true);

$results = [];
$failed = 0;
$total = 0;

foreach ($trees as $tree) {
    if (!is_dir($tree['dir'])) {
        $results[] = ['tree' => $tree['label'], 'file' => '(tree)', 'ok' => false, 'error' => 'directory missing: ' . $tree['dir']];
        $failed++;
        continue;
    }
    $files = [];
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($tree['dir'], FilesystemIterator::SKIP_DOTS));
    foreach ($it as $f) {
        if ($f->getExtension() !== 'tpl') { continue; }
        $files[] = str_replace('\\', '/', substr($f->getPathname(), strlen($tree['dir']) + 1));
    }
    sort($files);

    foreach ($files as $rel) {
        $total++;
        // A fresh instance per file so one failure cannot leave compiler
        // state behind that changes the verdict on the next file.
        $smarty = new WHMCS\Smarty($tree['admin']);
        $smarty->setTemplateDir($tree['dir']);
        $smarty->setCompileDir($compileDir);
        $smarty->setCaching(Smarty::CACHING_OFF);
        try {
            $tpl = $smarty->createTemplate($rel);
            $tpl->compileTemplateSource();
            $results[] = ['tree' => $tree['label'], 'file' => $rel, 'ok' => true];
        } catch (Throwable $e) {
            $failed++;
            $msg = preg_replace('/\s+/', ' ', $e->getMessage());
            $results[] = ['tree' => $tree['label'], 'file' => $rel, 'ok' => false, 'error' => $msg];
        }
    }
}

// Leave nothing behind.
$rm = function (string $d) use (&$rm): void {
    foreach (glob($d . '/*') ?: [] as $p) { is_dir($p) ? $rm($p) : @unlink($p); }
    @rmdir($d);
};
$rm($compileDir);

if ($json) {
    echo json_encode(['total' => $total, 'failed' => $failed, 'results' => $results], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), "\n";
} else {
    foreach ($results as $r) {
        if (!$r['ok']) { printf("FAIL  [%s] %s\n      %s\n", $r['tree'], $r['file'], $r['error']); }
    }
    printf("%d template(s) compiled with WHMCS\\Smarty; %d failed\n", $total, $failed);
}
exit($failed ? 1 : 0);
