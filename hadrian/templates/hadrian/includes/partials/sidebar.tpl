{* Hostnodes — Fixed 260px sidebar (rendered when body[data-layout="side"]).

   The middle .sidebar-nav block is admin-driven: it iterates
   $primaryNavbar->getChildren() (populated by the Hadrian menu-manager hook
   in modules/addons/Hadrian/hooks.php). Each child is a WHMCS\View\Menu\Item
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
        {* data-locale-open, NOT data-switcher — see the same fix in topnav.tpl.
           Nothing listens for [data-switcher], so this was a dead link. *}
        <a href="#" class="sidebar-item sidebar-item-switcher" data-locale-open data-switcher="{$mtType|escape}">
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
            {if !empty($hadrian.branding.square.light)}
                <img src="{$hadrian.branding.square.light|escape}" alt="{$companyname|escape}" class="sidebar-brand-logo">
            {elseif !empty($hadrian.branding.logo.light)}
                <img src="{$hadrian.branding.logo.light|escape}" alt="{$companyname|escape}" class="sidebar-brand-logo">
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
            <input type="text" name="search" class="sidebar-search-input" placeholder="{$LANG.searchbutton|default:'Search'}">
        </form>
    </div>

    <nav class="sidebar-nav">
        {if isset($mtSidebarItems) && $mtSidebarItems}
            {* $mtSidebarItems is a flat ordered array of WHMCS Menu Items
               built by Hadrian's TreeRenderer in DB position order. We
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
            <a href="{$WEB_ROOT}/" class="sidebar-item"><div class="sidebar-item-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12l9-9 9 9M5 10v10h14V10"/></svg></div>{$LANG.home|default:'Portal Home'}</a>
            {if $loggedin}
                <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-item"><div class="sidebar-item-icon indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></div>{$LANG.clientareanavhome|default:'Go to dashboard'}</a>
            {/if}
            <a href="/admin/addonmodules.php?module=Hadrian&action=menu" class="sidebar-item" style="margin-top:auto;opacity:.6">
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
                {* Profile dropdown panel (was missing -> togglePortalProfile('sidebar')
                   found no #profileDropdownSidebar and silently no-op'd). Mirrors the
                   inner-topbar panel; opens upward (profile-dropdown--up) for the
                   bottom-anchored rail. *}
                <div class="profile-dropdown profile-dropdown--up" id="profileDropdownSidebar">
                    <div class="profile-dropdown-header">
                        <div class="profile-dropdown-name">{$user_fullname|escape|default:'Account'}</div>
                        <div class="profile-dropdown-email">{$_email|escape}</div>
                    </div>

                    {* — Account section — *}
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {$LANG.accountdetails|default:'Account Details'}
                    </a>
                    <a href="{routePath('account-users')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                        {$LANG.usermanagement|default:'User Management'}
                    </a>
                    <a href="{routePath('account-paymentmethods')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                        {$LANG.paymentMethods.title}
                    </a>
                    <a href="{routePath('account-contacts')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        {$LANG.contacts|default:'Contacts'}
                    </a>
                    <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                        {$LANG.emailstitle|default:'Email History'}
                    </a>

                    <div class="profile-dropdown-divider"></div>

                    {* — Profile section — *}
                    <a href="{routePath('user-profile')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
                        {$LANG.yourprofile|default:'Your Profile'}
                    </a>
                    <a href="{routePath('user-accounts')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
                        {$LANG.switchaccount|default:'Switch Account'}
                    </a>
                    <a href="{routePath('user-password')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
                        {$LANG.clientareanavchangepassword|default:'Change Password'}
                    </a>
                    <a href="{routePath('user-security')}" class="profile-dropdown-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        {$LANG.securitysettings|default:'Security settings'}
                    </a>

                    {* — Theme toggle — gated by admin "Enable Dark Mode". *}
                    {if $mtShowDarkToggle}
                    <div class="profile-dropdown-divider"></div>

                    <div class="theme-toggle-row">
                        <span class="theme-toggle-label">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
                            {$hadrianLang.common.darkMode}
                        </span>
                        <div class="toggle-switch" onclick="toggleDarkMode && toggleDarkMode()"></div>
                    </div>
                    {/if}

                    <div class="profile-dropdown-divider"></div>

                    {* — Sign out — *}
                    <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                        {$LANG.logout|default:'Sign Out'}
                    </a>
                </div>
            </div>
        {else}
            <div class="only-out" style="padding:12px;display:flex;flex-direction:column;gap:8px">
                <a href="{$WEB_ROOT}/login.php" style="padding:9px 14px;border-radius:10px;background:var(--color-accent);color:#fff;text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.login}</a>
                <a href="{$WEB_ROOT}/register.php" style="padding:9px 14px;border-radius:10px;background:var(--color-surface-secondary);color:var(--color-text-primary);text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.createaccount|default:'Create your account'}</a>
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
