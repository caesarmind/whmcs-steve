<?php
declare(strict_types=1);

namespace Hadrian\Resources\Migrations;

/**
 * Add 'footer-secondary' to the hadrian_menus.location enum.
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
        if (!$schema->hasTable('hadrian_menus')) {
            return;
        }
        \WHMCS\Database\Capsule::statement(
            "ALTER TABLE `hadrian_menus`
             MODIFY COLUMN `location`
             ENUM('main', 'secondary', 'footer', 'footer-secondary')
             NOT NULL DEFAULT 'main'"
        );
    }

    public function down(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if (!$schema->hasTable('hadrian_menus')) {
            return;
        }
        // Drop any rows on the new value first so the enum shrink doesn't
        // fail or coerce values silently.
        \WHMCS\Database\Capsule::table('hadrian_menus')
            ->where('location', 'footer-secondary')
            ->delete();
        \WHMCS\Database\Capsule::statement(
            "ALTER TABLE `hadrian_menus`
             MODIFY COLUMN `location`
             ENUM('main', 'secondary', 'footer')
             NOT NULL DEFAULT 'main'"
        );
    }
}
