<?php
declare(strict_types=1);

namespace MyThemeLicensing;

/**
 * Where license records come from. Two backends:
 *   - WhmcsLicenseStore: production. License = a WHMCS product/service; status
 *     follows the billing lifecycle (tblhosting.domainstatus), so an unpaid
 *     invoice -> Suspended -> the theme reacts. This is the Lagom model.
 *   - FileLicenseStore: dev/testing. Reads licenses.dev.json (same shape as the
 *     Node server's licenses.json) so verify.php runs without a WHMCS install.
 *
 * make_store() picks one automatically.
 */
interface LicenseStore
{
    /**
     * @return array{license_status:string,expires:string,allowed_domains:list<string>,features:list<string>,max_domains:int}|null
     */
    public function find(string $licenseKey): ?array;

    public function bindDomain(string $licenseKey, string $domain): void;
}

final class FileLicenseStore implements LicenseStore
{
    public function __construct(private string $path) {}

    public function find(string $licenseKey): ?array
    {
        $rec = $this->load()[$licenseKey] ?? null;
        if ($rec === null) {
            return null;
        }
        return [
            'license_status'  => (string) ($rec['status'] ?? 'Invalid'),
            'expires'         => (string) ($rec['expires'] ?? ''),
            'allowed_domains' => array_values((array) ($rec['allowed_domains'] ?? [])),
            'features'        => array_values((array) ($rec['features'] ?? [])),
            'max_domains'     => (int) ($rec['max_domains'] ?? 1),
        ];
    }

    public function bindDomain(string $licenseKey, string $domain): void
    {
        $db = $this->load();
        if (!isset($db[$licenseKey])) {
            return;
        }
        $domains = (array) ($db[$licenseKey]['allowed_domains'] ?? []);
        if (!in_array($domain, $domains, true)) {
            $domains[] = $domain;
            $db[$licenseKey]['allowed_domains'] = array_values($domains);
            file_put_contents(
                $this->path,
                json_encode($db, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n"
            );
        }
    }

    private function load(): array
    {
        return is_file($this->path)
            ? (json_decode((string) file_get_contents($this->path), true) ?: [])
            : [];
    }
}

final class WhmcsLicenseStore implements LicenseStore
{
    public function find(string $licenseKey): ?array
    {
        $row = \Illuminate\Database\Capsule\Manager::table('mod_mytheme_licenses as l')
            ->join('tblhosting as h', 'h.id', '=', 'l.serviceid')
            ->where('l.license_key', $licenseKey)
            ->select('h.domainstatus', 'h.nextduedate', 'l.allowed_domains', 'l.features', 'l.max_domains')
            ->first();

        if ($row === null) {
            return null;
        }

        return [
            'license_status'  => self::mapStatus((string) $row->domainstatus),
            'expires'         => self::toIso((string) $row->nextduedate),
            'allowed_domains' => self::csv((string) $row->allowed_domains),
            'features'        => self::csv((string) $row->features),
            'max_domains'     => (int) $row->max_domains,
        ];
    }

    public function bindDomain(string $licenseKey, string $domain): void
    {
        $row = \Illuminate\Database\Capsule\Manager::table('mod_mytheme_licenses')
            ->where('license_key', $licenseKey)->first();
        if ($row === null) {
            return;
        }
        $domains = self::csv((string) $row->allowed_domains);
        if (!in_array($domain, $domains, true)) {
            $domains[] = $domain;
            \Illuminate\Database\Capsule\Manager::table('mod_mytheme_licenses')
                ->where('license_key', $licenseKey)
                ->update(['allowed_domains' => implode(',', $domains)]);
        }
    }

    /** Map the WHMCS service status to a LicenseState the client understands. */
    private static function mapStatus(string $whmcsStatus): string
    {
        return match ($whmcsStatus) {
            'Active'                  => 'Active',
            'Suspended'               => 'Suspended',
            'Terminated', 'Cancelled' => 'Cancelled',
            'Fraud'                   => 'Banned',
            default                   => 'Invalid', // Pending, etc.
        };
    }

    private static function toIso(string $date): string
    {
        if ($date === '' || $date === '0000-00-00') {
            return '';
        }
        $ts = strtotime($date);
        return $ts ? gmdate('Y-m-d\T00:00:00\Z', $ts) : '';
    }

    /** @return list<string> */
    private static function csv(string $s): array
    {
        return array_values(array_filter(array_map('trim', explode(',', $s)), 'strlen'));
    }
}

/**
 * Pick the store: WHMCS-backed when this module sits inside a WHMCS install
 * (vendor autoload + configuration.php present), otherwise the dev file store.
 */
function make_store(): LicenseStore
{
    // TEST MODE: if licenses.dev.json is present in the module root, use it and
    // bypass WHMCS entirely. DELETE that file in production so licenses come from
    // WHMCS billing (the WhmcsLicenseStore below).
    $devDb = dirname(__DIR__) . '/licenses.dev.json';
    if (is_file($devDb)) {
        return new FileLicenseStore($devDb);
    }

    $whmcsRoot = dirname(__DIR__, 4); // .../modules/servers/MyThemeLicensing/lib -> WHMCS root
    $autoload  = $whmcsRoot . '/vendor/autoload.php';
    $config    = $whmcsRoot . '/configuration.php';

    if (is_file($autoload) && is_file($config)) {
        require_once $autoload;

        // Read DB creds from WHMCS configuration.php (plaintext) — lighter than a
        // full init.php bootstrap, and avoids WHMCS request-context side effects.
        $db_host = $db_port = $db_username = $db_password = $db_name = '';
        require $config;

        $capsule = new \Illuminate\Database\Capsule\Manager();
        $capsule->addConnection([
            'driver'    => 'mysql',
            'host'      => $db_host,
            'port'      => $db_port !== '' ? $db_port : '3306',
            'database'  => $db_name,
            'username'  => $db_username,
            'password'  => $db_password,
            'charset'   => 'utf8',
            'collation' => 'utf8_general_ci',
            'prefix'    => '',
        ]);
        $capsule->setAsGlobal();
        $capsule->bootEloquent();

        return new WhmcsLicenseStore();
    }

    return new FileLicenseStore($devDb); // last-resort fallback (no WHMCS detected)
}
