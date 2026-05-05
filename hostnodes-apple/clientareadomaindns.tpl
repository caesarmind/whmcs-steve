{* =========================================================================
   clientareadomaindns.tpl — DNS records editor (A, CNAME, MX, TXT, etc).
   ========================================================================= *}
{if $errormessage}
    {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
{/if}
{if $successfulAction}
    {include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}
{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domaindnsmanagement'}</h3></div>
    <div class="card-body">
        <p>{lang key='domaindnsmanagementexp'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domaindns&domainid={$domainid}">
            <input type="hidden" name="sub" value="savedns">

            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='hostname'}</th>
                            <th>{lang key='recordtype'}</th>
                            <th>{lang key='address'}</th>
                            <th>{lang key='priority'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $dnsrecords as $num => $record}
                            <tr>
                                <td><input type="text" name="dnsrecords[{$num}][hostname]" value="{$record.hostname}" class="form-input"></td>
                                <td>
                                    <select name="dnsrecords[{$num}][type]" class="form-input">
                                        {foreach $dnsrecordtypes as $type}
                                            <option value="{$type}"{if $type eq $record.type} selected{/if}>{$type}</option>
                                        {/foreach}
                                    </select>
                                </td>
                                <td><input type="text" name="dnsrecords[{$num}][address]" value="{$record.address}" class="form-input"></td>
                                <td><input type="text" name="dnsrecords[{$num}][priority]" value="{$record.priority}" class="form-input"></td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>

            <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
        </form>
    </div>
</div>
