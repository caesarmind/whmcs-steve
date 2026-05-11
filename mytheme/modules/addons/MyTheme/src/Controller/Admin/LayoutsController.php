<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;

final class LayoutsController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        $kind = $_GET['kind'] ?? 'main-menu';
        if (!in_array($kind, ['main-menu', 'footer'], true)) {
            $kind = 'main-menu';
        }

        // POST = save then redirect (Post-Redirect-Get) so refresh doesn't re-submit
        // and so the user lands on a clean ?action=layouts URL.
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['layout'])) {
            $this->saveAction($template, $kind);
            $this->redirect($this->buildSelfUrl($kind, saved: true));
        }

        $available = $template->getLayouts($kind);
        $current   = Settings::getValue($template->getName() . '_active_layout_' . $kind, 'default');

        $list = [];
        foreach ($available as $name) {
            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . "/core/layouts/{$kind}/{$name}/layout.php"
            );
            $list[] = [
                'name'        => $name,
                'displayName' => $meta['displayName'] ?? ucfirst($name),
                'preview'     => $meta['preview'] ?? 'thumb.png',
                'isActive'    => $name === $current,
            ];
        }

        return $this->view('layouts/index', [
            'layouts'  => $list,
            'kind'     => $kind,
            'template' => $template->getName(),
            'saved'    => isset($_GET['saved']) && $_GET['saved'] === '1',
        ]);
    }

    private function saveAction($template, string $kind): void
    {
        $layout = (string)$_POST['layout'];
        if (in_array($layout, $template->getLayouts($kind), true)) {
            Settings::setValue($template->getName() . '_active_layout_' . $kind, $layout);
        }
    }

    /**
     * Build an absolute URL back to the current admin page.
     * We use absolute paths to avoid relative-URL pitfalls in WHMCS's
     * custom-admin-path setup (e.g. /<random>/addonmodules.php).
     */
    private function buildSelfUrl(string $kind, bool $saved = false): string
    {
        // $_SERVER['PHP_SELF'] resolves to the running script — typically
        // /<custom-admin-path>/addonmodules.php in a WHMCS install.
        $script = (string)($_SERVER['PHP_SELF'] ?? '/admin/addonmodules.php');
        $qs = http_build_query([
            'module' => 'MyTheme',
            'action' => 'layouts',
            'kind'   => $kind,
        ] + ($saved ? ['saved' => '1'] : []));
        return $script . '?' . $qs;
    }
}
