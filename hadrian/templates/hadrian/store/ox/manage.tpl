{* OX App Suite mailbox management (MarketConnect "Professional Email"): the
   page a client opens from an OX service to add, edit and remove mailboxes
   and aliases. WHMCS renders store/ox/manage.tpl.

   INTERIM compatibility wrapper, not a Hadrian design: until this page is
   rebuilt it renders WHMCS's own stock twenty-one template, which is a
   ~1,000-line jQuery + Bootstrap 4 application (five modals, tabs,
   dropdowns, WHMCS.http calls). Without any template here the page failed
   outright. Loaded for it: jQuery + the WHMCS JS core
   (includes/partials/whmcs-core-js.tpl), Bootstrap 4's JS (the same pinned
   build the order form loads) and the minimum Bootstrap CSS behaviour it
   depends on (hidden modals / tab panes / dropdowns, .w-hidden), scoped to
   .hn-compat where it can be. If the twenty-one theme has been removed from
   the install, a notice is shown instead of an error. *}
{if file_exists("templates/twenty-one/store/ox/manage.tpl")}
    {include file="`$template`/includes/partials/whmcs-core-js.tpl"}
    <script>window.jQuery && jQuery.fn.modal || document.write('<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"><\/script>');</script>
    <style>{literal}
    .hn-compat{max-width:1100px;margin:0 auto;padding:24px 0}
    .hn-compat .w-hidden{display:none !important}
    .hn-compat .row{display:flex;flex-wrap:wrap;margin:0 -8px}
    .hn-compat .row>[class*="col-"]{flex:1 1 240px;min-width:0;padding:0 8px}
    .hn-compat .table{width:100%;border-collapse:collapse;margin:12px 0}
    .hn-compat .table th,.hn-compat .table td{padding:10px 12px;border-bottom:.5px solid var(--color-border);text-align:left;vertical-align:middle}
    .hn-compat .form-control{width:100%;height:38px;padding:0 12px;border:.5px solid var(--color-border);border-radius:var(--radius-md);background:var(--color-surface);color:var(--color-text-primary);font:inherit}
    .hn-compat .input-group{display:flex;align-items:stretch}
    .hn-compat .input-group-text{display:flex;align-items:center;padding:0 10px;border:.5px solid var(--color-border);border-left:0;background:var(--color-surface-secondary);color:var(--color-text-secondary)}
    .hn-compat .alert{padding:12px 16px;border-radius:var(--radius-md);margin:0 0 12px}
    .hn-compat .alert-success{background:var(--color-green-bg);color:var(--color-green-text)}
    .hn-compat .alert-danger{background:var(--color-red-bg);color:var(--color-red-text)}
    .hn-compat .alert-info{background:var(--color-blue-bg);color:var(--color-blue-text)}
    .hn-compat .nav-tabs{display:flex;gap:6px;list-style:none;margin:24px 0 0;padding:0;border-bottom:.5px solid var(--color-border)}
    .hn-compat .nav-tabs .nav-link{display:block;padding:8px 14px;color:var(--color-text-secondary);text-decoration:none}
    .hn-compat .nav-tabs .nav-link.active{color:var(--color-text-primary);box-shadow:inset 0 -2px 0 var(--color-accent)}
    .hn-compat .tab-pane{display:none;padding:16px 0}
    .hn-compat .tab-pane.active{display:block}
    .hn-compat .dropdown,.hn-compat .btn-group{position:relative;display:inline-block}
    .hn-compat .dropdown-menu{display:none;position:absolute;z-index:1000;min-width:160px;padding:6px 0;margin:2px 0 0;background:var(--color-surface);border:.5px solid var(--color-border);border-radius:var(--radius-md);box-shadow:0 8px 24px rgba(0,0,0,.12)}
    .hn-compat .dropdown-menu.show{display:block}
    .hn-compat .dropdown-item{display:block;padding:6px 14px;color:var(--color-text-primary);text-decoration:none;white-space:nowrap}
    .hn-compat .progress{height:6px;border-radius:999px;background:var(--color-surface-secondary);overflow:hidden}
    .hn-compat .progress-bar{height:100%;background:var(--color-green-text)}
    .hn-compat .modal{position:fixed;inset:0;z-index:1050;display:none;overflow-y:auto;padding:40px 16px}
    .hn-compat .modal.show{display:block}
    .hn-compat .modal-dialog{max-width:560px;margin:0 auto}
    .hn-compat .modal-lg{max-width:800px}
    .hn-compat .modal-content{background:var(--color-surface);border-radius:var(--radius-lg);box-shadow:0 20px 60px rgba(0,0,0,.25);overflow:hidden}
    .hn-compat .modal-header,.hn-compat .modal-footer{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 20px}
    .hn-compat .modal-body{padding:20px}
    .hn-compat .close{border:0;background:transparent;font-size:22px;line-height:1;color:inherit;cursor:pointer}
    .modal-backdrop{position:fixed;inset:0;z-index:1040;background:#000}
    .modal-backdrop.fade{opacity:0}
    .modal-backdrop.show{opacity:.5}
    {/literal}</style>
    <div class="hn-compat">
        {include file="twenty-one/store/ox/manage.tpl"}
    </div>
{else}
    <div class="callout error" role="alert" style="max-width:var(--w-prose);margin:40px auto;">
        <div class="callout-text">{$LANG.clientareaerroroccured} <a href="{$WEB_ROOT}/submitticket.php">{$LANG.navopenticket}</a></div>
    </div>
{/if}
