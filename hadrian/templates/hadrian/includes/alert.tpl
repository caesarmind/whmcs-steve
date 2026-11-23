{* Alert - the WHMCS shared include, in Hadrian's .callout style.

   Hadrian's own pages never include it. It exists for code that is not ours
   but renders inside our pages and includes "$template/includes/alert.tpl" by
   name: the cPanel and Plesk server modules' client-area output, the Project
   Management addon, forwardpage.tpl. Without the file, WHMCS logs a Smarty
   error and that part of the module's output silently disappears.

   Same parameters as WHMCS's twenty-one include:
     type               error|danger|warning|success|info (default info)
     msg                the message (HTML allowed, as in WHMCS)
     title              optional heading
     errorshtml         <li> list of validation errors (replaces msg)
     textcenter         center the text
     hide               render hidden (shown later by the caller's JS)
     idname             element id
     additionalClasses  extra classes *}
{if $type == 'error' || $type == 'danger'}{assign var=mtAlertKind value='error'}{elseif $type == 'warning' || $type == 'success'}{assign var=mtAlertKind value=$type}{else}{assign var=mtAlertKind value='info'}{/if}
<div class="callout {$mtAlertKind}{if $additionalClasses} {$additionalClasses}{/if}"{if $idname} id="{$idname}"{/if} role="{if $mtAlertKind == 'error'}alert{else}status{/if}"{if $textcenter} style="justify-content:center;text-align:center"{/if}{if $hide} hidden{/if}>
    <div class="callout-text">
        {if $errorshtml}
            <strong>{$LANG.clientareaerrors}</strong>
            <ul style="margin:6px 0 0;padding-left:18px">{$errorshtml}</ul>
        {else}
            {if $title}<strong style="display:block;margin-bottom:4px">{$title}</strong>{/if}
            {$msg}
        {/if}
    </div>
</div>
