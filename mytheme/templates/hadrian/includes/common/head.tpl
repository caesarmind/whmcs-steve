{* Head includes — CSS, fonts, analytics. *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/theme.css?v={$hadrian.version|default:'1.0'}">
{if isset($templatefile) && in_array($templatefile, ['homepage', 'login', 'clientregister'])}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/site.css?v={$hadrian.version|default:'1.0'}">
{/if}
{if in_array($language, $hadrian.manifest.rtlLanguages|default:[])}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/theme-rtl.css?v={$hadrian.version|default:'1.0'}">
{/if}
