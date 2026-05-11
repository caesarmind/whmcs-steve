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

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['layout'])) {
            return $this->saveAction($template, $kind);
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
        ]);
    }

    private function saveAction($template, string $kind): string
    {
        $layout = (string)$_POST['layout'];
        if (in_array($layout, $template->getLayouts($kind), true)) {
            Settings::setValue($template->getName() . '_active_layout_' . $kind, $layout);
        }
        return $this->indexAction();
    }
}
