<?php
declare(strict_types=1);

namespace MyTheme\Resources\Migrations;

/**
 * Initial schema. ONE typed settings table.
 *
 * No JSON-in-text columns, no separate per-template state table — keep it tight.
 * Add migrations later as features need them; never add a new table when a row in
 * mytheme_settings will do.
 */
final class Initial
{
    public function up(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();

        if (!$schema->hasTable('mytheme_settings')) {
            $schema->create('mytheme_settings', function ($t) {
                $t->increments('id');
                $t->string('setting', 191)->unique();
                $t->text('value');
                $t->enum('value_type', ['string', 'int', 'bool', 'json'])->default('string');
                $t->timestamps();
            });
        }
    }

    public function down(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if ($schema->hasTable('mytheme_settings')) {
            $schema->drop('mytheme_settings');
        }

        // Wipe all MyTheme rows from tblconfiguration
        \WHMCS\Database\Capsule::table('tblconfiguration')
            ->where('setting', 'LIKE', 'MyTheme-%')
            ->delete();
    }
}
