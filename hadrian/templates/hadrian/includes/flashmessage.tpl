{* Flash message - the WHMCS shared include, in Hadrian's .callout style.

   Prints (and consumes) the message a WHMCS route left with
   get_flash_message(), for code that includes
   "$template/includes/flashmessage.tpl" by name. Hadrian's own pages read
   get_flash_message() themselves. Optional: align = left|center|right. *}
{if $message = get_flash_message()}
    {if $message.type == 'error'}{assign var=hnFlashKind value='error'}{elseif $message.type == 'success' || $message.type == 'warning'}{assign var=hnFlashKind value=$message.type}{else}{assign var=hnFlashKind value='info'}{/if}
    <div class="callout {$hnFlashKind}" role="{if $hnFlashKind == 'error'}alert{else}status{/if}"{if isset($align) && $align} style="text-align:{$align|escape}"{/if}>
        <div class="callout-text">{$message.text}</div>
    </div>
{/if}
