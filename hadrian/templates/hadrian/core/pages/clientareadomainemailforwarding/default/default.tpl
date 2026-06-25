{* Hostnodes — Email Forwarding (Apple-style).

   WHMCS variables for this page:
     $domain, $domainid
     $emailforwarders (array, keyed by num — each has .prefix, .forwardto)
     $external (bool), $code (HTML when external)
     $error (string)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomainemailforwarding.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$LANG.domainemailforwarding}</h1>
    <p class="page-subtitle">{$LANG.domainemailforwardingdesc}</p>
</header>

{if !empty($error)}
<div class="ef-alert ef-alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
    <div>{$error|escape}</div>
</div>
{/if}

<div class="ef-split">
    <div class="ef-main">

        {if !empty($external)}
            <div class="card ef-external">{$code}</div>
        {else}

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domainemailforwarding" class="card ef-card">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="save">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            <div class="ef-table-wrap">
                <table class="ef-table">
                    <thead>
                        <tr>
                            <th class="ef-col-prefix">{$LANG.domainemailforwardingprefix}</th>
                            <th class="ef-col-at">{$hadrianLang.domains.emailAt}</th>
                            <th class="ef-col-fwd">{$LANG.domainemailforwardingforwardto}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {if isset($emailforwarders) && $emailforwarders|@count > 0}
                        {foreach $emailforwarders as $num => $fwd}
                            <tr class="ef-row">
                                <td><input type="text" name="emailforwarderprefix[{$num}]" value="{$fwd.prefix|default:''|escape}" class="ef-input ef-input-prefix" placeholder="info"></td>
                                <td class="ef-at">@{$domain|escape}</td>
                                <td><input type="text" name="emailforwarderforwardto[{$num}]" value="{$fwd.forwardto|default:''|escape}" class="ef-input" placeholder="you@example.com"></td>
                            </tr>
                        {/foreach}
                        {/if}

                        <tr class="ef-row ef-row-new">
                            <td><input type="text" name="emailforwarderprefixnew" class="ef-input ef-input-prefix" placeholder="info"></td>
                            <td class="ef-at">@{$domain|escape}</td>
                            <td><input type="text" name="emailforwarderforwardtonew" class="ef-input" placeholder="you@example.com"></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="ef-actions">
                <button type="submit" class="btn-primary">{$LANG.clientareasavechanges}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="btn-secondary">{$LANG.clientareacancel}</a>
            </div>
        </form>

        {/if}
    </div>

    <aside class="ef-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$hadrianLang.domains.domainDetails}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindns&domainid={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>
                {$LANG.domaindnsmanagement}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domainemailforwarding&domainid={$domainid|escape}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                {$LANG.domainemailforwarding}
            </a>
        </div>
    </aside>
</div>
