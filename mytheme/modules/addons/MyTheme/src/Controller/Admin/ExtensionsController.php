<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;

final class ExtensionsController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        $extensions = $template?->getExtensions() ?? [];

        return $this->view('extensions/index', ['extensions' => $extensions]);
    }
}
