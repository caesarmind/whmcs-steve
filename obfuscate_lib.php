<?php
/**
 * Helper functions for obfuscate.php
 */

function rand_ident(int $len = 10): string {
    $first = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $rest  = $first . '0123456789_';
    $out   = $first[random_int(0, strlen($first) - 1)];
    for ($i = 1; $i < $len; $i++) {
        $out .= $rest[random_int(0, strlen($rest) - 1)];
    }
    return $out;
}

function hex_encode_string(string $s): string {
    $out = '"';
    for ($i = 0, $n = strlen($s); $i < $n; $i++) {
        $out .= sprintf('\x%02x', ord($s[$i]));
    }
    return $out . '"';
}

function scramble_int(int $n): string {
    if ($n < 0) return (string)$n;
    $mask = random_int(1, 0xFFFF);
    $a    = $n ^ $mask;
    return "({$a}^{$mask})";
}

function decode_encapsed(string $literal): string {
    $q = $literal[0];
    $inner = substr($literal, 1, -1);
    if ($q === '"') {
        return stripcslashes($inner);
    }
    return str_replace(["\\\\", "\\'"], ["\\", "'"], $inner);
}

function shuffle_array(array &$arr): void {
    for ($i = count($arr) - 1; $i > 0; $i--) {
        $j = random_int(0, $i);
        [$arr[$i], $arr[$j]] = [$arr[$j], $arr[$i]];
    }
}

/**
 * Look backwards from $i past whitespace/comments for the previous
 * meaningful token. Return its index, or -1.
 */
function prev_meaningful_token(array $tokens, int $i): int {
    for ($j = $i - 1; $j >= 0; $j--) {
        $t = $tokens[$j];
        if (is_array($t) && ($t[0] === T_WHITESPACE || $t[0] === T_COMMENT || $t[0] === T_DOC_COMMENT)) {
            continue;
        }
        return $j;
    }
    return -1;
}

function prev_is_arrow(array $tokens, int $i): bool {
    $j = prev_meaningful_token($tokens, $i);
    if ($j < 0) return false;
    $t = $tokens[$j];
    if (is_array($t)) {
        return $t[0] === T_OBJECT_OPERATOR
            || (defined('T_NULLSAFE_OBJECT_OPERATOR') && $t[0] === T_NULLSAFE_OBJECT_OPERATOR)
            || $t[0] === T_DOUBLE_COLON;
    }
    return false;
}

function prev_is_function_kw(array $tokens, int $i): bool {
    $j = prev_meaningful_token($tokens, $i);
    if ($j < 0) return false;
    $t = $tokens[$j];
    return is_array($t) && $t[0] === T_FUNCTION;
}

function prev_is_visibility(array $tokens, int $i): bool {
    // Walk back past whitespace, modifiers, and type hints to reach
    // the visibility keyword. Typed properties look like:
    //   protected ?Foo\Bar $name;
    //   private static readonly int $count;
    $skipArr = [T_WHITESPACE, T_COMMENT, T_DOC_COMMENT, T_STATIC,
        T_STRING, T_ARRAY, T_NS_SEPARATOR];
    if (defined('T_NAME_QUALIFIED'))       $skipArr[] = T_NAME_QUALIFIED;
    if (defined('T_NAME_FULLY_QUALIFIED')) $skipArr[] = T_NAME_FULLY_QUALIFIED;
    if (defined('T_READONLY'))             $skipArr[] = T_READONLY;
    if (defined('T_CALLABLE'))             $skipArr[] = T_CALLABLE;

    for ($j = $i - 1; $j >= 0; $j--) {
        $t = $tokens[$j];
        if (is_array($t)) {
            if (in_array($t[0], $skipArr, true)) continue;
            if (in_array($t[0], [T_PRIVATE, T_PROTECTED, T_PUBLIC], true)) return true;
            return false;
        }
        // Single-char tokens: ? and | are parts of nullable/union types.
        if ($t === '?' || $t === '|' || $t === '&') continue;
        return false;
    }
    return false;
}

/**
 * Walk tokens and return map of [original_name => random_name] for
 * methods and properties declared as `private`. We also pick up
 * `protected` so inherited calls within the obfuscated file still resolve.
 */
function discover_private_members(array $tokens): array {
    $map = [];
    $n = count($tokens);
    for ($i = 0; $i < $n; $i++) {
        $t = $tokens[$i];
        if (!is_array($t)) continue;

        // Only start collecting inside a class/trait/interface body.
        if ($t[0] !== T_PRIVATE && $t[0] !== T_PROTECTED) continue;

        // Look ahead for `function NAME` or `$NAME`.
        for ($j = $i + 1; $j < $n; $j++) {
            $u = $tokens[$j];
            if (is_array($u)) {
                if (in_array($u[0], [T_WHITESPACE, T_COMMENT, T_DOC_COMMENT,
                    T_STATIC, T_FINAL, T_ABSTRACT], true)) continue;
                if (defined('T_READONLY') && $u[0] === T_READONLY) continue;

                if ($u[0] === T_FUNCTION) {
                    // skip to the identifier after `function`
                    for ($k = $j + 1; $k < $n; $k++) {
                        $v = $tokens[$k];
                        if (is_array($v) && $v[0] === T_WHITESPACE) continue;
                        if (is_array($v) && $v[0] === T_STRING) {
                            $name = $v[1];
                            if ($name !== '__construct' && $name !== '__destruct'
                                && strpos($name, '__') !== 0) {
                                $map[$name] ??= rand_ident(8);
                            }
                        }
                        break;
                    }
                    break;
                }
                if ($u[0] === T_VARIABLE) {
                    $bare = substr($u[1], 1);
                    $map[$bare] ??= rand_ident(8);
                    break;
                }
                // Type hint like ?int, string, ClassName — keep scanning.
                if ($u[0] === T_STRING || $u[0] === T_ARRAY
                    || (defined('T_NAME_QUALIFIED') && $u[0] === T_NAME_QUALIFIED)
                    || (defined('T_NAME_FULLY_QUALIFIED') && $u[0] === T_NAME_FULLY_QUALIFIED)) {
                    continue;
                }
                break;
            } else {
                if ($u === '?' || $u === '&') continue;
                break;
            }
        }
    }
    return $map;
}

/**
 * Insert $preamble after the opening tag + any leading declare/namespace/use
 * statements. This avoids breaking strict_types declarations, which must be
 * the first statement in the file.
 */
function splice_preamble(string $source, string $preamble): string {
    // Find end of "<?php", then walk forward swallowing declare(...);,
    // namespace X;, use ...; statements. Stop at anything else.
    if (!preg_match('/<\?php\b/', $source, $m, PREG_OFFSET_CAPTURE)) {
        return "<?php\n{$preamble}\n" . ltrim($source);
    }
    $cursor = $m[0][1] + strlen($m[0][0]);
    $len = strlen($source);

    while ($cursor < $len) {
        // Skip whitespace.
        while ($cursor < $len && ctype_space($source[$cursor])) $cursor++;
        if ($cursor >= $len) break;

        $rest = substr($source, $cursor);
        if (preg_match('/^(declare\s*\([^)]*\)\s*;)/', $rest, $mm)
         || preg_match('/^(namespace\s+[^;{]+[;{])/', $rest, $mm)
         || preg_match('/^(use\s+[^;]+;)/', $rest, $mm)) {
            $cursor += strlen($mm[1]);
            // If a namespace { block was opened, the preamble must go
            // INSIDE it — stop here so it lands after the `{`.
            if (substr($mm[1], -1) === '{') break;
            continue;
        }
        break;
    }
    return substr($source, 0, $cursor) . "\n{$preamble}\n" . substr($source, $cursor);
}

/**
 * Build a function `fn(i) { static $t = [ ... ]; return $t[$i]; }` so the
 * string table is reachable from any scope. $entries is numerically
 * indexed in the *final* shuffled order.
 */
function build_string_table(string $fnName, array $entries): string {
    $parts = [];
    foreach ($entries as $idx => $val) {
        $parts[] = $idx . '=>' . hex_encode_string($val);
    }
    $table = '[' . implode(',', $parts) . ']';
    return 'function ' . $fnName . '($i){static $t=' . $table . ';return $t[$i];}';
}
