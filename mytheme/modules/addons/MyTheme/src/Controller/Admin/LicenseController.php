<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Models\Configuration;

/**
 * Theme license key entry.
 *
 * The KEY is stored here (tblconfiguration 'mytheme_license_key'); VALIDATION is
 * performed by whmcs-licensing-modern's hook (includes/hooks/hostnodes_theme_license.php),
 * which reads that same key. This page just saves the key and surfaces the hook's
 * live status — it does NOT run the old MyTheme license server.
 */
final class LicenseController extends AbstractController
{
    private const CFG_KEY = 'mytheme_license_key';

    public function indexAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['license_key'])) {
            Configuration::setValue(self::CFG_KEY, trim((string) $_POST['license_key']));
            // Clear the hook's cached result so the status below reflects this key now.
            @unlink(sys_get_temp_dir() . '/hn_theme_license.json');
        }

        $key         = (string) Configuration::getValue(self::CFG_KEY);
        $hookPresent = function_exists('hostnodes_license_check');
        $status      = 'Unknown';
        $detail      = '';

        if (!$hookPresent) {
            $status = 'Hook not installed';
            $detail = 'Upload includes/hooks/hostnodes_theme_license.php to this WHMCS, then reload.';
        } elseif ($key === '') {
            $status = 'No key';
            $detail = 'Enter the license key issued for this domain.';
        } else {
            $res = hostnodes_license_check($key);
            if (!empty($res['ok'])) {
                $status = 'Active';
                $detail = 'The theme is licensed for this domain.';
            } else {
                $status = (string) ($res['status'] ?? 'Invalid');
                $detail = !empty($res['soft'])
                    ? 'Could not reach the license server right now — offline grace applies.'
                    : 'The license server rejected this key for this domain.';
            }
        }

        return $this->view('license/index', [
            'key'         => $key,
            'status'      => $status,
            'detail'      => $detail,
            'hookPresent' => $hookPresent,
        ]);
    }
}
