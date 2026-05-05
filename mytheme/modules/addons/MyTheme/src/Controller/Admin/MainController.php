<?php
declare(strict_types=1);

namespace MyTheme\Controller\Admin;

use MyTheme\Controller\AbstractController;

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
 *   ?action=pages            → pages list
 *   ?action=editPage         → page editor (variant, SEO, custom layout)
 *   ?action=menu             → menu list
 *   ?action=editMenu         → menu editor (drag-drop tree)
 *   ?action=branding         → logo / favicon uploads
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
    public function pagesAction(): string      { return (new PagesController())->indexAction(); }
    public function editPageAction(): string   { return (new PagesController())->editAction(); }
    public function menuAction(): string       { return (new MenuController())->indexAction(); }
    public function editMenuAction(): string   { return (new MenuController())->editAction(); }
    public function brandingAction(): string   { return (new BrandingController())->indexAction(); }
    public function extensionsAction(): string { return (new ExtensionsController())->indexAction(); }
    public function toolsAction(): string      { return (new ToolsController())->indexAction(); }
    public function templatesAction(): string  { return (new TemplatesController())->indexAction(); }
    public function templateAction(): string   { return (new TemplatesController())->showAction(); }
    public function licenseAction(): string    { return (new LicenseController())->indexAction(); }
}
