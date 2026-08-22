{* Hostnodes — Register Nameservers / Glue Records.

   WHMCS variables:
     $domain, $domainid
     $result (warning string after a save)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomainregisterns.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$LANG.privatenameservers|default:'Glue records'}</h1>
    <p class="page-subtitle">{$LANG.domainregisternsexplanation}</p>
</header>

{if !empty($result)}
<div class="rns-alert rns-alert-warn">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
    <div>{$result|escape}</div>
</div>
{/if}

<div class="rns-split">
    <div class="rns-main">

        {* ----- Register ----- *}
        <form method="post" action="{$smarty.server.PHP_SELF}?action=registerns" class="card rns-card">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="register">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            <h3 class="rns-section-title">{$LANG.domainregisternsreg}</h3>

            <div class="rns-row">
                <label class="rns-label" for="rns-reg-ns">{$LANG.domainregisternsns}</label>
                <div class="rns-input-suffix">
                    <input type="text" class="rns-input" id="rns-reg-ns" name="ns" placeholder="ns1">
                    <span class="rns-suffix">.{$domain|escape}</span>
                </div>
            </div>
            <div class="rns-row">
                <label class="rns-label" for="rns-reg-ip">{$LANG.domainregisternsip}</label>
                <input type="text" class="rns-input" id="rns-reg-ip" name="ipaddress" placeholder="192.0.2.10">
            </div>

            <div class="rns-actions"><button type="submit" class="btn-primary">{$LANG.register}</button></div>
        </form>

        {* ----- Modify ----- *}
        <form method="post" action="{$smarty.server.PHP_SELF}?action=registerns" class="card rns-card">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="modify">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            <h3 class="rns-section-title">{$LANG.domainregisternsmod}</h3>

            <div class="rns-row">
                <label class="rns-label" for="rns-mod-ns">{$LANG.domainregisternsns}</label>
                <div class="rns-input-suffix">
                    <input type="text" class="rns-input" id="rns-mod-ns" name="ns" placeholder="ns1">
                    <span class="rns-suffix">.{$domain|escape}</span>
                </div>
            </div>
            <div class="rns-row">
                <label class="rns-label" for="rns-mod-cur">{$LANG.domainregisternscurrentip}</label>
                <input type="text" class="rns-input" id="rns-mod-cur" name="currentipaddress" placeholder="192.0.2.10">
            </div>
            <div class="rns-row">
                <label class="rns-label" for="rns-mod-new">{$LANG.domainregisternsnewip}</label>
                <input type="text" class="rns-input" id="rns-mod-new" name="newipaddress" placeholder="192.0.2.20">
            </div>

            <div class="rns-actions"><button type="submit" class="btn-primary">{$LANG.clientareasavechanges}</button></div>
        </form>

        {* ----- Delete ----- *}
        <form method="post" action="{$smarty.server.PHP_SELF}?action=registerns" class="card rns-card rns-card-danger">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="delete">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            <h3 class="rns-section-title">{$LANG.domainregisternsdel}</h3>

            <div class="rns-row">
                <label class="rns-label" for="rns-del-ns">{$LANG.domainregisternsns}</label>
                <div class="rns-input-suffix">
                    <input type="text" class="rns-input" id="rns-del-ns" name="ns" placeholder="ns1">
                    <span class="rns-suffix">.{$domain|escape}</span>
                </div>
            </div>

            <div class="rns-actions"><button type="submit" class="btn-secondary rns-danger-btn">{$hadrianLang.domains.delete}</button></div>
        </form>

    </div>

    <aside class="rns-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$hadrianLang.domains.domainDetails}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=registerns&id={$domainid|escape}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5z"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>
                {$LANG.privatenameservers|default:'Glue records'}
            </a>
        </div>
    </aside>
</div>
