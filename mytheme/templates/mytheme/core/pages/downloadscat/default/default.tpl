{* Hostnodes - Download category (Apple-style): files within a category.

   WHMCS standard variables expected (downloads.php?action=displaycat&catid=X):
     $pagetitle     - category name
     $downloads     - files in this category, each: link, title, clientsonly,
                      filesize, description, type
     $dlcats        - subcategories, each: id, urlfriendlyname, name, numarticles
   Cross-checked against Lagom downloadscat.tpl. Demo data under ?preview=1.
*}

{assign var=hasFiles value=false}
{if isset($downloads) && $downloads|@count > 0}{assign var=hasFiles value=true}{/if}
{assign var=hasSubcats value=false}
{if isset($dlcats) && $dlcats|@count > 0}{assign var=hasSubcats value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=dlDemo value=false}
{if !$hasFiles && !$hasSubcats && $isPreview}
    {assign var=dlDemo value=true}
    {assign var=downloads value=[
        ['link'=>'#','title'=>'Getting started - Hostnodes client area','clientsonly'=>false,'filesize'=>'2.4 MB','description'=>'Walk-through of the client portal - services, billing, domains, DNS and support.','type'=>'pdf','isnew'=>true],
        ['link'=>'#','title'=>'Email migration guide - MX records & DKIM','clientsonly'=>false,'filesize'=>'1.8 MB','description'=>'Zero-downtime email migration. Covers MX, SPF, DKIM, DMARC and mail-flow testing.','type'=>'pdf','isnew'=>false],
        ['link'=>'#','title'=>'cPanel to Hostnodes migration playbook','clientsonly'=>false,'filesize'=>'3.1 MB','description'=>'Pre-checks, backup capture, account transfer, DNS cutover and verification steps.','type'=>'pdf','isnew'=>false],
        ['link'=>'#','title'=>'SSL certificate installation - Apache & nginx','clientsonly'=>false,'filesize'=>'1.3 MB','description'=>'Generate CSRs, install issued certs, harden TLS and enable OCSP stapling.','type'=>'pdf','isnew'=>false],
        ['link'=>'#','title'=>'Migration scripts bundle - shell & rsync','clientsonly'=>true,'filesize'=>'6.7 MB','description'=>'Curated shell scripts for parallel rsync, database dumps, and account export.','type'=>'zip','isnew'=>false],
        ['link'=>'#','title'=>'WordPress hardening checklist','clientsonly'=>false,'filesize'=>'0.9 MB','description'=>'30-point checklist - from hosting-level controls down to plugin hygiene and 2FA.','type'=>'pdf','isnew'=>false]
    ]}
    {assign var=hasFiles value=true}
{/if}

{assign var=dlFull value=false}
{if $hasFiles || $hasSubcats}{assign var=dlFull value=true}{/if}
{if $dlFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{assign var=catName value=$pagetitle|default:$LANG.downloadstitle|default:'Downloads'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/downloadscat.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$catName|escape}</h1>
    <p class="page-subtitle">{$LANG.downloadscatintro|default:'Files in this category. Search, filter by type, or download directly.'}</p>
    {if $hasFiles}
    <div class="page-header-meta">
        <span>{$downloads|@count} {$LANG.downloadsfiles|default:'files'}</span>
    </div>
    {/if}
</header>

{if $dlFull}
<div class="when-full">
<div class="dl-split">

    {* ---- LEFT: Support sub-nav ---- *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.supporttab|default:'Support'}</div>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.mytickets|default:'My support tickets'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                {$LANG.announcementstitle|default:'Announcements'}
            </a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                {$LANG.knowledgebasetitle|default:'Knowledgebase'}
            </a>
            <a href="{$WEB_ROOT}/downloads.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                {$LANG.downloadstitle|default:'Downloads'}
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                {$LANG.networkstatus|default:'Server status'}
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open ticket'}
            </a>
        </div>
    </aside>

    {* ---- RIGHT: content ---- *}
    <div style="min-width: 0;">
        <div class="card" style="padding: 0;">

            <div class="dl-cat-banner">
                <div class="dl-cat-banner-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                </div>
                <div class="dl-cat-banner-meta">
                    <div class="dl-cat-banner-title">{$catName|escape}</div>
                    <div class="dl-cat-banner-sub">{$LANG.downloadscatbanner|default:'Documents and tools in this category, ready to download.'}</div>
                </div>
            </div>

            {* ---- Subcategories (if any) ---- *}
            {if $hasSubcats}
            {foreach $dlcats as $sub}
                <a href="{routePath('download-by-cat', $sub.id, $sub.urlfriendlyname)}" class="dl-file-row">
                    <div class="dl-subcat-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/></svg>
                    </div>
                    <div class="dl-file-meta">
                        <div class="dl-file-name">{$sub.name|escape}</div>
                        <div class="dl-file-sub"><span>{$sub.numarticles|default:0} {$LANG.downloadsfiles|default:'files'}</span></div>
                    </div>
                    <div class="dl-file-actions">
                        <span class="dl-dl-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>{$LANG.viewcart|default:'Open'}</span>
                    </div>
                </a>
            {/foreach}
            {/if}

            {* ---- Files ---- *}
            {if $hasFiles}
            <div class="dl-toolbar">
                <div class="dl-search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="search" id="dlCatSearch" placeholder="{$LANG.downloadssearchincat|default:'Search in this category...'}" autocomplete="off">
                </div>
                <div class="dl-filters" role="tablist">
                    <button type="button" class="active" data-type="all">{$LANG.all|default:'All'}</button>
                    <button type="button" data-type="pdf">PDF</button>
                    <button type="button" data-type="zip">ZIP</button>
                    <button type="button" data-type="other">{$LANG.other|default:'Other'}</button>
                </div>
                <div class="dl-toolbar-spacer"></div>
                <select class="dl-sort" id="dlSort" aria-label="{$LANG.sortby|default:'Sort by'}">
                    <option value="recent">{$LANG.sortrecent|default:'Most recent'}</option>
                    <option value="name">{$LANG.sortalpha|default:'Alphabetical'}</option>
                </select>
            </div>

            <div id="dlcatList">
                {foreach $downloads as $download}
                    {assign var=ft value=$download.type|default:''|lower}
                    <div class="dl-file-row" data-type="{$ft|escape}" data-name="{$download.title|strip_tags|lower|escape}" data-idx="{$download@index}">
                        {if $ft}
                        <div class="dl-file-ico {$ft|escape}">{$ft|upper|truncate:3:""|escape}</div>
                        {else}
                        <div class="dl-file-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
                        {/if}
                        <div class="dl-file-meta">
                            <div class="dl-file-name">
                                {$download.title|escape}
                                {if $download.isnew}<span class="dl-file-new-pill">{$LANG.new|default:'New'}</span>{/if}
                                {if $download.clientsonly}<span class="dl-lock"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>{if $loggedin}{$LANG.restricted|default:'Restricted'}{else}{$LANG.loginrequired|default:'Login required'}{/if}</span>{/if}
                            </div>
                            {if $download.description}<div class="dl-file-desc">{$download.description|strip_tags}</div>{/if}
                            <div class="dl-file-sub">
                                {if $download.filesize}<span>{$download.filesize|escape}</span>{/if}
                            </div>
                        </div>
                        <div class="dl-file-actions">
                            {if $download.clientsonly && !$loggedin}
                            <a href="{$download.link|default:'#'|escape}" class="dl-dl-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>{$LANG.login|default:'Log in'}</a>
                            {else}
                            <a href="{$download.link|default:'#'|escape}" class="dl-dl-btn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>{$LANG.downloadbutton|default:'Download'}</a>
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>

            <div class="dl-footer">
                <span>{$LANG.recordscount|default:'Showing'} {$downloads|@count}</span>
                <div class="spacer"></div>
                <a href="{$WEB_ROOT}/downloads.php">{$LANG.downloadsall|default:'All downloads'}</a>
            </div>
            {/if}

        </div>
    </div>
</div>
</div>{* /.when-full *}
{/if}

{if !$dlFull}
<div class="when-empty">
    <div class="card">
        <div class="dl-empty">
            <div class="dl-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            </div>
            <p class="dl-empty-title">{$LANG.downloadsnone|default:'No downloads in this category'}</p>
            <p class="dl-empty-sub">{$LANG.downloadscatempty|default:"This category doesn't have any downloads yet."}</p>
            <a href="{$WEB_ROOT}/downloads.php" class="btn-primary">{$LANG.downloadsall|default:'All downloads'}</a>
        </div>
    </div>
</div>
{/if}

{if $hasFiles}
<script>
{literal}
(function () {
    var root = document.getElementById('dlcatList');
    if (!root) return;
    var rows = Array.prototype.slice.call(root.querySelectorAll('.dl-file-row'));
    var pills = document.querySelectorAll('.dl-filters button');
    var sortSel = document.getElementById('dlSort');
    var searchInp = document.getElementById('dlCatSearch');
    var curType = 'all';

    function apply() {
        var q = (searchInp && searchInp.value || '').toLowerCase();
        rows.forEach(function (r) {
            var t = r.getAttribute('data-type') || '';
            var name = r.getAttribute('data-name') || '';
            var typeOk = curType === 'all' || (curType === 'other' ? (t !== 'pdf' && t !== 'zip') : t === curType);
            var qOk = !q || name.indexOf(q) !== -1;
            r.hidden = !(typeOk && qOk);
        });
    }

    pills.forEach(function (p) {
        p.addEventListener('click', function () {
            pills.forEach(function (x) { x.classList.remove('active'); });
            p.classList.add('active');
            curType = p.getAttribute('data-type') || 'all';
            apply();
        });
    });
    if (searchInp) { searchInp.addEventListener('input', apply); }
    if (sortSel) {
        sortSel.addEventListener('change', function () {
            var sorted = rows.slice();
            if (sortSel.value === 'name') {
                sorted.sort(function (a, b) { return (a.getAttribute('data-name') || '').localeCompare(b.getAttribute('data-name') || ''); });
            } else {
                sorted.sort(function (a, b) { return (parseInt(a.getAttribute('data-idx'), 10) || 0) - (parseInt(b.getAttribute('data-idx'), 10) || 0); });
            }
            sorted.forEach(function (r) { root.appendChild(r); });
        });
    }
})();
{/literal}
</script>
{/if}
