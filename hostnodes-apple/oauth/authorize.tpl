{* =========================================================================
   oauth/authorize.tpl — consent screen: approve/deny scopes for a client.
   ========================================================================= *}
<div class="auth-card">
    <h1 class="auth-title">{lang key='oauth.authorize.title'}</h1>
    <p class="auth-subtitle">{lang key='oauth.authorize.subtitle' clientName=$clientName}</p>

    <div class="oauth-scopes">
        <h3 class="form-section-title">{lang key='oauth.authorize.requestedAccess'}</h3>
        <ul class="oauth-scope-list">
            {foreach $scopes as $scope}
                <li><i class="fas fa-check"></i> <strong>{$scope.name}</strong><br><span class="form-hint">{$scope.description}</span></li>
            {/foreach}
        </ul>
    </div>

    <form method="post" action="{$authorizeUrl}" class="auth-form">
        <input type="hidden" name="token" value="{$token}">
        <div class="btn-group">
            <button type="submit" name="action" value="allow" class="btn btn-primary btn-lg">{lang key='oauth.authorize.allow'}</button>
            <button type="submit" name="action" value="deny" class="btn btn-secondary btn-lg">{lang key='oauth.authorize.deny'}</button>
        </div>
    </form>
</div>
