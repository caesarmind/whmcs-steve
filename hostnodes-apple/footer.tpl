{* =========================================================================
   Global page shell closer. Closes everything header.tpl opens.

   Note on branching: we mirror header's $loggedin branches — logged-in
   users closed .content-area and .main-content; public users closed
   .auth-layout-body.
   ========================================================================= *}
    {if $loggedin}
            </div>{* /.content-area *}
        </main>{* /.main-content *}
    {else}
        </div>{* /.auth-layout-body *}

        <footer class="public-footer">
            <div class="public-footer-inner">
                <ul class="footer-social-list">
                    {include file="$template/includes/social-accounts.tpl"}
                </ul>

                <nav class="footer-nav" aria-label="{lang key='footerNav'}">
                    <a href="{$WEB_ROOT}/contact.php">{lang key='contactus'}</a>
                    {if $acceptTOS}
                        <a href="{$tosURL}" target="_blank" rel="noopener">{lang key='ordertos'}</a>
                    {/if}
                    {if ($languagechangeenabled && count($locales) > 1) || $currencies}
                        <button type="button" class="btn-ghost btn-sm" data-toggle="modal" data-target="#modalChooseLanguage">
                            <i class="fas fa-globe"></i>
                            {$activeLocale.localisedName} / {$activeCurrency.code}
                        </button>
                    {/if}
                </nav>

                <p class="footer-copyright">
                    {lang key='copyrightFooterNotice' year=$date_year company=$companyname}
                </p>
            </div>
        </footer>
    {/if}

    <div id="fullpage-overlay" class="w-hidden">
        <div class="overlay-inner">
            <i class="fas fa-circle-notch fa-spin overlay-spinner"></i>
            <br>
            <span class="msg"></span>
        </div>
    </div>

    <div class="modal fade apple-modal" id="modalAjax" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-backdrop"></div>
        <div class="modal-dialog">
            <div class="modal-content card">
                <div class="modal-header card-header">
                    <h3 class="modal-title card-title"></h3>
                    <button type="button" class="modal-close" data-dismiss="modal" aria-label="{lang key='close'}">&times;</button>
                </div>
                <div class="modal-body card-body">{lang key='loading'}</div>
                <div class="modal-footer card-footer">
                    <div class="modal-loader"><i class="fas fa-circle-notch fa-spin"></i> {lang key='loading'}</div>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{lang key='close'}</button>
                    <button type="button" class="btn btn-primary modal-submit">{lang key='submit'}</button>
                </div>
            </div>
        </div>
    </div>

    <form method="get" action="{$currentpagelinkback}">
        <div class="modal fade apple-modal modal-localisation" id="modalChooseLanguage" tabindex="-1" role="dialog">
            <div class="modal-backdrop"></div>
            <div class="modal-dialog modal-lg">
                <div class="modal-content card">
                    <div class="modal-header card-header">
                        <h3 class="modal-title card-title">{lang key='chooselanguage'} / {lang key='choosecurrency'}</h3>
                        <button type="button" class="modal-close" data-dismiss="modal" aria-label="{lang key='close'}">&times;</button>
                    </div>
                    <div class="modal-body card-body">
                        {if $languagechangeenabled && count($locales) > 1}
                            <h4 class="form-section-title">{lang key='chooselanguage'}</h4>
                            <div class="item-selector">
                                <input type="hidden" name="language" data-current="{$language}" value="{$language}">
                                {foreach $locales as $locale}
                                    <a href="#" class="item{if $language == $locale.language} active{/if}" data-value="{$locale.language}">
                                        {$locale.localisedName}
                                    </a>
                                {/foreach}
                            </div>
                        {/if}
                        {if !$loggedin && $currencies}
                            <h4 class="form-section-title">{lang key='choosecurrency'}</h4>
                            <div class="item-selector">
                                <input type="hidden" name="currency" data-current="{$activeCurrency.id}" value="">
                                {foreach $currencies as $selectCurrency}
                                    <a href="#" class="item{if $activeCurrency.id == $selectCurrency.id} active{/if}" data-value="{$selectCurrency.id}">
                                        {$selectCurrency.prefix} {$selectCurrency.code}
                                    </a>
                                {/foreach}
                            </div>
                        {/if}
                    </div>
                    <div class="modal-footer card-footer">
                        <button type="submit" class="btn btn-primary">{lang key='apply'}</button>
                    </div>
                </div>
            </div>
        </div>
    </form>

    {include file="$template/includes/generate-password.tpl"}

    {$footeroutput}
</body>
</html>
