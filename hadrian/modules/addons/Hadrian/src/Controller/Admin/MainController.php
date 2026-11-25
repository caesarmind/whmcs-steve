<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;

/**
 * Admin entry point. Delegates by ?action= to a sub-controller.
 *
 * Routes:
 *   ?action=index            → Info (default landing)
 *   ?action=info             → Info (alias)
 *   ?action=settings         → addon-wide settings
 *   ?action=styles           → style picker
 *   ?action=editStyle        → style editor (color groups, typography, etc.)
 *   ?action=layouts          → layout picker
 *   ?action=pages            → pages list (default sub=index, ?sub=edit, ?sub=save)
 *   ?action=sitemap          → sitemap.xml + robots.txt (sub=save|generate|preview)
 *   ?action=menu             → menu list
 *   ?action=editMenu         → menu editor (drag-drop tree)
 *   ?action=branding         → logo / favicon uploads (sub=upload-ajax|remove-ajax: JSON)
 *   ?action=media            → Media screen; with a sub, the library's JSON
 *                              (sub=list|upload|delete|rename|optimize|restore|settings)
 *   ?action=extensions       → theme extensions
 *   ?action=tools            → cache, license refresh, htaccess gen
 *   ?action=templates        → list installed templates (rare)
 *   ?action=template         → single template config (sub-view)
 *   ?action=license          → license key entry
 */
final class MainController extends AbstractController
{
    /** Default landing — Info page (mirrors Lagom). */
    public function indexAction(): string      { return (new InfoController())->indexAction(); }
    public function infoAction(): string       { return (new InfoController())->indexAction(); }
    public function settingsAction(): string   { return (new SettingsController())->indexAction(); }
    public function stylesAction(): string     { return (new StylesController())->indexAction(); }
    public function editStyleAction(): string  { return (new StylesController())->editAction(); }
    public function layoutsAction(): string    { return (new LayoutsController())->indexAction(); }
    public function customizeAction(): string
    {
        $sub = (string)($_GET['sub'] ?? $_POST['sub'] ?? 'index');
        $ctl = new CustomizeController();
        return match ($sub) {
            'preview-ajax' => $ctl->previewAjaxAction(),
            'save-ajax'    => $ctl->saveAjaxAction(),
            default        => $ctl->indexAction(),
        };
    }
    public function pagesAction(): string
    {
        $sub = (string)($_GET['sub'] ?? $_POST['sub'] ?? 'index');
        $ctl = new PagesController();
        return match ($sub) {
            'edit' => $ctl->editAction(),
            'save' => $ctl->saveAction(),
            default => $ctl->indexAction(),
        };
    }
    public function sitemapAction(): string
    {
        $sub = (string)($_GET['sub'] ?? $_POST['sub'] ?? 'index');
        $ctl = new SitemapController();
        return match ($sub) {
            'save'     => $ctl->saveAction(),
            'generate' => $ctl->generateAction(),
            'preview'  => $ctl->previewAction(),
            default    => $ctl->indexAction(),
        };
    }
    public function menuAction(): string
    {
        $sub = (string)($_GET['sub'] ?? $_POST['sub'] ?? 'index');
        $ctl = new MenuController();
        return match ($sub) {
            'edit'           => $ctl->editAction(),
            'save'           => $ctl->saveAction(),
            'delete'         => $ctl->deleteAction(),
            'seed'           => $ctl->seedAction(),
            'reset-defaults' => $ctl->resetDefaultsAction(),
            'diagnose'       => $ctl->diagnoseAction(),
            'create'         => $ctl->createAction(),
            'areas'          => $ctl->areasAction(),
            default          => $ctl->indexAction(),
        };
    }
    public function editMenuAction(): string   { return (new MenuController())->editAction(); }
    public function brandingAction(): string
    {
        $sub = (string)($_GET['sub'] ?? $_POST['sub'] ?? 'index');
        $ctl = new BrandingController();
        return match ($sub) {
            'remove'      => $ctl->removeAction(),
            // JSON endpoints: answer and exit before WHMCS prints the admin
            // page. Reached only through Hadrian_output(), i.e. after WHMCS
            // has checked the admin login; see the note in hooks.php.
            'upload-ajax' => $ctl->uploadAjaxAction(),
            'remove-ajax' => $ctl->removeAjaxAction(),
            default       => $ctl->indexAction(),
        };
    }
    /**
     * The media library. With no sub it is the Media screen; every sub is a
     * JSON endpoint, used by that screen and by the picker behind every
     * [data-mt-media] field.
     */
    public function mediaAction(): string
    {
        $sub = (string)($_GET['sub'] ?? '');
        if ($sub === '' && ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
            return (new MediaScreenController())->indexAction();
        }
        $ctl = new MediaController();
        return match ($sub) {
            'list'     => $ctl->listAction(),
            'upload'   => $ctl->uploadAction(),
            'delete'   => $ctl->deleteAction(),
            'rename'   => $ctl->renameAction(),
            'optimize' => $ctl->optimizeAction(),
            'restore'  => $ctl->restoreAction(),
            'settings' => $ctl->settingsAction(),
            default    => \Hadrian\Helpers\AdminAjax::refuse('Unknown media action.', 404),
        };
    }
    public function extensionsAction(): string { return (new ExtensionsController())->indexAction(); }
    public function toolsAction(): string      { return (new ToolsController())->indexAction(); }
    public function templatesAction(): string  { return (new TemplatesController())->indexAction(); }
    public function templateAction(): string   { return (new TemplatesController())->showAction(); }
    public function licenseAction(): string    { return (new LicenseController())->indexAction(); }
}
