{include file="`$template`/includes/common/head.tpl"}
<div class="error-page error-page-500">
    <h1>{$rslang.error.serverError.title|default:"Something went wrong"}</h1>
    <p>{$rslang.error.serverError.body|default:"An unexpected error occurred. Please try again or contact support."}</p>
    <a href="{$WEB_ROOT}/" class="btn btn-primary">{$rslang.error.backHome|default:"Back to home"}</a>
</div>
