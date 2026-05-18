{* Default footer layout — slim copyright row, no menu.
   Mirrors Lagom's "Default" footer variant: minimal site chrome, suitable
   for client-area dashboards where the navigation already lives in the
   sidebar / topnav. Pick the "Extended" layout instead when you want the
   multi-column marketing footer with menu links. *}
<footer class="hp-footer hp-footer-slim">
    <div class="hp-footer-inner">
        <div class="hp-footer-bottom">
            <span class="hp-footer-copyright">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$LANG.allrightsreserved|default:'All rights reserved.'}</span>
            <div class="hp-footer-bottom-links">
                <a href="#">{$LANG.privacypolicy|default:'Privacy Policy'}</a>
                <a href="#">{$LANG.tos|default:'Terms of Use'}</a>
            </div>
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </div>
    </div>
</footer>
