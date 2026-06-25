<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\LicenseCheck;
use Hadrian\Models\Configuration;

/**
 * Theme license key entry. The key is stored in tblconfiguration; the live status
 * is checked against the Licensing Manager (see LicenseCheck). Licensing itself is
 * handled by the externally-installed licensing code, so this page just lets you
 * set the key and shows whether it's valid for the domain - no hook/enforcement UI.
 */
final class LicenseController extends AbstractController
{
    private const CFG_KEY = 'hadrian_license_key';

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
