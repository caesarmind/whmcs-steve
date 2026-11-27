<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * The Setup page's checklist, worked out from facts about this install.
 *
 * Nothing here reads the disk, the database or the network: SetupProbe
 * gathers the facts and this class only judges them. That is what lets
 * tests/static/test-setup.php run every branch without a WHMCS.
 *
 * There is no stored "installed" flag. Every row is read from the real state
 * each time, so the page cannot say "done" about an install where a folder
 * was deleted or an update left the database behind.
 *
 * Row states:
 *   ok    in order
 *   warn  works, but worth a look; never stops the theme going live
 *   todo  a step that has not been done yet
 *   fail  broken; needs fixing before the step can be done
 * A todo or fail in any group before "Go live" keeps the go-live button off.
 */
final class SetupChecks
{
    public const OK   = 'ok';
    public const WARN = 'warn';
    public const TODO = 'todo';
    public const FAIL = 'fail';

    private const RANK = [self::OK => 0, self::WARN => 1, self::TODO => 2, self::FAIL => 3];

    /**
     * @param array<string,mixed> $f facts, in the shape SetupProbe::facts() returns
     * @return list<array{key:string,title:string,state:string,rows:list<array{key:string,label:string,state:string,detail:string,path:string}>}>
     */
    public static function evaluate(array $f): array
    {
        $groups = [
            ['key' => 'files',        'title' => 'Files',        'rows' => self::files($f)],
            ['key' => 'requirements', 'title' => 'Requirements', 'rows' => self::requirements($f)],
            ['key' => 'database',     'title' => 'Database',     'rows' => self::database($f)],
            ['key' => 'license',      'title' => 'License',      'rows' => self::license($f)],
            ['key' => 'golive',       'title' => 'Go live',      'rows' => self::goLive($f)],
        ];
        foreach ($groups as &$g) {
            $g['state'] = self::worst($g['rows']);
        }
        unset($g);
        return $groups;
    }

    /**
     * @param list<array<string,mixed>> $groups what evaluate() returned
     * @param array<string,mixed>       $f      the same facts
     * @return array{blocked:bool,live:bool,cartReady:bool,cartLive:bool,finished:bool,done:int,total:int,canSwitchBack:bool}
     */
    public static function summary(array $groups, array $f): array
    {
        $blocked = false;
        $done    = 0;
        foreach ($groups as $g) {
            if (self::RANK[$g['state']] <= self::RANK[self::WARN]) {
                $done++;
            }
            if ($g['key'] !== 'golive' && self::RANK[$g['state']] >= self::RANK[self::TODO]) {
                $blocked = true;
            }
        }

        $theme     = (string)($f['slugs']['theme'] ?? '');
        $cart      = (string)($f['slugs']['cart'] ?? '');
        $live      = ($f['live']['template'] ?? '') === $theme;
        $cartReady = self::folderComplete($f['cart'] ?? []);
        $cartLive  = ($f['live']['orderform'] ?? '') === $cart;
        $prev      = (string)($f['live']['prev_template'] ?? '');

        return [
            'blocked'       => $blocked,
            'live'          => $live,
            'cartReady'     => $cartReady,
            'cartLive'      => $cartLive,
            'finished'      => !$blocked && $live && (!$cartReady || $cartLive),
            'done'          => $done,
            'total'         => count($groups),
            'canSwitchBack' => $live && $prev !== '' && $prev !== $theme,
        ];
    }

    /** Does `$version` meet a constraint such as ">=8.1"? No operator means "at least". */
    public static function meets(string $version, string $constraint): bool
    {
        if (!preg_match('/^\s*(>=|<=|>|<|==|=)?\s*([0-9][0-9A-Za-z.\-]*)\s*$/', $constraint, $m)) {
            return true; // a constraint we cannot read is not a reason to block anyone
        }
        $op = $m[1] === '' ? '>=' : ($m[1] === '=' ? '==' : $m[1]);
        return version_compare(self::numeric($version), self::numeric($m[2]), $op);
    }

    // ------------------------------------------------------------------ groups

    private static function files(array $f): array
    {
        $rows  = [];
        $theme = $f['theme'] ?? [];
        $cart  = $f['cart'] ?? [];
        $hook  = $f['hook'] ?? [];

        // Client area theme
        $path = (string)($theme['path'] ?? '');
        if (empty($theme['present'])) {
            $rows[] = self::row('theme', 'Client area theme', self::FAIL,
                'Not uploaded. Upload the "hadrian" folder from the release into templates/.', $path);
        } elseif (!empty($theme['missing'])) {
            $rows[] = self::row('theme', 'Client area theme', self::FAIL,
                'Some files did not arrive: ' . self::listOf($theme['missing']) . '. Upload the "hadrian" folder again.', $path);
        } else {
            $version = (string)($theme['version'] ?? '');
            $rows[] = self::row('theme', 'Client area theme', self::OK,
                $version !== '' ? 'Version ' . $version : 'Uploaded', $path);
        }

        // Order form. Missing is a warning, not a stop: the client area runs
        // without it and some sites keep a third-party order form on purpose.
        // Half-uploaded is a stop, because going live would switch checkout
        // onto it.
        $path = (string)($cart['path'] ?? '');
        if (empty($cart['present'])) {
            $rows[] = self::row('cart', 'Order form', self::WARN,
                'Not uploaded. The client area can go live without it, and orders keep using '
                . self::named((string)($f['live']['orderform'] ?? ''), 'the current order form')
                . '. To add it, upload the "hadrian_cart" folder into templates/orderforms/.', $path);
        } elseif (!empty($cart['missing'])) {
            $rows[] = self::row('cart', 'Order form', self::FAIL,
                'Some files did not arrive: ' . self::listOf($cart['missing']) . '. Upload the "hadrian_cart" folder again.', $path);
        } else {
            $rows[] = self::row('cart', 'Order form', self::OK, 'Uploaded', $path);
        }

        // License check
        $path = (string)($hook['path'] ?? '');
        $rows[] = empty($hook['present'])
            ? self::row('hook', 'License check', self::FAIL,
                'Not uploaded. Upload hostnodes_theme_license.php from the release into includes/hooks/.', $path)
            : self::row('hook', 'License check', self::OK, 'Uploaded', $path);

        // One release everywhere. An update uploaded over an older version and
        // cut off half way leaves, say, a new theme beside an old addon; each
        // folder looks complete on its own, so only the marks give it away.
        // No marks at all means a source checkout, which has no release.
        $marks = array_filter($f['release'] ?? [], static fn($v): bool => $v !== null);
        if (array_filter($marks, static fn($v): bool => $v !== '') !== []) {
            if (count(array_unique($marks)) === 1) {
                $rows[] = self::row('release', 'Release', self::OK, (string)reset($marks));
            } else {
                $names = ['theme' => 'theme', 'cart' => 'order form', 'addon' => 'addon'];
                $parts = [];
                foreach ($marks as $which => $mark) {
                    $parts[] = ($names[$which] ?? (string)$which) . ' ' . ($mark !== '' ? $mark : 'unmarked');
                }
                $rows[] = self::row('release', 'Release', self::FAIL,
                    'These folders are not from the same release: ' . implode(', ', $parts)
                    . '. Upload all of them again from one download.');
            }
        }

        return $rows;
    }

    private static function requirements(array $f): array
    {
        $rows = [];
        $req  = $f['requires'] ?? [];

        $php  = (string)($f['php'] ?? '');
        $need = (string)($req['php'] ?? '');
        if ($need !== '') {
            $rows[] = self::meets($php, $need)
                ? self::row('php', 'PHP', self::OK, $php . ' (needs ' . self::plain($need) . ')')
                : self::row('php', 'PHP', self::FAIL,
                    'This server runs PHP ' . $php . '. Hadrian needs ' . self::plain($need) . '. Switch the PHP version in your hosting panel.');
        }

        $whmcs = (string)($f['whmcs'] ?? '');
        $need  = (string)($req['whmcs'] ?? '');
        if ($need !== '') {
            if ($whmcs === '') {
                $rows[] = self::row('whmcs', 'WHMCS', self::WARN,
                    'The WHMCS version could not be read. Hadrian needs ' . self::plain($need) . '.');
            } else {
                $rows[] = self::meets($whmcs, $need)
                    ? self::row('whmcs', 'WHMCS', self::OK, $whmcs . ' (needs ' . self::plain($need) . ')')
                    : self::row('whmcs', 'WHMCS', self::FAIL,
                        'This is WHMCS ' . $whmcs . '. Hadrian needs ' . self::plain($need) . '. Update WHMCS first.');
            }
        }

        $missing = [];
        $loaded  = [];
        foreach (($f['extensions'] ?? []) as $name => $on) {
            if ($on) {
                $loaded[] = (string)$name;
            } else {
                $missing[] = (string)$name;
            }
        }
        if ($missing !== []) {
            $rows[] = self::row('extensions', 'PHP extensions', self::FAIL,
                'Missing: ' . implode(', ', $missing) . '. Ask your host to enable ' . (count($missing) === 1 ? 'it' : 'them') . '.');
        } elseif ($loaded !== []) {
            $rows[] = self::row('extensions', 'PHP extensions', self::OK, implode(', ', $loaded));
        }

        // Only worth saying once the theme is there to write into.
        if (!empty($f['theme']['present'])) {
            $rows[] = !empty($f['uploads_writable'])
                ? self::row('uploads', 'Upload folder', self::OK, 'Writable', (string)($f['uploads_path'] ?? ''))
                : self::row('uploads', 'Upload folder', self::WARN,
                    'Not writable, so logo and favicon uploads on the Branding page will fail. Give the web server write access to this folder.',
                    (string)($f['uploads_path'] ?? ''));
        }

        return $rows;
    }

    private static function database(array $f): array
    {
        $rows    = [];
        $pending = $f['migrations']['pending'] ?? [];
        $total   = (int)($f['migrations']['total'] ?? 0);

        if (!empty($f['migrations']['error'])) {
            $rows[] = self::row('tables', 'Tables', self::FAIL,
                'The database could not be read: ' . $f['migrations']['error']);
            return $rows;
        }

        if ($pending === []) {
            $rows[] = self::row('tables', 'Tables', self::OK, 'Up to date');
        } elseif (count($pending) === $total) {
            $rows[] = self::row('tables', 'Tables', self::TODO, 'Not created yet.');
        } else {
            $n = count($pending);
            $rows[] = self::row('tables', 'Tables', self::TODO,
                $n . ' update' . ($n === 1 ? ' has' : 's have') . ' not been applied. This happens when new files are uploaded over an older version.');
        }

        $menus = (int)($f['menus'] ?? 0);
        $rows[] = $menus > 0
            ? self::row('menus', 'Default menus', self::OK, $menus . ' menu' . ($menus === 1 ? '' : 's'))
            : self::row('menus', 'Default menus', self::TODO, 'Not created yet.');

        return $rows;
    }

    private static function license(array $f): array
    {
        $status = (string)($f['license']['status'] ?? 'No key');
        $active = !empty($f['license']['active']);

        if ($active) {
            return [self::row('license', 'License key', self::OK, 'Active for this domain.')];
        }

        return [match ($status) {
            'No key' => self::row('license', 'License key', self::TODO,
                'No key entered yet. It is in your order confirmation and in your account.'),
            'Suspended', 'Expired' => self::row('license', 'License key', self::WARN,
                $status . '. The theme keeps running, but updates are paused until you renew.'),
            // 'Error' is a fault on the licence server's side, not a verdict
            // on the key: say "try again", never "this key is not valid".
            'Unreachable', 'Unknown', 'Error' => self::row('license', 'License key', self::WARN,
                'The license server could not be reached just now. Reload this page in a minute to check again.'),
            'Banned', 'Cancelled', 'Revoked' => self::row('license', 'License key', self::FAIL,
                'This license has been revoked. Contact support if you think that is a mistake.'),
            default => self::row('license', 'License key', self::FAIL,
                'This key is not valid for this domain. Check it for typos, or reissue the license from your account if the site has moved.'),
        }];
    }

    private static function goLive(array $f): array
    {
        $theme = (string)($f['slugs']['theme'] ?? '');
        $cart  = (string)($f['slugs']['cart'] ?? '');
        $rows  = [];

        $tpl    = (string)($f['live']['template'] ?? '');
        $rows[] = $tpl === $theme
            ? self::row('live-theme', 'Client area', self::OK, 'Hadrian is the client area theme.')
            : self::row('live-theme', 'Client area', self::TODO,
                'Visitors currently see ' . self::named($tpl, 'another theme') . '.');

        // No row for an order form that is not uploaded: Files already says so.
        if (self::folderComplete($f['cart'] ?? [])) {
            $of     = (string)($f['live']['orderform'] ?? '');
            $rows[] = $of === $cart
                ? self::row('live-cart', 'Order form', self::OK, 'Hadrian Cart is the order form.')
                : self::row('live-cart', 'Order form', self::TODO,
                    'Orders currently use ' . self::named($of, 'another order form') . '.');
        }

        return $rows;
    }

    // ----------------------------------------------------------------- helpers

    /** @return array{key:string,label:string,state:string,detail:string,path:string} */
    private static function row(string $key, string $label, string $state, string $detail, string $path = ''): array
    {
        return ['key' => $key, 'label' => $label, 'state' => $state, 'detail' => $detail, 'path' => $path];
    }

    /** @param list<array{state:string}> $rows */
    private static function worst(array $rows): string
    {
        $worst = self::OK;
        foreach ($rows as $r) {
            if (self::RANK[$r['state']] > self::RANK[$worst]) {
                $worst = $r['state'];
            }
        }
        return $worst;
    }

    private static function folderComplete(array $folder): bool
    {
        return !empty($folder['present']) && empty($folder['missing']);
    }

    /** The first few names, then a count: a dropped FTP session can lose hundreds. */
    private static function listOf(array $names, int $show = 4): string
    {
        $names = array_values(array_map('strval', $names));
        $shown = implode(', ', array_slice($names, 0, $show));
        $rest  = count($names) - $show;
        return $rest > 0 ? $shown . ' and ' . $rest . ' more' : $shown;
    }

    private static function named(string $slug, string $fallback): string
    {
        return $slug !== '' ? '"' . $slug . '"' : $fallback;
    }

    /** ">=8.1" as words: "8.1 or newer". */
    private static function plain(string $constraint): string
    {
        if (!preg_match('/^\s*(>=|<=|>|<|==|=)?\s*(.+?)\s*$/', $constraint, $m)) {
            return $constraint;
        }
        return match ($m[1]) {
            '', '>=' => $m[2] . ' or newer',
            '>'      => 'newer than ' . $m[2],
            '<='     => $m[2] . ' or older',
            '<'      => 'older than ' . $m[2],
            default  => 'exactly ' . $m[2],
        };
    }

    /** "9.0.8-release.1" and "8.3.30-1+ubuntu" compare by their numbers only. */
    private static function numeric(string $version): string
    {
        return preg_match('/^\d+(?:\.\d+)*/', trim($version), $m) ? $m[0] : '0';
    }
}
