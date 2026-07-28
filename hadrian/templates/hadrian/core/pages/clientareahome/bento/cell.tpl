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
     - the .min-more / .min-hidden / .searching disclosure and filter states
     - the delegated Show-more and filter listeners in bento.tpl
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

{* Which tiles can grow a filter box: Services and Domains only. They are the
   two an established client keeps scanning for a specific row -- "which of my
   hosting accounts is web-03" -- whereas invoices, tickets and announcements
   are read newest-first and a filter over them is noise.

   NOTE every dashboard list, these two included, is capped at DASHBOARD_ROWS
   (8) by the hook, so $secCount tops out at 8 and a threshold above 8 can never
   fire. The useful range is 1-8; 0 switches the filter off everywhere. *}
{if ($sec == 'services' || $sec == 'domains') && $bnSearchAt > 0 && $secCount >= $bnSearchAt}
    {assign var=secSearch value=true}
{else}
    {assign var=secSearch value=false}
{/if}

{* "Hide when empty": emit nothing whatsoever, so the tile leaves no card and no
   grid item behind and the row closes up. *}
{assign var=secHide value=$secHideEmpty|default:false}
{if $secPanel || $secCount > 0 || !$secHide}

{* ---------- status split ----------
   The proportion bar and its legend describe THE ROWS IN THIS TILE, so they may
   only be drawn when the tile provably holds the whole collection. The hook
   caps every list at 8 rows, so fewer than 8 rows means nothing was cut; at the
   cap the bar is dropped rather than reporting a slice as if it were the total.

   Buckets are the distinct status strings themselves, in first-seen order, up
   to five. The colour comes from the same normalisation the pills below use
   ({$status|lower|replace:' ':'-'}), so a segment and its rows always agree.
   A sixth distinct status suppresses the whole thing rather than filing rows
   under a label that is not theirs.

   Five, not four, because of tickets specifically: Open, Answered,
   Customer-Reply, In Progress and On Hold are all reachable at once (Closed is
   filtered out upstream), so a four-slot bucket set suppressed the ticket bar
   on any account with a busy queue -- which is the one account it is for. *}
{assign var=secBar value=false}
{if $bnBars && $secCount > 0 && $secCount < 8 && ($sec == 'services' || $sec == 'domains' || $sec == 'tickets')}
    {assign var=secBar value=true}
    {assign var=b1k value=''}{assign var=b1n value=0}
    {assign var=b2k value=''}{assign var=b2n value=0}
    {assign var=b3k value=''}{assign var=b3n value=0}
    {assign var=b4k value=''}{assign var=b4n value=0}
    {assign var=b5k value=''}{assign var=b5n value=0}
    {assign var=bOver value=false}

    {if $sec == 'services'}{assign var=barRows value=$bnServices}
    {elseif $sec == 'domains'}{assign var=barRows value=$bnDomains}
    {else}{assign var=barRows value=$bnTickets}{/if}

    {foreach $barRows as $br}
        {assign var=bst value=$br.status|default:''}
        {if $bst == ''}{assign var=bst value='Active'}{/if}
        {if $b1k == '' || $b1k == $bst}
            {assign var=b1k value=$bst}{assign var=b1n value=($b1n+1)}
        {elseif $b2k == '' || $b2k == $bst}
            {assign var=b2k value=$bst}{assign var=b2n value=($b2n+1)}
        {elseif $b3k == '' || $b3k == $bst}
            {assign var=b3k value=$bst}{assign var=b3n value=($b3n+1)}
        {elseif $b4k == '' || $b4k == $bst}
            {assign var=b4k value=$bst}{assign var=b4n value=($b4n+1)}
        {elseif $b5k == '' || $b5k == $bst}
            {assign var=b5k value=$bst}{assign var=b5n value=($b5n+1)}
        {else}
            {assign var=bOver value=true}
        {/if}
    {/foreach}
    {if $bOver}{assign var=secBar value=false}{/if}
{/if}

{* A list tile only ever takes the WASH, whatever the admin picked.
   Measured: a .status-pill is a 10%-alpha background over the tile, so on a
   solid accent fill an Active pill composites to rgb(20,123,210) behind
   rgb(36,138,61) text -- 1.05:1, an invisible badge. Every list tile carries
   pills, so the two saturated fills are coerced here rather than offered and
   then broken. The panels (Register, Profile) have no pills and keep all three
   fills, straight from the shared .blk rules. *}
{assign var=secFillOut value=$secFill|default:'solid'}
{if !$secPanel && $secFillOut != 'tint'}{assign var=secFillOut value='tint'}{/if}
<div class="min-section bn-cell" data-sec="{$sec}" data-w="{$secW}"{if $secPaint|default:''} data-blk-paint="{$secPaint|escape}" data-blk-fill="{$secFillOut|escape}"{/if}>
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
                {if $clientsstats.numoverdueinvoices > 0}
                <div class="bn-cardsub">{$clientsstats.numoverdueinvoices} {if $clientsstats.numoverdueinvoices == 1}{$hadrianLang.dashboard.overdueInvoice}{else}{$hadrianLang.dashboard.overdueInvoices}{/if}</div>
                {/if}
                <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="bn-cta">{$LANG.invoicespaynow|default:'Pay Now'}</a>
            {else}
                <div class="bn-cardsub">{$hadrianLang.dashboard.nothingDue}</div>
            {/if}
        {else}
            <div class="bn-titlerow">
                <div class="bn-title">{if $sec == 'services'}{$clientsstats.productsnumactive|default:0} {$LANG.navservices|default:'Services'}{elseif $sec == 'domains'}{$clientsstats.numactivedomains|default:0} {$LANG.navdomains|default:'Domains'}{elseif $sec == 'tickets'}{$clientsstats.numactivetickets|default:0} {$LANG.navtickets|default:'Support'}{else}{$LANG.announcements|default:'Announcements'}{/if}</div>
            </div>
        {/if}

        {if $secBar}
        {* Percentages to four places so eight equal rows still sum to 100.
           Computed into variables first: a string_format's own quoted "%.4f"
           sitting inside a quoted HTML attribute parses fine in Smarty but
           reads as unbalanced to every HTML checker that looks at the source. *}
        {assign var=p1 value=($b1n*100/$secCount)|string_format:'%.4f'}
        {assign var=p2 value=($b2n*100/$secCount)|string_format:'%.4f'}
        {assign var=p3 value=($b3n*100/$secCount)|string_format:'%.4f'}
        {assign var=p4 value=($b4n*100/$secCount)|string_format:'%.4f'}
        {assign var=p5 value=($b5n*100/$secCount)|string_format:'%.4f'}
        <div class="bn-bar">
            {if $b1n > 0}<i class="{$b1k|lower|replace:' ':'-'|escape}" style="width:{$p1}%"></i>{/if}
            {if $b2n > 0}<i class="{$b2k|lower|replace:' ':'-'|escape}" style="width:{$p2}%"></i>{/if}
            {if $b3n > 0}<i class="{$b3k|lower|replace:' ':'-'|escape}" style="width:{$p3}%"></i>{/if}
            {if $b4n > 0}<i class="{$b4k|lower|replace:' ':'-'|escape}" style="width:{$p4}%"></i>{/if}
            {if $b5n > 0}<i class="{$b5k|lower|replace:' ':'-'|escape}" style="width:{$p5}%"></i>{/if}
        </div>
        <div class="bn-legend">
            {if $b1n > 0}<span class="bn-leg"><i class="{$b1k|lower|replace:' ':'-'|escape}"></i>{$b1k|escape} <b>{$b1n}</b></span>{/if}
            {if $b2n > 0}<span class="bn-leg"><i class="{$b2k|lower|replace:' ':'-'|escape}"></i>{$b2k|escape} <b>{$b2n}</b></span>{/if}
            {if $b3n > 0}<span class="bn-leg"><i class="{$b3k|lower|replace:' ':'-'|escape}"></i>{$b3k|escape} <b>{$b3n}</b></span>{/if}
            {if $b4n > 0}<span class="bn-leg"><i class="{$b4k|lower|replace:' ':'-'|escape}"></i>{$b4k|escape} <b>{$b4n}</b></span>{/if}
            {if $b5n > 0}<span class="bn-leg"><i class="{$b5k|lower|replace:' ':'-'|escape}"></i>{$b5k|escape} <b>{$b5n}</b></span>{/if}
        </div>
        {/if}

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
                <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$svc.id|escape:'url'}" class="min-row bn-row{if $svc@iteration > $bnRows} min-more{/if}">
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
                {/foreach}
            {elseif $sec == 'domains'}
                {foreach $bnDomains as $dom}
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&amp;id={$dom.id|escape:'url'}" class="min-row bn-row{if $dom@iteration > $bnRows} min-more{/if}">
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
                {/foreach}
            {elseif $sec == 'invoices'}
                {foreach $bnInvoices as $inv}
                <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id|escape:'url'}" class="min-row bn-row{if $inv@iteration > $bnRows} min-more{/if}">
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
                {/foreach}
            {elseif $sec == 'tickets'}
                {foreach $bnTickets as $tkt}
                <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape:'url'}{if $tkt.c}&amp;c={$tkt.c|escape:'url'}{/if}" class="min-row bn-row{if $tkt@iteration > $bnRows} min-more{/if}">
                    <span class="min-name">
                        <span class="bn-rn">{$tkt.subject|escape}</span>
                        <span class="bn-rs">#{$tkt.tid|escape}{if $tkt.lastreply} &middot; {$hadrianLang.dashboard.updated} {$tkt.lastreply|escape}{/if}</span>
                    </span>
                    <span class="status-pill {$tkt.status|default:'Open'|lower|replace:' ':'-'|escape}">{$tkt.status|default:'Open'|escape}</span>
                </a>
                {/foreach}
            {else}
                {foreach $bnNews as $ann}
                <a href="{$WEB_ROOT}/announcements.php?id={$ann.id|escape:'url'}" class="min-row bn-row bn-ann{if $ann@iteration > $bnRows} min-more{/if}">
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
                {/foreach}
            {/if}

            {if $secCount > $bnRows}
            <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
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
