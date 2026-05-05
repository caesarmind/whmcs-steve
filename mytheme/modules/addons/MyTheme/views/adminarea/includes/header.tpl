{* Hostnodes admin shell — opens. Footer closes it.
   STYLEGUIDE.md aligned: pill nav, no shadows on default cards, off-white bg. *}

{* Map currentAction → primary nav section so sub-views highlight their parent. *}
{$mt_action = $currentAction|default:'info'}
{$mt_nav = $mt_action}
{if $mt_action == 'index' || $mt_action == 'info' || $mt_action == 'license' || $mt_action == 'templates' || $mt_action == 'template'}
    {$mt_nav = 'info'}
{elseif $mt_action == 'editStyle'}
    {$mt_nav = 'styles'}
{elseif $mt_action == 'editPage'}
    {$mt_nav = 'pages'}
{elseif $mt_action == 'editMenu'}
    {$mt_nav = 'menu'}
{/if}

<div class="mt-wrap">
    <header class="mt-brandbar">
        <div class="mt-brandbar-left">
            <div class="mt-brandmark">H</div>
            <div>
                <div class="mt-brandname">Hostnodes</div>
                <div class="mt-brandversion">v1.0.0 · WHMCS Client Theme</div>
            </div>
        </div>
        <div class="mt-brandbar-right">
            <a class="mt-brandbar-link" href="https://docs.hostnodes.com" target="_blank" rel="noopener">
                <svg viewBox="0 0 16 16" fill="none">
                    <path d="M3 2.5h6.5L13 6v7.5a1 1 0 01-1 1H3a1 1 0 01-1-1v-10a1 1 0 011-1z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                    <path d="M9.5 2.5V6H13" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                    <path d="M5 9h6M5 11.5h4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
                </svg>
                Docs
            </a>
            <a class="mt-brandbar-link" href="https://github.com/hostnodes/issues" target="_blank" rel="noopener">
                <svg viewBox="0 0 16 16" fill="none">
                    <path d="M5 7c0-1.5 1.5-3 3-3s3 1.5 3 3v3a3 3 0 11-6 0V7z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/>
                    <path d="M2.5 8.5h3M10.5 8.5h3M3 5l1.5 1.5M13 5l-1.5 1.5M3 12l1.5-1.5M13 12l-1.5-1.5" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/>
                    <path d="M6.5 4.5L7 3.5h2l.5 1" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Report bug
            </a>
        </div>
    </header>

    <nav class="mt-topnav" aria-label="Hostnodes navigation">
        <a class="mt-topnav-item {if $mt_nav == 'info'}is-active{/if}" href="{$viewHelper->url('info')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="7.5" stroke="currentColor" stroke-width="1.4"/><path d="M10 6.5v.01M10 9.5v4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
            Info
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'settings'}is-active{/if}" href="{$viewHelper->url('settings')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="2.5" stroke="currentColor" stroke-width="1.4"/><path d="M10 2.5v2M10 15.5v2M2.5 10h2M15.5 10h2M4.7 4.7l1.4 1.4M13.9 13.9l1.4 1.4M4.7 15.3l1.4-1.4M13.9 6.1l1.4-1.4" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
            Settings
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'styles'}is-active{/if}" href="{$viewHelper->url('styles')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><circle cx="10" cy="10" r="6.5" stroke="currentColor" stroke-width="1.4"/><circle cx="10" cy="6" r="1.2" fill="currentColor"/><circle cx="6" cy="10" r="1.2" fill="currentColor"/><circle cx="14" cy="10" r="1.2" fill="currentColor"/></svg>
            Styles
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'layouts'}is-active{/if}" href="{$viewHelper->url('layouts')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><rect x="2.5" y="3" width="15" height="14" rx="2" stroke="currentColor" stroke-width="1.4"/><path d="M7 3v14M2.5 7h4.5" stroke="currentColor" stroke-width="1.4"/></svg>
            Layouts
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'pages'}is-active{/if}" href="{$viewHelper->url('pages')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><path d="M5 2.5h7l3 3v12a1 1 0 01-1 1H5a1 1 0 01-1-1v-14a1 1 0 011-1z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/><path d="M12 2.5v3h3" stroke="currentColor" stroke-width="1.4"/></svg>
            Pages
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'menu'}is-active{/if}" href="{$viewHelper->url('menu')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><path d="M3 5h14M3 10h14M3 15h14" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"/></svg>
            Menu
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'branding'}is-active{/if}" href="{$viewHelper->url('branding')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><path d="M10 2.5l3 5 5 .8-3.5 3.5.8 5L10 14l-5 2.8.8-5L2.5 8.3l5-.8 2.5-5z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
            Branding
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'extensions'}is-active{/if}" href="{$viewHelper->url('extensions')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><path d="M5 2.5h4v4H5zM11 2.5h4v4h-4zM5 8.5h4v4H5zM11 8.5h4a3 3 0 010 6h-4z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
            Extensions
        </a>
        <a class="mt-topnav-item {if $mt_nav == 'tools'}is-active{/if}" href="{$viewHelper->url('tools')}">
            <svg class="mt-topnav-icon" viewBox="0 0 20 20" fill="none"><path d="M13 2.5a3.5 3.5 0 011 6.8l-9 9-2 .5.5-2 9-9A3.5 3.5 0 0113 2.5z" stroke="currentColor" stroke-width="1.4" stroke-linejoin="round"/></svg>
            Tools
        </a>
    </nav>

    <div class="mt-card-outer">
        <div class="mt-card-inner">
