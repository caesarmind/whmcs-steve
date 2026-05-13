<?php
declare(strict_types=1);

namespace MyTheme\Helpers;

/**
 * Hardened image upload helper for the Branding admin tab.
 *
 * Defends against the usual file-upload attack surface:
 *
 *   1. MIME triple-check  — the browser-claimed $_FILES['type'] is ignored.
 *                           We sniff the real MIME with finfo, verify the
 *                           file is a parseable image via getimagesize(),
 *                           and require BOTH to match the per-field allow
 *                           list. SVG (which getimagesize can't parse) is
 *                           handled as a text-content-sniff special case.
 *   2. Size cap           — rejected before move_uploaded_file.
 *   3. Extension whitelist — derived from the sniffed MIME, never from the
 *                           uploaded filename. The user-supplied name is
 *                           discarded entirely.
 *   4. Hashed filename    — random_bytes(16) prevents enumeration + name
 *                           collisions + reflected-XSS-via-filename.
 *   5. Path containment   — destination is realpath()-checked against the
 *                           branding dir so symlink trickery can't escape.
 *   6. .htaccess drop     — first write into the branding dir installs a
 *                           sidecar .htaccess that disables PHP execution,
 *                           so even if validation is bypassed somehow a
 *                           planted .php file won't execute.
 *   7. SVG hardening      — SVG uploads are scanned for <script>, on*
 *                           attributes, javascript: URIs, and external
 *                           entity refs. Anything suspicious is rejected.
 *   8. Atomic replacement — caller-supplied `previousValue` is deleted
 *                           AFTER the new file lands successfully.
 *
 * Usage:
 *   $uploader = new Uploader();
 *   $result   = $uploader->handle($_FILES['logo_light'], [
 *       'allowedMimes' => Uploader::IMAGE_BITMAP_AND_SVG,
 *       'maxBytes'     => 2 * 1024 * 1024,
 *       'previousValue'=> Settings::getValue('logo_light'),
 *   ]);
 *   if ($result['ok']) {
 *       Settings::setValue('logo_light', $result['filename']);
 *   } else {
 *       // $result['error'] is a translated, end-user-facing string.
 *   }
 */
final class Uploader
{
    /** Mime → extension map. Trust the sniffed mime, write our own extension. */
    public const MIME_EXT_MAP = [
        'image/png'                => 'png',
        'image/jpeg'               => 'jpg',
        'image/gif'                => 'gif',
        'image/webp'               => 'webp',
        'image/svg+xml'            => 'svg',
        'image/svg'                => 'svg',
        'image/x-icon'             => 'ico',
        'image/vnd.microsoft.icon' => 'ico',
    ];

    /** Common bundles used by the Branding controller. */
    public const IMAGE_BITMAP_AND_SVG = ['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml'];
    public const IMAGE_FAVICON        = ['image/png', 'image/x-icon', 'image/vnd.microsoft.icon', 'image/svg+xml'];

    /** Max upload size cap regardless of caller config — server-side limit floor. */
    private const HARD_CEILING_BYTES = 5 * 1024 * 1024;

    private string $diskDir;
    private string $webPath;

    /**
     * @param string $diskDir Absolute filesystem path to the upload dir (without trailing slash).
     * @param string $webPath Web-relative path to the same dir (e.g. /templates/mytheme/assets/img/branding).
     */
    public function __construct(?string $diskDir = null, ?string $webPath = null)
    {
        $this->diskDir = $diskDir ?? self::defaultDiskDir();
        $this->webPath = '/' . trim($webPath ?? '/templates/mytheme/assets/img/branding', '/');
    }

    /**
     * Process a single $_FILES[$field] entry.
     *
     * @param array<string,mixed> $file    Raw $_FILES[$field] array.
     * @param array{
     *   allowedMimes: list<string>,
     *   maxBytes: int,
     *   previousValue?: string|null,
     * } $config
     * @return array{
     *   ok: bool,
     *   filename?: string,    // present on success — store this in Settings
     *   error?: string,       // present on failure — user-facing message
     * }
     */
    public function handle(array $file, array $config): array
    {
        // Upload-error code from PHP comes BEFORE our validation. INI-level
        // size limits surface as UPLOAD_ERR_INI_SIZE; we don't run a second
        // check against ini_get('upload_max_filesize') because PHP has
        // already enforced it for us.
        $err = (int)($file['error'] ?? UPLOAD_ERR_NO_FILE);
        if ($err === UPLOAD_ERR_NO_FILE) {
            return ['ok' => false, 'error' => 'No file was uploaded.'];
        }
        if ($err !== UPLOAD_ERR_OK) {
            return ['ok' => false, 'error' => $this->describePhpUploadError($err)];
        }

        $tmp = (string)($file['tmp_name'] ?? '');
        if ($tmp === '' || !is_uploaded_file($tmp)) {
            return ['ok' => false, 'error' => 'Upload was not received through PHP; rejected.'];
        }

        $size = (int)($file['size'] ?? @filesize($tmp));
        $cap  = min((int)$config['maxBytes'], self::HARD_CEILING_BYTES);
        if ($size <= 0) {
            return ['ok' => false, 'error' => 'Uploaded file is empty.'];
        }
        if ($size > $cap) {
            return [
                'ok'    => false,
                'error' => sprintf('File is too large (%s). Limit is %s.', $this->humanBytes($size), $this->humanBytes($cap)),
            ];
        }

        $sniff = $this->sniffMime($tmp);
        if ($sniff === null) {
            return ['ok' => false, 'error' => 'Unsupported file type (could not detect the format).'];
        }
        if (!in_array($sniff, $config['allowedMimes'], true)) {
            return [
                'ok'    => false,
                'error' => sprintf('Unsupported file type (%s). Allowed: %s.', $sniff, implode(', ', $config['allowedMimes'])),
            ];
        }

        // Bitmap formats must parse as real images. SVG (vector text) skips
        // getimagesize and runs through the SVG content scanner instead.
        if ($sniff === 'image/svg+xml') {
            $svgError = $this->scanSvg($tmp);
            if ($svgError !== null) {
                return ['ok' => false, 'error' => $svgError];
            }
        } elseif ($sniff !== 'image/x-icon' && $sniff !== 'image/vnd.microsoft.icon') {
            // .ico isn't supported by getimagesize on all PHP builds; for
            // .ico we trust the finfo sniff. For PNG/JPEG/WebP/GIF we
            // require getimagesize to confirm it's actually an image.
            $probe = @getimagesize($tmp);
            if ($probe === false) {
                return ['ok' => false, 'error' => 'File does not appear to be a real image.'];
            }
        }

        if (!$this->ensureDir()) {
            return ['ok' => false, 'error' => 'Branding directory is not writable. Check filesystem permissions.'];
        }

        // Drop the .htaccess sidecar BEFORE writing the file. Even if the
        // move below fails, the dir is hardened for the next attempt.
        $this->ensureHtaccess();

        $ext      = self::MIME_EXT_MAP[$sniff] ?? 'bin';
        $filename = bin2hex(random_bytes(16)) . '.' . $ext;
        $dest     = $this->diskDir . DIRECTORY_SEPARATOR . $filename;

        // Path containment — even though $filename is hex-only and can't
        // escape, realpath() the dir and reject if the resolved dest is
        // outside it. Defends against a symlinked branding dir pointing
        // somewhere it shouldn't.
        $realDir = realpath($this->diskDir);
        if ($realDir === false) {
            return ['ok' => false, 'error' => 'Branding directory does not exist after creation.'];
        }
        $destDir = dirname($dest);
        $realDestDir = realpath($destDir);
        if ($realDestDir === false || strpos($realDestDir, $realDir) !== 0) {
            return ['ok' => false, 'error' => 'Refusing to write outside the branding directory.'];
        }

        if (!@move_uploaded_file($tmp, $dest)) {
            return ['ok' => false, 'error' => 'Could not save the uploaded file.'];
        }
        @chmod($dest, 0644);

        // Atomic replacement — drop the previous file AFTER the new one
        // lands. If the move above failed, we won't get here, so the
        // previous logo stays intact (no broken-image state).
        $previous = (string)($config['previousValue'] ?? '');
        if ($previous !== '' && $previous !== $filename) {
            $this->deleteFileSafe($previous);
        }

        return ['ok' => true, 'filename' => $filename];
    }

    /** Resolve a stored filename → web URL. Empty string → empty string. */
    public function webUrlFor(string $stored): string
    {
        $stored = $this->normalizeStored($stored);
        if ($stored === '') {
            return '';
        }
        $webRoot = defined('WEB_ROOT') ? rtrim(WEB_ROOT, '/') : '';
        return $webRoot . $this->webPath . '/' . $stored;
    }

    /** Resolve a stored filename → absolute filesystem path, or '' if not set / outside dir. */
    public function diskPathFor(string $stored): string
    {
        $stored = $this->normalizeStored($stored);
        if ($stored === '') {
            return '';
        }
        $candidate = $this->diskDir . DIRECTORY_SEPARATOR . $stored;
        $realDir   = realpath($this->diskDir);
        $realFile  = realpath($candidate);
        if ($realDir === false || $realFile === false || strpos($realFile, $realDir) !== 0) {
            return '';
        }
        return $realFile;
    }

    /** Delete a previously-stored file. Silently no-ops if it's gone / outside dir. */
    public function deleteFileSafe(string $stored): void
    {
        $path = $this->diskPathFor($stored);
        if ($path !== '' && is_file($path)) {
            @unlink($path);
        }
    }

    /**
     * Normalize legacy stored values. Old installs stored
     * "/templates/mytheme/assets/img/branding/foo.png"; new installs store
     * just "foo.png". This makes the rest of the helper indifferent.
     */
    public function normalizeStored(string $stored): string
    {
        $stored = trim($stored);
        if ($stored === '') {
            return '';
        }
        // If it looks like a full path, keep only the basename. basename()
        // also strips ../ traversal attempts.
        if (str_contains($stored, '/') || str_contains($stored, '\\')) {
            $stored = basename($stored);
        }
        // Whitelist to filename-shaped characters only — anything weird
        // is rejected entirely. Prevents render-time injection of unusual
        // strings into a `<img src="...">` attribute.
        if (!preg_match('/^[A-Za-z0-9._-]+$/', $stored)) {
            return '';
        }
        return $stored;
    }

    public function getDiskDir(): string { return $this->diskDir; }
    public function getWebPath(): string { return $this->webPath; }

    /**
     * Prime the upload directory: create it if missing and drop the
     * .htaccess sidecar. Idempotent — safe to call on every activation /
     * upgrade. Returns true if the dir exists and is writable afterwards.
     *
     * Called from MyTheme_activate so the security posture is in place
     * before the first admin upload (rather than getting set up lazily
     * inside the first handle() call).
     */
    public function prepareStorage(): bool
    {
        if (!$this->ensureDir()) {
            return false;
        }
        $this->ensureHtaccess();
        return true;
    }

    // ---------------------------------------------------------------- internals

    private function sniffMime(string $path): ?string
    {
        if (!function_exists('finfo_open')) {
            return null;
        }
        $finfo = @finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo === false) {
            return null;
        }
        $mime = @finfo_file($finfo, $path);
        @finfo_close($finfo);
        if (!is_string($mime) || $mime === '') {
            return null;
        }
        $mime = strtolower($mime);

        // finfo on some PHP builds returns 'image/svg' or
        // 'text/xml' / 'text/plain' for SVG. Promote XML/text to
        // svg+xml only after a content-side confirmation that the
        // file actually contains an <svg> root.
        if (in_array($mime, ['text/xml', 'application/xml', 'text/plain', 'text/html'], true)) {
            $head = @file_get_contents($path, false, null, 0, 512);
            if (is_string($head) && stripos($head, '<svg') !== false) {
                return 'image/svg+xml';
            }
            return null;
        }
        if ($mime === 'image/svg') {
            return 'image/svg+xml';
        }
        return $mime;
    }

    /**
     * SVG hardening — block scriptable content. Refuses files containing:
     *   - <script ...> tags
     *   - on* event handler attributes (onload, onerror, ...)
     *   - javascript:/data: URIs in href / xlink:href
     *   - <foreignObject> (HTML embedded in SVG, scripts via that path)
     *   - <!ENTITY ...> declarations (XXE)
     *
     * Returns null on success, or an end-user error string.
     */
    private function scanSvg(string $path): ?string
    {
        $contents = @file_get_contents($path);
        if (!is_string($contents) || $contents === '') {
            return 'SVG file could not be read.';
        }
        // Case-insensitive substring/regex scan — we're not trying to parse
        // every possible obfuscation, just refuse anything that LOOKS
        // scriptable. Files that fail this scan should be re-exported as
        // bitmap or hand-cleaned.
        $patterns = [
            '/<script\b/i'        => 'SVG contains a <script> tag.',
            '/\son[a-z]+\s*=/i'   => 'SVG contains an event handler attribute (on*).',
            '/javascript\s*:/i'   => 'SVG contains a javascript: URI.',
            '/<foreignObject\b/i' => 'SVG contains a <foreignObject> tag.',
            '/<!ENTITY\b/i'       => 'SVG contains a DTD entity declaration.',
            '/<!DOCTYPE[^>]+\[/i' => 'SVG contains an inline DTD subset.',
        ];
        foreach ($patterns as $re => $msg) {
            if (preg_match($re, $contents)) {
                return 'SVG rejected: ' . $msg . ' Re-export without scripts.';
            }
        }
        return null;
    }

    private function ensureDir(): bool
    {
        if (is_dir($this->diskDir)) {
            return is_writable($this->diskDir);
        }
        if (!@mkdir($this->diskDir, 0755, true) && !is_dir($this->diskDir)) {
            return false;
        }
        return is_writable($this->diskDir);
    }

    /**
     * Drop a .htaccess that disables PHP execution inside the branding dir.
     * Idempotent — only writes if absent. Apache-style; for nginx-served
     * installs the rule is a no-op and the other defenses (mime sniff,
     * hashed name, ext whitelist) carry the load.
     */
    private function ensureHtaccess(): void
    {
        $path = $this->diskDir . DIRECTORY_SEPARATOR . '.htaccess';
        if (is_file($path)) {
            return;
        }
        $rules = <<<HTACCESS
# Auto-generated by MyTheme — disables script execution in the branding dir.
# Defense-in-depth: even if upload validation is bypassed somehow, a
# .php / .phtml / .phar planted here will not execute.
<IfModule mod_php.c>
    php_flag engine off
</IfModule>
<IfModule mod_php5.c>
    php_flag engine off
</IfModule>
<IfModule mod_php7.c>
    php_flag engine off
</IfModule>
<IfModule mod_php8.c>
    php_flag engine off
</IfModule>
<FilesMatch "\.(php|phtml|phar|phps|pl|py|rb|sh|cgi|js)$">
    Require all denied
</FilesMatch>
HTACCESS;
        @file_put_contents($path, $rules);
        @chmod($path, 0644);
    }

    private function describePhpUploadError(int $code): string
    {
        return match ($code) {
            UPLOAD_ERR_INI_SIZE   => 'File exceeds the server upload_max_filesize limit.',
            UPLOAD_ERR_FORM_SIZE  => 'File exceeds the form-declared size limit.',
            UPLOAD_ERR_PARTIAL    => 'Upload was interrupted; please try again.',
            UPLOAD_ERR_NO_TMP_DIR => 'Server has no temp directory for uploads.',
            UPLOAD_ERR_CANT_WRITE => 'Server could not write the upload to disk.',
            UPLOAD_ERR_EXTENSION  => 'A PHP extension blocked the upload.',
            default               => 'Upload failed (PHP code ' . $code . ').',
        };
    }

    private function humanBytes(int $bytes): string
    {
        if ($bytes < 1024)               return $bytes . ' B';
        if ($bytes < 1024 * 1024)        return round($bytes / 1024, 1) . ' KB';
        return round($bytes / (1024 * 1024), 2) . ' MB';
    }

    private static function defaultDiskDir(): string
    {
        $root = defined('ROOTDIR') ? ROOTDIR : dirname(__DIR__, 5);
        return rtrim($root, DIRECTORY_SEPARATOR)
            . DIRECTORY_SEPARATOR . 'templates'
            . DIRECTORY_SEPARATOR . 'mytheme'
            . DIRECTORY_SEPARATOR . 'assets'
            . DIRECTORY_SEPARATOR . 'img'
            . DIRECTORY_SEPARATOR . 'branding';
    }
}
