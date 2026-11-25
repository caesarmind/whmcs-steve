<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The file a page travels in between sites: "hadrian-pages", version 1.
 *
 * A zip holding one description and the images the pages use:
 *
 *   manifest.json
 *   media/<file name>          one entry per library image
 *
 * manifest.json:
 *
 *   {
 *     "format":   "hadrian-pages",
 *     "version":  1,
 *     "builder":  "0.1.0",                 the module version that wrote it
 *     "exported": "2026-11-25T10:00:00+00:00",
 *     "pages": [
 *       {
 *         "name":     "WordPress hosting",
 *         "slug":     "hosting/wordpress", '' when the page had no address
 *         "status":   "published",         what it was on the site it left
 *         "replaces": "homepage",          the theme page it stood in for, or ''
 *         "meta":     { "title": {...}, "description": {...} },
 *         "doc":      { "v": 1, "sections": [...] }      see Document
 *       }
 *     ],
 *     "media":    { "<file name>": { "label": "Team photo", "sha256": "...", "bytes": 48211 } },
 *     "products": { "12": { "name": "Starter", "group": "Shared hosting" } }
 *   }
 *
 * Two kinds of value mean nothing on another site, so the file carries them
 * differently from how a page stores them:
 *
 *   - An image from the media library is written as "media:<file name>" and
 *     the file itself is put in media/. An image that is a plain web address
 *     stays as typed.
 *   - A product is a WHMCS id. The id stays in the document, and `products`
 *     says what it was called, so the importing site can find its own
 *     product of that name.
 *
 * The document exported is the page's DRAFT: the page as its editor shows it.
 *
 * Without PHP's zip extension the manifest alone is the file (.json). It is
 * the same description; images from the library are then left as the
 * addresses they had, because there is nowhere to put the files.
 *
 * READING treats the file as something a stranger made. Nothing is ever
 * extracted by its own name: this class reads manifest.json and, when asked
 * for one image by a name it has already checked, that one entry, each up to
 * a fixed size. What the manifest says is cut down to known keys here; the
 * sections go through Document::normalize() and every image through the
 * media library's upload checks when the page is imported (Importer).
 */
final class PageFile
{
    public const FORMAT  = 'hadrian-pages';
    public const VERSION = 1;

    /** How a library image is written in an exported document. */
    public const MEDIA_PREFIX = 'media:';

    private const MAX_FILE_BYTES     = 300 * 1024 * 1024;
    private const MAX_MANIFEST_BYTES = 16 * 1024 * 1024;
    private const MAX_ENTRIES        = 1200;
    private const MAX_PAGES          = 200;
    private const MAX_MEDIA          = 1000;
    /** One image. The library's own limit is 5 MB; anything larger would be refused there anyway. */
    private const MAX_MEDIA_BYTES    = 6 * 1024 * 1024;

    /** A file name the media folder of a pages file may hold. */
    private const MEDIA_NAME = '/^[A-Za-z0-9][A-Za-z0-9._-]{0,100}\.(?:png|jpe?g|gif|webp)$/i';

    public static function zipAvailable(): bool
    {
        return class_exists(\ZipArchive::class);
    }

    // ---------------------------------------------------------------- write

    /**
     * Describe these pages for a file.
     *
     * @param list<array<string,mixed>> $pages rows of Page::find()
     * @param bool $withMedia false when the images cannot travel (no zip)
     * @return array{manifest: array<string,mixed>, files: array<string,string>} files: media name => path on disk
     */
    public static function build(array $pages, Site $site, bool $withMedia = true): array
    {
        $withMedia = $withMedia && $site->movesMedia();
        $catalog   = [];
        foreach ($site->products() as $p) {
            $catalog[(int)$p['id']] = $p;
        }
        $media    = [];
        $files    = [];
        $products = [];
        $out      = [];

        foreach ($pages as $page) {
            // No language list: every translation the page holds goes along,
            // whatever this site offers today.
            $doc = Document::normalize((array)($page['draft'] ?? []));
            $doc = Document::walk($doc, static function (array $f, mixed $value) use ($site, $withMedia, $catalog, &$media, &$files, &$products): mixed {
                if ($f['type'] === 'image' && $withMedia && is_string($value) && $value !== '') {
                    $name = $site->mediaNameIn($value);
                    if ($name === '' || !preg_match(self::MEDIA_NAME, $name)) {
                        return $value;
                    }
                    if (!isset($media[$name])) {
                        $file = $site->mediaFile($name);
                        $hash = $file !== null ? @hash_file('sha256', $file['path']) : false;
                        if ($file === null || !is_string($hash)) {
                            return $value;          // gone from the library: nothing to take along
                        }
                        $files[$name] = $file['path'];
                        $media[$name] = [
                            'label'  => Text::line($file['label'], 120),
                            'sha256' => $hash,
                            'bytes'  => (int)@filesize($file['path']),
                        ];
                    }
                    return self::MEDIA_PREFIX . $name;
                }
                if ($f['type'] === 'product' && is_int($value) && $value > 0 && isset($catalog[$value])) {
                    $products[(string)$value] = [
                        'name'  => Text::line((string)$catalog[$value]['name'], 200),
                        'group' => Text::line((string)$catalog[$value]['group'], 200),
                    ];
                }
                return $value;
            });

            $replaces = (string)($page['replaces'] ?? '');
            $out[] = [
                'name'     => Text::line((string)($page['name'] ?? ''), 120),
                'slug'     => Text::slug((string)($page['slug'] ?? '')),
                'status'   => (string)($page['status'] ?? '') === 'published' ? 'published' : 'draft',
                'replaces' => Replace::isTarget($replaces) ? $replaces : '',
                'meta'     => Document::normalizeMeta((array)($page['meta'] ?? [])),
                'doc'      => $doc,
            ];
        }

        return [
            'manifest' => [
                'format'   => self::FORMAT,
                'version'  => self::VERSION,
                'builder'  => AdminController::VERSION,
                'exported' => gmdate('c'),
                'pages'    => $out,
                // Objects, also when empty, so the file reads the same either way.
                'media'    => (object)$media,
                'products' => (object)$products,
            ],
            'files' => $files,
        ];
    }

    /** The manifest as the text of a file. */
    public static function json(array $manifest): string
    {
        return (string)json_encode(
            $manifest,
            JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
    }

    /**
     * Write a built description and its images to a zip.
     *
     * @param array{manifest: array<string,mixed>, files: array<string,string>} $bundle
     */
    public static function writeZip(array $bundle, string $path): bool
    {
        if (!self::zipAvailable()) {
            return false;
        }
        $zip = new \ZipArchive();
        if ($zip->open($path, \ZipArchive::CREATE | \ZipArchive::OVERWRITE) !== true) {
            return false;
        }
        $ok = $zip->addFromString('manifest.json', self::json($bundle['manifest']));
        foreach ($bundle['files'] as $name => $file) {
            $ok = $zip->addFile($file, 'media/' . $name) && $ok;
        }
        return $zip->close() && $ok;
    }

    /**
     * What to call the download: the page's address or name for one page,
     * the date for several.
     *
     * @param list<array<string,mixed>> $pages
     */
    public static function fileName(array $pages, bool $zip): string
    {
        $base = 'pages-' . date('Y-m-d');
        if (count($pages) === 1) {
            $from = (string)($pages[0]['slug'] ?? '') !== '' ? (string)$pages[0]['slug'] : (string)($pages[0]['name'] ?? '');
            $slug = trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower($from)), '-');
            $base = $slug !== '' ? substr($slug, 0, 60) : 'page';
        }
        return $base . '.' . self::FORMAT . ($zip ? '.zip' : '.json');
    }

    // ----------------------------------------------------------------- read

    /**
     * Open a file someone uploaded and read what it says it holds.
     *
     * @return array{ok:bool, error:string, kind:string, manifest:array<string,mixed>}
     *         kind: "zip" or "json". manifest (see clean()): pages, media, products.
     */
    public static function read(string $path): array
    {
        $fail = static fn(string $error): array => ['ok' => false, 'error' => $error, 'kind' => '', 'manifest' => []];

        if (!is_file($path) || !is_readable($path)) {
            return $fail('The file could not be read.');
        }
        $size = (int)@filesize($path);
        if ($size < 2) {
            return $fail('The file is empty.');
        }
        if ($size > self::MAX_FILE_BYTES) {
            return $fail('The file is too large to import.');
        }
        $head = (string)@file_get_contents($path, false, null, 0, 4);

        if (str_starts_with($head, "PK")) {
            if (!self::zipAvailable()) {
                return $fail('This server\'s PHP has no zip extension, so a .zip cannot be opened here. Ask your host to enable "zip", or import a .json pages file.');
            }
            $zip = self::open($path);
            if ($zip === null) {
                return $fail('The zip could not be opened. It may be damaged; export the pages again.');
            }
            if ($zip->numFiles > self::MAX_ENTRIES) {
                $zip->close();
                return $fail('The zip holds more files than a pages file can.');
            }
            $stat = $zip->statName('manifest.json');
            if ($stat === false) {
                $zip->close();
                return $fail('This is not a Hadrian pages file: it has no manifest.json.');
            }
            if ((int)$stat['size'] > self::MAX_MANIFEST_BYTES) {
                $zip->close();
                return $fail('The description inside the file is too large.');
            }
            // The length is a cap of our own: the size a zip states is only a claim.
            $raw = $zip->getFromName('manifest.json', self::MAX_MANIFEST_BYTES + 1);
            $zip->close();
            if (!is_string($raw) || strlen($raw) > self::MAX_MANIFEST_BYTES) {
                return $fail('The description inside the file could not be read.');
            }
            $kind = 'zip';
        } else {
            if ($size > self::MAX_MANIFEST_BYTES) {
                return $fail('The file is too large to be a pages file.');
            }
            $raw  = (string)@file_get_contents($path);
            $kind = 'json';
        }

        // A file saved by an editor may start with a byte order mark.
        $raw  = str_starts_with($raw, "\xEF\xBB\xBF") ? substr($raw, 3) : $raw;
        $data = json_decode($raw, true, 64);
        if (!is_array($data)) {
            return $fail($kind === 'zip'
                ? 'The description inside the file is not valid JSON.'
                : 'This is not a Hadrian pages file. Choose a file exported from Pages (.hadrian-pages.zip or .json).');
        }
        $clean = self::clean($data);
        if ($clean['error'] !== '') {
            return $fail($clean['error']);
        }
        return ['ok' => true, 'error' => '', 'kind' => $kind, 'manifest' => $clean['manifest']];
    }

    /**
     * Cut a decoded manifest down to what this version understands, with
     * every value the right shape. The sections are passed on as they came:
     * Document::normalize() is their gate, at import.
     *
     * @param array<mixed> $data
     * @return array{error:string, manifest:array<string,mixed>}
     */
    public static function clean(array $data): array
    {
        $str  = static fn(mixed $v): string => is_scalar($v) ? (string)$v : '';
        $fail = static fn(string $error): array => ['error' => $error, 'manifest' => []];

        $version = is_numeric($data['version'] ?? null) ? (int)$data['version'] : 0;
        if ($str($data['format'] ?? '') !== self::FORMAT || $version < 1) {
            return $fail('This is not a Hadrian pages file. Choose a file exported from Pages.');
        }
        if ($version > self::VERSION) {
            return $fail('This file was made by a newer Hadrian Page Builder (file format ' . $version
                . '). Update Hadrian Page Builder on this site, then import it again.');
        }

        $pages = [];
        foreach (is_array($data['pages'] ?? null) ? $data['pages'] : [] as $page) {
            if (count($pages) >= self::MAX_PAGES) {
                break;
            }
            if (!is_array($page) || !is_array($page['doc'] ?? null)) {
                continue;
            }
            $replaces = $str($page['replaces'] ?? '');
            $pages[] = [
                'name'     => Text::line($str($page['name'] ?? ''), 120) ?: 'Imported page',
                'slug'     => Text::slug($str($page['slug'] ?? '')),
                'status'   => $str($page['status'] ?? '') === 'published' ? 'published' : 'draft',
                'replaces' => preg_match('/^[a-z0-9][a-z0-9-]{0,60}$/', $replaces) ? $replaces : '',
                'meta'     => is_array($page['meta'] ?? null) ? $page['meta'] : [],
                'doc'      => $page['doc'],
            ];
        }
        if ($pages === []) {
            return $fail('There are no pages in this file.');
        }

        $media = [];
        foreach (is_array($data['media'] ?? null) ? $data['media'] : [] as $name => $info) {
            $name = (string)$name;
            if (count($media) >= self::MAX_MEDIA || !self::isMediaName($name)) {
                continue;
            }
            $info = is_array($info) ? $info : [];
            $hash = strtolower($str($info['sha256'] ?? ''));
            $media[$name] = [
                'label'  => Text::line($str($info['label'] ?? ''), 120),
                'sha256' => preg_match('/^[a-f0-9]{64}$/', $hash) ? $hash : '',
                'bytes'  => max(0, (int)(is_numeric($info['bytes'] ?? null) ? $info['bytes'] : 0)),
            ];
        }

        $products = [];
        foreach (is_array($data['products'] ?? null) ? $data['products'] : [] as $id => $info) {
            if (!is_numeric($id) || (int)$id < 1 || !is_array($info) || count($products) >= 2000) {
                continue;
            }
            $products[(int)$id] = [
                'name'  => Text::line($str($info['name'] ?? ''), 200),
                'group' => Text::line($str($info['group'] ?? ''), 200),
            ];
        }

        return ['error' => '', 'manifest' => [
            'version'  => $version,
            'builder'  => Text::line($str($data['builder'] ?? ''), 20),
            'exported' => Text::line($str($data['exported'] ?? ''), 40),
            'pages'    => $pages,
            'media'    => $media,
            'products' => $products,
        ]];
    }

    /** A name the media folder may hold: one file name with an image extension, nothing that walks. */
    public static function isMediaName(string $name): bool
    {
        return preg_match(self::MEDIA_NAME, $name) === 1 && !str_contains($name, '..');
    }

    /**
     * The image names a zip really holds, out of the ones its manifest lists.
     *
     * @param list<string> $names
     * @return array<string,true>
     */
    public static function mediaIn(string $path, array $names): array
    {
        $zip = self::zipAvailable() ? self::open($path) : null;
        if ($zip === null) {
            return [];
        }
        $out = [];
        foreach ($names as $name) {
            if (self::isMediaName($name) && $zip->statName('media/' . $name) !== false) {
                $out[$name] = true;
            }
        }
        $zip->close();
        return $out;
    }

    /**
     * Copy one image out of a zip to a path of the caller's choosing.
     * Returns '' when it worked, or why it did not.
     *
     * The name is checked and the entry is looked up by it; the zip's own
     * entry names are never used as a place to write to. What comes out is
     * still only "a file someone called an image": the media library checks
     * it before it is stored.
     */
    public static function extractMedia(string $path, string $name, string $dest): string
    {
        if (!self::isMediaName($name)) {
            return 'not an image name';
        }
        $zip = self::zipAvailable() ? self::open($path) : null;
        if ($zip === null) {
            return 'the file could not be opened';
        }
        try {
            $stat = $zip->statName('media/' . $name);
            if ($stat === false) {
                return 'it is not in the file';
            }
            if ((int)$stat['size'] > self::MAX_MEDIA_BYTES) {
                return 'it is too large';
            }
            $in  = $zip->getStream('media/' . $name);
            $out = $in !== false ? @fopen($dest, 'wb') : false;
            if ($in === false || $out === false) {
                if (is_resource($in)) {
                    fclose($in);
                }
                return 'it could not be read';
            }
            // One byte over the limit is enough to know the stated size lied.
            $copied = stream_copy_to_stream($in, $out, self::MAX_MEDIA_BYTES + 1);
            fclose($in);
            fclose($out);
            if ($copied === false || $copied < 1) {
                @unlink($dest);
                return 'it could not be read';
            }
            if ($copied > self::MAX_MEDIA_BYTES) {
                @unlink($dest);
                return 'it is too large';
            }
            return '';
        } finally {
            $zip->close();
        }
    }

    private static function open(string $path): ?\ZipArchive
    {
        $zip   = new \ZipArchive();
        $flags = defined('ZipArchive::RDONLY') ? \ZipArchive::RDONLY : 0;
        return $zip->open($path, $flags) === true ? $zip : null;
    }
}
