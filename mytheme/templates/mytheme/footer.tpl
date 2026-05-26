{* Hostnodes — page footer.
   Closes content-area + ph-main-wrap, dispatches to the admin-picked
   footer layout (core/layouts/footer/<name>/default.tpl), then loads the
   apple-theme.js + apple-layout.js. *}

{* Match the gate switch in header.tpl. When the gate is disabled (or the
   addon is active and has set canRender=true), fall through to the normal
   footer. *}
{assign var=mtLicenseGateEnabled value=false}

{* Mirror header.tpl — full-bleed pages (e.g. login "split") skip the footer
   chrome too, since header.tpl never opened .content-area / .ph-main-wrap. *}
{assign var=mt_fullPage value=false}
{if isset($myTheme.pages) && isset($myTheme.pages[$templatefile]) && !empty($myTheme.pages[$templatefile].fullPage)}{assign var=mt_fullPage value=true}{/if}

{if $mtLicenseGateEnabled && empty($myTheme.license.canRender)}
    </div>
</body>
</html>
{elseif file_exists("templates/$template/overwrites/footer.tpl")}
    {include file="`$template`/overwrites/footer.tpl"}
{else}
    {if !$mt_fullPage}
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
    {if file_exists("templates/`$template`/core/layouts/footer/`$mtFooterLayoutName`/default.tpl")}
        {include file="`$template`/core/layouts/footer/`$mtFooterLayoutName`/default.tpl"}
    {else}
        {include file="`$template`/core/layouts/footer/extended/default.tpl"}
    {/if}

</div>{* /.ph-main-wrap *}

{* Language / currency modal - lives outside .ph-main-wrap so its backdrop
   covers the full viewport. Opened by [data-locale-open] buttons in the
   footer; JS handler in apple-layout.js. *}
{include file="`$template`/includes/partials/locale-modal.tpl"}
    {/if}{* end portal chrome close (skipped when fullPage) *}

{$footeroutput}

<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-theme.js?v={$myTheme.version|default:'1.1'}"></script>
<script src="{$WEB_ROOT}/templates/{$template}/assets/js/apple-layout.js?v={$myTheme.version|default:'1.1'}"></script>

</body>
</html>
{/if}
