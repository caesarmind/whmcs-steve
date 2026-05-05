{* =========================================================================
   clientareadomaindetails.tpl — single-domain management with tabs.
   ========================================================================= *}
{if $registrarcustombuttonresult == "success"}
    {include file="$template/includes/alert.tpl" type="success" msg="{lang key='moduleactionsuccess'}" textcenter=true}
{elseif $registrarcustombuttonresult}
    {include file="$template/includes/alert.tpl" type="error" msg="{lang key='moduleactionfailed'}" textcenter=true}
{/if}

{if $unpaidInvoice}
    <div class="callout {if $unpaidInvoiceOverdue}danger{else}warning{/if}">
        <a href="viewinvoice.php?id={$unpaidInvoice}" class="btn btn-sm btn-primary float-right">{lang key='payInvoice'}</a>
        {$unpaidInvoiceMessage}
    </div>
{/if}

<div class="tab-content">
    <div class="tab-pane fade show active" id="tabOverview">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='overview'}</h3></div>
            <div class="card-body">
                {if $alerts}
                    {foreach $alerts as $alert}
                        {include file="$template/includes/alert.tpl" type=$alert.type msg="<strong>{$alert.title}</strong><br>{$alert.description}" textcenter=true}
                    {/foreach}
                {/if}

                {if $systemStatus != 'Active'}
                    {include file="$template/includes/alert.tpl" type="warning" msg="{lang key='domainCannotBeManagedUnlessActive'}" textcenter=true}
                {/if}

                {if $lockstatus eq "unlocked"}
                    {include file="$template/includes/alert.tpl" type="error" msg="<strong>{lang key='domaincurrentlyunlocked'}</strong><br>{lang key='domaincurrentlyunlockedexp'}"}
                {/if}

                <div class="product-meta-grid">
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='clientareahostingdomain'}</div><div class="product-meta-value"><a href="http://{$domain}" target="_blank" rel="noopener">{$domain}</a></div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='firstpaymentamount'}</div><div class="product-meta-value">{$firstpaymentamount}</div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='clientareahostingregdate'}</div><div class="product-meta-value">{$registrationdate}</div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='recurringamount'}</div><div class="product-meta-value">{$recurringamount} {lang key='every'} {$registrationperiod} {lang key='orderyears'}</div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='clientareahostingnextduedate'}</div><div class="product-meta-value">{$nextduedate}</div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='orderpaymentmethod'}</div><div class="product-meta-value">{$paymentmethod}</div></div>
                    <div class="product-meta-item"><div class="product-meta-label">{lang key='clientareastatus'}</div><div class="product-meta-value"><span class="status-pill active">{$status}</span></div></div>
                </div>

                {if $registrarclientarea}
                    <div class="moduleoutput mt-3">{$registrarclientarea|replace:'modulebutton':'btn'}</div>
                {/if}

                {foreach $hookOutput as $output}<div>{$output}</div>{/foreach}

                {if $canDomainBeManaged and ($managementoptions.nameservers or $managementoptions.contacts or $managementoptions.locking or $renew)}
                    <h4 class="mt-3">{lang key='doToday'}</h4>
                    <ul class="do-today-list">
                        {if $systemStatus == 'Active' && $managementoptions.nameservers}
                            <li><a class="tabControlLink" data-toggle="tab" href="#tabNameservers">{lang key='changeDomainNS'}</a></li>
                        {/if}
                        {if $systemStatus == 'Active' && $managementoptions.contacts}
                            <li><a href="clientarea.php?action=domaincontacts&domainid={$domainid}">{lang key='updateWhoisContact'}</a></li>
                        {/if}
                        {if $systemStatus == 'Active' && $managementoptions.locking}
                            <li><a class="tabControlLink" data-toggle="tab" href="#tabReglock">{lang key='changeRegLock'}</a></li>
                        {/if}
                        {if $renew}
                            <li><a href="{routePath('domain-renewal', $domain)}">{lang key='domainrenew'}</a></li>
                        {/if}
                    </ul>
                {/if}
            </div>
        </div>
    </div>

    <div class="tab-pane fade" id="tabAutorenew">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='domainsautorenew'}</h3></div>
            <div class="card-body">
                {if $changeAutoRenewStatusSuccessful}
                    {include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}
                {/if}
                <p>{lang key='domainrenewexp'}</p>
                <p class="text-center">
                    {lang key='domainautorenewstatus'}:
                    <span class="status-pill {if $autorenew}success{else}danger{/if}">{if $autorenew}{lang key='domainsautorenewenabled'}{else}{lang key='domainsautorenewdisabled'}{/if}</span>
                </p>
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabAutorenew">
                    <input type="hidden" name="id" value="{$domainid}">
                    <input type="hidden" name="sub" value="autorenew">
                    <input type="hidden" name="autorenew" value="{if $autorenew}disable{else}enable{/if}">
                    <button type="submit" class="btn btn-lg {if $autorenew}btn-danger{else}btn-primary{/if} btn-full">
                        {if $autorenew}{lang key='domainsautorenewdisable'}{else}{lang key='domainsautorenewenable'}{/if}
                    </button>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-pane fade" id="tabNameservers">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='domainnameservers'}</h3></div>
            <div class="card-body">
                {if $nameservererror}{include file="$template/includes/alert.tpl" type="error" msg=$nameservererror textcenter=true}{/if}
                {if $subaction eq "savens"}
                    {if $updatesuccess}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}
                    {elseif $error}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}
                {/if}
                {include file="$template/includes/alert.tpl" type="info" msg="{lang key='domainnsexp'}"}
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabNameservers">
                    <input type="hidden" name="id" value="{$domainid}">
                    <input type="hidden" name="sub" value="savens">
                    <label class="radio-label"><input type="radio" name="nschoice" value="default" onclick="disableFields('domnsinputs',true)"{if $defaultns} checked{/if}> {lang key='nschoicedefault'}</label>
                    <label class="radio-label"><input type="radio" name="nschoice" value="custom" onclick="disableFields('domnsinputs',false)"{if !$defaultns} checked{/if}> {lang key='nschoicecustom'}</label>
                    {for $num=1 to 5}
                        <div class="form-group">
                            <label for="inputNs{$num}" class="form-label">{lang key='clientareanameserver'} {$num}</label>
                            <input type="text" name="ns{$num}" class="form-input domnsinputs" id="inputNs{$num}" value="{$nameservers[$num].value}">
                        </div>
                    {/for}
                    <button type="submit" class="btn btn-primary">{lang key='changenameservers'}</button>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-pane fade" id="tabReglock">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='domainregistrarlock'}</h3></div>
            <div class="card-body">
                {if $subaction eq "savereglock"}
                    {if $updatesuccess}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}
                    {elseif $error}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}
                {/if}
                {include file="$template/includes/alert.tpl" type="info" msg="{lang key='domainlockingexp'}"}
                <p class="text-center">
                    {lang key='domainreglockstatus'}:
                    <span class="status-pill {if $lockstatus == 'locked'}success{else}danger{/if}">{if $lockstatus == 'locked'}{lang key='domainsautorenewenabled'}{else}{lang key='domainsautorenewdisabled'}{/if}</span>
                </p>
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabReglock">
                    <input type="hidden" name="id" value="{$domainid}">
                    <input type="hidden" name="sub" value="savereglock">
                    {if $lockstatus=="locked"}
                        <button type="submit" class="btn btn-lg btn-danger btn-full">{lang key='domainreglockdisable'}</button>
                    {else}
                        <button type="submit" class="btn btn-lg btn-primary btn-full" name="reglock" value="1">{lang key='domainreglockenable'}</button>
                    {/if}
                </form>
            </div>
        </div>
    </div>

    <div class="tab-pane fade" id="tabRelease">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='domainrelease'}</h3></div>
            <div class="card-body">
                {if $releaseDomainSuccessful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}
                {elseif !empty($error)}{include file="$template/includes/alert.tpl" type="error" msg=$error textcenter=true}{/if}
                {include file="$template/includes/alert.tpl" type="info" msg="{lang key='domainreleasedescription'}"}
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindetails#tabRelease">
                    <input type="hidden" name="sub" value="releasedomain">
                    <input type="hidden" name="id" value="{$domainid}">
                    <div class="form-group">
                        <label for="inputReleaseTag" class="form-label">{lang key='domainreleasetag'}</label>
                        <input type="text" class="form-input" id="inputReleaseTag" name="transtag">
                    </div>
                    <button type="submit" class="btn btn-primary">{lang key='domainrelease'}</button>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-pane fade" id="tabAddons">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='domainaddons'}</h3></div>
            <div class="card-body">
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
    </div>
</div>
