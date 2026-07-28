{* One dashboard section, selected by $sec. Included by minimal.tpl, once per
   section, from both the classic shell and the admin-ordered grid.

   PARAMETERS (passed on the {include}):
     sec      string  which section to render - one of the five keys below.
                      ALWAYS a literal constant at the call site, never an
                      admin-supplied value interpolated into a file path.
     secSpan  int     6|4|3|2 = 1/1|2/3|1/2|1/3. Drives data-w (the grid span)
                      and picks the roomy vs compact empty state.
     secHideEmpty bool when true, a section with no items renders NOTHING at
                      all -- no card, no heading, no grid item -- instead of an
                      empty state. Per-section, set in the admin builder.

   Everything else ($minServices, $nServices, $minRows, $minSearchAt, $LANG,
   $hadrianLang, $WEB_ROOT, $clientsstats) arrives by Smarty's normal
   parent-scope inheritance. Assignments made in here do NOT flow back to the
   parent, so nothing above may depend on a variable set below.

   This file lives INSIDE minimal/ deliberately. Template::getPageVariants
   scandirs the children of core/pages/clientareahome/ and treats every
   DIRECTORY as a variant candidate, so a sibling sections/ dir would show up
   as a bogus variant card in admin. A plain .tpl file next to minimal.tpl is
   invisible to that scan.

   Two things that used to be implied by a section's hardcoded position, and
   are now explicit, because an admin can put any section at any width:
     - the roomy empty state (icon + sentence + button) only renders when the
       section HAS a call to action and is at least 2/3 wide; a 48px centred
       CTA crammed into a 1/3 column looked broken.
     - the in-list search box is limited to Services and Domains, the two lists
       a client can grow without limit, and only once they reach $minSearchAt
       rows (an admin setting; 0 switches it off).
*}

{assign var=secW value=$secSpan|default:6}

{if $sec == 'services'}
    {assign var=secCount value=$nServices}
{elseif $sec == 'domains'}
    {assign var=secCount value=$nDomains}
{elseif $sec == 'invoices'}
    {assign var=secCount value=$nInvoices}
{elseif $sec == 'tickets'}
    {assign var=secCount value=$nTickets}
{elseif $sec == 'announcements'}
    {assign var=secCount value=$nNews}
{else}
    {assign var=secCount value=0}
{/if}
{if $secW >= 4}{assign var=secRoomy value=true}{else}{assign var=secRoomy value=false}{/if}

{* Panels, not lists. They have no rows, so they must not run the list
   scaffolding below -- and above all not the hide-when-empty guard, which reads
   $secCount and would delete an always-available block outright. *}
{if $sec == 'domainreg' || $sec == 'profile'}{assign var=secPanel value=true}{else}{assign var=secPanel value=false}{/if}

{* Which sections can grow a filter box: Services and Domains only. They are the
   two an established client keeps scanning for a specific row -- "which of my
   hosting accounts is web-03" -- whereas invoices, tickets and announcements
   are read newest-first and a filter over them is noise.

   NOTE every dashboard list, these two included, is capped at DASHBOARD_ROWS
   (8) by the hook, so $secCount tops out at 8 and a threshold above 8 can never
   fire. The useful range is 1-8; 0 switches the filter off everywhere. *}
{if ($sec == 'services' || $sec == 'domains') && $minSearchAt > 0 && $secCount >= $minSearchAt}
    {assign var=secSearch value=true}
{else}
    {assign var=secSearch value=false}
{/if}

{* "Hide when empty": emit nothing whatsoever, so the section leaves no card,
   no heading and no grid item behind. Guarding the whole file rather than just
   the empty-state branch is what makes the surrounding grid close up. *}
{assign var=secHide value=$secHideEmpty|default:false}
{if $secPanel || $secCount > 0 || !$secHide}
{* data-blk-paint / data-blk-fill drive the block paint rules in
   pages/clientareahome.css. Both are whitelisted in SectionLayout::parse, so an
   unknown value never reaches the attribute. Emitted only when set, so an
   unpainted block carries no attribute and matches no rule. *}
<div class="min-section" data-sec="{$sec}" data-w="{$secW}"{if $secPaint|default:''} data-blk-paint="{$secPaint|escape}" data-blk-fill="{$secFill|default:'solid'|escape}"{/if}>
{if $secPanel}
    {* ---------- Panels ----------
       Kept inside .min-section so they take part in the grid, the width spans
       and the :has(> .min-section) visibility guard, but they carry no section
       head and no .min-list: one .blk that reflows via its container query. *}
    <div class="blk">
        {if $sec == 'domainreg'}
        <div class="blk-body">
            <div>
                <div class="blk-title">{$LANG.registerdomain|default:'Register a domain'}</div>
                <div class="blk-sub">{$hadrianLang.dashboard.domainBlockSub}</div>
            </div>
            {* Posts to the same endpoint and field name the stock themes use
               (six/header.tpl: action=domainchecker.php, name="domain"). The
               second control is a plain LINK into the cart rather than a second
               submit: WHMCS's own transfer button depends on scripts.min.js,
               which this theme does not load, and a link always works.

               $captcha is not assigned on clientareahome, so it is included
               only when present -- on an install with captcha required for the
               domain checker the inline search would abort, which is exactly
               why the cart link beside it is a real navigation. *}
            <form class="blk-form" action="{$WEB_ROOT}/domainchecker.php" method="post">
                <input class="blk-input" type="text" name="domain" autocapitalize="none" autocomplete="off"
                       placeholder="{$LANG.exampledomain|default:'yourdomain.com'|escape}"
                       aria-label="{$LANG.registerdomain|default:'Register a domain'|escape}">
                <div class="blk-btns">
                    <button type="submit" class="blk-btn">{$LANG.search|default:'Search'}</button>
                    <a class="blk-btn ghost" href="{$WEB_ROOT}/cart.php?a=add&amp;domain=transfer">{$LANG.transferdomain|default:'Transfer'}</a>
                </div>
            </form>
            {* includes/captcha.tpl styles nothing itself -- by its own contract
               it renders INSIDE a page's own .X-captcha container, which sizes
               the image and the code box. Included bare, the verify image comes
               out at its natural size and swamps the block. *}
            {if isset($captcha) && $captcha && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm|default:'')}
            <div class="blk-captcha">
                {include file="`$template`/includes/captcha.tpl"}
            </div>
            {/if}
            {* Live register prices, newest currency. Renders nothing when WHMCS
               has no priced TLDs, so the block never shows an empty rail. *}
            {if $dashboard.tldPricing|default:[] && $dashboard.tldPricing|@count > 0}
            <div class="blk-chips">
                {foreach $dashboard.tldPricing as $tld}
                <span class="blk-chip">{$tld.tld|escape} <b>{$tld.price|escape}</b></span>
                {/foreach}
            </div>
            {/if}
        </div>
        {else}
        {* Profile. $clientsdetails is global on every client-area page, so this
           needs no hook data. Initials are recomputed here rather than reusing
           $user_initials: that is assigned inside whichever chrome partial the
           active layout happens to include, so it is not reliably in scope. *}
        {assign var=blkFirst value=$clientsdetails.firstname|default:''}
        {assign var=blkLast value=$clientsdetails.lastname|default:''}
        {assign var=blkI1 value=$blkFirst|truncate:1:''|upper}
        {assign var=blkI2 value=$blkLast|truncate:1:''|upper}
        {assign var=blkInitials value=$blkI1|cat:$blkI2}
        {assign var=blkName value="`$blkFirst` `$blkLast`"|trim}
        {assign var=blkCompany value=$clientsdetails.companyname|default:''}
        {* The company is the heading when there is one, with the person beneath
           it -- that is who the account belongs to. With no company the person
           IS the account, so they take the heading and the second line is
           dropped rather than repeated. *}
        <div class="blk-body">
            <div class="blk-person">
                <span class="blk-avatar">{$blkInitials|escape}</span>
                <span class="blk-who">
                    <span class="blk-name">{if $blkCompany}{$blkCompany|escape}{else}{$blkName|escape}{/if}</span>
                    {if $blkCompany}<span class="blk-person-name">{$blkName|escape}</span>{/if}
                    {if $clientsdetails.address1}<span class="blk-addr">{$clientsdetails.address1|escape}</span>{/if}
                    {if $clientsdetails.city || $clientsdetails.state || $clientsdetails.postcode}
                    <span class="blk-addr">{$clientsdetails.city|default:''|escape}{if $clientsdetails.city && $clientsdetails.state}, {/if}{$clientsdetails.state|default:''|escape}{if ($clientsdetails.city || $clientsdetails.state) && $clientsdetails.postcode}, {/if}{$clientsdetails.postcode|default:''|escape}</span>
                    {/if}
                    {* Name, not the ISO code -- resolved in the hook. Omitted
                       entirely when it could not be resolved. *}
                    {if $dashboard.countryName|default:''}<span class="blk-addr">{$dashboard.countryName|escape}</span>{/if}
                </span>
                <span class="blk-acts">
                    <a class="blk-btn" href="{$WEB_ROOT}/clientarea.php?action=details">{$LANG.navchangedetails|default:'My Details'}</a>
                    <a class="blk-btn quiet" href="{routePath('user-security')}">{$LANG.navsecuritysettings|default:'Security'}</a>
                </span>
            </div>
        </div>
        {/if}
    </div>
{else}
    <div class="min-section-head">
        <span class="min-section-label">{if $sec == 'services'}{$LANG.navservices|default:'Services'}{elseif $sec == 'domains'}{$LANG.navdomains|default:'Domains'}{elseif $sec == 'invoices'}{$hadrianLang.dashboard.recentInvoices}{elseif $sec == 'tickets'}{$LANG.navtickets|default:'Support'}{else}{$LANG.announcements|default:'Announcements'}{/if}</span>
        {if $secCount > 0}
            {if $sec == 'services'}<a href="{$WEB_ROOT}/clientarea.php?action=services" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.productsnumactive > 0} ({$clientsstats.productsnumactive}){/if} &rarr;</a>
            {elseif $sec == 'domains'}<a href="{$WEB_ROOT}/clientarea.php?action=domains" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.numactivedomains > 0} ({$clientsstats.numactivedomains}){/if} &rarr;</a>
            {elseif $sec == 'invoices'}<a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="min-section-link">{$LANG.viewall|default:'View All'} &rarr;</a>
            {elseif $sec == 'tickets'}<a href="{$WEB_ROOT}/supporttickets.php" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.numactivetickets > 0} ({$clientsstats.numactivetickets}){/if} &rarr;</a>
            {else}<a href="{$WEB_ROOT}/announcements.php" class="min-section-link">{$LANG.viewall|default:'View All'} &rarr;</a>
            {/if}
        {/if}
    </div>
    <div class="min-list">
        {if $secCount > 0}
            {if $secSearch}
            <div class="min-search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>
                <input type="text" placeholder="{$hadrianLang.dashboard.searchPlaceholder|escape}" aria-label="{$hadrianLang.dashboard.searchPlaceholder|escape}">
                <button type="button" class="min-search-clear" aria-label="{$LANG.clear|default:'Clear'|escape}">&times;</button>
            </div>
            {/if}

            {if $sec == 'services'}
                {foreach $minServices as $svc}
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$svc.id|escape:'url'}" class="min-row{if $svc@iteration > $minRows} min-more{/if}">
                    <span class="min-name">{$svc.name|escape}{if $svc.domain} &mdash; {$svc.domain|escape}{/if}</span>
                    <span class="status-pill {$svc.status|default:'Active'|lower|replace:' ':'-'|escape}">{$svc.status|default:'Active'|escape}</span>
                </a>
                {/foreach}
            {elseif $sec == 'domains'}
                {foreach $minDomains as $dom}
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&amp;id={$dom.id|escape:'url'}" class="min-row{if $dom@iteration > $minRows} min-more{/if}">
                    <span class="min-name">{$dom.domain|escape}</span>
                    {if $dom.status == 'Active' && $dom.expirydate}
                        {* Custom key, not $LANG.domainrenewals -- that one is the
                           "Domain Renewals" PAGE title, so it would read
                           "Domain Renewals Aug 24, 2026" and the |default: would
                           never fire to save it. *}
                        <span class="min-when">{$hadrianLang.dashboard.renews} {$dom.expirydate|escape}</span>
                    {else}
                        <span class="status-pill {$dom.statusLower|default:'active'|replace:' ':'-'|escape}">{$dom.status|default:'Active'|escape}</span>
                    {/if}
                </a>
                {/foreach}
            {elseif $sec == 'invoices'}
                {foreach $minInvoices as $inv}
                <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id|escape:'url'}" class="min-row{if $inv@iteration > $minRows} min-more{/if}">
                    {* invoicestitle ("Invoice"), NOT invoicenumber ("Invoice #") --
                       the latter carries its own hash and would render "Invoice # #12".
                       Matches viewinvoice/default.tpl:43 and invoice-payment/default.tpl:14. *}
                    <span class="min-name">{$LANG.invoicestitle|default:'Invoice'} #{$inv.id|escape}</span>
                    <span class="min-right">
                        {if $inv.total}<span class="min-amt">{$inv.total|escape}</span>{/if}
                        {if $inv.status}<span class="status-pill {$inv.statusLower|default:''|escape}">{$inv.status|escape}</span>{/if}
                    </span>
                </a>
                {/foreach}
            {elseif $sec == 'tickets'}
                {foreach $minTickets as $tkt}
                <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape:'url'}{if $tkt.c}&amp;c={$tkt.c|escape:'url'}{/if}" class="min-row{if $tkt@iteration > $minRows} min-more{/if}">
                    <span class="min-name">{$tkt.subject|escape}</span>
                    <span class="status-pill {$tkt.status|default:'Open'|lower|replace:' ':'-'|escape}">{$tkt.status|default:'Open'|escape}</span>
                </a>
                {/foreach}
            {else}
                {foreach $minNews as $ann}
                <a href="{$WEB_ROOT}/announcements.php?id={$ann.id|escape:'url'}" class="min-row{if $ann@iteration > $minRows} min-more{/if}">
                    <span class="min-name">{$ann.title|escape}</span>
                    {if $ann.date}<span class="min-when">{$ann.date|escape}</span>{/if}
                </a>
                {/foreach}
            {/if}

            {if $secCount > $minRows}
            <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
            {/if}
            {* Only meaningful when a search box exists to produce no matches. Emitting it
               unconditionally left a permanently hidden last child, which kept the final
               visible row on its non-:last-child branch and drew a stray hairline. *}
            {if $secSearch}<div class="min-noresults">{$hadrianLang.dashboard.noMatches}</div>{/if}
        {else}
            {if $sec == 'services' && $secRoomy}
            <div class="min-empty">
                <p>{$hadrianLang.dashboard.noServicesSub}</p>
                <div class="acts"><a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$LANG.orderproducts|default:'Order a service'}</a></div>
            </div>
            {elseif $sec == 'domains' && $secRoomy}
            <div class="min-empty">
                <p>{$hadrianLang.dashboard.noDomainsSub}</p>
                <div class="acts"><a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="btn-primary">{$LANG.registerdomain|default:'Register a domain'}</a></div>
            </div>
            {elseif $sec == 'services'}
            <div class="min-empty compact"><p>{$hadrianLang.dashboard.noServicesSub}</p></div>
            {elseif $sec == 'domains'}
            <div class="min-empty compact"><p>{$hadrianLang.dashboard.noDomainsSub}</p></div>
            {elseif $sec == 'invoices'}
            <div class="min-empty compact"><p>{$hadrianLang.dashboard.noInvoices}</p></div>
            {elseif $sec == 'tickets'}
            <div class="min-empty compact"><p>{$hadrianLang.dashboard.noOpenTickets}</p></div>
            {else}
            <div class="min-empty compact"><p>{$hadrianLang.dashboard.noAnnouncementsShort}</p></div>
            {/if}
        {/if}
    </div>
{/if}{* /panel vs list *}
</div>
{/if}{* /hide-when-empty guard *}
