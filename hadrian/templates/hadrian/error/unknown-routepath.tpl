{* Shown by WHMCS when a link points at a route it doesn't know (stock Nexus
   ships the same template): the 404 page plus a note naming the page that
   carried the bad link ($referrer). Stock hardcodes that note in English;
   so does this, since WHMCS has no lang key for it. *}
{include file="`$template`/error/page-not-found.tpl"}
{if isset($referrer) && $referrer}
<p class="error-page-note" style="text-align:center;margin:16px auto 40px;max-width:var(--w-prose);font-size:var(--text-sm);color:var(--color-text-secondary)">
    Sorry, but the previous page (<a href="{$referrer|escape}">{$referrer|escape}</a>) provided an invalid page link.
</p>
{/if}
