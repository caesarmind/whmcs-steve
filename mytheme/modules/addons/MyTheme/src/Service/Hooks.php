<?php
declare(strict_types=1);

namespace MyTheme\Service;

use MyTheme\Helpers\AddonHelper;
use MyTheme\Helpers\ThemeManifest;
use MyTheme\Models\Settings;
use MyTheme\Template\Template;

/**
 * Front-of-house hook service.
 *
 * Replaces "6 separate ClientAreaPage hook registrations + 200-line god-function"
 * with a single registration that calls dispatch(), routing by hook name to a
 * method here. One hook → one method → easy to read, easy to test, easy to extend.
 */
final class Hooks
{
    private static ?self $instance = null;

    public static function instance(): self
    {
        return self::$instance ??= new self();
    }

    public function dispatch(string $hookName, mixed $hookArg): mixed
    {
        $template = AddonHelper::getTemplate();
        if ($template === null || !$template->canActivate()) {
            return null;
        }

        $method = lcfirst($hookName);
        if (!method_exists($this, $method)) {
            return null;
        }
        return $this->{$method}($hookArg, $template);
    }

    // ------------------------------------------------------------------ hooks

    /** Runs LAST among ClientAreaPage hooks (priority -1). Assembles $myTheme. */
    private function clientAreaPage(array $vars, Template $template): array
    {
        return [
            'myTheme' => [
                'name'          => $template->getName(),
                'version'       => $template->getVersion(),
                'manifest'      => $template->getManifest(),
                'styles'        => $this->resolveActiveStyle($template),
                'layouts'       => [
                    'main-menu' => $this->resolveActiveLayout($template, 'main-menu'),
                    'footer'    => $this->resolveActiveLayout($template, 'footer'),
                ],
                'pages'         => $this->resolveCurrentPage($vars, $template),
                'addonSettings' => Settings::all(),
            ],
            'rslang' => $this->loadLanguage($template, $vars['language'] ?? 'english'),
        ];
    }

    private function clientAreaHeadOutput(array $vars, Template $template): ?string
    {
        return $this->extensionOutput($template, $vars, slot: 'headOutput');
    }

    private function clientAreaFooterOutput(array $vars, Template $template): ?string
    {
        return $this->extensionOutput($template, $vars, slot: 'footerOutput');
    }

    private function clientAreaHomepagePanels(mixed $panels, Template $template): void
    {
        // Iteration handled in tpl rather than PHP — keeps logic visible.
    }

    /**
     * Populate $dashboard.{activeServices, recentInvoices, openTickets} for clientareahome.
     * Uses WHMCS localAPI so we don't have to hardcode the schema.
     */
    private function clientAreaPageHome(array $vars, Template $template): array
    {
        $clientId = (int)($_SESSION['uid'] ?? 0);
        if ($clientId === 0) {
            return ['dashboard' => ['activeServices' => [], 'recentInvoices' => [], 'openTickets' => []]];
        }

        return [
            'dashboard' => [
                'activeServices' => $this->fetchActiveServices($clientId),
                'recentInvoices' => $this->fetchRecentInvoices($clientId),
                'openTickets'    => $this->fetchOpenTickets($clientId),
            ],
        ];
    }

    private function fetchActiveServices(int $clientId): array
    {
        try {
            $response = localAPI('GetClientsProducts', [
                'clientid'  => $clientId,
                'stats'     => false,
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $services = [];
            foreach (($response['products']['product'] ?? []) as $p) {
                if (!in_array($p['status'] ?? '', ['Active', 'Suspended'], true)) continue;
                $services[] = [
                    'id'           => (int)($p['id'] ?? 0),
                    'name'         => (string)($p['name'] ?? $p['groupname'] ?? 'Service'),
                    'domain'       => (string)($p['domain'] ?? ''),
                    'status'       => (string)($p['status'] ?? 'Active'),
                    'nextDueDate'  => !empty($p['nextduedate']) ? date('M j, Y', strtotime((string)$p['nextduedate'])) : '',
                    'manageUrl'    => '/clientarea.php?action=productdetails&id=' . (int)($p['id'] ?? 0),
                ];
                if (count($services) >= 5) break;
            }
            return $services;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchRecentInvoices(int $clientId): array
    {
        try {
            $response = localAPI('GetInvoices', [
                'userid'    => $clientId,
                'limitnum'  => 5,
                'orderby'   => 'date',
                'order'     => 'desc',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $invoices = [];
            foreach (($response['invoices']['invoice'] ?? []) as $inv) {
                $invoices[] = [
                    'id'     => (int)($inv['id'] ?? 0),
                    'date'   => !empty($inv['date']) ? date('M j, Y', strtotime((string)$inv['date'])) : '',
                    'total'  => (string)($inv['total'] ?? ''),
                    'status' => (string)($inv['status'] ?? ''),
                ];
            }
            return $invoices;
        } catch (\Throwable) {
            return [];
        }
    }

    private function fetchOpenTickets(int $clientId): array
    {
        try {
            $response = localAPI('GetTickets', [
                'clientid'  => $clientId,
                'limitnum'  => 5,
                'status'    => 'Awaiting Reply,Open,Customer-Reply,On Hold,In Progress',
            ]);
            if (($response['result'] ?? '') !== 'success') return [];

            $tickets = [];
            foreach (($response['tickets']['ticket'] ?? []) as $tkt) {
                $tickets[] = [
                    'tid'      => (string)($tkt['tid'] ?? ''),
                    'c'        => (string)($tkt['c'] ?? ''),
                    'subject'  => (string)($tkt['subject'] ?? ''),
                    'status'   => (string)($tkt['status'] ?? ''),
                    'priority' => (string)($tkt['priority'] ?? 'Medium'),
                    'date'     => !empty($tkt['date']) ? date('M j, Y', strtotime((string)$tkt['date'])) : '',
                ];
            }
            return $tickets;
        } catch (\Throwable) {
            return [];
        }
    }

    // ---------------------------------------------------------------- helpers

    private function extensionOutput(Template $template, array $vars, string $slot): ?string
    {
        $output = '';
        foreach ($template->getExtensions() as $name) {
            $extPath = $template->getFullPath() . "/core/extensions/{$name}/{$name}.php";
            if (!file_exists($extPath)) {
                continue;
            }
            $extConfig = require $extPath;
            $callable  = $extConfig[$slot] ?? null;
            if (is_callable($callable)) {
                $output .= (string)$callable($vars);
            }
        }
        return $output !== '' ? $output : null;
    }

    private function resolveActiveStyle(Template $template): array
    {
        $active   = (string)Settings::getValue($template->getName() . '_active_style', 'default');
        $metaPath = $template->getFullPath() . "/core/styles/{$active}/style.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);
        return [
            'name' => $active,
            'meta' => $meta,
            'vars' => $meta['variables'] ?? [],
        ];
    }

    private function resolveActiveLayout(Template $template, string $kind): array
    {
        // Default per kind — `main-menu` defaults to `sidebar` (the Hostnodes default).
        $defaultByKind = ['main-menu' => 'sidebar', 'footer' => 'default'];
        $active = (string)Settings::getValue(
            $template->getName() . '_active_layout_' . $kind,
            $defaultByKind[$kind] ?? 'default'
        );
        $metaPath = $template->getFullPath() . "/core/layouts/{$kind}/{$active}/layout.php";
        $meta     = ThemeManifest::loadVariantMeta($metaPath);
        return [
            'name'       => $active,
            'meta'       => $meta,
            'vars'       => $meta['variables'] ?? [],
            'mediumPath' => "{$template->getName()}/core/layouts/{$kind}/{$active}/default.tpl",
        ];
    }

    /** @return array<string, array{meta: array, variant: string, fullPath: ?string}> */
    private function resolveCurrentPage(array $vars, Template $template): array
    {
        $page = (string)($vars['templatefile'] ?? '');
        if ($page === '') {
            return [];
        }

        $pageMeta = ThemeManifest::loadVariantMeta(
            $template->getFullPath() . "/core/pages/{$page}/page.php"
        );
        $variant = (string)Settings::getValue(
            $template->getName() . '_page_variant_' . $page,
            'default'
        );
        $variantTpl = $template->getFullPath() . "/core/pages/{$page}/{$variant}/{$variant}.tpl";
        $fullPath   = file_exists($variantTpl)
            ? "{$template->getName()}/core/pages/{$page}/{$variant}/{$variant}.tpl"
            : null;

        return [
            $page => ['meta' => $pageMeta, 'variant' => $variant, 'fullPath' => $fullPath],
        ];
    }

    private function loadLanguage(Template $template, string $lang): array
    {
        $candidate = $template->getFullPath() . "/core/lang/{$lang}.php";
        $path      = file_exists($candidate)
            ? $candidate
            : $template->getFullPath() . '/core/lang/english.php';
        return ThemeManifest::loadVariantMeta($path);
    }
}
