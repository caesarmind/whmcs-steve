<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\AddonHelper;
use MyTheme\Models\Configuration;

final class InfoController extends AbstractController
{
    public function indexAction(): string
    {
        $template = AddonHelper::getTemplate();

        // License key is managed in the admin (tblconfiguration 'mytheme_license_key');
        // status + details come from whmcs-licensing-modern's hook, which reads that key.
        $key         = (string) Configuration::getValue('mytheme_license_key');
        $hookPresent = function_exists('hostnodes_license_check');
        $status      = 'Unknown';
        $data        = [];

        if (!$hookPresent) {
            $status = 'Hook not installed';
        } elseif ($key === '') {
            $status = 'No key';
        } else {
            $res    = hostnodes_license_check($key);
            $status = !empty($res['ok']) ? 'Active' : (string) ($res['status'] ?? 'Invalid');

            // The hook caches the full verified payload (regdate, nextduedate, etc.).
            $cache = sys_get_temp_dir() . '/hn_theme_license.json';
            if (is_file($cache)) {
                $c = json_decode((string) file_get_contents($cache), true);
                if (is_array($c) && isset($c['data']) && is_array($c['data'])) {
                    $data = $c['data'];
                }
            }
        }

        return $this->view('info/index', [
            'info'    => [
                'version'    => $template?->getVersion() ?? 'unknown',
                'newVersion' => null, // TODO: wire to an update-check endpoint
            ],
            'license' => [
                'key'    => $key,
                'status' => $status,
                'data'   => $data,
            ],
        ]);
    }
}
