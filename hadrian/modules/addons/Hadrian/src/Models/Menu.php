<?php
declare(strict_types=1);

namespace Hadrian\Models;

use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * A configured navigation menu — one row per saved menu in
 * hadrian_menus. Each menu has a tree of MenuItems and is bound to a
 * location (main/secondary/footer) + audience (client/guest/all).
 *
 * Conventions:
 *   - At most one menu per (location, audience='client') is active
 *   - At most one menu per (location, audience='guest') is active
 *   - 'all' audience is rare but supported (e.g. a public footer)
 *   - The render-time picker prefers the more-specific audience first
 *     (client/guest over all)
 */
class Menu extends Model
{
    protected $table = 'hadrian_menus';

    protected $fillable = ['name', 'location', 'audience', 'active', 'version', 'changed_by_user'];

    protected $casts = [
        'active'          => 'boolean',
        'changed_by_user' => 'boolean',
    ];

    public function items()
    {
        return $this->hasMany(MenuItem::class, 'menu_id')->orderBy('position');
    }

    /**
     * Items at the root level (parent_id IS NULL), ordered by position.
     * Used by the renderer as the starting point of the tree walk.
     */
    public function topLevelItems(): Collection
    {
        return $this->items()->whereNull('parent_id')->orderBy('position')->get();
    }

    /**
     * Find the menu that should render for a given location + audience.
     * Falls back to an 'all' menu if there's no audience-specific one.
     */
    public static function pick(string $location, string $audience): ?self
    {
        $exact = static::query()
            ->where('location', $location)
            ->where('audience', $audience)
            ->where('active', true)
            ->orderBy('id', 'desc')
            ->first();

        if ($exact) {
            return $exact;
        }

        return static::query()
            ->where('location', $location)
            ->where('audience', 'all')
            ->where('active', true)
            ->orderBy('id', 'desc')
            ->first();
    }
}
