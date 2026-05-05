{* =========================================================================
   Topbar notifications dropdown. Wrapper + button + panel. Driven by
   $clientAlerts[] where each alert exposes getMessage(), getLink(), and
   getSeverity() ('danger', 'warning', 'info', 'success').
   ========================================================================= *}
<div class="notification-wrapper">
    <button type="button" class="topbar-btn" title="{lang key='notifications'}" onclick="toggleNotifications(event)">
        <i class="far fa-flag"></i>
        {if $clientAlerts && count($clientAlerts) > 0}
            <div class="topbar-notification-dot"></div>
        {/if}
    </button>
    <div class="notification-dropdown" id="notificationDropdown">
        <div class="notification-dropdown-header">
            <span class="notification-dropdown-title">{lang key='notifications'}</span>
        </div>
        {if $clientAlerts && count($clientAlerts) > 0}
            {foreach $clientAlerts as $alert}
                <a href="{$alert->getLink()}" class="notification-item">
                    <div class="notification-dot-indicator {if $alert->getSeverity() == 'danger'}red{elseif $alert->getSeverity() == 'warning'}orange{elseif $alert->getSeverity() == 'info'}blue{else}green{/if}"></div>
                    <div class="notification-content">
                        <div class="notification-text">{$alert->getMessage()}</div>
                    </div>
                </a>
            {/foreach}
        {else}
            <div class="notification-item notification-empty">
                <div class="notification-content">
                    <div class="notification-text">{lang key='notificationsnone'}</div>
                </div>
            </div>
        {/if}
    </div>
</div>
