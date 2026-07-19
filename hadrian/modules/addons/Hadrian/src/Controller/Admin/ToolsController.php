<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Menu\Seeder as MenuSeeder;
use Hadrian\Models\Settings;
use Hadrian\Template\PagesCache;

final class ToolsController extends AbstractController
{
    public function indexAction(): string
    {
        $message = '';
        $ok      = true;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            [$ok, $message] = $this->runTool((string)($_POST['tool'] ?? ''));
        }

        return $this->view('tools/index', ['message' => $message, 'messageOk' => $ok]);
    }

    /**
     * Run a tool and report whether it succeeded.
     *
     * Returns [ok, message] rather than a bare string: the view used to render
     * every outcome in a green success alert, so "No active template — cannot
     * rebuild discovery." and "Unknown tool" both read as wins.
     *
     * @return array{0:bool,1:string}
     */
    private function runTool(string $tool): array
    {
        return match ($tool) {
            'clear_template_cache'  => $this->clearTemplateCache(),
            'rebuild_pages_cache'   => $this->rebuildPagesCache(),
            'migrate_menu_pages'    => $this->migrateMenuPages(),
            'refresh_license'       => $this->refreshLicense(),
            default                 => [false, 'Unknown tool.'],
        };
    }

    /** @return array{0:bool,1:string} */
    private function rebuildPagesCache(): array
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return [false, 'No active template — cannot rebuild discovery.'];
        }
        $pages = PagesCache::rebuild($template);
        return [true, 'Pages discovery rebuilt — ' . count($pages) . ' pages found.'];
    }

    /** @return array{0:bool,1:string} */
    private function migrateMenuPages(): array
    {
        $count = (new MenuSeeder())->migrateCustomLinksToWhmcsPages();
        return [true, $count === 0
            ? 'No custom_link items matched a known WHMCS page — nothing to do.'
            : "Converted {$count} custom_link items to whmcs_page."];
    }

    /**
     * Clear the ADDON's compiled templates.
     *
     * Scope is deliberately named in the message: this is the admin addon's own
     * Smarty compile dir (AbstractController / ViewHelper both point there).
     * Client-facing theme templates are compiled by WHMCS's Smarty into its own
     * templates_c/, which this cannot reach — the button used to promise
     * "recompile all Smarty templates", which it never did for the front end.
     *
     * @return array{0:bool,1:string}
     */
    private function clearTemplateCache(): array
    {
        $dir = sys_get_temp_dir() . '/hadrian-smarty';
        $count = 0;
        if (is_dir($dir)) {
            foreach (glob($dir . '/*') ?: [] as $file) {
                if (is_file($file) && @unlink($file)) {
                    $count++;
                }
            }
        }
        return [true, "Cleared {$count} compiled admin templates."];
    }

    /** @return array{0:bool,1:string} */
    private function refreshLicense(): array
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return [false, 'No active template — cannot refresh license.'];
        }
        if ($template->license()->isDevMode()) {
            return [true, 'Development mode active — license refresh is a no-op.'];
        }
        $template->license()->refreshNow();
        return [true, 'License refreshed from server.'];
    }
}
