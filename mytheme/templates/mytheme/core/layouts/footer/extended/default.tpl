{* Extended footer layout — multi-column site map + copyright row.

   Columns are driven by the admin Footer Menu (Addons → MyTheme → Menu →
   Footer tab). Each top-level dropdown_parent becomes one column; its
   children are the column's links. Divider/header child items are skipped
   so admins can group entries inside the column without breaking the
   <ul> markup. Stray top-level non-container items degrade to a single-
   link column for robustness.

   When the menu tables exist but no footer-location menu is active (admin
   deleted every footer menu, or this is a brand-new install before the
   seeder has run) we render a minimal hardcoded fallback so the footer
   never goes blank. *}
<footer class="hp-footer hp-footer-extended">
    <div class="hp-footer-inner">
        <div class="hp-footer-cols">
        {if isset($mtFooterItems) && $mtFooterItems}
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
        {else}
            <div class="hp-footer-col">
                <h4>{$LANG.shop|default:'Shop'}</h4>
                <ul>
                    <li><a href="{$WEB_ROOT}/cart.php">{$LANG.orderproducts|default:'Browse Products'}</a></li>
                    <li><a href="{$WEB_ROOT}/cart.php?a=add&domain=register">{$LANG.registerdomain|default:'Register Domain'}</a></li>
                </ul>
            </div>
            <div class="hp-footer-col">
                <h4>{$LANG.accounttab|default:'Account'}</h4>
                <ul>
                    <li><a href="{$WEB_ROOT}/login.php">{$LANG.login|default:'Sign in'}</a></li>
                    <li><a href="{$WEB_ROOT}/register.php">{$LANG.createaccount|default:'Create account'}</a></li>
                    <li><a href="{$WEB_ROOT}/clientarea.php?action=invoices">{$LANG.invoicestab|default:'Billing'}</a></li>
                </ul>
            </div>
            <div class="hp-footer-col">
                <h4>{$LANG.supporttickets|default:'Support'}</h4>
                <ul>
                    <li><a href="{$WEB_ROOT}/knowledgebase.php">{$LANG.knowledgebasetitle|default:'Knowledgebase'}</a></li>
                    <li><a href="{$WEB_ROOT}/contact.php">{$LANG.contactus|default:'Contact us'}</a></li>
                    <li><a href="{$WEB_ROOT}/serverstatus.php">{$LANG.networkstatus|default:'Network status'}</a></li>
                </ul>
            </div>
        {/if}
        </div>
        <div class="hp-footer-bottom">
            <span>&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$LANG.allrightsreserved|default:'All rights reserved.'}</span>
            <div class="hp-footer-bottom-links">
                <a href="#">{$LANG.privacypolicy|default:'Privacy Policy'}</a>
                <a href="#">{$LANG.tos|default:'Terms of Use'}</a>
            </div>
        </div>
    </div>
</footer>
