<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Models\Settings;

final class BrandingController extends AbstractController
{
    public function indexAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_FILES)) {
            $this->handleUploads();
        }

        return $this->view('branding/index', [
            'logoLight'        => Settings::getValue('logo_light'),
            'logoDark'         => Settings::getValue('logo_dark'),
            'logoSquareLight'  => Settings::getValue('logo_square_light'),
            'logoSquareDark'   => Settings::getValue('logo_square_dark'),
            'favicon'          => Settings::getValue('favicon'),
        ]);
    }

    private function handleUploads(): void
    {
        $allowed = ['logo_light', 'logo_dark', 'logo_square_light', 'logo_square_dark', 'favicon'];
        foreach ($allowed as $field) {
            if (empty($_FILES[$field]['tmp_name'])) {
                continue;
            }
            // TODO: real upload + validation. For now just store the filename.
            $name = basename((string)$_FILES[$field]['name']);
            $dest = __DIR__ . '/../../../../templates/mytheme/assets/img/branding/' . $name;
            if (@move_uploaded_file($_FILES[$field]['tmp_name'], $dest)) {
                Settings::setValue($field, '/templates/mytheme/assets/img/branding/' . $name);
            }
        }
    }
}
