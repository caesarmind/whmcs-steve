<?php
/**
 * PHP obfuscator (no IonCube, no base64).
 *
 * Usage:
 *   php obfuscate.php input.php output.php
 *
 * Passes:
 *   1. Strip comments, collapse whitespace
 *   2. Rename user variables to random identifiers
 *   3. Rename private methods/properties to random identifiers
 *   4. Extract string literals into a single lookup table, reference by index
 *   5. Hex-escape any remaining inline strings
 *   6. Rewrite integer literals as XOR expressions
 *   7. Shuffle the string-table order so indices aren't sequential
 */

if ($argc < 3) {
    fwrite(STDERR, "Usage: php {$argv[0]} <input.php> <output.php>\n");
    exit(1);
}

[$in, $out] = [$argv[1], $argv[2]];
if (!is_readable($in)) { fwrite(STDERR, "Cannot read {$in}\n"); exit(1); }

require __DIR__ . '/obfuscate_lib.php';

$source  = file_get_contents($in);
$tokens  = token_get_all($source);

$SUPERGLOBALS = [
    '$GLOBALS','$_SERVER','$_GET','$_POST','$_FILES','$_COOKIE',
    '$_SESSION','$_REQUEST','$_ENV','$this','$php_errormsg',
    '$http_response_header','$argc','$argv',
];

// --- Pass A: discover variables (skip property declarations) ----------
$varMap = [];
$tokenCountA = count($tokens);
for ($i = 0; $i < $tokenCountA; $i++) {
    $t = $tokens[$i];
    if (!is_array($t) || $t[0] !== T_VARIABLE) continue;
    if (in_array($t[1], $SUPERGLOBALS, true)) continue;
    if (prev_is_visibility($tokens, $i)) continue; // property decl
    $varMap[$t[1]] ??= '$' . rand_ident(8);
}

// --- Pass B: discover private methods + properties ---------------------
$privateMap = discover_private_members($tokens);

// --- Pass C: collect all constant strings into table -------------------
$stringTable = [];               // value => index
$fetchFn = rand_ident(10);       // name of the lookup function
foreach ($tokens as $t) {
    if (is_array($t) && $t[0] === T_CONSTANT_ENCAPSED_STRING) {
        $raw = decode_encapsed($t[1]);
        if (!isset($stringTable[$raw])) {
            $stringTable[$raw] = count($stringTable);
        }
    }
}

// --- Pass D: rebuild source --------------------------------------------
$result = '';
$prevWord = false;
$tokenCount = count($tokens);

for ($i = 0; $i < $tokenCount; $i++) {
    $tok = $tokens[$i];

    if (is_array($tok)) {
        [$id, $text] = [$tok[0], $tok[1]];

        if ($id === T_COMMENT || $id === T_DOC_COMMENT) continue;
        if ($id === T_OPEN_TAG) { $result .= $text; $prevWord = false; continue; }

        if ($id === T_WHITESPACE) {
            if ($prevWord) { $result .= ' '; $prevWord = false; }
            continue;
        }

        // Property declaration: $propName right after visibility modifier.
        // Handle this BEFORE the generic variable-rename so we pick privateMap.
        if ($id === T_VARIABLE && prev_is_visibility($tokens, $i)) {
            $bare = substr($text, 1);
            if (isset($privateMap[$bare])) {
                $text = '$' . $privateMap[$bare];
            }
        }
        // Static property access: self::$foo / static::$foo / Class::$foo
        elseif ($id === T_VARIABLE && prev_is_arrow($tokens, $i)) {
            $bare = substr($text, 1);
            if (isset($privateMap[$bare])) {
                $text = '$' . $privateMap[$bare];
            }
        }
        // Regular variable rename.
        elseif ($id === T_VARIABLE && isset($varMap[$text])) {
            $text = $varMap[$text];
        }

        // Rename private member references: method/property names after ->, ::,
        // and method names right after the `function` keyword.
        if ($id === T_STRING && isset($privateMap[$text])) {
            if (prev_is_arrow($tokens, $i) || prev_is_function_kw($tokens, $i)) {
                $text = $privateMap[$text];
            }
        }

        // String literals -> table lookup (emit placeholder, remap later)
        if ($id === T_CONSTANT_ENCAPSED_STRING) {
            $raw = decode_encapsed($tok[1]);
            $idx = $stringTable[$raw];
            $text = "\x01STR{$idx}\x01";
        }

        // Decimal integers -> XOR form
        if ($id === T_LNUMBER && ctype_digit($text)) {
            $text = scramble_int((int)$text);
        }

        $result .= $text;
        $last = substr($text, -1);
        $prevWord = $last !== '' && (ctype_alnum($last) || $last === '_');
    } else {
        $result .= $tok;
        $prevWord = false;
    }
}

// --- Pass E: emit string table preamble --------------------------------
// Shuffle so indices are scrambled, rewrite references accordingly.
$entries = array_keys($stringTable);                 // index => value
$perm    = range(0, count($entries) - 1);
shuffle_array($perm);
$shuffled = [];
$indexRemap = [];                                    // oldIdx => newIdx
foreach ($perm as $newIdx => $oldIdx) {
    $shuffled[$newIdx] = $entries[$oldIdx];
    $indexRemap[$oldIdx] = $newIdx;
}

// Replace every \x01STR<n>\x01 placeholder with $fetch[(a^b)] using
// the shuffled index.
$result = preg_replace_callback(
    '/\x01STR(\d+)\x01/',
    function ($m) use ($indexRemap, $fetchFn) {
        $newIdx = $indexRemap[(int)$m[1]];
        return $fetchFn . '(' . scramble_int($newIdx) . ')';
    },
    $result
);

$preamble = build_string_table($fetchFn, $shuffled);

// Splice the preamble in after the opening tag AND any leading
// declare(...); / namespace ...; / use ...; statements, since those must
// come before any other code.
$final = splice_preamble($result, $preamble);

file_put_contents($out, $final);

// Syntax check
$check = shell_exec(escapeshellcmd(PHP_BINARY).' -l '.escapeshellarg($out).' 2>&1');
echo trim($check), "\n";
