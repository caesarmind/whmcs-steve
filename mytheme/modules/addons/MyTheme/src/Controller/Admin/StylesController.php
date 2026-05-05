<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;

final class StylesController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['style'])) {
            return $this->saveAction($template);
        }

        $available = $template->getStyles();
        $current   = Settings::getValue($template->getName() . '_active_style', 'default');

        $list = [];
        foreach ($available as $name) {
            $meta = ThemeManifest::loadVariantMeta(
                $template->getFullPath() . "/core/styles/{$name}/style.php"
            );
            $list[] = [
                'name'        => $name,
                'displayName' => $meta['name'] ?? ucfirst($name),
                'preview'     => $meta['preview'] ?? 'thumb.png',
                'isActive'    => $name === $current,
            ];
        }

        return $this->view('styles/index', [
            'styles'   => $list,
            'template' => $template->getName(),
        ]);
    }

    public function editAction(): string
    {
        $template = AddonHelper::getTemplate();
        if ($template === null) {
            return $this->view('error', ['error' => 'No active template']);
        }
        $style = (string)($_GET['style'] ?? 'default');

        return $this->view('styles/edit', [
            'template'  => $template->getName(),
            'style'     => $style,
            'styleName' => ucfirst($style),
            // Default Apple-spec color groups; real impl reads from core/styles/<style>/style.php
            'schemes'   => [
                ['name' => 'Default', 'dot' => '#1062fe', 'active' => true],
                ['name' => 'Green',   'dot' => '#299341', 'active' => false],
                ['name' => 'Orange',  'dot' => '#E07800', 'active' => false],
                ['name' => 'Purple',  'dot' => '#7B2CBF', 'active' => false],
                ['name' => 'Red',     'dot' => '#D92632', 'active' => false],
            ],
            'subcat'    => (string)($_GET['subcat'] ?? 'colors'),
        ]);
    }

    private function saveAction($template): string
    {
        $style = (string)$_POST['style'];
        if (in_array($style, $template->getStyles(), true)) {
            Settings::setValue($template->getName() . '_active_style', $style);
        }
        return $this->indexAction();
    }
}
