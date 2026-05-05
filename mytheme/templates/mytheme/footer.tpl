{* Hostnodes — page footer.
   Closes content-area + ph-main-wrap, renders site footer (top-layout) and slim
   footer (sidebar/rail), then loads the apple-theme.js + apple-layout.js. *}

{if empty($myTheme.license.canRender)}
    </div>
</body>
</html>
{elseif file_exists("templates/$template/overwrites/footer.tpl")}
    {include file="`$template`/overwrites/footer.tpl"}
{else}
    </div>{* /.content-area *}

    {* Site footer — top-layout only *}
    <footer class="hp-footer only-top">
        <div class="hp-footer-inner">
            <div class="hp-footer-cols">
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
            </div>
            <div class="hp-footer-bottom">
                <span>&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$LANG.allrightsreserved|default:'All rights reserved.'} <strong style="color:#ff3b30;font-weight:700;">[DEPLOY-CHECK-V6]</strong></span>
                <div class="hp-footer-bottom-links">
                    <a href="#">{$LANG.privacypolicy|default:'Privacy Policy'}</a>
                    <a href="#">{$LANG.tos|default:'Terms of Use'}</a>
                </div>
            </div>
        </div>
    </footer>

    {* Slim footer — sidebar + rail *}
    {include file="`$template`/includes/partials/sidebar-footer.tpl"}

</div>{* /.ph-main-wrap *}

{$footeroutput}

<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-theme.js?v={$myTheme.version|default:'1.0'}"></script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-layout.js?v={$myTheme.version|default:'1.0'}"></script>

</body>
</html>
{/if}
