{* =========================================================================
   clientareaemails.tpl — history of system emails sent to the client.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='clientareanavemails'}</h1></div>

{include file="$template/includes/tablelist.tpl" tableName="EmailsList" startOrderCol="0" noSortColumns="2"}

<div class="card">
    <div class="card-body">
        <div class="table-container">
            <table id="tableEmailsList" class="table table-hover">
                <thead>
                    <tr>
                        <th>{lang key='clientareaemailsdate'}</th>
                        <th>{lang key='clientareaemailssubject'}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $emails as $email}
                        <tr onclick="clickableSafeRedirect(event, 'viewemail.php?id={$email.id}', false)">
                            <td><span class="w-hidden">{$email.normalisedDate}</span>{$email.date}</td>
                            <td>{$email.subject}</td>
                            <td><span class="service-chevron"><i class="fas fa-chevron-right"></i></span></td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>
