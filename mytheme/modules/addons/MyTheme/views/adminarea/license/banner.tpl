{* License-state banner shown on AdminHomepage. Rendered by License::getDashboardBanner(). *}
<div class="alert alert--license alert--{if $state == 'DEV_MODE'}warning{elseif $state == 'EXPIRED' || $state == 'INVALID' || $state == 'CANCELLED' || $state == 'BANNED'}danger{else}info{/if}">
    <div class="alert-body">
        {if $state == 'DEV_MODE'}
            <strong>MyTheme — Development mode.</strong> {$message|escape}
        {elseif $message}
            <strong>MyTheme:</strong> {$message|escape}
        {elseif $state == 'EXPIRED'}
            <strong>MyTheme license expired.</strong> Please renew to keep using your theme.
        {elseif $days !== null && $days <= 14}
            <strong>MyTheme license expires in {$days} day{if $days != 1}s{/if}.</strong>
        {else}
            <strong>MyTheme:</strong> license attention needed.
        {/if}
    </div>
    <div class="alert-actions">
        {if $state != 'DEV_MODE'}
            <a href="https://your-domain.com/my-account/" target="_blank" class="btn btn-default">Renew</a>
        {/if}
        <a href="addonmodules.php?module=MyTheme&action=license" class="btn btn-default">Manage</a>
    </div>
</div>
<style>
.alert--license { padding: 13px 16px; margin: 16px 0; border-radius: 4px; display: flex; gap: 16px; align-items: center; }
.alert--license.alert--danger  { background: #fceeef; border: 1px solid #f7d4d6; color: #d92632; }
.alert--license.alert--warning { background: #fef3c7; border: 1px solid #fde68a; color: #92400e; }
.alert--license.alert--info    { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; }
.alert--license .alert-body { flex: 1; }
.alert--license .btn { margin-left: 8px; }
</style>
