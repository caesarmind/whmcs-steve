{* =========================================================================
   Hero-style domain search. Used on the homepage and domain landing pages.
   ========================================================================= *}
<form method="post" action="{$WEB_ROOT}/domainchecker.php" id="frmDomainHomepage" class="ds-hero">
    <div class="ds-hero-inner">
        <h2 class="ds-hero-title">{lang key='secureYourDomainShort'}</h2>
        <input type="hidden" name="transfer" />
        <div class="ds-input-group">
            <input type="text" class="ds-input" name="domain" placeholder="{lang key='exampledomain'}" autocapitalize="none">
            {if $registerdomainenabled}
                <button type="submit" class="btn btn-primary{$captcha->getButtonClass($captchaForm)}" id="btnDomainSearch">
                    {lang key='search'}
                </button>
            {/if}
            {if $transferdomainenabled}
                <button type="submit" id="btnTransfer" data-domain-action="transfer" class="btn btn-secondary{$captcha->getButtonClass($captchaForm)}">
                    {lang key='domainstransfer'}
                </button>
            {/if}
        </div>

        {include file="$template/includes/captcha.tpl"}

        {if $featuredTlds}
            <ul class="ds-popular">
                {foreach $featuredTlds as $num => $tldinfo}
                    {if $num < 5}
                        <li class="ds-popular-item">
                            <img src="{$BASE_PATH_IMG}/tld_logos/{$tldinfo.tldNoDots}.png" alt="{$tldinfo.tld}">
                            {if is_object($tldinfo.register)}{$tldinfo.register->toFull()}{else}{lang key='domainregnotavailable'}{/if}
                        </li>
                    {/if}
                {/foreach}
            </ul>
        {/if}

        <a href="{routePath('domain-pricing')}" class="ds-all-tlds">{lang key='viewAllPricing'}</a>
    </div>
</form>
