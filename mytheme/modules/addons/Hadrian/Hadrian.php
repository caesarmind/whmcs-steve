<?php
declare(strict_types=1);

/**
 * Hadrian — WHMCS addon entry point.
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
        'description' => 'Manages Hadrian client-area templates. <a href="https://your-domain.com/" target="_blank">Learn more</a>',
        'author'      => '<a href="https://your-domain.com" target="_blank">Your Studio</a>',
        'language'    => 'english',
        'version'     => '1.2.0',
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
    try {
        $migrator = new Hadrian\Database\Migrator(__DIR__);
        $migrator->migrate();

        // Seed the 4 preset menus on first activation. The seeder skips any
        // preset whose (name, location) already exists, so re-activation
        // doesn't clobber admin customisations.
        (new Hadrian\Menu\Seeder())->run();

        // Build the pages-discovery cache for every installed template.
        // The Pages admin tab reads this on every visit; without it the
        // tab would surface only the pages explicitly declared in
        // theme.json's provides.pages. Filesystem scan happens here at
        // activation time — never during a client-area request.
        foreach (Hadrian\Template\Template::getAll() as $tpl) {
            try {
                Hadrian\Template\PagesCache::rebuild($tpl);
            } catch (\Throwable $e) {
                error_log('Hadrian: pages discovery rebuild failed for '
                    . $tpl->getName() . ': ' . $e->getMessage());
            }
        }

        // Prime the branding upload directory + drop the security
        // .htaccess sidecar before the admin's first upload. Failure here
        // isn't fatal — the Uploader self-heals lazily on first use — but
        // doing it at activation surfaces filesystem permission issues
        // immediately rather than at upload time.
        try {
            if (!(new Hadrian\Helpers\Uploader())->prepareStorage()) {
                error_log('Hadrian: branding storage dir not writable. '
                    . 'Check filesystem permissions on templates/hadrian/assets/img/branding/');
            }
        } catch (\Throwable $e) {
            error_log('Hadrian: branding storage prep failed: ' . $e->getMessage());
        }
    } catch (\Throwable $e) {
        return [
            'status'      => 'error',
            'description' => 'Migration failed: ' . $e->getMessage(),
        ];
    }
    return ['status' => 'success'];
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
    $migrator = new Hadrian\Database\Migrator(__DIR__);
    $migrator->migrate();
    // Belt and braces: seed presets if they were never installed (e.g. upgrading
    // from a version that predates the menu manager). Idempotent.
    (new Hadrian\Menu\Seeder())->run();

    // v1.2.0: convert existing custom_link items whose URL matches a known
    // WHMCS page → whmcs_page. Safe to re-run; converts nothing on next pass.
    try {
        $migrated = (new Hadrian\Menu\Seeder())->migrateCustomLinksToWhmcsPages();
        if ($migrated > 0) {
            error_log("Hadrian upgrade: migrated {$migrated} custom_link menu items to whmcs_page");
        }
    } catch (\Throwable $e) {
        error_log('Hadrian: custom_link → whmcs_page migration failed: ' . $e->getMessage());
    }

    // Refresh pages discovery so any new core/pages/ directories shipped
    // with the upgrade are picked up without the buyer touching anything.
    foreach (Hadrian\Template\Template::getAll() as $tpl) {
        try {
            Hadrian\Template\PagesCache::rebuild($tpl);
        } catch (\Throwable $e) {
            error_log('Hadrian: pages discovery rebuild failed for '
                . $tpl->getName() . ': ' . $e->getMessage());
        }
    }

    // Re-prime the branding upload directory. Newly-shipped upgrades may
    // tighten the .htaccess rules; the Uploader will rewrite the file
    // only if it doesn't already exist (idempotent), so existing buyer
    // customisations to the sidecar are preserved.
    try {
        (new Hadrian\Helpers\Uploader())->prepareStorage();
    } catch (\Throwable $e) {
        error_log('Hadrian upgrade: branding storage prep failed: ' . $e->getMessage());
    }
}

function Hadrian_output($vars)
{
    echo Hadrian\Controller\Admin\MainController::render()->adminArea();
}
