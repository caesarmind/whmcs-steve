<?php
declare(strict_types=1);

namespace Hadrian\Service;

use Hadrian\Helpers\AddonHelper;
use Hadrian\Models\Settings;

/**
 * Front-side AJAX dispatch — invoked from hooks.php when $_POST['mtAction'] is set.
 *
 * Each action is a method here. Add new ones as the theme needs.
 *
 * The `tableX` actions back the Dynamic AJAX Loading feature: DataTables POSTs
 * the server-side protocol params, we hand them to TableData (which queries the
 * logged-in client's rows with DB-level pagination) and return the standard
 * DataTables JSON. Every table action is gated by guardTable() — it requires a
 * logged-in client AND the `enable_dynamic_ajax` setting to be on.
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

    // ------------------------------------------------------- dynamic tables

    private static function actionTableServices(array $p): never       { self::respond(TableData::services(self::guardTable(), $p)); }
    private static function actionTableDomains(array $p): never        { self::respond(TableData::domains(self::guardTable(), $p)); }
    private static function actionTableTickets(array $p): never        { self::respond(TableData::tickets(self::guardTable(), $p)); }
    private static function actionTableInvoices(array $p): never       { self::respond(TableData::invoices(self::guardTable(), $p)); }
    private static function actionTableQuotes(array $p): never         { self::respond(TableData::quotes(self::guardTable(), $p)); }
    private static function actionTableEmails(array $p): never         { self::respond(TableData::emails(self::guardTable(), $p)); }

    /**
     * Shared gate for every table endpoint. Returns the authenticated client id,
     * or terminates the request with a JSON error (401 / 403) — so an action
     * body only ever runs for an authorised request with the feature enabled.
     */
    private static function guardTable(): int
    {
        $uid = (int)($_SESSION['uid'] ?? 0);
        if ($uid <= 0) {
            self::respond(['error' => 'Unauthorized'], code: 401);
        }
        if (!Settings::getValue('enable_dynamic_ajax', false)) {
            self::respond(['error' => 'Feature disabled'], code: 403);
        }
        return $uid;
    }

    private static function respond(array $data, int $code = 200): never
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo (string)json_encode($data);
        exit;
    }
}
