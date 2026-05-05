<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Template\Template;

final class LicenseController extends AbstractController
{
    public function indexAction(): string
    {
        $template = $this->resolveTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No MyTheme template found']);
        }

        $license = $template->license();
        $devMode = $license->isDevMode();

        // POST handlers — disabled in dev mode (no-ops, since there's no server to call)
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$devMode) {
            if (isset($_POST['license_key'])) {
                $license->setLicenseKey((string)$_POST['license_key']);
                $license->refreshNow();
            } elseif (isset($_POST['refresh'])) {
                $license->refreshNow();
            }
        }

        return $this->view('license/index', [
            'template' => $template->getName(),
            'isActive' => $template->canActivate(),
            'devMode'  => $devMode,
            'key'      => $license->getLicenseKey(),
        ]);
    }

    private function resolveTemplate(): ?Template
    {
        $requested = (string)($_GET['templateName'] ?? '');
        if ($requested !== '') {
            try {
                return new Template($requested);
            } catch (\Throwable) {
                return null;
            }
        }

        $active = AddonHelper::getTemplate();
        if ($active !== null) {
            return $active;
        }

        $templates = Template::getAll();
        return $templates !== [] ? reset($templates) : null;
    }
}
