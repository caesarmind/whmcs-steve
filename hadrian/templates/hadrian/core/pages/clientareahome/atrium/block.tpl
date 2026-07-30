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

{assign var=atRows value=$secRows|default:4}

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
     {if $secCustom|default:''}style="--blk-base:#{$secCustom|escape}"{/if}>

{* ---------------- Amount due ----------------
   A panel, not a collection. Renders NOTHING when nothing is owed: an
   "amount due: nothing" card is worse than no card, because it trains the
   reader to skip the one block that matters when it does appear. Its
   hide-when-empty switch is therefore inert, as documented in atrium.php. *}
{if $sec == 'unpaid'}
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
    <div class="at-card at-panel">
        <div class="at-card-head"><span class="at-card-title">{$hadrianLang.dashboard.accountCredit}</span></div>
        {* hasCredit is the raw float. Never test $clientsstats.creditbalance --
           it is pre-formatted, so the comparison becomes a string test
           against "$0.00". *}
        {if $dashboard.billing.hasCredit|default:false}
            <div class="at-big">{$dashboard.billing.credit}</div>
            <div class="at-panel-meta">{$hadrianLang.dashboard.creditAppliedAuto}</div>
        {else}
            <div class="at-big is-muted">{$dashboard.billing.credit|default:'&mdash;'}</div>
            <div class="at-panel-meta">{$hadrianLang.dashboard.noCreditYet}</div>
        {/if}
        <div class="at-panel-btns">
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="at-btn at-btn-primary">{$hadrianLang.dashboard.addFunds}</a>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="at-btn">{$hadrianLang.dashboard.invoiceHistory}</a>
        </div>
    </div>

{* ---------------- Quick actions ---------------- *}
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
                        {if $sec == 'services'}{$r.name|escape}
                        {elseif $sec == 'domains'}{$r.domain|escape}
                        {elseif $sec == 'invoices'}#{$r.id|escape}
                        {elseif $sec == 'tickets'}{$r.subject|escape}
                        {else}{$r.title|escape}{/if}
                    </span>
                    {if !$secCompact|default:false}
                        {if $sec == 'services' && ($r.domain || $r.nextDueDate)}
                        <span class="at-row-sub">{if $r.domain}{$r.domain|escape}{/if}{if $r.domain && $r.nextDueDate} &middot; {/if}{if $r.nextDueDate}{$hadrianLang.dashboard.renews} {$r.nextDueDate|escape}{/if}</span>
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
