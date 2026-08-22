{* Hostnodes — Domain DNS Records.

   WHMCS variables for this page:
     $domain, $domainid
     $dnsrecords (array — each has .recid, .hostname, .type, .address, .priority)
     $external (bool — registrar handles externally → render $code HTML)
     $code (HTML when $external)
     $error (string)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomaindns.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$LANG.domaindnsmanagement}</h1>
    <p class="page-subtitle">{$LANG.domaindnsmanagementdesc}</p>
</header>

{if !empty($error)}
<div class="dns-alert dns-alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$error|escape}</div>
</div>
{/if}

<div class="dns-split">
    <div class="dns-main">

        {if !empty($external)}
            <div class="card dns-external">
                <p class="dns-external-note">{$hadrianLang.domains.dnsExternal}</p>
                <div class="dns-external-body">{$code}</div>
            </div>
        {else}

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindns" class="card dns-card">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="save">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            <div class="dns-table-wrap">
                <table class="dns-table">
                    <thead>
                        <tr>
                            <th class="dns-col-host">{$LANG.domaindnshostname}</th>
                            <th class="dns-col-type">{$LANG.domaindnsrecordtype}</th>
                            <th class="dns-col-addr">{$LANG.domaindnsaddress}</th>
                            <th class="dns-col-prio">{$LANG.domaindnspriority}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {if isset($dnsrecords) && $dnsrecords|@count > 0}
                        {foreach $dnsrecords as $rec}
                            <tr class="dns-row" data-type="{$rec.type|default:'A'|escape}">
                                <td>
                                    <input type="hidden" name="dnsrecid[]" value="{$rec.recid|default:''|escape}">
                                    <input type="text" name="dnsrecordhost[]" value="{$rec.hostname|default:''|escape}" class="dns-input dns-input-host" placeholder="@">
                                </td>
                                <td>
                                    <select name="dnsrecordtype[]" class="dns-input dns-input-type">
                                        <option value="A"     {if $rec.type eq 'A'} selected{/if}>A</option>
                                        <option value="AAAA"  {if $rec.type eq 'AAAA'} selected{/if}>AAAA</option>
                                        <option value="CNAME" {if $rec.type eq 'CNAME'} selected{/if}>CNAME</option>
                                        <option value="MX"    {if $rec.type eq 'MX'} selected{/if}>MX</option>
                                        <option value="MXE"   {if $rec.type eq 'MXE'} selected{/if}>MXE</option>
                                        <option value="TXT"   {if $rec.type eq 'TXT'} selected{/if}>TXT</option>
                                        <option value="URL"   {if $rec.type eq 'URL'} selected{/if}>URL</option>
                                        <option value="FRAME" {if $rec.type eq 'FRAME'} selected{/if}>FRAME</option>
                                    </select>
                                </td>
                                <td><input type="text" name="dnsrecordaddress[]" value="{$rec.address|default:''|escape}" class="dns-input dns-input-addr" placeholder="—"></td>
                                <td>
                                    {if $rec.type eq 'MX'}
                                        <input type="text" name="dnsrecordpriority[]" value="{$rec.priority|default:''|escape}" class="dns-input dns-input-prio">
                                    {else}
                                        <input type="hidden" name="dnsrecordpriority[]" value="N/A">
                                        <span class="dns-na">—</span>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                        {/if}

                        {* Empty rows for adding new records *}
                        <tr class="dns-row dns-row-new" data-type="A">
                            <td><input type="text" name="dnsrecordhost[]" class="dns-input dns-input-host" placeholder="@"></td>
                            <td>
                                <select name="dnsrecordtype[]" class="dns-input dns-input-type">
                                    <option value="A">A</option>
                                    <option value="AAAA">AAAA</option>
                                    <option value="CNAME">CNAME</option>
                                    <option value="MX">MX</option>
                                    <option value="MXE">MXE</option>
                                    <option value="TXT">TXT</option>
                                    <option value="URL">URL</option>
                                    <option value="FRAME">FRAME</option>
                                </select>
                            </td>
                            <td><input type="text" name="dnsrecordaddress[]" class="dns-input dns-input-addr" placeholder="—"></td>
                            <td><input type="text" name="dnsrecordpriority[]" class="dns-input dns-input-prio" placeholder="—"></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <p class="dns-note">* {$LANG.domaindnsmxonly}</p>

            <div class="dns-actions">
                <button type="submit" class="btn-primary">{$LANG.clientareasavechanges}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="btn-secondary">{$LANG.clientareacancel}</a>
            </div>
        </form>

        {/if}

    </div>

    <aside class="dns-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$hadrianLang.domains.domainDetails}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindns&domainid={$domainid|escape}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                {$LANG.domaindnsmanagement}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domainemailforwarding&domainid={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                {$LANG.domainemailforwarding}
            </a>
        </div>
        <div class="card dns-help">
            <h4 class="dns-help-title">{$hadrianLang.domains.dnsHelpTitle}</h4>
            <dl class="dns-help-list">
                <dt>A</dt><dd>{$hadrianLang.domains.dnsHelpA}</dd>
                <dt>AAAA</dt><dd>{$hadrianLang.domains.dnsHelpAaaa}</dd>
                <dt>CNAME</dt><dd>{$hadrianLang.domains.dnsHelpCname}</dd>
                <dt>MX</dt><dd>{$hadrianLang.domains.dnsHelpMx}</dd>
                <dt>TXT</dt><dd>{$hadrianLang.domains.dnsHelpTxt}</dd>
            </dl>
        </div>
    </aside>
</div>

<script>{literal}
(function(){
    function refresh(row){
        var sel = row.querySelector('.dns-input-type');
        var type = (sel && sel.value) || 'A';
        row.setAttribute('data-type', type);
    }
    document.querySelectorAll('.dns-row').forEach(function(r){
        refresh(r);
        var t = r.querySelector('.dns-input-type');
        if (t) t.addEventListener('change', function(){ refresh(r); });
    });
})();
{/literal}</script>
