{* =========================================================================
   store/ssl/competitive-upgrade.tpl — upgrade offer for SSL users from
   competitor CAs.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='store.ssl.competitiveUpgrade.title'}</h1>
    <p class="page-subtitle">{lang key='store.ssl.competitiveUpgrade.subtitle'}</p>
</div>

<div class="card">
    <div class="card-body">
        <p>{lang key='store.ssl.competitiveUpgrade.description'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}">
            <div class="form-group">
                <label for="competitorDomain" class="form-label">{lang key='orderdomain'}</label>
                <input type="text" name="domain" id="competitorDomain" class="form-input" required>
            </div>
            <div class="form-group">
                <label for="competitorCA" class="form-label">{lang key='store.ssl.currentCA'}</label>
                <select name="currentCA" id="competitorCA" class="form-input">
                    {foreach $competitors as $competitor}
                        <option value="{$competitor.id}">{$competitor.name}</option>
                    {/foreach}
                </select>
            </div>
            <button type="submit" class="btn btn-primary btn-lg">{lang key='store.ssl.getUpgradeOffer'}</button>
        </form>
    </div>
</div>
