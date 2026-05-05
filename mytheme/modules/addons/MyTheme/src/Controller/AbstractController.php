<?php
declare(strict_types=1);

namespace MyTheme\Controller;

use MyTheme\View\ViewHelper;

/**
 * Smarty 4+ on WHMCS 9: the engine class moved from \Smarty to \Smarty\Smarty.
 * We resolve the right class name at runtime so this works on either version.
 */
abstract class AbstractController
{
    protected object $smarty;
    protected string $action;

    public static function render(array $params = []): static
    {
        return new static($params);
    }

    public function __construct(array $params = [])
    {
        $smartyClass = self::resolveSmartyClass();
        $this->smarty = new $smartyClass();
        $this->smarty->setTemplateDir(__DIR__ . '/../../views/adminarea');
        $this->smarty->setCompileDir(sys_get_temp_dir() . '/mytheme-smarty');
        $this->smarty->setCacheDir(sys_get_temp_dir() . '/mytheme-smarty-cache');
        $this->smarty->setCaching(false);

        $this->action = (string)($_GET['action'] ?? 'index');
    }

    public function adminArea(): string
    {
        $method = lcfirst($this->action) . 'Action';
        if (!method_exists($this, $method)) {
            $method = 'indexAction';
        }
        return (string)$this->{$method}();
    }

    protected function view(string $template, array $vars = []): string
    {
        $this->smarty->assign([
            'viewHelper'    => new ViewHelper(),
            'currentAction' => $this->action,
            ...$vars,
        ]);
        return (string)$this->smarty->fetch($template . '.tpl');
    }

    protected function redirect(string $url): never
    {
        header('Location: ' . $url);
        exit;
    }

    /**
     * Smarty 4 (WHMCS 9) uses \Smarty\Smarty.
     * Smarty 3 (WHMCS 7/8) uses \Smarty.
     * Both expose the same instance API we use.
     */
    public static function resolveSmartyClass(): string
    {
        return match (true) {
            class_exists('\\Smarty\\Smarty') => '\\Smarty\\Smarty',
            class_exists('\\Smarty')         => '\\Smarty',
            default => throw new \RuntimeException('Smarty engine not available'),
        };
    }
}
