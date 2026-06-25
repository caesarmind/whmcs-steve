{* Default footer layout — slim copyright row, no menu.
   Mirrors Lagom's "Default" footer variant: minimal site chrome, suitable
   for client-area dashboards where the navigation already lives in the
   sidebar / topnav. Pick the "Extended" layout instead when you want the
   multi-column marketing footer with menu links. *}
<footer class="hp-footer hp-footer-slim">
    <div class="hp-footer-inner">
        <div class="hp-footer-bottom">
            <span class="hp-footer-copyright">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$hadrianLang.footer.allRightsReserved}</span>
            {if isset($mtFooterSecondaryItems) && $mtFooterSecondaryItems}
                <div class="hp-footer-bottom-links">
                    {foreach $mtFooterSecondaryItems as $item}
                        {if $item.type == 'divider' || $item.type == 'header' || $item.type == 'dropdown_parent'}{continue}{/if}
                        <a href="{$item.uri|escape}"{if $item.target} target="{$item.target|escape}"{/if}>{$item.label|escape}</a>
                    {/foreach}
                </div>
            {/if}
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </div>
    </div>
</footer>
