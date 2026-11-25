<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Turns the pages in a pages file (PageFile) into pages on this site.
 *
 * In two steps, so nothing is written before the admin has seen what the
 * file would do:
 *
 *   review()  reads only. For each page in the file: how many sections it
 *             brings, what will not come across (a section type this site
 *             does not have, a language it does not offer, a product it does
 *             not sell, an image that is missing), and which pages here it
 *             could be mistaken for (same address or same name).
 *   run()     does what the admin chose for each page: add it as a new page,
 *             put its sections in an existing page, or leave it out.
 *
 * What an import can never do:
 *
 *   - Change what visitors see. A new page is a draft. Putting the sections
 *     in an existing page writes that page's draft only; its published copy
 *     keeps being served until someone publishes.
 *   - Take over a theme page. "Replaces" in the file is shown, not applied.
 *   - Store anything the editor could not have stored. Every section goes
 *     through Document::normalize(), the same gate as a save, and every image
 *     through the media library's upload checks.
 *
 * A product in the file is the id it had on the site it came from, which
 * means nothing here. It is matched to this site's product of the same name;
 * with no match the field is emptied, never left pointing at whatever product
 * happens to have that number.
 */
final class Importer
{
    public const NEW  = 'new';
    public const SKIP = 'skip';

    // --------------------------------------------------------------- review

    /**
     * @param array<string,mixed> $manifest as PageFile::read() returns it
     * @param list<array<string,mixed>> $existing this site's pages (id, name, slug)
     * @param array<string,true> $mediaInFile image names the file really holds
     * @return list<array<string,mixed>> one report per page in the file:
     *         index, name, slug, status, replaces,
     *         sections   how many will be imported
     *         unknown    section type => how many, for types this site lacks
     *         over       sections past the limit of a page, dropped
     *         images     library images that come with the file
     *         missing    images the page names that are not in the file
     *         linked     images that are plain web addresses, kept as typed
     *         products   names of products this site has no match for
     *         languages  languages with text in the file that are not installed here
     *         matches    list of {id, name, slug, why: "address"|"name"}: pages here it resembles
     */
    public static function review(array $manifest, array $existing, array $mediaInFile, Site $site): array
    {
        $languages  = $site->languages();
        $productMap = self::products($manifest, $site);
        $types      = Sections::types();
        $out        = [];

        foreach ($manifest['pages'] as $index => $page) {
            $unknown = [];
            $known   = 0;
            foreach ((array)($page['doc']['sections'] ?? []) as $section) {
                $type = is_array($section) && is_scalar($section['type'] ?? null) ? (string)$section['type'] : '';
                if (isset($types[$type])) {
                    $known++;
                    continue;
                }
                $label = Text::line((string)preg_replace('/[^A-Za-z0-9 _-]/', '', $type), 40) ?: 'unnamed';
                $unknown[$label] = ($unknown[$label] ?? 0) + 1;
            }
            $max = Document::maxSections();

            $images   = [];
            $missing  = [];
            $linked   = 0;
            $products = [];
            $dropped  = [];
            $note = static function (mixed $value) use ($languages, &$dropped): void {
                foreach (is_array($value) ? array_keys($value) : [] as $lang) {
                    $lang = strtolower((string)$lang);
                    if ($lang !== '_' && preg_match('/^[a-z][a-z0-9_-]{1,40}$/', $lang) && !in_array($lang, $languages, true)
                        && is_scalar($value[$lang]) && trim((string)$value[$lang]) !== '') {
                        $dropped[$lang] = true;
                    }
                }
            };
            Document::walk($page['doc'], static function (array $f, mixed $value) use ($manifest, $mediaInFile, $productMap, $note, &$images, &$missing, &$linked, &$products): mixed {
                if ($f['type'] === 'image' && is_string($value) && $value !== '') {
                    $name = self::mediaName($value);
                    if ($name === '') {
                        $linked++;
                    } elseif (isset($manifest['media'][$name], $mediaInFile[$name])) {
                        $images[$name] = true;
                    } else {
                        $missing[$name] = true;
                    }
                }
                if ($f['type'] === 'product' && is_numeric($value) && (int)$value > 0 && ($productMap[(int)$value] ?? 0) === 0) {
                    $products[(int)$value] = $manifest['products'][(int)$value]['name'] ?? '';
                }
                if (!empty($f['translatable'])) {
                    $note($value);
                }
                return $value;
            });
            $note($page['meta']['title'] ?? null);
            $note($page['meta']['description'] ?? null);

            $matches = [];
            foreach ($existing as $row) {
                $why = match (true) {
                    $page['slug'] !== '' && (string)$row['slug'] === $page['slug'] => 'address',
                    self::fold((string)$row['name']) === self::fold($page['name']) => 'name',
                    default => '',
                };
                if ($why !== '') {
                    $matches[] = ['id' => (int)$row['id'], 'name' => (string)$row['name'], 'slug' => (string)$row['slug'], 'why' => $why];
                }
            }
            // The page at the same address first: that is the one a re-import means.
            usort($matches, static fn(array $a, array $b): int => [$a['why'], $a['id']] <=> [$b['why'], $b['id']]);

            $out[] = [
                'index'     => (int)$index,
                'name'      => $page['name'],
                'slug'      => $page['slug'],
                'status'    => $page['status'],
                'replaces'  => Replace::isTarget($page['replaces']) ? Replace::TARGETS[$page['replaces']] : '',
                'sections'  => min($known, $max),
                'unknown'   => $unknown,
                'over'      => max(0, $known - $max),
                'images'    => count($images),
                'missing'   => count($missing),
                'linked'    => $linked,
                'products'  => array_values(array_unique(array_map(
                    static fn(string $n): string => $n !== '' ? $n : 'a product with no name in the file',
                    $products
                ))),
                'languages' => array_keys($dropped),
                'matches'   => array_slice($matches, 0, 10),
            ];
        }
        return $out;
    }

    /**
     * Which product here stands for each product id in the file.
     *
     * In order: the same id with the same name (a file from this very site),
     * the one product with that name in a group of that name, the one product
     * with that name. Anything else is 0: no product.
     *
     * @param array<string,mixed> $manifest
     * @return array<int,int> id in the file => id here, 0 for none
     */
    public static function products(array $manifest, Site $site): array
    {
        $here   = [];
        $byName = [];
        foreach ($site->products() as $p) {
            $here[(int)$p['id']] = $p;
            $byName[self::fold((string)$p['name'])][] = $p;
        }
        $map = [];
        foreach ($manifest['products'] as $id => $hint) {
            $id   = (int)$id;
            $name = self::fold((string)$hint['name']);
            $map[$id] = 0;
            if ($name === '') {
                continue;
            }
            if (isset($here[$id]) && self::fold((string)$here[$id]['name']) === $name) {
                $map[$id] = $id;
                continue;
            }
            $named   = $byName[$name] ?? [];
            $inGroup = array_values(array_filter(
                $named,
                static fn(array $p): bool => self::fold((string)$p['group']) === self::fold((string)$hint['group'])
            ));
            if (count($inGroup) === 1) {
                $map[$id] = (int)$inGroup[0]['id'];
            } elseif (count($named) === 1) {
                $map[$id] = (int)$named[0]['id'];
            }
        }
        return $map;
    }

    // ------------------------------------------------------------------ run

    /**
     * One page of the file as a document this site can store: images pointed
     * at this site's library, products at this site's products, then cleaned
     * the way a save cleans it.
     *
     * @param array<string,mixed> $doc the page's document as it is in the file
     * @param array<string,string> $mediaUrls image name => its address here, '' when it could not be brought in
     * @param array<int,int> $productMap see products()
     * @param list<string> $languages
     * @return array{v:int,sections:list<array<string,mixed>>}
     */
    public static function document(array $doc, array $mediaUrls, array $productMap, array $languages): array
    {
        $doc = Document::walk($doc, static function (array $f, mixed $value) use ($mediaUrls, $productMap): mixed {
            if ($f['type'] === 'image' && is_string($value)) {
                $name = self::mediaName($value);
                // An image that did not arrive leaves the field empty; the
                // section then shows its own placeholder, not a broken image.
                return $name === '' ? $value : ($mediaUrls[$name] ?? '');
            }
            if ($f['type'] === 'product') {
                return is_numeric($value) ? ($productMap[(int)$value] ?? 0) : 0;
            }
            return $value;
        });
        return Document::normalize($doc, $languages);
    }

    /**
     * Do what was chosen for each page.
     *
     * @param array<string,mixed> $manifest
     * @param array<int,string> $choices page index => Importer::NEW, Importer::SKIP or "replace:<id>".
     *                                   A page with no choice is left out.
     * @param callable(string $name, string $dest): string $fetch copies one image of the file to $dest;
     *                                   '' when it worked, else why not
     * @return array{created:list<array{id:int,name:string}>, replaced:list<array{id:int,name:string}>, skipped:int, images:int, notes:list<string>}
     */
    public static function run(array $manifest, array $choices, callable $fetch, Site $site): array
    {
        $languages  = $site->languages();
        $productMap = self::products($manifest, $site);
        $mediaUrls  = [];
        $result     = ['created' => [], 'replaced' => [], 'skipped' => 0, 'images' => 0, 'notes' => []];

        foreach ($manifest['pages'] as $index => $page) {
            $choice = (string)($choices[(int)$index] ?? self::SKIP);
            $target = null;
            if (preg_match('/^replace:(\d{1,10})$/', $choice, $m)) {
                $target = Page::find((int)$m[1]);
                if ($target === null) {
                    $result['notes'][] = '"' . $page['name'] . '" was not imported: the page it was to go into no longer exists.';
                    $result['skipped']++;
                    continue;
                }
            } elseif ($choice !== self::NEW) {
                $result['skipped']++;
                continue;
            }

            // Only the images of pages that are really imported are stored.
            Document::walk($page['doc'], static function (array $f, mixed $value) use ($manifest, $fetch, $site, &$mediaUrls, &$result): mixed {
                $name = $f['type'] === 'image' && is_string($value) ? self::mediaName($value) : '';
                if ($name !== '' && !array_key_exists($name, $mediaUrls)) {
                    [$url, $note] = self::bring($name, $manifest['media'][$name] ?? null, $fetch, $site);
                    $mediaUrls[$name] = $url;
                    $result['images'] += $url !== '' ? 1 : 0;
                    if ($note !== '') {
                        $result['notes'][] = $note;
                    }
                }
                return $value;
            });
            $doc = self::document($page['doc'], $mediaUrls, $productMap, $languages);

            if ($target !== null) {
                // The draft only: the name, the address, the settings in
                // Pages and what visitors see all stay as they are.
                Page::update((int)$target['id'], ['draft' => $doc]);
                unset($_SESSION[Router::PREVIEW_SESSION][(int)$target['id']]);
                $result['replaced'][] = ['id' => (int)$target['id'], 'name' => (string)$target['name']];
                continue;
            }

            $name = Page::freeName($page['name'], 'imported');
            $slug = $page['slug'];
            if ($slug !== '' && str_starts_with($slug . '/', Router::PREVIEW_PREFIX . '/')) {
                $slug = '';
            }
            $id = Page::create([
                'name'  => $name,
                'slug'  => Page::freeSlug($slug),
                'meta'  => Document::normalizeMeta($page['meta'], $languages),
                'draft' => $doc,
            ]);
            $result['created'][] = ['id' => $id, 'name' => $name];
        }
        return $result;
    }

    /**
     * Get one image of the file into this site's library.
     *
     * @param array<string,mixed>|null $info the manifest's entry for it
     * @return array{0:string, 1:string} its address here ('' when it failed) and a note for the admin ('' when there is nothing to say)
     */
    private static function bring(string $name, ?array $info, callable $fetch, Site $site): array
    {
        if ($info === null) {
            return ['', 'An image named in the file was not in it and was left out.'];
        }
        $label = $info['label'] !== '' ? $info['label'] : $name;

        // The very file is already here: the pages came from this site, or
        // were imported before.
        $local = $site->mediaFile($name);
        if ($local !== null && $info['sha256'] !== '' && @hash_file('sha256', $local['path']) === $info['sha256']) {
            return [$site->mediaUrl($name), ''];
        }

        $tmp = tempnam(sys_get_temp_dir(), 'hbi');
        if ($tmp === false) {
            return ['', 'The image "' . $label . '" was left out: the server has nowhere to unpack it.'];
        }
        try {
            $error = $fetch($name, $tmp);
            if ($error !== '') {
                return ['', 'The image "' . $label . '" was left out: ' . $error . '.'];
            }
            $stored = $site->mediaAdd($tmp, $label);
            if (empty($stored['ok']) || (string)($stored['url'] ?? '') === '') {
                return ['', 'The image "' . $label . '" was left out: ' . rtrim((string)($stored['error'] ?? 'it could not be stored'), '.') . '.'];
            }
            return [(string)$stored['url'], ''];
        } finally {
            @unlink($tmp);
        }
    }

    /** The file name in a "media:<name>" value; '' for anything else. */
    public static function mediaName(string $value): string
    {
        if (!str_starts_with($value, PageFile::MEDIA_PREFIX)) {
            return '';
        }
        $name = substr($value, strlen(PageFile::MEDIA_PREFIX));
        // A value that claims to be a library image but is not shaped like one
        // is still "a library image we do not have", never a web address.
        return PageFile::isMediaName($name) ? $name : '?';
    }

    /** Names compared without regard to case or spacing. */
    private static function fold(string $s): string
    {
        $s = trim((string)preg_replace('/\s+/', ' ', $s));
        return function_exists('mb_strtolower') ? mb_strtolower($s) : strtolower($s);
    }
}
