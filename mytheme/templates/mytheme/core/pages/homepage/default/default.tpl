{* Hostnodes — Public homepage (Apple-style hero + quick links).

   Rendered when /index.php is hit. Logged-in users still see this if they
   land here directly; the hero CTAs flip based on $loggedin.

   Variant config from $myTheme.pages.homepage.config:
     heroTitle         — string  (default: $companyname)
     heroSubtitle      — string  (default: 'Manage your services …')
     showQuickLinks    — bool    (default: true)
     showAnnouncements — bool    (default: true)
*}

{assign var=heroTitle value=$companyname}
{assign var=heroSubtitle value='Manage your services, domains and billing in one place.'}
{assign var=showQuickLinks value=true}
{assign var=showAnnouncements value=true}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/homepage.css?v={$myTheme.version|default:'1.0'}">

<section class="home-hero">
    <h1>{$heroTitle|escape}</h1>
    <p>{$heroSubtitle|escape}</p>
    <div class="home-hero-actions">
        {if $loggedin}
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.clientareanavhome|default:'Go to Dashboard'}</a>
            <a href="{$WEB_ROOT}/cart.php" class="btn-secondary">{$LANG.orderproducts|default:'Browse Products'}</a>
        {else}
            <a href="{$WEB_ROOT}/login.php" class="btn-primary">{$LANG.login|default:'Sign in'}</a>
            <a href="{$WEB_ROOT}/register.php" class="btn-secondary">{$LANG.createaccount|default:'Create account'}</a>
        {/if}
    </div>
</section>

{if $showQuickLinks}
<div class="home-grid">
    <a href="{$WEB_ROOT}/cart.php" class="home-tile">
        <div class="home-tile-ico blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg></div>
        <p class="home-tile-title">{$LANG.shop|default:'Browse Products'}</p>
        <p class="home-tile-sub">{$LANG.shopsub|default:'Hosting, domains, SSL and more.'}</p>
    </a>
    <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="home-tile">
        <div class="home-tile-ico green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
        <p class="home-tile-title">{$LANG.registerdomain|default:'Register Domain'}</p>
        <p class="home-tile-sub">{$LANG.registerdomainsub|default:'Find and register your perfect name.'}</p>
    </a>
    <a href="{$WEB_ROOT}/knowledgebase.php" class="home-tile">
        <div class="home-tile-ico orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg></div>
        <p class="home-tile-title">{$LANG.knowledgebasetitle|default:'Knowledgebase'}</p>
        <p class="home-tile-sub">{$LANG.knowledgebasesub|default:'Guides and how-to articles.'}</p>
    </a>
    <a href="{$WEB_ROOT}/serverstatus.php" class="home-tile">
        <div class="home-tile-ico purple"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/></svg></div>
        <p class="home-tile-title">{$LANG.networkstatus|default:'Network Status'}</p>
        <p class="home-tile-sub">{$LANG.networkstatussub|default:'Live system uptime and incidents.'}</p>
    </a>
</div>
{/if}

{if $showAnnouncements && $publishedAnnouncements && $publishedAnnouncements|count > 0}
<div class="home-news">
    <div class="home-news-heading">
        <h3>{$LANG.recentNews|default:'Recent News'}</h3>
        <a href="{$WEB_ROOT}/announcements.php">{$LANG.viewall|default:'View all'} →</a>
    </div>
    <div class="home-news-list">
        {foreach $publishedAnnouncements as $ann}
            <a href="{$WEB_ROOT}/announcements.php?id={$ann.id}" class="home-news-row">
                <div class="home-news-title">{$ann.title|escape}</div>
                <div class="home-news-date">{$ann.date|escape}</div>
            </a>
            {if $ann@iteration >= 3}{break}{/if}
        {/foreach}
    </div>
</div>
{/if}
