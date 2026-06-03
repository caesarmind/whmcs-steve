{* Hostnodes - Manage SSL certificates (Apple-style): certificate list.

   WHMCS variables (cross-checked against Nexus managessl.tpl, WHMCS 9):
     $sslProducts  - collection of SslProduct objects, each:
                       ->addonId, ->addon (addon-based) | ->service (standalone)
                       ->validationType ('DV'|'OV'|'EV')
                       ->status (compared to $sslStatusAwaiting* constants)
                       ->addon|service ->domain, ->productAddon|product->name,
                         ->nextDueDateFormatted, ->nextDueDateProperties[isPast|isFuture|daysTillExpiry]
                       ->getConfigurationUrl(), ->getUpgradeUrl(), ->id
     $sslStatusAwaitingConfiguration / $sslStatusAwaitingIssuance - status constants
   Every deep chain is isset-guarded so a partial object can't blank the page.
   Demo data under ?preview=1 uses plain arrays (no object model needed).
*}

{assign var=hasProducts value=false}
{if isset($sslProducts) && $sslProducts|@count > 0}{assign var=hasProducts value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=sslDemo value=false}
{if !$hasProducts && $isPreview}
    {assign var=sslDemo value=true}
    {assign var=sslDemoRows value=[
        ['domain'=>'hendersondesign.com','name'=>'PositiveSSL OV','type'=>'OV','typeClass'=>'ov','status'=>'Active','statusClass'=>'active','expires'=>'Dec 15, 2026','action'=>'manage'],
        ['domain'=>'alexhenderson.io','name'=>'PositiveSSL DV','type'=>'DV','typeClass'=>'','status'=>'Active','statusClass'=>'active','expires'=>'Mar 22, 2027','action'=>'manage'],
        ['domain'=>'myportfolio.dev','name'=>'PositiveSSL DV','type'=>'DV','typeClass'=>'','status'=>'Expired','statusClass'=>'expired','expires'=>'Feb 28, 2026','action'=>'renew'],
        ['domain'=>'newsite.app','name'=>'EV SSL','type'=>'EV','typeClass'=>'ev','status'=>'Awaiting configuration','statusClass'=>'info','expires'=>'-','action'=>'configure']
    ]}
{/if}

{assign var=sslFull value=false}
{if $hasProducts || $sslDemo}{assign var=sslFull value=true}{/if}
{if $sslFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/managessl.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div>
            <p class="page-eyebrow">{$LANG.domainssloptions}</p>
            <h1>{$LANG.nav_manage_ssl}</h1>
            <p class="page-subtitle">{$hadrianLang.ssl.manageIntro}</p>
        </div>
        {if $sslFull}<a href="{$WEB_ROOT}/cart.php?gid=ssl" class="btn-primary">{$hadrianLang.ssl.orderNew}</a>{/if}
    </div>
</header>

{if $sslFull}
<div class="when-full">
    <div class="card">
        <div class="card-body" style="padding: 0;">
            <table class="ssl-table">
                <thead>
                    <tr>
                        <th>{$LANG.ssldomain}</th>
                        <th>{$LANG.sslproduct}</th>
                        <th>{$LANG.invoicesstatus}</th>
                        <th>{$LANG.sslrenewaldate}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                {if $sslDemo}
                    {foreach $sslDemoRows as $row}
                    <tr>
                        <td><span class="ssl-domain">{$row.domain|escape}</span></td>
                        <td>{$row.name|escape} <span class="ssl-type {$row.typeClass}">{$row.type|escape}</span></td>
                        <td><span class="ssl-pill {$row.statusClass}">{$row.status|escape}</span></td>
                        <td class="ssl-date">{$row.expires|escape}</td>
                        <td class="ssl-actions-cell">
                            {if $row.action == 'configure'}<a href="{$WEB_ROOT}/configuressl.php" class="ssl-action">{$LANG.sslconfigure}</a>
                            {elseif $row.action == 'renew'}<a href="{$WEB_ROOT}/clientarea.php?action=services" class="ssl-action">{$LANG.renew}</a>
                            {else}<a href="{$WEB_ROOT}/clientarea.php?action=services" class="ssl-action">{$LANG.manageproduct}</a>{/if}
                        </td>
                    </tr>
                    {/foreach}
                {else}
                    {foreach $sslProducts as $sslProduct}
                        {assign var=isAddon value=false}
                        {if isset($sslProduct->addonId) && $sslProduct->addonId > 0}{assign var=isAddon value=true}{/if}

                        {assign var=sslDomain value='-'}
                        {assign var=sslName value=''}
                        {assign var=sslRenews value=''}
                        {assign var=isPast value=false}
                        {assign var=isFuture value=false}
                        {assign var=daysTill value=999}
                        {if $isAddon}
                            {if isset($sslProduct->addon->service->domain) && $sslProduct->addon->service->domain}{assign var=sslDomain value=$sslProduct->addon->service->domain}{/if}
                            {if isset($sslProduct->addon->productAddon->name)}{assign var=sslName value=$sslProduct->addon->productAddon->name}{/if}
                            {if isset($sslProduct->addon->nextDueDateFormatted)}{assign var=sslRenews value=$sslProduct->addon->nextDueDateFormatted}{/if}
                            {if isset($sslProduct->addon->nextDueDateProperties['isPast']) && $sslProduct->addon->nextDueDateProperties['isPast']}{assign var=isPast value=true}{/if}
                            {if isset($sslProduct->addon->nextDueDateProperties['isFuture']) && $sslProduct->addon->nextDueDateProperties['isFuture']}{assign var=isFuture value=true}{/if}
                            {if isset($sslProduct->addon->nextDueDateProperties['daysTillExpiry'])}{assign var=daysTill value=$sslProduct->addon->nextDueDateProperties['daysTillExpiry']}{/if}
                        {else}
                            {if isset($sslProduct->service->domain) && $sslProduct->service->domain}{assign var=sslDomain value=$sslProduct->service->domain}{/if}
                            {if isset($sslProduct->service->product->name)}{assign var=sslName value=$sslProduct->service->product->name}{/if}
                            {if isset($sslProduct->service->nextDueDateFormatted)}{assign var=sslRenews value=$sslProduct->service->nextDueDateFormatted}{/if}
                            {if isset($sslProduct->service->nextDueDateProperties['isPast']) && $sslProduct->service->nextDueDateProperties['isPast']}{assign var=isPast value=true}{/if}
                            {if isset($sslProduct->service->nextDueDateProperties['isFuture']) && $sslProduct->service->nextDueDateProperties['isFuture']}{assign var=isFuture value=true}{/if}
                            {if isset($sslProduct->service->nextDueDateProperties['daysTillExpiry'])}{assign var=daysTill value=$sslProduct->service->nextDueDateProperties['daysTillExpiry']}{/if}
                        {/if}

                        {assign var=vType value=''}
                        {if isset($sslProduct->validationType)}{assign var=vType value=$sslProduct->validationType}{/if}
                        {assign var=vTypeClass value=''}
                        {if $vType == 'OV'}{assign var=vTypeClass value='ov'}{elseif $vType == 'EV'}{assign var=vTypeClass value='ev'}{/if}

                        {assign var=awaitingConfig value=false}
                        {if isset($sslStatusAwaitingConfiguration) && isset($sslProduct->status) && $sslProduct->status == $sslStatusAwaitingConfiguration}{assign var=awaitingConfig value=true}{/if}
                        {assign var=awaitingIssuance value=false}
                        {if isset($sslStatusAwaitingIssuance) && isset($sslProduct->status) && $sslProduct->status == $sslStatusAwaitingIssuance}{assign var=awaitingIssuance value=true}{/if}

                        <tr>
                            <td>
                                {if $awaitingConfig}<span class="ssl-pill info">{$LANG.sslawaitingconfig}</span>
                                {else}<span class="ssl-domain">{$sslDomain|escape}</span>{/if}
                            </td>
                            <td>{$sslName|escape}{if $vType} <span class="ssl-type {$vTypeClass}">{$vType|escape}</span>{/if}</td>
                            <td>
                                {if $awaitingConfig}<span class="ssl-pill info">{$LANG.sslawaitingconfig}</span>
                                {elseif $awaitingIssuance}<span class="ssl-pill info">{$LANG.sslawaitingissuance}</span>
                                {elseif $isPast}<span class="ssl-pill expired">{$LANG.clientareaexpired}</span>
                                {elseif $daysTill < 60}<span class="ssl-pill warn">{$LANG.expiringsoon}</span>
                                {else}<span class="ssl-pill active">{$LANG.clientareaactive}</span>{/if}
                            </td>
                            <td class="ssl-date">{if $sslRenews}{$sslRenews|escape}{else}-{/if}</td>
                            <td class="ssl-actions-cell">
                                {if $awaitingConfig}<a href="{$sslProduct->getConfigurationUrl()}" class="ssl-action">{$LANG.sslconfigure}</a>{/if}
                                {if $isFuture && isset($sslProduct->id)}
                                <form class="ssl-action-form" action="{$sslProduct->getUpgradeUrl()}" method="post">
                                    <input type="hidden" name="id" value="{$sslProduct->id}">
                                    <button type="submit" class="ssl-action"{if $vType == 'EV'} disabled{/if}>{$LANG.upgrade}</button>
                                </form>
                                {/if}
                                <a href="{$WEB_ROOT}/clientarea.php?action=services" class="ssl-action">{$LANG.manageproduct}</a>
                            </td>
                        </tr>
                    {/foreach}
                {/if}
                </tbody>
            </table>
        </div>
    </div>
</div>{* /.when-full *}
{/if}

{if !$sslFull}
<div class="when-empty">
    <div class="card">
        <div class="ssl-empty">
            <div class="ssl-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <p class="ssl-empty-title">{$hadrianLang.ssl.noCertificates}</p>
            <p class="ssl-empty-sub">{$hadrianLang.ssl.noCertificatesSub}</p>
            <a href="{$WEB_ROOT}/cart.php?gid=ssl" class="btn-primary">{$hadrianLang.ssl.browse}</a>
        </div>
    </div>
</div>
{/if}
