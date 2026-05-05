{* Hostnodes — page footer (client-side theme).
   Closes the main wrappers opened by the sidebar layout, adds JS. *}

{if file_exists("templates/$template/overwrites/footer.tpl")}
    {include file="`$template`/overwrites/footer.tpl"}
{else}
    </div>{* /.content *}

    {* Optional visible footer content from layout — empty by default for sidebar layout *}
    {if $myTheme.layouts.footer.mediumPath && file_exists("templates/`$myTheme.layouts.footer.mediumPath`")}
        {include file="`$myTheme.layouts.footer.mediumPath`"}
    {/if}
</div>{* /.main *}

{$footeroutput}

<script>
// Dynamic time-of-day greeting
(function() {
    var el = document.getElementById('greetingTitle');
    if (!el) return;
    var firstName = {$clientsdetails.firstname|@json_encode|default:'""'};
    var hour = new Date().getHours();
    var greeting;
    if (hour < 12) greeting = {$LANG.greetingmorning|@json_encode|default:'"Good morning"'};
    else if (hour < 17) greeting = {$LANG.greetingafternoon|@json_encode|default:'"Good afternoon"'};
    else greeting = {$LANG.greetingevening|@json_encode|default:'"Good evening"'};
    el.textContent = greeting + (firstName ? ', ' + firstName + '.' : '.');
})();

// Profile dropdown
function toggleProfileDropdown(e) {
    e.stopPropagation();
    var d = document.getElementById('profileDropdown');
    if (d) d.classList.toggle('open');
}
document.addEventListener('click', function(e) {
    var d = document.getElementById('profileDropdown');
    var w = d ? d.parentElement : null;
    if (d && w && !w.contains(e.target)) d.classList.remove('open');
});

// Dark mode
function toggleDarkMode() {
    var html = document.documentElement;
    var t = document.getElementById('darkModeToggle');
    var isDark = html.getAttribute('data-theme') === 'dark';
    html.setAttribute('data-theme', isDark ? 'light' : 'dark');
    if (t) t.classList.toggle('active', !isDark);
    try { localStorage.setItem('hostnodes-theme', isDark ? 'light' : 'dark'); } catch(e) {}
}
// Restore preference
(function() {
    var stored;
    try { stored = localStorage.getItem('hostnodes-theme'); } catch(e) {}
    var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    var theme = stored || (prefersDark ? 'dark' : 'light');
    document.documentElement.setAttribute('data-theme', theme);
    var t = document.getElementById('darkModeToggle');
    if (t && theme === 'dark') t.classList.add('active');
})();
</script>
</body>
</html>
{/if}
