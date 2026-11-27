<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Template\Template;

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
        // Only a template the list itself offers. The slug becomes part of a
        // file path inside Template, so an arbitrary value must never reach
        // it, and the error must not print server paths back to the browser.
        $slug = (string)($_GET['templateName'] ?? '');
        $all  = Template::getAll();
        if (!isset($all[$slug])) {
            return $this->view('error', ['error' => 'There is no Hadrian template called "' . $slug . '".']);
        }
        $template = $all[$slug];
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
