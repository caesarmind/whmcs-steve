<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\LicenseCheck;
use MyTheme\Models\Configuration;

/**
 * Theme license key entry. The key is stored in tblconfiguration; the live
 * status is checked against the Licensing Manager (see LicenseCheck).
 */
final class LicenseController extends AbstractController
{
    private const CFG_KEY = 'mytheme_license_key';

    public function indexAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['license_key'])) {
            Configuration::setValue(self::CFG_KEY, trim((string) $_POST['license_key']));
            // Drop the cached front-end result so the site re-checks the new key.
            @unlink(sys_get_temp_dir() . '/hn_theme_license.json');
        }

        $key    = (string) Configuration::getValue(self::CFG_KEY);
        $result = LicenseCheck::status($key);

        return $this->view('license/index', [
            'key'    => $key,
            'active' => $result['active'],
            'status' => $result['status'],
        ]);
    }
}
