{* =========================================================================
   configuressl-stepone.tpl — choose domain to issue certificate for.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='ssl.configuressl.title'}</h1>
    <p class="page-subtitle">{lang key='ssl.configuressl.stepone'}</p>
</div>

{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<div class="card">
    <div class="card-body">
        <form method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="step" value="2">
            <input type="hidden" name="id" value="{$id}">

            <div class="form-group">
                <label for="domainSelection" class="form-label">{lang key='ssl.domain'}</label>
                <select name="domain" id="domainSelection" class="form-input" required>
                    {foreach $domains as $domain}
                        <option value="{$domain}">{$domain}</option>
                    {/foreach}
                </select>
            </div>

            <button type="submit" class="btn btn-primary btn-lg">{lang key='continue'} <i class="fas fa-arrow-right"></i></button>
        </form>
    </div>
</div>
