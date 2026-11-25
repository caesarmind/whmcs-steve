<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Helpers\AdminAjax;
use Hadrian\Helpers\MediaLibrary;
use Hadrian\Helpers\MediaOptimizer;
use Hadrian\Helpers\MediaUsage;
use Hadrian\Helpers\Uploader;

/**
 * Admin: media library JSON API behind the image picker.
 *
 * Routes (all POST, via Hadrian_output() -> MainController::mediaAction, so
 * WHMCS has checked the admin login first; each answers and exits before
 * WHMCS prints the admin page):
 *   ?module=Hadrian&action=media&sub=list     -> browse
 *   ?module=Hadrian&action=media&sub=upload   -> add one file
 *   ?module=Hadrian&action=media&sub=delete   -> remove one or more
 *   ?module=Hadrian&action=media&sub=rename   -> change an image's name
 *   ?module=Hadrian&action=media&sub=optimize -> make one or more smaller
 *   ?module=Hadrian&action=media&sub=restore  -> put an original back
 *   ?module=Hadrian&action=media&sub=settings -> optimise new uploads, on or off
 *
 * The first three serve the picker on every admin page. The rest, and
 * `list` with usage=1, serve the Media screen (MediaScreenController), which
 * is the same library with room to manage it.
 *
 * `list` is a POST despite being semantically a read: it carries the CSRF
 * token like the other two, and AdminAjax::guard() refuses anything else.
 *
 * Deliberately does NOT extend AbstractController: that constructor spins up
 * a Smarty instance (compile + cache dirs) which is pure waste on a JSON
 * route, and it exposes redirect(), a never-returning exit() that must not be
 * reachable from an AJAX action.
 *
 * Auth: WHMCS's own admin login check (these run inside _output), and
 * AdminAjax::guard() at the start of boot(): POST, signed-in admin, CSRF
 * token. The X-Requested-With check after it is not an auth control; it only
 * turns a plain form post into a clear error.
 */
final class MediaController
{
    /** Guard against the endpoint being driven from a plain cross-origin form post. */
    private const REQUIRED_HEADER = 'XMLHttpRequest';

    /** Directory-level cap; keeps the modal payload and the disk bounded. */
    public const MAX_FILES = 500;

    /** Seconds one optimize request may spend; the screen sends the rest again. */
    private const OPTIMIZE_BUDGET = 8;

    private string $collection = MediaLibrary::DEFAULT_COLLECTION;
    private Uploader $uploader;
    /** @var array<string,mixed> */
    private array $cfg = [];

    // --------------------------------------------------------------- actions

    /** POST sub=list -> { ok, items[], total, ... } */
    public function listAction(): never
    {
        $this->boot();
        // Usage costs a read of every place an image can be saved in, so only
        // the Media screen asks for it; the picker's list stays cheap.
        $items = $this->items(!empty($_POST['usage']));
        $this->respondJson([
            'ok'        => true,
            'collection'=> $this->collection,
            'maxFiles'  => self::MAX_FILES,
            'optimizer' => MediaOptimizer::available(),
            'optimizeUploads' => MediaLibrary::optimizesUploads(),
            'deletable' => (bool)$this->cfg['deletable'],
            'accept'    => (string)$this->cfg['accept'],
            'maxBytes'  => (int)$this->cfg['maxBytes'],
            'maxHuman'  => $this->humanBytes((int)$this->cfg['maxBytes']),
            'uploadMax' => (string)ini_get('upload_max_filesize'),
            'postMax'   => (string)ini_get('post_max_size'),
            'total'     => count($items),
            'items'     => $items,
        ]);
    }

    /** POST sub=upload (one file, field `file`) -> { ok, item } */
    public function uploadAction(): never
    {
        $this->boot();

        $upload = $_FILES['file'] ?? null;
        if (!is_array($upload) || ($upload['tmp_name'] ?? '') === '') {
            // Both $_POST and $_FILES empty on a non-empty body means PHP
            // discarded the request for exceeding post_max_size — which
            // otherwise reads as an unexplained "no file received".
            if (empty($_POST) && empty($_FILES) && (int)($_SERVER['CONTENT_LENGTH'] ?? 0) > 0) {
                $this->respondJson([
                    'ok'    => false,
                    'error' => 'The upload exceeded the server limit (post_max_size = '
                        . ini_get('post_max_size') . ', upload_max_filesize = '
                        . ini_get('upload_max_filesize') . ').',
                ], 413);
            }
            $this->respondJson(['ok' => false, 'error' => 'No file received.'], 400);
        }

        if (count($this->uploader->listStored(self::MAX_FILES + 1)) >= self::MAX_FILES) {
            $this->respondJson([
                'ok'    => false,
                'error' => 'The media library is full (' . self::MAX_FILES . ' files). Delete something first.',
            ], 422);
        }

        // No previousValue: a library upload accumulates, it never replaces.
        $result = $this->uploader->handle($upload, [
            'allowedMimes' => $this->cfg['mimes'],
            'maxBytes'     => (int)$this->cfg['maxBytes'],
            'maxPixels'    => (int)$this->cfg['maxPixels'],
        ]);

        if (empty($result['ok'])) {
            // handle()'s messages are already end-user-facing.
            $this->respondJson(['ok' => false, 'error' => (string)($result['error'] ?? 'Upload failed.')], 422);
        }

        $stored = (string)$result['filename'];
        $path   = $this->uploader->diskPathFor($stored);
        $label  = MediaLibrary::labelFromUpload((string)($upload['name'] ?? ''));
        $size   = @getimagesize($path);
        MediaLibrary::remember(
            $this->collection,
            $stored,
            $label !== '' ? $label : $stored,
            (int)($size[0] ?? 0),
            (int)($size[1] ?? 0)
        );

        // Never fails the upload: an image that cannot be made smaller is
        // simply stored as it came.
        $status = '';
        if (MediaLibrary::optimizesUploads() && MediaOptimizer::available()) {
            $status = $this->optimizeOne($stored)['status'];
        }

        $this->respondJson(['ok' => true, 'optimized' => $status === 'optimized', 'item' => $this->itemFor($stored, false)]);
    }

    /** POST sub=delete (name[] or name) -> { ok, deleted, results{} } */
    public function deleteAction(): never
    {
        $this->boot();

        if (empty($this->cfg['deletable'])) {
            $this->respondJson(['ok' => false, 'error' => 'This collection is read-only.'], 403);
        }

        $raw = $_POST['name'] ?? [];
        $names = is_array($raw) ? $raw : [$raw];
        if ($names === []) {
            $this->respondJson(['ok' => false, 'error' => 'No file name given.'], 400);
        }

        // Membership set from the CURRENT listing. "Resolves inside the dir"
        // is NOT sufficient on its own — isLibraryName() already rejects
        // .htaccess and the manifest, and this makes the endpoint incapable
        // of touching anything the picker would not have shown.
        $present = [];
        foreach ($this->uploader->listStored(0) as $row) {
            $present[$row['name']] = true;
        }

        // An image that a page, an email or a menu still points at is not
        // deleted unless the caller says so (force=1, which the Media screen
        // sends after showing where it is used). The picker never forces.
        $force = !empty($_POST['force']);
        $inUse = $force ? [] : MediaUsage::of(array_values(array_filter($names, 'is_string')));

        $results = [];
        $deleted = 0;
        foreach ($names as $name) {
            $name = is_string($name) ? $name : '';
            if (!$this->uploader->isLibraryName($name)) {
                $results[$name === '' ? '(empty)' : $name] = 'invalid';
                continue;
            }
            if (!isset($present[$name])) {
                $results[$name] = 'not-found';
                continue;
            }
            if (isset($inUse[$name])) {
                $results[$name] = 'in-use';
                continue;
            }
            MediaOptimizer::forget($this->uploader->diskPathFor($name));
            $this->uploader->deleteFileSafe($name);
            MediaLibrary::forget($this->collection, $name);
            $results[$name] = 'deleted';
            $deleted++;
        }

        // Always 200: a partial failure is data, not an error condition.
        $this->respondJson(['ok' => true, 'deleted' => $deleted, 'results' => $results, 'usage' => (object)$inUse]);
    }

    /** POST sub=rename (name, label) -> { ok, item } */
    public function renameAction(): never
    {
        $this->boot();
        $name  = $this->storedName((string)($_POST['name'] ?? ''));
        $label = MediaLibrary::cleanLabel((string)($_POST['label'] ?? ''));
        if ($label === '') {
            $this->respondJson(['ok' => false, 'error' => 'Give the image a name.'], 422);
        }
        MediaLibrary::patch($this->collection, $name, ['label' => $label]);
        $this->respondJson(['ok' => true, 'item' => $this->itemFor($name)]);
    }

    /**
     * POST sub=optimize (name[] or name) -> { ok, results{name: {status, reason, item}}, pending[] }
     *
     * Works through the names until OPTIMIZE_BUDGET runs out and hands back
     * the ones it did not reach, so a large library never times a request out.
     */
    public function optimizeAction(): never
    {
        $this->boot();
        if (!MediaOptimizer::available()) {
            $this->respondJson(['ok' => false, 'error' => 'This server has no GD image library, so images cannot be optimised.'], 422);
        }
        $raw   = $_POST['name'] ?? [];
        $names = array_values(array_filter(is_array($raw) ? $raw : [$raw], 'is_string'));
        if ($names === []) {
            $this->respondJson(['ok' => false, 'error' => 'No file name given.'], 400);
        }

        $until   = microtime(true) + self::OPTIMIZE_BUDGET;
        $results = [];
        $pending = [];
        foreach ($names as $i => $name) {
            if ($i > 0 && microtime(true) > $until) {
                $pending[] = $name;
                continue;
            }
            if (!$this->uploader->isLibraryName($name) || $this->uploader->diskPathFor($name) === '') {
                $results[$name] = ['status' => 'skipped', 'reason' => 'No such image.', 'item' => null];
                continue;
            }
            $r = $this->optimizeOne($name);
            $results[$name] = ['status' => $r['status'], 'reason' => $r['reason'], 'item' => $this->itemFor($name)];
        }
        $this->respondJson(['ok' => true, 'results' => $results, 'pending' => $pending]);
    }

    /** POST sub=restore (name) -> { ok, item } */
    public function restoreAction(): never
    {
        $this->boot();
        $name = $this->storedName((string)($_POST['name'] ?? ''));
        $path = $this->uploader->diskPathFor($name);
        if (!MediaOptimizer::restore($path)) {
            $this->respondJson(['ok' => false, 'error' => 'There is no original to restore for this image.'], 422);
        }
        clearstatcache(true, $path);
        $size = @getimagesize($path);
        // skipOptimize: "Optimise library" leaves an image alone once its
        // original was put back on purpose.
        MediaLibrary::patch($this->collection, $name, [
            'w' => (int)($size[0] ?? 0), 'h' => (int)($size[1] ?? 0), 'skipOptimize' => 1,
        ]);
        $this->respondJson(['ok' => true, 'item' => $this->itemFor($name)]);
    }

    /**
     * POST sub=settings -> { ok, optimizeUploads, quality, maxEdge }
     *
     * Each field is optional and saved on its own, so the screen can send
     * the one control that changed: optimize=0|1, quality=<one of
     * MediaLibrary::QUALITIES>, max_edge=<one of MediaLibrary::MAX_EDGES>.
     */
    public function settingsAction(): never
    {
        $this->boot();
        try {
            if (isset($_POST['optimize'])) {
                MediaLibrary::setOptimizesUploads(!empty($_POST['optimize']));
            }
            if (isset($_POST['quality']) && !MediaLibrary::setQuality((int)$_POST['quality'])) {
                $this->respondJson(['ok' => false, 'error' => 'That quality is not one of the choices.'], 422);
            }
            if (isset($_POST['max_edge']) && !MediaLibrary::setMaxEdge((int)$_POST['max_edge'])) {
                $this->respondJson(['ok' => false, 'error' => 'That size is not one of the choices.'], 422);
            }
        } catch (\Throwable $e) {
            $this->respondJson(['ok' => false, 'error' => 'The setting could not be saved.'], 500);
        }
        $this->respondJson([
            'ok'              => true,
            'optimizeUploads' => MediaLibrary::optimizesUploads(),
            'quality'         => MediaLibrary::quality(),
            'maxEdge'         => MediaLibrary::maxEdge(),
        ]);
    }

    // ------------------------------------------------------------- internals

    /** Shared preamble: auth, header check, collection resolution, storage priming. */
    private function boot(): void
    {
        AdminAjax::guard();

        if (($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') !== self::REQUIRED_HEADER) {
            // Named in the message so a proxy stripping the header is
            // self-diagnosing rather than a mystery 400.
            $this->respondJson([
                'ok'    => false,
                'error' => 'Bad request - the X-Requested-With header was missing.',
            ], 400);
        }

        $requested = (string)($_POST['collection'] ?? MediaLibrary::DEFAULT_COLLECTION);
        if (!MediaLibrary::has($requested)) {
            $this->respondJson(['ok' => false, 'error' => 'Unknown media collection.'], 400);
        }

        $this->collection = $requested;
        $this->cfg        = MediaLibrary::config($requested);
        $this->uploader   = MediaLibrary::uploaderFor($requested);
        // Installs that never re-ran _upgrade have neither the dir nor the
        // .htaccess sidecar; priming here rather than only on activate means
        // the first picker open is enough.
        $this->uploader->prepareStorage();
    }

    /**
     * A name from the request that is a real library image, or a 404.
     * Same two checks as delete: shaped like a library image, and on disk.
     */
    private function storedName(string $name): string
    {
        if (!$this->uploader->isLibraryName($name) || $this->uploader->diskPathFor($name) === '') {
            $this->respondJson(['ok' => false, 'error' => 'No such image.'], 404);
        }
        return $name;
    }

    /**
     * Optimise one stored image and record its new size in the manifest.
     *
     * @return array{status:string,reason:string,before:int,after:int,width:int,height:int}
     */
    private function optimizeOne(string $name): array
    {
        $path = $this->uploader->diskPathFor($name);
        $r    = MediaOptimizer::optimize($path, MediaLibrary::quality(), MediaLibrary::maxEdge());
        clearstatcache(true, $path);
        if ($r['status'] === 'optimized') {
            MediaLibrary::patch($this->collection, $name, ['w' => $r['width'], 'h' => $r['height'], 'skipOptimize' => 0]);
        }
        return $r;
    }

    /** @return array<string,mixed> the tile for one stored image, read fresh from disk */
    private function itemFor(string $name, bool $withUsage = true): array
    {
        $path = $this->uploader->diskPathFor($name);
        clearstatcache(true, $path);
        $item = $this->decorate([
            'name'  => $name,
            'bytes' => (int)@filesize($path),
            'mtime' => (int)@filemtime($path),
        ], MediaLibrary::manifest($this->collection));
        // A new upload cannot be in use yet, so its tile skips the lookup.
        $item['usage'] = $withUsage ? (MediaUsage::of([$name])[$name] ?? []) : [];
        return $item;
    }

    /** @return list<array<string,mixed>> */
    private function items(bool $withUsage = false): array
    {
        $manifest = MediaLibrary::manifest($this->collection);
        $usage    = $withUsage ? MediaUsage::map() : null;
        $out = [];
        foreach ($this->uploader->listStored(self::MAX_FILES) as $row) {
            $item = $this->decorate($row, $manifest);
            if ($usage !== null) {
                $item['usage'] = $usage[$row['name']] ?? [];
            }
            $out[] = $item;
        }
        return $out;
    }

    /**
     * Server-side shape of one tile. Never includes a disk path, and never
     * echoes back a caller-supplied string.
     *
     * @param array{name:string,bytes:int,mtime:int} $row
     * @param array<string,mixed> $manifest
     * @return array<string,mixed>
     */
    private function decorate(array $row, array $manifest): array
    {
        $name  = $row['name'];
        $entry = is_array($manifest[$name] ?? null) ? $manifest[$name] : [];
        $label = trim((string)($entry['label'] ?? ''));
        // The original's size on disk is the truth about "optimised": it is
        // there exactly while the image can be restored.
        $before = MediaOptimizer::originalBytes($this->uploader->diskPathFor($name));
        $bytes  = (int)$row['bytes'];

        return [
            'name'   => $name,
            'label'  => $label !== '' ? $label : $name,
            'url'    => $this->uploader->webUrlFor($name),
            'absUrl' => MediaLibrary::absUrlFor($this->collection, $name),
            'bytes'  => $bytes,
            'human'  => $this->humanBytes($bytes),
            'mtime'  => (int)$row['mtime'],
            'ext'    => strtolower((string)pathinfo($name, PATHINFO_EXTENSION)),
            // 0 x 0 for a file that came in before sizes were recorded, or by
            // FTP; the browser reads the size off the image it loads instead.
            'w'      => (int)($entry['w'] ?? 0),
            'h'      => (int)($entry['h'] ?? 0),
            'optimized'    => $before > 0,
            'saved'        => $before > 0 ? max(0, $before - $bytes) : 0,
            'savedHuman'   => $before > 0 ? $this->humanBytes(max(0, $before - $bytes)) : '',
            'skipOptimize' => !empty($entry['skipOptimize']),
        ];
    }

    private function humanBytes(int $bytes): string
    {
        if ($bytes < 1024)        return $bytes . ' B';
        if ($bytes < 1024 * 1024) return round($bytes / 1024) . ' KB';
        return round($bytes / (1024 * 1024), 1) . ' MB';
    }

    /**
     * Copied verbatim (and kept private) from BrandingController rather than
     * refactored into a shared base: that would put the live branding upload
     * path in this change's blast radius for no functional gain.
     *
     * The buffer flush must run FIRST — it is what discards WHMCS's own
     * output-filter buffer, which would otherwise prepend admin HTML to the
     * JSON body.
     */
    private function respondJson(array $payload, int $code = 200): never
    {
        while (ob_get_level() > 0) {
            @ob_end_clean();
        }
        if (!headers_sent()) {
            http_response_code($code);
            header('Content-Type: application/json; charset=utf-8');
            header('X-Content-Type-Options: nosniff');
            header('Cache-Control: no-store');
        }
        echo (string)json_encode($payload);
        exit;
    }
}
