<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Helpers\MediaLibrary;
use Hadrian\Helpers\Uploader;

/**
 * Admin: media library JSON API behind the image picker.
 *
 * Routes (all POST, dispatched from hooks.php BEFORE WHMCS renders chrome):
 *   ?module=Hadrian&action=media&sub=list     -> browse
 *   ?module=Hadrian&action=media&sub=upload   -> add one file
 *   ?module=Hadrian&action=media&sub=delete   -> remove one or more
 *
 * `list` is a POST despite being semantically a read: the hooks.php intercept
 * is REQUEST_METHOD === 'POST' gated, so a GET falls through to
 * addonmodules.php -> MainController and returns a full page of admin HTML —
 * which surfaces to the caller as the "Server returned a non-JSON response"
 * JSON.parse failure rather than anything diagnosable.
 *
 * Deliberately does NOT extend AbstractController: that constructor spins up
 * a Smarty instance (compile + cache dirs) which is pure waste on a JSON
 * route, and it exposes redirect(), a never-returning exit() that must not be
 * reachable from an AJAX action.
 *
 * Auth: defined('ADMINAREA') is the gate, matching BrandingController — see
 * the comment block in hooks.php for why a session/token check at this
 * lifecycle point was observed non-functional on real WHMCS 9.
 */
final class MediaController
{
    /** Guard against the endpoint being driven from a plain cross-origin form post. */
    private const REQUIRED_HEADER = 'XMLHttpRequest';

    /** Directory-level cap; keeps the modal payload and the disk bounded. */
    private const MAX_FILES = 500;

    private string $collection = MediaLibrary::DEFAULT_COLLECTION;
    private Uploader $uploader;
    /** @var array<string,mixed> */
    private array $cfg = [];

    // --------------------------------------------------------------- actions

    /** POST sub=list -> { ok, items[], total, ... } */
    public function listAction(): never
    {
        $this->boot();
        $items = $this->items();
        $this->respondJson([
            'ok'        => true,
            'collection'=> $this->collection,
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
        $label  = MediaLibrary::labelFromUpload((string)($upload['name'] ?? ''));
        if ($label !== '') {
            MediaLibrary::remember($this->collection, $stored, $label);
        }

        $this->respondJson(['ok' => true, 'item' => $this->decorate([
            'name'  => $stored,
            'bytes' => (int)@filesize($this->uploader->diskPathFor($stored)),
            'mtime' => time(),
        ], MediaLibrary::manifest($this->collection))]);
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
            $this->uploader->deleteFileSafe($name);
            MediaLibrary::forget($this->collection, $name);
            $results[$name] = 'deleted';
            $deleted++;
        }

        // Always 200: a partial failure is data, not an error condition.
        $this->respondJson(['ok' => true, 'deleted' => $deleted, 'results' => $results]);
    }

    // ------------------------------------------------------------- internals

    /** Shared preamble: header check, collection resolution, storage priming. */
    private function boot(): void
    {
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

    /** @return list<array<string,mixed>> */
    private function items(): array
    {
        $manifest = MediaLibrary::manifest($this->collection);
        $out = [];
        foreach ($this->uploader->listStored(self::MAX_FILES) as $row) {
            $out[] = $this->decorate($row, $manifest);
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

        return [
            'name'   => $name,
            'label'  => $label !== '' ? $label : $name,
            'url'    => $this->uploader->webUrlFor($name),
            'absUrl' => MediaLibrary::absUrlFor($this->collection, $name),
            'bytes'  => (int)$row['bytes'],
            'human'  => $this->humanBytes((int)$row['bytes']),
            'mtime'  => (int)$row['mtime'],
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
