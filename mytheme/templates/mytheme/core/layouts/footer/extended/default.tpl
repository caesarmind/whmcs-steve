{* Extended footer layout — multi-column site map + copyright row.

   Columns are driven by the admin Footer Menu (Addons → MyTheme → Menu →
   Footer tab). Each top-level dropdown_parent becomes one column; its
   children are the column's links. Divider/header child items are skipped
   so admins can group entries inside the column without breaking the
   <ul> markup. Stray top-level non-container items degrade to a single-
   link column for robustness.

   When no footer-location menu is active (admin deactivated it, or it
   isn't seeded), .hp-footer-cols renders empty — Lagom-style "disable
   means disappear". The bottom copyright row + Privacy/Terms links
   always render. *}
<footer class="hp-footer hp-footer-extended">
    <div class="hp-footer-inner">
        {* Brand block — Apple-style company wordmark, tagline, Trustpilot
           rating chip, social links and payment-method chips. Sits above
           the admin-driven menu columns. The tagline is overridable via
           the `footertagline` language string; social URLs and payment
           chips are hardcoded for now (admin can edit via overwrites). *}
        <div class="hp-footer-legal">
            <div class="hp-footer-brand-mark">
                <svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 12.54c-.02-2.62 2.14-3.87 2.24-3.94-1.22-1.78-3.12-2.03-3.79-2.05-1.61-.16-3.15.95-3.97.95-.83 0-2.09-.93-3.45-.9-1.77.03-3.41 1.03-4.32 2.62-1.86 3.22-.47 7.97 1.32 10.58.88 1.28 1.92 2.71 3.28 2.66 1.32-.05 1.82-.85 3.42-.85 1.59 0 2.04.85 3.44.82 1.43-.02 2.32-1.29 3.18-2.58 1.01-1.48 1.42-2.92 1.44-3-.03-.01-2.77-1.06-2.79-4.21zM14.3 4.88c.72-.88 1.21-2.09 1.07-3.3-1.04.04-2.3.69-3.05 1.56-.67.77-1.25 2.01-1.09 3.19 1.16.09 2.35-.59 3.07-1.45z"/></svg>
                {$companyname|escape}
            </div>
            <p class="hp-footer-tagline">{$LANG.footertagline|default:'Premium web hosting on Google Cloud. A genuinely free plan, isolated environments, no cPanel clutter.'}</p>
            <div class="hp-footer-rating">
                <span class="hp-footer-rating-stars">&#9733;&#9733;&#9733;&#9733;&#9733;</span>
                <span>4.9 on Trustpilot</span>
            </div>
            <div class="hp-footer-socials">
                <a class="hp-footer-social" href="https://twitter.com/hostnodes" target="_blank" rel="noopener" aria-label="X (Twitter)" title="X"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg></a>
                <a class="hp-footer-social" href="https://linkedin.com/company/hostnodes" target="_blank" rel="noopener" aria-label="LinkedIn" title="LinkedIn"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.85 0-2.14 1.45-2.14 2.94v5.67H9.36V9h3.41v1.56h.05c.48-.9 1.64-1.85 3.37-1.85 3.6 0 4.27 2.37 4.27 5.46v6.28zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.56V9h3.56v11.45zM22.22 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.45c.98 0 1.78-.77 1.78-1.72V1.72C24 .77 23.2 0 22.22 0z"/></svg></a>
                <a class="hp-footer-social" href="https://facebook.com/hostnodes" target="_blank" rel="noopener" aria-label="Facebook" title="Facebook"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M24 12.07C24 5.4 18.63 0 12 0S0 5.4 0 12.07c0 6.02 4.39 11.02 10.13 11.93v-8.44H7.08v-3.49h3.05V9.41c0-3.02 1.79-4.69 4.53-4.69 1.31 0 2.68.24 2.68.24v2.97h-1.51c-1.49 0-1.95.93-1.95 1.88v2.26h3.32l-.53 3.49h-2.79V24C19.61 23.09 24 18.09 24 12.07z"/></svg></a>
                <a class="hp-footer-social" href="https://github.com/hostnodes" target="_blank" rel="noopener" aria-label="GitHub" title="GitHub"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 .3a12 12 0 0 0-3.79 23.39c.6.11.82-.26.82-.58v-2.03c-3.34.72-4.04-1.6-4.04-1.6-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.2.09 1.84 1.24 1.84 1.24 1.07 1.84 2.81 1.31 3.5 1 .1-.78.42-1.31.76-1.61-2.66-.3-5.47-1.34-5.47-5.93 0-1.31.47-2.38 1.23-3.22-.12-.3-.53-1.52.12-3.18 0 0 1-.32 3.3 1.23a11.5 11.5 0 0 1 6 0c2.3-1.55 3.3-1.23 3.3-1.23.65 1.66.24 2.88.12 3.18.77.84 1.23 1.91 1.23 3.22 0 4.6-2.81 5.62-5.49 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0 0 12 .3"/></svg></a>
            </div>
            <div class="hp-footer-payments">
                <div class="hp-footer-payment" title="Visa"><svg viewBox="0 0 38 12"><text x="19" y="10" text-anchor="middle" font-family="Helvetica,Arial,sans-serif" font-weight="900" font-style="italic" font-size="12" fill="#1a1f71">VISA</text></svg></div>
                <div class="hp-footer-payment" title="Mastercard"><svg viewBox="0 0 32 20"><circle cx="12" cy="10" r="8" fill="#eb001b"/><circle cx="20" cy="10" r="8" fill="#f79e1b" fill-opacity="0.9" style="mix-blend-mode:multiply"/></svg></div>
                <div class="hp-footer-payment" title="American Express"><svg viewBox="0 0 44 14"><rect width="44" height="14" rx="1.5" fill="#006FCF"/><text x="22" y="10" text-anchor="middle" font-family="Helvetica,Arial,sans-serif" font-weight="900" font-size="8" fill="#fff" letter-spacing="0.6">AMEX</text></svg></div>
                <div class="hp-footer-payment" title="PayPal"><svg viewBox="0 0 50 14"><text x="0" y="11" font-family="Helvetica,Arial,sans-serif" font-weight="900" font-style="italic" font-size="12" fill="#003087">Pay</text><text x="23" y="11" font-family="Helvetica,Arial,sans-serif" font-weight="900" font-style="italic" font-size="12" fill="#009cde">Pal</text></svg></div>
                <div class="hp-footer-payment" title="Apple Pay"><svg viewBox="0 0 44 14" fill="#1d1d1f"><path d="M8 3.4c.4-.5.7-1.2.6-1.9-.6 0-1.3.4-1.7.9-.4.4-.7 1.1-.6 1.8.7 0 1.3-.3 1.7-.8zM8.6 4.4c-.9 0-1.7.5-2.1.5s-1.1-.5-1.9-.5C3.6 4.4 2.7 5 2.2 5.9 1.2 7.6 2 10.1 2.9 11.5c.4.7 1 1.4 1.7 1.4.7 0 .9-.4 1.8-.4s1.1.4 1.8.4 1.2-.7 1.7-1.4c.5-.7.7-1.5.7-1.5s-1.4-.6-1.4-2.3c0-1.4 1.2-2.1 1.2-2.1-.7-1-1.7-1.1-2.1-1.2z"/><text x="14" y="11" font-family="Helvetica,Arial,sans-serif" font-weight="500" font-size="10" fill="#1d1d1f">Pay</text></svg></div>
                <div class="hp-footer-payment" title="Bitcoin"><svg viewBox="0 0 14 14"><circle cx="7" cy="7" r="6.5" fill="#f7931a"/><text x="7" y="10.5" text-anchor="middle" font-family="Helvetica,Arial,sans-serif" font-weight="700" font-size="10" fill="#fff">&#8383;</text></svg></div>
            </div>
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
        <div class="hp-footer-bottom">
            <span class="hp-footer-copyright">&copy; {$smarty.now|date_format:"%Y"} {$companyname|escape}. {$LANG.allrightsreserved|default:'All rights reserved.'}</span>
            <div class="hp-footer-bottom-links">
                <a href="#">{$LANG.privacypolicy|default:'Privacy Policy'}</a>
                <a href="#">{$LANG.tos|default:'Terms of Use'}</a>
            </div>
            {include file="`$template`/includes/partials/locale-btn.tpl"}
        </div>
    </div>
</footer>
