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
        // Keep this default-by-kind table in sync with Hooks::resolveActiveLayout —
        // otherwise the "Active" badge in admin lies about what the front-end
        // actually renders, and clicking the falsely-active card is a no-op
        // (the radio is already checked, so onchange never fires).
        $defaultByKind = ['main-menu' => 'sidebar', 'footer' => 'extended'];
        $current   = Settings::getValue(
            $template->getName() . '_active_layout_' . $kind,
            $defaultByKind[$kind] ?? 'default'
        );

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
        $accepted = in_array($layout, $template->getLayouts($kind), true);
        // Sentinel write — bumps on every saveAction call, regardless of
        // whether the layout validates. Combined with `_save_last_*`, this
        // is enough to tell from a front-end diagnostic comment whether
        // the click reached PHP at all, what value was POSTed, and whether
        // the manifest accepted it. Strip once the path is trusted again.
        Settings::setValue('mytheme_layout_save_attempts',
            (int)Settings::getValue('mytheme_layout_save_attempts', 0) + 1);
        Settings::setValue('mytheme_layout_save_last_kind', $kind);
        Settings::setValue('mytheme_layout_save_last_value', $layout);
        Settings::setValue('mytheme_layout_save_last_accepted', $accepted ? '1' : '0');
        if ($accepted) {
            Settings::setValue($template->getName() . '_active_layout_' . $kind, $layout);
        }
        // PRG — calling indexAction() directly here would re-enter the
        // POST branch (REQUEST_METHOD is still POST) and recurse until PHP
        // bails out, which WHMCS surfaces as a 404. Redirect instead so
        // the next request is a clean GET.
        $this->redirect('?module=MyTheme&action=layouts&kind=' . urlencode($kind));
    }
}
