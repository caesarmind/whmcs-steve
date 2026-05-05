{* =========================================================================
   clientareaquotes.tpl — list of sales quotes.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='quotes'}</h1></div>

{include file="$template/includes/tablelist.tpl" tableName="QuotesList"}

<div class="card">
    <div class="card-body">
        <div class="table-container">
            <table id="tableQuotesList" class="table table-hover">
                <thead>
                    <tr>
                        <th>{lang key='quotenumber'}</th>
                        <th>{lang key='subject'}</th>
                        <th>{lang key='datecreated'}</th>
                        <th>{lang key='validuntil'}</th>
                        <th class="text-right">{lang key='total'}</th>
                        <th>{lang key='status'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $quotes as $quote}
                        <tr onclick="clickableSafeRedirect(event, 'viewquote.php?id={$quote.id}', false)">
                            <td>#{$quote.id}</td>
                            <td>{$quote.subject}</td>
                            <td>{$quote.datecreated}</td>
                            <td>{$quote.validuntil}</td>
                            <td class="text-right">{$quote.total}</td>
                            <td><span class="status-pill {$quote.stage|strtolower}">{$quote.stage}</span></td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>
