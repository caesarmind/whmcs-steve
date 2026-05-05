<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Template\Template;

final class TemplatesController extends AbstractController
{
    public function indexAction(): string
    {
        $templates = Template::getAll();
        $rows = [];
        foreach ($templates as $slug => $template) {
            $rows[] = [
                'slug'        => $slug,
                'displayName' => $template->getDisplayName(),
                'version'     => $template->getVersion(),
                'isActive'    => $template->isActive(),
                'canActivate' => $template->canActivate(),
            ];
        }
        return $this->view('templates/index', ['templates' => $rows]);
    }

    public function showAction(): string
    {
        $slug = $_GET['templateName'] ?? '';
        try {
            $template = new Template($slug);
        } catch (\Throwable $e) {
            return $this->view('error', ['error' => $e->getMessage()]);
        }
        return $this->view('templates/show', [
            'template' => [
                'slug'    => $template->getName(),
                'name'    => $template->getDisplayName(),
                'version' => $template->getVersion(),
                'styles'  => $template->getStyles(),
                'layouts' => [
                    'main-menu' => $template->getLayouts('main-menu'),
                    'footer'    => $template->getLayouts('footer'),
                ],
                'pages'   => $template->getPages(),
            ],
        ]);
    }
}
