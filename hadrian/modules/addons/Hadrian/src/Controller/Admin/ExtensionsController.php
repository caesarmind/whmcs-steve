<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;

final class ExtensionsController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        $extensions = $template?->getExtensions() ?? [];

        return $this->view('extensions/index', ['extensions' => $extensions]);
    }
}
