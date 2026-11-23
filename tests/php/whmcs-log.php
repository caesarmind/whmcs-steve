<?php
/**
 * What WHMCS logged about the theme while the tests ran.
 *
 *   php tests/php/whmcs-log.php mark            -> {"activity": N, "error": M}
 *   php tests/php/whmcs-log.php since N M       -> JSON list of findings
 *
 * WHMCS swallows most template failures and writes them to its own logs
 * instead of the page: a missing {include} becomes "Smarty Error: Default
 * handler: No template default content for ..." in the activity log, and a
 * template reading $key@iteration or an array offset on null becomes a PHP
 * warning in tblerrorlog whose file is a compiled template in templates_c.
 * Every one of these returned HTTP 200 with a normal-looking page; the log was
 * the only place they showed - 4,421 times for one missing include.
 *
 * Findings are grouped (message + source template + line) and, for compiled
 * templates, mapped back to the .tpl they were compiled from.
 */

declare(strict_types=1);

$whmcsRoot = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
chdir($whmcsRoot);
require_once $whmcsRoot . '/init.php';

use WHMCS\Database\Capsule as DB;

$cmd = $argv[1] ?? '';
if ($cmd === 'mark') {
    echo json_encode(['activity' => (int) DB::table('tblactivitylog')->max('id'), 'error' => (int) DB::table('tblerrorlog')->max('id')]);
    exit(0);
}
if ($cmd !== 'since') { fwrite(STDERR, "usage: whmcs-log.php mark | since <activityId> <errorId>\n"); exit(1); }

$sinceActivity = (int) ($argv[2] ?? 0);
$sinceError = (int) ($argv[3] ?? 0);
$out = [];

/** templates_c\<hash>.file.<name>.tpl.php -> the source .tpl, relative to templates/ */
$sourceOf = function (string $compiled): string {
    static $cache = [];
    if (isset($cache[$compiled])) return $cache[$compiled];
    $f = getcwd() . '/' . str_replace('\\', '/', $compiled);
    $src = $compiled;
    if (is_file($f) && preg_match('~from\s+\'([^\']+\.tpl)\'~', (string) file_get_contents($f, false, null, 0, 600), $m)) {
        $src = preg_replace('~^.*[\\\\/]templates[\\\\/]~', '', $m[1]);
    }
    return $cache[$compiled] = str_replace('\\', '/', $src);
};

foreach (DB::table('tblactivitylog')->where('id', '>', $sinceActivity)
    ->where(fn($q) => $q->where('description', 'like', 'Smarty Error%')->orWhere('description', 'like', '%template%rror%'))
    ->selectRaw('description, count(*) n')->groupBy('description')->get() as $r) {
    // A failed compile-cache write on Windows is the known non-atomic rename
    // race (tests/lib/warmup.mjs), not a theme bug.
    if (str_contains($r->description, 'unable to write file')) continue;
    $out[] = ['log' => 'activity', 'count' => (int) $r->n, 'message' => $r->description, 'source' => null, 'line' => null];
}

foreach (DB::table('tblerrorlog')->where('id', '>', $sinceError)
    ->selectRaw('message, filename, line, count(*) n')->groupBy('message', 'filename', 'line')->get() as $r) {
    $file = (string) $r->filename;
    $isTemplate = str_starts_with($file, 'templates_c');
    $isOurs = $isTemplate || stripos($file, 'Hadrian') !== false || stripos((string) $r->message, 'templates/hadrian') !== false
        || stripos((string) $r->message, 'hadrian_cart') !== false;
    if (!$isOurs) continue;
    if (preg_match('~^rename\(.*templates_c|^mkdir\(\): File exists~', (string) $r->message)) continue;   // Windows compile race
    $out[] = [
        'log' => 'error', 'count' => (int) $r->n, 'message' => (string) $r->message,
        'source' => $isTemplate ? $sourceOf($file) : str_replace('\\', '/', $file), 'line' => (int) $r->line,
    ];
}

echo json_encode($out, JSON_UNESCAPED_SLASHES);
