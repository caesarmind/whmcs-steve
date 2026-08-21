{*
    Account / profile dropdown panel.

    One body, four call sites. It used to be copy-pasted into topnav,
    sidebar and inner-topbar; the three copies were byte-identical apart
    from the wrapper id, and that duplication is exactly why the icon rail
    never got one -- its avatar was a bare <a> to clientarea.php?action=details,
    so clicking it navigated instead of opening a menu.

    Params:
      $ddId       - element id. Must match the key togglePortalProfile()
                    maps `which` to in core-layout.js, and must be listed
                    in that file's ALL[] so outside-click closes it:
                      (default) -> profileDropdown         topnav
                      'side'    -> profileDropdownSide     inner-topbar
                      'sidebar' -> profileDropdownSidebar  sidebar
                      'rail'    -> profileDropdownRail     rail
      $ddUp       - bool. Opens upward (panel anchored to a trigger that
                    sits at the BOTTOM of its column: sidebar, rail).
      $ddToggleId - optional id for the dark-mode slider. Only ONE element
                    per document may carry it (core-theme.js does a
                    getElementById to sync the .active class), so only the
                    top layout's copy passes it: side/rail render TWO of
                    these panels at once (chrome + inner-topbar), and
                    ?preview=1 renders all four.

    Everything else -- $LANG, $WEB_ROOT, routePath(), $user_fullname,
    $_email, $mtShowDarkToggle -- resolves from the including scope.
*}
<div class="profile-dropdown{if $ddUp|default:false} profile-dropdown--up{/if}" id="{$ddId}">
    <div class="profile-dropdown-header">
        <div class="profile-dropdown-name">{$user_fullname|escape|default:'Account'}</div>
        <div class="profile-dropdown-email">{$_email|escape}</div>
    </div>

    {* — Account section — *}
    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        {$LANG.accountdetails|default:'Account Details'}
    </a>
    <a href="{routePath('account-users')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
        {$LANG.usermanagement|default:'User Management'}
    </a>
    <a href="{routePath('account-paymentmethods')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
        {$LANG.paymentMethods.title}
    </a>
    <a href="{routePath('account-contacts')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        {$LANG.contacts|default:'Contacts'}
    </a>
    <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        {$LANG.emailstitle|default:'Email History'}
    </a>

    <div class="profile-dropdown-divider"></div>

    {* — Profile section — *}
    <a href="{routePath('user-profile')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 14a4 4 0 100-8 4 4 0 000 8z"/><path d="M19.5 19a8 8 0 00-15 0"/></svg>
        {$LANG.yourprofile|default:'Your Profile'}
    </a>
    <a href="{routePath('user-accounts')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 014-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 01-4 4H3"/></svg>
        {$LANG.switchaccount|default:'Switch Account'}
    </a>
    <a href="{routePath('user-password')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg>
        {$LANG.clientareanavchangepassword|default:'Change Password'}
    </a>
    <a href="{routePath('user-security')}" class="profile-dropdown-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        {$LANG.securitysettings|default:'Security settings'}
    </a>

    {* — Theme toggle — gated by admin "Enable Dark Mode". *}
    {if $mtShowDarkToggle}
    <div class="profile-dropdown-divider"></div>

    <div class="theme-toggle-row">
        <span class="theme-toggle-label">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            {$hadrianLang.common.darkMode}
        </span>
        <div class="toggle-switch"{if $ddToggleId|default:''} id="{$ddToggleId}"{/if} onclick="toggleDarkMode && toggleDarkMode()"></div>
    </div>
    {/if}

    <div class="profile-dropdown-divider"></div>

    {* — Sign out — *}
    <a href="{$WEB_ROOT}/logout.php" class="profile-dropdown-item danger">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        {$LANG.logout|default:'Sign Out'}
    </a>
</div>
