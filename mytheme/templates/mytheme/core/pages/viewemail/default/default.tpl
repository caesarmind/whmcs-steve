{* Hostnodes - View email (Apple-style): standalone popup window.

   viewemail.php opens in a popup and does NOT load the client-area chrome, so this
   tpl emits its own HTML document (like Lagom's viewemail.tpl) and loads apple-theme.css
   for design tokens.
   WHMCS variables (Lagom viewemail.tpl): $message (email body HTML),
   $attachments (array of filenames), $companyname.
   Demo data under ?preview=1.
*}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}
{assign var=vemMsg value=$message|default:''}
{if !$vemMsg && $isPreview}{assign var=vemMsg value='<p>Hi Arshile,</p><p>This is a confirmation that your payment for invoice #1042 has been received. Thank you for your business.</p><p>Regards,<br>The Hostnodes Team</p>'}{/if}
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$LANG.clientareaemails|default:'Email'} - {$companyname|default:'Hostnodes'|escape}</title>
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-theme.css?v={$myTheme.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewemail.css?v={$myTheme.version|default:'1.0'}">
</head>
<body class="vem-popup">
    <div class="vem-card">
        <div class="vem-header">
            <p class="vem-eyebrow">{$LANG.clientareaemails|default:'Email'}</p>
            <h1 class="vem-title">{$companyname|default:'Hostnodes'|escape}</h1>
        </div>
        {if $vemMsg}
            <div class="vem-message">{$vemMsg}</div>
            {if isset($attachments) && $attachments|@count > 0}
            <div class="vem-attach">
                <p class="vem-attach-title">{$LANG.supportticketsticketattachments|default:'Attachments'}</p>
                {foreach $attachments as $attachedFile}
                <div class="vem-attach-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                    <span>{$attachedFile|escape}</span>
                </div>
                {/foreach}
            </div>
            {/if}
        {else}
            <div class="vem-empty">{$LANG.clientareaemailsnone|default:'This email is no longer available.'}</div>
        {/if}
    </div>
</body>
</html>
