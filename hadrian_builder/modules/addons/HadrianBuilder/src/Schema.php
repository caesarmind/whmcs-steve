<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The module's tables. ensure() is idempotent and cheap, so it runs on
 * activation, on upgrade and on every visit to the admin page: files uploaded
 * over an older copy pick up a new table without anyone clicking anything.
 *
 * hadrian_builder_settings   key/value (see Store)
 *
 * hadrian_builder_pages      one row per page
 *   slug       the address under the site root: "hosting" or "about/team".
 *              Empty for a page that has not been given one yet.
 *   name       what the admin calls the page in the list
 *   draft      the document being edited, JSON (see Document)
 *   published  the document visitors get, JSON. Null until first published.
 *              Saving a draft never touches it.
 *   meta       page-level texts, JSON: {"title": {...}, "description": {...}},
 *              each a translatable map
 *   status     draft | published. A published page with a newer draft stays
 *              "published"; the editor compares the two documents to say
 *              whether there are unpublished changes.
 *   replaces   the theme page this one stands in for: a key of
 *              Replace::TARGETS, or '' for none. At most one page per target.
 *   replace_rule  follow | always | never (see Replace)
 */
final class Schema
{
    public const PAGES = 'hadrian_builder_pages';

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

        if (!$schema->hasTable(self::PAGES)) {
            $schema->create(self::PAGES, function ($t) {
                $t->increments('id');
                $t->string('slug', 191)->default('');
                $t->string('name', 191);
                $t->longText('draft');
                $t->longText('published')->nullable();
                $t->longText('meta')->nullable();
                $t->string('status', 16)->default('draft');
                $t->timestamp('published_at')->nullable();
                $t->timestamps();
                $t->index('slug');
                $t->index('status');
            });
        }

        // Added after 0.1.0. ensure() runs on every visit to the admin page,
        // so an older table picks the columns up without a reactivation.
        if (!$schema->hasColumn(self::PAGES, 'replaces')) {
            $schema->table(self::PAGES, function ($t) {
                $t->string('replaces', 64)->default('');
                $t->string('replace_rule', 16)->default('follow');
                $t->index('replaces');
            });
        }
    }

    public static function drop(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        $schema->dropIfExists(self::PAGES);
        $schema->dropIfExists(Store::TABLE);
    }
}
