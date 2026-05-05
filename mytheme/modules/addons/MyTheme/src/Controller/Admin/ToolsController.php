<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Models\Settings;

final class ToolsController extends AbstractController
{
    public function indexAction(): string
    {
        $message = '';
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $message = $this->runTool((string)($_POST['tool'] ?? ''));
        }

        return $this->view('tools/index', ['message' => $message]);
    }

    private function runTool(string $tool): string
    {
        return match ($tool) {
            'clear_template_cache' => $this->clearTemplateCache(),
            'refresh_menu_cache'   => $this->refreshMenuCache(),
            'refresh_license'      => $this->refreshLicense(),
            'generate_htaccess'    => $this->generateHtaccess(),
            default                => 'Unknown tool',
        };
    }

    private function clearTemplateCache(): string
    {
        $dir = sys_get_temp_dir() . '/mytheme-smarty';
        $count = 0;
        if (is_dir($dir)) {
            foreach (glob($dir . '/*') ?: [] as $file) {
                if (is_file($file) && @unlink($file)) {
                    $count++;
                }
            }
        }
        return "Cleared {$count} compiled templates.";
    }

    private function refreshMenuCache(): string
    {
        // Bump cache key — invalidates Settings::$cache and any reads keyed off it
        Settings::setValue('cache_key', (string)time());
        return 'Menu cache invalidated.';
    }

    private function refreshLicense(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return 'No active template — cannot refresh license.';
        }
        if ($template->license()->isDevMode()) {
            return 'Development mode active — license refresh is a no-op.';
        }
        $template->license()->refreshNow();
        return 'License refreshed from server.';
    }

    private function generateHtaccess(): string
    {
        // TODO: write SEO-friendly redirect rules to <ROOTDIR>/.htaccess
        return 'htaccess generation: not yet implemented.';
    }
}
