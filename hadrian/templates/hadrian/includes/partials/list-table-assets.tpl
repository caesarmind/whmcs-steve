{* Unified list-table engine assets — Lagom-parity Dynamic AJAX Loading.

   Included once by every client-area list page (services, domains, invoices,
   quotes, tickets, emails). Loads jQuery + DataTables + the shared engine
   (assets/js/dynamic-tables.js), which drives each table in BOTH modes:
     • Dynamic AJAX ON  → server-side DataTable (table carries data-mt-action)
     • Dynamic AJAX OFF → client-side DataTable over the server-rendered rows
   The engine reads all user copy from window.HadrianTablesLang (set below).

   Guarded so a double-include on a page is a no-op. *}
{if !isset($mtListAssetsLoaded)}
{assign var=mtListAssetsLoaded value=true}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
<script>
window.HadrianTablesLang = {ldelim}
    showing:      '{$hadrianLang.common.tableShowing|default:"Showing"|escape:"javascript"}',
    to:           '–',
    of:           '{$hadrianLang.common.tableOf|default:"of"|escape:"javascript"}',
    previousPage: '{$hadrianLang.common.previousPage|default:"Previous page"|escape:"javascript"}',
    nextPage:     '{$hadrianLang.common.nextPage|default:"Next page"|escape:"javascript"}',
    viewAll:      '{$hadrianLang.common.tableViewAll|default:"View all"|escape:"javascript"}'
{rdelim};
</script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$hadrian.version|default:'1.0'}"></script>
{/if}
