{* One Atrium body block. Included once per section by atrium.tpl.

   Params:
     sec           the section key (whitelisted at the call site AND in
                   SectionLayout::parse -- never interpolated into a path)
     secPaint      palette key or hexRRGGBB, '' for unpainted
     secFill       solid | tint | grad
     secCustom     the six hex digits when secPaint is a custom colour
     secHideEmpty  bool, drop the block entirely when it has no rows
     secHideList   bool, keep the summary and drop the row list (Billing only)
     secCompact    bool, rows lose their second line
     secRows       resolved row cap

   Each block branches on its OWN count, never on the page-level
   .when-full/.when-empty classes -- those follow one body[data-data] flag, so a
   client with services but no domains would get an empty Services card too. *}

{* secRows is the 5th field of this block's layout entry, and the parser
   returns 0 when the admin left it blank -- NOT "show no rows". |default:
   does not fire on 0, so treating it as a cap emptied every list the moment a
   layout was saved. Same guard bento uses. *}
{assign var=atRows value=$secRows|default:0}
{if $atRows < 1}{assign var=atRows value=4}{/if}

{* Paint plumbing, identical to bento's: the palette key becomes an attribute
   the stylesheet matches, and a custom colour arrives as a --blk-base on the
   element. secFill must never resolve empty -- the panel rules select on the
   VALUE, so a blank one leaves them unpainted while the list rules (which
   select on presence) still fire. *}
{assign var=atFill value=$secFill|default:'tint'}
{if $atFill == ''}{assign var=atFill value='tint'}{/if}

<div class="at-cell min-section"
     data-sec="{$sec|escape}"
     {if $secPaint|default:''}data-blk-paint="{$secPaint|escape}" data-blk-fill="{$atFill|escape}"{/if}
     {if $secCustom|default:''}style="--blk-base:{$secCustom|escape}"{/if}>

{* ---------------- Welcome band ----------------
   A block like any other now, so it reorders, hides and paints from the
   builder alongside everything else. It carries no rows, so hide-when-empty
   has nothing to act on. *}
{if $sec == 'hero'}
<section class="at-hero" data-at-style="{$atHeroStyle|escape}" data-at-width="{$atHeroWidth|escape}" data-at-acts="{$atHeroActs|escape}" data-at-profile="{$atHeroProfile|escape}" data-at-size="{$atHeroSize|escape}">
    {* Decorative rings around the avatar. FIRST child so it paints under the
       text and buttons, which carry z-index 2 and 3; it is inert (aria-hidden,
       pointer-events:none) and takes no flex slot, being absolutely positioned.
       Gated on the same condition as the avatar itself -- they are an ornament
       ON the disc, so with no disc there is nothing to ring. It cannot sit
       inside the avatar as the mockup has it; see .at-hero-rings in the CSS. *}
    {if $atHeroProfile == 'avatar' && $loggedin}
    <span class="at-hero-rings" aria-hidden="true"><span class="at-hero-ring"></span></span>
    {/if}
    <div class="at-hero-main">
        {* Supplied by the hook, not formatted in Smarty: |date_format's
           %-style codes rely on strftime and are broken on PHP 8.1+. *}
        {if $dashboard.today|default:''}<div class="at-hero-date">{$dashboard.today|escape}</div>{/if}
        <h1 class="at-hero-title">
{if $dashboard.greeting == 'morning'}{$hadrianLang.dashboard.goodMorning}{elseif $dashboard.greeting == 'afternoon'}{$hadrianLang.dashboard.goodAfternoon}{else}{$hadrianLang.dashboard.goodEvening}{/if}{if $clientsdetails.firstname}, {$clientsdetails.firstname|escape}{/if}
        </h1>
        <p class="at-hero-sub">
            <span class="when-full">{$hadrianLang.dashboard.atriumSubFull}</span>
            <span class="when-empty">{$hadrianLang.dashboard.atriumSubEmpty}</span>
        </p>
    </div>
    {if $atHeroActs != 'off'}
    <div class="at-hero-actions">
        {* Gated with {if}, not CSS: a client with nothing due must never have
           the string emitted at all, or it ships in the HTML for anyone
           reading source. *}
        {if $atInvN > 0 && $clientsstats.unpaidinvoicesamount}
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="at-hero-btn at-hero-btn-primary">
            {$hadrianLang.dashboard.payBalance} &mdash; {$clientsstats.unpaidinvoicesamount}
        </a>
        {/if}
        <a href="{$WEB_ROOT}/cart.php" class="at-hero-btn">{$LANG.orderproducts|default:'Order a service'}</a>
    </div>
    {/if}

    {* Account menu. Reuses includes/partials/profile-dropdown.tpl -- the one
       body four other call sites already share -- rather than porting the
       mockup's own dropdown, so the band offers exactly the items the topbar
       and sidebar do and gains no second list to keep in step.

       The partial resolves $user_fullname and $_email from the INCLUDING
       scope, and each call site sets them itself (see inner-topbar.tpl), so
       they are assigned here too. ddId must match the arm added to
       togglePortalProfile() and the ALL[] list in apple-layout.js, or the menu
       opens and outside-click never closes it. *}
    {if $atHeroProfile == 'avatar' && $loggedin}
    {assign var=_first value=$clientsdetails.firstname|default:''}
    {assign var=_last value=$clientsdetails.lastname|default:''}
    {assign var=_email value=$clientsdetails.email|default:''}
    {assign var=user_initials value=$_first|truncate:1:''|upper}
    {assign var=user_fullname value=$_first|cat:' '|cat:$_last}
    <div class="profile-dropdown-wrapper at-hero-profile" id="atBandUserWrap">
        <button type="button" class="at-hero-avatar" onclick="togglePortalProfile && togglePortalProfile(event, 'band')"
                aria-haspopup="menu" aria-expanded="false"
                title="{$LANG.accounttab|default:'Account'}">{$user_initials|default:'U'}</button>
        {include file="`$template`/includes/partials/profile-dropdown.tpl" ddId="profileDropdownBand"}
    </div>
    {/if}
</section>

{* ---------------- Summary figures ----------------
   ONE block drawing its own four-up grid, not four: the layout DSL has no 1/4
   token and six columns cannot express quarters. WHICH figures appear is set
   by the atr_stat_* options; hide-when-empty drops the whole strip when the
   account has nothing in any of them, which is the one sense in which a strip
   of counts can be empty. *}
{elseif $sec == 'stats'}
    {if !($secHideEmpty|default:false && $atSvcN == 0 && $atDomN == 0 && $atInvN == 0 && $atTktN == 0)}
{* Each figure is a flag on THIS block. The flag is negative (its presence
   HIDES the figure) because a flag is absent by default and the four figures
   ship on; the admin control is labelled positively and inverted for storage,
   the same way the invoice-list switch works. *}
{assign var=atStatSvc value=true}{if $secFlags.s|default:false}{assign var=atStatSvc value=false}{/if}
{assign var=atStatDom value=true}{if $secFlags.d|default:false}{assign var=atStatDom value=false}{/if}
{assign var=atStatBill value=true}{if $secFlags.b|default:false}{assign var=atStatBill value=false}{/if}
{assign var=atStatTkt value=true}{if $secFlags.t|default:false}{assign var=atStatTkt value=false}{/if}
{* The sub-line flag runs the other way: the strip ships COMPACT, so 'f' turns
   detail on rather than off. Compact is what the mockup's own Stats chip does
   (body[data-stats="compact"] hides .dash-stat-sub) and it is the difference
   between a 104px tile and a 136px one -- a single tile with a sub-line
   stretches the whole grid row, so one overdue invoice grew all four. *}
{assign var=atStatSub value=false}{if $secFlags.f|default:false}{assign var=atStatSub value=true}{/if}
{assign var=atStatN value=0}
{if $atStatSvc}{assign var=atStatN value=($atStatN+1)}{/if}
{if $atStatDom}{assign var=atStatN value=($atStatN+1)}{/if}
{if $atStatBill}{assign var=atStatN value=($atStatN+1)}{/if}
{if $atStatTkt}{assign var=atStatN value=($atStatN+1)}{/if}
{if $atStatN > 0}
{* --at-stat-n drives the column count: the tiles are independently switchable
   and repeat(auto-fit, ...) would leave empty tracks when fewer than four are
   on, half-filling the row. *}
<section class="at-stats" style="--at-stat-n:{$atStatN}">
    {if $atStatSvc}
    <a class="at-stat" href="{$WEB_ROOT}/clientarea.php?action=services">
        <span class="at-stat-label">{$hadrianLang.dashboard.activeServices}</span>
        <span class="at-stat-value">{$atSvcN}</span>
        {* No sub-line. The mockup's "3 renewing soon" has no source: nextDueDate
           arrives pre-formatted with no timestamp left to window on. Every stat
           tile in the default variant is count + label for the same reason. *}
    </a>
    {/if}
    {if $atStatDom}
    <a class="at-stat" href="{$WEB_ROOT}/clientarea.php?action=domains">
        <span class="at-stat-label">{$LANG.navdomains|default:'Domains'}</span>
        <span class="at-stat-value">{$atDomN}</span>
        {if $atStatSub && $atDomEx > 0}<span class="at-stat-sub">{$atDomEx} {if $atDomEx == 1}{$hadrianLang.dashboard.domainSingular}{else}{$hadrianLang.dashboard.domainPlural}{/if} {$hadrianLang.dashboard.expireWithin45}</span>{/if}
    </a>
    {/if}
    {if $atStatBill}
    <a class="at-stat{if $atInvN > 0} is-due{/if}" href="{$WEB_ROOT}/clientarea.php?action=invoices">
        <span class="at-stat-label">{$hadrianLang.dashboard.balanceDue}</span>
        <span class="at-stat-value">{if $clientsstats.unpaidinvoicesamount}{$clientsstats.unpaidinvoicesamount}{else}&mdash;{/if}</span>
        {* Overdue AGE is knowable; a future due date is not. Shown only when
           something actually is overdue. *}
        {if $atStatSub}
        {if $dashboard.billing.overdueAmount|default:'' && $dashboard.billing.worstDays|default:0 > 0}
        <span class="at-stat-sub is-alert">{$dashboard.billing.worstDays} {$hadrianLang.dashboard.daysOverdue}</span>
        {elseif $atInvN > 0}
        <span class="at-stat-sub">{$atInvN} {if $atInvN == 1}{$hadrianLang.dashboard.unpaidInvoiceOne}{else}{$hadrianLang.dashboard.unpaidInvoiceMany}{/if}</span>
        {/if}
        {/if}
    </a>
    {/if}
    {if $atStatTkt}
    <a class="at-stat" href="{$WEB_ROOT}/supporttickets.php">
        <span class="at-stat-label">{$hadrianLang.dashboard.openTickets}</span>
        <span class="at-stat-value">{$atTktN}</span>
        {* "N awaiting your reply", never "N new": this is an exact COUNT of
           tickets staff have answered, not an unread count. *}
        {if $atStatSub && $atTktWait > 0}<span class="at-stat-sub">{$atTktWait} {if $atTktWait == 1}{$hadrianLang.dashboard.attnTicketOne}{else}{$hadrianLang.dashboard.attnTicketMany}{/if}</span>{/if}
    </a>
    {/if}
</section>
{/if}
    {/if}

{* ---------------- Amount due ----------------
   A panel, not a collection. Renders NOTHING when nothing is owed: an
   "amount due: nothing" card is worse than no card, because it trains the
   reader to skip the one block that matters when it does appear. Its
   hide-when-empty is therefore redundant here rather than inert -- the block
   already behaves as though it were permanently switched on. *}
{elseif $sec == 'unpaid'}
    {if $dashboard.billing.worstAmount|default:''}
    <div class="at-card at-panel">
        <div class="at-card-head">
            <span class="at-card-title">{$hadrianLang.dashboard.amountDue}</span>
            {if $dashboard.billing.worstDays|default:0 > 0}
            <span class="status-pill overdue">{$dashboard.billing.worstDays} {$hadrianLang.dashboard.daysOverdue}</span>
            {/if}
        </div>
        <div class="at-big">{$dashboard.billing.worstAmount}</div>
        {if $dashboard.billing.worstNum|default:''}
        <div class="at-panel-meta">#{$dashboard.billing.worstNum|escape}</div>
        {/if}
        {* Goes to the invoice LIST, not viewinvoice.php?id=worstNum: worstNum is
           the display invoice number, which diverges from the row id on any
           install with custom numbering, so a direct link lands on the wrong
           invoice. *}
        <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="at-btn at-btn-primary">{$hadrianLang.dashboard.payNow}</a>
    </div>
    {/if}

{* ---------------- Account credit ---------------- *}
{elseif $sec == 'credit'}
    {* Hide-when-empty here means "no credit on the account". *}
    {if !($secHideEmpty|default:false && !$dashboard.billing.hasCredit|default:false)}
    <div class="at-card at-panel">
        <div class="at-card-head"><span class="at-card-title">{$hadrianLang.dashboard.accountCredit}</span></div>
        {* hasCredit is the raw float. Never test $clientsstats.creditbalance --
           it is pre-formatted, so the comparison becomes a string test
           against "$0.00". *}
        {if $dashboard.billing.hasCredit|default:false}
            <div class="at-big">{$dashboard.billing.credit}</div>
            <div class="at-panel-meta">{$hadrianLang.dashboard.creditAppliedAuto}</div>
        {else}
            {* Show the FIGURE, not a sentence. credit is pre-formatted by the
               hook and reads "$0.00" with nothing on the account, which says
               the same thing in the shape the reader is scanning for -- and
               keeps the block the same height either way. *}
            <div class="at-big is-muted">{$dashboard.billing.credit|default:$clientsstats.creditbalance|default:'0.00'}</div>
            <div class="at-panel-meta">{$hadrianLang.dashboard.noCreditYet}</div>
        {/if}
        <div class="at-panel-btns">
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="at-btn at-btn-primary">{$hadrianLang.dashboard.addFunds}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="at-btn">{$hadrianLang.dashboard.invoiceHistory}</a>
        </div>
    </div>
    {/if}

{* ---------------- Quick actions ----------------
   Four fixed links, so there is nothing it can be empty OF. The builder offers
   hide-when-empty on every block; on this one it is honestly a no-op rather
   than something quietly broken. *}
{elseif $sec == 'actions'}
    <div class="at-card at-panel">
        <div class="at-card-head"><span class="at-card-title">{$hadrianLang.dashboard.quickActions}</span></div>
        <div class="at-actions">
            <a href="{$WEB_ROOT}/cart.php" class="at-action">{$LANG.orderproducts|default:'Order a service'}</a>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="at-action">{$LANG.registerdomain|default:'Register a domain'}</a>
            <a href="{$WEB_ROOT}/submitticket.php" class="at-action">{$LANG.navopenticket|default:'Open a ticket'}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="at-action">{$LANG.clientareanavdetails|default:'Account details'}</a>
        </div>
    </div>

{* ---------------- Payment methods ----------------
   Its own arm rather than a sixth branch of the collections arm below: the row
   is a different shape -- an identity and a standing, with no date and no
   amount -- and the {else} would have rendered it as announcements.

   Every value here is a plain string or bool flattened by the hook. Nothing in
   this block touches a WHMCS pay-method object, which is deliberate: the
   account page reaches those through $client, and $client does not exist on
   the dashboard. See fetchPayMethods() for the rest of that reasoning. *}
{elseif $sec == 'payments'}
    {assign var=atPm value=$dashboard.payMethods|default:[]}
    {assign var=atPmN value=$atPm|@count}
    {if !($secHideEmpty|default:false && $atPmN == 0)}
    <div class="at-card">
        <div class="at-card-head">
            <span class="at-card-title">{$LANG.paymentMethods.title|default:'Payment Methods'}</span>
            {if $atPmN > 0}
            <a class="at-card-link" href="{routePath('account-paymentmethods')}">{$hadrianLang.dashboard.manage} &rsaquo;</a>
            {/if}
        </div>
        {if $atPmN > 0}
        <div class="at-rows">
            {foreach $atPm as $r}
            {if $r@iteration <= $atRows}
            <div class="at-row">
                <span class="at-row-main">
                    <span class="at-row-name">{if $r.label|default:''}{$r.label|escape}{else}{$hadrianLang.dashboard.payMethodUnnamed}{/if}</span>
                    {if !$secCompact|default:false && $r.sub|default:''}
                    <span class="at-row-sub">{$r.sub|escape}</span>
                    {/if}
                </span>
                {* Expired outranks default: a lapsed card that is ALSO the
                   default is the worst case on the account, and saying
                   "Default" about it would bury that. *}
                {if $r.isExpired|default:false}
                <span class="status-pill expired">{$hadrianLang.billing.pmExpired}</span>
                {elseif $r.isDefault|default:false}
                <span class="status-pill is-default">{$LANG.paymentMethods.default|default:'Default'}</span>
                {/if}
            </div>
            {/if}
            {/foreach}
        </div>
        {else}
        <div class="at-empty min-empty">
            <div class="at-empty-title">{$hadrianLang.dashboard.noPayMethodsTitle}</div>
            <p>{$LANG.paymentMethods.noPaymentMethodsCreated|default:'You have no payment methods saved.'}</p>
            <a href="{routePath('account-paymentmethods-add')}" class="at-btn at-btn-primary">{$hadrianLang.dashboard.addPayMethod}</a>
        </div>
        {/if}
    </div>
    {/if}

{* ---------------- Collections ---------------- *}
{else}
    {* Resolve this block's rows and count ONCE, so the empty branch and the
       hide-when-empty test agree. *}
    {if $sec == 'services'}{assign var=atList value=$dashboard.activeServices|default:[]}
    {elseif $sec == 'domains'}{assign var=atList value=$dashboard.domains|default:[]}
    {elseif $sec == 'invoices'}{assign var=atList value=$dashboard.recentInvoices|default:[]}
    {elseif $sec == 'tickets'}{assign var=atList value=$dashboard.openTickets|default:[]}
    {else}{assign var=atList value=$dashboard.announcements|default:[]}{/if}
    {assign var=atN value=$atList|@count}

    {if !($secHideEmpty|default:false && $atN == 0)}
    <div class="at-card">
        <div class="at-card-head">
            <span class="at-card-title">
                {if $sec == 'services'}{$LANG.navservices|default:'Services'}
                {elseif $sec == 'domains'}{$LANG.navdomains|default:'Domains'}
                {elseif $sec == 'invoices'}{$hadrianLang.dashboard.recentInvoices}
                {elseif $sec == 'tickets'}{$LANG.navtickets|default:'Support'}
                {else}{$LANG.announcements|default:'Announcements'}{/if}
            </span>
            {if $atN > 0}
            <a class="at-card-link" href="{if $sec == 'services'}{$WEB_ROOT}/clientarea.php?action=services{elseif $sec == 'domains'}{$WEB_ROOT}/clientarea.php?action=domains{elseif $sec == 'invoices'}{$WEB_ROOT}/clientarea.php?action=invoices{elseif $sec == 'tickets'}{$WEB_ROOT}/supporttickets.php{else}{$WEB_ROOT}/announcements.php{/if}">{if $sec == 'invoices' || $sec == 'announcements'}{$LANG.viewall|default:'View All'}{else}{$hadrianLang.dashboard.manage}{/if} &rsaquo;</a>
            {/if}
        </div>

        {* Billing keeps its aggregate when the list is switched off -- the one
           collection whose headline is an account total rather than a count. *}
        {if $sec == 'invoices' && $secHideList|default:false}
        <div class="at-card-body">
            <div class="at-big">{$clientsstats.unpaidinvoicesamount|default:'&mdash;'}</div>
            <div class="at-panel-meta">
                {if $clientsstats.numunpaidinvoices|default:0 > 0}
                    {$clientsstats.numunpaidinvoices} {if $clientsstats.numunpaidinvoices == 1}{$hadrianLang.dashboard.unpaidInvoiceOne}{else}{$hadrianLang.dashboard.unpaidInvoiceMany}{/if}
                {else}{$hadrianLang.dashboard.nothingDue}{/if}
            </div>
        </div>
        {elseif $atN > 0}
        <div class="at-rows">
            {foreach $atList as $r}
            {if $r@iteration <= $atRows}
            <div class="at-row">
                <span class="at-row-main">
                    <span class="at-row-name">
                        {* Services lead with the DOMAIN: on a hosting account that
                           is what identifies the service, and the product name
                           repeats across every row ("License", "License"). Not
                           every service has one though -- licences and other
                           non-hosting products come back with domain '' -- so
                           the product name is the fallback rather than leaving
                           the row untitled. *}
                        {* label/sublabel are resolved in the hook: WHMCS's domain
                           column holds a LICENCE KEY for licensing products, so
                           "lead with the domain" needs a hostname test, and that
                           is a regex rather than something Smarty should carry.
                           Falls back to name on an older payload. *}
                        {if $sec == 'services'}{$r.label|default:$r.name|escape}
                        {elseif $sec == 'domains'}{$r.domain|escape}
                        {elseif $sec == 'invoices'}#{$r.id|escape}
                        {elseif $sec == 'tickets'}{$r.subject|escape}
                        {else}{$r.title|escape}{/if}
                    </span>
                    {if !$secCompact|default:false}
                        {* The sub-line carries whichever of the pair the title did
                           not use, so nothing is lost either way. *}
                        {if $sec == 'services' && ($r.sublabel|default:'' || $r.nextDueDate)}
                        <span class="at-row-sub">{if $r.sublabel|default:''}{$r.sublabel|escape}{/if}{if $r.sublabel|default:'' && $r.nextDueDate} &middot; {/if}{if $r.nextDueDate}{$hadrianLang.dashboard.renews} {$r.nextDueDate|escape}{/if}</span>
                        {elseif $sec == 'domains' && $r.expirydate}
                        <span class="at-row-sub">{$hadrianLang.dashboard.renews} {$r.expirydate|escape}</span>
                        {elseif $sec == 'invoices' && $r.date}
                        <span class="at-row-sub">{$hadrianLang.dashboard.issued} {$r.date|escape}</span>
                        {elseif $sec == 'tickets'}
                        <span class="at-row-sub">#{$r.tid|escape}{if $r.lastreply} &middot; {$hadrianLang.dashboard.updated} {$r.lastreply|escape}{/if}</span>
                        {elseif $sec == 'announcements' && $r.date}
                        <span class="at-row-sub">{$r.date|escape}</span>
                        {/if}
                    {/if}
                </span>
                {if $sec == 'invoices'}<span class="at-row-amt">{$r.total|escape}</span>{/if}
                {if $r.status|default:''}
                <span class="status-pill {$r.statusLower|default:$r.status|lower|escape}">{$r.status|escape}</span>
                {/if}
            </div>
            {/if}
            {/foreach}
        </div>
        {else}
        {* Per-block empty state: what the block is FOR, and the action that
           fills it. Reuses .min-empty so it inherits the painted-fill ink
           rules the bento tiles already have. *}
        <div class="at-empty min-empty">
            <div class="at-empty-title">
                {if $sec == 'services'}{$hadrianLang.dashboard.noServicesTitle}
                {elseif $sec == 'domains'}{$hadrianLang.dashboard.noDomainsTitle}
                {elseif $sec == 'invoices'}{$hadrianLang.dashboard.allPaidUp}
                {elseif $sec == 'tickets'}{$hadrianLang.dashboard.noTicketsTitle}
                {else}{$hadrianLang.dashboard.noAnnouncements}{/if}
            </div>
            <p>
                {if $sec == 'services'}{$hadrianLang.dashboard.noServicesSub}
                {elseif $sec == 'domains'}{$hadrianLang.dashboard.noDomainsSub}
                {elseif $sec == 'invoices'}{$hadrianLang.dashboard.nothingDue}
                {elseif $sec == 'tickets'}{$hadrianLang.dashboard.noTicketsSub}
                {else}{$hadrianLang.dashboard.noAnnouncementsSub}{/if}
            </p>
            {if $sec == 'services'}<a href="{$WEB_ROOT}/cart.php" class="at-btn at-btn-primary">{$LANG.orderproducts|default:'Order a service'}</a>
            {elseif $sec == 'domains'}<a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="at-btn at-btn-primary">{$LANG.registerdomain|default:'Register a domain'}</a>
            {elseif $sec == 'tickets'}<a href="{$WEB_ROOT}/submitticket.php" class="at-btn at-btn-primary">{$LANG.navopenticket|default:'Open a ticket'}</a>
            {/if}
        </div>
        {/if}
    </div>
    {/if}
{/if}

</div>
