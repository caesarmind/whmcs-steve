{*
 * hadrian_cart/linkedaccounts.tpl
 *
 * Surface for OAuth/SSO "sign in with…" providers (Google, Facebook,
 * Apple, etc.) and -- when included on the client-security page -- the
 * managed-links table of accounts already linked to the WHMCS user.
 *
 * Five $linkContext modes (set by the caller via {include ... linkContext=…}):
 *   linktable         show a data-driven jQuery DataTable of linked
 *                     accounts (used on clientarea Security page).
 *   registration      sign-up form's social-sign-up rail.
 *   checkout-existing checkout page "or" sign-in rail.
 *   checkout-new      checkout page sign-up rail.
 *   clientsecurity    in-app "link more accounts" rail.
 *
 * Contract preserved verbatim:
 *   - #providerLinkingMessages hidden lookup div with all of the
 *     .providerLinkingMsg-preLink-* keys. scripts.min.js pulls strings
 *     from here to render status toasts during the OAuth dance.
 *   - .providerPreLinking wrapper with data-link-context,
 *     data-hide-on-prelink, data-disable-on-prelink. Driven by the
 *     providerLinking JS state machine.
 *   - .social-signin-btns wrapper + per-provider $provider.code or
 *     $provider.login_button injection (the WHMCS gateway module's
 *     pre-rendered button HTML -- can't be re-templated).
 *   - .providerLinkingFeedback target div (unless caller opts out
 *     via customFeedback=true).
 *   - #tableLinkedAccounts data-driven attributes + data-ajax-url +
 *     data-on-draw-rebind-confirmation-modal + data-lang-empty-table.
 *
 * Apple visual layer:
 *   - "or" divider replaces .sub-heading-borderless / .sub-heading
 *     spans -- same semantics, Apple typography.
 *   - .social-signin-btns is just a flex row; the actual buttons
 *     come from each provider's module and inherit Apple .btn-default
 *     styling via style.min.css.
 *   - linktable variant uses .data-driven (jQuery DataTables) so we
 *     leave the <table> shell intact; CSS in style.min.css restyles
 *     it as an Apple-flat table.
 *}

{if ($linkableProviders || $hasLinkedProvidersEnabled) && $linkContext == 'linktable'}

    <table id="tableLinkedAccounts"
           class="table display data-driven linked-accounts-table"
           data-ajax-url="{$linkedAccountsUrl}"
           data-on-draw-rebind-confirmation-modal="true"
           data-lang-empty-table="{lang key='remoteAuthn.noLinkedAccounts'}">
        <thead>
            <tr>
                <th>{lang key='remoteAuthn.provider'}</th>
                <th>{lang key='remoteAuthn.name'}</th>
                <th>{lang key='remoteAuthn.emailAddress'}</th>
                <th class="text-right">{lang key='remoteAuthn.actions'}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td colspan="4" class="text-center linked-accounts-empty">
                    {lang key='remoteAuthn.noLinkedAccounts'}
                </td>
            </tr>
        </tbody>
    </table>

{elseif $linkableProviders}

    {* ── Hidden message lookup that scripts.min.js reads via jQuery.text() ── *}
    <div id="providerLinkingMessages" class="w-hidden hidden">
        <p class="providerLinkingMsg-preLink-init_failed">
            <span class="provider-name"></span> {lang key='remoteAuthn.unavailable'}
        </p>
        <p class="providerLinkingMsg-preLink-connect_error">
            <strong>{lang key='remoteAuthn.error'}</strong> {lang key='remoteAuthn.connectError'}
        </p>
        <p class="providerLinkingMsg-preLink-complete_sign_in">
            {lang key='remoteAuthn.completeSignIn'}
        </p>
        <p class="providerLinkingMsg-preLink-2fa_needed">
            {lang key='remoteAuthn.redirecting'}
        </p>
        <p class="providerLinkingMsg-preLink-linking_complete">
            <strong>{lang key='remoteAuthn.success'}</strong> {lang key='remoteAuthn.accountNowLinked'}
        </p>
        <p class="providerLinkingMsg-preLink-login_to_link-signin-required">
            <strong>{lang key='remoteAuthn.linkInitiated'}</strong> {lang key='remoteAuthn.oneTimeAuthRequired'}
        </p>
        <p class="providerLinkingMsg-preLink-login_to_link-registration-required">
            <strong>{lang key='remoteAuthn.linkInitiated'}</strong> {lang key='remoteAuthn.completeRegistrationForm'}
        </p>
        <p class="providerLinkingMsg-preLink-checkout-new">
            <strong>{lang key='remoteAuthn.linkInitiated'}</strong> {lang key='remoteAuthn.completeNewAccountForm'}
        </p>
        <p class="providerLinkingMsg-preLink-other_user_exists">
            <strong>{lang key='remoteAuthn.error'}</strong> {lang key='remoteAuthn.linkedToAnotherClient'}
        </p>
        <p class="providerLinkingMsg-preLink-already_linked">
            <strong>{lang key='remoteAuthn.error'}</strong> {lang key='remoteAuthn.alreadyLinkedToYou'}
        </p>
        <p class="providerLinkingMsg-preLink-default">
            <strong>{lang key='remoteAuthn.error'}</strong> {lang key='remoteAuthn.connectError'}
        </p>
    </div>

    {* ── Apple "or"-divider + intro per context ── *}
    {if $linkContext == 'registration'}
        <div class="sso-divider sub-heading">
            <span class="primary-bg-color">{lang key='remoteAuthn.titleSignUpVerb'}</span>
        </div>
    {elseif $linkContext == 'checkout-existing'}
        <div class="sso-divider sub-heading-borderless">
            <span class="primary-bg-color">{lang key='remoteAuthn.titleOr'}</span>
        </div>
        <p class="sso-intro text-center text-muted small">{lang key='remoteAuthn.saveTimeByLinking'}</p>
    {elseif $linkContext == 'checkout-new'}
        <div class="sso-divider sub-heading">
            <span class="primary-bg-color">{lang key='remoteAuthn.titleSignUpVerb'}</span>
        </div>
        <p class="sso-intro text-center text-muted small">{lang key='remoteAuthn.saveTimeByLinking'}</p>
    {elseif $linkContext == 'clientsecurity'}
        <p class="sso-intro">{lang key='remoteAuthn.mayHaveMultipleLinks'}</p>
    {/if}

    {* ── Provider button rail ── *}
    <div class="providerPreLinking sso-providers"
         data-link-context="{$linkContext|escape}"
         data-hide-on-prelink="{if in_array($linkContext, ['clientsecurity','login'])}0{else}1{/if}"
         data-disable-on-prelink="0">
        <div class="social-signin-btns sso-buttons">
            {foreach $linkableProviders as $provider}
                {if in_array($linkContext, ['checkout-existing'])}
                    {$provider.login_button}
                {else}
                    {$provider.code}
                {/if}
            {/foreach}
        </div>
    </div>

    {if !isset($customFeedback) || !$customFeedback}
        <div class="providerLinkingFeedback sso-feedback"></div>
    {/if}

{/if}
