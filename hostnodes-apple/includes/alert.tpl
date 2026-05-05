{* =========================================================================
   Inline alert. Parameters:
     type  — 'error' | 'danger' | 'warning' | 'success' | 'info'
     msg   — main body (may contain HTML)
     title — optional heading
     errorshtml — optional pre-rendered <li> list (renders inside <ul>)
     textcenter / hide / idname / additionalClasses — optional modifiers
   ========================================================================= *}
<div class="callout {if $type eq "error"}danger{elseif $type}{$type}{else}info{/if}{if $textcenter} text-center{/if}{if $additionalClasses} {$additionalClasses}{/if}{if $hide} w-hidden{/if}"{if $idname} id="{$idname}"{/if}>
    {if $errorshtml}
        <strong>{lang key='clientareaerrors'}</strong>
        <ul>
            {$errorshtml}
        </ul>
    {else}
        {if $title}<h3 class="callout-title">{$title}</h3>{/if}
        {$msg}
    {/if}
</div>
