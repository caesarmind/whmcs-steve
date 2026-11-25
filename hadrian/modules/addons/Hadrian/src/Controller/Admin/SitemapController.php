<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Models\Page;
use Hadrian\Service\SitemapGenerator;

/**
 * Admin: sitemap.xml + robots.txt generator.
 *
 * Routing — MainController::sitemapAction reads ?sub= and dispatches:
 *   index    → settings form + generate/preview controls
 *   save     → persist settings, then regenerate (Lagom parity)
 *   generate → write sitemap.xml (+ robots.txt) to the web root
 *   preview  → the sitemap XML itself, for a new tab (no file write)
 */
final class SitemapController extends AbstractController
{
    /** @var list<string> */
    private const FREQUENCIES = ['always', 'hourly', 'daily', 'weekly', 'monthly', 'yearly', 'never'];

    public function indexAction(): string
    {
        return $this->renderForm();
    }

    public function saveAction(): string
    {
        SitemapGenerator::saveConfig($this->postedConfig());
        // Saving also regenerates the files (mirrors Lagom's save behaviour).
        return $this->generateAction();
    }

    /**
     * The settings as the form posts them: a toggle that is off is absent.
     *
     * @return array<string,mixed>
     */
    private function postedConfig(): array
    {
        return [
            'enabled'       => isset($_POST['enabled']),
            'robots'        => isset($_POST['robots']),
            'productGroups' => isset($_POST['productGroups']),
            'announcements' => isset($_POST['announcements']),
            'knowledgebase' => isset($_POST['knowledgebase']),
            'downloads'     => isset($_POST['downloads']),
            'frequency'     => in_array((string)($_POST['frequency'] ?? 'weekly'), self::FREQUENCIES, true)
                ? (string)$_POST['frequency'] : 'weekly',
        ];
    }

    public function generateAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            $this->redirect('?module=Hadrian&action=sitemap&err=' . rawurlencode('No active template.'));
        }
        try {
            $res = (new SitemapGenerator())->write($template->getName());
        } catch (\Throwable $e) {
            $this->redirect('?module=Hadrian&action=sitemap&err=' . rawurlencode('Generation failed: ' . $e->getMessage()));
        }
        $key = $res['ok'] ? 'flash' : 'err';
        $this->redirect('?module=Hadrian&action=sitemap&' . $key . '=' . rawurlencode($res['message']));
    }

    /**
     * The sitemap as it would be written, as the XML document itself, for a
     * browser tab of its own. Nothing is written or saved.
     *
     * The Preview button posts the settings form here, so the preview shows
     * the toggles as they are on screen, saved or not. A plain GET (a
     * bookmarked or typed address) previews the saved settings.
     */
    public function previewAction(): never
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            $this->raw('No active template.', 'text/plain', 409);
        }
        $cfg = ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST'
            ? array_merge(SitemapGenerator::defaults(), $this->postedConfig())
            : null;
        try {
            $xml = (new SitemapGenerator())->buildSitemap($template->getName(), $cfg);
        } catch (\Throwable $e) {
            $this->raw('The preview could not be built: ' . $e->getMessage(), 'text/plain', 500);
        }
        $this->raw($xml, 'application/xml', 200);
    }

    /** Answer with a document of our own instead of an admin page. */
    private function raw(string $body, string $type, int $code): never
    {
        while (ob_get_level() > 0) {
            @ob_end_clean();
        }
        if (!headers_sent()) {
            http_response_code($code);
            header('Content-Type: ' . $type . '; charset=utf-8');
            header('X-Content-Type-Options: nosniff');
            header('Cache-Control: no-store');
            header('X-Robots-Tag: noindex');
        }
        echo $body;
        exit;
    }

    /** @param array<string,mixed> $extra */
    private function renderForm(array $extra = []): string
    {
        $cfg      = SitemapGenerator::config();
        $template = AddonHelper::getTemplate();
        if ($template !== null) {
            // Self-heal: ensure the hadrian_pages table exists + is seeded, so the
            // sitemap works even if this is the admin's first Hadrian tab visit.
            try {
                (new \Hadrian\Database\Migrator(dirname(__DIR__, 3)))->migrate();
                \Hadrian\Service\PageRegistry::sync($template);
            } catch (\Throwable $e) {
                error_log('Hadrian sitemap self-heal failed: ' . $e->getMessage());
            }
        }
        $pageCount = $template !== null ? count(Page::forSitemap($template->getName())) : 0;

        $rootWritable  = defined('ROOTDIR') && is_writable(ROOTDIR);
        $lastGenerated = '';
        if (defined('ROOTDIR') && file_exists(ROOTDIR . '/sitemap.xml')) {
            $mtime = filemtime(ROOTDIR . '/sitemap.xml');
            $lastGenerated = $mtime ? date('Y-m-d H:i', $mtime) : '';
        }

        return $this->view('sitemap/index', array_merge([
            'cfg'           => $cfg,
            'frequencies'   => self::FREQUENCIES,
            'pageCount'     => $pageCount,
            'rootWritable'  => $rootWritable,
            'lastGenerated' => $lastGenerated,
            'flashMsg'      => (string)($_GET['flash'] ?? ''),
            'flashErr'      => (string)($_GET['err'] ?? ''),
        ], $extra));
    }
}
