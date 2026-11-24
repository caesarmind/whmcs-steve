{* Panel - the WHMCS shared include, in Hadrian's .callout style.

   For code that is not ours but includes "$template/includes/panel.tpl" by
   name (WHMCS and addon/module templates; stock Nexus uses it for invoice
   payment notices). Without the file WHMCS logs a Smarty error and that
   output disappears. Same parameters as stock Nexus:
     type              success|danger|error|warning|info|primary|default
     headerTitle       optional heading
     bodyContent       body (HTML allowed, as in WHMCS)
     bodyTextCenter    center the body
     footerContent     optional footer (HTML)
     footerTextCenter  center the footer *}
{if $type == 'danger' || $type == 'error'}{assign var=hnPanelKind value='error'}{elseif $type == 'success' || $type == 'warning'}{assign var=hnPanelKind value=$type}{else}{assign var=hnPanelKind value='info'}{/if}
<div class="callout {$hnPanelKind}" role="{if $hnPanelKind == 'error'}alert{else}status{/if}">
    <div class="callout-text" style="flex:1;min-width:0">
        {if isset($headerTitle) && $headerTitle}<strong style="display:block;margin-bottom:4px">{$headerTitle}</strong>{/if}
        {if isset($bodyContent)}<div{if isset($bodyTextCenter) && $bodyTextCenter} style="text-align:center"{/if}>{$bodyContent}</div>{/if}
        {if isset($footerContent) && $footerContent}<div style="margin-top:8px{if isset($footerTextCenter) && $footerTextCenter};text-align:center{/if}">{$footerContent}</div>{/if}
    </div>
</div>
