<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;

final class PagesController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        $tab      = (string)($_GET['tab'] ?? 'client-area');

        $pages = [];
        if ($template !== null) {
            foreach ($template->getPages() as $name) {
                $pages[] = [
                    'name'  => $name,
                    'label' => ucwords(str_replace(['-', '_'], ' ', $name)),
                    'seo'   => false,                    // TODO: read from per-page settings
                    'variant' => 'Default',
                ];
            }
        }

        return $this->view('pages/index', ['pages' => $pages, 'tab' => $tab]);
    }

    public function editAction(): string
    {
        $page = (string)($_GET['page'] ?? 'login');
        return $this->view('pages/edit', [
            'page'     => $page,
            'pageLabel'=> ucwords(str_replace(['-', '_'], ' ', $page)),
            'variants' => ['default' => 'Default', 'sidebar-login' => 'Sidebar Login'],
            'activeVariant' => 'default',
        ]);
    }
}
