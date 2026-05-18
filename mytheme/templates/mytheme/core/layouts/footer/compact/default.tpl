{* Compact footer layout — single horizontal row.

   Three zones (left → right):
     1. Brand: admin-uploaded logo (or Apple-leaf SVG fallback + company
        name), plus an optional one-line description from $mtBrand.
     2. Inline menu: top-level entries from the admin Footer Menu shown
        as a flat horizontal list. dropdown_parent labels render as a
        single link to their `uri` when present; nested children are
        intentionally not surfaced here (use the Extended layout for
        multi-col menus).
     3. End: copyright + the locale chooser.

   When no footer menu is configured, the middle zone collapses cleanly
   and the row stays balanced via flexbox. *}
<footer class="hp-footer hp-footer-compact">
    <div class="hp-footer-inner hp-footer-compact-inner">
        <div class="hp-footer-compact-brand">
            <div class="hp-footer-brand-mark">
                {if !empty($mtBrand.logoUrl) || !empty($mtBrand.logoDarkUrl)}
                    {if !empty($mtBrand.logoUrl)}<img src="{$mtBrand.logoUrl|escape}" alt="{$companyname|escape}" class="hp-footer-brand-logo is-light">{/if}
                    {if !empty($mtBrand.logoDarkUrl)}<img src="{$mtBrand.logoDarkUrl|escape}" alt="{$companyname|escape}" class="hp-footer-brand-logo is-dark">{/if}
                {else}
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 12.54c-.02-2.62 2.14-3.87 2.24-3.94-1.22-1.78-3.12-2.03-3.79-2.05-1.61-.16-3.15.95-3.97.95-.83 0-2.09-.93-3.45-.9-1.77.03-3.41 1.03-4.32 2.62-1.86 3.22-.47 7.97 1.32 10.58.88 1.28 1.92 2.71 3.28 2.66 1.32-.05 1.82-.85 3.42-.85 1.59 0 2.04.85 3.44.82 1.43-.02 2.32-1.29 3.18-2.58 1.01-1.48 1.42-2.92 1.44-3-.03-.01-2.77-1.06-2.79-4.21zM14.3 4.88c.72-.88 1.21-2.09 1.07-3.3-1.04.04-2.3.69-3.05 1.56-.67.77-1.25 2.01-1.09 3.19 1.16.09 2.35-.59 3.07-1.45z"/></svg>
                    <span>{$companyname|escape}</span>
                {/if}
            </div>
            {if !empty($mtBrand.description)}
                <span class="hp-footer-compact-desc">{$mtBrand.description|escape}</span>
            {/if}
        </div>
        {if isset($mtFooterItems) && $mtFooterItems}
            <nav class="hp-footer-compact-nav" aria-label="{$LANG.footer|default:'Footer'}">
                {foreach $mtFooterItems as $item}
                    {if $item.type == 'divider' || $item.type == 'header'}{continue}{/if}
                    {if !empty($item.uri)}
                        <a href="{$item.uri|escape}"{if $item.target} target="{$item.target|escape}"{/if}>{$item.label|escape}</a>
                    {else}
                        <span class="hp-footer-compact-nav-label">{$item.label|escape}</span>
                    {/if}
                {/foreach}
            </nav>
        {/if}
        <div class="hp-footer-compact-end">
            <span class="hp-footer-compact-copy">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}</span>
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </div>
    </div>
</footer>
