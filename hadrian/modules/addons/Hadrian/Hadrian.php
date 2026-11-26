<?php
declare(strict_types=1);

/**
 * Hadrian — WHMCS addon entry point.
 *
 * THIS FILE WILL BE IONCUBE-ENCODED FOR PRODUCTION.
 *
 * Lifecycle:
 *   _config()     → admin metadata + dbrollback field
 *   _activate()   → Database\Installer: tables, preset menus, caches, upload folder
 *   _deactivate() → optionally drop tables + clean tblconfiguration
 *   _upgrade()    → the same Installer run (idempotent)
 *   _output()     → render admin UI
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

// Bootstrap: License first (so it can run integrity check before anything else loads),
// then the autoloader.
//
// IntegrityHashes.php is a BUILD-TIME generated artifact (.gitignore'd) — it
// only exists in distribution builds where `npm run build:integrity` has run.
// In a source-tree checkout (which is what the GH Action deploys) it's
// absent, so we load a no-op fallback that declares the same class with a
// dummy verifyOrDie. Three downstream classes (License / LicenseHelper /
// Template) call verifyOrDie from their constructors and would fatal with
// 'class not found' otherwise.
$_mtIntegrity = __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Helpers' . DIRECTORY_SEPARATOR . 'IntegrityHashes.php';
if (file_exists($_mtIntegrity)) {
    require_once $_mtIntegrity;
} else {
    require_once __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Helpers' . DIRECTORY_SEPARATOR . 'IntegrityHashes.fallback.php';
}
unset($_mtIntegrity);
require_once __DIR__ . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Template' . DIRECTORY_SEPARATOR . 'License.php';
require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

function Hadrian_config()
{
    return [
        'name'        => 'Hadrian',
        'description' => 'Manages Hadrian client-area templates. <a href="' . htmlspecialchars(\Hadrian\Brand::PRODUCT_URL) . '" target="_blank" rel="noopener">Learn more</a>',
        'author'      => \Hadrian\Brand::authorHtml(),
        'language'    => 'english',
        'version'     => '1.2.3',
        'fields'      => [
            'dbrollback' => [
                'FriendlyName' => 'Database Clear',
                'Type'         => 'yesno',
                'Description'  => 'When enabled, deactivating this addon will drop all Hadrian tables and clear settings.',
            ],
        ],
    ];
}

function Hadrian_activate()
{
    // Run migrations on activation. The Migrator tracks executed migrations in
    // `hadrian_migrations` and is idempotent, so a re-activation is safe.
    //
    // We do this here AND in _upgrade() because WHMCS doesn't reliably trigger
    // _upgrade() on first activation across versions — some 8.x and earlier
    // installs only call it on subsequent version bumps. Belt and braces.
    //
    // Installer::run() is the same work the Setup page's "Run now" button
    // does: tables, the preset menus (a menu that already exists is left
    // alone, so re-activation doesn't clobber admin customisations), the
    // page and layout discovery caches, and the branding upload folder.
    try {
        Hadrian\Database\Installer::run(__DIR__);
    } catch (\Throwable $e) {
        return [
            'status'      => 'error',
            'description' => 'Migration failed: ' . $e->getMessage(),
        ];
    }
    return [
        'status'      => 'success',
        'description' => 'Activated. Open Addons > Hadrian to finish setup: license key, checks, and switching the theme on.',
    ];
}

function Hadrian_deactivate()
{
    $rollback = WHMCS\Module\Addon\Setting::where('module', 'Hadrian')
        ->where('setting', 'dbrollback')
        ->value('value');

    if ($rollback === 'on') {
        WHMCS\Database\Capsule::schema()->disableForeignKeyConstraints();
        $migrator = new Hadrian\Database\Migrator(__DIR__);
        $migrator->rollback();
        WHMCS\Database\Capsule::schema()->enableForeignKeyConstraints();
    }

    return ['status' => 'success'];
}

function Hadrian_upgrade($vars)
{
    // Pending migrations, then the presets if they were never installed (e.g.
    // upgrading from a version that predates the menu manager), then the page
    // and layout discovery caches so new core/pages/ or core/layouts/ folders
    // shipped with the upgrade are picked up, then the branding upload folder
    // (an existing .htaccess there is kept). All idempotent; see Installer.
    Hadrian\Database\Installer::run(__DIR__);

    // The custom_link → whmcs_page conversion used to run here, unconditionally,
    // on every upgrade, under a comment claiming it was "safe to re-run". It
    // was not: it rewrote menu items the admin owns, with no gate, no
    // confirmation and no record of what they had been.
    //
    // Removed rather than gated. It is a one-shot repair for installs seeded
    // during a ~14 hour window in May 2026 (8200dff → the preset rewrite in
    // c57d7ab), and MenuController::ensureMenuPagesMigration() already performs
    // exactly that repair on the first admin Menu page hit, marker-gated so it
    // runs at most once. Nothing here depended on it -- the block was
    // self-contained and only logged -- so an upgrade now leaves menus alone.
    //
    // The conversion itself is unchanged in purpose but no longer destructive;
    // see the guards in Seeder::migrateCustomLinksToWhmcsPages().
}

function Hadrian_output($vars)
{
    echo Hadrian\Controller\Admin\MainController::render()->adminArea();
}
