<?php
declare(strict_types=1);

/**
 * Hadrian Email Templates: WHMCS addon entry point.
 *
 * A module of its own, not part of the Hadrian theme or its addon: its own
 * folder, its own tables, its own activation. It REQUIRES Hadrian, which is
 * where an email's colours, font and logo come from; every call into Hadrian
 * goes through src/Bridge.php.
 *
 * Lifecycle:
 *   _config()     admin metadata + the "remove data" option
 *   _activate()   create the two tables
 *   _deactivate() hand WHMCS its own mail header back; optionally remove data
 *   _upgrade()    create anything a newer version added
 *   _output()     the admin page
 */

if (!defined('WHMCS')) {
    exit('This file cannot be accessed directly');
}

require_once __DIR__ . DIRECTORY_SEPARATOR . 'autoload.php';

function HadrianEmail_config()
{
    return [
        'name'        => 'Hadrian Email Templates',
        'description' => 'Branded email for WHMCS: a layout around every client email and a block builder for the ones you redesign. Requires the Hadrian addon.',
        'author'      => 'Caesarthemes',
        'language'    => 'english',
        'version'     => '1.0.0',
        'fields'      => [
            'removedata' => [
                'FriendlyName' => 'Remove data on deactivation',
                'Type'         => 'yesno',
                'Description'  => 'When enabled, deactivating this addon puts every published email template back to its WHMCS original and deletes all designs.',
            ],
        ],
    ];
}

function HadrianEmail_activate()
{
    try {
        HadrianEmail\Schema::ensure();
    } catch (\Throwable $e) {
        return ['status' => 'error', 'description' => 'Could not create the module tables: ' . $e->getMessage()];
    }
    // Activating changes nothing about outgoing mail. That only happens when
    // the admin turns Hadrian email on from the module page.
    $reason = HadrianEmail\Bridge::reason();
    return $reason === ''
        ? ['status' => 'success', 'description' => 'Activated. Open Addons > Hadrian Email Templates to set it up.']
        : ['status' => 'info', 'description' => 'Activated, but not usable yet. ' . $reason];
}

function HadrianEmail_deactivate()
{
    // Always: give WHMCS its own global header, footer and CSS back. With the
    // module off its send hook no longer runs. The guarded placeholder would
    // keep sending the static layout, which is safe, but an admin who switched
    // the module off should get their own header back.
    try {
        if (HadrianEmail\Takeover::isEnabled()) {
            HadrianEmail\Takeover::disable();
        }
    } catch (\Throwable $e) {
        return [
            'status'      => 'error',
            'description' => 'Could not restore the WHMCS email header and footer: ' . $e->getMessage()
                . ' Check General Settings > Mail before sending email.',
        ];
    }

    $remove = WHMCS\Module\Addon\Setting::where('module', 'HadrianEmail')
        ->where('setting', 'removedata')
        ->value('value');

    if ($remove === 'on') {
        try {
            // Restore first, drop second: the originals live in the table.
            foreach (HadrianEmail\Design::published() as $design) {
                HadrianEmail\Publisher::restore((int)$design['id']);
            }
            HadrianEmail\Schema::drop();
        } catch (\Throwable $e) {
            return ['status' => 'error', 'description' => 'Could not remove the module data: ' . $e->getMessage()];
        }
        return ['status' => 'success', 'description' => 'Deactivated. Every email template is back to its WHMCS original and the designs were deleted.'];
    }

    // Published designs stay in their WHMCS templates: they are plain HTML
    // and need nothing from this module to keep sending.
    return ['status' => 'success', 'description' => 'Deactivated. Your designs are kept for when you activate it again.'];
}

function HadrianEmail_upgrade($vars)
{
    try {
        HadrianEmail\Schema::ensure();
    } catch (\Throwable $e) {
        error_log('Hadrian Email upgrade: ' . $e->getMessage());
    }
}

function HadrianEmail_output($vars)
{
    echo (new HadrianEmail\AdminController())->dispatch();
}
