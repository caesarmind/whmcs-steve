<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Models\Configuration;
use Hadrian\Template\Template;

final class AddonHelper
{
    public static function isActive(): bool
    {
        $value = (string)Configuration::getValue('ActiveAddonModules');
        return $value !== '' && str_contains($value, 'Hadrian');
    }

    public static function getActiveTemplateName(): string
    {
        return match (true) {
            isset($_GET['systpl'])      => (string)$_GET['systpl'],
            isset($_SESSION['Template']) => (string)$_SESSION['Template'],
            default                     => (string)Configuration::getValue('Template'),
        };
    }

    public static function getTemplate(): ?Template
    {
        try {
            return new Template(self::getActiveTemplateName());
        } catch (\Throwable) {
            // The site is on another theme. For visitors that is the end of
            // it: Hadrian's hooks must stay out of someone else's pages. In
            // the admin the addon still manages Hadrian, so Styles, Layouts
            // and Pages can be set up before the theme is switched on (they
            // used to answer "No active template" until then).
            if (defined('ADMINAREA')) {
                try {
                    return new Template(ThemeSwitch::THEME);
                } catch (\Throwable) {
                    return null;
                }
            }
            return null;
        }
    }

    /** @return list<string> */
    public static function getNotActiveTemplates(): array
    {
        $disabled = [];
        foreach (Template::getAll() as $slug => $template) {
            if (!$template->canActivate()) {
                $disabled[] = $slug;
            }
        }
        return $disabled;
    }

    public static function isCli(): bool
    {
        return PHP_SAPI === 'cli'
            || defined('STDIN')
            || empty($_SERVER['REQUEST_METHOD'] ?? null);
    }
}
