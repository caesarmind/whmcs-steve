{* =========================================================================
   Authenticated-area topbar. Breadcrumb + status + notifications + cart +
   profile menu. Rendered inside <main class="main-content"> by header.tpl.
   ========================================================================= *}
<div class="topbar">
    <div class="topbar-breadcrumb">
        {include file="$template/includes/breadcrumb.tpl"}
    </div>

    <div class="topbar-status">
        {if $openNetworkIssueCounts.open > 0}
            <span class="topbar-status-dot red"></span>
            <a href="{$WEB_ROOT}/serverstatus.php">{lang key='networkIssuesAware'}</a>
        {elseif $openNetworkIssueCounts.scheduled > 0}
            <span class="topbar-status-dot orange"></span>
            <a href="{$WEB_ROOT}/serverstatus.php">{lang key='networkIssuesScheduled'}</a>
        {else}
            <span class="topbar-status-dot"></span>{lang key='serverstatus.allsystems'}
        {/if}
    </div>

    <div class="topbar-spacer"></div>

    <div class="topbar-actions">
        {include file="$template/includes/notification-dropdown.tpl"}

        <a href="{$WEB_ROOT}/cart.php?a=view" class="topbar-btn topbar-cart" title="{lang key='carttitle'}">
            <i class="far fa-shopping-cart"></i>
            {if $cartitemcount > 0}<span class="topbar-btn-badge">{$cartitemcount}</span>{/if}
        </a>

        {if $adminMasqueradingAsClient || $adminLoggedIn}
            <a href="{$WEB_ROOT}/logout.php?returntoadmin=1" class="topbar-btn topbar-admin-return" title="{if $adminMasqueradingAsClient}{lang key='adminmasqueradingasclient'}{else}{lang key='adminloggedin'}{/if}">
                <i class="fas fa-redo-alt"></i>
            </a>
        {/if}

        {include file="$template/includes/profile-dropdown.tpl"}
    </div>
</div>
