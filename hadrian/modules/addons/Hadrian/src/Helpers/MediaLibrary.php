<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Configuration;

/**
 * Media library: the seam between the admin picker and the Uploader.
 *
 * A "collection" is one storage bucket with its own directory, allowed MIME
 * set and delete policy. Only 'library' ships today; the registry exists so
 * the second consumer (Branding wanting to re-use an already uploaded image,
 * a page option of type 'image') is a table entry rather than a second
 * implementation of upload/list/delete.
 *
 * Why a separate dir from branding: a library delete must never be able to
 * orphan `logo_light` out from under hadrian_settings, and the two buckets
 * have deliberately different MIME policies (branding allows SVG, the
 * library does not — see Uploader::IMAGE_MEDIA).
 *
 * ── The label manifest ──────────────────────────────────────────────────
 * Uploader::handle() names files bin2hex(random_bytes(16)).ext, which is the
 * right security property (no enumeration, no collision, no attacker-chosen
 * name) and a terrible UX one: a library of 40 files is 40 lines of hex. So
 * a sidecar `.hadrian-media.json` maps stored name -> the original upload
 * name, and the picker shows that. Files that arrive out of band (FTP, git)
 * simply have no entry and fall back to their filename.
 *
 * The manifest is advisory: a corrupt or missing file degrades to "no
 * labels", never to an error. Its leading dot means Uploader::isLibraryName()
 * refuses to list or delete it, for free.
 */
final class MediaLibrary
{
    public const DEFAULT_COLLECTION = 'library';

    private const MANIFEST = '.hadrian-media.json';

    /** Label length cap — long enough to be useful, short enough not to wrap a tile. */
    private const LABEL_MAX = 80;

    /**
     * @var array<string, array{
     *   label: string, dir: string, webDir: string,
     *   mimes: list<string>, accept: string,
     *   maxBytes: int, maxPixels: int, deletable: bool,
     * }>
     */
    private const COLLECTIONS = [
        'library' => [
            'label'     => 'Media library',
            'dir'       => 'media',
            'webDir'    => '/templates/hadrian/assets/img/media',
            'mimes'     => Uploader::IMAGE_MEDIA,
            'accept'    => 'image/png,image/jpeg,image/gif,image/webp',
            'maxBytes'  => 5 * 1024 * 1024,
            'maxPixels' => 50000000,
            'deletable' => true,
        ],
        // Documented, deliberately NOT shipped yet:
        // 'branding' => [... 'dir' => 'branding', 'deletable' => false ...]
        // read-only, so the picker could offer an existing logo without a
        // library delete being able to break hadrian_settings.
    ];

    public static function has(string $key): bool
    {
        return array_key_exists($key, self::COLLECTIONS);
    }

    /** @return array<string,mixed> */
    public static function config(string $key): array
    {
        return self::COLLECTIONS[$key] ?? self::COLLECTIONS[self::DEFAULT_COLLECTION];
    }

    public static function uploaderFor(string $key): Uploader
    {
        $cfg  = self::config($key);
        $root = defined('ROOTDIR') ? ROOTDIR : dirname(__DIR__, 5);
        $disk = rtrim($root, '/\\')
            . DIRECTORY_SEPARATOR . 'templates'
            . DIRECTORY_SEPARATOR . 'hadrian'
            . DIRECTORY_SEPARATOR . 'assets'
            . DIRECTORY_SEPARATOR . 'img'
            . DIRECTORY_SEPARATOR . $cfg['dir'];

        return new Uploader($disk, $cfg['webDir']);
    }

    /**
     * Absolute URL for a stored file.
     *
     * Takes scheme + host + port ONLY from SystemURL and hands the path to
     * Uploader::webUrlFor(), which already prepends WEB_ROOT. Concatenating
     * the whole SystemURL with webUrlFor() would double the WEB_ROOT segment
     * on an install running in a subdirectory.
     *
     * This matters because header.tpl emits the stored social image RAW into
     * og:image / twitter:image with no resolver, and the Open Graph spec
     * requires an absolute URL.
     */
    public static function absUrlFor(string $key, string $storedName): string
    {
        $rel = self::uploaderFor($key)->webUrlFor($storedName);
        if ($rel === '') {
            return '';
        }
        $origin = self::origin();
        return $origin === '' ? $rel : $origin . $rel;
    }

    /** scheme://host[:port] with no trailing slash and no path. */
    public static function origin(): string
    {
        $raw = '';
        try {
            $raw = (string)(Configuration::getValue('SystemURL') ?? '');
        } catch (\Throwable $e) {
            $raw = '';
        }
        if ($raw !== '') {
            $p = parse_url($raw);
            if (!empty($p['host'])) {
                $scheme = (string)($p['scheme'] ?? 'https');
                $port   = isset($p['port']) ? ':' . (int)$p['port'] : '';
                return $scheme . '://' . $p['host'] . $port;
            }
        }
        // Last resort (misconfigured SystemURL): derive from the request.
        $https  = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        $scheme = (string)($_SERVER['REQUEST_SCHEME'] ?? ($https ? 'https' : 'http'));
        $host   = (string)($_SERVER['HTTP_HOST'] ?? '');
        return $host !== '' ? $scheme . '://' . $host : '';
    }

    // ------------------------------------------------------------- manifest

    /**
     * @return array<string, array{label:string,w:int,h:int,at:int}>
     */
    public static function manifest(string $key): array
    {
        $path = self::manifestPath($key);
        if ($path === '' || !is_file($path)) {
            return [];
        }
        $raw = @file_get_contents($path);
        if ($raw === false || $raw === '') {
            return [];
        }
        $data = json_decode($raw, true);
        return is_array($data) ? $data : [];   // corrupt -> no labels, never fatal
    }

    /** Record (or overwrite) one entry. Best-effort: a failed write costs a label, nothing more. */
    public static function remember(string $key, string $storedName, string $label, int $w = 0, int $h = 0): void
    {
        self::mutate($key, static function (array $map) use ($storedName, $label, $w, $h): array {
            $map[$storedName] = ['label' => $label, 'w' => $w, 'h' => $h, 'at' => time()];
            return $map;
        });
    }

    public static function forget(string $key, string $storedName): void
    {
        self::mutate($key, static function (array $map) use ($storedName): array {
            unset($map[$storedName]);
            return $map;
        });
    }

    /**
     * Derive a human label from the browser-supplied upload name.
     * Never trusted as a path — basename, extension dropped, control chars
     * stripped, length capped. It is display text only.
     */
    public static function labelFromUpload(string $clientName): string
    {
        $base = basename(str_replace('\\', '/', trim($clientName)));
        $base = (string)preg_replace('/\.[A-Za-z0-9]{1,5}$/', '', $base);
        $base = (string)preg_replace('/[\x00-\x1F\x7F]/u', '', $base);
        $base = trim((string)preg_replace('/\s+/u', ' ', $base));
        if ($base === '') {
            return '';
        }
        return function_exists('mb_substr')
            ? mb_substr($base, 0, self::LABEL_MAX)
            : substr($base, 0, self::LABEL_MAX);
    }

    // ------------------------------------------------------------ internals

    private static function manifestPath(string $key): string
    {
        $dir = self::uploaderFor($key)->getDiskDir();
        return is_dir($dir) ? $dir . DIRECTORY_SEPARATOR . self::MANIFEST : '';
    }

    /**
     * Read-modify-write under an exclusive lock. Two admins uploading at the
     * same moment would otherwise race and one label would vanish.
     *
     * @param callable(array<string,mixed>):array<string,mixed> $fn
     */
    private static function mutate(string $key, callable $fn): void
    {
        $path = self::manifestPath($key);
        if ($path === '') {
            return;                         // dir not created yet
        }
        $fh = @fopen($path, 'c+');
        if ($fh === false) {
            return;
        }
        try {
            if (!@flock($fh, LOCK_EX)) {
                return;
            }
            $raw  = (string)stream_get_contents($fh);
            $data = json_decode($raw, true);
            $map  = is_array($data) ? $data : [];
            $map  = $fn($map);
            $json = json_encode($map, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            if ($json === false) {
                return;
            }
            @ftruncate($fh, 0);
            @rewind($fh);
            @fwrite($fh, $json);
            @fflush($fh);
            @flock($fh, LOCK_UN);
        } finally {
            @fclose($fh);
        }
    }
}
