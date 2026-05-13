<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;
use MyTheme\Helpers\Uploader;
use MyTheme\Models\Settings;

/**
 * Admin: Branding tab.
 *
 * Five image slots stored in mytheme_settings as filenames (just the
 * basename — full disk + web paths are reconstructed by Uploader). The
 * legacy storage format ("/templates/mytheme/assets/img/branding/foo.png")
 * is normalized to a bare filename on first read; no migration script
 * needed.
 *
 * Routes:
 *   ?action=branding               → GET render, POST handle uploads
 *   ?action=branding&sub=remove    → POST remove a single field
 *
 * Security posture is documented in Uploader.php. Notably: we do NOT use a
 * CSRF token here to match the rest of the MyTheme admin controllers (none
 * of them do — WHMCS gates /admin/addonmodules.php). The upload-side
 * validation (MIME triple-check, size cap, hashed filenames, sidecar
 * .htaccess) is the security boundary.
 */
final class BrandingController extends AbstractController
{
    /**
     * Single source of truth — drives both the controller's validation
     * dispatch and the view's per-field rendering (label, hints, accept
     * attribute, size cap). Adding a new branding slot only requires
     * touching this table.
     *
     * @var array<string, array{
     *   label: string,
     *   help: string,
     *   maxBytes: int,
     *   allowedMimes: list<string>,
     *   accept: string,
     *   group: string,
     *   variant: 'light'|'dark'|'single',
     * }>
     */
    public const FIELDS = [
        'logo_light' => [
            'label'        => 'Logo (light backgrounds)',
            'help'         => 'PNG, JPG, WebP or SVG. Suggested: at least 40 px tall.',
            'maxBytes'     => 2 * 1024 * 1024,
            'allowedMimes' => Uploader::IMAGE_BITMAP_AND_SVG,
            'accept'       => 'image/png,image/jpeg,image/webp,image/svg+xml',
            'group'        => 'full',
            'variant'      => 'light',
        ],
        'logo_dark' => [
            'label'        => 'Logo (dark backgrounds)',
            'help'         => 'PNG, JPG, WebP or SVG. Suggested: at least 40 px tall.',
            'maxBytes'     => 2 * 1024 * 1024,
            'allowedMimes' => Uploader::IMAGE_BITMAP_AND_SVG,
            'accept'       => 'image/png,image/jpeg,image/webp,image/svg+xml',
            'group'        => 'full',
            'variant'      => 'dark',
        ],
        'logo_square_light' => [
            'label'        => 'Square logo (light)',
            'help'         => 'Avatar / icon variant. Square aspect, ~64–128 px.',
            'maxBytes'     => 1 * 1024 * 1024,
            'allowedMimes' => Uploader::IMAGE_BITMAP_AND_SVG,
            'accept'       => 'image/png,image/jpeg,image/webp,image/svg+xml',
            'group'        => 'square',
            'variant'      => 'light',
        ],
        'logo_square_dark' => [
            'label'        => 'Square logo (dark)',
            'help'         => 'Avatar / icon variant. Square aspect, ~64–128 px.',
            'maxBytes'     => 1 * 1024 * 1024,
            'allowedMimes' => Uploader::IMAGE_BITMAP_AND_SVG,
            'accept'       => 'image/png,image/jpeg,image/webp,image/svg+xml',
            'group'        => 'square',
            'variant'      => 'dark',
        ],
        'favicon' => [
            'label'        => 'Favicon',
            'help'         => '.ico, .png or .svg. Square preferred (16/32/64 px).',
            'maxBytes'     => 256 * 1024,
            'allowedMimes' => Uploader::IMAGE_FAVICON,
            'accept'       => 'image/x-icon,image/vnd.microsoft.icon,image/png,image/svg+xml',
            'group'        => 'favicon',
            'variant'      => 'single',
        ],
    ];

    private const FLASH_KEY  = 'mytheme_branding_flash';
    private const ERRORS_KEY = 'mytheme_branding_errors';

    private Uploader $uploader;

    public function __construct(array $params = [])
    {
        parent::__construct($params);
        $this->uploader = new Uploader();
    }

    public function indexAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $this->startSession();
            $errors  = [];
            $updated = 0;

            foreach (self::FIELDS as $field => $cfg) {
                // No file uploaded for this slot → nothing to do.
                if (empty($_FILES[$field]['tmp_name'])
                    || ($_FILES[$field]['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
                    continue;
                }
                $result = $this->uploader->handle($_FILES[$field], [
                    'allowedMimes'  => $cfg['allowedMimes'],
                    'maxBytes'      => $cfg['maxBytes'],
                    'previousValue' => (string)Settings::getValue($field, ''),
                ]);
                if ($result['ok']) {
                    Settings::setValue($field, $result['filename']);
                    $updated++;
                } else {
                    $errors[$field] = $result['error'];
                }
            }

            $_SESSION[self::ERRORS_KEY] = $errors;
            $flash = match (true) {
                !empty($errors) && $updated > 0 => 'partial',
                !empty($errors)                 => 'errors',
                $updated > 0                    => 'saved',
                default                         => 'noop',
            };
            $_SESSION[self::FLASH_KEY] = $flash;
            $this->redirect('?module=MyTheme&action=branding');
        }

        return $this->renderIndex();
    }

    /**
     * Sub-route: ?action=branding&sub=remove (POST with `field`).
     * Wipes the file and clears the Settings row. Form-fallback path
     * used when JS is disabled — the AJAX equivalent (removeAjaxAction)
     * is the normal flow.
     */
    public function removeAction(): string
    {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->redirect('?module=MyTheme&action=branding');
        }
        $this->startSession();
        $field = (string)($_POST['field'] ?? '');
        if (!array_key_exists($field, self::FIELDS)) {
            $_SESSION[self::FLASH_KEY] = 'invalid-field';
            $this->redirect('?module=MyTheme&action=branding');
        }
        $this->doRemove($field);
        $_SESSION[self::FLASH_KEY] = 'removed';
        $this->redirect('?module=MyTheme&action=branding');
    }

    /**
     * AJAX sub-route: handles one field's upload in isolation. Returns
     * JSON, exits without touching the WHMCS admin chrome.
     *
     * Routed from adminHooks.php which fires BEFORE WHMCS starts echoing
     * the admin header. Going through MainController would land us inside
     * the admin body and corrupt the JSON with leading HTML.
     *
     * Request shape:
     *   POST ?module=MyTheme&action=branding&sub=upload-ajax
     *   field=<one of self::FIELDS>
     *   file=<binary>
     *
     * Response on success:
     *   { ok: true, field, filename, url, label }
     * Response on failure:
     *   { ok: false, error }
     */
    public function uploadAjaxAction(): never
    {
        $field = (string)($_POST['field'] ?? '');
        if (!array_key_exists($field, self::FIELDS)) {
            $this->respondJson(['ok' => false, 'error' => 'Unknown branding field.'], 400);
        }
        $cfg = self::FIELDS[$field];

        // Per-field $_FILES[$field] (form fallback) OR generic $_FILES['file']
        // (AJAX path). Both shapes work; the JS uses 'file'.
        $upload = !empty($_FILES['file']['tmp_name'])
            ? $_FILES['file']
            : ($_FILES[$field] ?? null);

        if (!is_array($upload) || empty($upload['tmp_name'])) {
            $this->respondJson(['ok' => false, 'error' => 'No file received.'], 400);
        }

        $result = $this->uploader->handle($upload, [
            'allowedMimes'  => $cfg['allowedMimes'],
            'maxBytes'      => $cfg['maxBytes'],
            'previousValue' => (string)Settings::getValue($field, ''),
        ]);

        if (!$result['ok']) {
            $this->respondJson(['ok' => false, 'error' => $result['error']], 422);
        }

        Settings::setValue($field, $result['filename']);
        $this->respondJson([
            'ok'       => true,
            'field'    => $field,
            'filename' => $result['filename'],
            'url'      => $this->uploader->webUrlFor($result['filename']),
            'label'    => $cfg['label'],
        ]);
    }

    /**
     * AJAX sub-route: removes one field's file. Same routing as upload-ajax.
     *
     * Request shape:
     *   POST ?module=MyTheme&action=branding&sub=remove-ajax
     *   field=<one of self::FIELDS>
     *
     * Response: { ok: true, field } | { ok: false, error }
     */
    public function removeAjaxAction(): never
    {
        $field = (string)($_POST['field'] ?? '');
        if (!array_key_exists($field, self::FIELDS)) {
            $this->respondJson(['ok' => false, 'error' => 'Unknown branding field.'], 400);
        }
        $this->doRemove($field);
        $this->respondJson(['ok' => true, 'field' => $field]);
    }

    // ----------------------------------------------------------------- internals

    /**
     * NB: must NOT be named render() — AbstractController declares a static
     * render() factory method, and PHP 8 fatals on static→instance signature
     * mismatch. Sibling controllers (Settings/Menu/etc.) inline this kind
     * of view-prep instead of extracting; we extract because the method is
     * shared between indexAction (POST→redirect, GET→render) and any
     * future GET-only callers.
     */
    private function renderIndex(): string
    {
        $this->startSession();
        $flash  = (string)($_SESSION[self::FLASH_KEY]  ?? '');
        $errors = (array) ($_SESSION[self::ERRORS_KEY] ?? []);
        // One-shot flash — clear immediately so a refresh doesn't re-show
        // last submission's banner.
        unset($_SESSION[self::FLASH_KEY], $_SESSION[self::ERRORS_KEY]);

        // Build view rows: regroup FIELDS into the three sections the
        // template needs (full / square / favicon) with current value +
        // resolved preview URL + per-field error attached.
        $sections = [
            'full'    => ['title' => 'Full Logo',   'rows' => []],
            'square'  => ['title' => 'Square Logo', 'rows' => []],
            'favicon' => ['title' => 'Favicon',     'rows' => []],
        ];
        foreach (self::FIELDS as $field => $cfg) {
            $stored = $this->uploader->normalizeStored((string)Settings::getValue($field, ''));
            $sections[$cfg['group']]['rows'][$field] = [
                'field'    => $field,
                'label'    => $cfg['label'],
                'help'     => $cfg['help'],
                'accept'   => $cfg['accept'],
                'variant'  => $cfg['variant'],
                'maxBytes' => $cfg['maxBytes'],
                'maxHuman' => $this->humanBytes($cfg['maxBytes']),
                'stored'   => $stored,
                'url'      => $stored !== '' ? $this->uploader->webUrlFor($stored) : '',
                'error'    => $errors[$field] ?? '',
            ];
        }

        return $this->view('branding/index', [
            'sections' => $sections,
            'flash'    => $flash,
            'errors'   => $errors,
            'hasAny'   => $this->anyConfigured($sections),
        ]);
    }

    private function anyConfigured(array $sections): bool
    {
        foreach ($sections as $section) {
            foreach ($section['rows'] as $row) {
                if (!empty($row['stored'])) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Errors are per-field and structured; we can't fit them in the URL
     * cleanly, so they go in the session. WHMCS starts the admin session
     * before our addon runs, but defend against test contexts that don't.
     */
    private function startSession(): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            @session_start();
        }
    }

    private function humanBytes(int $bytes): string
    {
        if ($bytes < 1024)        return $bytes . ' B';
        if ($bytes < 1024 * 1024) return round($bytes / 1024) . ' KB';
        return round($bytes / (1024 * 1024), 1) . ' MB';
    }

    /** Wipe file + clear Settings. Shared by form-based remove and AJAX remove. */
    private function doRemove(string $field): void
    {
        $stored = (string)Settings::getValue($field, '');
        if ($stored !== '') {
            $this->uploader->deleteFileSafe($stored);
        }
        Settings::setValue($field, '');
    }

    /**
     * JSON response with clean output buffer. The AJAX endpoints are
     * dispatched from adminHooks.php BEFORE WHMCS renders chrome, so the
     * output buffer should be empty here — but flush defensively in case
     * any hook earlier in the chain echoed something.
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
