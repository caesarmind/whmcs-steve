{include file="`$template`/includes/common/head.tpl"}
<div class="error-page">
    <h1>{$rslang.error.notFound.title|default:"Page not found"}</h1>
    <p>{$rslang.error.notFound.body|default:"The page you're looking for doesn't exist."}</p>
    <a href="{$WEB_ROOT}/" class="btn btn-primary">{$rslang.error.backHome|default:"Back to home"}</a>
</div>
