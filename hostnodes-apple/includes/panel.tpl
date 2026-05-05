{* =========================================================================
   Panel — apple-themed card wrapper. Parameters:
     headerTitle      — card header heading
     type             — accent color ('primary', 'success', 'warning', 'danger', 'info')
     bodyContent      — card body HTML
     bodyTextCenter   — center body text
     footerContent    — card footer HTML
     footerTextCenter — center footer text
   ========================================================================= *}
<div class="card card-panel{if $type} card-panel-{$type}{/if}">
    {if isset($headerTitle)}
        <div class="card-header">
            <h3 class="card-title">{$headerTitle}</h3>
        </div>
    {/if}
    {if isset($bodyContent)}
        <div class="card-body{if isset($bodyTextCenter)} text-center{/if}">
            {$bodyContent}
        </div>
    {/if}
    {if isset($footerContent)}
        <div class="card-footer{if isset($footerTextCenter)} text-center{/if}">
            {$footerContent}
        </div>
    {/if}
</div>
