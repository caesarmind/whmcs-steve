{* =========================================================================
   clientareadomainaddons.tpl — enable/disable domain addons (ID protection,
   DNS management, email forwarding).
   ========================================================================= *}
<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domainaddons'}</h3></div>
    <div class="card-body">
        {if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}
        {if $error}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}
        <p>{lang key='domainaddonsinfo'}</p>

        {if $addons.idprotection}
            <div class="addon-item">
                <div class="addon-icon"><i class="fas fa-shield-alt"></i></div>
                <div class="addon-info">
                    <strong>{lang key='domainidprotection'}</strong>
                    <p>{lang key='domainaddonsidprotectioninfo'}</p>
                    <form action="clientarea.php?action=domainaddons" method="post">
                        <input type="hidden" name="id" value="{$domainid}">
                        {if $addonstatus.idprotection}
                            <input type="hidden" name="disable" value="idprotect">
                            <button type="submit" class="btn btn-danger btn-sm">{lang key='disable'}</button>
                        {else}
                            <input type="hidden" name="buy" value="idprotect">
                            <button type="submit" class="btn btn-primary btn-sm">{lang key='domainaddonsbuynow'} {$addonspricing.idprotection}</button>
                        {/if}
                    </form>
                </div>
            </div>
        {/if}
        {if $addons.dnsmanagement}
            <div class="addon-item">
                <div class="addon-icon"><i class="fas fa-cloud"></i></div>
                <div class="addon-info">
                    <strong>{lang key='domainaddonsdnsmanagement'}</strong>
                    <p>{lang key='domainaddonsdnsmanagementinfo'}</p>
                    <form action="clientarea.php?action=domainaddons" method="post">
                        <input type="hidden" name="id" value="{$domainid}">
                        {if $addonstatus.dnsmanagement}
                            <input type="hidden" name="disable" value="dnsmanagement">
                            <a class="btn btn-primary btn-sm" href="clientarea.php?action=domaindns&domainid={$domainid}">{lang key='manage'}</a>
                            <button type="submit" class="btn btn-danger btn-sm">{lang key='disable'}</button>
                        {else}
                            <input type="hidden" name="buy" value="dnsmanagement">
                            <button type="submit" class="btn btn-primary btn-sm">{lang key='domainaddonsbuynow'} {$addonspricing.dnsmanagement}</button>
                        {/if}
                    </form>
                </div>
            </div>
        {/if}
        {if $addons.emailforwarding}
            <div class="addon-item">
                <div class="addon-icon"><i class="fas fa-envelope"></i></div>
                <div class="addon-info">
                    <strong>{lang key='domainemailforwarding'}</strong>
                    <p>{lang key='domainaddonsemailforwardinginfo'}</p>
                    <form action="clientarea.php?action=domainaddons" method="post">
                        <input type="hidden" name="id" value="{$domainid}">
                        {if $addonstatus.emailforwarding}
                            <input type="hidden" name="disable" value="emailfwd">
                            <a class="btn btn-primary btn-sm" href="clientarea.php?action=domainemailforwarding&domainid={$domainid}">{lang key='manage'}</a>
                            <button type="submit" class="btn btn-danger btn-sm">{lang key='disable'}</button>
                        {else}
                            <input type="hidden" name="buy" value="emailfwd">
                            <button type="submit" class="btn btn-primary btn-sm">{lang key='domainaddonsbuynow'} {$addonspricing.emailforwarding}</button>
                        {/if}
                    </form>
                </div>
            </div>
        {/if}
    </div>
</div>
