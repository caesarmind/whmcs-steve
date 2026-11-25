<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * `hadrian_builder_pages`: thin Capsule wrapper. The table is described in
 * Schema. JSON columns are decoded on read and encoded on write.
 *
 * Reads are wrapped: the router calls bySlug() on a client request, and a
 * missing table (files uploaded, module never activated) must mean "no such
 * page", not an error on someone's 404.
 */
final class Page
{
    private const TABLE = Schema::PAGES;

    private const JSON = ['draft', 'published', 'meta'];

    /** @return array<string,mixed>|null */
    public static function find(int $id): ?array
    {
        if ($id < 1) {
            return null;
        }
        try {
            $row = \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->first();
            return $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * The published page at this address, or null.
     *
     * @return array<string,mixed>|null
     */
    public static function bySlug(string $slug): ?array
    {
        if ($slug === '') {
            return null;
        }
        try {
            $row = \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('slug', $slug)->where('status', 'published')->orderBy('id')->first();
            return $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Every page for the list screen, without the documents.
     *
     * @return list<array<string,mixed>>
     */
    public static function all(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table(self::TABLE)
                ->orderBy('name')
                ->get(['id', 'slug', 'name', 'status', 'published_at', 'updated_at', 'replaces', 'replace_rule']);
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $out[] = self::hydrate($row);
        }
        return $out;
    }

    /**
     * Every page with what the rest of the site needs to know about it: its
     * address, status, what it replaces and its meta. No documents.
     *
     * @return list<array<string,mixed>>
     */
    public static function forSite(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table(self::TABLE)
                ->orderBy('id')
                ->get(['id', 'slug', 'name', 'status', 'meta', 'replaces', 'replace_rule']);
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $out[] = self::hydrate($row);
        }
        return $out;
    }

    /**
     * The page that names this theme page as the one it replaces, or null.
     * The router calls this on client requests: a table that predates the
     * column means "nothing replaces it", not an error.
     *
     * @return array<string,mixed>|null
     */
    public static function replacing(string $target): ?array
    {
        if ($target === '') {
            return null;
        }
        try {
            $row = \WHMCS\Database\Capsule::table(self::TABLE)->where('replaces', $target)->orderBy('id')->first();
            return $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Point a page at the theme page it replaces ('' for none). A theme page
     * has one replacement, so any other page naming it lets go.
     */
    public static function setReplaces(int $id, string $target, string $rule): void
    {
        if ($target !== '') {
            \WHMCS\Database\Capsule::table(self::TABLE)->where('replaces', $target)->where('id', '!=', $id)
                ->update(['replaces' => '', 'replace_rule' => 'follow']);
        }
        \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)
            ->update(['replaces' => $target, 'replace_rule' => $target === '' ? 'follow' : $rule, 'updated_at' => date('Y-m-d H:i:s')]);
    }

    /** Is another page already using this address? */
    public static function slugTaken(string $slug, int $exceptId = 0): bool
    {
        if ($slug === '') {
            return false;
        }
        try {
            return \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('slug', $slug)->where('id', '!=', $exceptId)->exists();
        } catch (\Throwable $e) {
            return false;
        }
    }

    /**
     * A name no other page has, for a page that arrives with a name already
     * in use: "Hosting" becomes "Hosting (imported)", then "Hosting (imported 2)".
     * Names need not be unique; this only keeps two rows in Pages apart.
     */
    public static function freeName(string $name, string $word): string
    {
        $taken = [];
        foreach (self::all() as $row) {
            $taken[strtolower((string)$row['name'])] = true;
        }
        $name = Text::line($name, 120) ?: 'Page';
        if (!isset($taken[strtolower($name)])) {
            return $name;
        }
        for ($n = 1; $n < 200; $n++) {
            $tail = ' (' . $word . ($n > 1 ? ' ' . $n : '') . ')';
            $try  = Text::cut($name, 120 - strlen($tail)) . $tail;
            if (!isset($taken[strtolower($try)])) {
                return $try;
            }
        }
        return $name;
    }

    /**
     * This address if no page has it, else the first of "<address>-2",
     * "<address>-3" that is free. '' stays '' (a page with no address yet),
     * and '' is also the answer when nothing free can be made.
     */
    public static function freeSlug(string $slug): string
    {
        $slug = Text::slug($slug);
        if ($slug === '' || !self::slugTaken($slug)) {
            return $slug;
        }
        for ($n = 2; $n < 200; $n++) {
            $try = Text::slug($slug . '-' . $n);
            if ($try !== '' && !self::slugTaken($try)) {
                return $try;
            }
        }
        return '';
    }

    /** @param array<string,mixed> $data */
    public static function create(array $data): int
    {
        $now = date('Y-m-d H:i:s');
        $row = self::columns($data) + [
            'slug' => '', 'draft' => Document::encode(Document::blank()), 'status' => 'draft',
            'created_at' => $now, 'updated_at' => $now,
        ];
        return (int)\WHMCS\Database\Capsule::table(self::TABLE)->insertGetId($row);
    }

    /** @param array<string,mixed> $data */
    public static function update(int $id, array $data): void
    {
        $row = self::columns($data) + ['updated_at' => date('Y-m-d H:i:s')];
        \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->update($row);
    }

    public static function delete(int $id): void
    {
        \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->delete();
    }

    /** Make the current draft the page visitors get. */
    public static function publish(int $id): void
    {
        $page = self::find($id);
        if ($page === null) {
            return;
        }
        self::update($id, ['published' => $page['draft'], 'status' => 'published', 'published_at' => date('Y-m-d H:i:s')]);
    }

    /** Take the page offline. The draft and the last published copy are kept. */
    public static function unpublish(int $id): void
    {
        self::update($id, ['status' => 'draft']);
    }

    /** Does the draft differ from what visitors see? */
    public static function hasUnpublishedChanges(array $page): bool
    {
        return $page['status'] === 'published'
            && Document::encode((array)$page['draft']) !== Document::encode((array)$page['published']);
    }

    /**
     * @param array<string,mixed> $data
     * @return array<string,mixed>
     */
    private static function columns(array $data): array
    {
        $out = [];
        foreach (['slug', 'name', 'status', 'published_at'] as $k) {
            if (array_key_exists($k, $data)) {
                $out[$k] = $data[$k];
            }
        }
        foreach (self::JSON as $k) {
            if (array_key_exists($k, $data)) {
                $out[$k] = $data[$k] === null ? null : Document::encode((array)$data[$k]);
            }
        }
        return $out;
    }

    /** @return array<string,mixed> */
    private static function hydrate(object $row): array
    {
        $a = (array)$row;
        foreach (self::JSON as $k) {
            if (array_key_exists($k, $a)) {
                $decoded = is_string($a[$k]) && $a[$k] !== '' ? json_decode($a[$k], true) : null;
                $a[$k]   = is_array($decoded) ? $decoded : [];
            }
        }
        if (isset($a['id'])) {
            $a['id'] = (int)$a['id'];
        }
        return $a;
    }
}
