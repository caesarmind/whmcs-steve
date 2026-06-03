{include file="`$template`/includes/common/head.tpl"}
<div class="error-page error-page-500">
    <h1>{$hadrianLang.error.serverError.title|default:"Something went wrong"}</h1>
    <p>{$hadrianLang.error.serverError.body|default:"An unexpected error occurred. Please try again or contact support."}</p>
    <a href="{$WEB_ROOT}/" class="btn btn-primary">{$hadrianLang.error.backHome|default:"Back to home"}</a>
</div>
