<?php
declare(strict_types=1);

/**
 * MyTheme — WHMCS addon entry point.
 *
 * THIS FILE WILL BE IONCUBE-ENCODED FOR PRODUCTION.
 *
 * Lifecycle:
 *   _config()     → admin metadata + dbrollback field
 *   _activate()   → no-op (migrations run on first admin visit / upgrade)
 *   _deactivate() → optionally drop tables + clean tblconfiguration
 *   _upgrade()    → run pending migrations
 *   _output()     → render admin UI
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

// Bootstrap: License first (so it can run integrity check before anything else loads),
// then the autoloader.
require_once __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Helpers' . DIRECTORY_SEPARATOR . 'IntegrityHashes.php';
require_once __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Template' . DIRECTORY_SEPARATOR . 'License.php';
require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

function MyTheme_config()
{
    return [
        'name'        => 'MyTheme',
        'description' => 'Manages MyTheme client-area templates. <a href="https://your-domain.com/" target="_blank">Learn more</a>',
        'author'      => '<a href="https://your-domain.com" target="_blank">Your Studio</a>',
        'language'    => 'english',
        'version'     => '1.0.0',
        'fields'      => [
            'dbrollback' => [
                'FriendlyName' => 'Database Clear',
                'Type'         => 'yesno',
                'Description'  => 'When enabled, deactivating this addon will drop all MyTheme tables and clear settings.',
            ],
        ],
    ];
}

function MyTheme_activate()
{
    // Run migrations on activation. The Migrator tracks executed migrations in
    // `mytheme_migrations` and is idempotent, so a re-activation is safe.
    //
    // We do this here AND in _upgrade() because WHMCS doesn't reliably trigger
    // _upgrade() on first activation across versions — some 8.x and earlier
    // installs only call it on subsequent version bumps. Belt and braces.
    try {
        $migrator = new MyTheme\Database\Migrator(__DIR__);
        $migrator->migrate();

        // Seed the 4 preset menus on first activation. The seeder skips any
        // preset whose (name, location) already exists, so re-activation
        // doesn't clobber admin customisations.
        (new MyTheme\Menu\Seeder())->run();
    } catch (\Throwable $e) {
        return [
            'status'      => 'error',
            'description' => 'Migration failed: ' . $e->getMessage(),
        ];
    }
    return ['status' => 'success'];
}

function MyTheme_deactivate()
{
    $rollback = WHMCS\Module\Addon\Setting::where('module', 'MyTheme')
        ->where('setting', 'dbrollback')
        ->value('value');

    if ($rollback === 'on') {
        WHMCS\Database\Capsule::schema()->disableForeignKeyConstraints();
        $migrator = new MyTheme\Database\Migrator(__DIR__);
        $migrator->rollback();
        WHMCS\Database\Capsule::schema()->enableForeignKeyConstraints();
    }

    return ['status' => 'success'];
}

function MyTheme_upgrade($vars)
{
    $migrator = new MyTheme\Database\Migrator(__DIR__);
    $migrator->migrate();
    // Belt and braces: seed presets if they were never installed (e.g. upgrading
    // from a version that predates the menu manager). Idempotent.
    (new MyTheme\Menu\Seeder())->run();
}

function MyTheme_output($vars)
{
    echo MyTheme\Controller\Admin\MainController::render()->adminArea();
}
