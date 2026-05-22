{* Hostnodes - Submit ticket KB suggestions (Apple-style).
   Knowledgebase articles suggested from the ticket subject, shown before submitting.
   WHMCS variables (Lagom supportticketsubmit-kbsuggestions.tpl):
     $kbarticles - each: id, title, article (excerpt)
   Demo data under ?preview=1.
*}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasKb value=false}
{if isset($kbarticles) && $kbarticles|@count > 0}{assign var=hasKb value=true}{/if}

{assign var=kbDemo value=false}
{if !$hasKb && $isPreview}
    {assign var=kbDemo value=true}
    {assign var=kbarticles value=[
        ['id'=>1,'title'=>'How to reset your cPanel password','article'=>'Step-by-step instructions for resetting the password on your hosting control panel from the client area.'],
        ['id'=>2,'title'=>'Pointing your domain to our nameservers','article'=>'Update your domain nameservers so it resolves to your Hostnodes hosting account.'],
        ['id'=>3,'title'=>'Setting up email on your device','article'=>'IMAP and SMTP settings for configuring your mailbox in Apple Mail, Outlook and mobile.']
    ]}
    {assign var=hasKb value=true}
{/if}

{if $hasKb}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supportticketsubmit-kbsuggestions.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.supporttab|default:'Support'}</p>
    <h1>{$LANG.kbsuggestions|default:'Before you submit'}</h1>
    <p class="page-subtitle">{$LANG.kbsuggestionsexplanation|default:'These knowledgebase articles match your question and might resolve it instantly.'}</p>
</header>

<div class="tk-wrap">
    {if $hasKb}
    <div class="when-full">
        <div class="card tk-kb">
            {foreach $kbarticles as $kbarticle}
            <a class="tk-kb-item" href="{$WEB_ROOT}/knowledgebase.php?action=displayarticle&amp;id={$kbarticle.id|escape}" target="_blank" rel="noopener">
                <span class="tk-kb-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg></span>
                <span>
                    <span class="tk-kb-title">{$kbarticle.title|escape}</span>
                    {if $kbarticle.article}<span class="tk-kb-excerpt">{$kbarticle.article|strip_tags}</span>{/if}
                </span>
            </a>
            {/foreach}
        </div>
        <div class="page-actions" style="margin-top:16px;display:flex;gap:10px;">
            <a href="{$WEB_ROOT}/submitticket.php?step=2" class="btn-primary">{$LANG.kbsuggestionscontinue|default:'None of these helped, continue'}</a>
        </div>
    </div>
    {/if}

    {if !$hasKb}
    <div class="when-empty">
        <div class="card">
            <div class="tk-empty">
                <div class="tk-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                </div>
                <p class="tk-empty-title">{$LANG.kbnosuggestions|default:'No matching articles'}</p>
                <p class="tk-empty-sub">{$LANG.kbnosuggestionssub|default:"We couldn't find a related article. Go ahead and open your ticket."}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket|default:'Open a ticket'}</a>
            </div>
        </div>
    </div>
    {/if}
</div>
