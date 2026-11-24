<?php
/**
 * Menus by area: which menu a location shows in each part of the site.
 *
 * Runs Hadrian's real MenuPointers class against in-memory stand-ins for the
 * settings table and the menus table, so no WHMCS and no database is needed.
 * Every client hook that draws a menu picks it through MenuPointers::pick().
 *
 *   php tests/static/test-menu-pointers.php
 */

declare(strict_types=1);

namespace Hadrian\Models {
    /** In-memory stand-in for hadrian_settings. Declared before the real one can load. */
    final class Settings
    {
        /** @var array<string,mixed> */
        public static array $rows = [];

        public static function getValue(string $key, mixed $default = null): mixed
        {
            return array_key_exists($key, self::$rows) ? self::$rows[$key] : $default;
        }

        public static function setValue(string $key, mixed $value, string $type = 'string'): void
        {
            self::$rows[$key] = $value;
        }
    }

    /**
     * In-memory stand-in for hadrian_menus: the two lookups MenuPointers
     * makes. The by-visitor rule (pick) is the real model's, copied: exact
     * audience first, then a menu for everyone, active ones only.
     */
    final class Menu
    {
        /** @var list<self> */
        public static array $table = [];
        /** @var array<string,mixed> */
        private array $wheres = [];

        public function __construct(
            public int $id = 0,
            public string $location = '',
            public string $audience = '',
            public bool $active = false,
        ) {
        }

        public static function query(): self
        {
            return new self();
        }

        public function where(string $column, mixed $value): self
        {
            $this->wheres[$column] = $value;
            return $this;
        }

        public function first(): ?self
        {
            foreach (self::$table as $row) {
                foreach ($this->wheres as $column => $value) {
                    if ($row->{$column} !== $value) {
                        continue 2;
                    }
                }
                return $row;
            }
            return null;
        }

        public static function pick(string $location, string $audience): ?self
        {
            return self::query()->where('location', $location)->where('audience', $audience)->where('active', true)->first()
                ?? self::query()->where('location', $location)->where('audience', 'all')->where('active', true)->first();
        }
    }
}

namespace {
    use Hadrian\Menu\MenuPointers as M;
    use Hadrian\Models\Menu;
    use Hadrian\Models\Settings;

    $src = dirname(__DIR__, 2) . '/hadrian/modules/addons/Hadrian/src';
    require $src . '/Helpers/PageArea.php';
    require $src . '/Menu/MenuPointers.php';

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

    Menu::$table = [
        new Menu(1, 'main', 'client', true),
        new Menu(2, 'main', 'guest', true),
        new Menu(3, 'main', 'client', false),     // a spare, switched off
        new Menu(4, 'footer', 'all', true),
        new Menu(5, 'footer', 'guest', false),
    ];
    /** What a location draws: [menu id, audience its items are filtered for]. */
    $drawn = static function (string $location, ?string $area, string $audience): array {
        [$menu, $as] = M::pick($location, $area, $audience);
        return [$menu?->id, $as];
    };

    // ------------------------------------------------------------------
    $section = 'nothing picked';
    same('no picks are stored', M::all(), []);
    same('an area follows the visitor', M::forArea('main', 'website'), 0);
    same('a guest gets the guest menu, filtered by the menu', $drawn('main', 'website', 'guest'), [2, null]);
    same('a client gets the client menu, in every area', [
        $drawn('main', 'website', 'client'), $drawn('main', 'client', 'client'), $drawn('main', 'order', 'client'),
    ], [[1, null], [1, null], [1, null]]);
    same('the footer for everyone serves both', [$drawn('footer', 'website', 'guest'), $drawn('footer', 'client', 'client')], [[4, null], [4, null]]);
    same('a location with no menu draws none', $drawn('secondary', 'website', 'guest'), [null, null]);

    // ------------------------------------------------------------------
    $section = 'an area with its own menu';
    M::setForArea('main', 'website', 3);
    same('the pick is stored', M::all(), ['main' => ['website' => 3]]);
    same('a guest there gets it, filtered as a guest', $drawn('main', 'website', 'guest'), [3, 'guest']);
    same('a client there gets the same menu, filtered as a client', $drawn('main', 'website', 'client'), [3, 'client']);
    same('it need not be switched on, nor match the audience', [Menu::$table[2]->active, Menu::$table[2]->audience], [false, 'client']);
    same('the other areas still follow the visitor', [$drawn('main', 'client', 'guest'), $drawn('main', 'order', 'client')], [[2, null], [1, null]]);
    same('the other locations are untouched', $drawn('footer', 'website', 'guest'), [4, null]);
    same('a page whose area is unknown follows the visitor', $drawn('main', null, 'guest'), [2, null]);

    M::setForArea('footer', 'order', 5);
    same('each location keeps its own picks', M::all(), ['main' => ['website' => 3], 'footer' => ['order' => 5]]);
    same('the footer pick applies in its area only', [$drawn('footer', 'order', 'client'), $drawn('footer', 'website', 'client')], [[5, 'client'], [4, null]]);
    same('areasOf lists where a menu is picked', [M::areasOf(3, 'main'), M::areasOf(5, 'footer'), M::areasOf(3, 'footer'), M::areasOf(1, 'main')], [['website'], ['order'], [], []]);

    M::setForArea('main', 'client', 3);
    same('one menu can serve two areas', M::areasOf(3, 'main'), ['website', 'client']);

    // ------------------------------------------------------------------
    $section = 'picks that no longer hold';
    M::setForArea('main', 'order', 99);
    same('a pick of a menu that is gone follows the visitor', $drawn('main', 'order', 'guest'), [2, null]);
    same('and the stored pick is left alone', M::forArea('main', 'order'), 99);
    M::setForArea('main', 'order', 4);
    same('a menu from another location is not drawn', $drawn('main', 'order', 'guest'), [2, null]);

    M::setForArea('main', 'order', 0);
    same('0 puts an area back on the visitor rule', [M::forArea('main', 'order'), $drawn('main', 'order', 'guest')], [0, [2, null]]);
    same('and takes the area out of what is stored', array_key_exists('order', M::all()['main']), false);

    M::forget(3);
    same('forgetting a menu drops every pick of it', M::all(), ['footer' => ['order' => 5]]);
    M::forget(5);
    same('the last pick gone leaves nothing stored', [M::all(), Settings::$rows['menus_by_area']], [[], []]);

    // ------------------------------------------------------------------
    $section = 'bad input';
    M::setForArea('sidebar', 'website', 1);
    M::setForArea('main', 'moon', 1);
    same('an unknown location or area is not written', M::all(), []);
    Settings::$rows['menus_by_area'] = 'not an array';
    same('a stored value that is not a map reads as no picks', [M::all(), M::forArea('main', 'website')], [[], 0]);
    Settings::$rows['menus_by_area'] = ['main' => ['website' => '7', 'moon' => 3, 'client' => -2, 'order' => 'x'], 'attic' => ['website' => 1], 'footer' => 'x'];
    same('junk inside the map is dropped, a numeric id is kept', M::all(), ['main' => ['website' => 7]]);

    echo "\n" . ($ok + $fails) . " checks, {$fails} failing\n";
    exit($fails ? 1 : 0);
}
