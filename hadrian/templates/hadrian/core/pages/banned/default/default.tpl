{* Hostnodes - Account banned (Apple-style): ban notification.
   Optional WHMCS variables: $banreason, $banexpires.
*}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/banned.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

{* No .page-header: this renders full-bleed and the card's own h2 carries the
   message. See assets/css/pages/banned.css. *}
<div class="card err-card">
    <div class="err-ico">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
    </div>
    <h2 class="err-title">{$hadrianLang.error.bannedHeading}</h2>
    <p class="err-sub">
        {if isset($banreason) && $banreason}{$LANG.bannedbanreason}: {$banreason|strip_tags}{else}{$hadrianLang.error.bannedSub}{/if}
        {if isset($banexpires) && $banexpires}<br>{$LANG.bannedbanexpires}: {$banexpires|escape}{/if}
    </p>
    {* contact.php sits behind the same ban, so for the people who actually see
       this page the on-site contact form is unreachable. Set `bannedContactEmail`
       in core/lang/english.php to an off-domain address and this becomes a
       mailto: that works from a blocked IP. Until it's set, the old on-site link
       is kept rather than leaving the card with no action at all. *}
    <div class="err-actions">
        {if $hadrianLang.error.bannedContactEmail}
        <a href="mailto:{$hadrianLang.error.bannedContactEmail|escape}" class="btn-primary">{$LANG.contactus}</a>
        {else}
        <a href="{$WEB_ROOT}/contact.php" class="btn-primary">{$LANG.contactus}</a>
        {/if}
    </div>
</div>
