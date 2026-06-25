<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\AddonHelper;
use Hadrian\Helpers\LicenseCheck;
use Hadrian\Models\Configuration;

final class InfoController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();
        $key      = (string) Configuration::getValue('hadrian_license_key');
        $result   = LicenseCheck::status($key);

        return $this->view('info/index', [
            'info'    => [
                'version'    => $template?->getVersion() ?? 'unknown',
                'newVersion' => null, // TODO: wire to an update-check endpoint
            ],
            'license' => [
                'key'    => $key,
                'active' => $result['active'],
                'status' => $result['status'],
                'data'   => $result['data'], // productname, regdate, nextduedate, billingcycle, validdomain, addons
            ],
        ]);
    }
}
