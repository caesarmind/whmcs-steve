{* One bento tile, selected by $sec. Included by bento.tpl, once per tile.

   PARAMETERS (passed on the {include}):
     sec      string  which tile to render - one of the seven keys below.
                      ALWAYS a literal constant at the call site, never an
                      admin-supplied value interpolated into a file path.
     secSpan  int     6|4|3|2 = 1/1|2/3|1/2|1/3. Drives data-w (the grid span)
                      and picks the roomy vs compact empty state.
     secHideEmpty bool when true, a tile with no items renders NOTHING at all --
                      no card, no grid item -- instead of an empty state.
     secPaint / secFill  the tile's colour, both whitelisted in
                      SectionLayout::parse, so an unknown value never reaches
                      the attribute.

   Everything else ($bnServices, $nServices, $bnRows, $bnSearchAt, $bnBars,
   $LANG, $hadrianLang, $WEB_ROOT, $clientsstats) arrives by Smarty's normal
   parent-scope inheritance. Assignments made in here do NOT flow back to the
   parent, so nothing above may depend on a variable set below.

   This file lives INSIDE bento/ deliberately, as a plain .tpl beside bento.tpl.
   Template::getPageVariants scandirs the children of core/pages/clientareahome/
   and treats every DIRECTORY as a variant candidate, so a sibling cells/ dir
   would show up as a bogus variant card in admin. A file is invisible to it.

   The wrapper is .min-section, and the row markup is .min-list / .min-row /
   .min-name / .status-pill, exactly as the minimal variant emits. That is not
   lazy reuse -- five shared rule families are keyed off those names and would
   silently vanish under a bento-only wrapper:
     - the six-column [data-w] spans and both responsive ladders
     - the :not(:has(> .min-section)) empty-grid guard
     - the 13 dashboard-only .min-row .status-pill.<x> colours (an Expired
       domain under any other row class renders an invisible badge)
     - the .min-hidden / .searching filter states
     - the delegated filter listener in bento.tpl
   (NOT the .min-more disclosure -- bento has no Show more. Each tile prints a
   fixed number of items and hands the rest to its View all link.)
   Bento ADDS classes to those elements (.bn-card, .bn-row); it never
   substitutes them.
*}

{assign var=secW value=$secSpan|default:6}

{* Panels, not lists. They have no rows, so they must not run the list
   scaffolding below -- and above all not the hide-when-empty guard, which reads
   $secCount and would delete an always-available tile outright. *}
{if $sec == 'domainreg' || $sec == 'profile'}{assign var=secPanel value=true}{else}{assign var=secPanel value=false}{/if}

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

{* ---------- how many items this tile lists ----------
   Bento has NO Show more. Each tile prints its first N rows and its View all
   link carries the rest, so N is a real cap rather than a fold -- which is why
   it is worth setting per tile: a 1/3 tile beside a 2/3 one can be given fewer
   so the row stays even.

   secRowsIn is the 5th field of this section's layout entry (0 when the admin
   left it blank), and it falls back to the page-level bnt_visible_rows. Clamped
   to DASHBOARD_ROWS because the hook never hands over more than 8 -- a larger
   number is not wrong, it is just unreachable. *}
{assign var=secRows value=$secRowsIn|default:0}
{if $secRows < 1}{assign var=secRows value=$bnRows}{/if}
{if $secRows < 1}{assign var=secRows value=4}{/if}
{if $secRows > 8}{assign var=secRows value=8}{/if}
{* What the tile will actually print. The filter box and the empty state both
   key off this rather than off the fetched count: a search box over rows the
   tile is not showing filters nothing a reader can see. *}
{if $secCount < $secRows}{assign var=secShown value=$secCount}{else}{assign var=secShown value=$secRows}{/if}

{* Which tiles can grow a filter box: Services and Domains only. They are the
   two an established client keeps scanning for a specific row -- "which of my
   hosting accounts is web-03" -- whereas invoices, tickets and announcements
   are read newest-first and a filter over them is noise.

   NOTE every dashboard list, these two included, is capped at DASHBOARD_ROWS
   (8) by the hook, so $secCount tops out at 8 and a threshold above 8 can never
   fire. The useful range is 1-8; 0 switches the filter off everywhere. *}
{if ($sec == 'services' || $sec == 'domains') && $bnSearchAt > 0 && $secShown >= $bnSearchAt}
    {assign var=secSearch value=true}
{else}
    {assign var=secSearch value=false}
{/if}

{* "Hide when empty": emit nothing whatsoever, so the tile leaves no card and no
   grid item behind and the row closes up. *}
{assign var=secHide value=$secHideEmpty|default:false}
{if $secPanel || $secCount > 0 || !$secHide}

{* The fill must never resolve EMPTY: the panel rules are keyed off the fill
   VALUE (.min-section[data-blk-fill="tint"] > .blk) and so are the tile rules
   now, so a blank attribute would leave --blk-base set with no rule to apply it
   and the block would render unpainted while still looking painted in admin.

   No coercion here any more. List tiles used to be forced to the wash because a
   .status-pill is a 10%-alpha background and a saturated fill put an Active
   badge at 1.05:1; pages/clientareahome.css now swaps those pills to a
   near-opaque light chip with authored dark ink on solid and gradient tiles, so
   all three fills are honoured as chosen. *}
{assign var=secFillOut value=$secFill|default:'solid'}
{if $secFillOut == ''}{assign var=secFillOut value='solid'}{/if}

{* A CUSTOM colour is emitted as inline custom properties rather than through a
   [data-blk-paint="..."] rule, because there is no rule to write: the value is
   whatever the admin picked. Inline beats every selector, so it overrides the
   accent fallback the attribute alone would give -- and if it were ever
   stripped, that fallback is a visible block rather than an invisible one.
   Only --blk-base: the ink is derived from it by the @supports block in
   pages/clientareahome.css, so a custom colour and a palette colour go
   through exactly the same contrast maths. *}
<div class="min-section bn-cell" data-sec="{$sec}" data-w="{$secW}"{if $secPaint|default:''} data-blk-paint="{$secPaint|escape}" data-blk-fill="{$secFillOut|escape}"{/if}{if $secCustom|default:''} style="--blk-base:{$secCustom|escape}"{/if}>
{if $secPanel}
    {* ---------- Panels ----------
       Shared byte-for-byte with the minimal variant's rows.tpl: the .blk
       vocabulary, its named container query (container-name: blk) and the paint
       rules are all keyed off `.min-section > .blk`, so these two tiles reflow
       to whichever of the four widths the admin dropped them into without a
       single bento-specific rule. *}
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
               which this theme does not load, and a link always works. *}
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
               out at its natural size and swamps the tile. *}
            {if isset($captcha) && $captcha && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm|default:'')}
            <div class="blk-captcha">
                {include file="`$template`/includes/captcha.tpl"}
            </div>
            {/if}
            {* Live register prices, newest currency. Renders nothing when WHMCS
               has no priced TLDs, so the tile never shows an empty rail. *}
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
                    <a class="blk-btn" href="{$WEB_ROOT}/clientarea.php?action=details">{$hadrianLang.dashboard.editProfile}</a>
                    <a class="blk-btn quiet" href="{routePath('user-security')}">{$LANG.navsecuritysettings|default:'Security'}</a>
                </span>
            </div>
        </div>
        {/if}
    </div>
{else}
    {* ---------- List tiles ---------- *}
    <div class="bn-card">
        <div class="bn-eyebrow{if $sec == 'invoices' && $clientsstats.numoverdueinvoices > 0} is-alert{/if}">{if $sec == 'services'}{$LANG.navservices|default:'Services'}{elseif $sec == 'domains'}{$LANG.navdomains|default:'Domains'}{elseif $sec == 'invoices'}{$LANG.invoicestitle|default:'Invoices'}{elseif $sec == 'tickets'}{$LANG.navtickets|default:'Support'}{else}{$LANG.announcements|default:'Announcements'}{/if}</div>

        {if $sec == 'invoices'}
            {* ---------- Billing: an aggregate, not a leaderboard ----------
               Money is one number and one action. The rows below it are the
               recent invoices, but the tile answers "what do I owe" first. *}
            {assign var=bnDue value=$clientsstats.numunpaidinvoices|default:0}
            <div class="bn-titlerow">
                <div class="bn-title">{if $bnDue > 0}{$bnDue} {if $bnDue == 1}{$hadrianLang.dashboard.unpaidInvoiceOne}{else}{$hadrianLang.dashboard.unpaidInvoiceMany}{/if}{else}{$hadrianLang.dashboard.allPaidUp}{/if}</div>
            </div>
            {if $bnDue > 0}
                {if $clientsstats.unpaidinvoicesamount}<div class="bn-big">{$clientsstats.unpaidinvoicesamount}</div>{/if}
                {* How much of the balance is late, and how late the worst one
                   is. $clientsstats has the COUNT of overdue invoices but not
                   the amount, the invoice or the age, so this comes from
                   $dashboard.billing -- and every part of it is omitted rather
                   than guessed when the query could not answer. *}
                {assign var=bnBill value=$dashboard.billing|default:[]}
                {if $bnBill.overdueAmount|default:''}
                <div class="bn-cardsub">{$bnBill.overdueAmount|escape} {$hadrianLang.dashboard.ofItIs} <strong>{$bnBill.worstDays} {if $bnBill.worstDays == 1}{$hadrianLang.dashboard.dayOverdue}{else}{$hadrianLang.dashboard.daysOverdue}{/if}</strong>{if $bnBill.worstNum} (#{$bnBill.worstNum|escape}){/if}</div>
                {elseif $clientsstats.numoverdueinvoices > 0}
                <div class="bn-cardsub">{$clientsstats.numoverdueinvoices} {if $clientsstats.numoverdueinvoices == 1}{$hadrianLang.dashboard.overdueInvoice}{else}{$hadrianLang.dashboard.overdueInvoices}{/if}</div>
                {/if}
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="bn-cta">{$hadrianLang.dashboard.payAll}</a>
            {else}
                <div class="bn-cardsub">{$hadrianLang.dashboard.nothingDue}</div>
            {/if}
        {else}
            <div class="bn-titlerow">
                <div class="bn-title">{if $sec == 'services'}{$clientsstats.productsnumactive|default:0} {$LANG.navservices|default:'Services'}{elseif $sec == 'domains'}{$clientsstats.numactivedomains|default:0} {$LANG.navdomains|default:'Domains'}{elseif $sec == 'tickets'}{$clientsstats.numactivetickets|default:0} {$LANG.navtickets|default:'Support'}{else}{$LANG.announcements|default:'Announcements'}{/if}</div>
            </div>
        {/if}

        {* SUMMARY MODE. With the list off the tile is what it already leads
           with -- what you owe, how late, one action -- and the rows go to the
           invoices page. Only the Billing tile has this: it is the one
           collection whose headline figure is an account total rather than a
           count of the rows below it, so it still says something true with
           nothing listed. *}
        {if $sec == 'invoices' && !$bnBillList}
            {assign var=secShowList value=false}
        {else}
            {assign var=secShowList value=true}
        {/if}
        {if $secShowList}
        <div class="min-list bn-rows">
        {if $secCount > 0}
            {if $secSearch}
            <div class="min-search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>
                <input type="text" placeholder="{$hadrianLang.dashboard.searchPlaceholder|escape}" aria-label="{$hadrianLang.dashboard.searchPlaceholder|escape}">
                <button type="button" class="min-search-clear" aria-label="{$LANG.clear|default:'Clear'|escape}">&times;</button>
            </div>
            {/if}

            {if $sec == 'services'}
                {foreach $bnServices as $svc}
                {if $svc@iteration <= $secRows}
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$svc.id|escape:'url'}" class="min-row bn-row">
                    {* The domain is the identifier a client recognises; the
                       product name drops to the sub-line beside the renewal.
                       With no domain on the service the name takes the top
                       line and the sub-line carries the date alone. *}
                    <span class="min-name">
                        <span class="bn-rn">{if $svc.domain}{$svc.domain|escape}{else}{$svc.name|escape}{/if}</span>
                        <span class="bn-rs">{if $svc.domain}{$svc.name|escape}{/if}{if $svc.domain && $svc.nextDueDate} &middot; {/if}{if $svc.nextDueDate}{$hadrianLang.dashboard.renews} {$svc.nextDueDate|escape}{/if}</span>
                    </span>
                    <span class="status-pill {$svc.status|default:'Active'|lower|replace:' ':'-'|escape}">{$svc.status|default:'Active'|escape}</span>
                </a>
                {/if}
                {/foreach}
            {elseif $sec == 'domains'}
                {foreach $bnDomains as $dom}
                {if $dom@iteration <= $secRows}
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&amp;id={$dom.id|escape:'url'}" class="min-row bn-row">
                    <span class="min-name">
                        <span class="bn-rn">{$dom.domain|escape}</span>
                        {* Custom key, not $LANG.domainrenewals -- that one is
                           the "Domain Renewals" PAGE title, so it would read
                           "Domain Renewals Aug 24, 2026" and the |default:
                           would never fire to save it. *}
                        {if $dom.expirydate}<span class="bn-rs">{$hadrianLang.dashboard.renews} {$dom.expirydate|escape}</span>{/if}
                    </span>
                    <span class="status-pill {$dom.statusLower|default:'active'|replace:' ':'-'|escape}">{$dom.status|default:'Active'|escape}</span>
                </a>
                {/if}
                {/foreach}
            {elseif $sec == 'invoices'}
                {foreach $bnInvoices as $inv}
                {if $inv@iteration <= $secRows}
                <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id|escape:'url'}" class="min-row bn-row">
                    {* invoicestitle ("Invoice"), NOT invoicenumber ("Invoice #") --
                       the latter carries its own hash and would render "Invoice # #12". *}
                    <span class="min-name">
                        <span class="bn-rn">{$LANG.invoicestitle|default:'Invoice'} #{$inv.id|escape}</span>
                        {if $inv.date}<span class="bn-rs">{$inv.date|escape}</span>{/if}
                    </span>
                    <span class="min-right">
                        {if $inv.total}<span class="min-amt">{$inv.total|escape}</span>{/if}
                        {if $inv.status}<span class="status-pill {$inv.statusLower|default:''|escape}">{$inv.status|escape}</span>{/if}
                    </span>
                </a>
                {/if}
                {/foreach}
            {elseif $sec == 'tickets'}
                {foreach $bnTickets as $tkt}
                {if $tkt@iteration <= $secRows}
                <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape:'url'}{if $tkt.c}&amp;c={$tkt.c|escape:'url'}{/if}" class="min-row bn-row">
                    <span class="min-name">
                        <span class="bn-rn">{$tkt.subject|escape}</span>
                        <span class="bn-rs">#{$tkt.tid|escape}{if $tkt.lastreply} &middot; {$hadrianLang.dashboard.updated} {$tkt.lastreply|escape}{/if}</span>
                    </span>
                    <span class="status-pill {$tkt.status|default:'Open'|lower|replace:' ':'-'|escape}">{$tkt.status|default:'Open'|escape}</span>
                </a>
                {/if}
                {/foreach}
            {else}
                {foreach $bnNews as $ann}
                {if $ann@iteration <= $secRows}
                <a href="{$WEB_ROOT}/announcements.php?id={$ann.id|escape:'url'}" class="min-row bn-row bn-ann">
                    {* dateMonth / dateDay are split in the hook, not here:
                       $ann.date is one pre-formatted "M j, Y" string with no
                       timestamp left in it to take apart. Both are empty when
                       the row's date could not be parsed, and the calendar
                       chip is dropped rather than rendered blank. *}
                    {if $ann.dateMonth|default:'' && $ann.dateDay|default:''}
                    <span class="bn-cal"><span class="m">{$ann.dateMonth|escape}</span><span class="d">{$ann.dateDay|escape}</span></span>
                    {/if}
                    <span class="min-name">
                        <span class="bn-rn">{$ann.title|escape}</span>
                        {if $ann.excerpt|default:''}<span class="bn-rs">{$ann.excerpt|escape}</span>{elseif $ann.date}<span class="bn-rs">{$ann.date|escape}</span>{/if}
                    </span>
                </a>
                {/if}
                {/foreach}
            {/if}

            {* Only meaningful when a search box exists to produce no matches.
               Emitting it unconditionally leaves a permanently hidden last
               child, which keeps the final visible row on its non-:last-child
               branch and draws a stray hairline. *}
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
        {/if}{* /show list *}

        {* Credit comes off the next invoice before anything is charged, so it
           belongs with the amount rather than on the invoices page. Gated on a
           RAW value from the hook, not on $clientsstats.creditbalance -- that
           one arrives pre-formatted, so testing it means comparing against the
           string "$0.00". *}
        {if $sec == 'invoices' && $dashboard.billing.hasCredit|default:false}
        <div class="bn-credit">{$dashboard.billing.credit|escape} {$hadrianLang.dashboard.creditApplied}</div>
        {/if}

        {* One footer slot, bottom-anchored, so every tile in a row lines its
           View all up on the same baseline however tall its neighbour grows. *}
        <div class="bn-foot">
            {if $sec == 'services'}<a href="{$WEB_ROOT}/clientarea.php?action=services" class="bn-viewall">{$LANG.viewall|default:'View All'} &rarr;</a>
            {elseif $sec == 'domains'}<a href="{$WEB_ROOT}/clientarea.php?action=domains" class="bn-viewall">{$LANG.viewall|default:'View All'} &rarr;</a>
            {elseif $sec == 'invoices'}<a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="bn-viewall">{$LANG.viewall|default:'View All'} &rarr;</a>
            {elseif $sec == 'tickets'}<a href="{$WEB_ROOT}/supporttickets.php" class="bn-viewall">{$LANG.viewall|default:'View All'} &rarr;</a>
            {else}<a href="{$WEB_ROOT}/announcements.php" class="bn-viewall">{$LANG.viewall|default:'View All'} &rarr;</a>
            {/if}
        </div>
    </div>
{/if}{* /panel vs list *}
</div>
{/if}{* /hide-when-empty guard *}
