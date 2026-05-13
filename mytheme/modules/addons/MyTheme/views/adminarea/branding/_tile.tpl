{*
    One branding slot. Renders one of two static states:

      empty  -> dashed upload tile
      filled -> image preview with hover overlay (Replace / Remove)

    A third state -- uploading -- is composed at runtime by the JS in
    index.tpl (it injects an overlay with spinner + progress bar; no
    server-side rendering needed).

    The wrapping div carries data-* attributes the JS reads when:
      - rebuilding the tile after an AJAX upload / remove succeeds
      - resolving the per-field upload URL, accept list, and labels

    Inputs:
      $row.field, $row.label, $row.help, $row.accept, $row.maxHuman,
      $row.stored, $row.url, $row.error
      $dark -- boolean, dark surface theming for this tile
*}
<div class="mt-branding-tile"
     data-field="{$row.field|escape}"
     data-label="{$row.label|escape}"
     data-help="{$row.help|escape}"
     data-accept="{$row.accept|escape}"
     data-max-human="{$row.maxHuman|escape}"
     data-variant="{if $dark}dark{else}light{/if}">
    {if $row.stored}
        <div class="mt-branding-current{if $dark} is-dark{/if}">
            <img src="{$row.url|escape}" alt="{$row.label|escape}">
            <div class="mt-branding-overlay">
                <label class="mt-btn mt-btn-secondary mt-btn-sm" for="upload-{$row.field|escape}" style="cursor:pointer">Replace</label>
                {* CANNOT wrap this in a <form> -- the outer page already has
                   one and HTML5 forbids nested forms. Browsers respond by
                   silently closing the outer form at the inner <form> opening
                   tag, which strands every tile AFTER this one outside the
                   outer form and breaks form.querySelectorAll() lookups.
                   JS click handler on [data-remove] does the AJAX remove. *}
                <button type="button"
                        class="mt-btn mt-btn-danger mt-btn-sm"
                        data-remove="{$row.field|escape}">Remove</button>
            </div>
        </div>
        {* Hidden file input for the Replace flow -- pairs with the
           overlay's Replace label via the matching id/for. JS auto-
           submits this on change; form-submit fallback for no-JS. *}
        <input id="upload-{$row.field|escape}" type="file" name="{$row.field|escape}"
               accept="{$row.accept|escape}" hidden data-upload="{$row.field|escape}">
        <div class="mt-upload-file-meta">{$row.stored|escape}</div>
    {else}
        <label class="mt-upload{if $dark} is-dark{/if}{if $row.error} has-error{/if}" for="upload-{$row.field|escape}">
            <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none">
                <path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <div class="mt-upload-text">Click to upload</div>
            <div class="mt-upload-hint">{$row.help|escape} - max {$row.maxHuman}</div>
            <input id="upload-{$row.field|escape}" type="file" name="{$row.field|escape}"
                   accept="{$row.accept|escape}" hidden data-upload="{$row.field|escape}">
        </label>
    {/if}
    <div class="mt-upload-caption">{$row.label|escape}</div>
    {if $row.error}
        <div class="mt-upload-error">{$row.error|escape}</div>
    {/if}
</div>
