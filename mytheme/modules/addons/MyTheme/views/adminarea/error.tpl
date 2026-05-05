{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Error</h1>
</header>

<div class="mt-alert mt-alert-danger">
    <strong>Something went wrong.</strong>
    {$error|escape}
</div>

<a href="{$viewHelper->url('index')}" class="mt-btn mt-btn-secondary">Back to templates</a>

{include file="includes/footer.tpl"}
