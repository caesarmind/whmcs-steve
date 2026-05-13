{* Hostnodes — page footer.
   Closes content-area + ph-main-wrap, dispatches to the admin-picked
   footer layout (core/layouts/footer/<name>/default.tpl), then loads the
   apple-theme.js + apple-layout.js. *}

{* Match the gate switch in header.tpl. When the gate is disabled (or the
   addon is active and has set canRender=true), fall through to the normal
   footer. *}
{assign var=mtLicenseGateEnabled value=false}

{if $mtLicenseGateEnabled && empty($myTheme.license.canRender)}
    </div>
</body>
</html>
{elseif file_exists("templates/$template/overwrites/footer.tpl")}
    {include file="`$template`/overwrites/footer.tpl"}
{else}
    </div>{* /.content-area *}

    {* Footer layout dispatch — admin picks one of `core/layouts/footer/*`
       in Addons → MyTheme → Layouts → Footer:

         default   → slim copyright row (no menu) — Lagom-style "Default".
         extended  → multi-column site map driven by the Footer Menu
                     ($mtFooterItems) — Lagom-style "Extended".

       Hooks.php::resolveActiveLayout reads the admin's choice from
       Settings and exposes it as $myTheme.layouts.footer.name. The
       per-page Pages-tab override (Hooks.php::clientAreaPage) has
       already been applied to $myTheme.layouts.footer by the time we
       get here, so we just include the picked layout. *}
    {assign var=mtFooterLayoutName value=$myTheme.layouts.footer.name|default:'extended'}
    <!-- mtfooter: picked={$mtFooterLayoutName|escape} setting={$myTheme.addonSettings.mytheme_active_layout_footer|default:'unset'|escape} attempts={$myTheme.addonSettings.mytheme_layout_save_attempts|default:'0'|escape} last_kind={$myTheme.addonSettings.mytheme_layout_save_last_kind|default:'-'|escape} last_value={$myTheme.addonSettings.mytheme_layout_save_last_value|default:'-'|escape} last_accepted={$myTheme.addonSettings.mytheme_layout_save_last_accepted|default:'-'|escape} -->
    {if file_exists("templates/`$template`/core/layouts/footer/`$mtFooterLayoutName`/default.tpl")}
        {include file="`$template`/core/layouts/footer/`$mtFooterLayoutName`/default.tpl"}
    {else}
        {include file="`$template`/core/layouts/footer/extended/default.tpl"}
    {/if}

</div>{* /.ph-main-wrap *}

{$footeroutput}

<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-theme.js?v={$myTheme.version|default:'1.0'}"></script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-layout.js?v={$myTheme.version|default:'1.0'}"></script>

</body>
</html>
{/if}
