{* Hostnodes - Email history (Apple-style): emails sent to the client.

   WHMCS variables (cross-checked against Lagom clientareaemails.tpl):
     $emails - each: id, date, normalisedDate, subject, attachmentCount
   Rows open viewemail.php?id={id} in a popup window.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasEmails value=false}
{if isset($emails) && $emails|@count > 0}{assign var=hasEmails value=true}{/if}

{assign var=emDemo value=false}
{if !$hasEmails && $isPreview}
    {assign var=emDemo value=true}
    {assign var=emails value=[
        ['id'=>1,'date'=>'May 18, 2026 14:32','subject'=>'Invoice #1042 payment confirmation','attachmentCount'=>1],
        ['id'=>2,'date'=>'May 15, 2026 09:10','subject'=>'Your service has been activated','attachmentCount'=>0],
        ['id'=>3,'date'=>'May 11, 2026 18:45','subject'=>'Domain hendersondesign.com renewal notice','attachmentCount'=>0],
        ['id'=>4,'date'=>'May 02, 2026 08:00','subject'=>'Welcome to Hostnodes','attachmentCount'=>1]
    ]}
    {assign var=hasEmails value=true}
{/if}

{if $hasEmails}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). *}
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaemails.css?v={$myTheme.version|default:'1.0'}">
{if $mtAjaxTables}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$myTheme.version|default:'1.0'}"></script>
{/if}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <p class="eyebrow">{$LANG.accounttab|default:'Account'}</p>
    <h1>{$LANG.emailstitle|default:'Email history'}</h1>
    <p class="page-subtitle">{$LANG.emailsintro|default:'Messages we have sent to your account email address.'}</p>
</header>

<div class="em-split">
    <div class="em-main">
        {if $hasEmails}
        <div class="when-full">
            {if !$mtAjaxTables}
            <div class="em-toolbar">
                <div class="em-search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="search" id="emSearch" placeholder="{$LANG.search|default:'Search'}…" autocomplete="off" aria-label="{$LANG.search|default:'Search'}">
                </div>
            </div>
            {/if}
            <div class="card" style="padding: 0; overflow: hidden;">
                <table class="em-table" id="emTable"{if $mtAjaxTables} data-mt-action="tableEmails" data-mt-type="emails" data-mt-endpoint="{$WEB_ROOT}/clientarea.php" data-mt-order="0:desc" data-mt-length="10"{/if}>
                    <thead>
                        <tr>
                            {if !$mtAjaxTables}
                            <th><button type="button" class="em-sort" data-sort="date" data-dir="">{$LANG.clientareaemailsdate|default:'Date Sent'} <span class="em-sort-ico"></span></button></th>
                            <th><button type="button" class="em-sort" data-sort="subject" data-dir="">{$LANG.clientareaemailssubject|default:'Message Subject'} <span class="em-sort-ico"></span></button></th>
                            {else}
                            <th>{$LANG.clientareaemailsdate|default:'Date Sent'}</th>
                            <th>{$LANG.clientareaemailssubject|default:'Message Subject'}</th>
                            {/if}
                        </tr>
                    </thead>
                    <tbody>
                        {if !$mtAjaxTables}
                        {foreach $emails as $email}
                        <tr data-href="{$WEB_ROOT}/viewemail.php?id={$email.id|escape}" data-date="{$email.normalisedDate|default:''|escape}" data-subject="{$email.subject|strip_tags|escape}">
                            <td class="em-date">{$email.date|escape}</td>
                            <td>
                                <div class="em-subject">
                                    {if $email.attachmentCount > 0}<svg class="em-clip" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>{/if}
                                    <a href="{$WEB_ROOT}/viewemail.php?id={$email.id|escape}">{$email.subject|escape}</a>
                                </div>
                            </td>
                        </tr>
                        {/foreach}
                        {/if}
                    </tbody>
                </table>
            </div>
            {if $mtAjaxTables}
            <div class="mt-dt-foot">
                <span class="mt-dt-search"><input type="search" placeholder="{$LANG.search|default:'Search'}…" aria-label="{$LANG.search|default:'Search'}" data-mt-search data-mt-for="emTable"></span>
                <span class="spacer"></span>
                <span data-dt-info data-mt-for="emTable"></span>
                <div data-dt-pager data-mt-for="emTable"></div>
            </div>
            {else}
            <div class="em-footer">
                <div class="em-page-size">
                    {$LANG.show|default:'Show'}
                    <select id="emLength" aria-label="{$LANG.show|default:'Show'} {$LANG.entries|default:'entries'}">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span class="em-info" id="emInfo"></span>
                <div class="em-pages" id="emPages"></div>
            </div>
            {/if}
        </div>
        {/if}

        {if !$hasEmails}
        <div class="when-empty">
            <div class="card">
                <div class="em-empty">
                    <div class="em-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                    </div>
                    <p class="em-empty-title">{$LANG.clientareaemailsnonetitle|default:'No emails yet'}</p>
                    <p class="em-empty-sub">{$LANG.clientareaemailsnone|default:'Messages we send to your account email will be listed here.'}</p>
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="btn-primary">{$LANG.accountdetails|default:'Account details'}</a>
                </div>
            </div>
        </div>
        {/if}
    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                {$LANG.emailstitle|default:'Email History'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.security|default:'Security'}
            </a>
        </div>
    </aside>
</div>

{if $hasEmails && !$mtAjaxTables}
<script>
{literal}
(function () {
    var table = document.getElementById('emTable');
    if (!table) { return; }
    var tbody = table.querySelector('tbody');
    var allRows = Array.prototype.slice.call(tbody.querySelectorAll('tr'));
    allRows.forEach(function (r, i) { r.setAttribute('data-idx', String(i)); });

    var searchInp = document.getElementById('emSearch');
    var lengthSel = document.getElementById('emLength');
    var info = document.getElementById('emInfo');
    var pagesEl = document.getElementById('emPages');
    var L = { showing: 'Showing', to: '–', of: 'of', none: 'No matching emails', filtered: 'filtered from' };

    var state = { q: '', pageSize: 10, page: 1, sortKey: '', sortDir: '' };

    function filtered() {
        var q = state.q.trim().toLowerCase();
        if (!q) { return allRows.slice(); }
        return allRows.filter(function (r) {
            var subj = (r.getAttribute('data-subject') || '').toLowerCase();
            var dateCell = r.querySelector('.em-date');
            var date = dateCell ? dateCell.textContent.toLowerCase() : '';
            return subj.indexOf(q) > -1 || date.indexOf(q) > -1;
        });
    }
    function sorted(rows) {
        if (!state.sortDir) {
            return rows.slice().sort(function (a, b) { return (+a.getAttribute('data-idx')) - (+b.getAttribute('data-idx')); });
        }
        var mul = state.sortDir === 'asc' ? 1 : -1;
        var key = state.sortKey;
        return rows.slice().sort(function (a, b) {
            var va, vb;
            if (key === 'date') {
                va = a.getAttribute('data-date') || ''; vb = b.getAttribute('data-date') || '';
                var na = parseFloat(va), nb = parseFloat(vb);
                if (!isNaN(na) && !isNaN(nb)) { return (na - nb) * mul; }
            } else {
                va = (a.getAttribute('data-subject') || '').toLowerCase();
                vb = (b.getAttribute('data-subject') || '').toLowerCase();
            }
            return va < vb ? -mul : va > vb ? mul : 0;
        });
    }
    function pageWindow(cur, total) {
        var out = [];
        if (total <= 7) { for (var i = 1; i <= total; i++) { out.push(i); } return out; }
        out.push(1);
        var s = Math.max(2, cur - 1), e = Math.min(total - 1, cur + 1);
        if (s > 2) { out.push('…'); }
        for (var j = s; j <= e; j++) { out.push(j); }
        if (e < total - 1) { out.push('…'); }
        out.push(total);
        return out;
    }
    function mkBtn(html, opts) {
        var b = document.createElement('button');
        b.type = 'button';
        b.innerHTML = html;
        if (opts.disabled) { b.disabled = true; }
        if (opts.active) { b.className = 'active'; }
        if (!opts.disabled && !opts.active && typeof opts.go === 'number') {
            b.addEventListener('click', function () { state.page = opts.go; render(); });
        }
        return b;
    }
    var PREV = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>';
    var NEXT = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';

    function render() {
        var rows = sorted(filtered());
        var total = rows.length;
        var pages = Math.max(1, Math.ceil(total / state.pageSize));
        if (state.page > pages) { state.page = pages; }
        if (state.page < 1) { state.page = 1; }
        var start = total ? (state.page - 1) * state.pageSize : 0;
        var end = Math.min(start + state.pageSize, total);

        allRows.forEach(function (r) { r.style.display = 'none'; });
        for (var i = start; i < end; i++) { rows[i].style.display = ''; tbody.appendChild(rows[i]); }

        if (info) {
            if (total === 0) {
                info.textContent = L.none;
            } else {
                var base = L.showing + ' ' + (start + 1) + L.to + end + ' ' + L.of + ' ' + total;
                info.textContent = (state.q && total !== allRows.length) ? (base + ' (' + L.filtered + ' ' + allRows.length + ')') : base;
            }
        }
        if (pagesEl) {
            pagesEl.innerHTML = '';
            pagesEl.appendChild(mkBtn(PREV, { disabled: state.page <= 1, go: state.page - 1 }));
            pageWindow(state.page, pages).forEach(function (p) {
                if (p === '…') {
                    var s = document.createElement('span');
                    s.className = 'em-ellipsis'; s.textContent = '…';
                    pagesEl.appendChild(s);
                } else {
                    pagesEl.appendChild(mkBtn(String(p), { active: p === state.page, go: p }));
                }
            });
            pagesEl.appendChild(mkBtn(NEXT, { disabled: state.page >= pages, go: state.page + 1 }));
        }
    }

    if (searchInp) { searchInp.addEventListener('input', function () { state.q = this.value; state.page = 1; render(); }); }
    if (lengthSel) { lengthSel.addEventListener('change', function () { state.pageSize = parseInt(this.value, 10) || 10; state.page = 1; render(); }); }

    table.querySelectorAll('.em-sort').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var dir = btn.getAttribute('data-dir');
            var next = dir === '' ? 'asc' : dir === 'asc' ? 'desc' : '';
            table.querySelectorAll('.em-sort').forEach(function (b) { b.setAttribute('data-dir', ''); b.classList.remove('active'); });
            btn.setAttribute('data-dir', next);
            if (next) { btn.classList.add('active'); }
            state.sortKey = btn.getAttribute('data-sort');
            state.sortDir = next;
            state.page = 1;
            render();
        });
    });

    allRows.forEach(function (row) {
        row.addEventListener('click', function (e) {
            if (e.target.closest('a')) { return; }
            window.open(row.getAttribute('data-href'), 'emailWin', 'width=680,height=520,scrollbars=yes');
        });
    });

    render();
})();
{/literal}
</script>
{/if}
