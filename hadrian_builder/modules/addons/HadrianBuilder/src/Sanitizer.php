<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Allow-list sanitiser for the rich-text fields of a section.
 *
 * The editor's rich field is a contenteditable, so what it posts is whatever
 * the browser (or a paste from Word) produced. Only a short list of text tags
 * survives, and every attribute is dropped except an anchor's href. Styling
 * comes from the theme, so nothing an admin pastes can restyle the page or
 * carry a script.
 *
 * The result is always handed to a template as a VALUE. It is never compiled
 * as template source, so braces in it are plain characters.
 */
final class Sanitizer
{
    private const ALLOWED = [
        'p', 'br', 'strong', 'b', 'em', 'i', 'u', 's', 'a',
        'ul', 'ol', 'li', 'h3', 'h4', 'small', 'blockquote', 'code',
    ];

    /** Block-level tags that are unwrapped but should leave a paragraph behind. */
    private const AS_PARAGRAPH = ['div', 'section', 'article', 'h1', 'h2', 'h5', 'h6', 'pre', 'td', 'th'];

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
            '<?xml encoding="utf-8" ?><div id="hb-root">' . $html . '</div>',
            LIBXML_NOERROR | LIBXML_NOWARNING | LIBXML_HTML_NODEFDTD
        );
        libxml_clear_errors();
        libxml_use_internal_errors($prev);

        $root = null;
        foreach ($dom->getElementsByTagName('div') as $div) {
            if ($div instanceof \DOMElement && $div->getAttribute('id') === 'hb-root') {
                $root = $div;
                break;
            }
        }
        if ($root === null) {
            return '';
        }

        $out = self::children($root);
        // Loose text at the top level (a field typed without pressing Enter)
        // becomes a paragraph so the theme has something to style.
        if (!preg_match('/^\s*<(p|ul|ol|h3|h4|blockquote)\b/i', $out)) {
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
            $href = Text::link($node->getAttribute('href'));
            if ($href === '') {
                return $inner;
            }
            $external = (bool)preg_match('/^https?:\/\//i', $href);
            return '<a href="' . htmlspecialchars($href, ENT_QUOTES, 'UTF-8') . '"'
                . ($external ? ' rel="noopener"' : '') . '>' . $inner . '</a>';
        }
        // Normalise the two spellings so the theme styles one of each.
        $tag = ['b' => 'strong', 'i' => 'em'][$tag] ?? $tag;
        return '<' . $tag . '>' . $inner . '</' . $tag . '>';
    }
}
