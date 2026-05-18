<?php
declare(strict_types=1);

namespace MyTheme\Resources\Migrations;

/**
 * Add 'footer-secondary' to the mytheme_menus.location enum.
 *
 * The original Menus migration created the column with three values
 * ('main', 'secondary', 'footer'). Adding a new admin-managed menu
 * location requires extending that enum on existing installs.
 *
 * Uses a raw ALTER TABLE because Laravel's schema builder doesn't
 * expose enum modification cleanly across MySQL versions.
 */
final class MenusAddFooterSecondary
{
    public function up(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if (!$schema->hasTable('mytheme_menus')) {
            return;
        }
        \WHMCS\Database\Capsule::statement(
            "ALTER TABLE `mytheme_menus`
             MODIFY COLUMN `location`
             ENUM('main', 'secondary', 'footer', 'footer-secondary')
             NOT NULL DEFAULT 'main'"
        );
    }

    public function down(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if (!$schema->hasTable('mytheme_menus')) {
            return;
        }
        // Drop any rows on the new value first so the enum shrink doesn't
        // fail or coerce values silently.
        \WHMCS\Database\Capsule::table('mytheme_menus')
            ->where('location', 'footer-secondary')
            ->delete();
        \WHMCS\Database\Capsule::statement(
            "ALTER TABLE `mytheme_menus`
             MODIFY COLUMN `location`
             ENUM('main', 'secondary', 'footer')
             NOT NULL DEFAULT 'main'"
        );
    }
}
