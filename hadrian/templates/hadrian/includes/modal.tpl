{* Modal - the WHMCS shared include, for code that includes
   "$template/includes/modal.tpl" by name. Stock Bootstrap 4 markup with the
   stock ids (#modal<name>, #modal<name>Title, #modal<name>Loader,
   #modal<name>Body), because the caller's own JS opens and fills it with
   Bootstrap's .modal() - available on order-form pages, where Hadrian loads
   Bootstrap's JS and the order form styles .modal. Same parameters as stock:
   name, title, content, closeLabel, submitAction, submitLabel. *}
<div class="modal fade" id="modal{$name}" tabindex="-1" role="dialog" aria-labelledby="modal{$name}Title">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="modal{$name}Title">{$title}</h4>
                <button type="button" class="close" data-dismiss="modal" aria-label="{$LANG.close}"><span aria-hidden="true">&times;</span></button>
            </div>
            <div class="modal-body w-hidden" id="modal{$name}Loader" hidden>
                <p>{lang key='loading'}</p>
            </div>
            <div class="modal-body" id="modal{$name}Body">
                {if isset($content)}<p>{$content}</p>{/if}
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary" data-dismiss="modal">{if isset($closeLabel)}{$closeLabel}{else}{lang key='closewindow'}{/if}</button>
                {if isset($submitAction)}
                    <button type="button" class="btn-primary" onclick="{$submitAction}">{if isset($submitLabel)}{$submitLabel}{else}{lang key='clientareasavechanges'}{/if}</button>
                {/if}
            </div>
        </div>
    </div>
</div>
