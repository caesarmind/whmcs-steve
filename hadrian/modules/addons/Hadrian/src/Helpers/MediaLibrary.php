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

    /** How many images a collection holds before uploads and imports are refused. */
    public const MAX_FILES = 500;

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
     * Change some fields of one entry and keep the rest. Makes the entry when
     * the file has none (it arrived by FTP or git).
     *
     * @param array<string,mixed> $fields
     */
    public static function patch(string $key, string $storedName, array $fields): void
    {
        self::mutate($key, static function (array $map) use ($storedName, $fields): array {
            $entry = is_array($map[$storedName] ?? null) ? $map[$storedName] : ['label' => '', 'w' => 0, 'h' => 0, 'at' => 0];
            $map[$storedName] = $fields + $entry;
            return $map;
        });
    }

    // ------------------------------------------- files that come with a module

    /**
     * One library image as a module that exports it needs it: where it is on
     * disk and what the admin calls it. Null when there is no such image.
     *
     * @return array{path:string,label:string,w:int,h:int}|null
     */
    public static function file(string $storedName, string $key = self::DEFAULT_COLLECTION): ?array
    {
        $uploader = self::uploaderFor($key);
        if (!$uploader->isLibraryName($storedName)) {
            return null;
        }
        $path = $uploader->diskPathFor($storedName);
        if ($path === '' || !is_file($path)) {
            return null;
        }
        $entry = self::manifest($key)[$storedName] ?? [];
        $entry = is_array($entry) ? $entry : [];
        return [
            'path'  => $path,
            'label' => trim((string)($entry['label'] ?? '')),
            'w'     => (int)($entry['w'] ?? 0),
            'h'     => (int)($entry['h'] ?? 0),
        ];
    }

    /**
     * Put a file that is already on this server into the library: an image
     * that arrived inside an imported page, say. It gets every check an
     * upload gets (Uploader::ingest) and the same treatment afterwards: a
     * label, its size recorded, optimised when new uploads are.
     *
     * The same image is stored once. The file's hash as it arrived is kept in
     * the manifest (`src`), so importing the same page twice, or two pages
     * that share a picture, does not fill the library with copies even when
     * optimising has changed the stored bytes.
     *
     * The source file is left where it is; the caller removes it.
     *
     * @return array{ok:bool, name?:string, url?:string, reused?:bool, error?:string}
     */
    public static function add(string $path, string $label, string $key = self::DEFAULT_COLLECTION): array
    {
        if (!self::has($key)) {
            return ['ok' => false, 'error' => 'Unknown media collection.'];
        }
        $hash = is_file($path) ? @hash_file('sha256', $path) : false;
        if (!is_string($hash)) {
            return ['ok' => false, 'error' => 'The file could not be read.'];
        }
        $cfg      = self::config($key);
        $uploader = self::uploaderFor($key);
        $uploader->prepareStorage();

        $stored = $uploader->listStored(self::MAX_FILES + 1);
        $bytes  = (int)@filesize($path);
        $known  = self::manifest($key);
        foreach ($stored as $row) {
            $name  = $row['name'];
            $entry = is_array($known[$name] ?? null) ? $known[$name] : [];
            $same  = ($entry['src'] ?? '') === $hash
                || ($row['bytes'] === $bytes && @hash_file('sha256', $uploader->diskPathFor($name)) === $hash);
            if ($same) {
                return ['ok' => true, 'name' => $name, 'url' => $uploader->webUrlFor($name), 'reused' => true];
            }
        }
        if (count($stored) >= self::MAX_FILES) {
            return ['ok' => false, 'error' => 'The media library is full (' . self::MAX_FILES . ' files).'];
        }

        $result = $uploader->ingest($path, [
            'allowedMimes' => $cfg['mimes'],
            'maxBytes'     => (int)$cfg['maxBytes'],
            'maxPixels'    => (int)$cfg['maxPixels'],
        ]);
        if (empty($result['ok'])) {
            return ['ok' => false, 'error' => (string)($result['error'] ?? 'The image could not be stored.')];
        }
        $name  = (string)$result['filename'];
        $disk  = $uploader->diskPathFor($name);
        $size  = @getimagesize($disk);
        $label = self::cleanLabel($label);
        self::remember($key, $name, $label !== '' ? $label : $name, (int)($size[0] ?? 0), (int)($size[1] ?? 0));
        self::patch($key, $name, ['src' => $hash]);

        // Never fails the import: an image that cannot be made smaller is
        // stored as it came.
        if (self::optimizesUploads() && class_exists(MediaOptimizer::class) && MediaOptimizer::available()) {
            try {
                $r = MediaOptimizer::optimize($disk, self::quality(), self::maxEdge());
                if (($r['status'] ?? '') === 'optimized') {
                    self::patch($key, $name, ['w' => (int)$r['width'], 'h' => (int)$r['height'], 'skipOptimize' => 0]);
                }
            } catch (\Throwable $e) {
                // Stored as it came.
            }
        }
        return ['ok' => true, 'name' => $name, 'url' => $uploader->webUrlFor($name), 'reused' => false];
    }

    /**
     * Clean a name an admin typed for an image. Display text only: it is
     * never a path, and the file on disk keeps its own name.
     */
    public static function cleanLabel(string $label): string
    {
        $label = (string)preg_replace('/[\x00-\x1F\x7F]/u', '', $label);
        $label = trim((string)preg_replace('/\s+/u', ' ', $label));
        return function_exists('mb_substr')
            ? mb_substr($label, 0, self::LABEL_MAX)
            : substr($label, 0, self::LABEL_MAX);
    }

    // ---------------------------------------------------------- optimising

    /** The Hadrian setting behind "Optimise new uploads". On unless switched off. */
    public const OPTIMIZE_SETTING = 'media_optimize_uploads';

    /** Are new uploads optimised as they arrive? */
    public static function optimizesUploads(): bool
    {
        try {
            return (string)\Hadrian\Models\Settings::getValue(self::OPTIMIZE_SETTING, '1') !== '0';
        } catch (\Throwable $e) {
            return false;                       // no settings table: leave uploads as they are
        }
    }

    public static function setOptimizesUploads(bool $on): void
    {
        \Hadrian\Models\Settings::setValue(self::OPTIMIZE_SETTING, $on ? '1' : '0');
    }

    public const QUALITY_SETTING  = 'media_optimize_quality';
    public const MAX_EDGE_SETTING = 'media_optimize_max_edge';

    /**
     * The quality choices on the Media screen: JPEG/WebP quality => what the
     * admin reads. Three named levels, not a 1-100 slider: nobody knows what
     * 74 looks like, and the useful range is narrow.
     */
    public const QUALITIES = [
        90 => 'High: closest to the original',
        82 => 'Balanced: smaller, looks the same at normal sizes',
        70 => 'Small: smallest files, fine detail softens',
    ];

    /** The size choices: longest edge in pixels => label. 0 keeps every image at its own size. */
    public const MAX_EDGES = [
        1600 => '1600 px',
        1920 => '1920 px',
        2560 => '2560 px',
        3840 => '3840 px',
        0    => 'Do not resize',
    ];

    /** The quality optimising uses. Always one of QUALITIES. */
    public static function quality(): int
    {
        return self::choice(self::QUALITY_SETTING, self::QUALITIES, MediaOptimizer::QUALITY);
    }

    /** The longest edge optimising scales down to; 0 for none. Always one of MAX_EDGES. */
    public static function maxEdge(): int
    {
        return self::choice(self::MAX_EDGE_SETTING, self::MAX_EDGES, MediaOptimizer::MAX_EDGE);
    }

    /** Save a quality; false when it is not one of the choices. */
    public static function setQuality(int $quality): bool
    {
        if (!isset(self::QUALITIES[$quality])) {
            return false;
        }
        \Hadrian\Models\Settings::setValue(self::QUALITY_SETTING, (string)$quality);
        return true;
    }

    /** Save a longest edge; false when it is not one of the choices. */
    public static function setMaxEdge(int $edge): bool
    {
        if (!isset(self::MAX_EDGES[$edge])) {
            return false;
        }
        \Hadrian\Models\Settings::setValue(self::MAX_EDGE_SETTING, (string)$edge);
        return true;
    }

    /**
     * A stored setting, if it is still one of the choices; the default
     * otherwise (never saved, no table, or a value a later version dropped).
     *
     * @param array<int,string> $choices
     */
    private static function choice(string $key, array $choices, int $default): int
    {
        try {
            $raw = \Hadrian\Models\Settings::getValue($key);
        } catch (\Throwable $e) {
            return $default;
        }
        return is_numeric($raw) && isset($choices[(int)$raw]) ? (int)$raw : $default;
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
