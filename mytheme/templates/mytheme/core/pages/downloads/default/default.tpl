{* Hostnodes - Downloads (Apple-style): category browser + popular files.

   Rendered in the Hostnodes Apple visual language; content model from the WHMCS
   standard downloads vars (cross-checked against Lagom downloads.tpl).

   WHMCS standard variables expected:
     $dlcats        - array of categories, each: id, urlfriendlyname, name,
                      numarticles, description
     $mostdownloads - array of popular files, each: link, title, clientsonly,
                      filesize, description, type
   Demo data is injected only under ?preview=1 when no live data exists, so the
   design is reviewable without a configured WHMCS backend (see serverstatus).
*}

{* ---- Resolve real-data presence ---- *}
{assign var=hasCats value=false}
{if isset($dlcats) && $dlcats|@count > 0}{assign var=hasCats value=true}{/if}
{assign var=hasPopular value=false}
{if isset($mostdownloads) && $mostdownloads|@count > 0}{assign var=hasPopular value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{* ---- Preview demo fallback ---- *}
{assign var=dlDemo value=false}
{if !$hasCats && !$hasPopular && $isPreview}
    {assign var=dlDemo value=true}
    {assign var=dlcats value=[
        ['id'=>1,'urlfriendlyname'=>'control-panel-clients','name'=>'Control panel clients','numarticles'=>6,'description'=>'Desktop apps for cPanel, Plesk and DirectAdmin.'],
        ['id'=>2,'urlfriendlyname'=>'ftp-ssh-clients','name'=>'FTP & SSH clients','numarticles'=>4,'description'=>'FileZilla, Cyberduck, Termius configurations.'],
        ['id'=>3,'urlfriendlyname'=>'guides','name'=>'Guides & documentation','numarticles'=>12,'description'=>'PDF guides - getting started, migration, email.'],
        ['id'=>4,'urlfriendlyname'=>'backup-tools','name'=>'Backup tools','numarticles'=>5,'description'=>'CodeGuard agents, restore scripts, CLI utilities.'],
        ['id'=>5,'urlfriendlyname'=>'scripts-sdks','name'=>'Scripts & SDKs','numarticles'=>8,'description'=>'Deploy scripts, API SDKs (Python, Node, PHP).'],
        ['id'=>6,'urlfriendlyname'=>'branded-assets','name'=>'Branded assets','numarticles'=>3,'description'=>'Email signatures, logo pack, press kit.']
    ]}
    {assign var=mostdownloads value=[
        ['link'=>'#','title'=>'Getting started - Hostnodes client area','clientsonly'=>false,'filesize'=>'2.4 MB','description'=>'1,284 downloads','type'=>'pdf'],
        ['link'=>'#','title'=>'cPanel migration toolkit - v4.2','clientsonly'=>false,'filesize'=>'18.1 MB','description'=>'892 downloads','type'=>'zip'],
        ['link'=>'#','title'=>'Hostnodes CLI for macOS - arm64','clientsonly'=>true,'filesize'=>'34.6 MB','description'=>'612 downloads','type'=>'dmg'],
        ['link'=>'#','title'=>'Hostnodes CLI for Windows','clientsonly'=>false,'filesize'=>'22.3 MB','description'=>'441 downloads','type'=>'exe'],
        ['link'=>'#','title'=>'Email migration guide - MX records & DKIM','clientsonly'=>false,'filesize'=>'1.8 MB','description'=>'318 downloads','type'=>'pdf']
    ]}
{/if}

{assign var=dlFull value=false}
{if $hasCats || $hasPopular || $dlDemo}{assign var=dlFull value=true}{/if}
{if $dlFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/downloads.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.downloadstitle|default:'Downloads'}</h1>
    <p class="page-subtitle">{$LANG.downloadsintro|default:'Software, guides and templates for your Hostnodes account. Browse by category or search.'}</p>
</header>

{* ============================ FULL / POPULATED STATE ============================ *}
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
    <div class="dl-content">

        {* Search *}
        <div class="card" style="padding: 0;">
            <form method="post" action="{routePath('download-search')}" class="dl-searchbar">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="search" name="search" placeholder="{$LANG.downloadssearch|default:'Search downloads...'}" autocomplete="off">
            </form>
        </div>

        {* Categories *}
        {if isset($dlcats) && $dlcats|@count > 0}
        <div>
            <h2 class="dl-section-title">{$LANG.downloadscategories|default:'Browse by category'}</h2>
            <div class="dl-cats">
                {foreach $dlcats as $dlcat}
                    <a href="{routePath('download-by-cat', $dlcat.id, $dlcat.urlfriendlyname)}" class="card dl-cat">
                        <div class="dl-cat-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/></svg>
                        </div>
                        <div class="dl-cat-meta">
                            <div class="dl-cat-title">{$dlcat.name|escape} <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></div>
                            {if $dlcat.description}<div class="dl-cat-desc">{$dlcat.description|strip_tags}</div>{/if}
                            <div class="dl-cat-count">{$dlcat.numarticles|default:0} {$LANG.downloadsfiles|default:'files'}</div>
                        </div>
                    </a>
                {/foreach}
            </div>
        </div>
        {/if}

        {* Most popular *}
        {if isset($mostdownloads) && $mostdownloads|@count > 0}
        <div>
            <h2 class="dl-section-title">{$LANG.downloadspopular|default:'Most popular'}</h2>
            <div class="card dl-file-list">
                {foreach $mostdownloads as $download}
                    {assign var=ft value=$download.type|default:''|lower}
                    <a href="{$download.link|default:'#'}" class="dl-file-row">
                        {if $ft}
                        <div class="dl-file-ico {$ft|escape}">{$ft|upper|truncate:3:""|escape}</div>
                        {else}
                        <div class="dl-file-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></div>
                        {/if}
                        <div class="dl-file-meta">
                            <div class="dl-file-name">{$download.title|escape}</div>
                            <div class="dl-file-sub">
                                {if $download.clientsonly}<span class="dl-lock"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>{if $loggedin}{$LANG.restricted|default:'Restricted'}{else}{$LANG.loginrequired|default:'Login required'}{/if}</span>{/if}
                                {if $download.filesize}<span>{$download.filesize|escape}</span>{/if}
                                {if $download.description}<span class="dot">·</span><span>{$download.description|strip_tags}</span>{/if}
                            </div>
                        </div>
                        {if $download.clientsonly && !$loggedin}
                        <span class="dl-file-action" title="{$LANG.loginrequired|default:'Login required'}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        </span>
                        {else}
                        <span class="dl-file-action" title="{$LANG.downloadbutton|default:'Download'}">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                        </span>
                        {/if}
                    </a>
                {/foreach}
            </div>
        </div>
        {/if}

    </div>
</div>
</div>{* /.when-full *}
{/if}

{* ============================ EMPTY STATE ============================ *}
{if !$dlFull}
<div class="when-empty">
    <div class="card">
        <div class="dl-empty">
            <div class="dl-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </div>
            <p class="dl-empty-title">{$LANG.downloadsnone|default:'No downloads available'}</p>
            <p class="dl-empty-sub">{$LANG.downloadsnonesub|default:'There are no downloads in your account at this time. Check back later.'}</p>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="btn-primary">{$LANG.knowledgebasetitle|default:'Open knowledge base'}</a>
        </div>
    </div>
</div>
{/if}
