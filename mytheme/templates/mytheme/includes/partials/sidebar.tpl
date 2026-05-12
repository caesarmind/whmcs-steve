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

{function name=mtSidebarItem item=null}
    {assign var=mtType  value=$item->getAttribute('data-mt-type')|default:'whmcs_page'}
    {assign var=mtColor value=$item->getAttribute('data-mt-color')|default:'gray'}
    {assign var=mtIconName value=$item->getIcon()|default:''}
    {assign var=mtBadgeKey value=$item->getAttribute('data-mt-badge-source')|default:''}
    {assign var=mtBadge value=''}
    {if $mtBadgeKey == 'services'}{assign var=mtBadge value=$clientsstats.productsnumactive|default:''}
    {elseif $mtBadgeKey == 'unpaid_invoices'}{assign var=mtBadge value=$clientsstats.numunpaidinvoices|default:''}
    {elseif $mtBadgeKey == 'open_tickets'}{assign var=mtBadge value=$clientsstats.numactivetickets|default:''}
    {elseif $mtBadgeKey == 'domains'}{assign var=mtBadge value=$clientsstats.numactivedomains|default:''}
    {/if}

    {if $mtType == 'header'}
        <div class="sidebar-section-label">{$item->getLabel()|escape}</div>
    {elseif $mtType == 'divider'}
        <hr class="sidebar-divider">
    {elseif $mtType == 'dropdown_parent' || ($mtType == 'account_dropdown' && $item->getChildren())}
        <details class="sidebar-dropdown" data-mt-id="{$item->getName()|escape}">
            <summary class="sidebar-item sidebar-item-dropdown">
                <div class="sidebar-item-icon {$mtColor|escape}">{mtSidebarIcon iconName=$mtIconName}</div>
                <span class="sidebar-item-label">{$item->getLabel()|escape}</span>
                <span class="sidebar-item-chevron">
                    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 6 8 10 12 6"/></svg>
                </span>
            </summary>
            <div class="sidebar-children">
                {foreach $item->getChildren() as $child}
                    {mtSidebarItem item=$child}
                {/foreach}
            </div>
        </details>
    {elseif $mtType == 'login_button'}
        <a href="{$item->getUri()|escape}" class="sidebar-item sidebar-item-login">
            <div class="sidebar-item-icon blue">{mtSidebarIcon iconName=($mtIconName|default:'transfer')}</div>
            {$item->getLabel()|escape}
        </a>
    {elseif $mtType == 'language' || $mtType == 'currency'}
        <a href="#" class="sidebar-item sidebar-item-switcher" data-switcher="{$mtType|escape}">
            <div class="sidebar-item-icon gray">{mtSidebarIcon iconName=($mtIconName|default:'globe')}</div>
            {$item->getLabel()|escape}
        </a>
    {else}
        {* whmcs_page, custom_link, account_dropdown (no children), whmcs_default *}
        <a href="{$item->getUri()|escape}" class="sidebar-item" data-nav="{$item->getName()|escape}">
            <div class="sidebar-item-icon {$mtColor|escape}">{mtSidebarIcon iconName=$mtIconName}</div>
            {$item->getLabel()|escape}
            {if $mtBadge}<span class="sidebar-item-badge">{$mtBadge|escape}</span>{/if}
        </a>
    {/if}
{/function}

<aside class="sidebar only-side">
    <div class="sidebar-header">
        <a href="{$WEB_ROOT}/" class="sidebar-home-link">
            <span class="sidebar-brand">{$companyname|escape}</span>
        </a>
    </div>
    <div class="sidebar-search">
        <form action="{$WEB_ROOT}/knowledgebase.php" method="get">
            <input type="text" name="search" class="sidebar-search-input" placeholder="{$LANG.searchbutton|default:'Search'}">
        </form>
    </div>

    <nav class="sidebar-nav">
        {if isset($primaryNavbar) && $primaryNavbar->getChildren()}
            {foreach $primaryNavbar->getChildren() as $item}
                {mtSidebarItem item=$item}
            {/foreach}
        {else}
            {* Fallback if menu manager is empty / errored — never blank *}
            <a href="{$WEB_ROOT}/" class="sidebar-item"><div class="sidebar-item-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12l9-9 9 9M5 10v10h14V10"/></svg></div>{$LANG.home|default:'Home'}</a>
            {if $loggedin}
                <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-item"><div class="sidebar-item-icon indigo"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg></div>{$LANG.clientareanavhome|default:'Dashboard'}</a>
            {/if}
            <a href="/admin/addonmodules.php?module=MyTheme&action=menu" class="sidebar-item" style="margin-top:auto;opacity:.6">
                <div class="sidebar-item-icon gray"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19 12a7 7 0 11-14 0 7 7 0 0114 0z"/></svg></div>
                Configure menu…
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
                <a href="{$WEB_ROOT}/login.php" style="padding:9px 14px;border-radius:10px;background:var(--color-accent);color:#fff;text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.login|default:'Sign in'}</a>
                <a href="{$WEB_ROOT}/register.php" style="padding:9px 14px;border-radius:10px;background:var(--color-surface-secondary);color:var(--color-text-primary);text-align:center;font-size:13px;font-weight:500;text-decoration:none">{$LANG.createaccount|default:'Create account'}</a>
            </div>
        {/if}
    </div>
</aside>
