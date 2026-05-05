<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;

final class InfoController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();

        $info = [
            'version'           => $template?->getVersion() ?? 'unknown',
            'displayName'       => $template?->getDisplayName() ?? 'Hostnodes',
            'newVersion'        => null,                  // TODO: wire to update-check endpoint
            'registrationDate'  => null,                  // TODO: from license server
            'nextDueDate'       => null,                  // TODO: from license server
            'firstPaymentAmount'=> null,
            'recurringAmount'   => null,
            'paymentMethod'     => null,
            'supportExpired'    => false,
            'licenseKey'        => $template?->license()->getLicenseKey() ?? '',
            'licenseStatus'     => $template?->canActivate() ? 'Active' : 'Inactive',
            'devMode'           => $template?->license()->isDevMode() ?? false,
        ];

        return $this->view('info/index', ['info' => $info]);
    }
}
