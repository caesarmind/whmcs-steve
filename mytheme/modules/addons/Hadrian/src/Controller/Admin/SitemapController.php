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
 *   preview  → render the sitemap XML inline (no file write)
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
        SitemapGenerator::saveConfig([
            'enabled'       => isset($_POST['enabled']),
            'robots'        => isset($_POST['robots']),
            'productGroups' => isset($_POST['productGroups']),
            'announcements' => isset($_POST['announcements']),
            'knowledgebase' => isset($_POST['knowledgebase']),
            'downloads'     => isset($_POST['downloads']),
            'frequency'     => in_array((string)($_POST['frequency'] ?? 'weekly'), self::FREQUENCIES, true)
                ? (string)$_POST['frequency'] : 'weekly',
        ]);
        // Saving also regenerates the files (mirrors Lagom's save behaviour).
        return $this->generateAction();
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

    public function previewAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->renderForm();
        }
        try {
            $xml = (new SitemapGenerator())->buildSitemap($template->getName());
        } catch (\Throwable $e) {
            return $this->renderForm(['flashErr' => 'Preview failed: ' . $e->getMessage()]);
        }
        return $this->renderForm(['previewXml' => $xml]);
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
            'previewXml'    => '',
            'flashMsg'      => (string)($_GET['flash'] ?? ''),
            'flashErr'      => (string)($_GET['err'] ?? ''),
        ], $extra));
    }
}
