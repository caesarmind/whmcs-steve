<?php
declare(strict_types=1);

namespace Hadrian\Controller;

use Hadrian\Helpers\AdminAjax;
use Hadrian\Helpers\AdminCsrf;
use Hadrian\View\ViewHelper;

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
        $this->smarty->setCompileDir(sys_get_temp_dir() . '/hadrian-smarty');
        $this->smarty->setCacheDir(sys_get_temp_dir() . '/hadrian-smarty-cache');
        $this->smarty->setCaching(false);

        $this->action = (string)($_GET['action'] ?? 'index');
    }

    public function adminArea(): string
    {
        // Every write needs the WHMCS admin token, checked here once before
        // any controller runs. WHMCS does not check it for an addon. See
        // Helpers\AdminCsrf.
        $sub     = (string)($_GET['sub'] ?? $_POST['sub'] ?? '');
        $refusal = AdminCsrf::check($this->action, $sub, (string)($_SERVER['REQUEST_METHOD'] ?? 'GET'));
        if ($refusal !== null) {
            if (AdminCsrf::isJsonRoute($this->action, $sub)) {
                AdminAjax::refuse('Your session expired. Reload the page and try again.', 403);
            }
            http_response_code(403);
            $known = method_exists($this, lcfirst($this->action) . 'Action');
            return $this->view('error', [
                'title'   => 'Not saved',
                'error'   => $refusal,
                'backUrl' => (new ViewHelper())->url($known ? $this->action : 'index'),
            ]);
        }

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
            // Tabs for separately installed extension modules; see Helpers\Extensions.
            'mtExtensions'  => \Hadrian\Helpers\Extensions::all(),
            // For the few GET links that change state (AdminCsrf::GET_WRITES):
            // they carry it as &token=. POST forms get it from WHMCS itself.
            'csrfToken'     => AdminCsrf::token(),
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
