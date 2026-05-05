{* =========================================================================
   Global page shell. Every page .tpl renders *inside* the wrappers opened
   here. footer.tpl must close what this opens (in the inverse order).

   Branches:
     $loggedin   — sidebar + topbar + content-area
     otherwise   — public auth-layout (homepage-nav + auth-container)
   ========================================================================= *}
<!doctype html>
<html lang="{$activeLocale.language|default:'en'}" data-theme="light">
<head>
    <meta charset="{$charset}">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>{if $kbarticle.title}{$kbarticle.title} - {/if}{$pagetitle} - {$companyname}</title>
    {include file="$template/includes/head.tpl"}
    {$headoutput}
</head>
<body class="{if $loggedin}authenticated-layout{else}auth-layout{/if}{if $templatefile} page-{$templatefile}{/if}" data-phone-cc-input="{$phoneNumberInputStyle}">
    {if $captcha}{$captcha->getMarkup()}{/if}
    {$headeroutput}

    {include file="$template/includes/network-issues-notifications.tpl"}

    {if $loggedin}
        {include file="$template/includes/verifyemail.tpl"}
        {include file="$template/includes/validateuser.tpl"}

        <aside class="sidebar">
            <div class="sidebar-header">
                <a href="{$WEB_ROOT}/clientarea.php" class="sidebar-home-link">
                    {if $assetLogoPath}
                        <img src="{$assetLogoPath}" alt="{$companyname}" class="sidebar-logo-img">
                    {else}
                        <div class="sidebar-logo"><i class="fas fa-cube"></i></div>
                        <span class="sidebar-brand">{$companyname}</span>
                    {/if}
                </a>
            </div>
            <nav class="sidebar-nav" aria-label="{lang key='primarysidebar'}">
                {if $primarySidebar->hasChildren()}
                    {include file="$template/includes/sidebar.tpl" sidebar=$primarySidebar}
                {/if}
                {if $secondarySidebar->hasChildren()}
                    {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
                {/if}
            </nav>
            <div class="sidebar-footer">
                <div class="sidebar-user">
                    {capture name="sidebarInitials"}{if $client.firstname}{$client.firstname|truncate:1:""}{/if}{if $client.lastname}{$client.lastname|truncate:1:""}{/if}{/capture}
                    <div class="sidebar-avatar">{$smarty.capture.sidebarInitials|default:"?"}</div>
                    <div class="sidebar-user-info">
                        <div class="sidebar-user-name">{if $client.companyname}{$client.companyname}{else}{$client.fullName}{/if}</div>
                        <div class="sidebar-user-email">{$client.email}</div>
                    </div>
                </div>
            </div>
        </aside>

        <main class="main-content">
            {include file="$template/includes/topbar.tpl"}
            <div class="content-area">
    {else}
        <nav class="homepage-nav">
            <div class="homepage-nav-inner">
                <a href="{$WEB_ROOT}/index.php" class="nav-logo">
                    {if $assetLogoPath}
                        <img src="{$assetLogoPath}" alt="{$companyname}">
                    {else}
                        <i class="fas fa-cube"></i>
                    {/if}
                </a>
                <a href="{$WEB_ROOT}/index.php" class="nav-brand">{$companyname}</a>
                {if $primaryNavbar}
                    {include file="$template/includes/navbar.tpl" navbar=$primaryNavbar}
                {/if}
                <div class="nav-spacer"></div>
                <a href="#" onclick="toggleDarkMode(); return false;" class="nav-icon-btn" title="{lang key='userSecurity.darkMode'}">
                    <i class="far fa-moon"></i>
                </a>
                {if !isset($hideLoginLink) || !$hideLoginLink}
                    <a href="{$WEB_ROOT}/login.php" class="nav-signin">{lang key='loginbutton'}</a>
                {/if}
            </div>
        </nav>

        <div class="auth-layout-body">
            {if $templatefile == 'homepage' && ($registerdomainenabled || $transferdomainenabled)}
                {include file="$template/includes/domain-search.tpl"}
            {/if}
    {/if}
