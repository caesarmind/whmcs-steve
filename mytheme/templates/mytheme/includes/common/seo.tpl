{* SEO meta tags. *}
<title>{if $pagetitle}{$pagetitle} - {/if}{$companyname}</title>
{if $tagline}<meta name="description" content="{$tagline|escape}">{/if}
<link rel="canonical" href="{$WEB_ROOT}{$smarty.server.REQUEST_URI}">
