{* Extended footer layout — multi-column site map + copyright row.

   Columns are driven by the admin Footer Menu (Addons → MyTheme → Menu →
   Footer tab). Each top-level dropdown_parent becomes one column; its
   children are the column's links. Divider/header child items are skipped
   so admins can group entries inside the column without breaking the
   <ul> markup. Stray top-level non-container items degrade to a single-
   link column for robustness.

   This layout is intentionally MENU-ONLY — no brand block, no socials,
   no payment chips. Pick "Extended Footer + Info" instead to surface
   the brand block (logo + description + socials) alongside the menu
   columns. The bottom row carries the copyright, the Footer Secondary
   menu (Privacy/Terms/etc.), and the locale chooser.

   When no footer-location menu is active (admin deactivated it, or it
   isn't seeded), .hp-footer-cols renders empty — Lagom-style "disable
   means disappear". *}
<footer class="hp-footer hp-footer-extended">
    <div class="hp-footer-inner">
        {if isset($mtFooterItems) && $mtFooterItems}
            <div class="hp-footer-cols">
                {foreach $mtFooterItems as $col}
                    {if $col.type == 'dropdown_parent' && $col.children}
                        <div class="hp-footer-col">
                            <h4>{$col.label|escape}</h4>
                            <ul>
                                {foreach $col.children as $link}
                                    {if $link.type == 'divider' || $link.type == 'header'}{continue}{/if}
                                    <li><a href="{$link.uri|escape}"{if $link.target} target="{$link.target|escape}"{/if}>{$link.label|escape}</a></li>
                                {/foreach}
                            </ul>
                        </div>
                    {elseif $col.type != 'divider' && $col.type != 'header'}
                        {* Stray top-level link — promote to a single-link column *}
                        <div class="hp-footer-col">
                            <h4><a href="{$col.uri|escape}"{if $col.target} target="{$col.target|escape}"{/if}>{$col.label|escape}</a></h4>
                        </div>
                    {/if}
                {/foreach}
            </div>
        {/if}
        <div class="hp-footer-bottom">
            <span class="hp-footer-copyright">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$LANG.allrightsreserved|default:'All rights reserved.'}</span>
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
