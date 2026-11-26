<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Everything that touches a brace.
 *
 * WHMCS compiles the global header, the message body and the global footer as
 * ONE Smarty template (measured on 9.0.8: an {if} opened in the header and
 * closed in the footer hides the body). That has two consequences this class
 * exists for:
 *
 *   - A design published into tblemailtemplates is Smarty source. One stray
 *     brace -- "use {curly} brackets" -- and WHMCS refuses to send that email
 *     at all ("Sending Failed"). protect() turns every brace that is not a
 *     recognised tag into an entity, so only real merge fields reach Smarty.
 *
 *   - The header and footer are delivered as merge-field VALUES, which WHMCS
 *     inserts raw and never evaluates. So {$companyname} in a footer has to be
 *     substituted here. That is done by plain string replacement: no string
 *     from the database or the request is ever compiled as a template.
 */
final class Merge
{
    /**
     * A {literal} block, a comment, or one recognised tag. Order matters: the
     * literal alternative must win so its contents are passed over whole.
     */
    private const TAG = '/\{literal\}.*?\{\/literal\}'
        . '|\{\*.*?\*\}'
        . '|\{\$[A-Za-z_][^{}]*\}'
        . '|\{\/(?:if|foreach|section|capture|strip|nocache)\}'
        . '|\{(?:if|elseif|foreach|section|capture|assign)\s[^{}]*\}'
        . '|\{(?:else|foreachelse|sectionelse|ldelim|rdelim|strip|nocache)\}/s';

    /** A plain merge field: {$name} with optional modifiers, nothing else. */
    private const FIELD = '/\{\$([A-Za-z_][A-Za-z0-9_]*)(?:\|[^{}]*)?\}/';

    /**
     * Pick one language out of a translatable value.
     *
     * A translatable value is either a plain string or a map keyed by WHMCS
     * language name, with "_" holding the default. An empty translation falls
     * back to the default rather than rendering blank.
     */
    public static function pick(mixed $value, string $lang): string
    {
        if (is_string($value)) {
            return $value;
        }
        if (!is_array($value)) {
            return '';
        }
        $v = $value[$lang] ?? '';
        if (is_string($v) && trim($v) !== '') {
            return $v;
        }
        $d = $value['_'] ?? '';
        return is_string($d) ? $d : '';
    }

    /** Entity-escape every brace that is not part of a recognised Smarty tag. */
    public static function protect(string $html): string
    {
        return self::mapOutsideTags($html, static fn(string $s): string => strtr($s, ['{' => '&#123;', '}' => '&#125;']));
    }

    /** htmlspecialchars() for plain text that may carry merge fields. */
    public static function escape(string $text): string
    {
        return self::mapOutsideTags($text, static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8'));
    }

    /** @param callable(string):string $fn */
    private static function mapOutsideTags(string $html, callable $fn): string
    {
        $parts = preg_split(self::TAG, $html, -1, PREG_SPLIT_OFFSET_CAPTURE);
        if ($parts === false) {
            return $fn($html);
        }
        preg_match_all(self::TAG, $html, $tags);
        $out = '';
        foreach ($parts as $i => [$segment]) {
            $out .= $fn($segment) . ($tags[0][$i] ?? '');
        }
        return $out;
    }

    /**
     * Replace merge fields with values.
     *
     * $keepUnknown = true leaves an unmatched {$field} on the page, which is
     * what the preview wants (the admin sees the field they typed). At send
     * time it is false: an unknown field renders empty, as it would in Smarty.
     *
     * @param array<string,mixed> $fields
     */
    public static function substitute(string $html, array $fields, bool $keepUnknown): string
    {
        return (string)preg_replace_callback(self::FIELD, static function (array $m) use ($fields, $keepUnknown): string {
            $name = $m[1];
            if (array_key_exists($name, $fields)) {
                $v = $fields[$name];
                // WHMCS passes amounts as Price objects, not strings.
                if (is_scalar($v) || $v === null || $v instanceof \Stringable) {
                    return (string)$v;
                }
            }
            return $keepUnknown ? htmlspecialchars($m[0], ENT_QUOTES, 'UTF-8') : '';
        }, $html);
    }

    /**
     * Drop Smarty logic, keeping one readable branch: the {if} side of every
     * condition and one pass of every loop. Used where nothing will evaluate
     * the logic -- the preview, and the layout at send time.
     */
    public static function stripLogic(string $html): string
    {
        $html = (string)preg_replace('/\{literal\}(.*?)\{\/literal\}/s', '$1', $html);
        $html = (string)preg_replace('/\{\*.*?\*\}/s', '', $html);
        // Innermost first, repeated, so nested conditions unwind correctly.
        for ($i = 0; $i < 8; $i++) {
            $next = (string)preg_replace(
                '/\{(?:else|elseif\s[^{}]*|foreachelse|sectionelse)\}(?:(?!\{(?:if|foreach|section)\s).)*?(?=\{\/(?:if|foreach|section)\})/s',
                '',
                $html
            );
            if ($next === $html) {
                break;
            }
            $html = $next;
        }
        return (string)preg_replace(
            '/\{\/(?:if|foreach|section|capture|strip|nocache)\}|\{(?:if|elseif|foreach|section|capture|assign)\s[^{}]*\}|\{(?:else|foreachelse|sectionelse|strip|nocache)\}/',
            '',
            $html
        );
    }

    /**
     * Resolve the renderer's own conditional markers.
     *
     *   <!--hx-if:unsubscribe_url-->...<!--/hx-if-->
     *
     * $fields = null turns them into Smarty, for the static fallback that
     * WHMCS evaluates itself; otherwise they are decided here.
     *
     * Markers may nest (a status pill inside the subject title). The innermost
     * ones are resolved first, so each pass only ever sees marker pairs with
     * no other marker between them.
     *
     * @param array<string,mixed>|null $fields
     */
    public static function conditionals(string $html, ?array $fields): string
    {
        return self::innermost($html, static function (string $name, string $inner) use ($fields): string {
            if ($fields === null) {
                return '{if $' . $name . '}' . $inner . '{/if}';
            }
            $v = $fields[$name] ?? '';
            return ((is_scalar($v) || $v instanceof \Stringable) && trim((string)$v) !== '') ? $inner : '';
        });
    }

    /**
     * Replace every marker pair, innermost first, with what $fn returns for it.
     *
     * @param callable(string, string): string $fn  (field name, inner html)
     */
    public static function innermost(string $html, callable $fn): string
    {
        $re = '/<!--hx-if:([a-z_][a-z0-9_]*)-->((?:(?!<!--hx-if:).)*?)<!--\/hx-if-->/s';
        // Our own markup nests two deep at most; the cap only stops a
        // malformed document from looping.
        for ($i = 0; $i < 6 && str_contains($html, '<!--hx-if:'); $i++) {
            $next = (string)preg_replace_callback($re, static fn(array $m): string => $fn($m[1], $m[2]), $html);
            if ($next === $html) {
                break;
            }
            $html = $next;
        }
        return $html;
    }

    /**
     * Drop the markers for the renderer's own per-email values (hx_*), and
     * what they wrap, leaving every other marker in place. For the static
     * fallback, where nothing fills those values.
     */
    public static function dropOwn(string $html): string
    {
        // An hx_ marker never wraps a marker of another kind in our markup,
        // so the innermost-hx_ pattern is enough.
        $re = '/<!--hx-if:hx_[a-z0-9_]*-->((?:(?!<!--hx-if:hx_).)*?)<!--\/hx-if-->/s';
        for ($i = 0; $i < 6 && str_contains($html, '<!--hx-if:hx_'); $i++) {
            $next = (string)preg_replace($re, '', $html);
            if ($next === $html) {
                break;
            }
            $html = $next;
        }
        return $html;
    }

    /**
     * Every problem that would stop WHMCS sending a published body: an
     * unbalanced block tag. Unknown tags never get this far -- protect() has
     * already neutralised them.
     *
     * @return list<string>
     */
    public static function lint(string $html): array
    {
        $errors = [];
        $stack  = [];
        $scan   = (string)preg_replace('/\{literal\}.*?\{\/literal\}|\{\*.*?\*\}/s', '', $html);
        if (substr_count($html, '{literal}') !== substr_count($html, '{/literal}')) {
            $errors[] = 'A {literal} block is not closed.';
        }
        preg_match_all('/\{(\/?)(if|foreach|section|capture|strip|nocache)\b[^{}]*\}/', $scan, $m, PREG_SET_ORDER);
        foreach ($m as $tag) {
            if ($tag[1] === '') {
                $stack[] = $tag[2];
                continue;
            }
            $open = array_pop($stack);
            if ($open !== $tag[2]) {
                $errors[] = $open === null
                    ? 'Found {/' . $tag[2] . '} with nothing to close.'
                    : 'Found {/' . $tag[2] . '} where {/' . $open . '} was expected.';
                return $errors;
            }
        }
        foreach ($stack as $open) {
            $errors[] = 'A {' . $open . '} block is not closed.';
        }
        return $errors;
    }
}
