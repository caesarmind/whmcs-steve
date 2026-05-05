{* =========================================================================
   Breadcrumb trail. Consumed by topbar.tpl.
   Source: $breadcrumb (array of {label, link}).
   ========================================================================= *}
{if $breadcrumb}
    {foreach $breadcrumb as $item}
        {if !$item@first}<span class="topbar-breadcrumb-sep">/</span>{/if}
        {if $item@last}
            <span class="topbar-breadcrumb-current" aria-current="page">{$item.label}</span>
        {else}
            <a href="{$item.link}">{$item.label}</a>
        {/if}
    {/foreach}
{/if}
