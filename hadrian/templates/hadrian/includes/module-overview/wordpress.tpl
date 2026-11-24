{* WordPress Toolkit card (cPanel / Plesk), ported from the modules'
   overview.tpl. js/client.js owns it: it reads data-service-id and
   data-wp-domain from the container (cPanelWordPress / pleskWordPress),
   opens the selected instance (#btnGoToWordPressHome / #btnGoToWordPressAdmin),
   live-previews the new site URL (#wpNewPath -> #newWordPressFullUrlPreview)
   and installs WordPress (#btnInstallWordpress), showing the result in
   #wordPressInstallResultRow .alert-success / .alert-danger. Ids, classes and
   the inline display:none toggles stay exactly as the module ships them.

   Parameters: panelId = cPanelWordPress | pleskWordPress. *}
{if (isset($wpInstances) && count($wpInstances)) || !empty($allowWpClientInstall)}
<div class="card" id="{$panelId}" data-service-id="{$serviceId}" data-wp-domain="{$wpDomain}">
    <div class="card-header"><h2 class="card-title">WordPress&reg;</h2></div>
    <div class="card-body">
        <div class="hn-mo-row" id="wordpressInstanceRow" {if !count($wpInstances)}style="display: none"{/if}>
            <select class="pd-field-input" id="wordPressInstances" aria-label="WordPress">
                {foreach $wpInstances as $wpInstance}
                    <option value="{$wpInstance.instanceUrl}">{$wpInstance.blogTitle}{if $wpInstance.path} ({$wpInstance.path}){/if}</option>
                {/foreach}
            </select>
            <button type="button" class="btn-secondary hn-mo-shrink" id="btnGoToWordPressHome">{lang key='wptk.goToWebsite'}</button>
            <button type="button" class="btn-secondary hn-mo-shrink" id="btnGoToWordPressAdmin">{lang key='wptk.goToAdmin'}</button>
        </div>
        <div {if empty($allowWpClientInstall)}style="display: none"{/if}>
            <p class="hn-mo-title" style="margin-top: 16px;">{lang key='wptk.createNew'}</p>
            <p class="hn-mo-muted" id="newWordPressFullUrlPreview">https://{$wpDomain}/</p>
            <div id="wordPressInstallResultRow" style="display: none">
                <div class="alert alert-success" style="display: none">{lang key='wptk.installationSuccess'}</div>
                <div class="alert alert-danger" style="display: none"></div>
            </div>
            {* The three placeholders are the module's own English text: WHMCS
               has no lang keys for them, and $hadrianLang isn't assigned yet
               when WHMCS renders a module's overview template. *}
            <div class="hn-mo-row" style="margin-top: 12px;">
                <input type="text" class="pd-field-input" id="wpNewBlogTitle" placeholder="New Blog Title" aria-label="New Blog Title" />
                <input type="text" class="pd-field-input" id="wpNewPath" placeholder="Path (optional)" aria-label="Path (optional)" />
                <input type="password" class="pd-field-input" id="wpAdminPass" placeholder="Admin Password" aria-label="Admin Password" autocomplete="new-password" />
                <button type="button" class="btn-primary hn-mo-shrink" id="btnInstallWordpress">{lang key='wptk.installWordPressShort'}</button>
            </div>
        </div>
    </div>
</div>
{/if}
