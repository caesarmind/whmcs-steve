<?php
/**
 * The PHP half of tests/lib/site-lock.mjs: a driver that changes the local
 * site's global state refuses to run while another test run holds
 * tests/.local/site.lock.
 *
 * A process the holder started inherits the lock's token in
 * HADRIAN_SITE_LOCK_TOKEN and is let through: the specs that run these
 * drivers, and the preflight's settings restore. Run by hand while another
 * run holds the lock, a driver would change settings, menus or email
 * templates under that run's tests, so it stops here (exit 75, before WHMCS
 * boots) and names the holder. With no lock, or one whose process has ended,
 * it runs as before; the next run.mjs takes a stale lock over.
 *
 *   require_once __DIR__ . '/site-lock.php';
 *   hadrian_site_lock_guard('settings.php');
 */

declare(strict_types=1);

function hadrian_site_lock_guard(string $script): void
{
    $file = dirname(__DIR__) . '/.local/site.lock';
    if (!is_file($file)) {
        return;
    }
    $lock = json_decode((string) @file_get_contents($file), true);
    if (!is_array($lock) || !is_int($lock['pid'] ?? null)) {
        // Being written, or junk: run.mjs gives a new lock 10 s to get its content.
        if (time() - (int) @filemtime($file) > 10) {
            return;
        }
        $lock = ['pid' => '?', 'startedAt' => 'just now', 'command' => '(lock still being written)'];
    } elseif (($lock['token'] ?? null) === getenv('HADRIAN_SITE_LOCK_TOKEN')
        || !hadrian_site_lock_alive($lock['pid'], (string) ($lock['exe'] ?? ''))) {
        return;
    }
    fwrite(STDERR, sprintf(
        "REFUSING TO RUN: %s changes the local site, and another test run is using it\n"
        . "  (pid %s, started %s): %s\n"
        . "Wait for that run to end. Lock: tests/.local/site.lock\n",
        $script, $lock['pid'], $lock['startedAt'] ?? '?', $lock['command'] ?? '?'
    ));
    exit(75);
}

/** Is $pid running, and still the program that wrote the lock (Windows reuses pids)? */
function hadrian_site_lock_alive(int $pid, string $exe): bool
{
    if ($pid <= 0) {
        return false;
    }
    if (PHP_OS_FAMILY === 'Windows') {
        if (!function_exists('shell_exec')) {
            return true; // cannot tell: assume it is running
        }
        $out = @shell_exec('tasklist /FI "PID eq ' . $pid . '" /FO CSV /NH 2>NUL');
        if (!is_string($out)) {
            return true;
        }
        if (!preg_match('/^"([^"]+)","' . $pid . '"/m', $out, $m)) {
            return false;
        }
        return $exe === '' || strcasecmp($m[1], $exe) === 0;
    }
    if (function_exists('posix_kill')) {
        return posix_kill($pid, 0) || posix_get_last_error() === 1; // EPERM: running, not ours
    }
    return !is_dir('/proc') || is_dir('/proc/' . $pid);
}
