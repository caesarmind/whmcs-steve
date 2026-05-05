{* =========================================================================
   clientareadomainemailforwarding.tpl — email forwarding rules editor.
   ========================================================================= *}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}
{if $successfulAction}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domainemailforwarding'}</h3></div>
    <div class="card-body">
        <p>{lang key='domainemailforwardingexp'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domainemailforwarding&domainid={$domainid}">
            <input type="hidden" name="sub" value="saveemailforwarding">

            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='prefix'}</th>
                            <th>{lang key='domainname'}</th>
                            <th>{lang key='forwardto'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $forwarding as $num => $forward}
                            <tr>
                                <td><input type="text" name="forwarding[{$num}][prefix]" value="{$forward.prefix}" class="form-input"></td>
                                <td>@{$domain}</td>
                                <td><input type="text" name="forwarding[{$num}][forwardto]" value="{$forward.forwardto}" class="form-input"></td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>

            <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
        </form>
    </div>
</div>
