<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The module's two tables. ensure() is idempotent and cheap, so it runs on
 * activation, on upgrade and on every visit to the admin page: files uploaded
 * over an older copy pick up a new table without anyone clicking anything.
 *
 * hadrian_email_settings   key/value (see Store)
 *
 * hadrian_email_designs    one row per design
 *   kind      layout | message
 *   target    for a message, the WHMCS template name it replaces
 *             (tblemailtemplates.name). Null for a layout.
 *   doc       the block document, JSON. This is the design.
 *   published what a publish wrote into tblemailtemplates, per language:
 *             {"": {"rowId": 12, "hash": "..."}, "french": {...}}
 *             The hash is how an edit made in WHMCS's own editor is noticed.
 *   backup    the rows as they were before the first publish, per language.
 *             Restore puts these back and deletes any row the publish created.
 */
final class Schema
{
    public const DESIGNS = 'hadrian_email_designs';

    public static function ensure(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();

        if (!$schema->hasTable(Store::TABLE)) {
            $schema->create(Store::TABLE, function ($t) {
                $t->string('setting', 191)->primary();
                $t->longText('value')->nullable();
                $t->timestamp('updated_at')->nullable();
            });
        }

        if (!$schema->hasTable(self::DESIGNS)) {
            $schema->create(self::DESIGNS, function ($t) {
                $t->increments('id');
                $t->string('kind', 16);
                $t->string('name', 191);
                $t->string('target', 191)->nullable();
                $t->longText('doc');
                $t->string('status', 16)->default('draft');
                $t->longText('published')->nullable();
                $t->longText('backup')->nullable();
                $t->timestamp('published_at')->nullable();
                $t->timestamps();
                $t->index(['kind', 'target']);
            });
        }
    }

    public static function drop(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        $schema->dropIfExists(self::DESIGNS);
        $schema->dropIfExists(Store::TABLE);
    }
}
