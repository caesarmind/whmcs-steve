{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">{$title|default:'Error'|escape}</h1>
</header>

<div class="mt-panel pad">
    <div class="mt-alert mt-alert-danger">
        <strong>Something went wrong.</strong>
        {$error|escape}
    </div>
</div>

{if $backUrl|default:''}
    <a href="{$backUrl|escape}" class="mt-btn mt-btn-secondary">Go back</a>
{else}
    <a href="{$viewHelper->url('index')}" class="mt-btn mt-btn-secondary">Back to templates</a>
{/if}

{include file="includes/footer.tpl"}
