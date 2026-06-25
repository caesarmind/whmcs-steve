<?php
declare(strict_types=1);

namespace Hadrian\Resources\Migrations;

/**
 * Page registry table — one row per (template, page).
 *
 * Single source of truth for per-page SEO + sitemap config, superseding the
 * hadrian_settings `<tpl>_page_options_<page>` / `<tpl>_page_variant_<page>`
 * key-value rows. PageRegistry::sync imports those into this table on the
 * first admin Pages-tab hit and intentionally LEAVES the legacy keys in place
 * as a rollback path.
 *
 * This consciously departs from the "never add a new table when a row in
 * hadrian_settings will do" note in Initial.php: a queryable registry is what
 * the sitemap generator (and future admin-created pages) actually need.
 *
 * seo_title / seo_description hold EITHER a per-language JSON map keyed by the
 * WHMCS language name ({"english":"…"}) OR a plain string (legacy import);
 * `settings` holds {options, layout_overrides, subnav, svclayout} as JSON.
 */
final class Pages
{
    public function up(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if ($schema->hasTable('hadrian_pages')) {
            return;
        }
        $schema->create('hadrian_pages', function ($t) {
            $t->increments('id');
            $t->string('template', 191);
            $t->string('page', 191);
            $t->string('url', 255)->nullable();          // public path; null = not crawlable
            $t->string('page_group', 64)->default('');   // not `group` (reserved word)
            $t->boolean('seo_enabled')->default(true);
            $t->enum('indexing', ['inherit', 'allow', 'disallow'])->default('inherit');
            $t->enum('visibility', ['public', 'auth', 'disabled'])->default('public');
            $t->text('seo_title')->nullable();           // per-language JSON map or plain string
            $t->text('seo_description')->nullable();      // per-language JSON map or plain string
            $t->string('seo_image', 500)->nullable();
            $t->string('variant', 191)->nullable();
            $t->text('settings')->nullable();             // JSON: options + layout_overrides + subnav + svclayout
            $t->boolean('published')->default(true);
            $t->integer('sort')->default(0);
            $t->timestamps();
            $t->unique(['template', 'page']);
        });
    }

    public function down(): void
    {
        $schema = \WHMCS\Database\Capsule::schema();
        if ($schema->hasTable('hadrian_pages')) {
            $schema->drop('hadrian_pages');
        }
    }
}
