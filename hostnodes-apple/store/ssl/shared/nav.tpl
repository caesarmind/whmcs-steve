{* =========================================================================
   SSL sub-nav shown on the SSL product family landing pages.
   ========================================================================= *}
<div class="filter-tabs ssl-subnav" role="tablist">
    <a class="filter-tab{if empty($current)} active{/if}" href="{routePath('store-product-group', $routePathSlug)}">{lang key='overview'}</a>
    {if $certTypes.dv > 0 || $inPreview}
        <a class="filter-tab{if $current == 'dv'} active{/if}" href="{routePath('store-product-group', $routePathSlug, 'dv')}">{lang key='store.ssl.shared.dvSsl'}</a>
    {/if}
    {if $certTypes.wildcard > 0 || $inPreview}
        <a class="filter-tab{if $current == 'wildcard'} active{/if}" href="{routePath('store-product-group', $routePathSlug, 'wildcard')}">{lang key='store.ssl.shared.wcSsl'}</a>
    {/if}
    {if $certTypes.ov > 0 || $inPreview}
        <a class="filter-tab{if $current == 'ov'} active{/if}" href="{routePath('store-product-group', $routePathSlug, 'ov')}">{lang key='store.ssl.shared.ovSsl'}</a>
    {/if}
    {if $certTypes.ev > 0 || $inPreview}
        <a class="filter-tab{if $current == 'ev'} active{/if}" href="{routePath('store-product-group', $routePathSlug, 'ev')}">{lang key='store.ssl.shared.evSsl'}</a>
    {/if}
</div>

{if $inCompetitiveUpgrade}
    <div class="callout info competitive-upgrade-banner" id="competitiveUpgradeBanner">
        <button class="btn btn-sm btn-secondary float-right" onclick="jQuery('#competitiveUpgradeBanner').slideUp()">{lang key="dismiss"}</button>
        <h4>{lang key="store.ssl.competitiveUpgrade"}</h4>
        <p>{lang key="store.ssl.competitiveUpgradeBannerMsg" domain=$competitiveUpgradeDomain}</p>
    </div>
{/if}
