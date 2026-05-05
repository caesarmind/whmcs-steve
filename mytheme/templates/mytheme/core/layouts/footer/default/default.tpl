{* Footer layout — visible site-footer content (sits between .content close and body close).
   For the sidebar layout, the dashboard scrolls cleanly without a visible footer; we render
   nothing here. Switch to a visible footer for the top-nav layout if/when needed. *}

{if !$myTheme.layouts['main-menu'].vars.sidebarPresent}
    <footer class="app-footer">
        <div class="container">
            <p>&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}.
                {$rslang.footer.allRightsReserved|default:'All rights reserved.'}</p>
        </div>
    </footer>
{/if}
