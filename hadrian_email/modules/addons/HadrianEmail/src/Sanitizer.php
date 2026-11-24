<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Allow-list sanitiser for the rich-text fields of an email block.
 *
 * The builder's editor is a contenteditable, so what it posts is whatever the
 * browser (or a paste from Word) produced. Only the handful of tags an email
 * can render reliably survive; every attribute is dropped except an anchor's
 * href. The renderer adds the inline styles afterwards, so nothing the admin
 * pastes can restyle the email or carry a script.
 *
 * Smarty tags pass through as text: {$client_name} and {if ...} are just
 * characters to the HTML parser.
 */
final class Sanitizer
{
    private const ALLOWED = [
        'p', 'br', 'strong', 'b', 'em', 'i', 'u', 's', 'a',
        'ul', 'ol', 'li', 'h2', 'h3', 'small', 'blockquote', 'code',
    ];

    /** Block-level tags that are unwrapped but should leave a paragraph behind. */
    private const AS_PARAGRAPH = ['div', 'section', 'article', 'h1', 'h4', 'h5', 'h6', 'pre', 'td', 'th'];

    private const DROP_WITH_CONTENT = ['script', 'style', 'iframe', 'object', 'embed', 'form', 'head', 'title', 'svg', 'math', 'template', 'noscript'];

    public static function rich(string $html, int $maxLength = 20000): string
    {
        $html = trim($html);
        if ($html === '') {
            return '';
        }
        if (strlen($html) > $maxLength * 4) {
            $html = substr($html, 0, $maxLength * 4);
        }
        if (!class_exists(\DOMDocument::class)) {
            // No ext-dom: fall back to the bluntest safe thing.
            return '<p>' . nl2br(htmlspecialchars(strip_tags($html), ENT_QUOTES, 'UTF-8')) . '</p>';
        }

        $dom  = new \DOMDocument('1.0', 'UTF-8');
        $prev = libxml_use_internal_errors(true);
        // The XML declaration is what makes libxml read the fragment as UTF-8
        // instead of ISO-8859-1.
        $dom->loadHTML(
            '<?xml encoding="utf-8" ?><div id="hx-root">' . $html . '</div>',
            LIBXML_NOERROR | LIBXML_NOWARNING | LIBXML_HTML_NODEFDTD
        );
        libxml_clear_errors();
        libxml_use_internal_errors($prev);

        $root = $dom->getElementById('hx-root');
        if ($root === null) {
            foreach ($dom->getElementsByTagName('div') as $div) {
                if ($div instanceof \DOMElement && $div->getAttribute('id') === 'hx-root') {
                    $root = $div;
                    break;
                }
            }
        }
        if ($root === null) {
            return '';
        }

        $out = self::children($root);
        $out = self::unescapeInsideTags($out);
        // Loose text at the top level (a field typed without pressing Enter)
        // becomes a paragraph so the renderer has something to style.
        if (!preg_match('/^\s*<(p|ul|ol|h2|h3|blockquote)\b/i', $out)) {
            $out = '<p>' . $out . '</p>';
        }
        $out = (string)preg_replace('/<p>(?:\s|<br>|&nbsp;)*<\/p>/i', '', $out);
        if (strlen($out) > $maxLength) {
            $out = substr($out, 0, $maxLength);
        }
        return trim($out);
    }

    private static function children(\DOMNode $node): string
    {
        $out = '';
        foreach ($node->childNodes as $child) {
            $out .= self::node($child);
        }
        return $out;
    }

    private static function node(\DOMNode $node): string
    {
        if ($node instanceof \DOMText) {
            return htmlspecialchars($node->nodeValue ?? '', ENT_NOQUOTES, 'UTF-8');
        }
        if (!$node instanceof \DOMElement) {
            return '';
        }
        $tag = strtolower($node->tagName);
        if (in_array($tag, self::DROP_WITH_CONTENT, true)) {
            return '';
        }
        $inner = self::children($node);

        if ($tag === 'br') {
            return '<br>';
        }
        if (in_array($tag, self::AS_PARAGRAPH, true)) {
            return trim($inner) === '' ? '' : '<p>' . $inner . '</p>';
        }
        if (!in_array($tag, self::ALLOWED, true)) {
            return $inner;
        }
        if ($tag === 'a') {
            $href = self::href($node->getAttribute('href'));
            return $href === '' ? $inner : '<a href="' . htmlspecialchars($href, ENT_QUOTES, 'UTF-8') . '">' . $inner . '</a>';
        }
        // Normalise the two spellings so the renderer styles one of each.
        $tag = ['b' => 'strong', 'i' => 'em'][$tag] ?? $tag;
        return '<' . $tag . '>' . $inner . '</' . $tag . '>';
    }

    /** A link an email may carry: web, mail, phone, or a merge field. */
    public static function href(string $href): string
    {
        $href = trim($href);
        if ($href === '' || strlen($href) > 2000) {
            return '';
        }
        if (preg_match('/^\{[\$i]/', $href)) {
            return $href;             // {$invoice_url} or {if ...}{$x}{/if}
        }
        if (preg_match('/^(https?:\/\/|mailto:|tel:)/i', $href)) {
            return $href;
        }
        return '';
    }

    /**
     * htmlspecialchars() above also escaped the inside of Smarty tags, so
     * {if $total > 10} arrived as {if $total &gt; 10} -- which Smarty rejects.
     * Put the operators back, inside tags only.
     */
    private static function unescapeInsideTags(string $html): string
    {
        return (string)preg_replace_callback(
            '/\{(?:\$|\/?(?:if|elseif|foreach|section|assign)\b)[^{}]*\}/',
            static fn(array $m): string => html_entity_decode($m[0], ENT_QUOTES, 'UTF-8'),
            $html
        );
    }
}
