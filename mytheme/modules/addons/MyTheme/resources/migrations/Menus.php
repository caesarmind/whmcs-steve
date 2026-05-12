<?php
declare(strict_types=1);

namespace MyTheme\Resources\Migrations;

/**
 * Menu manager schema. Two tables — see docs/MENU-MANAGER.md.
 *
 * Why two tables (vs Lagom's five):
 *   - No separate menu_types table — item types are a PHP class registry
 *   - No separate menu_content table — per-item config is one JSON column
 *   - No display_menus junction — audience is an enum column on the menu
 *
 * Cascading delete: dropping a menu drops its items via FK ON DELETE CASCADE.
 */
final class Menus
{
    public function up(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();

        if (!$schema->hasTable('mytheme_menus')) {
            $schema->create('mytheme_menus', function ($t) {
                $t->increments('id');
                $t->string('name', 191);
                $t->enum('location', ['main', 'secondary', 'footer'])->default('main');
                $t->enum('audience', ['client', 'guest', 'all'])->default('all');
                $t->boolean('active')->default(false);
                $t->string('version', 32)->default('1.0');
                $t->boolean('changed_by_user')->default(false);
                $t->timestamps();

                $t->index('location');
                $t->index(['active', 'audience']);
            });
        }

        if (!$schema->hasTable('mytheme_menu_items')) {
            $schema->create('mytheme_menu_items', function ($t) {
                $t->increments('id');
                $t->unsignedInteger('menu_id');
                $t->unsignedInteger('parent_id')->nullable();
                $t->integer('position')->default(0);
                $t->string('item_type', 32);
                $t->text('label_json');
                $t->text('config_json');
                $t->boolean('active')->default(true);
                $t->timestamps();

                $t->foreign('menu_id')
                    ->references('id')->on('mytheme_menus')
                    ->onDelete('cascade');

                $t->index(['menu_id', 'parent_id', 'position'], 'mytheme_menu_items_tree_idx');
            });
        }
    }

    public function down(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if ($schema->hasTable('mytheme_menu_items')) {
            $schema->drop('mytheme_menu_items');
        }
        if ($schema->hasTable('mytheme_menus')) {
            $schema->drop('mytheme_menus');
        }
    }
}
