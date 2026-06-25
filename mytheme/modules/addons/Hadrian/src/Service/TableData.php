<?php
declare(strict_types=1);

namespace Hadrian\Service;

use WHMCS\Database\Capsule;

/**
 * Server-side data provider for the client-area DataTables (Dynamic AJAX
 * Loading feature). One public method per list table; each implements the
 * jQuery DataTables server-side protocol and returns the standard payload
 * shape:
 *
 *   ['draw'=>int, 'recordsTotal'=>int, 'recordsFiltered'=>int, 'data'=>array]
 *
 * Rows are queried directly via Capsule (NOT localAPI) so pagination/search/
 * sort happen at the DB with LIMIT/OFFSET — only ~10 rows are read per request
 * regardless of account size.
 *
 * Security:
 *   - The client id is ALWAYS passed in by the caller from $_SESSION['uid'];
 *     never read from the request here. Every query is scoped `WHERE userid`.
 *   - Sort columns are resolved through a per-table allowlist (index → column),
 *     so an out-of-range / forged order index falls back to the default column
 *     and can never inject a SQL identifier.
 *   - Search values are bound by Capsule (parameterised LIKE).
 *
 * Field values are returned mostly RAW; the front-end render functions in
 * dynamic-tables.js escape everything before injecting it into the DOM.
 */
final class TableData
{
    // ---------------------------------------------------------------- tables

    public static function invoices(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tblinvoices')->where('userid', $uid)->count();

        $query = Capsule::table('tblinvoices')->where('userid', $uid);
        self::applyFilter($query, 'status', $params['filter']);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'id', 1 => 'date', 2 => 'duedate', 3 => 'total', 4 => 'status'],
            ['invoicenum', 'status', 'total'],
            $params,
            'id'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $status    = trim(strip_tags((string)$r->status));
            $statusLow = self::statusSlug($status);
            $num       = ((string)$r->invoicenum !== '') ? (string)$r->invoicenum : (string)$r->id;
            $href      = $web . '/viewinvoice.php?id=' . (int)$r->id;
            $data[] = [
                'num'        => $num,
                'date'       => self::fmtDate($r->date),
                'due'        => self::fmtDate($r->duedate),
                'amount'     => self::fmtMoney($r->total, $uid),
                'unpaid'     => in_array($statusLow, ['unpaid', 'overdue'], true),
                'status'     => $status,
                'statusSlug' => $statusLow,
                'urls'       => [
                    'view' => $href,
                    'pdf'  => $web . '/dl.php?type=i&id=' . (int)$r->id,
                ],
                'DT_RowAttr' => ['data-href' => $href],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    public static function quotes(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tblquotes')->where('userid', $uid)->count();

        $query = Capsule::table('tblquotes')->where('userid', $uid);
        self::applyFilter($query, 'stage', $params['filter']);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'id', 1 => 'datecreated', 2 => 'validuntil', 3 => 'total', 4 => 'stage'],
            ['subject', 'stage'],
            $params,
            'id'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $stage     = trim(strip_tags((string)$r->stage));
            $stageLow  = self::statusSlug($stage);
            $href      = $web . '/viewquote.php?id=' . (int)$r->id;
            $data[] = [
                'num'        => (string)$r->id,
                'subject'    => (string)$r->subject,
                'date'       => self::fmtDate($r->datecreated),
                'valid'      => self::fmtDate($r->validuntil),
                'amount'     => self::fmtMoney($r->total, $uid),
                'stage'      => $stage,
                'stageSlug'  => $stageLow,
                'delivered'  => $stageLow === 'delivered',
                'urls'       => [
                    'view' => $href,
                    'pdf'  => $href . '&pdf=true',
                ],
                'DT_RowAttr' => ['data-href' => $href],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    public static function tickets(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tbltickets')->where('userid', $uid)->count();

        $query = Capsule::table('tbltickets')
            ->leftJoin('tblticketdepartments', 'tblticketdepartments.id', '=', 'tbltickets.did')
            ->where('tbltickets.userid', $uid)
            ->select('tbltickets.*', 'tblticketdepartments.name as department');
        self::applyFilter($query, 'tbltickets.status', $params['filter']);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'tbltickets.title', 1 => 'tblticketdepartments.name', 2 => 'tbltickets.status', 3 => 'tbltickets.lastreply'],
            ['tbltickets.title', 'tbltickets.status', 'tblticketdepartments.name', 'tbltickets.tid'],
            $params,
            'tbltickets.lastreply'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $status    = trim(strip_tags((string)$r->status));
            $statusLow = self::statusSlug($status);
            $href      = $web . '/viewticket.php?tid=' . rawurlencode((string)$r->tid)
                       . ((string)$r->c !== '' ? '&c=' . rawurlencode((string)$r->c) : '');
            $data[] = [
                'tid'        => (string)$r->tid,
                'subject'    => (string)$r->title,
                'department' => (string)($r->department ?? ''),
                'status'     => $status,
                'statusSlug' => $statusLow,
                'prio'       => strtolower(trim((string)($r->urgency ?? ''))),
                'lastreply'  => self::fmtDate($r->lastreply),
                'DT_RowAttr' => ['data-href' => $href, 'data-status' => $statusLow],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    public static function services(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tblhosting')->where('userid', $uid)->count();

        $query = Capsule::table('tblhosting')
            ->leftJoin('tblproducts', 'tblproducts.id', '=', 'tblhosting.packageid')
            ->leftJoin('tblproductgroups', 'tblproductgroups.id', '=', 'tblproducts.gid')
            ->where('tblhosting.userid', $uid)
            ->select('tblhosting.*', 'tblproducts.name as productName', 'tblproductgroups.name as groupName');
        self::applyFilter($query, 'tblhosting.domainstatus', $params['filter']);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'tblproducts.name', 1 => 'tblhosting.amount', 2 => 'tblhosting.nextduedate', 3 => 'tblhosting.domainstatus'],
            ['tblproducts.name', 'tblhosting.domain', 'tblhosting.domainstatus'],
            $params,
            'tblhosting.id'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $status    = trim(strip_tags((string)$r->domainstatus));
            $statusLow = self::statusSlug($status);
            $cycle     = trim((string)$r->billingcycle);
            $oneTime   = strcasecmp($cycle, 'One Time') === 0 || strcasecmp($cycle, 'Free Account') === 0;
            $id        = (int)$r->id;
            $href      = $web . '/clientarea.php?action=productdetails&id=' . $id;
            $data[] = [
                'name'        => (string)($r->productName ?? ''),
                'group'       => (string)($r->groupName ?? ''),
                'domain'      => (string)$r->domain,
                'amount'      => self::fmtMoney($r->amount, $uid),
                'cycle'       => $cycle,
                'due'         => $oneTime ? '' : self::fmtDate($r->nextduedate),
                'status'      => $status,
                'statusSlug'  => $statusLow,
                'urls'        => [
                    'manage'  => $href,
                    'upgrade' => $web . '/clientarea.php?action=upgrade&id=' . $id,
                    'addons'  => $href . '&modop=custom&a=Addons',
                    'cancel'  => $web . '/clientarea.php?action=cancel&id=' . $id,
                ],
                'DT_RowAttr'  => ['data-href' => $href],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    public static function domains(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tbldomains')->where('userid', $uid)->count();

        $query = Capsule::table('tbldomains')->where('userid', $uid);
        self::applyFilter($query, 'status', $params['filter']);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'domain', 1 => 'registrationdate', 2 => 'expirydate', 3 => 'status'],
            ['domain', 'status'],
            $params,
            'domain',
            'asc'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $status    = trim(strip_tags((string)$r->status));
            $statusLow = self::statusSlug($status);
            $id        = (int)$r->id;
            $href      = $web . '/clientarea.php?action=domaindetails&id=' . $id;
            $data[] = [
                'domain'     => (string)$r->domain,
                'registered' => self::fmtDate($r->registrationdate),
                'expiry'     => self::fmtDate($r->expirydate),
                'status'     => $status,
                'statusSlug' => $statusLow,
                'autorenew'  => empty($r->donotrenew),
                'urls'       => [
                    'manage'      => $href,
                    'nameservers' => $href . '&modop=custom&a=nameservers',
                    'contacts'    => $web . '/clientarea.php?action=domaincontacts&domainid=' . $id,
                    'autorenew'   => $href,
                    'renew'       => $web . '/cart.php?gid=renewals',
                ],
                'DT_RowClass' => 'domain-row',
                'DT_RowAttr'  => ['data-href' => $href],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    public static function emails(int $uid, array $p): array
    {
        $params       = self::params($p);
        $recordsTotal = Capsule::table('tblemails')->where('userid', $uid)->count();

        $query = Capsule::table('tblemails')->where('userid', $uid);
        [$filtered, $rows] = self::run(
            $query,
            [0 => 'date', 1 => 'subject'],
            ['subject'],
            $params,
            'date'
        );

        $web  = self::webRoot();
        $data = [];
        foreach ($rows as $r) {
            $href = $web . '/viewemail.php?id=' . (int)$r->id;
            $data[] = [
                'date'       => self::fmtDate($r->date),
                'subject'    => (string)$r->subject,
                'hasAttach'  => self::attachmentCount($r->attachments ?? null) > 0,
                'urls'       => ['view' => $href],
                'DT_RowAttr' => ['data-href' => $href],
            ];
        }
        return self::payload($params['draw'], $recordsTotal, $filtered, $data);
    }

    // ---------------------------------------------------------------- engine

    /**
     * Apply search → count filtered → apply allowlisted order → paginate.
     *
     * @param  \Illuminate\Database\Query\Builder $query   userid-scoped query (joins/select already applied)
     * @param  array<int,string>                  $orderMap column index → DB column (allowlist)
     * @param  list<string>                       $search   columns the global search LIKEs across
     * @return array{0:int,1:\Illuminate\Support\Collection}  [recordsFiltered, rows]
     */
    private static function run($query, array $orderMap, array $search, array $params, string $defaultCol, string $defaultDir = 'desc'): array
    {
        $term = $params['search'];
        if ($term !== '' && $search !== []) {
            $query->where(static function ($q) use ($search, $term) {
                foreach ($search as $i => $col) {
                    $q->{$i === 0 ? 'where' : 'orWhere'}($col, 'LIKE', '%' . $term . '%');
                }
            });
        }

        $recordsFiltered = (clone $query)->count();

        $col = $orderMap[$params['orderCol']] ?? $defaultCol;
        $dir = in_array($params['orderDir'], ['asc', 'desc'], true) ? $params['orderDir'] : $defaultDir;
        $query->orderBy($col, $dir);

        $rows = $query->skip($params['start'])->take($params['length'])->get();
        return [$recordsFiltered, $rows];
    }

    /** Apply an active status/stage filter tab to the query (exact match; skips 'all'/''). */
    private static function applyFilter($query, string $col, string $filter): void
    {
        if ($filter !== '' && strcasecmp($filter, 'all') !== 0) {
            $query->where($col, $filter);
        }
    }

    /** Normalise the DataTables request params we care about. */
    private static function params(array $p): array
    {
        $order = (isset($p['order'][0]) && is_array($p['order'][0])) ? $p['order'][0] : [];
        return [
            'draw'     => (int)($p['draw'] ?? 0),
            'start'    => max(0, (int)($p['start'] ?? 0)),
            'length'   => self::clampLength($p['length'] ?? 10),
            'search'   => trim((string)($p['search']['value'] ?? '')),
            'orderCol' => (int)($order['column'] ?? -1),
            'orderDir' => strtolower((string)($order['dir'] ?? 'desc')) === 'asc' ? 'asc' : 'desc',
            // Active status/stage filter tab (mtFilter); '' or 'all' means no filter.
            'filter'   => trim((string)($p['mtFilter'] ?? '')),
        ];
    }

    /** Page size: positive, capped at 100. DataTables "all" (-1) → 10. */
    private static function clampLength(mixed $len): int
    {
        $n = (int)$len;
        return ($n <= 0) ? 10 : min($n, 100);
    }

    private static function payload(int $draw, int $total, int $filtered, array $data): array
    {
        return [
            'draw'            => $draw,
            'recordsTotal'    => $total,
            'recordsFiltered' => $filtered,
            'data'            => $data,
        ];
    }

    // ------------------------------------------------------------ formatters

    private static function fmtDate(mixed $raw): string
    {
        $raw = (string)$raw;
        if ($raw === '' || str_starts_with($raw, '0000-00-00')) {
            return '';
        }
        $ts = strtotime($raw);
        return $ts ? date('M j, Y', $ts) : '';
    }

    /** Currency-format using the client's currency; degrade gracefully. */
    private static function fmtMoney(mixed $amount, int $uid): string
    {
        $val = (float)$amount;
        try {
            if (class_exists('\\WHMCS\\View\\Formatter\\Price') && function_exists('getCurrency')) {
                return (string)(new \WHMCS\View\Formatter\Price($val, getCurrency($uid)))->toFull();
            }
        } catch (\Throwable) {
            // fall through
        }
        return number_format($val, 2);
    }

    /** A safe CSS-class slug for a status pill, e.g. "Customer Reply" → "customer-reply". */
    private static function statusSlug(string $status): string
    {
        $s = strtolower(strip_tags($status));
        $s = (string)preg_replace('/[^a-z0-9]+/', '-', $s);
        return trim($s, '-');
    }

    /** tblemails.attachments is a JSON array of filenames (or empty). */
    private static function attachmentCount(mixed $raw): int
    {
        $raw = (string)$raw;
        if ($raw === '') {
            return 0;
        }
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? count($decoded) : 0;
    }

    private static function webRoot(): string
    {
        return defined('WEB_ROOT') ? rtrim((string)WEB_ROOT, '/') : '';
    }
}
