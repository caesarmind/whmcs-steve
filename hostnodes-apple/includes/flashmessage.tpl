{* =========================================================================
   Flash message — shown once after a redirect (form submission, etc.).
   Source: get_flash_message() returns {type, text} or false.
   ========================================================================= *}
{if $message = get_flash_message()}
    <div class="callout {if $message.type == 'error'}danger{elseif $message.type == 'success'}success{elseif $message.type == 'warning'}warning{else}info{/if}{if isset($align)} text-{$align}{/if}">
        {$message.text}
    </div>
{/if}
