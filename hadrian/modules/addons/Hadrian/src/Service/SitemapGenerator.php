<?php
declare(strict_types=1);

namespace Hadrian\Service;

use Hadrian\Models\Configuration;
use Hadrian\Models\Page;
use Hadrian\Models\Settings;

/**
 * Generates sitemap.xml + robots.txt and writes them to the WHMCS web root.
 *
 * Mirrors Lagom's RSThemes\Helpers\SitemapGenerator: a DOMDocument sitemap and
 * a robots.txt block, both wrapped in comment markers so any non-theme content
 * already in those files is preserved across regenerations. Adapted to read
 * the hadrian_pages registry (Models\Page) for static pages, and the same
 * WHMCS APIs Lagom uses for dynamic content (product groups, announcements,
 * KB, downloads). Friendly URLs come from WHMCS's own routePath() /
 * getModRewriteFriendlyString() so they respect the install's URL config.
 *
 * Writes are fail-soft: a read-only web root returns an error message rather
 * than throwing, so the admin sees a clear notice instead of a white screen.
 */
final class SitemapGenerator
{
    private const MARK_START = 'hadrian sitemap generator start';
    private const MARK_END   = 'hadrian sitemap generator end';
    private const SETTING    = 'sitemap_settings';

    /** @return array<string,mixed> */
    public static function defaults(): array
    {
        return [
            'enabled'       => true,
            'frequency'     => 'weekly',
            'robots'        => true,
            'productGroups' => true,
            'announcements' => true,
            'knowledgebase' => true,
            'downloads'     => false,
        ];
    }

    /** @return array<string,mixed> */
    public static function config(): array
    {
        $stored = Settings::getValue(self::SETTING, null);
        return is_array($stored) ? array_merge(self::defaults(), $stored) : self::defaults();
    }

    public static function saveConfig(array $cfg): void
    {
        Settings::setValue(self::SETTING, array_merge(self::defaults(), $cfg), 'json');
    }

    /**
     * Build + write sitemap.xml (and robots.txt when enabled) to the web root.
     *
     * @return array{ok:bool, message:string}
     */
    public function write(string $template): array
    {
        if (!defined('ROOTDIR')) {
            return ['ok' => false, 'message' => 'ROOTDIR is not defined; cannot locate the web root.'];
        }
        $cfg = self::config();

        $okXml = @file_put_contents(ROOTDIR . '/sitemap.xml', $this->buildSitemap($template, $cfg)) !== false;

        $okRobots = true;
        if (!empty($cfg['robots'])) {
            $okRobots = @file_put_contents(ROOTDIR . '/robots.txt', $this->buildRobots($template)) !== false;
        }

        if (!$okXml || !$okRobots) {
            return ['ok' => false, 'message' => 'Could not write to the web root (' . ROOTDIR . '). Check file permissions.'];
        }
        return [
            'ok'      => true,
            'message' => 'Wrote sitemap.xml' . (!empty($cfg['robots']) ? ' and robots.txt' : '') . ' to ' . ROOTDIR . '.',
        ];
    }

    /**
     * Build the sitemap XML (no file writes — safe for the admin Preview). Any
     * existing sitemap.xml is reused with the previous hadrian block stripped,
     * so non-theme <url> entries survive.
     */
    public function buildSitemap(string $template, ?array $cfg = null): string
    {
        $cfg  = $cfg ?? self::config();
        $base = rtrim($this->systemUrl(), '/');

        [$xml, $urlset] = $this->openSitemapDoc();

        if (empty($cfg['enabled'])) {
            return (string)$xml->saveXML();
        }

        $freq = (string)($cfg['frequency'] ?? 'weekly');
        $urlset->appendChild($xml->createComment(' ' . self::MARK_START . ' '));

        // Site root always first.
        $urlset->appendChild($this->urlNode($xml, $base . '/', $freq, '1.0'));

        // Static registry pages (indexable, public, published, with a URL).
        foreach (Page::forSitemap($template) as $row) {
            $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$row['url'], '/'), $freq, '0.8'));
        }

        // Dynamic content from WHMCS. Each source is isolated in its own
        // try/catch so an API/schema difference on some install can't abort the
        // whole sitemap (this theme ships to many WHMCS versions).

        // Product groups.
        if (!empty($cfg['productGroups']) && class_exists('\\WHMCS\\Product\\Group')) {
            try {
                foreach (\WHMCS\Product\Group::get() as $group) {
                    $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$group->getRoutePath(), '/'), $freq, '0.6'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: product groups skipped — ' . $e->getMessage());
            }
        }

        // Announcements.
        if (!empty($cfg['announcements']) && class_exists('\\WHMCS\\Announcement\\Announcement') && function_exists('routePath')) {
            try {
                foreach (\WHMCS\Announcement\Announcement::published()->get() as $a) {
                    $path = routePath('announcement-view', $a->id, self::friendly((string)$a->title));
                    $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$path, '/'), $freq, '0.5'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: announcements skipped — ' . $e->getMessage());
            }
        }

        // Knowledge base categories + public articles.
        if (!empty($cfg['knowledgebase']) && function_exists('routePath')) {
            try {
                foreach (\WHMCS\Database\Capsule::table('tblknowledgebasecats')->where('hidden', '')->orWhere('hidden', 0)->get() as $cat) {
                    $path = routePath('knowledgebase-category-view', $cat->id, self::friendly((string)$cat->name));
                    $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$path, '/'), $freq, '0.5'));
                }
                foreach (\WHMCS\Database\Capsule::table('tblknowledgebase')->where('private', '')->orWhere('private', 0)->get() as $art) {
                    $path = routePath('knowledgebase-article-view', $art->id, self::friendly((string)$art->title));
                    $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$path, '/'), $freq, '0.5'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: knowledge base skipped — ' . $e->getMessage());
            }
        }

        // Download categories.
        if (!empty($cfg['downloads']) && function_exists('routePath')) {
            try {
                foreach (\WHMCS\Database\Capsule::table('tbldownloadcats')->where('hidden', '')->orWhere('hidden', 0)->get() as $dc) {
                    $path = routePath('download-by-cat', $dc->id, self::friendly((string)$dc->name));
                    $urlset->appendChild($this->urlNode($xml, $base . '/' . ltrim((string)$path, '/'), $freq, '0.4'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: downloads skipped — ' . $e->getMessage());
            }
        }

        $urlset->appendChild($xml->createComment(' ' . self::MARK_END . ' '));
        return (string)$xml->saveXML();
    }

    /** Build the robots.txt content (preserves any existing non-theme block). */
    public function buildRobots(string $template): string
    {
        $base     = rtrim($this->systemUrl(), '/');
        $existing = '';
        if (defined('ROOTDIR') && file_exists(ROOTDIR . '/robots.txt')) {
            $existing = $this->stripRobotsBlock((string)@file_get_contents(ROOTDIR . '/robots.txt'));
        }

        $block  = '# ' . self::MARK_START . "\n";
        // Only advertise the sitemap when it is actually being generated —
        // with the feature off, buildSitemap() strips the block from
        // sitemap.xml, so pointing crawlers at it sends them to a file we no
        // longer maintain. The Disallow rules below still apply either way.
        if (!empty(self::config()['enabled'])) {
            $block .= 'Sitemap: ' . $base . "/sitemap.xml\n";
        }
        $block .= "User-agent: *\n";
        foreach (Page::all($template) as $row) {
            if (($row['indexing'] ?? '') === 'disallow' && (string)($row['url'] ?? '') !== '') {
                $block .= 'Disallow: /' . ltrim((string)$row['url'], '/') . "\n";
            }
        }
        $block .= '# ' . self::MARK_END . "\n";

        $existing = rtrim($existing);
        return ($existing !== '' ? $existing . "\n\n" : '') . $block;
    }

    // ── internals ───────────────────────────────────────────────────────────

    /**
     * Open a sitemap DOMDocument, reusing the existing file's <urlset> (minus
     * our previous block) so foreign entries are preserved.
     *
     * @return array{0:\DOMDocument,1:\DOMElement}
     */
    private function openSitemapDoc(): array
    {
        if (defined('ROOTDIR') && file_exists(ROOTDIR . '/sitemap.xml')) {
            $existing = $this->stripBlock((string)@file_get_contents(ROOTDIR . '/sitemap.xml'));
            if (trim($existing) !== '') {
                $doc = new \DOMDocument('1.0');
                $doc->formatOutput = true;
                if (@$doc->loadXML($existing)) {
                    $urlset = $doc->getElementsByTagName('urlset')->item(0);
                    if ($urlset instanceof \DOMElement) {
                        return [$doc, $urlset];
                    }
                }
            }
        }

        $doc = new \DOMDocument('1.0');
        $doc->formatOutput = true;
        $doc->encoding = 'UTF-8';
        $urlset = $doc->createElement('urlset');
        $urlset->setAttribute('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9');
        $doc->appendChild($urlset);
        return [$doc, $urlset];
    }

    private function urlNode(\DOMDocument $xml, string $loc, string $freq, string $priority): \DOMElement
    {
        $url = $xml->createElement('url');
        $locEl = $xml->createElement('loc');
        $locEl->appendChild($xml->createTextNode($loc)); // text node escapes & in query strings
        $url->appendChild($locEl);
        $url->appendChild($xml->createElement('changefreq', $freq));
        $url->appendChild($xml->createElement('priority', $priority));
        return $url;
    }

    /** Remove the previous hadrian block (markers + the <url> nodes between). */
    private function stripBlock(string $content): string
    {
        $start = strpos($content, self::MARK_START);
        $end   = strpos($content, self::MARK_END);
        if ($start === false || $end === false || $start > $end) {
            return $content;
        }
        $open  = strrpos(substr($content, 0, $start), '<!--');
        $close = strpos($content, '-->', $end);
        if ($open === false || $close === false) {
            return $content;
        }
        return substr($content, 0, $open) . substr($content, $close + 3);
    }

    private function stripRobotsBlock(string $content): string
    {
        $out = [];
        $in  = false;
        foreach (preg_split('/\r\n|\r|\n/', $content) ?: [] as $line) {
            if (strpos($line, self::MARK_START) !== false) { $in = true; continue; }
            if (strpos($line, self::MARK_END) !== false)   { $in = false; continue; }
            if (!$in) { $out[] = $line; }
        }
        return implode("\n", $out);
    }

    private function systemUrl(): string
    {
        $url = (string)(Configuration::getValue('SystemURL') ?? '');
        if ($url !== '') {
            return $url;
        }
        // Last resort (CLI/misconfig): construct from the current request.
        $https  = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $scheme = (string)($_SERVER['REQUEST_SCHEME'] ?? ($https ? 'https' : 'http'));
        $host   = (string)($_SERVER['HTTP_HOST'] ?? '');
        return $host !== '' ? $scheme . '://' . $host : '';
    }

    private static function friendly(string $s): string
    {
        if (function_exists('getModRewriteFriendlyString')) {
            return (string)getModRewriteFriendlyString($s);
        }
        $s = strtolower(trim($s));
        return trim((string)preg_replace('/[^a-z0-9]+/', '-', $s), '-');
    }
}
