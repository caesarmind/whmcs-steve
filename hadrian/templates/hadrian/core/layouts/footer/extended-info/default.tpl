{* Extended Footer + Info layout — brand block left, menu cols right.

   Two-zone layout:
     1. Brand block (.hp-footer-legal) — admin-uploaded logo (or Apple-
        leaf fallback + company name), description tagline, and a row
        of social icons. All three pieces are driven by the Branding
        admin tab via $mtBrand.
     2. Menu cols (.hp-footer-cols) — admin Footer Menu, same renderer
        as the "Extended" layout.

   The two are wrapped in .hp-footer-top which is a CSS grid (brand:
   1fr | cols: 2fr) defined in apple-theme.css. The horizontal border
   sits on the wrapper so the brand block and cols share one divider.

   Bottom row (.hp-footer-bottom): copyright, the Footer Secondary
   menu (Privacy/Terms/Cookie etc.), and the locale chooser. *}
<footer class="hp-footer hp-footer-extended hp-footer-extended-info">
    <div class="hp-footer-inner">
        <div class="hp-footer-top">
        <div class="hp-footer-legal">
            <div class="hp-footer-brand-mark">
                {if !empty($mtBrand.logoUrl) || !empty($mtBrand.logoDarkUrl)}
                    {if !empty($mtBrand.logoUrl)}<img src="{$mtBrand.logoUrl|escape}" alt="{$companyname|escape}" class="hp-footer-brand-logo is-light">{/if}
                    {if !empty($mtBrand.logoDarkUrl)}<img src="{$mtBrand.logoDarkUrl|escape}" alt="{$companyname|escape}" class="hp-footer-brand-logo is-dark">{/if}
                {else}
                    <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 12.54c-.02-2.62 2.14-3.87 2.24-3.94-1.22-1.78-3.12-2.03-3.79-2.05-1.61-.16-3.15.95-3.97.95-.83 0-2.09-.93-3.45-.9-1.77.03-3.41 1.03-4.32 2.62-1.86 3.22-.47 7.97 1.32 10.58.88 1.28 1.92 2.71 3.28 2.66 1.32-.05 1.82-.85 3.42-.85 1.59 0 2.04.85 3.44.82 1.43-.02 2.32-1.29 3.18-2.58 1.01-1.48 1.42-2.92 1.44-3-.03-.01-2.77-1.06-2.79-4.21zM14.3 4.88c.72-.88 1.21-2.09 1.07-3.3-1.04.04-2.3.69-3.05 1.56-.67.77-1.25 2.01-1.09 3.19 1.16.09 2.35-.59 3.07-1.45z"/></svg>
                    <span>{$companyname|escape}</span>
                {/if}
            </div>
            <p class="hp-footer-tagline">{if !empty($mtBrand.description)}{$mtBrand.description|escape}{else}{$hadrianLang.footer.tagline}{/if}</p>
            {* Admin gating (Layouts -> Footer options) on top of the existing
               "only if any social URL is set in Branding" check. *}
            {if !$hadrian.addonSettings.hide_footer_socials && !empty($mtBrand.socials)}
                <div class="hp-footer-socials">
                    {if !empty($mtBrand.socials.x)}<a class="hp-footer-social" href="{$mtBrand.socials.x|escape}" target="_blank" rel="noopener" aria-label="X (Twitter)" title="X"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg></a>{/if}
                    {if !empty($mtBrand.socials.linkedin)}<a class="hp-footer-social" href="{$mtBrand.socials.linkedin|escape}" target="_blank" rel="noopener" aria-label="LinkedIn" title="LinkedIn"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.85 0-2.14 1.45-2.14 2.94v5.67H9.36V9h3.41v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.56V9h3.56v11.45zM22.22 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.45c.98 0 1.78-.77 1.78-1.72V1.72C24 .77 23.2 0 22.22 0z"/></svg></a>{/if}
                    {if !empty($mtBrand.socials.facebook)}<a class="hp-footer-social" href="{$mtBrand.socials.facebook|escape}" target="_blank" rel="noopener" aria-label="Facebook" title="Facebook"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.07C24 5.4 18.63 0 12 0S0 5.4 0 12.07c0 6.02 4.39 11.02 10.13 11.93v-8.44H7.08v-3.49h3.05V9.41c0-3.02 1.79-4.69 4.53-4.69 1.31 0 2.68.24 2.68.24v2.97h-1.51c-1.49 0-1.95.93-1.95 1.88v2.26h3.32l-.53 3.49h-2.79V24C19.61 23.09 24 18.09 24 12.07z"/></svg></a>{/if}
                    {if !empty($mtBrand.socials.github)}<a class="hp-footer-social" href="{$mtBrand.socials.github|escape}" target="_blank" rel="noopener" aria-label="GitHub" title="GitHub"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 .3a12 12 0 0 0-3.79 23.39c.6.11.82-.26.82-.58v-2.03c-3.34.72-4.04-1.6-4.04-1.6-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.2.09 1.84 1.24 1.84 1.24 1.07 1.84 2.81 1.31 3.5 1 .1-.78.42-1.31.76-1.61-2.66-.3-5.47-1.34-5.47-5.93 0-1.31.47-2.38 1.23-3.22-.12-.3-.53-1.52.12-3.18 0 0 1-.32 3.3 1.23a11.5 11.5 0 0 1 6 0c2.3-1.55 3.3-1.23 3.3-1.23.65 1.66.24 2.88.12 3.18.77.84 1.23 1.91 1.23 3.22 0 4.6-2.81 5.62-5.49 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0 0 12 .3"/></svg></a>{/if}
                    {if !empty($mtBrand.socials.youtube)}<a class="hp-footer-social" href="{$mtBrand.socials.youtube|escape}" target="_blank" rel="noopener" aria-label="YouTube" title="YouTube"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M23.5 6.2c-.3-1-1-1.8-2-2.1C19.7 3.6 12 3.6 12 3.6s-7.7 0-9.5.5c-1 .3-1.7 1.1-2 2.1C0 8 0 12 0 12s0 4 .5 5.8c.3 1 1 1.8 2 2.1 1.8.5 9.5.5 9.5.5s7.7 0 9.5-.5c1-.3 1.7-1.1 2-2.1.5-1.8.5-5.8.5-5.8s0-4-.5-5.8zM9.6 15.6V8.4l6.4 3.6-6.4 3.6z"/></svg></a>{/if}
                    {if !empty($mtBrand.socials.instagram)}<a class="hp-footer-social" href="{$mtBrand.socials.instagram|escape}" target="_blank" rel="noopener" aria-label="Instagram" title="Instagram"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.5" y2="6.5"/></svg></a>{/if}
                </div>
            {/if}
        </div>
        {if isset($mtFooterItems) && $mtFooterItems}
            <div class="hp-footer-cols">
                {foreach $mtFooterItems as $col}
                    {if $col.type == 'dropdown_parent' && $col.children}
                        <div class="hp-footer-col">
                            <h4>{$col.label|escape}</h4>
                            <ul>
                                {foreach $col.children as $link}
                                    {if $link.type == 'divider' || $link.type == 'header'}{continue}{/if}
                                    <li><a href="{$link.uri|escape}"{if $link.target} target="{$link.target|escape}"{/if}>{$link.label|escape}</a></li>
                                {/foreach}
                            </ul>
                        </div>
                    {elseif $col.type != 'divider' && $col.type != 'header'}
                        {* Stray top-level link — promote to a single-link column *}
                        <div class="hp-footer-col">
                            <h4><a href="{$col.uri|escape}"{if $col.target} target="{$col.target|escape}"{/if}>{$col.label|escape}</a></h4>
                        </div>
                    {/if}
                {/foreach}
            </div>
        {/if}
        </div>{* /.hp-footer-top *}
        <div class="hp-footer-bottom">
            <span class="hp-footer-copyright">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$hadrianLang.footer.allRightsReserved}</span>
            {if isset($mtFooterSecondaryItems) && $mtFooterSecondaryItems}
                <div class="hp-footer-bottom-links">
                    {foreach $mtFooterSecondaryItems as $item}
                        {if $item.type == 'divider' || $item.type == 'header' || $item.type == 'dropdown_parent'}{continue}{/if}
                        <a href="{$item.uri|escape}"{if $item.target} target="{$item.target|escape}"{/if}>{$item.label|escape}</a>
                    {/foreach}
                </div>
            {/if}
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </div>
    </div>
</footer>
