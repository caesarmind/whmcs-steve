{include file="`$template`/includes/common/head.tpl"}
<div class="error-page">
    <h1>{$hadrianLang.error.notFound.title|default:"Page not found"}</h1>
    <p>{$hadrianLang.error.notFound.body|default:"The page you're looking for doesn't exist."}</p>
    <a href="{$WEB_ROOT}/" class="btn btn-primary">{$hadrianLang.error.backHome|default:"Back to home"}</a>
</div>
