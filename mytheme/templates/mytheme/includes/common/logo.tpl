{* Logo with overwrites escape hatch. *}
{if file_exists("templates/`$template`/includes/common/overwrites/logo.tpl")}
    {include file="`$template`/includes/common/overwrites/logo.tpl"}
{else}
    <a href="{$WEB_ROOT}/" class="brand-logo">
        {if $logo}
            <img src="{$logo}" alt="{$companyname|escape}">
        {else}
            <span class="brand-name">{$companyname|escape}</span>
        {/if}
    </a>
{/if}
