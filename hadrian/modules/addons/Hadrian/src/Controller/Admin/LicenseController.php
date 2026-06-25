<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\LicenseCheck;
use Hadrian\Models\Configuration;

/**
 * Theme license key entry. The key is stored in tblconfiguration; the live status
 * is checked against the Licensing Manager (see LicenseCheck). The enforcement
 * *decision* (what the front-end hook last decided to do) is recorded by the hook
 * in tblconfiguration and surfaced here so you can verify behaviour - especially
 * while the hook is in DRY-RUN - before it ever touches the live theme.
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

        $decision = json_decode((string) Configuration::getValue('hadrian_license_decision'), true);
        $mode     = is_array($decision) ? (string) ($decision['mode'] ?? '') : '';
        $dstatus  = is_array($decision) ? (string) ($decision['status'] ?? '') : '';
        $enforce  = is_array($decision) ? (bool) ($decision['enforce'] ?? false) : null;

        [$decLevel, $decText] = self::describeDecision($mode, $dstatus, $enforce);

        return $this->view('license/index', [
            'key'      => $key,
            'active'   => $result['active'],
            'status'   => $result['status'],
            'enforce'  => $enforce,           // true = enforcing, false = dry-run, null = hook not seen yet
            'reverted' => Configuration::getValue('hadrian_license_reverted') === '1',
            'decLevel' => $decLevel,          // success | info | warning | danger | neutral
            'decText'  => $decText,
        ]);
    }

    /** @return array{0:string,1:string} [level, text] */
    private static function describeDecision(string $mode, string $status, ?bool $enforce): array
    {
        if ($mode === '') {
            return ['neutral', 'No enforcement decision recorded yet. Once the license hook is installed, load any client-area page and refresh this page.'];
        }

        $dry = ($enforce === false);

        switch ($mode) {
            case 'ok':
                return ['success', 'Theme is licensed and running normally.'];
            case 'soft_quiet':
                return ['warning', 'License is ' . $status . '. The theme keeps running, but theme updates are paused until you renew.'];
            case 'grace_warn':
                return ['warning', 'The license could not be verified. The client area will revert to the default theme soon unless this is resolved.'];
            case 'revert':
                return $dry
                    ? ['warning', 'License is ' . $status . '. Enforcement is in DRY-RUN, so the theme has NOT been reverted. Confirm the key is correct, then enable enforcement in the hook.']
                    : ['danger', 'License is ' . $status . '. The client area has been reverted to the default theme.'];
        }

        return ['neutral', ''];
    }
}
