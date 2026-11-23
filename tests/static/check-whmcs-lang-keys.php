<?php
/**
 * Every WHMCS language key the templates print exists in WHMCS's own
 * lang/english.php - as the shape the template asks for.
 *
 *   php tests/static/check-whmcs-lang-keys.php
 *
 * Three ways a $LANG reference prints the wrong thing, all with HTTP 200 and
 * nothing in any log:
 *   - a key that does not exist prints NOTHING. The markdown guide asked for
 *     $LANG['markdown.bold'] - a flat key - while WHMCS stores
 *     $_LANG['markdown']['bold'], so all 27 of its strings were blank.
 *   - an ARRAY used as text prints "Array" ($LANG.billing is a group).
 *   - {lang key='a.b'} with no such key prints the key itself.
 * A reference with a |default:... is allowed to miss: the default is the text.
 *
 * Needs a WHMCS install for the language file (WHMCS_ROOT, default the local
 * stack). Without one it says so and passes, like a skipped check.
 */

declare(strict_types=1);

$repo = dirname(__DIR__, 2);
$whmcs = getenv('WHMCS_ROOT') ?: 'C:/laragon/www/whmcs';
$langFile = $whmcs . '/lang/english.php';
if (!is_file($langFile)) {
    echo "skipped: no WHMCS language file at $langFile (set WHMCS_ROOT)\n";
    exit(0);
}
$_LANG = [];
define('WHMCS', true);                 // the lang file refuses direct access without it
include $langFile;
$LANG = $_LANG;

/** Resolve a dotted path against the nested array. [found, value] */
$resolve = function (array $parts) use ($LANG): array {
    $v = $LANG;
    foreach ($parts as $p) {
        if (!is_array($v) || !array_key_exists($p, $v)) return [false, null];
        $v = $v[$p];
    }
    return [true, $v];
};

$files = [];
foreach (['hadrian/templates/hadrian', 'hadrian_cart'] as $root) {
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($repo . '/' . $root, FilesystemIterator::SKIP_DOTS));
    foreach ($it as $f) {
        $p = str_replace('\\', '/', $f->getPathname());
        if (str_ends_with($p, '.tpl') && !str_contains($p, '/_archive/') && !preg_match('~/(invoice|quote)pdf\.tpl$~', $p)) $files[] = $p;
    }
}

$problems = [];
$checked = 0;
foreach ($files as $file) {
    $src = (string) file_get_contents($file);
    // Comments and {literal} blocks carry no live references.
    $src = preg_replace_callback('~\{\*.*?\*\}|\{literal\}.*?\{/literal\}~s', fn($m) => preg_replace('~[^\n]~', ' ', $m[0]), $src);
    $rel = substr($file, strlen($repo) + 1);

    // {$LANG.a.b|...}  and  {$LANG['a.b']|...} / {$LANG["a"]["b"]}
    preg_match_all('~\$LANG((?:\.[A-Za-z_][A-Za-z0-9_]*|\[\s*[\'"][^\'"]+[\'"]\s*\])+)([^}]*)~', $src, $mm, PREG_SET_ORDER | PREG_OFFSET_CAPTURE);
    foreach ($mm as $m) {
        $chain = $m[1][0];
        $rest = $m[2][0];
        $line = substr_count(substr($src, 0, $m[0][1]), "\n") + 1;
        preg_match_all('~\.([A-Za-z_][A-Za-z0-9_]*)|\[\s*[\'"]([^\'"]+)[\'"]\s*\]~', $chain, $pp, PREG_SET_ORDER);
        $parts = array_map(fn($p) => $p[1] !== '' ? $p[1] : $p[2], $pp);
        $hasDefault = (bool) preg_match('~\|\s*default\s*:~', $rest);
        // Used as a value to test or pass on, not printed: {if $LANG.x}, isset(), |@count...
        $before = substr($src, max(0, $m[0][1] - 12), 12);
        $notPrinted = (bool) preg_match('~(isset\(|empty\(|\{if |\{elseif |&& |\|\| |== |!= |=)\s*$~', $before) || preg_match('~^\s*(\||\)|\s(eq|ne|==|!=)\s)~', $rest) && !$hasDefault;
        $checked++;
        [$found, $value] = $resolve($parts);
        $flat = implode('.', $parts);
        if (!$found && count($parts) === 1 && str_contains($parts[0], '.')) {
            [$foundNested] = $resolve(explode('.', $parts[0]));
            if ($foundNested) {
                $problems[] = "$rel:$line  \$LANG['{$parts[0]}'] is a flat key; WHMCS nests it - write \$LANG." . $parts[0];
                continue;
            }
        }
        if (!$found) {
            if (!$hasDefault && !$notPrinted) $problems[] = "$rel:$line  \$LANG.$flat does not exist in WHMCS's english.php (prints nothing) - use a real key or add |default:";
            continue;
        }
        if (is_array($value) && !$notPrinted && !preg_match('~^\s*(\.|\[)~', $rest) && !preg_match('~\|@~', $rest)) {
            $problems[] = "$rel:$line  \$LANG.$flat is a group of " . count($value) . ' strings, not a string (prints "Array")';
        }
    }

    // {lang key='a.b'}
    preg_match_all('~\{lang\s+key\s*=\s*[\'"]([^\'"]+)[\'"]([^}]*)~', $src, $lm, PREG_SET_ORDER | PREG_OFFSET_CAPTURE);
    foreach ($lm as $m) {
        $key = $m[1][0];
        // Built at render time ('a.'|cat:$x, "a.$x") or with its own fallback: not checkable here.
        if (str_contains($key, '$') || str_ends_with($key, '.') || preg_match('~\|cat:|defaultValue\s*=~', $m[2][0])) continue;
        $checked++;
        $line = substr_count(substr($src, 0, $m[0][1]), "\n") + 1;
        [$found] = $resolve(explode('.', $key));
        if (!$found && !array_key_exists($key, $LANG)) $problems[] = "$rel:$line  {lang key='$key'} does not exist in WHMCS's english.php (prints the key)";
    }
}

foreach ($problems as $p) fwrite(STDERR, "FAIL  $p\n");
echo count($problems)
    ? 'FAILED: ' . count($problems) . " of $checked WHMCS language references print the wrong thing\n"
    : "ok: all $checked WHMCS language references resolve\n";
exit(count($problems) ? 1 : 0);
