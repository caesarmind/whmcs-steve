{* Signin Integrations (Google, Facebook, X ... configured in WHMCS under
   System Settings > Sign-In Integrations) - the WHMCS shared include.

   $linkableProviders[].code is each provider's button + script, written by
   WHMCS against jQuery and WHMCS.authn.provider (assets/js/whmcs/authn.js),
   which reads the hidden #providerLinkingMessages strings and writes its
   progress / errors into .providerLinkingFeedback. Hadrian's pages load
   neither, so whmcs-core-js.tpl brings them in, only when a provider is on.
   Same contract as stock Nexus; restyled with the auth pages' classes.

   Parameters:
     linkContext     login | registration | clientsecurity (as stock)
     customFeedback  true when the page prints its own .providerLinkingFeedback *}
{if isset($linkableProviders) && $linkableProviders}
{include file="$template/includes/partials/whmcs-core-js.tpl" withAuthn=true}
<style>{literal}
.hn-linked .auth-divider{display:flex;align-items:center;gap:12px;margin:18px 0;font-size:var(--text-sm);color:var(--color-text-tertiary);text-transform:uppercase;letter-spacing:.04em}
.hn-linked .auth-divider::before,.hn-linked .auth-divider::after{content:"";flex:1;height:.5px;background:var(--color-border)}
.hn-linked .social-signin-btns{display:flex;flex-direction:column;align-items:center;gap:10px}
.hn-linked .social-signin-btns>*{max-width:100%}
.providerLinkingFeedback{display:none;padding:12px 16px;border-radius:var(--radius-md);font-size:var(--text-sm);margin:12px 0}
.providerLinkingFeedback.alert-info{background:var(--color-blue-bg);color:var(--color-blue-text)}
.providerLinkingFeedback.alert-success{background:var(--color-green-bg);color:var(--color-green-text)}
.providerLinkingFeedback.alert-warning{background:var(--color-orange-bg);color:var(--color-orange-text)}
.providerLinkingFeedback.alert-danger{background:var(--color-red-bg);color:var(--color-red-text)}
{/literal}</style>

<div id="providerLinkingMessages" class="w-hidden" hidden>
    <p class="providerLinkingMsg-preLink-init_failed"><span class="provider-name"></span> {$LANG.remoteAuthn.unavailable}</p>
    <p class="providerLinkingMsg-preLink-connect_error"><strong>{$LANG.remoteAuthn.error}</strong> {$LANG.remoteAuthn.connectError}</p>
    <p class="providerLinkingMsg-preLink-complete_sign_in">{$LANG.remoteAuthn.completeSignIn}</p>
    <p class="providerLinkingMsg-preLink-2fa_needed">{$LANG.remoteAuthn.redirecting}</p>
    <p class="providerLinkingMsg-preLink-linking_complete"><strong>{$LANG.remoteAuthn.success}</strong> {$LANG.remoteAuthn.accountNowLinked}</p>
    <p class="providerLinkingMsg-preLink-login_to_link-signin-required"><strong>{$LANG.remoteAuthn.linkInitiated}</strong> {$LANG.remoteAuthn.oneTimeAuthRequired}</p>
    <p class="providerLinkingMsg-preLink-login_to_link-registration-required"><strong>{$LANG.remoteAuthn.linkInitiated}</strong> {$LANG.remoteAuthn.completeRegistrationForm}</p>
    <p class="providerLinkingMsg-preLink-checkout-new"><strong>{$LANG.remoteAuthn.linkInitiated}</strong> {$LANG.remoteAuthn.completeNewAccountForm}</p>
    <p class="providerLinkingMsg-preLink-other_user_exists"><strong>{$LANG.remoteAuthn.error}</strong> {$LANG.remoteAuthn.linkedToAnotherClient}</p>
    <p class="providerLinkingMsg-preLink-already_linked"><strong>{$LANG.remoteAuthn.error}</strong> {$LANG.remoteAuthn.alreadyLinkedToYou}</p>
    <p class="providerLinkingMsg-preLink-default"><strong>{$LANG.remoteAuthn.error}</strong> {$LANG.remoteAuthn.connectError}</p>
</div>

<div class="hn-linked">
    {if $linkContext == 'login'}
        <div class="auth-divider">{$LANG.or}</div>
    {elseif $linkContext == 'registration'}
        <div class="auth-divider">{$LANG.remoteAuthn.titleSignUpVerb}</div>
    {elseif $linkContext == 'clientsecurity'}
        <p>{$LANG.remoteAuthn.mayHaveMultipleLinks}</p>
    {/if}

    <div class="providerPreLinking" data-link-context="{$linkContext}"
         data-hide-on-prelink={if in_array($linkContext, ['clientsecurity','login'])}0{else}1{/if}
         data-disable-on-prelink=0>
        <div class="social-signin-btns">
            {foreach $linkableProviders as $provider}
                {$provider.code}
            {/foreach}
        </div>
    </div>

    {if !isset($customFeedback) || !$customFeedback}
        <div class="providerLinkingFeedback"></div>
    {/if}
</div>
{/if}
