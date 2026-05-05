<?php
declare(strict_types=1);

namespace MyTheme\Service;

use MyTheme\Helpers\AddonHelper;

/**
 * Front-side AJAX dispatch — invoked from hooks.php when $_POST['mtAction'] is set.
 *
 * Each action is a method here. Add new ones as the theme needs.
 */
final class AjaxService
{
    public static function handle(string $action, array $payload): never
    {
        $clean  = preg_replace('/[^a-z0-9]/i', '', $action) ?? '';
        $method = 'action' . ucfirst($clean);

        if (!method_exists(self::class, $method)) {
            self::respond(['error' => 'Unknown action'], code: 404);
        }
        self::{$method}($payload);
    }

    private static function actionPing(array $payload): never
    {
        self::respond([
            'pong'  => true,
            'theme' => AddonHelper::getActiveTemplateName(),
        ]);
    }

    private static function respond(array $data, int $code = 200): never
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo (string)json_encode($data);
        exit;
    }
}
