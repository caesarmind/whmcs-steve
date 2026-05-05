<?php
declare(strict_types=1);

namespace MyTheme\View;

use MyTheme\Controller\AbstractController;

/**
 * URL/asset helpers for admin UI views.
 *
 * URL strategy: build query-string-only URLs (`?module=MyTheme&action=…`).
 * The browser appends them to the current admin URL, so they always stay
 * inside the admin area regardless of WHMCS's customadminpath setting.
 *
 * Asset strategy: use WEB_ROOT + absolute path from the WHMCS install root.
 */
final class ViewHelper
{
    /** Build a same-page URL with query params: ?module=MyTheme&action=… */
    public function url(string $action, array $params = []): string
    {
        $qs = 'module=MyTheme';
        if ($action !== 'index') {
            $qs .= '&action=' . urlencode($action);
        }
        foreach ($params as $k => $v) {
            $qs .= '&' . urlencode($k) . '=' . urlencode((string)$v);
        }
        return '?' . $qs;
    }

    public function script(string $name): string { return $this->assetUrl('js/' . $name); }
    public function style(string $name): string  { return $this->assetUrl('css/' . $name); }
    public function image(string $name): string  { return $this->assetUrl('img/' . $name); }

    private function assetUrl(string $relative): string
    {
        $webRoot = defined('WEB_ROOT') ? rtrim(WEB_ROOT, '/') : '';
        return $webRoot . '/modules/addons/MyTheme/views/adminarea/assets/' . ltrim($relative, '/');
    }

    /** Render an admin-area partial without instantiating a controller. */
    public static function renderAdminPartial(string $template, array $vars = []): string
    {
        $smartyClass = AbstractController::resolveSmartyClass();
        $smarty = new $smartyClass();
        $smarty->setTemplateDir(__DIR__ . '/../../views/adminarea');
        $smarty->setCompileDir(sys_get_temp_dir() . '/mytheme-smarty');
        $smarty->assign($vars);
        return (string)$smarty->fetch($template . '.tpl');
    }
}
