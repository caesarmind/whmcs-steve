<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\Uploader;
use Hadrian\Models\Settings;

/**
 * Admin: Branding tab.
 *
 * Five image slots stored in hadrian_settings as filenames (just the
 * basename — full disk + web paths are reconstructed by Uploader). The
 * legacy storage format ("/templates/hadrian/assets/img/branding/foo.png")
 * is normalized to a bare filename on first read; no migration script
 * needed.
 *
 * Routes:
 *   ?action=branding               → GET render, POST handle uploads
 *   ?action=branding&sub=remove    → POST remove a single field
 *
 * Security posture is documented in Uploader.php. Notably: we do NOT use a
 * CSRF token here to match the rest of the Hadrian admin controllers (none
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
     * `help` is the small grey line printed inside the empty upload tile.
     * Per-slot explanation stops there — the two logo sections carry an
     * info-tooltip on their heading (see renderIndex) and that is the only
     * place tooltip copy lives on this page.
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

    /**
     * Text/URL fields rendered in the same Branding tab below the image
     * uploads. `description` is a short tagline shown in the footer brand
     * block; the `social_*` URLs drive the footer social-icon row.
     * `type` controls validation (free text vs http(s) URL).
     *
     * @var array<string, array{label: string, help: string, type: 'text'|'url', maxLen: int, multiline?: bool}>
     */
    public const TEXT_FIELDS = [
        'footer_description' => [
            'label'    => 'Footer description',
            'help'     => '1-2 short sentences shown under the company name in the footer brand block.',
            'type'     => 'text',
            'maxLen'   => 280,
            'multiline'=> true,
        ],
        'footer_social_x' => [
            'label'  => 'X (Twitter)',
            'help'   => 'Full https:// URL. Leave blank to hide.',
            'type'   => 'url',
            'maxLen' => 200,
        ],
        'footer_social_linkedin' => [
            'label'  => 'LinkedIn',
            'help'   => '',
            'type'   => 'url',
            'maxLen' => 200,
        ],
        'footer_social_facebook' => [
            'label'  => 'Facebook',
            'help'   => '',
            'type'   => 'url',
            'maxLen' => 200,
        ],
        'footer_social_github' => [
            'label'  => 'GitHub',
            'help'   => '',
            'type'   => 'url',
            'maxLen' => 200,
        ],
        'footer_social_youtube' => [
            'label'  => 'YouTube',
            'help'   => '',
            'type'   => 'url',
            'maxLen' => 200,
        ],
        'footer_social_instagram' => [
            'label'  => 'Instagram',
            'help'   => '',
            'type'   => 'url',
            'maxLen' => 200,
        ],
    ];

    private const FLASH_KEY  = 'hadrian_branding_flash';
    private const ERRORS_KEY = 'hadrian_branding_errors';

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

            // Text + URL fields — only fields that are present in $_POST get
            // touched. An empty input clears the setting; a missing key means
            // the field wasn't on the submitted form and we leave it alone.
            foreach (self::TEXT_FIELDS as $field => $cfg) {
                if (!array_key_exists($field, $_POST)) {
                    continue;
                }
                $value = trim((string)$_POST[$field]);
                if ($value === '') {
                    if ((string)Settings::getValue($field, '') !== '') {
                        Settings::setValue($field, '');
                        $updated++;
                    }
                    continue;
                }
                if (mb_strlen($value) > $cfg['maxLen']) {
                    $errors[$field] = "Too long (max {$cfg['maxLen']} characters).";
                    continue;
                }
                if ($cfg['type'] === 'url'
                    && (!filter_var($value, FILTER_VALIDATE_URL) || !preg_match('#^https?://#i', $value))) {
                    $errors[$field] = 'Must be a valid http(s) URL.';
                    continue;
                }
                if ((string)Settings::getValue($field, '') !== $value) {
                    Settings::setValue($field, $value);
                    $updated++;
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
            $this->redirect('?module=Hadrian&action=branding');
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
            $this->redirect('?module=Hadrian&action=branding');
        }
        $this->startSession();
        $field = (string)($_POST['field'] ?? '');
        if (!array_key_exists($field, self::FIELDS)) {
            $_SESSION[self::FLASH_KEY] = 'invalid-field';
            $this->redirect('?module=Hadrian&action=branding');
        }
        $this->doRemove($field);
        $_SESSION[self::FLASH_KEY] = 'removed';
        $this->redirect('?module=Hadrian&action=branding');
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
     *   POST ?module=Hadrian&action=branding&sub=upload-ajax
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
     *   POST ?module=Hadrian&action=branding&sub=remove-ajax
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
        //
        // `tip` is the heading's info-tooltip copy. Only the two logo
        // sections get one -- what "Favicon" means needs no explaining, and
        // the per-slot tiles say enough with their label + help line. The
        // view renders a plain <h2> when tip is ''.
        $sections = [
            'full' => [
                'title' => 'Full Logo',
                'tip'   => 'The wide, horizontal version of your logo -- the one most of the client area uses. Shown in the top navigation, the page topbar, the login screen and the footer. Upload both variants so it stays legible in light and dark mode.',
                'rows'  => [],
            ],
            'square' => [
                'title' => 'Square Logo',
                'tip'   => 'A compact, square version of your mark, for the places a wide logo would be cut off: the icon rail, the top of the sidebar, and the home-screen icon when someone saves the site to a phone. The sidebar falls back to the full logo when this is empty; the rail shows a placeholder.',
                'rows'  => [],
            ],
            'favicon' => [
                'title' => 'Favicon',
                'tip'   => '',
                'rows'  => [],
            ],
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

        // Brand Info section — pre-fill the description + social URL inputs
        // from saved settings, attach the multiline flag and any per-field
        // error so the view can render textarea vs input and inline errors.
        $brandInfo = [];
        foreach (self::TEXT_FIELDS as $field => $cfg) {
            $brandInfo[$field] = [
                'field'     => $field,
                'label'     => $cfg['label'],
                'help'      => $cfg['help'],
                'type'      => $cfg['type'],
                'maxLen'    => $cfg['maxLen'],
                'multiline' => $cfg['multiline'] ?? false,
                'value'     => (string)Settings::getValue($field, ''),
                'error'     => $errors[$field] ?? '',
            ];
        }

        return $this->view('branding/index', [
            'sections'  => $sections,
            'brandInfo' => $brandInfo,
            'flash'     => $flash,
            'errors'    => $errors,
            'hasAny'    => $this->anyConfigured($sections),
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
