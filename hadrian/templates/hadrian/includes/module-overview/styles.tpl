{* Styles for the module-overview cards (Sitejet, WordPress, email accounts,
   add-on upsells). They render inside the product details page, so its
   .card / .pd-field-* / .btn-* classes apply; this only adds the layout bits
   and maps the Bootstrap state classes the modules' client.js toggles
   (.alert-info/-success/-danger, .progress-bar) onto Hadrian tokens. *}
<style>{literal}
.hn-module-overview .hn-mo-row{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end}
.hn-module-overview .hn-mo-row>*{flex:1 1 180px;min-width:0}
.hn-module-overview .hn-mo-row>.hn-mo-shrink{flex:0 0 auto}
.hn-module-overview .hn-mo-split{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1fr);gap:20px;align-items:start}
@media (max-width:720px){.hn-module-overview .hn-mo-split{grid-template-columns:1fr}}
.hn-module-overview .hn-mo-actions{display:flex;flex-wrap:wrap;gap:8px;margin-top:12px}
.hn-module-overview .hn-mo-muted{font-size:var(--text-sm);color:var(--color-text-secondary);margin:0 0 12px;line-height:1.5}
.hn-module-overview .hn-mo-title{font-size:var(--text-md);font-weight:var(--fw-semibold);color:var(--color-text-primary);margin:0 0 2px}
.hn-module-overview .hn-mo-preview{width:100%;max-width:100%;border:.5px solid var(--color-border);border-radius:var(--radius-md);transition:opacity .2s ease-in-out}
.hn-module-overview .hn-mo-suffix{display:flex;align-items:stretch}
.hn-module-overview .hn-mo-suffix .pd-field-input{border-top-right-radius:0;border-bottom-right-radius:0;margin:0}
.hn-module-overview .hn-mo-suffix span{display:flex;align-items:center;padding:0 12px;border:.5px solid var(--color-border);border-left:0;border-radius:0 var(--radius-md) var(--radius-md) 0;background:var(--color-surface-secondary);font-size:var(--text-sm);color:var(--color-text-secondary);white-space:nowrap}
.hn-module-overview .hn-mo-row .pd-field-input,.hn-module-overview .hn-mo-row select.pd-field-input{margin:0}
.hn-module-overview .alert{padding:12px 16px;border-radius:var(--radius-md);font-size:var(--text-sm);margin:12px 0 0}
.hn-module-overview .alert-info{background:var(--color-blue-bg);color:var(--color-blue-text)}
.hn-module-overview .alert-success{background:var(--color-green-bg);color:var(--color-green-text)}
.hn-module-overview .alert-danger{background:var(--color-red-bg);color:var(--color-red-text)}
.hn-module-overview .progress{height:6px;border-radius:999px;background:var(--color-surface-secondary);overflow:hidden}
.hn-module-overview .progress-bar{height:100%;background:var(--color-accent);transition:width .3s}
.hn-module-overview .progress-bar.bg-success{background:var(--color-green-text)}
.hn-module-overview .progress-bar.bg-danger{background:var(--color-red-text)}
{/literal}</style>
