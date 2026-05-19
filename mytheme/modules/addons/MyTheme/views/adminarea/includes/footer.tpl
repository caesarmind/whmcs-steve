        </div>
    </div>
</div>

<style>
/* ============================================================================
   Hostnodes admin — Apple HIG / STYLEGUIDE.md aligned.
   Self-contained inside the addon's _output() so it doesn't leak into WHMCS.
============================================================================ */

.mt-wrap, .mt-wrap * { box-sizing: border-box; }
.mt-wrap {
    --mt-bg:          #fbfbfd;
    --mt-surface:     #ffffff;
    --mt-surface-2:   #f5f5f7;
    --mt-surface-3:   #fafafa;
    --mt-text:        #1d1d1f;
    --mt-text-2:      #6e6e73;
    --mt-text-3:      #86868b;
    --mt-text-4:      #aeaeb2;
    --mt-border:      #e8e8ed;
    --mt-border-2:    #f0f0f5;
    --mt-input-border:#d2d2d7;
    --mt-primary:     #0071e3;
    --mt-primary-h:   #0077ed;
    --mt-primary-tint: rgba(0,113,227,0.08);
    --mt-link:        #0066cc;
    --mt-success:     #30d158;
    --mt-success-tint: rgba(48,209,88,0.10);
    --mt-success-text: #248a3d;
    --mt-warning:     #ff9f0a;
    --mt-warning-tint: rgba(255,159,10,0.10);
    --mt-warning-text: #c27400;
    --mt-danger:      #ff3b30;
    --mt-danger-tint: rgba(255,59,48,0.10);
    --mt-danger-text: #d70015;
    --mt-neutral-tint: rgba(142,142,147,0.12);
    --mt-toggle-on:   #30d158;

    --mt-radius-sm:   8px;
    --mt-radius:      12px;
    --mt-radius-card: 18px;
    --mt-radius-pill: 980px;

    --mt-shadow-card-hover: 0 2px 12px rgba(0,0,0,0.06);
    --mt-shadow-dropdown:   0 4px 32px rgba(0,0,0,0.12), 0 0 1px rgba(0,0,0,0.08);

    max-width: 1200px;
    margin: 0 auto;
    padding: 24px;
    background: var(--mt-bg);
    color: var(--mt-text);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Open Sans", "Segoe UI", system-ui, sans-serif;
    font-size: 14px;
    line-height: 1.5;
    -webkit-font-smoothing: antialiased;
}
.mt-wrap a { color: var(--mt-primary); text-decoration: none; }
.mt-wrap a:hover { color: var(--mt-primary-h); }
.mt-wrap code { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; font-size: 0.92em; background: rgba(0,0,0,0.04); padding: 1px 6px; border-radius: 4px; }

.mt-brandbar { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-card); padding: 18px 22px; margin-bottom: 12px; display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
.mt-brandbar-left { display: flex; align-items: center; gap: 12px; }
.mt-brandmark { width: 38px; height: 38px; border-radius: 10px; background: linear-gradient(135deg, #6366F1 0%, #0071E3 100%); color: #fff; display: grid; place-items: center; font-weight: 700; font-size: 18px; letter-spacing: -0.02em; position: relative; overflow: hidden; }
.mt-brandmark::after { content: ''; position: absolute; inset: 0; background: radial-gradient(circle at 30% 30%, rgba(255,255,255,0.25), transparent 60%); }
.mt-brandname { font-weight: 600; font-size: 16px; letter-spacing: -0.015em; }
.mt-brandversion { font-size: 12px; color: var(--mt-text-3); margin-top: 1px; }
.mt-brandbar-right { display: flex; gap: 6px; }
.mt-brandbar-link { display: inline-flex; align-items: center; gap: 6px; padding: 8px 18px; border-radius: var(--mt-radius-pill); color: var(--mt-text); background: transparent; border: 1.5px solid rgba(0,0,0,0.18); font-size: 13px; font-weight: 500; text-decoration: none; transition: background 0.2s ease, border-color 0.2s ease; }
.mt-brandbar-link:hover { background: var(--mt-surface-2); border-color: rgba(0,0,0,0.25); text-decoration: none; }
.mt-brandbar-link svg { width: 14px; height: 14px; }

.mt-topnav { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-card); padding: 6px; margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 2px; }
.mt-topnav-item { display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: var(--mt-radius-pill); color: var(--mt-text-2); font-size: 14px; font-weight: 500; letter-spacing: -0.005em; text-decoration: none; transition: background 0.2s ease, color 0.2s ease; }
.mt-topnav-item:hover { background: var(--mt-surface-2); color: var(--mt-text); text-decoration: none; }
.mt-topnav-item.is-active { background: var(--mt-primary); color: #fff; }
.mt-topnav-item.is-active:hover { background: var(--mt-primary-h); color: #fff; }
.mt-topnav-icon { width: 16px; height: 16px; flex-shrink: 0; }

.mt-card-outer { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-card); overflow: hidden; }
.mt-card-inner { padding: 32px 36px; }

.mt-page-header { margin-bottom: 28px; padding-bottom: 20px; border-bottom: 1px solid var(--mt-border); }
.mt-page-eyebrow { font-size: 12px; font-weight: 600; color: var(--mt-primary); letter-spacing: 0.06em; text-transform: uppercase; margin-bottom: 8px; }
.mt-page-title { font-size: 28px; font-weight: 600; letter-spacing: -0.025em; margin: 0 0 6px; line-height: 1.1; }
.mt-page-subtitle { font-size: 15px; color: var(--mt-text-2); margin: 0; }
.mt-page-meta { display: inline; color: var(--mt-text-3); font-weight: 400; font-size: 15px; margin-left: 6px; }

.mt-section { margin-bottom: 32px; }
.mt-section:last-child { margin-bottom: 0; }
.mt-section-header { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 16px; gap: 16px; flex-wrap: wrap; }
.mt-section-title { font-size: 17px; font-weight: 600; margin: 0; letter-spacing: -0.015em; }
.mt-section-count { font-size: 13px; color: var(--mt-text-3); font-weight: 400; }
.mt-section-tools { display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }

.mt-tabs { display: inline-flex; background: var(--mt-border); padding: 3px; border-radius: 9px; gap: 0; margin-bottom: 20px; }
.mt-tab { padding: 5px 14px; border-radius: 6px; color: var(--mt-text-2); font-size: 13px; font-weight: 500; text-decoration: none; cursor: pointer; transition: background 0.15s ease, color 0.15s ease; }
.mt-tab:hover { color: var(--mt-text); text-decoration: none; }
.mt-tab.is-active { background: var(--mt-surface); color: var(--mt-text); box-shadow: 0 1px 2px rgba(0,0,0,0.04); }

.mt-subcats { display: flex; flex-direction: column; gap: 2px; min-width: 180px; }
.mt-subcat { padding: 7px 12px; border-radius: 6px; color: var(--mt-text-2); font-size: 13px; font-weight: 500; cursor: pointer; text-decoration: none; }
.mt-subcat:hover { background: var(--mt-surface-2); color: var(--mt-text); text-decoration: none; }
.mt-subcat.is-active { background: var(--mt-primary-tint); color: var(--mt-primary); }

.mt-badge { display: inline-flex; align-items: center; gap: 4px; padding: 2px 10px; border-radius: var(--mt-radius-pill); font-size: 12px; font-weight: 500; line-height: 1.6; white-space: nowrap; }
.mt-badge-success { background: var(--mt-success-tint); color: var(--mt-success-text); }
.mt-badge-warning { background: var(--mt-warning-tint); color: var(--mt-warning-text); }
.mt-badge-danger  { background: var(--mt-danger-tint);  color: var(--mt-danger-text); }
.mt-badge-primary { background: var(--mt-primary-tint); color: var(--mt-primary); }
.mt-badge-neutral { background: var(--mt-neutral-tint); color: var(--mt-text-2); }

.mt-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 24px; border-radius: var(--mt-radius-pill); border: 1px solid transparent; font-family: inherit; font-size: 14px; font-weight: 500; line-height: 1.2; letter-spacing: -0.005em; cursor: pointer; text-decoration: none; transition: background 0.2s ease, border-color 0.2s ease; user-select: none; }
.mt-btn-primary { background: var(--mt-primary); color: #fff; }
.mt-btn-primary:hover { background: var(--mt-primary-h); color: #fff; text-decoration: none; }
.mt-btn-secondary { background: transparent; color: var(--mt-text); border: 1.5px solid rgba(0,0,0,0.2); }
.mt-btn-secondary:hover { background: var(--mt-surface-2); color: var(--mt-text); text-decoration: none; }
.mt-btn-ghost { background: transparent; color: var(--mt-link); padding: 6px 12px; }
.mt-btn-ghost:hover { background: var(--mt-primary-tint); color: var(--mt-link); text-decoration: none; }
.mt-btn-sm { padding: 6px 14px; font-size: 13px; }
.mt-btn[disabled], .mt-btn:disabled { opacity: 0.4; cursor: not-allowed; pointer-events: none; }

.mt-input, .mt-select, .mt-textarea { width: 100%; padding: 12px 16px; border: 1px solid var(--mt-input-border); border-radius: var(--mt-radius); background: var(--mt-surface); color: var(--mt-text); font-family: inherit; font-size: 15px; line-height: 1.4; transition: border-color 0.15s ease, box-shadow 0.15s ease; }
.mt-input:focus, .mt-select:focus, .mt-textarea:focus { outline: none; border-color: var(--mt-primary); box-shadow: 0 0 0 4px rgba(0,113,227,0.15); }
/* Custom select chevron — strips the native browser caret and paints a
   consistent caret matching the rest of the design. ASCII-only data URI
   so it survives Chrome's CSS-skip quirk on this WHMCS install. */
.mt-select {
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    background-image: url("data:image/svg+xml;charset=utf-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='none' stroke='%236e6e73' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='4 6 8 10 12 6'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 12px center;
    background-size: 14px 14px;
    padding-right: 36px;
    cursor: pointer;
}
.mt-select:disabled { opacity: 0.6; cursor: not-allowed; }
.mt-select::-ms-expand { display: none; } /* IE/Edge legacy caret */
.mt-search { position: relative; max-width: 280px; }
.mt-search .mt-input { padding-left: 32px; }
.mt-search-icon { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--mt-text-3); pointer-events: none; }
.mt-search-icon svg { width: 14px; height: 14px; display: block; }
.mt-field { display: flex; flex-direction: column; gap: 6px; margin-bottom: 16px; }
.mt-field-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
.mt-field-label { font-size: 13px; font-weight: 500; color: var(--mt-text); }
.mt-field-tools { display: flex; align-items: center; gap: 8px; font-size: 12px; color: var(--mt-text-3); }
.mt-field-help { font-size: 12px; color: var(--mt-text-3); }
.mt-charcount { font-variant-numeric: tabular-nums; }
.mt-charcount.is-over { color: var(--mt-danger); }
.mt-inline-row { display: grid; grid-template-columns: 200px 1fr; gap: 16px; align-items: center; padding: 12px 0; border-bottom: 1px solid var(--mt-border); }
.mt-inline-row:last-child { border-bottom: 0; }
.mt-inline-row > .mt-input, .mt-inline-row > .mt-select { max-width: 320px; }

.mt-toggle { position: relative; display: inline-block; width: 40px; height: 24px; flex-shrink: 0; }
.mt-toggle input { opacity: 0; width: 0; height: 0; }
.mt-toggle-track { position: absolute; inset: 0; background: #E8E8ED; border-radius: 999px; transition: background 0.2s ease; cursor: pointer; }
.mt-toggle-thumb { position: absolute; top: 2px; left: 2px; width: 20px; height: 20px; background: #fff; border-radius: 50%; box-shadow: 0 1px 1px rgba(0,0,0,0.04), 0 2px 6px rgba(0,0,0,0.12); transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1); }
.mt-toggle input:checked ~ .mt-toggle-track { background: var(--mt-toggle-on); }
.mt-toggle input:checked ~ .mt-toggle-track .mt-toggle-thumb { transform: translateX(16px); }

.mt-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 14px 0; border-bottom: 1px solid var(--mt-border); }
.mt-row:last-child { border-bottom: 0; }
.mt-row-label { font-size: 14px; font-weight: 500; }
.mt-row-help { font-size: 12px; color: var(--mt-text-3); margin-top: 2px; }

.mt-deflist { display: grid; grid-template-columns: 200px 1fr; gap: 8px 24px; }
.mt-deflist dt { color: var(--mt-text-2); font-size: 13px; padding: 6px 0; }
.mt-deflist dd { margin: 0; padding: 6px 0; font-size: 14px; font-weight: 500; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

.mt-table-wrap { overflow: hidden; border: 1px solid var(--mt-border); border-radius: var(--mt-radius); }
.mt-table { width: 100%; border-collapse: collapse; }
.mt-table thead th { background: var(--mt-surface-2); border-bottom: 1px solid var(--mt-border); padding: 10px 16px; text-align: left; font-size: 11px; font-weight: 600; color: var(--mt-text-2); text-transform: uppercase; letter-spacing: 0.04em; }
.mt-table tbody td { padding: 12px 16px; border-bottom: 1px solid var(--mt-border); font-size: 13px; vertical-align: middle; }
.mt-table tbody tr:last-child td { border-bottom: 0; }
.mt-table tbody tr:hover { background: var(--mt-surface-2); }
.mt-table tbody tr.is-active { background: var(--mt-primary-tint); }
.mt-table .mt-table-name { font-weight: 500; }
.mt-table .mt-table-actions { text-align: right; }

.mt-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
.mt-card { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius); padding: 14px; transition: border-color 0.15s ease, box-shadow 0.15s ease, transform 0.15s ease; cursor: pointer; display: flex; flex-direction: column; gap: 10px; }
.mt-card:hover { transform: translateY(-1px); box-shadow: var(--mt-shadow-card-hover); }
.mt-card.is-active { border-color: var(--mt-primary); box-shadow: 0 0 0 2px var(--mt-primary-tint); }
.mt-card-thumb { aspect-ratio: 16/10; background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%); border-radius: var(--mt-radius-sm); display: grid; place-items: center; color: var(--mt-text-3); font-size: 24px; font-weight: 200; }
.mt-card-title { font-size: 14px; font-weight: 600; margin: 0; }
.mt-card-meta { font-size: 12px; color: var(--mt-text-3); margin: 0; }
.mt-card-footer { display: flex; align-items: center; justify-content: space-between; margin-top: auto; }
.mt-card label { cursor: pointer; }
.mt-card input[type="radio"] { display: none; }

.mt-schemes { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px; }
.mt-scheme { display: inline-flex; align-items: center; gap: 8px; padding: 5px 11px 5px 7px; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-pill); cursor: pointer; font-size: 13px; font-weight: 500; text-decoration: none; color: var(--mt-text); }
.mt-scheme.is-active { border-color: var(--mt-primary); box-shadow: 0 0 0 2px var(--mt-primary-tint); color: var(--mt-primary); }
.mt-scheme-dot { width: 14px; height: 14px; border-radius: 50%; border: 1px solid rgba(0,0,0,0.06); }

.mt-color-group { margin-bottom: 20px; }
.mt-color-group-title { font-size: 11px; font-weight: 600; color: var(--mt-text-2); margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.04em; }
.mt-color-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 8px; }
.mt-color-tile { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-sm); overflow: hidden; cursor: pointer; }
.mt-color-tile:hover { border-color: var(--mt-input-border); }
.mt-color-swatch { height: 36px; border-bottom: 1px solid rgba(0,0,0,0.06); }
.mt-color-meta { padding: 6px 10px; }
.mt-color-name { font-size: 11px; color: var(--mt-text-2); font-weight: 500; }
.mt-color-hex { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; font-size: 11px; color: var(--mt-text); margin-top: 1px; font-variant-numeric: tabular-nums; }
.mt-color-tile.is-gradient { grid-column: span 2; }
.mt-color-tile.is-gradient .mt-color-swatch { background: linear-gradient(90deg, var(--g1, #1966FF), var(--g2, #009AFF)); }
.mt-color-tile.is-gradient .mt-color-hex { display: flex; gap: 3px; }
.mt-color-tile.is-gradient .mt-color-hex em { color: var(--mt-text-3); font-style: normal; }

.mt-variant-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 10px; }
.mt-variant { background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius); padding: 12px 14px; display: flex; align-items: center; justify-content: space-between; gap: 10px; }
.mt-variant.is-active { border-color: var(--mt-primary); box-shadow: 0 0 0 2px var(--mt-primary-tint); }
.mt-variant-name { font-size: 13px; font-weight: 500; }

.mt-upload { border: 2px dashed var(--mt-input-border); background: var(--mt-surface-2); border-radius: var(--mt-radius); padding: 20px; text-align: center; cursor: pointer; transition: border-color 0.15s ease, background 0.15s ease; min-height: 110px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; }
.mt-upload:hover { border-color: var(--mt-primary); background: var(--mt-primary-tint); }
.mt-upload-icon { color: var(--mt-text-3); }
.mt-upload-text { font-size: 13px; font-weight: 500; }
.mt-upload-hint { font-size: 11px; color: var(--mt-text-3); }
.mt-upload-pair { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.mt-upload-caption { font-size: 12px; color: var(--mt-text-2); margin-top: 6px; text-align: center; }

.mt-toolbar { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 16px; }
.mt-back { display: inline-flex; align-items: center; gap: 6px; color: var(--mt-text-2); font-size: 13px; font-weight: 500; text-decoration: none; }
.mt-back:hover { color: var(--mt-primary); text-decoration: none; }
.mt-back svg { width: 14px; height: 14px; }

.mt-menu-tree { display: flex; flex-direction: column; gap: 6px; }
.mt-menu-tree ul.mt-menu-list, .mt-menu-tree ul.mt-menu-children { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 4px; }
.mt-menu-tree ul.mt-menu-children { margin: 4px 0 4px 22px; padding-left: 12px; border-left: 2px solid var(--mt-border); }
.mt-menu-tree ul.mt-menu-children:empty { display: none; }
.mt-menu-tree ul.is-drag-over { background: var(--mt-primary-tint); border-radius: var(--mt-radius-sm); outline: 1px dashed rgba(0,113,227,0.35); }
.mt-menu-item { list-style: none; }
.mt-menu-item.is-dragging > .mt-menu-item-row { opacity: 0.4; }
.mt-menu-item-row { display: flex; align-items: center; gap: 10px; padding: 9px 12px; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-sm); cursor: grab; transition: border-color .12s; }
.mt-menu-item-row:hover { border-color: var(--mt-primary); }
.mt-menu-handle { color: var(--mt-text-3); flex-shrink: 0; }
.mt-menu-handle svg { width: 14px; height: 14px; display: block; }
.mt-menu-type-badge { font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; padding: 2px 7px; border-radius: 999px; background: var(--mt-primary-tint); color: var(--mt-primary); flex-shrink: 0; }
.mt-menu-name { flex: 1; font-size: 13px; font-weight: 500; color: var(--mt-text); }
.mt-menu-actions { display: flex; gap: 4px; flex-shrink: 0; opacity: 0; transition: opacity .15s; }
.mt-menu-item-row:hover .mt-menu-actions, .mt-menu-item-row:focus-within .mt-menu-actions { opacity: 1; }
.mt-icon-btn { width: 26px; height: 26px; padding: 0; border: 0; background: transparent; color: var(--mt-text-3); border-radius: 4px; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; }
.mt-icon-btn:hover { background: var(--mt-bg); color: var(--mt-text); }
.mt-icon-btn svg { width: 14px; height: 14px; display: block; }
.mt-menu-add-row { display: flex; gap: 6px; margin-top: 12px; padding-top: 12px; border-top: 1px dashed var(--mt-border); }
.mt-menu-add-row .mt-input { flex: 1; }
.mt-menu-add { border: 1px dashed var(--mt-input-border); background: transparent; color: var(--mt-text-2); padding: 7px 12px; border-radius: var(--mt-radius-sm); font-size: 12px; font-weight: 500; cursor: pointer; }
.mt-menu-add:hover { border-color: var(--mt-primary); color: var(--mt-primary); background: var(--mt-primary-tint); }
.mt-menu-split { display: grid; grid-template-columns: 1.6fr 1fr; gap: 24px; align-items: start; }
.mt-split { display: grid; grid-template-columns: 200px 1fr; gap: 24px; }
@media (max-width: 1100px) { .mt-menu-split, .mt-split { grid-template-columns: 1fr; } }
.mt-page-title-input { font: inherit; background: transparent; border: 0; border-bottom: 1px dashed var(--mt-border); padding: 0 2px; color: var(--mt-text); min-width: 200px; }
.mt-page-title-input:focus { outline: 0; border-color: var(--mt-primary); }
.mt-item-drawer { display: flex; flex-direction: column; gap: 14px; }
.mt-drawer-head { display: flex; flex-direction: column; gap: 2px; margin-bottom: 6px; }
.mt-drawer-eyebrow { font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--mt-text-3); }
.mt-drawer-title { font-size: 15px; font-weight: 600; color: var(--mt-text); margin: 0; }
.mt-drawer-empty { color: var(--mt-text-3); font-size: 13px; padding: 14px 4px; text-align: center; }
.mt-checkbox { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; padding: 4px 0; margin-right: 12px; }
.mt-divider { border: 0; border-top: 1px solid var(--mt-border); margin: 6px 0; }
.mt-flash { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 999px; font-size: 12px; font-weight: 500; margin-right: 8px; }
.mt-flash-success { background: rgba(40, 167, 69, 0.15); color: #1e7e34; }
.mt-flash-warn    { background: rgba(255, 159,  10, 0.15); color: #b35900; max-width: 600px; font-size: 12px; line-height: 1.4; padding: 6px 12px; border-radius: 6px; }
.mt-flash-warn a  { color: inherit; font-weight: 600; }
.mt-section-note  { font-size: 12px; color: var(--mt-text-2); padding: 0 14px 8px; margin: 0; line-height: 1.5; }
.mt-section-note em { font-style: normal; font-weight: 600; color: var(--mt-text); }

/* Icon picker (admin drawer) */
.mt-icon-picker-wrap { position: relative; }
.mt-icon-picker-trigger { display: flex; align-items: center; gap: 10px; width: 100%; padding: 8px 12px; background: var(--mt-surface); border: 1px solid var(--mt-input-border); border-radius: var(--mt-radius-sm); font: inherit; color: var(--mt-text); cursor: pointer; }
.mt-icon-picker-trigger:hover { border-color: var(--mt-primary); }
.mt-icon-picker-preview { width: 22px; height: 22px; display: inline-flex; align-items: center; justify-content: center; color: var(--mt-text); }
.mt-icon-picker-preview svg { width: 18px; height: 18px; }
.mt-icon-picker-name { flex: 1; text-align: left; font-size: 13px; color: var(--mt-text-2); font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
.mt-icon-picker-caret { color: var(--mt-text-3); font-size: 10px; }
.mt-icon-picker-panel { position: absolute; top: calc(100% + 4px); left: 0; right: 0; z-index: 30; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-sm); box-shadow: 0 8px 24px rgba(0,0,0,0.08); padding: 8px; max-height: 280px; overflow-y: auto; }
.mt-icon-picker-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 4px; }
.mt-icon-tile { width: 38px; height: 38px; display: inline-flex; align-items: center; justify-content: center; background: transparent; border: 1px solid transparent; border-radius: var(--mt-radius-sm); color: var(--mt-text); cursor: pointer; transition: background .12s, border-color .12s; }
.mt-icon-tile:hover { background: var(--mt-primary-tint); border-color: var(--mt-primary); }
.mt-icon-tile.is-active { background: var(--mt-primary-tint); border-color: var(--mt-primary); }
.mt-icon-tile svg { width: 18px; height: 18px; }
.mt-icon-tile-clear { color: var(--mt-text-3); font-size: 14px; }
.mt-diag-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; padding: 14px; }
.mt-diag-card { padding: 14px 16px; background: var(--mt-surface); border: 1px solid var(--mt-border); border-radius: var(--mt-radius-sm); }
.mt-diag-card.is-warn { background: rgba(255, 159, 10, 0.08); border-color: rgba(255, 159, 10, 0.3); }
.mt-diag-eyebrow { font-size: 10px; font-weight: 600; letter-spacing: 0.04em; text-transform: uppercase; color: var(--mt-text-3); margin-bottom: 6px; }
.mt-diag-title { font-size: 14px; font-weight: 600; color: var(--mt-text); margin-bottom: 4px; }
.mt-diag-title em { font-style: normal; color: var(--mt-text-3); font-weight: 400; }
.mt-diag-meta { font-size: 12px; color: var(--mt-text-2); line-height: 1.5; }
.mt-diag-meta a { color: var(--mt-primary); text-decoration: underline; }
@media (max-width: 880px) { .mt-diag-grid { grid-template-columns: 1fr; } }

.mt-empty { text-align: center; padding: 40px 20px; color: var(--mt-text-2); }
.mt-empty-icon { width: 40px; height: 40px; margin: 0 auto 12px; color: var(--mt-text-3); }
.mt-empty-title { font-size: 15px; font-weight: 600; color: var(--mt-text); margin: 0 0 4px; }

.mt-alert { padding: 12px 16px; border-radius: var(--mt-radius); margin-bottom: 18px; font-size: 13px; border: 1px solid transparent; }
.mt-alert strong { font-weight: 600; }
.mt-alert-info    { background: var(--mt-primary-tint); border-color: rgba(0,113,227,0.20);   color: #0040A0; }
.mt-alert-success { background: var(--mt-success-tint); border-color: rgba(48,209,88,0.25);   color: var(--mt-success-text); }
.mt-alert-warning { background: var(--mt-warning-tint); border-color: rgba(255,159,10,0.25);  color: var(--mt-warning-text); }
.mt-alert-danger  { background: var(--mt-danger-tint);  border-color: rgba(255,59,48,0.25);   color: var(--mt-danger-text); }
.mt-alert ol, .mt-alert ul { margin: 6px 0 0 18px; padding: 0; }

.mt-detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.mt-detail-list { list-style: none; padding: 0; margin: 0; }
.mt-detail-list li { padding: 10px 0; border-bottom: 1px solid var(--mt-border); display: flex; align-items: center; justify-content: space-between; font-size: 14px; }
.mt-detail-list li:last-child { border-bottom: 0; }
.mt-detail-kicker { font-size: 11px; text-transform: uppercase; letter-spacing: 0.06em; color: var(--mt-text-3); margin: 16px 0 8px; font-weight: 600; }
.mt-detail-kicker:first-child { margin-top: 0; }
@media (max-width: 900px) { .mt-detail-grid { grid-template-columns: 1fr; } }
</style>

<script>
(function(){
    document.querySelectorAll('.mt-wrap input[maxlength], .mt-wrap textarea[maxlength]').forEach(function(el) {
        var counter = el.parentElement && el.parentElement.querySelector('.mt-charcount');
        if (!counter) return;
        var max = parseInt(el.getAttribute('maxlength'), 10);
        function update() {
            counter.textContent = el.value.length + '/' + max;
            counter.classList.toggle('is-over', el.value.length >= max);
        }
        el.addEventListener('input', update);
    });
})();
</script>
