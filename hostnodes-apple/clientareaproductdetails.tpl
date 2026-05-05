{* =========================================================================
   clientareaproductdetails.tpl — single service management page with tabs.
   ========================================================================= *}
{if $modulecustombuttonresult}
    {if $modulecustombuttonresult == "success"}
        {include file="$template/includes/alert.tpl" type="success" msg="{lang key='moduleactionsuccess'}" textcenter=true idname="alertModuleCustomButtonSuccess"}
    {else}
        {include file="$template/includes/alert.tpl" type="error" msg="{lang key='moduleactionfailed'}"|cat:' ':$modulecustombuttonresult textcenter=true idname="alertModuleCustomButtonFailed"}
    {/if}
{/if}

{if $pendingcancellation}
    {include file="$template/includes/alert.tpl" type="error" msg="{lang key='cancellationrequestedexplanation'}" textcenter=true idname="alertPendingCancellation"}
{/if}

{if $unpaidInvoice}
    <div class="callout {if $unpaidInvoiceOverdue}danger{else}warning{/if}" id="alert{if $unpaidInvoiceOverdue}Overdue{else}Unpaid{/if}Invoice">
        <a href="viewinvoice.php?id={$unpaidInvoice}" class="btn btn-sm btn-primary float-right">{lang key='payInvoice'}</a>
        {$unpaidInvoiceMessage}
    </div>
{/if}

<div class="tab-content">
    <div class="tab-pane fade show active" role="tabpanel" id="tabOverview">
        {if $tplOverviewTabOutput}
            {$tplOverviewTabOutput}
        {else}
            <div class="card">
                <div class="card-body">
                    <div class="product-details">
                        <div class="product-details-header">
                            <div class="product-details-icon">
                                <i class="fas fa-{if $type eq 'hostingaccount' || $type == 'reselleraccount'}hdd{elseif $type eq 'server'}database{else}archive{/if}"></i>
                            </div>
                            <h2 class="product-details-name">{$product}</h2>
                            <h3 class="product-details-group">{$groupname}</h3>
                            <span class="status-pill {$rawstatus|strtolower} mt-2">{$status}</span>
                        </div>

                        <div class="product-meta-grid">
                            <div class="product-meta-item">
                                <div class="product-meta-label">{lang key='clientareahostingregdate'}</div>
                                <div class="product-meta-value">{$regdate}</div>
                            </div>
                            {if $firstpaymentamount neq $recurringamount}
                                <div class="product-meta-item">
                                    <div class="product-meta-label">{lang key='firstpaymentamount'}</div>
                                    <div class="product-meta-value">{$firstpaymentamount}</div>
                                </div>
                            {/if}
                            {if $billingcycle != "{lang key='orderpaymenttermonetime'}" && $billingcycle != "{lang key='orderfree'}"}
                                <div class="product-meta-item">
                                    <div class="product-meta-label">{lang key='recurringamount'}</div>
                                    <div class="product-meta-value">{$recurringamount}</div>
                                </div>
                            {/if}
                            {if $quantitySupported && $quantity > 1}
                                <div class="product-meta-item">
                                    <div class="product-meta-label">{lang key='quantity'}</div>
                                    <div class="product-meta-value">{$quantity}</div>
                                </div>
                            {/if}
                            <div class="product-meta-item">
                                <div class="product-meta-label">{lang key='orderbillingcycle'}</div>
                                <div class="product-meta-value">{$billingcycle}</div>
                            </div>
                            <div class="product-meta-item">
                                <div class="product-meta-label">{lang key='clientareahostingnextduedate'}</div>
                                <div class="product-meta-value">{$nextduedate}</div>
                            </div>
                            <div class="product-meta-item">
                                <div class="product-meta-label">{lang key='orderpaymentmethod'}</div>
                                <div class="product-meta-value">{$paymentmethod}</div>
                            </div>
                            {if $suspendreason}
                                <div class="product-meta-item">
                                    <div class="product-meta-label">{lang key='suspendreason'}</div>
                                    <div class="product-meta-value">{$suspendreason}</div>
                                </div>
                            {/if}
                        </div>

                        {if $showRenewServiceButton || $showcancelbutton || $packagesupgrade}
                            <div class="btn-group product-actions">
                                {if $packagesupgrade}
                                    <a href="upgrade.php?type=package&amp;id={$id}" class="btn btn-primary"><i class="fas fa-level-up-alt"></i> {lang key='upgrade'}</a>
                                {/if}
                                {if $showRenewServiceButton}
                                    <a href="{routePath('service-renewals-service', $id)}" class="btn btn-primary"><i class="fas fa-sync"></i> {lang key='renewService.titleSingular'}</a>
                                {/if}
                                {if $showcancelbutton}
                                    <a href="clientarea.php?action=cancel&amp;id={$id}" class="btn btn-danger{if $pendingcancellation} disabled{/if}">
                                        <i class="fas fa-ban"></i>
                                        {if $pendingcancellation}{lang key='cancellationrequested'}{else}{lang key='clientareacancelrequestbutton'}{/if}
                                    </a>
                                {/if}
                            </div>
                        {/if}
                    </div>
                </div>
            </div>

            {foreach $hookOutput as $output}
                <div>{$output}</div>
            {/foreach}

            {if $domain || $moduleclientarea || $configurableoptions || $customfields || $lastupdate}
                <div class="card">
                    <div class="card-header">
                        <div class="filter-tabs product-tabs" role="tablist">
                            {if $domain}
                                <a href="#domain" data-toggle="tab" class="filter-tab active"><i class="fas fa-globe"></i> {if $type eq 'server'}{lang key='sslserverinfo'}{elseif ($type eq 'hostingaccount' || $type eq 'reselleraccount') && $serverdata}{lang key='hostingInfo'}{else}{lang key='clientareahostingdomain'}{/if}</a>
                            {elseif $moduleclientarea}
                                <a href="#manage" data-toggle="tab" class="filter-tab active"><i class="fas fa-cogs"></i> {lang key='manage'}</a>
                            {/if}
                            {if $configurableoptions}<a href="#configoptions" data-toggle="tab" class="filter-tab{if !$domain && !$moduleclientarea} active{/if}"><i class="fas fa-cubes"></i> {lang key='orderconfigpackage'}</a>{/if}
                            {if $metricStats}<a href="#metrics" data-toggle="tab" class="filter-tab{if !$domain && !$moduleclientarea && !$configurableoptions} active{/if}"><i class="fas fa-chart-line"></i> {lang key='metrics.title'}</a>{/if}
                            {if $customfields}<a href="#additionalinfo" data-toggle="tab" class="filter-tab{if !$domain && !$moduleclientarea && !$metricStats && !$configurableoptions} active{/if}"><i class="fas fa-info-circle"></i> {lang key='additionalInfo'}</a>{/if}
                            {if $lastupdate}<a href="#resourceusage" data-toggle="tab" class="filter-tab{if !$domain && !$moduleclientarea && !$configurableoptions && !$customfields} active{/if}"><i class="fas fa-inbox"></i> {lang key='resourceUsage'}</a>{/if}
                        </div>
                    </div>

                    <div class="card-body">
                        <div class="tab-content product-details-tabs">
                            {if $domain}
                                <div class="tab-pane fade show active" role="tabpanel" id="domain">
                                    {if $type eq 'server'}
                                        <div class="product-meta-grid">
                                            <div class="product-meta-item"><div class="product-meta-label">{lang key='serverhostname'}</div><div class="product-meta-value">{$domain}</div></div>
                                            {if $dedicatedip}<div class="product-meta-item"><div class="product-meta-label">{lang key='primaryIP'}</div><div class="product-meta-value">{$dedicatedip}</div></div>{/if}
                                            {if $assignedips}<div class="product-meta-item"><div class="product-meta-label">{lang key='assignedIPs'}</div><div class="product-meta-value">{$assignedips|nl2br}</div></div>{/if}
                                            {if $ns1 || $ns2}<div class="product-meta-item"><div class="product-meta-label">{lang key='domainnameservers'}</div><div class="product-meta-value">{$ns1}<br>{$ns2}</div></div>{/if}
                                        </div>
                                    {else}
                                        <div class="product-meta-grid">
                                            {if $domain}<div class="product-meta-item"><div class="product-meta-label">{lang key='orderdomain'}</div><div class="product-meta-value">{$domain}</div></div>{/if}
                                            {if $username}<div class="product-meta-item"><div class="product-meta-label">{lang key='serverusername'}</div><div class="product-meta-value">{$username}</div></div>{/if}
                                            {if $serverdata}
                                                <div class="product-meta-item"><div class="product-meta-label">{lang key='servername'}</div><div class="product-meta-value">{$serverdata.hostname}</div></div>
                                                <div class="product-meta-item"><div class="product-meta-label">{lang key='domainregisternsip'}</div><div class="product-meta-value">{$serverdata.ipaddress}</div></div>
                                            {/if}
                                        </div>
                                        <div class="btn-group mt-3">
                                            <a href="http://{$domain}" class="btn btn-secondary" target="_blank" rel="noopener">{lang key='visitwebsite'}</a>
                                            {if $domainId}<a href="clientarea.php?action=domaindetails&id={$domainId}" class="btn btn-secondary">{lang key='managedomain'}</a>{/if}
                                        </div>
                                    {/if}
                                    {if $moduleclientarea}<div class="module-client-area mt-3">{$moduleclientarea}</div>{/if}
                                </div>
                            {elseif $moduleclientarea}
                                <div class="tab-pane fade show active" role="tabpanel" id="manage">
                                    <div class="module-client-area">{$moduleclientarea}</div>
                                </div>
                            {/if}

                            {if $configurableoptions}
                                <div class="tab-pane fade{if !$domain && !$moduleclientarea} show active{/if}" role="tabpanel" id="configoptions">
                                    <div class="product-meta-grid">
                                        {foreach from=$configurableoptions item=configoption}
                                            <div class="product-meta-item">
                                                <div class="product-meta-label">{$configoption.optionname}</div>
                                                <div class="product-meta-value">{if $configoption.optiontype eq 3}{if $configoption.selectedqty}{lang key='yes'}{else}{lang key='no'}{/if}{elseif $configoption.optiontype eq 4}{$configoption.selectedqty} x {$configoption.selectedoption}{else}{$configoption.selectedoption}{/if}</div>
                                            </div>
                                        {/foreach}
                                    </div>
                                </div>
                            {/if}

                            {if $metricStats}
                                <div class="tab-pane fade{if !$domain && !$moduleclientarea && !$configurableoptions} show active{/if}" role="tabpanel" id="metrics">
                                    {include file="$template/clientareaproductusagebilling.tpl"}
                                </div>
                            {/if}

                            {if $customfields}
                                <div class="tab-pane fade{if !$domain && !$moduleclientarea && !$configurableoptions && !$metricStats} show active{/if}" role="tabpanel" id="additionalinfo">
                                    <div class="product-meta-grid">
                                        {foreach from=$customfields item=field}
                                            <div class="product-meta-item">
                                                <div class="product-meta-label">{$field.name}</div>
                                                <div class="product-meta-value">{$field.value}</div>
                                            </div>
                                        {/foreach}
                                    </div>
                                </div>
                            {/if}

                            {if $lastupdate}
                                <div class="tab-pane fade" role="tabpanel" id="resourceusage">
                                    <div class="usage-stats">
                                        <div class="usage-stat">
                                            <h4>{lang key='diskSpace'}</h4>
                                            <div class="usage-bar"><div class="usage-bar-fill" style="width:{$diskpercent}"></div></div>
                                            <p class="form-hint">{$diskusage}MB / {$disklimit}MB</p>
                                        </div>
                                        <div class="usage-stat">
                                            <h4>{lang key='bandwidth'}</h4>
                                            <div class="usage-bar"><div class="usage-bar-fill" style="width:{$bwpercent}"></div></div>
                                            <p class="form-hint">{$bwusage}MB / {$bwlimit}MB</p>
                                        </div>
                                    </div>
                                    <p class="form-hint">{lang key='clientarealastupdated'}: {$lastupdate}</p>
                                </div>
                            {/if}
                        </div>
                    </div>
                </div>
            {/if}
        {/if}
    </div>

    <div class="tab-pane fade" role="tabpanel" id="tabChangepw">
        <div class="card">
            <div class="card-header"><h3 class="card-title">{lang key='serverchangepassword'}</h3></div>
            <div class="card-body">
                {if $modulechangepwresult}
                    {if $modulechangepwresult == "success"}
                        {include file="$template/includes/alert.tpl" type="success" msg=$modulechangepasswordmessage textcenter=true}
                    {elseif $modulechangepwresult == "error"}
                        {include file="$template/includes/alert.tpl" type="error" msg=$modulechangepasswordmessage|strip_tags textcenter=true}
                    {/if}
                {/if}
                <form class="using-password-strength" method="post" action="{$smarty.server.PHP_SELF}?action=productdetails#tabChangepw">
                    <input type="hidden" name="id" value="{$id}">
                    <input type="hidden" name="modulechangepassword" value="true">
                    <div class="form-group" id="newPassword1">
                        <label for="inputNewPassword1" class="form-label">{lang key='newpassword'}</label>
                        <input type="password" class="form-input" id="inputNewPassword1" name="newpw" autocomplete="off">
                        {include file="$template/includes/pwstrength.tpl"}
                    </div>
                    <div class="form-group" id="newPassword2">
                        <label for="inputNewPassword2" class="form-label">{lang key='confirmnewpassword'}</label>
                        <input type="password" class="form-input" id="inputNewPassword2" name="confirmpw" autocomplete="off">
                        <div id="inputNewPassword2Msg"></div>
                    </div>
                    <div class="btn-group">
                        <button type="button" class="btn btn-secondary generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">{lang key='generatePassword.btnLabel'}</button>
                        <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
