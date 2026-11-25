<?php
declare(strict_types=1);

namespace Hadrian\Service;

use Hadrian\Helpers\ExtensionPages;
use Hadrian\Helpers\FrontDoor;
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
     * Bring the files up to date after something they list has changed: a
     * page saved in Pages, a module's page published or removed, an
     * announcement added, the daily cron.
     *
     * It only maintains files this site already keeps: nothing is written
     * until an admin has saved the Sitemap settings or generated the files
     * once. A file is rewritten only when its content would differ, so
     * calling this often costs a few queries and no disk writes. Never
     * throws: the change that triggered it is already saved.
     *
     * @return bool whether a file was rewritten
     */
    public static function refresh(string $template): bool
    {
        if (!defined('ROOTDIR') || $template === '') {
            return false;
        }
        try {
            $self      = new self();
            $cfg       = self::config();
            $sitemap   = ROOTDIR . '/sitemap.xml';
            $robots    = ROOTDIR . '/robots.txt';
            $oldXml    = is_file($sitemap) ? (string)@file_get_contents($sitemap) : '';
            $oldRobots = is_file($robots) ? (string)@file_get_contents($robots) : '';

            $configured = is_array(Settings::getValue(self::SETTING, null));
            $ours       = strpos($oldXml, self::MARK_START) !== false || strpos($oldRobots, self::MARK_START) !== false;
            if (!$configured && !$ours) {
                return false;
            }

            $wrote = false;
            // Switched off: only an old block of ours is left to take out.
            if (!empty($cfg['enabled']) || strpos($oldXml, self::MARK_START) !== false) {
                $xml = $self->buildSitemap($template, $cfg);
                if ($xml !== $oldXml && @file_put_contents($sitemap, $xml) !== false) {
                    $wrote = true;
                }
            }
            if (!empty($cfg['robots'])) {
                $txt = $self->buildRobots($template);
                if ($txt !== $oldRobots && @file_put_contents($robots, $txt) !== false) {
                    $wrote = true;
                }
            }
            return $wrote;
        } catch (\Throwable $e) {
            error_log('Hadrian sitemap: refresh skipped: ' . $e->getMessage());
            return false;
        }
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
        //
        // A module's page that is standing in for a theme page (a built page
        // serving as Announcements) answers at the theme page's address as
        // well as its own, and names the theme page's address as canonical
        // (Hooks::resolveSeoContext). So that address is listed once, the
        // module page's own address is not, and whether it is listed at all
        // follows the module page: its settings are the ones in force there.
        $rows      = Page::forSitemap($template);
        $listed    = [];
        foreach ($rows as $row) {
            $listed[(string)$row['page']] = true;
        }
        $standIn = [];                      // theme page => the module page serving there
        foreach (ExtensionPages::all() as $key => $meta) {
            $replaced = (string)($meta['extension']['replaces'] ?? '');
            if ($replaced !== '') {
                $standIn[$replaced] = (string)$key;
            }
        }
        $add = function (string $page, string $url) use ($xml, $urlset, $base, $freq): void {
            $urlset->appendChild($this->urlNode($xml, self::pageAddress($base, $page, $url), $freq, '0.8'));
        };
        foreach ($rows as $row) {
            $page = (string)$row['page'];
            if (in_array($page, $standIn, true)) {
                continue;                   // its content is listed at the address it serves
            }
            if (isset($standIn[$page]) && !isset($listed[$standIn[$page]])) {
                continue;                   // what answers here is not for search engines
            }
            $add($page, (string)$row['url']);
        }
        // A theme page that would not be listed itself, with an indexable
        // module page serving at its address.
        foreach ($standIn as $replaced => $key) {
            if (isset($listed[$key]) && !isset($listed[$replaced])) {
                $url = Page::get($template, $replaced)['url'] ?? null;
                if (is_string($url) && $url !== '') {
                    $add((string)$replaced, $url);
                }
            }
        }

        // Dynamic content from WHMCS. Each source is isolated in its own
        // try/catch so an API/schema difference on some install can't abort the
        // whole sitemap (this theme ships to many WHMCS versions).

        // Product groups. A hidden group is one the store does not list: it
        // is reached by direct link only, so it is not advertised here.
        if (!empty($cfg['productGroups']) && class_exists('\\WHMCS\\Product\\Group')) {
            try {
                foreach (\WHMCS\Product\Group::where('hidden', 0)->get() as $group) {
                    $urlset->appendChild($this->urlNode($xml, self::fromRoute($base, (string)$group->getRoutePath()), $freq, '0.6'));
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
                    $urlset->appendChild($this->urlNode($xml, self::fromRoute($base, (string)$path), $freq, '0.5'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: announcements skipped — ' . $e->getMessage());
            }
        }

        // Knowledge base categories + public articles.
        if (!empty($cfg['knowledgebase']) && function_exists('routePath')) {
            try {
                // WHMCS keeps a category's and an article's translations as
                // rows of their own (catid / parentid = the original). They
                // are the same page in another language, not pages with an
                // address, so only the original is listed.
                $cats = \WHMCS\Database\Capsule::table('tblknowledgebasecats')
                    ->where(self::flagOff('hidden'))
                    ->where(static function ($q) { $q->where('catid', 0)->orWhereNull('catid'); })
                    ->get();
                foreach ($cats as $cat) {
                    $path = routePath('knowledgebase-category-view', $cat->id, self::friendly((string)$cat->name));
                    $urlset->appendChild($this->urlNode($xml, self::fromRoute($base, (string)$path), $freq, '0.5'));
                }
                $articles = \WHMCS\Database\Capsule::table('tblknowledgebase')
                    ->where(self::flagOff('private'))
                    ->where(static function ($q) { $q->where('parentid', 0)->orWhereNull('parentid'); })
                    ->get();
                foreach ($articles as $art) {
                    $path = routePath('knowledgebase-article-view', $art->id, self::friendly((string)$art->title));
                    $urlset->appendChild($this->urlNode($xml, self::fromRoute($base, (string)$path), $freq, '0.5'));
                }
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap: knowledge base skipped — ' . $e->getMessage());
            }
        }

        // Download categories.
        if (!empty($cfg['downloads']) && function_exists('routePath')) {
            try {
                foreach (\WHMCS\Database\Capsule::table('tbldownloadcats')->where(self::flagOff('hidden'))->get() as $dc) {
                    $path = routePath('download-by-cat', $dc->id, self::friendly((string)$dc->name));
                    $urlset->appendChild($this->urlNode($xml, self::fromRoute($base, (string)$path), $freq, '0.4'));
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
                // Announcements and the knowledgebase are served at a routed
                // address; the script named above only redirects to it. The
                // rule for the routed address ends in "$" (RFC 9309: match
                // the end of the address), because a Disallow is a prefix:
                // without it, "Disallow: /announcements" would also shut out
                // every single announcement, which is a different page with
                // its own setting.
                $routed = FrontDoor::isScript((string)$row['page'], (string)$row['url']) ? FrontDoor::path((string)$row['page']) : null;
                if ($routed !== null) {
                    $block .= 'Disallow: /' . ltrim($routed, '/') . "$\n";
                }
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

    /**
     * The address a registry page is served at. The registry stores a path
     * from the WHMCS root. For Announcements and the knowledgebase that is a
     * script which only redirects (Helpers\FrontDoor), so the routed address
     * is listed in its place.
     */
    public static function pageAddress(string $base, string $page, string $url): string
    {
        if (FrontDoor::isScript($page, $url)) {
            $routed = FrontDoor::path($page);
            if ($routed !== null) {
                return self::fromRoute($base, $routed);
            }
        }
        return rtrim($base, '/') . '/' . ltrim($url, '/');
    }

    /**
     * A WHMCS route path as a full address. routePath() answers from the
     * domain root, so on an install in a folder it already starts with that
     * folder, and so does the System URL: joining the two as they are would
     * name the folder twice (https://example.com/billing/billing/store/...).
     */
    public static function fromRoute(string $base, string $path): string
    {
        if (preg_match('~^https?://~i', $path)) {
            return $path;
        }
        $base   = rtrim($base, '/');
        $folder = rtrim((string)(parse_url($base, PHP_URL_PATH) ?? ''), '/');
        $path   = '/' . ltrim($path, '/');
        if ($folder !== '' && ($path === $folder || str_starts_with($path, $folder . '/') || str_starts_with($path, $folder . '?'))) {
            $path = substr($path, strlen($folder));
        }
        return $base . '/' . ltrim($path, '/');
    }

    /**
     * A WHMCS on/off column that is off. Some of these are text columns
     * holding 'on' or '' and some are tinyint, so both spellings of "off" are
     * accepted, and both are compared as STRINGS: `private = 0` asks MySQL to
     * read the text as a number, 'on' reads as 0, and every private article
     * and hidden category would match.
     */
    private static function flagOff(string $column): \Closure
    {
        return static function ($q) use ($column): void {
            $q->where($column, '')->orWhere($column, '0');
        };
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
