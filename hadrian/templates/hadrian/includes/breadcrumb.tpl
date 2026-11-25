{* Breadcrumb trail - the WHMCS shared include, for code that includes
   "$template/includes/breadcrumb.tpl" by name. Hadrian's own chrome shows a
   single back link instead (header.tpl). Reads $breadcrumb[] {link, label}
   as stock Nexus does. *}
{if isset($breadcrumb) && $breadcrumb}
<nav class="hn-breadcrumb" aria-label="{$hadrianLang.nav.breadcrumb|default:'Breadcrumb'}">
    <style>{literal}
    .hn-breadcrumb ol{display:flex;flex-wrap:wrap;gap:6px;list-style:none;margin:0 0 16px;padding:0;font-size:var(--text-sm);color:var(--color-text-tertiary)}
    .hn-breadcrumb li+li::before{content:"/";margin-right:6px;color:var(--color-text-tertiary)}
    .hn-breadcrumb a{color:var(--color-text-secondary);text-decoration:none}
    .hn-breadcrumb a:hover{color:var(--color-accent)}
    {/literal}</style>
    <ol>
        {foreach $breadcrumb as $item}
        <li{if $item@last} aria-current="page"{/if}>{if !$item@last}<a href="{$item.link}">{/if}{$item.label}{if !$item@last}</a>{/if}</li>
        {/foreach}
    </ol>
</nav>
{/if}
