{* Shown by WHMCS when a client hits its request rate limit (stock Nexus ships
   the same template). Copy is WHMCS's own errorPage.rateLimitExceeded keys. *}
{include file="`$template`/includes/common/head.tpl"}
<div class="error-page error-page-429">
    <h1>{lang key="errorPage.rateLimitExceeded.title"}</h1>
    <p><strong>{lang key="errorPage.rateLimitExceeded.subtitle"}</strong> {lang key="errorPage.rateLimitExceeded.description"}</p>
    <a href="{$systemurl|default:$WEB_ROOT}" class="btn btn-primary">{lang key="errorPage.rateLimitExceeded.home"}</a>
</div>
