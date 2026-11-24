<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * `hadrian_email_designs` -- thin Capsule wrapper. The table itself is described
 * in Schema.
 * JSON columns are decoded on read and encoded on write.
 *
 * Every read is wrapped: the send hook calls these on every outgoing email,
 * and a missing table (files uploaded, module not yet activated) must degrade to
 * "no design" rather than break mail.
 */
final class Design
{
    private const TABLE = Schema::DESIGNS;

    /** Setting holding the id of the layout in use. */
    public const ACTIVE_LAYOUT_KEY = 'layout_id';

    /** @var array<string, array<string,mixed>|null> */
    private static array $byTarget = [];

    public static function tableExists(): bool
    {
        static $memo = null;
        if ($memo === true) {
            return true;
        }
        try {
            return $memo = \WHMCS\Database\Capsule::schema()->hasTable(self::TABLE);
        } catch (\Throwable $e) {
            return false;
        }
    }

    /** @return array<string,mixed>|null */
    public static function find(int $id): ?array
    {
        try {
            $row = \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->first();
            return $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * The layout every email is wrapped in: the one the setting points at, or
     * failing that the oldest layout row.
     *
     * @return array<string,mixed>|null
     */
    public static function layout(): ?array
    {
        try {
            $id  = (int)Store::get(self::ACTIVE_LAYOUT_KEY, 0);
            $row = $id > 0
                ? \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->where('kind', Blocks::KIND_LAYOUT)->first()
                : null;
            $row ??= \WHMCS\Database\Capsule::table(self::TABLE)->where('kind', Blocks::KIND_LAYOUT)->orderBy('id')->first();
            return $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /** @return array<string,mixed>|null */
    public static function forTarget(string $target): ?array
    {
        if ($target === '') {
            return null;
        }
        if (array_key_exists($target, self::$byTarget)) {
            return self::$byTarget[$target];
        }
        try {
            $row = \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('kind', Blocks::KIND_MESSAGE)->where('target', $target)->orderBy('id')->first();
            return self::$byTarget[$target] = $row ? self::hydrate($row) : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Every message design, keyed by the WHMCS template it targets. Without
     * the documents: the list page only needs status.
     *
     * @return array<string, array<string,mixed>>
     */
    public static function messagesByTarget(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('kind', Blocks::KIND_MESSAGE)
                ->get(['id', 'kind', 'name', 'target', 'status', 'published', 'published_at', 'updated_at']);
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $out[(string)$row->target] = self::hydrate($row);
        }
        return $out;
    }

    /** @return list<array<string,mixed>> */
    public static function published(): array
    {
        try {
            $rows = \WHMCS\Database\Capsule::table(self::TABLE)
                ->where('kind', Blocks::KIND_MESSAGE)->where('status', 'published')->get();
        } catch (\Throwable $e) {
            return [];
        }
        $out = [];
        foreach ($rows as $row) {
            $out[] = self::hydrate($row);
        }
        return $out;
    }

    /** @param array<string,mixed> $data */
    public static function create(array $data): int
    {
        $now = date('Y-m-d H:i:s');
        $row = self::columns($data) + ['status' => 'draft', 'created_at' => $now, 'updated_at' => $now];
        self::$byTarget = [];
        return (int)\WHMCS\Database\Capsule::table(self::TABLE)->insertGetId($row);
    }

    /** @param array<string,mixed> $data */
    public static function update(int $id, array $data): void
    {
        $row = self::columns($data) + ['updated_at' => date('Y-m-d H:i:s')];
        \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->update($row);
        self::$byTarget = [];
    }

    public static function delete(int $id): void
    {
        \WHMCS\Database\Capsule::table(self::TABLE)->where('id', $id)->delete();
        self::$byTarget = [];
    }

    /**
     * @param array<string,mixed> $data
     * @return array<string,mixed>
     */
    private static function columns(array $data): array
    {
        $out = [];
        foreach (['kind', 'name', 'target', 'status', 'published_at'] as $k) {
            if (array_key_exists($k, $data)) {
                $out[$k] = $data[$k];
            }
        }
        foreach (['doc', 'published', 'backup'] as $k) {
            if (array_key_exists($k, $data)) {
                $out[$k] = $data[$k] === null
                    ? null
                    : json_encode($data[$k], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
            }
        }
        return $out;
    }

    /** @return array<string,mixed> */
    private static function hydrate(object $row): array
    {
        $a = (array)$row;
        foreach (['doc', 'published', 'backup'] as $k) {
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
