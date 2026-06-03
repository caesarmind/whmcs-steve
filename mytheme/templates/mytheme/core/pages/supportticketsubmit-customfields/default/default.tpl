{* Hostnodes - Submit ticket custom fields (Apple-style).
   Department-specific custom fields shown during ticket submission.
   WHMCS variables (Lagom supportticketsubmit-customfields.tpl):
     $customfields - each: id, type ('tickbox'|'text'|'textarea'|'dropdown'|'link'|...),
                     input (raw WHMCS-rendered field HTML), name, required, description
   Normally a fragment of the submit form; rendered here as a standalone card too.
   Demo data under ?preview=1.
*}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasFields value=false}
{if isset($customfields) && $customfields|@count > 0}{assign var=hasFields value=true}{/if}

{assign var=cfDemo value=false}
{if !$hasFields && $isPreview}
    {assign var=cfDemo value=true}
    {assign var=customfields value=[
        ['id'=>1,'type'=>'dropdown','name'=>'Affected service','required'=>'*','description'=>'Which service is this about?','input'=>'<select class="form-select"><option>Business Cloud Pro</option><option>hendersondesign.com</option></select>'],
        ['id'=>2,'type'=>'text','name'=>'Order or invoice number','required'=>'','description'=>'','input'=>'<input type="text" class="form-input" placeholder="e.g. #1042">']
    ]}
    {assign var=hasFields value=true}
{/if}

{if $hasFields}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supportticketsubmit-customfields.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.supporttab}</p>
    <h1>{$hadrianLang.support.additionalInfoTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.support.customFieldsIntro}</p>
</header>

<div class="tk-wrap">
    {if $hasFields}
    <div class="when-full">
        <div class="card">
            <div class="card-body">
                {foreach $customfields as $customfield}
                <div class="form-group">
                    {if $customfield.type == 'tickbox'}
                        <label style="display:flex;align-items:flex-start;gap:8px;cursor:pointer;">
                            {$customfield.input}
                            <span>{$customfield.name|escape}{if $customfield.required} <span class="tk-required">{$customfield.required|escape}</span>{/if}</span>
                        </label>
                    {else}
                        <label class="form-label">{$customfield.name|escape}{if $customfield.required} <span class="tk-required">{$customfield.required|escape}</span>{/if}</label>
                        {$customfield.input}
                    {/if}
                    {if $customfield.description}<span class="tk-hint">{$customfield.description|strip_tags}</span>{/if}
                </div>
                {/foreach}
            </div>
        </div>
    </div>
    {/if}

    {if !$hasFields}
    <div class="when-empty">
        <div class="card">
            <div class="tk-empty">
                <div class="tk-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                </div>
                <p class="tk-empty-title">{$hadrianLang.support.noCustomFieldsTitle}</p>
                <p class="tk-empty-sub">{$hadrianLang.support.noCustomFieldsSub}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket}</a>
            </div>
        </div>
    </div>
    {/if}
</div>
