{* Hostnodes — page header (client-side theme).
   Buyer escape hatch first, then standard sidebar layout dispatch. *}

{if file_exists("templates/$template/overwrites/header.tpl")}
    {include file="`$template`/overwrites/header.tpl"}
{else}
<!DOCTYPE html>
<html lang="{$activeLocale.languageCode|default:'en'}"
      data-theme="light"
      {if in_array($language, $myTheme.manifest.rtlLanguages|default:[])}dir="rtl"{/if}>
<head>
    <meta charset="{$charset|default:'utf-8'}">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{if $pagetitle}{$pagetitle} — {/if}{$companyname|escape}</title>
    {if $tagline}<meta name="description" content="{$tagline|escape}">{/if}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/theme.css?v={$myTheme.version|default:'1.0'}">
    {$headoutput}
</head>
<body class="page-{$templatefile|default:'unknown'}{if $loggedin} is-authenticated{/if}{if $myTheme.layouts['main-menu'].vars.bodyClass} {$myTheme.layouts['main-menu'].vars.bodyClass}{/if}">

{$headeroutput}

{* Layout dispatch — by default renders the sidebar layout (set in admin) *}
{if $myTheme.layouts['main-menu'].mediumPath && file_exists("templates/`$myTheme.layouts['main-menu'].mediumPath`")}
    {include file="`$myTheme.layouts['main-menu'].mediumPath`"}
{else}
    {include file="`$template`/core/layouts/main-menu/sidebar/default.tpl"}
{/if}
{/if}
