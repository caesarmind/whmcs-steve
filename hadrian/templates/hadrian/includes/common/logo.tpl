{*
    Logo with overwrites escape hatch.

    Resolution order:
      1. core/pages/.../overwrites/logo.tpl (per-theme buyer override)
      2. $hadrian.branding.logo[.light|.dark] (admin Branding tab upload)
      3. WHMCS-native $logo (legacy six theme variable)
      4. text fallback: $companyname

    The light/dark variant is picked off the <html data-theme> value the
    header sets. data-theme="light" → light-surface logo. The hook resolver
    fills the missing variant from the other, so a single upload is enough
    to get a logo on both surfaces.
*}
{if file_exists("templates/`$template`/includes/common/overwrites/logo.tpl")}
    {include file="`$template`/includes/common/overwrites/logo.tpl"}
{else}
    {assign var=mt_brandingLogo value=''}
    {if isset($hadrian.branding.logo.light) && $hadrian.branding.logo.light}
        {assign var=mt_brandingLogo value=$hadrian.branding.logo.light}
    {/if}
    <a href="{$WEB_ROOT}/" class="brand-logo">
        {if $mt_brandingLogo}
            <img src="{$mt_brandingLogo|escape}" alt="{$companyname|escape}"
                 {if isset($hadrian.branding.logo.dark) && $hadrian.branding.logo.dark && $hadrian.branding.logo.dark != $mt_brandingLogo}
                    data-logo-dark="{$hadrian.branding.logo.dark|escape}"
                 {/if}>
        {elseif $logo}
            <img src="{$logo}" alt="{$companyname|escape}">
        {else}
            <span class="brand-name">{$companyname|escape}</span>
        {/if}
    </a>
{/if}
