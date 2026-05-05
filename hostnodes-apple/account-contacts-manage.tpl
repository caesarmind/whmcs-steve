{* =========================================================================
   account-contacts-manage.tpl — manage existing sub-account contacts.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='contacts.title'}</h1>
    <a href="{routePath('account-contacts-new')}" class="btn btn-primary"><i class="fas fa-plus"></i> {lang key='contacts.addNew'}</a>
</div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body">
        {if $contacts && count($contacts) > 0}
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>{lang key='name'}</th>
                            <th>{lang key='email'}</th>
                            <th>{lang key='contacts.type'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $contacts as $contact}
                            <tr>
                                <td>{$contact.firstname} {$contact.lastname}</td>
                                <td>{$contact.email}</td>
                                <td>{$contact.type}</td>
                                <td class="text-right">
                                    <a href="?contactid={$contact.id}" class="btn btn-secondary btn-sm">{lang key='edit'}</a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='contacts.noneFound'}" textcenter=true}
        {/if}
    </div>
</div>
