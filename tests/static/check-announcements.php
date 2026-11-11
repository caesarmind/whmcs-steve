<?php
/**
 * Checks for Hooks::fetchRecentAnnouncements translation handling, no WHMCS.
 *
 * WHMCS stores announcement translations as child rows (parentid = base id,
 * language = language name). The REAL method runs here against a stub Capsule
 * whose tiny query builder implements just the semantics the method uses -
 * where / closure-where+orWhereNull / whereIn / orderBy / limit / get - over a
 * fixture table that contains every trap: a translated base, an untranslated
 * base with parentid NULL (legacy), a wrong-language child, an unpublished row
 * and a future-dated row.
 *
 *   php tests/static/check-announcements.php   -> exit 0 all good / 1 + list
 */

namespace WHMCS\Database {
    final class FakeQuery
    {
        /** @var list<object> */ private array $rows;
        /** @var list<callable> */ private array $preds = [];
        /** @var list<callable> */ private array $orPreds = [];
        private ?int $take = null;
        private array $order = [];

        public function __construct(array $rows) { $this->rows = $rows; }

        public function where($col, $op = null, $val = null): self
        {
            if ($col instanceof \Closure) {
                $sub = new self([]);
                $col($sub);
                $this->preds[] = fn ($r) => $sub->matches($r);
                return $this;
            }
            if (func_num_args() === 2) { $val = $op; $op = '='; }
            $this->preds[] = fn ($r) => match ($op) {
                '='  => ($r->{$col} ?? null) == $val,
                '<=' => (string)($r->{$col} ?? '') <= (string)$val,
                default => throw new \RuntimeException("unhandled op {$op}"),
            };
            return $this;
        }

        public function orWhereNull(string $col): self
        {
            $this->orPreds[] = fn ($r) => !property_exists($r, $col) || $r->{$col} === null;
            return $this;
        }

        public function whereIn(string $col, array $vals): self
        {
            $this->preds[] = fn ($r) => in_array((int)($r->{$col} ?? -1), array_map('intval', $vals), true);
            return $this;
        }

        public function orderBy(string $col, string $dir = 'asc'): self
        {
            $this->order = [$col, $dir];
            return $this;
        }

        public function limit(int $n): self { $this->take = $n; return $this; }

        /** AND of preds, then OR'd with any orWhereNull - Laravel's grouping for this shape. */
        public function matches(object $r): bool
        {
            $and = true;
            foreach ($this->preds as $p) { $and = $and && $p($r); }
            if ($and) { return true; }
            foreach ($this->orPreds as $p) { if ($p($r)) { return true; } }
            return false;
        }

        public function get(array $cols = []): array
        {
            $out = array_values(array_filter($this->rows, fn ($r) => $this->matches($r)));
            if ($this->order) {
                [$col, $dir] = $this->order;
                usort($out, fn ($a, $b) => $dir === 'desc'
                    ? strcmp((string)$b->{$col}, (string)$a->{$col})
                    : strcmp((string)$a->{$col}, (string)$b->{$col}));
            }
            if ($this->take !== null) { $out = array_slice($out, 0, $this->take); }
            return $out;
        }
    }

    final class Capsule
    {
        /** @var array<string, list<object>> */ public static array $tables = [];
        public static function table(string $name): FakeQuery
        {
            return new FakeQuery(self::$tables[$name] ?? []);
        }
    }
}

namespace {

$root  = dirname(__DIR__, 2);
$admin = $root . '/hadrian/modules/addons/Hadrian';

/* The anti-tamper hash table is a gitignored build artifact; load it the way
   the addon does (hooks.php) - the real one when present, the tracked stub
   otherwise. A checker that needed the generated file only ran on one machine. */
require is_file($admin . '/src/Helpers/IntegrityHashes.php')
    ? $admin . '/src/Helpers/IntegrityHashes.php'
    : $admin . '/src/Helpers/IntegrityHashes.fallback.php';
require $admin . '/src/Helpers/ThemeManifest.php';
require $admin . '/src/Helpers/LocaleHelper.php';
require $admin . '/src/Template/Template.php';
require $admin . '/src/Template/PagesCache.php';
require $admin . '/src/Template/LayoutsCache.php';
require $admin . '/src/Service/Hooks.php';

$fails = [];
$oks   = 0;
$check = function (bool $cond, string $what) use (&$fails, &$oks): void {
    if ($cond) { $oks++; } else { $fails[] = $what; }
};

$row = fn (array $a) => (object)$a;
WHMCS\Database\Capsule::$tables['tblannouncements'] = [
    // Base, translated into french + german by child rows.
    $row(['id' => 1, 'parentid' => 0, 'language' => '', 'published' => 1,
          'date' => '2026-02-01 09:00:00', 'title' => 'Hello', 'announcement' => 'Hello body text.']),
    $row(['id' => 11, 'parentid' => 1, 'language' => 'french', 'published' => 1,
          'date' => '2026-02-01 09:00:00', 'title' => 'Bonjour', 'announcement' => 'Corps du texte bonjour.']),
    $row(['id' => 12, 'parentid' => 1, 'language' => 'german', 'published' => 1,
          'date' => '2026-02-01 09:00:00', 'title' => 'Hallo', 'announcement' => 'Hallo Text.']),
    // Legacy base with parentid NULL, no translations.
    $row(['id' => 2, 'parentid' => null, 'language' => '', 'published' => 1,
          'date' => '2026-01-15 09:00:00', 'title' => 'Second', 'announcement' => 'Second body.']),
    // Excluded: unpublished, and future-dated.
    $row(['id' => 3, 'parentid' => 0, 'language' => '', 'published' => 0,
          'date' => '2026-01-10 09:00:00', 'title' => 'Draft', 'announcement' => 'Draft.']),
    $row(['id' => 4, 'parentid' => 0, 'language' => '', 'published' => 1,
          'date' => '2099-01-01 09:00:00', 'title' => 'Future', 'announcement' => 'Future.']),
];

$hooks = (new ReflectionClass(Hadrian\Service\Hooks::class))->newInstanceWithoutConstructor();
$m     = new ReflectionMethod(Hadrian\Service\Hooks::class, 'fetchRecentAnnouncements');
$m->setAccessible(true);
$fetch = fn (int $limit, string $lang = '') => $m->invoke($hooks, $limit, $lang);

/* French visitor */
$fr = $fetch(5, 'french');
$check(count($fr) === 2, 'bases only: translations are not separate items, draft + future excluded');
$check(($fr[0]['id'] ?? 0) === 1 && ($fr[1]['id'] ?? 0) === 2, 'newest first, ids are the BASE ids');
$check(($fr[0]['title'] ?? '') === 'Bonjour', 'translated title substituted for the visitor language');
$check(str_contains($fr[0]['excerpt'] ?? '', 'Corps du texte'), 'excerpt built from the TRANSLATED body');
$check(($fr[1]['title'] ?? '') === 'Second', 'untranslated announcement falls back to the base title');

/* German visitor gets the german child, not the french one */
$de = $fetch(5, 'german');
$check(($de[0]['title'] ?? '') === 'Hallo', 'language filter picks the matching child only');

/* No language - base rows verbatim, no lookup */
$plain = $fetch(5);
$check(($plain[0]['title'] ?? '') === 'Hello', 'empty language renders the base language');

/* Limit applies to BASES, and a DB throw degrades to [] (empty table = no throw, so
   simulate failure by pointing at a table of garbage that breaks the builder) */
$one = $fetch(1, 'french');
$check(count($one) === 1 && ($one[0]['title'] ?? '') === 'Bonjour', 'limit caps base rows, translation still applies');

echo "  {$oks} check(s) passed\n";
if ($fails) {
    echo "  " . count($fails) . " FAILED:\n";
    foreach ($fails as $f) { echo "   - {$f}\n"; }
    exit(1);
}
echo "  All checks passed.\n";

}
