{* =========================================================================
   Topbar profile/avatar menu. Matches apple-client-area clientareahome.html
   and clientareadomainaddons.html exactly: a .topbar-avatar circle opens a
   .profile-dropdown that contains identity, quick links, dark-mode toggle,
   and sign-out. The dropdown header also serves as a drag handle so users
   can move the panel out of the way when it covers content.
   ========================================================================= *}
{capture name="initials"}{if $client.firstname}{$client.firstname|truncate:1:""}{/if}{if $client.lastname}{$client.lastname|truncate:1:""}{/if}{/capture}
<div class="profile-dropdown-wrapper">
    <div class="topbar-avatar" onclick="toggleProfileDropdown(event)" title="{lang key='account'}">{$smarty.capture.initials|default:"?"}</div>

    <div class="profile-dropdown" id="profileDropdown" role="menu">
        <div class="profile-dropdown-header drag-handle" data-drag-target="#profileDropdown" title="Drag to move · double-click grip to reset">
            <div class="profile-dropdown-identity">
                <div class="profile-dropdown-name">
                    {if $client.companyname}{$client.companyname}{else}{$client.fullName}{/if}
                </div>
                <div class="profile-dropdown-email">{$client.email}</div>
            </div>
            <span class="profile-dropdown-grip" aria-hidden="true"><i class="fas fa-grip-horizontal"></i></span>
        </div>

        <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
            <i class="far fa-user-circle"></i>{lang key='clientareanavdetails'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=security" class="profile-dropdown-item">
            <i class="fas fa-shield-alt"></i>{lang key='clientareanavsecurity'}
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
            <i class="far fa-envelope"></i>{lang key='clientareanavemails'}
        </a>
        <a href="{routePath('user-accounts')}" class="profile-dropdown-item">
            <i class="fad fa-random"></i>{lang key='userSwitch.switchAccount'}
        </a>

        <div class="profile-dropdown-divider"></div>

        <div class="theme-toggle-row">
            <span class="theme-toggle-label"><i class="far fa-moon"></i>{lang key='userSecurity.darkMode'}</span>
            <div class="toggle-switch" id="darkModeToggle" onclick="toggleDarkMode()"></div>
        </div>

        <div class="profile-dropdown-divider"></div>

        <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
            <i class="fas fa-sign-out-alt"></i>{lang key='logout'}
        </a>
    </div>
</div>
