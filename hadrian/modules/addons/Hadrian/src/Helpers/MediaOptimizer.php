<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Makes a library image smaller without the admin having to think about it.
 *
 * Two things, in one pass:
 *   - an image wider or taller than MAX_EDGE is scaled down to it. Nothing on
 *     a client page is drawn larger than that, even on a 2x display.
 *   - the image is written again: JPEG and WebP at QUALITY, PNG at the
 *     strongest lossless level.
 *
 * The result replaces the file only when it is clearly smaller (KEEP_BELOW).
 * The file keeps its name, so every page, email and menu that points at it
 * keeps working, and the untouched upload is moved to ORIGINALS so "Restore
 * original" can put it back.
 *
 * What is deliberately left alone, and reported as skipped with the reason:
 *   - GIF, animated PNG and animated WebP: GD keeps one frame only
 *   - lossless WebP: writing it lossy would be a quality loss nobody chose
 *   - a JPEG with a colour profile other than sRGB (Display P3, Adobe RGB,
 *     CMYK): GD drops the profile and the colours would shift
 *   - a JPEG that needs its EXIF rotation and a PHP without the exif
 *     extension to read it
 *   - anything that would not fit in PHP's memory once decoded
 *
 * GD only. WHMCS itself requires GD, so it is there wherever this runs;
 * available() says so when it is not.
 */
final class MediaOptimizer
{
    /**
     * Default JPEG and WebP quality. Visually clean at normal sizes, about
     * half the bytes of 95. The admin can pick another on the Media screen.
     */
    public const QUALITY = 82;

    /** Default longest edge, in pixels, an optimised image keeps. */
    public const MAX_EDGE = 2560;

    /** The result must be at most this share of the original to replace it. */
    private const KEEP_BELOW = 0.95;

    /** Folder inside the library that holds the untouched uploads. Dot-named: never listed. */
    public const ORIGINALS = '.originals';

    public static function available(): bool
    {
        return extension_loaded('gd')
            && function_exists('imagecreatefromjpeg')
            && function_exists('imagecreatefrompng')
            && function_exists('imagecreatetruecolor');
    }

    /**
     * Optimise the image at $path in place.
     *
     * @return array{status: 'optimized'|'kept'|'skipped', reason: string, before: int, after: int, width: int, height: int}
     *         optimized  the file is smaller now and the original is kept aside
     *         kept       already as small as this can make it; nothing changed
     *         skipped    not attempted; `reason` says why, in words for the admin
     */
    public static function optimize(string $path, int $quality = self::QUALITY, int $maxEdge = self::MAX_EDGE): array
    {
        // What the admin chose on the Media screen (MediaLibrary::quality(),
        // ::maxEdge()). Kept inside what makes sense whatever is passed: a
        // quality under 40 is visibly broken, and 0 for the edge means
        // "do not scale".
        $quality = max(40, min(95, $quality));
        $maxEdge = $maxEdge <= 0 ? 0 : max(320, $maxEdge);
        $before = is_file($path) ? (int)@filesize($path) : 0;
        $out = static fn(string $status, string $reason = '', int $after = 0, int $w = 0, int $h = 0): array => [
            'status' => $status, 'reason' => $reason, 'before' => $before,
            'after'  => $after > 0 ? $after : $before, 'width' => $w, 'height' => $h,
        ];

        if ($before <= 0) {
            return $out('skipped', 'The file is missing.');
        }
        if (!self::available()) {
            return $out('skipped', 'This server has no GD image library.');
        }
        if (self::hasOriginal($path)) {
            return $out('kept', 'Already optimised.');
        }
        $info = @getimagesize($path);
        if ($info === false) {
            return $out('skipped', 'Not a readable image.');
        }
        [$w, $h] = [(int)$info[0], (int)$info[1]];
        $mime = (string)($info['mime'] ?? '');
        if ($w < 1 || $h < 1) {
            return $out('skipped', 'Not a readable image.');
        }

        $head = (string)@file_get_contents($path, false, null, 0, 262144);
        $why  = self::leaveAlone($mime, $head, $path);
        if ($why !== '') {
            return $out('skipped', $why, 0, $w, $h);
        }
        if (!self::fitsInMemory($w, $h, $maxEdge)) {
            return $out('skipped', 'Too large to process on this server (' . $w . ' x ' . $h . ').', 0, $w, $h);
        }

        $src = match ($mime) {
            'image/jpeg' => @imagecreatefromjpeg($path),
            'image/png'  => @imagecreatefrompng($path),
            'image/webp' => @imagecreatefromwebp($path),
            default      => false,
        };
        if ($src === false) {
            return $out('skipped', 'The image could not be decoded.', 0, $w, $h);
        }

        if ($mime === 'image/jpeg') {
            $src = self::upright($src, $path);
            [$w, $h] = [imagesx($src), imagesy($src)];
        }

        [$nw, $nh] = self::fit($w, $h, $maxEdge);
        $resized   = $nw !== $w || $nh !== $h;
        if ($resized) {
            $dst = imagecreatetruecolor($nw, $nh);
            if ($mime !== 'image/jpeg') {
                imagealphablending($dst, false);
                imagesavealpha($dst, true);
                imagefill($dst, 0, 0, (int)imagecolorallocatealpha($dst, 0, 0, 0, 127));
            }
            imagecopyresampled($dst, $src, 0, 0, 0, 0, $nw, $nh, $w, $h);
            imagedestroy($src);
            $src = $dst;
        } elseif ($mime !== 'image/jpeg') {
            imagealphablending($src, false);
            imagesavealpha($src, true);
        }

        // Written beside the target and renamed over it, so a failure halfway
        // leaves the library exactly as it was. Dot-named: never listed.
        $tmp = dirname($path) . DIRECTORY_SEPARATOR . '.opt-' . bin2hex(random_bytes(6));
        if ($mime === 'image/jpeg') {
            imageinterlace($src, true);          // progressive: usually a little smaller, paints sooner
        }
        $written = match ($mime) {
            'image/jpeg' => @imagejpeg($src, $tmp, $quality),
            'image/png'  => @imagepng($src, $tmp, 9),
            'image/webp' => @imagewebp($src, $tmp, $quality),
            default      => false,
        };
        imagedestroy($src);
        $after = $written ? (int)@filesize($tmp) : 0;
        if ($after <= 0) {
            @unlink($tmp);
            return $out('skipped', 'The image could not be written.', 0, $w, $h);
        }
        if ($after > $before * self::KEEP_BELOW) {
            @unlink($tmp);
            return $out('kept', 'Already as small as it gets.', 0, $w, $h);
        }

        $orig = self::originalPath($path);
        if (!self::ensureOriginalsDir(dirname($orig)) || !@rename($path, $orig)) {
            @unlink($tmp);
            return $out('skipped', 'The original could not be set aside. Check the folder permissions.', 0, $w, $h);
        }
        if (!@rename($tmp, $path)) {
            @rename($orig, $path);               // put the upload back where it was
            @unlink($tmp);
            return $out('skipped', 'The optimised image could not be saved.', 0, $w, $h);
        }
        @chmod($path, 0644);
        return $out('optimized', $resized ? 'Scaled to ' . $nw . ' x ' . $nh . '.' : '', $after, $nw, $nh);
    }

    /** Put the untouched upload back. False when there is none. */
    public static function restore(string $path): bool
    {
        $orig = self::originalPath($path);
        if (!is_file($orig)) {
            return false;
        }
        // The optimised file is replaced, not deleted first: rename() over an
        // existing file fails on Windows, so remove it only once the original
        // is known to be readable.
        $tmp = $path . '.restore';
        if (!@copy($orig, $tmp)) {
            return false;
        }
        @unlink($path);
        if (!@rename($tmp, $path)) {
            @unlink($tmp);
            return false;
        }
        @unlink($orig);
        @chmod($path, 0644);
        return true;
    }

    public static function hasOriginal(string $path): bool
    {
        return is_file(self::originalPath($path));
    }

    /** Size of the untouched upload, 0 when the image was never optimised. */
    public static function originalBytes(string $path): int
    {
        $orig = self::originalPath($path);
        return is_file($orig) ? (int)@filesize($orig) : 0;
    }

    /** The image is being deleted: its set-aside original goes with it. */
    public static function forget(string $path): void
    {
        $orig = self::originalPath($path);
        if (is_file($orig)) {
            @unlink($orig);
        }
    }

    // ------------------------------------------------------------ internals

    private static function originalPath(string $path): string
    {
        return dirname($path) . DIRECTORY_SEPARATOR . self::ORIGINALS . DIRECTORY_SEPARATOR . basename($path);
    }

    private static function ensureOriginalsDir(string $dir): bool
    {
        return is_dir($dir) || @mkdir($dir, 0755, true) || is_dir($dir);
    }

    /** Why this image must not be re-encoded, or '' when it may be. */
    private static function leaveAlone(string $mime, string $head, string $path): string
    {
        if ($mime === 'image/gif') {
            return 'GIF images are left as they are, so an animation keeps playing.';
        }
        if ($mime === 'image/png') {
            $idat = strpos($head, 'IDAT');
            $actl = strpos($head, 'acTL');
            if ($actl !== false && ($idat === false || $actl < $idat)) {
                return 'Animated PNG is left as it is.';
            }
            return '';
        }
        if ($mime === 'image/webp') {
            if (!function_exists('imagewebp') || !function_exists('imagecreatefromwebp')) {
                return 'This server cannot write WebP.';
            }
            if (str_contains(substr($head, 0, 4096), 'ANIM')) {
                return 'Animated WebP is left as it is.';
            }
            if (substr($head, 12, 4) === 'VP8L' || str_contains(substr($head, 0, 64), 'VP8L')) {
                return 'Lossless WebP is left as it is.';
            }
            return '';
        }
        if ($mime === 'image/jpeg') {
            if (str_contains($head, "ICC_PROFILE\0") && !self::profileIsSrgb($head)) {
                return 'It carries a colour profile that would be lost.';
            }
            if (str_contains($head, "Exif\0\0") && !function_exists('exif_read_data')) {
                return 'This server cannot read the photo\'s rotation (no exif extension).';
            }
            return '';
        }
        return 'This format is not optimised.';
    }

    /**
     * Is the JPEG's embedded colour profile plain sRGB? Then dropping it
     * changes nothing: a browser treats an untagged image as sRGB.
     *
     * Decided by the profile's red, green and blue primaries, not by its
     * name. Names cannot be trusted either way: browsers and phones write
     * sRGB profiles whose description is stored as UTF-16, or says "c2", or
     * is a vendor's own wording. The numbers are the D50-adapted sRGB
     * primaries every such profile carries.
     *
     * Anything it cannot read is "not sRGB": the image is then left alone.
     */
    private static function profileIsSrgb(string $head): bool
    {
        $at = strpos($head, "ICC_PROFILE\0");
        if ($at === false || $at < 4) {
            return false;
        }
        // APP2 payload: "ICC_PROFILE\0", chunk number, chunk count, profile.
        // A profile split over several chunks is far larger than sRGB's.
        if (ord($head[$at + 13] ?? "\2") !== 1) {
            return false;
        }
        $len     = (int)(unpack('n', substr($head, $at - 2, 2))[1] ?? 0);
        $profile = substr($head, $at + 14, max(0, $len - 16));
        if (strlen($profile) < 132 || substr($profile, 16, 4) !== 'RGB ') {
            return false;
        }
        $want  = ['rXYZ' => [0.4361, 0.2225, 0.0139], 'gXYZ' => [0.3851, 0.7169, 0.0971], 'bXYZ' => [0.1431, 0.0606, 0.7141]];
        $found = 0;
        $count = min(64, (int)(unpack('N', substr($profile, 128, 4))[1] ?? 0));
        for ($i = 0; $i < $count; $i++) {
            $tag = substr($profile, 132 + $i * 12, 12);
            $sig = substr($tag, 0, 4);
            if (strlen($tag) < 12 || !isset($want[$sig])) {
                continue;
            }
            $xyz = substr($profile, (int)unpack('N', substr($tag, 4, 4))[1] + 8, 12);
            if (strlen($xyz) < 12) {
                return false;
            }
            foreach (array_values(unpack('N3', $xyz)) as $k => $raw) {
                $value = ($raw >= 0x80000000 ? $raw - 0x100000000 : $raw) / 65536;
                if (abs($value - $want[$sig][$k]) > 0.006) {
                    return false;
                }
            }
            $found++;
        }
        return $found === 3;
    }

    /**
     * Turn a photo the way its EXIF orientation says, because re-encoding
     * drops that tag and the image would otherwise come out on its side.
     */
    private static function upright(\GdImage $img, string $path): \GdImage
    {
        if (!function_exists('exif_read_data')) {
            return $img;
        }
        $exif = @exif_read_data($path);
        $o    = is_array($exif) ? (int)($exif['Orientation'] ?? 1) : 1;
        // 2 and 4 are mirror images; 5 and 7 are a mirror plus a quarter turn
        // (flip first, then turn clockwise). imagerotate() turns
        // anticlockwise, so clockwise is -90.
        if (in_array($o, [2, 4, 5, 7], true)) {
            imageflip($img, in_array($o, [2, 7], true) ? IMG_FLIP_HORIZONTAL : IMG_FLIP_VERTICAL);
        }
        $angle = match ($o) { 3 => 180, 5, 6, 7 => -90, 8 => 90, default => 0 };
        if ($angle !== 0) {
            $turned = imagerotate($img, $angle, 0);
            if ($turned !== false) {
                imagedestroy($img);
                return $turned;
            }
        }
        return $img;
    }

    /** @return array{0:int,1:int} the size after scaling the longest edge to $maxEdge (0: as it is) */
    private static function fit(int $w, int $h, int $maxEdge): array
    {
        $long = max($w, $h);
        if ($maxEdge <= 0 || $long <= $maxEdge) {
            return [$w, $h];
        }
        $k = $maxEdge / $long;
        return [max(1, (int)round($w * $k)), max(1, (int)round($h * $k))];
    }

    /**
     * Would decoding (and, when it is scaled, a second canvas) fit in what
     * PHP has left? A failed allocation in GD is a fatal error, not something
     * to catch, so this is asked first.
     */
    private static function fitsInMemory(int $w, int $h, int $maxEdge): bool
    {
        $limit = self::bytes((string)ini_get('memory_limit'));
        if ($limit <= 0) {
            return true;                         // -1: no limit
        }
        [$nw, $nh] = self::fit($w, $h, $maxEdge);
        // ~5 bytes a pixel for a truecolour GD canvas, with headroom.
        $need = (int)(($w * $h + $nw * $nh) * 5 * 1.3);
        return $need < $limit - memory_get_usage(true) - 8 * 1024 * 1024;
    }

    private static function bytes(string $ini): int
    {
        $ini = trim($ini);
        if ($ini === '' || $ini === '-1') {
            return -1;
        }
        $n = (int)$ini;
        return match (strtolower(substr($ini, -1))) {
            'g' => $n * 1024 * 1024 * 1024,
            'm' => $n * 1024 * 1024,
            'k' => $n * 1024,
            default => $n,
        };
    }
}
