{* Hostnodes - Server Status (Apple-style status page).

   Combines the WHMCS standard "six" theme + Lagom data model, rendered in the
   Hostnodes Apple visual language.

   WHMCS standard variables expected:
     $servers      - array keyed by $num, each: name, phpinfourl
                     (port/load/uptime are filled live via AJAX, see script below)
     $issues       - array of network issues, each: title, status, priority,
                     rawPriority, type, server, affecting, startdate, enddate,
                     lastupdate, clientaffected, description
     $opencount    - count of open issues
     $scheduledcount / $resolvedcount - issue counts by view
     $view         - active filter: '' | open | scheduled | resolved
     $noissuesmsg  - "no issues" message
     $prevpage / $nextpage - pagination targets
*}

{* ---- Resolve real-data presence ---- *}
{assign var=hasServers value=false}
{if isset($servers) && $servers|@count > 0}{assign var=hasServers value=true}{/if}
{assign var=hasIssues value=false}
{if isset($issues) && $issues|@count > 0}{assign var=hasIssues value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=ssOpen value=$opencount|default:0}
{assign var=ssScheduled value=$scheduledcount|default:0}
{assign var=ssResolved value=$resolvedcount|default:0}
{assign var=ssView value=$view|default:''}

{* ---- Preview demo fallback: only when there is no live data AND ?preview=1,
        so the design is reviewable without a configured WHMCS backend. ---- *}
{assign var=ssDemo value=false}
{if !$hasServers && !$hasIssues && $isPreview}
    {assign var=ssDemo value=true}
    {assign var=servers value=[
        ['name' => 'web-fra-01.hostnodes.com', 'phpinfourl' => '#', 'demoHttp' => 'up', 'demoFtp' => 'up', 'demoPop3' => 'up', 'demoLoad' => '0.42', 'demoLoadPct' => 21, 'demoUptime' => '142 days'],
        ['name' => 'web-fra-02.hostnodes.com', 'phpinfourl' => '#', 'demoHttp' => 'up', 'demoFtp' => 'up', 'demoPop3' => 'down', 'demoLoad' => '1.86', 'demoLoadPct' => 62, 'demoUptime' => '142 days'],
        ['name' => 'db-ash-01.hostnodes.com', 'phpinfourl' => '#', 'demoHttp' => 'up', 'demoFtp' => 'up', 'demoPop3' => 'up', 'demoLoad' => '0.71', 'demoLoadPct' => 35, 'demoUptime' => '88 days'],
        ['name' => 'mail-ams-01.hostnodes.com', 'phpinfourl' => '#', 'demoHttp' => 'down', 'demoFtp' => 'down', 'demoPop3' => 'down', 'demoLoad' => '--', 'demoLoadPct' => 0, 'demoUptime' => '--']
    ]}
    {assign var=issues value=[
        ['title' => 'Packet loss on AMS mail cluster', 'status' => 'Open', 'priority' => 'Critical', 'rawPriority' => 'Critical', 'type' => 'Server', 'server' => 'mail-ams-01.hostnodes.com', 'affecting' => '', 'startdate' => 'May 22, 2026 09:14', 'enddate' => '', 'lastupdate' => '12 minutes ago', 'clientaffected' => true, 'description' => 'We are investigating elevated packet loss affecting inbound mail on the Amsterdam cluster. Engineers are engaged and a fix is being rolled out.'],
        ['title' => 'Scheduled kernel upgrades - Frankfurt', 'status' => 'Scheduled', 'priority' => 'Medium', 'rawPriority' => 'Medium', 'type' => 'Other', 'server' => '', 'affecting' => 'Frankfurt region', 'startdate' => 'May 25, 2026 02:00', 'enddate' => 'May 25, 2026 04:00', 'lastupdate' => '2 hours ago', 'clientaffected' => false, 'description' => 'Rolling kernel and security updates across the Frankfurt fleet. Brief reboots expected per node; services migrate live where possible.']
    ]}
    {assign var=ssOpen value=1}
    {assign var=ssScheduled value=1}
{/if}

{assign var=ssFull value=false}
{if $hasServers || $hasIssues || $ssDemo}{assign var=ssFull value=true}{/if}
{if $ssFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* Overall state for the status banner: down (open) > warn (scheduled) > ok *}
{if $ssOpen > 0}{assign var=ssState value='down'}
{elseif $ssScheduled > 0}{assign var=ssState value='warn'}
{else}{assign var=ssState value='ok'}{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/serverstatus.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.serverstatustitle|default:'Server Status'}</h1>
    <p class="page-subtitle">{$LANG.serverstatusheadingtext|default:'Live availability of the Hostnodes network, plus any active incidents and scheduled maintenance.'}</p>
</header>

<div class="ss-split">
    <div class="ss-main">

        {* ============================ EMPTY / ALL-CLEAR STATE ============================ *}
        <div class="when-empty">
            <div class="ss-overall ok">
                <span class="ss-overall-dot"></span>
                <div class="ss-overall-text">
                    <div class="ss-overall-title">{$LANG.serverstatusalloperational|default:'All systems operational'}</div>
                    <div class="ss-overall-sub">{$LANG.serverstatusnoincidents|default:'No incidents reported. Every monitored service is responding normally.'}</div>
                </div>
            </div>
            <div class="card">
                <div class="ss-empty">
                    <div class="ss-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <p class="ss-empty-title">{$LANG.serverstatusnoservers|default:'No servers are being monitored yet'}</p>
                    <p class="ss-empty-sub">{$LANG.serverstatusnoserverssub|default:'When network monitoring is enabled, each server and its services will appear here with live uptime indicators.'}</p>
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-secondary">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                        {$LANG.serverstatusreport|default:'Report a problem'}
                    </a>
                </div>
            </div>
        </div>

        {* ============================ FULL / POPULATED STATE ============================ *}
        {if $ssFull}
        <div class="when-full">

            {* ---- Overall status banner ---- *}
            <div class="ss-overall {$ssState}">
                <span class="ss-overall-dot"></span>
                <div class="ss-overall-text">
                    {if $ssState == 'down'}
                        <div class="ss-overall-title">{if $ssOpen == 1}{$LANG.serverstatusoneincident|default:'1 active incident'}{else}{$ssOpen} {$LANG.serverstatusincidents|default:'active incidents'}{/if}</div>
                        <div class="ss-overall-sub">{$LANG.serverstatusinvestigating|default:'Our team is engaged and posting updates below.'}</div>
                    {elseif $ssState == 'warn'}
                        <div class="ss-overall-title">{$LANG.serverstatusmaintenance|default:'Scheduled maintenance planned'}</div>
                        <div class="ss-overall-sub">{$LANG.serverstatusmaintenancesub|default:'All services are operational. See the planned work below.'}</div>
                    {else}
                        <div class="ss-overall-title">{$LANG.serverstatusalloperational|default:'All systems operational'}</div>
                        <div class="ss-overall-sub">{$LANG.serverstatusnoincidents|default:'No incidents reported. Every monitored service is responding normally.'}</div>
                    {/if}
                </div>
                {if $ssDemo}<span class="ss-overall-badge">{$LANG.preview|default:'Preview'}</span>{/if}
            </div>

            {* ---- Issue filter tabs (Lagom-style view filter) ---- *}
            {if $hasIssues || $ssDemo || $ssOpen > 0 || $ssScheduled > 0 || $ssResolved > 0}
            <div class="ss-filter">
                <a href="{$WEB_ROOT}/serverstatus.php" class="ss-filter-tab{if !$ssView} active{/if}">{$LANG.all|default:'All'}</a>
                <a href="{$WEB_ROOT}/serverstatus.php?view=open" class="ss-filter-tab{if $ssView == 'open'} active{/if}">{$LANG.networkissuesstatusopen|default:'Active'}{if $ssOpen > 0} <span class="ss-filter-count">{$ssOpen}</span>{/if}</a>
                <a href="{$WEB_ROOT}/serverstatus.php?view=scheduled" class="ss-filter-tab{if $ssView == 'scheduled'} active{/if}">{$LANG.networkissuesstatusscheduled|default:'Scheduled'}{if $ssScheduled > 0} <span class="ss-filter-count">{$ssScheduled}</span>{/if}</a>
                <a href="{$WEB_ROOT}/serverstatus.php?view=resolved" class="ss-filter-tab{if $ssView == 'resolved'} active{/if}">{$LANG.networkissuesstatusresolved|default:'Resolved'}</a>
            </div>
            {/if}

            {* ---- Incidents ---- *}
            {if $hasIssues || $ssDemo}
            <section class="ss-section">
                <h2 class="ss-section-title">{$LANG.networkstatustitle|default:'Incidents & maintenance'}</h2>
                <div class="ss-incidents">
                    {foreach $issues as $issue}
                        {assign var=sev value=$issue.rawPriority|default:$issue.priority|lower}
                        {assign var=sevClass value='medium'}
                        {if $sev == 'Critical' || $sev == 'critical'}{assign var=sevClass value='critical'}
                        {elseif $sev == 'High' || $sev == 'high'}{assign var=sevClass value='high'}
                        {elseif $sev == 'Low' || $sev == 'low'}{assign var=sevClass value='low'}
                        {else}{assign var=sevClass value='medium'}{/if}
                        {assign var=statusLower value=$issue.status|default:''|lower}
                        {if $statusLower == 'scheduled'}{assign var=sevClass value='scheduled'}{/if}
                        <article class="ss-incident {$sevClass}">
                            <div class="ss-incident-bar"></div>
                            <div class="ss-incident-body">
                                <div class="ss-incident-head">
                                    <h3 class="ss-incident-title">{$issue.title|escape}</h3>
                                    <span class="ss-sev {$sevClass}">{$issue.priority|default:$issue.rawPriority|escape}</span>
                                </div>
                                {if $issue.server || $issue.affecting}
                                <div class="ss-incident-affecting">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                                    {$LANG.networkissuesaffecting|default:'Affecting'} {$issue.type|default:''|escape} - {if $issue.server}{$issue.server|escape}{else}{$issue.affecting|escape}{/if}
                                </div>
                                {/if}
                                {if $issue.clientaffected}
                                <div class="ss-incident-flag">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                    {$LANG.networkissuesaffectingyou|default:'This incident may be affecting your services.'}
                                </div>
                                {/if}
                                {if $issue.description}<p class="ss-incident-desc">{$issue.description|strip_tags}</p>{/if}
                                <div class="ss-incident-meta">
                                    {if $issue.status}<span class="ss-meta-item"><span class="ss-status-dot {$sevClass}"></span>{$issue.status|escape}</span>{/if}
                                    {if $issue.startdate}<span class="ss-meta-item">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                        {$issue.startdate|escape}{if $issue.enddate} - {$issue.enddate|escape}{/if}
                                    </span>{/if}
                                    {if $issue.lastupdate}<span class="ss-meta-item">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                        {$LANG.networkissueslastupdated|default:'Updated'} {$issue.lastupdate|escape}
                                    </span>{/if}
                                </div>
                            </div>
                        </article>
                    {foreachelse}
                        <div class="ss-noissues">{$noissuesmsg|default:$LANG.networkstatusnone|default:'No incidents to report.'}</div>
                    {/foreach}
                </div>

                {* ---- Pagination (only meaningful with live data) ---- *}
                {if !$ssDemo && (isset($prevpage) || isset($nextpage)) && ($prevpage || $nextpage)}
                <div class="ss-pages">
                    <a class="ss-page-btn{if !$prevpage} disabled{/if}" href="{if $prevpage}?{if $ssView}view={$ssView}&amp;{/if}page={$prevpage}{else}#{/if}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                        {$LANG.previouspage|default:'Previous'}
                    </a>
                    <a class="ss-page-btn{if !$nextpage} disabled{/if}" href="{if $nextpage}?{if $ssView}view={$ssView}&amp;{/if}page={$nextpage}{else}#{/if}">
                        {$LANG.nextpage|default:'Next'}
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
                {/if}
            </section>
            {/if}

            {* ---- Servers ---- *}
            {if $hasServers || $ssDemo}
            <section class="ss-section">
                <h2 class="ss-section-title">{$LANG.serverstatusservers|default:'Network & servers'}</h2>
                <div class="card ss-servers-card">
                    <div class="ss-servers" role="table">
                        <div class="ss-server-head" role="row">
                            <span role="columnheader">{$LANG.servername|default:'Server'}</span>
                            <span role="columnheader" class="ss-col-ports">{$LANG.serverstatusservices|default:'Services'}</span>
                            <span role="columnheader" class="ss-col-num">{$LANG.serverstatusserverload|default:'Load'}</span>
                            <span role="columnheader" class="ss-col-num">{$LANG.serverstatusuptime|default:'Uptime'}</span>
                            <span role="columnheader" class="ss-col-link"></span>
                        </div>
                        {foreach $servers as $num => $server}
                            <div class="ss-server" role="row"{if !$ssDemo} data-num="{$num}"{/if}>
                                <div class="ss-server-name" role="cell">
                                    {if $ssDemo}<span class="ss-server-status {if $server.demoHttp == 'down'}down{else}up{/if}"></span>{else}<span class="ss-server-status loading"></span>{/if}
                                    <span class="ss-server-host">{$server.name|escape}</span>
                                </div>
                                <div class="ss-server-ports" role="cell">
                                    {if $ssDemo}
                                        <span class="ss-port {$server.demoHttp}"><span class="ss-port-dot"></span>HTTP</span>
                                        <span class="ss-port {$server.demoFtp}"><span class="ss-port-dot"></span>FTP</span>
                                        <span class="ss-port {$server.demoPop3}"><span class="ss-port-dot"></span>POP3</span>
                                    {else}
                                        <span class="ss-port loading" id="port80_{$num}"><span class="ss-port-dot"></span>HTTP</span>
                                        <span class="ss-port loading" id="port21_{$num}"><span class="ss-port-dot"></span>FTP</span>
                                        <span class="ss-port loading" id="port110_{$num}"><span class="ss-port-dot"></span>POP3</span>
                                    {/if}
                                </div>
                                <div class="ss-server-load ss-col-num" role="cell">
                                    {if $ssDemo}
                                        <span class="ss-load-val">{$server.demoLoad}</span>
                                        <span class="ss-load-bar"><span class="ss-load-fill" style="width: {$server.demoLoadPct}%;"></span></span>
                                    {else}
                                        <span id="load{$num}" class="ss-load-val ss-muted">--</span>
                                    {/if}
                                </div>
                                <div class="ss-server-uptime ss-col-num" role="cell">
                                    {if $ssDemo}<span>{$server.demoUptime}</span>{else}<span id="uptime{$num}" class="ss-muted">--</span>{/if}
                                </div>
                                <div class="ss-server-link ss-col-link" role="cell">
                                    {if isset($server.phpinfourl) && $server.phpinfourl && $server.phpinfourl != '#'}
                                    <a href="{$server.phpinfourl}" target="_blank" rel="noopener" title="{$LANG.serverstatusphpinfo|default:'PHP info'}">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </a>
                                    {/if}
                                </div>
                            </div>
                        {foreachelse}
                            <div class="ss-server-empty">{$LANG.serverstatusnoservers|default:'No servers to display.'}</div>
                        {/foreach}
                    </div>
                </div>
                <p class="ss-legend">
                    <span class="ss-legend-item"><span class="ss-port-dot up"></span>{$LANG.serverstatusup|default:'Operational'}</span>
                    <span class="ss-legend-item"><span class="ss-port-dot down"></span>{$LANG.serverstatusdown|default:'Disrupted'}</span>
                    <span class="ss-legend-item"><span class="ss-port-dot loading"></span>{$LANG.serverstatuschecking|default:'Checking'}</span>
                </p>
            </section>
            {/if}

        </div>{* /.when-full *}
        {/if}
    </div>{* /.ss-main *}

    {* ============================ Support sub-nav ============================ *}
    <aside class="ss-aside">
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
            <a href="{$WEB_ROOT}/downloads.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                {$LANG.downloadstitle|default:'Downloads'}
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                {$LANG.networkstatus|default:'Server status'}
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open ticket'}
            </a>
        </div>
    </aside>
</div>{* /.ss-split *}

{if $hasServers && !$ssDemo}
<script>
{literal}
(function () {
    // Self-contained port checks against the standard WHMCS endpoint, rendered
    // as Apple-style status dots (we set classes rather than injecting WHMCS's
    // gif markup so the visual language stays consistent).
    function mtCheckPort(row, num, port) {
        var el = document.getElementById('port' + port + '_' + num);
        if (!el) return;
        var done = function (up) {
            el.classList.remove('loading');
            el.classList.add(up ? 'up' : 'down');
            mtRollUp(row);
        };
        try {
            fetch('serverstatus.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'ping=1&num=' + encodeURIComponent(num) + '&port=' + encodeURIComponent(port),
                credentials: 'same-origin'
            })
            .then(function (r) { return r.text(); })
            .then(function (t) { done(/online/i.test(t)); })
            .catch(function () { done(false); });
        } catch (e) { done(false); }
    }

    // Aggregate the row's port dots into the server's overall status dot.
    function mtRollUp(row) {
        var ports = row.querySelectorAll('.ss-server-ports .ss-port');
        var dot = row.querySelector('.ss-server-status');
        if (!dot || !ports.length) return;
        var pending = false, anyDown = false;
        ports.forEach(function (p) {
            if (p.classList.contains('loading')) pending = true;
            if (p.classList.contains('down')) anyDown = true;
        });
        if (pending) return;
        dot.classList.remove('loading');
        dot.classList.add(anyDown ? 'down' : 'up');
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.ss-server[data-num]').forEach(function (row) {
            var num = row.getAttribute('data-num');
            mtCheckPort(row, num, 80);
            mtCheckPort(row, num, 21);
            mtCheckPort(row, num, 110);
            // Load + uptime: defer to WHMCS core getStats if present (fills
            // #load{num} / #uptime{num}); otherwise the cells stay muted.
            if (typeof getStats === 'function') {
                try { getStats(num); } catch (e) {}
            }
        });
    });
})();
{/literal}
</script>
{/if}
