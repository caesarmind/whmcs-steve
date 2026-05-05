{* =========================================================================
   user-security.tpl — linked accounts, 2FA, active sessions for a user.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='userSecurity.title'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

{if $twoFactorEnabled}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='twofactorauth'}</h3></div>
        <div class="card-body">
            {if $twoFactorEnabledForUser}
                {include file="$template/includes/alert.tpl" type="success" msg="{lang key='twofaEnabled'}"}
                <a href="{routePath('user-two-factor-disable')}" class="btn btn-danger">{lang key='disable'}</a>
            {else}
                <p>{lang key='twofaExp'}</p>
                <a href="{routePath('user-two-factor-enable')}" class="btn btn-primary">{lang key='enable'}</a>
            {/if}
        </div>
    </div>
{/if}

{if $linkedAccountsEnabled}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='userSecurity.linkedAccounts'}</h3></div>
        <div class="card-body">
            {include file="$template/includes/linkedaccounts.tpl" linkContext="clientsecurity"}
        </div>
    </div>
{/if}

{if $activeSessions}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='userSecurity.activeSessions'}</h3></div>
        <div class="card-body">
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='userSecurity.browser'}</th>
                            <th>{lang key='userSecurity.ipAddress'}</th>
                            <th>{lang key='userSecurity.lastUsed'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $activeSessions as $session}
                            <tr>
                                <td>{$session.user_agent}</td>
                                <td>{$session.ip_address}</td>
                                <td>{$session.last_used}</td>
                                <td class="text-right">
                                    {if $session.current}<span class="status-pill active">{lang key='userSecurity.currentSession'}</span>{else}
                                        <a href="{routePath('user-security-revoke', $session.id)}" class="btn btn-danger btn-sm">{lang key='userSecurity.revoke'}</a>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
{/if}
