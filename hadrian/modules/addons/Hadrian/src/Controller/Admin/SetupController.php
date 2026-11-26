<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Database\Installer;
use Hadrian\Helpers\SetupChecks;
use Hadrian\Helpers\SetupProbe;
use Hadrian\Helpers\ThemeSwitch;
use Hadrian\Models\Configuration;

/**
 * The Setup page: one screen that says what is left before Hadrian can go
 * live, and does each remaining step from where it is listed.
 *
 * It shows the checklist SetupChecks works out from SetupProbe's facts, and
 * takes four POSTs (the `setup_do` field):
 *
 *   install     create or update the tables, menus and caches
 *   license     save the license key and check it
 *   golive      make Hadrian the client area theme, and the order form if it
 *               is uploaded; refused while an earlier step is open
 *   switchback  put back the theme the site used before
 *
 * Every POST carries the WHMCS admin token, checked centrally in
 * AbstractController::adminArea() before this class is reached. A POST that
 * worked redirects, so a reload never repeats it.
 */
final class SetupController extends AbstractController
{
    private const DONE = [
        'installed' => 'The database is up to date.',
        'license'   => 'License key saved.',
        'live'      => 'Hadrian is now live.',
        'back'      => 'The earlier theme is back in place.',
    ];

    public function indexAction(): string
    {
        $flash = null;
        $done  = is_string($_GET['done'] ?? null) ? $_GET['done'] : '';

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
            [$code, $error] = $this->handle((string)($_POST['setup_do'] ?? ''));
            if ($error === null) {
                $this->redirect('?module=Hadrian&action=setup&done=' . urlencode($code));
            }
            $flash = ['type' => 'danger', 'text' => $error];
        } elseif (isset(self::DONE[$done])) {
            $flash = ['type' => 'success', 'text' => self::DONE[$done]];
        }

        $facts   = SetupProbe::facts();
        $groups  = SetupChecks::evaluate($facts);
        $summary = SetupChecks::summary($groups, $facts);

        return $this->view('setup/index', [
            // Reached from the bare addon URL too (MainController::indexAction),
            // where the action reads "index".
            'currentAction' => 'setup',
            'groups'        => $groups,
            'summary'       => $summary,
            'flash'         => $flash,
            'licenseKey'    => (string)$facts['license']['key'],
            'live'          => $facts['live'],
            'previewUrl'    => $this->previewUrl($summary['cartReady']),
        ]);
    }

    /**
     * @return array{0:string,1:?string} the code to confirm with, and why it
     *                                   did not work (null when it did)
     */
    private function handle(string $do): array
    {
        switch ($do) {
            case 'install':
                try {
                    Installer::run(SetupProbe::addonRoot());
                } catch (\Throwable $e) {
                    return ['', 'The database could not be set up: ' . $e->getMessage()];
                }
                return ['installed', null];

            case 'license':
                Configuration::setValue('hadrian_license_key', trim((string)($_POST['license_key'] ?? '')));
                // The site-side check keeps its own answer; drop it so the new
                // key is asked about on the next page view.
                @unlink(sys_get_temp_dir() . '/hn_theme_license.json');
                SetupProbe::facts(freshLicense: true);
                return ['license', null];

            case 'golive':
                $facts   = SetupProbe::facts();
                $summary = SetupChecks::summary(SetupChecks::evaluate($facts), $facts);
                if ($summary['blocked']) {
                    return ['', 'Hadrian was not switched on. Finish the steps marked "To do" or "Problem" first.'];
                }
                ThemeSwitch::goLive(withCart: $summary['cartReady']);
                return ['live', null];

            case 'switchback':
                $error = ThemeSwitch::switchBack(SetupProbe::root());
                return $error === null ? ['back', null] : ['', $error];
        }

        return ['', 'Nothing was changed: that is not something this page does.'];
    }

    /**
     * The site in Hadrian for this browser only; nothing changes for visitors.
     * WHMCS keeps both parameters in the session, so the whole visit stays in
     * preview. carttpl is added when the order form is uploaded: without it
     * the cart shows the Hadrian shell around the old order form, whose hidden
     * "Added to Cart" modal then shows on the page unstyled.
     */
    private function previewUrl(bool $withCart): string
    {
        $base = rtrim((string)Configuration::getValue('SystemURL'), '/');
        return $base . '/index.php?systpl=' . urlencode(ThemeSwitch::THEME)
            . ($withCart ? '&carttpl=' . urlencode(ThemeSwitch::CART) : '');
    }
}
