{* =========================================================================
   clientareadomainregisterns.tpl — register custom nameservers for a domain.
   ========================================================================= *}
{if $success}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}
{if $errors}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errors}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domainregisternameservers'}</h3></div>
    <div class="card-body">
        <p>{lang key='domainregisternsexp'}</p>

        <div class="filter-tabs" role="tablist">
            <a href="#tabAdd" class="filter-tab active" data-toggle="tab">{lang key='domainregisternsadd'}</a>
            <a href="#tabModify" class="filter-tab" data-toggle="tab">{lang key='domainregisternsmodify'}</a>
            <a href="#tabDelete" class="filter-tab" data-toggle="tab">{lang key='domainregisternsdelete'}</a>
        </div>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="tabAdd">
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domainregisterns&domainid={$domainid}">
                    <input type="hidden" name="sub" value="add">
                    <div class="form-group">
                        <label for="nsAddName" class="form-label">{lang key='domainregisternsname'}</label>
                        <input type="text" name="ns" id="nsAddName" class="form-input">
                    </div>
                    <div class="form-group">
                        <label for="nsAddIp" class="form-label">{lang key='domainregisternsip'}</label>
                        <input type="text" name="ip" id="nsAddIp" class="form-input">
                    </div>
                    <button type="submit" class="btn btn-primary">{lang key='domainregisternsadd'}</button>
                </form>
            </div>

            <div class="tab-pane fade" id="tabModify">
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domainregisterns&domainid={$domainid}">
                    <input type="hidden" name="sub" value="modify">
                    <div class="form-group">
                        <label for="nsModifyName" class="form-label">{lang key='domainregisternsname'}</label>
                        <input type="text" name="ns" id="nsModifyName" class="form-input">
                    </div>
                    <div class="form-group">
                        <label for="nsModifyCurrentIp" class="form-label">{lang key='domainregisternscurrentip'}</label>
                        <input type="text" name="currentip" id="nsModifyCurrentIp" class="form-input">
                    </div>
                    <div class="form-group">
                        <label for="nsModifyNewIp" class="form-label">{lang key='domainregisternsnewip'}</label>
                        <input type="text" name="newip" id="nsModifyNewIp" class="form-input">
                    </div>
                    <button type="submit" class="btn btn-primary">{lang key='domainregisternsmodify'}</button>
                </form>
            </div>

            <div class="tab-pane fade" id="tabDelete">
                <form method="post" action="{$smarty.server.PHP_SELF}?action=domainregisterns&domainid={$domainid}">
                    <input type="hidden" name="sub" value="delete">
                    <div class="form-group">
                        <label for="nsDeleteName" class="form-label">{lang key='domainregisternsname'}</label>
                        <input type="text" name="ns" id="nsDeleteName" class="form-input">
                    </div>
                    <button type="submit" class="btn btn-danger">{lang key='domainregisternsdelete'}</button>
                </form>
            </div>
        </div>
    </div>
</div>
