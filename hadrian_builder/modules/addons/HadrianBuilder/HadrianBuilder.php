<?php
declare(strict_types=1);

/**
 * Hadrian Page Builder: WHMCS addon entry point.
 *
 * A module of its own, not part of the Hadrian theme or its addon: its own
 * folder, its own tables, its own activation. It REQUIRES Hadrian, whose
 * theme draws the pages it builds and whose admin shell frames its editor;
 * every call into Hadrian goes through src/Bridge.php.
 *
 * Lifecycle:
 *   _config()     admin metadata + the "remove data" option
 *   _activate()   create the tables
 *   _deactivate() optionally remove data
 *   _upgrade()    create anything a newer version added
 *   _output()     the admin page
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

function HadrianBuilder_config()
{
    return [
        'name'        => 'Hadrian Page Builder',
        'description' => 'Build marketing pages from sections and publish them at their own addresses. Requires the Hadrian addon and theme.',
        'author'      => 'Caesarthemes',
        'language'    => 'english',
        'version'     => HadrianBuilder\AdminController::VERSION,
        'fields'      => [
            'removedata' => [
                'FriendlyName' => 'Remove data on deactivation',
                'Type'         => 'yesno',
                'Description'  => 'When enabled, deactivating this addon deletes every page built with it.',
            ],
        ],
    ];
}

function HadrianBuilder_activate()
{
    try {
        HadrianBuilder\Schema::ensure();
    } catch (\Throwable $e) {
        return ['status' => 'error', 'description' => 'Could not create the module tables: ' . $e->getMessage()];
    }
    $reason = HadrianBuilder\Bridge::reason();
    return $reason === ''
        ? ['status' => 'success', 'description' => 'Activated. Open Addons > Hadrian Page Builder to create a page.']
        : ['status' => 'info', 'description' => 'Activated, but not usable yet. ' . $reason];
}

function HadrianBuilder_deactivate()
{
    $remove = WHMCS\Module\Addon\Setting::where('module', 'HadrianBuilder')
        ->where('setting', 'removedata')
        ->value('value');

    if ($remove === 'on') {
        try {
            HadrianBuilder\Schema::drop();
        } catch (\Throwable $e) {
            return ['status' => 'error', 'description' => 'Could not remove the module data: ' . $e->getMessage()];
        }
        return ['status' => 'success', 'description' => 'Deactivated. Every built page was deleted.'];
    }

    // With the module off its hooks.php no longer loads, so built pages stop
    // being served. The rows stay for when it is activated again.
    return ['status' => 'success', 'description' => 'Deactivated. Built pages are offline and kept for when you activate it again.'];
}

function HadrianBuilder_upgrade($vars)
{
    try {
        HadrianBuilder\Schema::ensure();
    } catch (\Throwable $e) {
        error_log('Hadrian Page Builder upgrade: ' . $e->getMessage());
    }
}

function HadrianBuilder_output($vars)
{
    echo (new HadrianBuilder\AdminController())->dispatch();
}
