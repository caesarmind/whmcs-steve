<?php
/**
 * The media library: finding where an image is used, making one smaller,
 * and the names an admin gives them.
 *
 * Runs Hadrian's real MediaUsage, MediaOptimizer and MediaLibrary against a
 * temporary folder, with no WHMCS and no database. The folder stands in for
 * the WHMCS root (ROOTDIR), so the library lives under it exactly where it
 * does on a site.
 *
 *   php tests/static/test-media.php
 */

declare(strict_types=1);

namespace {
    use Hadrian\Helpers\MediaLibrary as L;
    use Hadrian\Helpers\MediaOptimizer as O;
    use Hadrian\Helpers\MediaUsage as U;

    $root = rtrim(str_replace('\\', '/', sys_get_temp_dir()), '/') . '/hadrian-media-test-' . bin2hex(random_bytes(4));
    define('ROOTDIR', $root);
    $dir = $root . '/templates/hadrian/assets/img/media';
    mkdir($dir, 0777, true);

    $src = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src';
    require $src . '/Models/Configuration.php';
    require $src . '/Helpers/Uploader.php';
    require $src . '/Helpers/MediaLibrary.php';
    require $src . '/Helpers/MediaOptimizer.php';
    require $src . '/Helpers/MediaUsage.php';

    $ok = 0;
    $fails = 0;
    $section = '';
    function same(string $label, mixed $got, mixed $want): void
    {
        global $ok, $fails, $section;
        if ($got === $want) {
            $ok++;
            return;
        }
        $fails++;
        echo "FAIL  [{$section}] {$label}\n      got:  " . json_encode($got) . "\n      want: " . json_encode($want) . "\n";
    }
    function truthy(string $label, bool $got): void
    {
        same($label, $got, true);
    }

    /** A picture with enough going on to compress like a photo. */
    function photo(int $w, int $h): GdImage
    {
        $im = imagecreatetruecolor($w, $h);
        mt_srand($w + $h);
        for ($i = 0; $i < 300; $i++) {
            imagefilledellipse($im, mt_rand(0, $w), mt_rand(0, $h), mt_rand(20, (int)($w / 2)), mt_rand(20, (int)($h / 2)),
                (int)imagecolorallocate($im, mt_rand(0, 255), mt_rand(0, 255), mt_rand(0, 255)));
        }
        return $im;
    }

    // ------------------------------------------------------------------
    $section = 'finding references';
    $a = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg';
    $b = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb.png';
    $c = 'cccccccccccccccccccccccccccccccc.webp';
    $base = '/templates/hadrian/assets/img/media/';

    same('a full address', U::namesIn('https://example.com' . $base . $a), [$a]);
    same('a root-relative one', U::namesIn('<img src="' . $base . $b . '">'), [$b]);
    same('an install in a subfolder', U::namesIn('https://example.com/billing' . $base . $a . '?v=2'), [$a]);
    same('JSON, where slashes are escaped', U::namesIn(json_encode(['image' => 'https://x.test' . $base . $c, 'alt' => 'x'])), [$c]);
    same('several, each once', U::namesIn($base . $a . ' ' . $base . $b . ' ' . $base . $a), [$a, $b]);
    same('inside CSS', U::namesIn('.hero{background:url(' . $base . $a . ')}'), [$a]);
    same('a name that only starts the same is another file', U::namesIn($base . 'photo.jpg.bak ' . $base . 'photo.jpgx'), []);
    same('the branding folder is not the library', U::namesIn('/templates/hadrian/assets/img/branding/' . $a), []);
    same('another theme\'s folder is not the library', U::namesIn('/templates/other/assets/img/media/' . $a), []);
    same('not an image', U::namesIn($base . '.htaccess ' . $base . 'x.php ' . $base . 'notes.txt'), []);
    same('no address at all', U::namesIn('just some text about media'), []);

    // ------------------------------------------------------------------
    $section = 'where each image is used';
    U::reset();
    U::register('pages', static fn (): array => [
        ['where' => 'Built page "Home"', 'url' => '?module=HadrianBuilder&action=edit&id=3', 'text' => json_encode(['hero' => $base . $a])],
        ['where' => 'Built page "About"', 'url' => '?module=HadrianBuilder&action=edit&id=4', 'text' => $base . $a . ' ' . $base . $b],
        ['where' => 'Built page "Empty"', 'url' => '?module=HadrianBuilder&action=edit&id=5', 'text' => ''],
    ]);
    U::register('email', static fn (): array => [
        ['where' => 'Email layout', 'url' => 'https://evil.test/', 'text' => $base . $b],
        ['where' => '', 'url' => '', 'text' => $base . $c],
        'not a row',
    ]);
    U::register('broken', static function (): array { throw new \RuntimeException('table missing'); });
    U::register('Not A Slug', static fn (): array => [['where' => 'x', 'url' => '', 'text' => $base . $c]]);

    $prev = ini_set('error_log', $root . '/php-errors.log');     // the broken source is logged, not shown
    $map = U::map();
    ini_set('error_log', (string)$prev);
    same('an image used on two pages lists both', array_column($map[$a] ?? [], 'where'), ['Built page "Home"', 'Built page "About"']);
    same('one used by two modules lists both', array_column($map[$b] ?? [], 'where'), ['Built page "About"', 'Email layout']);
    same('a link that is not into the admin is dropped, the place stays', $map[$b][1]['url'] ?? null, '');
    same('a link into the admin is kept', $map[$a][0]['url'] ?? null, '?module=HadrianBuilder&action=edit&id=3');
    same('a place with no name, and a source with a bad id, report nothing', isset($map[$c]), false);
    same('a source that throws does not take the others with it', count($map), 2);
    same('of() answers for the names asked about', array_keys(U::of([$b, $c, 'never-uploaded.png'])), [$b]);
    U::register('pages', static fn (): array => []);
    same('registering a source again replaces it', array_keys(U::map()), [$b]);
    U::reset();
    same('with no sources nothing is in use', U::map(), []);

    // ------------------------------------------------------------------
    $section = 'names';
    same('a typed name is trimmed and single-spaced', L::cleanLabel("  Hero   image\t one \n"), 'Hero image one');
    same('control characters go', L::cleanLabel("Logo\x00\x07 dark"), 'Logo dark');
    same('it is capped', strlen(L::cleanLabel(str_repeat('x', 200))), 80);
    same('an upload name loses its path and extension', L::labelFromUpload('C:\\Users\\me\\Pictures\\team photo.JPG'), 'team photo');

    file_put_contents($dir . '/' . $a, 'x');
    L::remember('library', $a, 'first name', 800, 600);
    L::patch('library', $a, ['label' => 'second name']);
    $entry = L::manifest('library')[$a] ?? [];
    same('renaming keeps the size that was recorded', [$entry['label'] ?? null, $entry['w'] ?? null, $entry['h'] ?? null], ['second name', 800, 600]);
    L::patch('library', $b, ['label' => 'came by FTP']);
    same('a file with no entry gets one', L::manifest('library')[$b]['label'] ?? null, 'came by FTP');
    L::forget('library', $a);
    same('forgetting one leaves the other', array_keys(L::manifest('library')), [$b]);
    unlink($dir . '/' . $a);

    // ------------------------------------------------------------------
    $section = 'optimising';
    if (!O::available()) {
        echo "SKIP  optimising: this PHP has no GD\n";
    } else {
        // A large photo: scaled to the longest edge, clearly smaller, original kept.
        $big = $dir . '/big.jpg';
        imagejpeg(photo(3200, 1800), $big, 97);
        $before = filesize($big);
        $r = O::optimize($big);
        clearstatcache();
        same('a large JPEG is optimised', $r['status'], 'optimized');
        same('and scaled to the longest edge allowed', [$r['width'], $r['height']], [O::MAX_EDGE, 1440]);
        same('the file on disk has the new size', array_slice((array)getimagesize($big), 0, 2), [O::MAX_EDGE, 1440]);
        truthy('it is at least a quarter smaller', filesize($big) < $before * 0.75);
        same('the report matches the disk', [$r['before'], $r['after']], [$before, filesize($big)]);
        same('the original is set aside, untouched', O::originalBytes($big), $before);
        truthy('in a folder the library never lists', is_file($dir . '/' . O::ORIGINALS . '/big.jpg'));
        same('no working file is left behind', glob($dir . '/.opt-*') ?: [], []);

        same('a second pass leaves it alone', O::optimize($big)['status'], 'kept');
        clearstatcache();
        same('and does not disturb the original', O::originalBytes($big), $before);

        truthy('restore puts the upload back', O::restore($big));
        clearstatcache();
        same('byte for byte the same size', filesize($big), $before);
        same('and the original is no longer set aside', O::hasOriginal($big), false);
        same('restoring twice is refused', O::restore($big), false);

        // A PNG with transparency keeps it.
        $png = $dir . '/logo.png';
        $im = imagecreatetruecolor(400, 200);
        imagealphablending($im, false);
        imagesavealpha($im, true);
        imagefill($im, 0, 0, (int)imagecolorallocatealpha($im, 0, 0, 0, 127));
        imagefilledrectangle($im, 50, 50, 350, 150, (int)imagecolorallocate($im, 0, 113, 227));
        imagepng($im, $png, 0);
        $r = O::optimize($png);
        same('an uncompressed PNG is optimised', $r['status'], 'optimized');
        same('and not scaled', [$r['width'], $r['height']], [400, 200]);
        $back = imagecreatefrompng($png);
        same('its transparent corner is still transparent', (imagecolorat($back, 0, 0) >> 24) & 0x7F, 127);
        same('and its colour is exact (PNG is lossless)', imagecolorat($back, 200, 100) & 0xFFFFFF, 0x0071E3);

        // Already small: nothing to gain, nothing changes.
        $small = $dir . '/small.jpg';
        imagejpeg(photo(300, 200), $small, 60);
        $sum = md5_file($small);
        same('an already small JPEG is kept', O::optimize($small)['status'], 'kept');
        same('untouched', md5_file($small), $sum);
        same('with no original set aside', O::hasOriginal($small), false);

        // Left alone, with a reason an admin can read.
        $gif = $dir . '/anim.gif';
        $g = imagecreate(50, 50);
        imagecolorallocate($g, 255, 0, 0);
        imagegif($g, $gif);
        $r = O::optimize($gif);
        same('a GIF is skipped', [$r['status'], str_contains($r['reason'], 'GIF')], ['skipped', true]);

        $apng = $dir . '/apng.png';
        $bytes = (string)file_get_contents($png);
        $at = strpos($bytes, 'IDAT') - 4;           // an acTL chunk before the image data marks an animation
        file_put_contents($apng, substr($bytes, 0, $at) . pack('N', 8) . 'acTL' . str_repeat("\0", 12) . substr($bytes, $at));
        same('an animated PNG is skipped', O::optimize($apng)['status'], 'skipped');

        // Colour profiles. What decides is the profile's primaries, not its
        // name: Chrome writes an sRGB profile whose name is UTF-16, which a
        // search for "sRGB" misses, and that made every screenshot and every
        // canvas export "not optimisable".
        $withProfile = static function (string $file, array $r, array $g, array $b, string $space = 'RGB ') use ($dir): string {
            $fixed = static fn (float $v): string => pack('N', (int)round($v * 65536) & 0xFFFFFFFF);
            $xyz   = static fn (array $c): string => 'XYZ ' . "\0\0\0\0" . $fixed($c[0]) . $fixed($c[1]) . $fixed($c[2]);
            $tags  = ['rXYZ' => $xyz($r), 'gXYZ' => $xyz($g), 'bXYZ' => $xyz($b)];
            $table = pack('N', count($tags));
            $data  = '';
            $at    = 128 + 4 + 12 * count($tags);
            foreach ($tags as $sig => $body) {
                $table .= $sig . pack('N2', $at + strlen($data), strlen($body));
                $data  .= $body;
            }
            $header  = str_pad(str_repeat("\0", 16) . $space, 128, "\0");
            $profile = $header . $table . $data;
            $app2    = "ICC_PROFILE\0\1\1" . $profile;
            $path    = $dir . '/' . $file;
            imagejpeg(photo(1200, 800), $path, 95);
            $bytes = (string)file_get_contents($path);
            file_put_contents($path, substr($bytes, 0, 2) . "\xFF\xE2" . pack('n', strlen($app2) + 2) . $app2 . substr($bytes, 2));
            return $path;
        };
        $srgb = [[0.4361, 0.2225, 0.0139], [0.3851, 0.7169, 0.0971], [0.1431, 0.0606, 0.7141]];
        $p3   = [[0.5151, 0.2412, -0.0011], [0.2920, 0.6922, 0.0419], [0.1571, 0.0666, 0.7841]];

        $tagged = $withProfile('srgb-tagged.jpg', ...$srgb);
        truthy('(the test profile is really in the file)', str_contains((string)file_get_contents($tagged), "ICC_PROFILE\0"));
        same('a JPEG tagged with an sRGB profile is optimised', O::optimize($tagged)['status'], 'optimized');

        $r = O::optimize($withProfile('profile.jpg', ...$p3));
        same('one tagged Display P3 is skipped', [$r['status'], str_contains($r['reason'], 'colour profile')], ['skipped', true]);
        same('so is CMYK, whatever its numbers', O::optimize($withProfile('cmyk.jpg', $srgb[0], $srgb[1], $srgb[2], 'CMYK'))['status'], 'skipped');
        $garbled = $dir . '/garbled.jpg';
        imagejpeg(photo(1200, 800), $garbled, 95);
        $bytes = (string)file_get_contents($garbled);
        $app2  = "ICC_PROFILE\0\1\1" . 'not a profile';
        file_put_contents($garbled, substr($bytes, 0, 2) . "\xFF\xE2" . pack('n', strlen($app2) + 2) . $app2 . substr($bytes, 2));
        same('and a profile that cannot be read', O::optimize($garbled)['status'], 'skipped');

        same('a missing file is skipped', O::optimize($dir . '/nope.jpg')['status'], 'skipped');
        file_put_contents($dir . '/text.jpg', 'this is not an image');
        same('so is a file that is not an image', O::optimize($dir . '/text.jpg')['status'], 'skipped');

        // Deleting an image takes its original with it.
        imagejpeg(photo(3000, 2000), $big, 97);
        O::optimize($big);
        truthy('(an optimised image again)', O::hasOriginal($big));
        O::forget($big);
        same('forget() removes the original', O::hasOriginal($big), false);

        // The two things an admin can set: quality and the largest size.
        $sized = static function (string $file, int $quality, int $edge) use ($dir): array {
            $path = $dir . '/' . $file;
            imagejpeg(photo(3000, 2000), $path, 97);
            return O::optimize($path, $quality, $edge) + ['bytes' => (int)filesize($path)];
        };
        $high  = $sized('q-high.jpg', 90, 2560);
        $small = $sized('q-small.jpg', 70, 2560);
        same('both qualities optimise', [$high['status'], $small['status']], ['optimized', 'optimized']);
        truthy('a lower quality gives a smaller file', $small['after'] < $high['after'] * 0.9);
        same('a smaller largest size scales further', array_slice($sized('edge-1600.jpg', 82, 1600), 4, 2), ['width' => 1600, 'height' => 1067]);
        same('"do not resize" keeps the image\'s own size', array_slice($sized('edge-none.jpg', 82, 0), 4, 2), ['width' => 3000, 'height' => 2000]);
        same('an image under the limit is never enlarged', array_slice($sized('edge-4k.jpg', 82, 3840), 4, 2), ['width' => 3000, 'height' => 2000]);
        same('a nonsense quality is pulled into range, not obeyed', $sized('q-zero.jpg', 0, 2560)['status'], 'optimized');
        truthy('(and still decodes)', getimagesize($dir . '/q-zero.jpg') !== false);
        foreach (['q-high', 'q-small', 'edge-1600', 'edge-none', 'edge-4k', 'q-zero'] as $f) {
            O::forget($dir . '/' . $f . '.jpg');
            unlink($dir . '/' . $f . '.jpg');
        }

        // The choices offered are the only values that can be stored.
        same('the default quality is one of the choices', isset(L::QUALITIES[O::QUALITY]), true);
        same('the default size is one of the choices', isset(L::MAX_EDGES[O::MAX_EDGE]), true);
        same('with no settings table the defaults apply', [L::quality(), L::maxEdge()], [O::QUALITY, O::MAX_EDGE]);

        // The library lists none of the working folders or files.
        $names = array_column(L::uploaderFor('library')->listStored(0), 'name');
        sort($names);
        same('the library lists images only', $names, ['anim.gif', 'apng.png', 'big.jpg', 'cmyk.jpg', 'garbled.jpg', 'logo.png', 'profile.jpg', 'small.jpg', 'srgb-tagged.jpg', 'text.jpg']);
    }

    // ------------------------------------------------------------------
    // An image that arrives inside a file (an imported page brings its
    // pictures) is checked exactly like an upload, and stored once.
    if (function_exists('imagecreatetruecolor') && function_exists('finfo_open')) {
        $section = 'images that arrive in a file';
        $up  = L::uploaderFor('library');
        $cfg = ['allowedMimes' => \Hadrian\Helpers\Uploader::IMAGE_MEDIA, 'maxBytes' => 5 * 1024 * 1024, 'maxPixels' => 50000000];
        $in  = $root . '/incoming';
        mkdir($in);
        $count = static fn (): int => count($up->listStored(0));
        $before = $count();

        imagepng(imagecreatetruecolor(40, 30), $in . '/whatever.dat');
        $r = $up->ingest($in . '/whatever.dat', $cfg);
        truthy('a real image is stored', !empty($r['ok']));
        truthy('under a name of our own, with the extension of what it is', (bool)preg_match('/^[a-f0-9]{32}\.png$/', (string)($r['filename'] ?? '')));
        truthy('the file it came from stays where it was', is_file($in . '/whatever.dat'));
        truthy('the folder got its no-scripts rule', is_file($dir . '/.htaccess'));

        file_put_contents($in . '/shell.png', '<?php echo "x";');
        same('a script named like an image is refused', $up->ingest($in . '/shell.png', $cfg)['ok'], false);
        file_put_contents($in . '/drawing.png', '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>');
        same('an SVG is refused: the library is raster only', $up->ingest($in . '/drawing.png', $cfg)['ok'], false);
        same('a file that is not there is refused', $up->ingest($in . '/nope.png', $cfg)['ok'], false);
        same('one over the size limit is refused', $up->ingest($in . '/whatever.dat', ['maxBytes' => 10] + $cfg)['ok'], false);
        same('one with too many pixels is refused', $up->ingest($in . '/whatever.dat', ['maxPixels' => 100] + $cfg)['ok'], false);
        same('only the one good file was written', $count(), $before + 1);

        imagepng(photo(60, 40), $in . '/team.png');
        $a1 = L::add($in . '/team.png', "Team   photo\x01");
        truthy('add() stores it', !empty($a1['ok']) && empty($a1['reused']));
        $stored = (string)($a1['name'] ?? '');
        same('with the address the image picker would give', $a1['url'] ?? '', '/templates/hadrian/assets/img/media/' . $stored);
        same('and its label and size on record', array_intersect_key(L::manifest('library')[$stored] ?? [], ['label' => 1, 'w' => 1, 'h' => 1]), ['label' => 'Team photo', 'w' => 60, 'h' => 40]);
        $a2 = L::add($in . '/team.png', 'Again');
        same('the same image a second time is the first one', [$a2['name'] ?? '', $a2['reused'] ?? null], [$stored, true]);
        same('(and keeps the name it was given)', L::manifest('library')[$stored]['label'] ?? '', 'Team photo');
        // Optimising rewrites the stored file; the image is still known by
        // what it was when it arrived.
        imagepng(photo(60, 41), $dir . '/' . $stored);
        clearstatcache();
        $a3 = L::add($in . '/team.png', 'Again');
        same('also after the stored copy was made smaller', [$a3['name'] ?? '', $a3['reused'] ?? null], [$stored, true]);
        same('what is not an image is not added', L::add($in . '/shell.png', 'x')['ok'], false);
        same('nor a file that is not there', L::add($in . '/nope.png', 'x')['ok'], false);

        same('file() says where an image is and what it is called', [is_file((string)(L::file($stored)['path'] ?? '')), L::file($stored)['label'] ?? ''], [true, 'Team photo']);
        same('and nothing for a name that is not a library image', [L::file('.htaccess'), L::file('../' . $stored), L::file('never.png')], [null, null, null]);
    }

    // ------------------------------------------------------------------
    // Clean up the temporary root.
    $it = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($root, \FilesystemIterator::SKIP_DOTS), \RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($it as $f) {
        $f->isDir() ? @rmdir($f->getPathname()) : @unlink($f->getPathname());
    }
    @rmdir($root);

    echo $fails === 0 ? "{$ok} checks passed\n" : "{$fails} of " . ($ok + $fails) . " checks FAILED\n";
    exit($fails === 0 ? 0 : 1);
}
