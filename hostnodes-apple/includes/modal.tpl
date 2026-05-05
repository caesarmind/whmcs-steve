{* =========================================================================
   Generic modal. Parameters:
     name         — unique suffix (ID = modal{$name})
     title        — modal title
     content      — static body content (optional)
     closeLabel   — custom close button text
     submitAction — onclick JS for primary action button (optional)
     submitLabel  — primary button text
   ========================================================================= *}
<div class="modal fade apple-modal" id="modal{$name}" tabindex="-1" role="dialog">
    <div class="modal-backdrop"></div>
    <div class="modal-dialog">
        <div class="modal-content card">
            <div class="modal-header card-header">
                <h3 class="modal-title card-title" id="modal{$name}Title">{$title}</h3>
                <button type="button" class="modal-close" data-dismiss="modal" aria-label="{lang key='close'}">&times;</button>
            </div>
            <div class="modal-body card-body text-center w-hidden" id="modal{$name}Loader">
                <p><i class="fas fa-spinner fa-spin"></i> {lang key='loading'}</p>
            </div>
            <div class="modal-body card-body" id="modal{$name}Body">
                {if isset($content)}<p>{$content}</p>{/if}
            </div>
            <div class="modal-footer card-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">
                    {if isset($closeLabel)}{$closeLabel}{else}{lang key='closewindow'}{/if}
                </button>
                {if isset($submitAction)}
                    <button type="button" class="btn btn-primary" onclick="{$submitAction}">
                        {if isset($submitLabel)}{$submitLabel}{else}{lang key='clientareasavechanges'}{/if}
                    </button>
                {/if}
            </div>
        </div>
    </div>
</div>
