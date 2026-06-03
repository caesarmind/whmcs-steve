{* Hostnodes — Fixed 260px sidebar (rendered when body[data-layout="side"]).

   The middle .sidebar-nav block is admin-driven: it iterates
   $primaryNavbar->getChildren() (populated by the MyTheme menu-manager hook
   in modules/addons/MyTheme/hooks.php). Each child is a WHMCS\View\Menu\Item
   with the menu-manager item-type exposed via the data-mt-type attribute.

   Header (logo, search) and footer (profile dropdown / login CTAs) stay
   hardcoded — they're layout chrome, not admin-editable nav. *}
{assign var=_first value=''}
{assign var=_last value=''}
{assign var=_email value=''}
{if isset($clientsdetails) && is_array($clientsdetails)}
    {assign var=_first value=$clientsdetails.firstname|default:''}
    {assign var=_last value=$clientsdetails.lastname|default:''}
    {assign var=_email value=$clientsdetails.email|default:''}
{/if}
{assign var=user_initials value=$_first|truncate:1:''|upper}
{assign var=user_fullname value=$_first|cat:' '|cat:$_last}

{* Renders one menu item to the sidebar. Recursion handled via {include} so it
   doesn't depend on Smarty {function} (which has rendered nothing on some
   WHMCS Smarty configs). Helper for the icon lookup is inline. *}
{function name=mtSidebarIcon iconName=''}
    {if $iconName && isset($mtIcons[$iconName])}
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">{$mtIcons[$iconName] nofilter}</svg>
    {elseif $iconName}
        {* Unknown name — treat as a CSS class (Font Awesome / similar) *}
        <i class="{$iconName|escape}"></i>
    {else}
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/></svg>
    {/if}
{/function}

{* Renders one entry from the $mtSidebarItems plain-array list (built by
   TreeRenderer::buildFlatList). Each entry has: type, name, label, uri,
   icon, color, side, css_class, badge_source, dropdown_style, target,
   children. *}
{function name=mtSidebarItem item=null}
    {assign var=mtType   value=$item.type|default:'whmcs_page'}
    {assign var=mtColor  value=$item.color|default:'gray'}
    {assign var=mtIconName value=$item.icon|default:''}
    {assign var=mtBadgeKey value=$item.badge_source|default:''}
    {assign var=mtBadge value=''}
    {if $mtBadgeKey == 'services'}{assign var=mtBadge value=$clientsstats.productsnumactive|default:''}
    {elseif $mtBadgeKey == 'unpaid_invoices'}{assign var=mtBadge value=$clientsstats.numunpaidinvoices|default:''}
    {elseif $mtBadgeKey == 'open_tickets'}{assign var=mtBadge value=$clientsstats.numactivetickets|default:''}
    {elseif $mtBadgeKey == 'domains'}{assign var=mtBadge value=$clientsstats.numactivedomains|default:''}
    {/if}

    {if $mtType == 'header'}
        {if $item.label}<div class="sidebar-section-label">{$item.label|escape}</div>{/if}
    {elseif $mtType == 'divider'}
        <hr class="sidebar-divider">
    {elseif $mtType == 'dropdown_parent' || ($mtType == 'account_dropdown' && $item.children)}
        <div class="sidebar-group" data-group="{$item.name|escape}">
            <button type="button" class="sidebar-group-toggle">
                <div class="sidebar-item-icon {$mtColor|escape}">{mtSidebarIcon iconName=$mtIconName}</div>
                <span class="group-label">{$item.label|escape}</span>
                <svg class="group-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 6 15 12 9 18"/></svg>
            </button>
            <div class="sidebar-group-items">
                {foreach $item.children as $child}
                    {if $child.type == 'divider'}
                        <hr class="sidebar-group-divider">
                    {elseif $child.type == 'header'}
                        <div class="sidebar-group-section">{$child.label|escape}</div>
                    {else}
                        <a href="{$child.uri|escape}">{$child.label|escape}</a>
                    {/if}
                {/foreach}
            </div>
        </div>
    {elseif $mtType == 'login_button'}
        <a href="{$item.uri|escape}" class="sidebar-item sidebar-item-login">
            <div class="sidebar-item-icon blue">{mtSidebarIcon iconName=($mtIconName|default:'transfer')}</div>
            {$item.label|escape}
        </a>
    {elseif $mtType == 'language' || $mtType == 'currency'}
        <a href="#" class="sidebar-item sidebar-item-switcher" data-switcher="{$mtType|escape}">
            <div class="sidebar-item-icon gray">{mtSidebarIcon iconName=($mtIconName|default:'globe')}</div>
            {$item.label|escape}
        </a>
    {else}
        {* whmcs_page, custom_link, account_dropdown (no children) *}
        <a href="{$item.uri|escape}" class="sidebar-item" data-nav="{$item.name|escape}"{if $item.target} target="{$item.target|escape}"{/if}>
            <div class="sidebar-item-icon {$mtColor|escape}">{mtSidebarIcon iconName=$mtIconName}</div>
            {$item.label|escape}
            {if $mtBadge}<span class="sidebar-item-badge">{$mtBadge|escape}</span>{/if}
        </a>
    {/if}
{/function}

<aside class="sidebar only-side">
    <div class="sidebar-header">
        <a href="{$WEB_ROOT}/" class="sidebar-home-link">
            {* The sidebar is a light surface. Prefer the square logo for
               this slot (better proportions in a vertical layout); fall
               back to the full logo, then to text. *}
            {if !empty($myTheme.branding.square.light)}
                <img src="{$myTheme.branding.square.light|escape}" alt="{$companyname|escape}" class="sidebar-brand-logo">
            {elseif !empty($myTheme.branding.logo.light)}
                <img src="{$myTheme.branding.logo.light|escape}" alt="{$companyname|escape}" class="sidebar-brand-logo">
            {else}
                <span class="sidebar-brand">{$companyname|escape}</span>
            {/if}
        </a>
        {* Close button — only visible when the sidebar is a mobile drawer
           (<=900px). data-nav-toggle closes the open drawer via apple-layout.js.
           Hidden on desktop where the sidebar is a permanent column. *}
        <button type="button" class="sidebar-close" aria-label="{$LANG.close}" data-nav-toggle>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>
    </div>
    <div class="sidebar-search">
        <form action="{$WEB_ROOT}/knowledgebase.php" method="get">
            <input type="text" name="search" class="sidebar-search-input" placeholder="{$LANG.searchbutton}">
        </form>
    </div>

    <nav class="sidebar-nav">
        {if isset($mtSidebarItems) && $mtSidebarItems}
            {* $mtSidebarItems is a flat ordered array of WHMCS Menu Items
               built by MyTheme's TreeRenderer in DB position order. We
               iterate THIS instead of $primaryNavbar->getChildren() because
               the latter reorders children in ways we can't predict
               (headers bucketed, dropdowns grouped). *}
            {foreach $mtSidebarItems as $item}
                {mtSidebarItem item=$item}
            {/foreach}
        {elseif isset($primaryNavbar) && $primaryNavbar->getChildren()}
            {foreach $primaryNavbar->getChildren() as $item}
                {mtSidebarItem item=$item}
            {/foreach}
        {else}
            {* Fallback if menu manager is empty / errored — never blank *}
            <a href="{$WEB_ROOT}/" class="sidebar-item"><div class="sidebar-item-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12l9-9 9 9M5 10v10h14V10"/></svg></div>{$LANG.home}</a>
            {if $loggedin}
                <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-item"><div class="sidebar-item-icon indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></div>{$LANG.clientareanavhome}</a>
            {/if}
            <a href="/admin/addonmodules.php?module=MyTheme&action=menu" class="sidebar-item" style="margin-top:auto;opacity:.6">
                <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 11-14 0 7 7 0 0114 0z"/></svg></div>
                {$hadrianLang.nav.configureMenu}
            </a>
        {/if}
    </nav>

    <div class="sidebar-footer">
        {if $loggedin}
            <div class="profile-dropdown-wrapper only-in">
                <div class="sidebar-user" role="button" tabindex="0" onclick="togglePortalProfile && togglePortalProfile(event, 'sidebar')">
                    <div class="sidebar-avatar">{$user_initials|default:'U'}</div>
                    <div class="sidebar-user-info">
                        <div class="sidebar-user-name">{$user_fullname|escape}</div>
                        <div class="sidebar-user-email">{$_email|escape}</div>
                    </div>
                </div>
            </div>
        {else}
            <div class="only-out" style="padding:12px;display:flex;flex-direction:column;gap:8px">
                <a href="{$WEB_ROOT}/login.php" style="padding:9px 14px;border-radius:10px;background:var(--color-accent);color:#fff;text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.login}</a>
                <a href="{$WEB_ROOT}/register.php" style="padding:9px 14px;border-radius:10px;background:var(--color-surface-secondary);color:var(--color-text-primary);text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.createaccount}</a>
            </div>
        {/if}
    </div>
</aside>

<script>{literal}
(function(){
    // Direct-bind to each .sidebar-group-toggle (idempotent via dataset.mtBound).
    // apple-layout.js's initSidebarGroups() does the same thing once at boot,
    // but if anything in its promise chain rejects this still works. Runs as
    // soon as the script tag is parsed — sidebar markup is already in the DOM.
    function bind() {
        var toggles = document.querySelectorAll('.sidebar-group-toggle');
        toggles.forEach(function(btn){
            if (btn.dataset.mtBound === '1') return;
            btn.dataset.mtBound = '1';
            btn.addEventListener('click', function(e){
                e.preventDefault();
                var group = btn.closest('.sidebar-group');
                if (group) group.classList.toggle('open');
            });
        });
    }
    bind();
    // Rebind after apple-layout boots in case partials were injected after parse
    document.addEventListener('apple-layout:ready', bind);
})();
{/literal}</script>
