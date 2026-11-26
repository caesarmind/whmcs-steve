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
        $data     = $result['data'];

        // The signed licence reply says which release this site runs, the
        // latest release, and whether the licence covers each (support period).
        $installed = (string) ($data['version'] ?? '');
        $latest    = (string) ($data['latest_version'] ?? '');
        $newer     = $installed !== '' && $latest !== '' && version_compare($latest, $installed, '>');

        return $this->view('info/index', [
            'info'    => [
                'version'    => $template?->getVersion() ?? 'unknown',
                'newVersion' => $newer ? $latest : null,
                'newAllowed' => $newer && !empty($data['latest_allowed']),
            ],
            'updates' => [
                // Before the licence server answers with a support period, fall
                // back to the licence state, as this page always did.
                'entitled' => isset($data['version_allowed']) ? (bool) $data['version_allowed'] : $result['active'],
                'kind'     => (string) ($data['support']['kind'] ?? ''),
                'until'    => (string) ($data['support']['until'] ?? ''),
                // Support that has run out still covers what was released before.
                'ended'    => ($data['support']['until'] ?? '') !== '' && $data['support']['until'] < date('Y-m-d'),
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
