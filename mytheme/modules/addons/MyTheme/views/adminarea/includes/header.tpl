{* Hostnodes admin shell (Hadrian visual language) -- opens. Footer closes it.
   Apple-style: flat brand bar, segmented pill nav, off-white bg, light/dark.
   All shell CSS + JS live in footer.tpl so they load once per page. *}

{* Map currentAction -> primary nav section so sub-views highlight their parent. *}
{$mt_action = $currentAction|default:'info'}
{$mt_nav = $mt_action}
{if $mt_action == 'index' || $mt_action == 'info' || $mt_action == 'license' || $mt_action == 'templates' || $mt_action == 'template'}
    {$mt_nav = 'info'}
{elseif $mt_action == 'editStyle'}
    {$mt_nav = 'styles'}
{elseif $mt_action == 'editMenu'}
    {$mt_nav = 'menu'}
{/if}

<div class="mt-wrap" id="mt-admin-root" data-theme="light">
{literal}<script>(function(){try{var w=document.getElementById('mt-admin-root');var t=localStorage.getItem('mytheme-admin-theme');if(w&&(t==='dark'||t==='light'))w.setAttribute('data-theme',t);}catch(e){}})();</script>{/literal}

{* Full-width admin fallback. The sidebar/title-hiding CSS is injected into the
   admin <head> by the AdminAreaHeadOutput hook (hooks.php) so it applies before
   first paint -- no sidebar flash. This script is a structural belt-and-braces
   for admin layouts whose sidebar/content ids differ from the CSS selectors;
   the head CSS has already hidden the common case, so this never reintroduces a
   flash -- it only widens the column / clears margins where CSS could not. *}
{literal}<script>
(function () {
    var root = document.getElementById('mt-admin-root');
    if (!root) { return; }
    function hideEl(el) { if (el && !el.contains(root)) { el.style.setProperty('display', 'none', 'important'); } }
    // Blend-style floated/fixed sidebar (id="sidebar").
    hideEl(document.getElementById('sidebar'));
    // Bootstrap-grid layouts: widen our content column, hide its sibling columns.
    var col = root.closest('[class*="col-"]');
    if (col) {
        var p = col.parentElement;
        if (p) { Array.prototype.forEach.call(p.children, function (s) { if (s !== col && /\bcol-\w/.test(s.className || '')) { hideEl(s); } }); }
        col.style.setProperty('flex', '0 0 100%', 'important');
        col.style.setProperty('max-width', '100%', 'important');
        col.style.setProperty('width', '100%', 'important');
    }
    // Generic fallback: clear left margins on ancestors so freed space is reclaimed.
    var node = root.parentElement, guard = 0;
    while (node && node !== document.body && guard++ < 14) {
        if (parseFloat(getComputedStyle(node).marginLeft) > 0) { node.style.setProperty('margin-left', '0', 'important'); }
        node = node.parentElement;
    }

    // Hide the WHMCS-rendered addon page title ("MyTheme") shown above our panel.
    // Only headings OUTSIDE our panel and OUTSIDE the top navbar are hidden, so our
    // own page titles and the WHMCS top menu are untouched.
    var titles = document.querySelectorAll('h1, .page-header, .pageheader, .pageheading, .page-title');
    Array.prototype.forEach.call(titles, function (h) {
        if (root.contains(h)) { return; }
        if (h.closest && h.closest('#header, .navbar, .top-nav, .navbar-default')) { return; }
        h.style.setProperty('display', 'none', 'important');
    });
})();
</script>{/literal}

    <header class="mt-brandbar">
        <div class="mt-brandbar-inner">
            <div class="mt-brandbar-left">
                <div class="mt-brandmark">H</div>
                <div class="mt-brand-text">
                    <div class="mt-brandname">Hostnodes</div>
                    <div class="mt-brandversion">Hadrian &middot; Client Theme</div>
                </div>
                <span class="mt-brand-ver">v1.0.0</span>
            </div>
            <div class="mt-brandbar-right">
                <a class="mt-brandbar-link" href="https://docs.hostnodes.com" target="_blank" rel="noopener">
                    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                        <path d="M3 2.5h6.5L13 6v7.5a1 1 0 01-1 1H3a1 1 0 01-1-1v-10a1 1 0 011-1z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                        <path d="M9.5 2.5V6H13" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                        <path d="M5 9h6M5 11.5h4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
                    </svg>
                    Docs
                </a>
                <a class="mt-brandbar-link" href="https://github.com/hostnodes/issues" target="_blank" rel="noopener">
                    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                        <path d="M5 7c0-1.5 1.5-3 3-3s3 1.5 3 3v3a3 3 0 11-6 0V7z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                        <path d="M2.5 8.5h3M10.5 8.5h3M3 5l1.5 1.5M13 5l-1.5 1.5M3 12l1.5-1.5M13 12l-1.5-1.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
                    </svg>
                    Report bug
                </a>
                <button type="button" class="mt-theme-toggle" id="mt-theme-toggle" aria-label="Toggle light or dark mode">
                    <svg class="mt-ico-sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5L19 19M19 5l-1.5 1.5M6.5 17.5L5 19"/></svg>
                    <svg class="mt-ico-moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/></svg>
                </button>
            </div>
        </div>
    </header>

    <nav class="mt-topnav" aria-label="Hostnodes navigation">
        <div class="mt-topnav-inner">
            <div class="mt-topnav-pill">
                <a class="mt-topnav-item {if $mt_nav == 'info'}is-active{/if}" href="{$viewHelper->url('info')}">Info</a>
                <a class="mt-topnav-item {if $mt_nav == 'settings'}is-active{/if}" href="{$viewHelper->url('settings')}">Settings</a>
                <a class="mt-topnav-item {if $mt_nav == 'styles'}is-active{/if}" href="{$viewHelper->url('styles')}">Styles</a>
                <a class="mt-topnav-item {if $mt_nav == 'layouts'}is-active{/if}" href="{$viewHelper->url('layouts')}">Layouts</a>
                <a class="mt-topnav-item {if $mt_nav == 'pages'}is-active{/if}" href="{$viewHelper->url('pages')}">Pages</a>
                <a class="mt-topnav-item {if $mt_nav == 'sitemap'}is-active{/if}" href="{$viewHelper->url('sitemap')}">Sitemap</a>
                <a class="mt-topnav-item {if $mt_nav == 'menu'}is-active{/if}" href="{$viewHelper->url('menu')}">Menu</a>
                <a class="mt-topnav-item {if $mt_nav == 'branding'}is-active{/if}" href="{$viewHelper->url('branding')}">Branding</a>
                <a class="mt-topnav-item {if $mt_nav == 'extensions'}is-active{/if}" href="{$viewHelper->url('extensions')}">Extensions</a>
                <a class="mt-topnav-item {if $mt_nav == 'tools'}is-active{/if}" href="{$viewHelper->url('tools')}">Tools</a>
            </div>
        </div>
    </nav>

    <div class="mt-body">
