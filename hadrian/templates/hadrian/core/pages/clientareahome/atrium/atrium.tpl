{* Hostnodes - Client Home dashboard, "atrium" variant.

   A welcome band over four summary figures, then an asymmetric two-column body.
   That last part is why it is a variant rather than a bento arrangement: bento
   flows tiles across one six-column grid, which interleaves rows and cannot
   produce two independent stacks of unequal height. Here a section's WIDTH
   reads as a COLUMN ASSIGNMENT -- full-width band, main column, side column.

   Variables from WHMCS:
     $clientsdetails.firstname
     $clientsstats.productsnumactive / .numactivedomains / .numactivetickets
                   .numunpaidinvoices / .unpaidinvoicesamount / .numexpiringdomains

   From the Hadrian ClientAreaPageHome hook ($dashboard):
     greeting                'morning'|'afternoon'|'evening'
     billing.overdueAmount / .worstDays / .worstNum / .credit / .hasCredit
     attention.awaitingReply integer, exact COUNT of tickets awaiting the client

   DATA HONESTY. The mockup this is ported from carries several figures with no
   WHMCS source, and they are DROPPED rather than approximated -- a metric that
   looks real and is not is worse than an absent one:
     "+2 since last month"   no services-added-since figure exists
     "3 renewing soon"       nextDueDate arrives pre-formatted, no timestamp left
     "next 14 Sep"           no MIN(expirydate) query; merged into the 45-day count
     "due 2 Aug"             no due date reaches this page; replaced by overdue age
     "1 new"                 no unread count; relabelled to awaiting-your-reply
     "avg 2h reply"          tblticketreplies is never queried. No substitute.
   Every figure below names the variable it comes from.

   NOTE on empty states: each block branches on its OWN count with {if}, not on
   the global .when-full/.when-empty classes. Those are driven by one page-level
   body[data-data] flag, so using them per-block would show an empty Domains
   card to a client who has services but no domains. The page-level flag is
   still emitted, for the theme's global affordances and the preview chip.

   Variant options (admin: Hadrian > Pages > Dashboard), read as
   $hadrian.pages.clientareahome.options.* - NOT .config.*, which does not exist:
     atr_hero            bool - the welcome band
     atr_stat_services   bool - summary figure
     atr_stat_domains    bool - summary figure
     atr_stat_billing    bool - summary figure
     atr_stat_tickets    bool - summary figure
*}

{* ---------- options ----------
   A stored FALSE must not be re-defaulted to true. |default: fires on a value
   the modifier considers "missing", and which values those are depends on the
   Smarty build: an empty()-based smarty_modifier_default treats false as
   missing and hands back the default, so a toggle switched OFF comes back ON
   and the control looks broken. isset() is right under either implementation.
   Only default-TRUE booleans need this. *}
{assign var=atHero value=true}
{if isset($hadrian.pages.clientareahome.options.atr_hero)}{assign var=atHero value=$hadrian.pages.clientareahome.options.atr_hero}{/if}
{assign var=atStatSvc value=true}
{if isset($hadrian.pages.clientareahome.options.atr_stat_services)}{assign var=atStatSvc value=$hadrian.pages.clientareahome.options.atr_stat_services}{/if}
{assign var=atStatDom value=true}
{if isset($hadrian.pages.clientareahome.options.atr_stat_domains)}{assign var=atStatDom value=$hadrian.pages.clientareahome.options.atr_stat_domains}{/if}
{assign var=atStatBill value=true}
{if isset($hadrian.pages.clientareahome.options.atr_stat_billing)}{assign var=atStatBill value=$hadrian.pages.clientareahome.options.atr_stat_billing}{/if}
{assign var=atStatTkt value=true}
{if isset($hadrian.pages.clientareahome.options.atr_stat_tickets)}{assign var=atStatTkt value=$hadrian.pages.clientareahome.options.atr_stat_tickets}{/if}

{* ---------- counts ----------
   Real figures, each from a named variable. numunpaidinvoices is NOT summed
   with numoverdueinvoices: they count the same invoices twice. *}
{assign var=atSvcN  value=$clientsstats.productsnumactive|default:0}
{assign var=atDomN  value=$clientsstats.numactivedomains|default:0}
{assign var=atDomEx value=$clientsstats.numexpiringdomains|default:0}
{assign var=atInvN  value=$clientsstats.numunpaidinvoices|default:0}
{assign var=atTktN  value=$clientsstats.numactivetickets|default:0}
{assign var=atTktWait value=$dashboard.attention.awaitingReply|default:0}

{if $atSvcN > 0 || $atDomN > 0 || $atInvN > 0 || $atTktN > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareahome.css?v={$hadrian.version|default:'1.0'}">

{* Page-level signal. header.tpl owns data-layout / data-subnav / data-svc-layout,
   so only the one this page decides is set here. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

{* ---------- welcome band ---------- *}
{if $atHero}
<section class="at-hero">
    <div class="at-hero-main">
        <h1 class="at-hero-title">
            {if $dashboard.greeting == 'morning'}{$hadrianLang.dashboard.goodMorning}
            {elseif $dashboard.greeting == 'afternoon'}{$hadrianLang.dashboard.goodAfternoon}
            {else}{$hadrianLang.dashboard.goodEvening}{/if}{if $clientsdetails.firstname}, {$clientsdetails.firstname|escape}{/if}
        </h1>
        <p class="at-hero-sub">
            <span class="when-full">{$hadrianLang.dashboard.atriumSubFull}</span>
            <span class="when-empty">{$hadrianLang.dashboard.atriumSubEmpty}</span>
        </p>
    </div>
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
</section>
{/if}

{* ---------- summary figures ----------
   ONE section drawing its own four-up grid, not four sections: the layout DSL
   has no 1/4 token and six columns cannot express quarters -- four 1/3 entries
   would span 8 and wrap 3+1. Each tile is switched independently instead. *}
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
        {if $atDomEx > 0}<span class="at-stat-sub">{$atDomEx} {if $atDomEx == 1}{$hadrianLang.dashboard.domainSingular}{else}{$hadrianLang.dashboard.domainPlural}{/if} {$hadrianLang.dashboard.expireWithin45}</span>{/if}
    </a>
    {/if}
    {if $atStatBill}
    <a class="at-stat{if $atInvN > 0} is-due{/if}" href="{$WEB_ROOT}/clientarea.php?action=invoices">
        <span class="at-stat-label">{$hadrianLang.dashboard.balanceDue}</span>
        <span class="at-stat-value">{if $clientsstats.unpaidinvoicesamount}{$clientsstats.unpaidinvoicesamount}{else}&mdash;{/if}</span>
        {* Overdue AGE is knowable; a future due date is not. Shown only when
           something actually is overdue. *}
        {if $dashboard.billing.overdueAmount|default:'' && $dashboard.billing.worstDays|default:0 > 0}
        <span class="at-stat-sub is-alert">{$dashboard.billing.worstDays} {$hadrianLang.dashboard.daysOverdue}</span>
        {elseif $atInvN > 0}
        <span class="at-stat-sub">{$atInvN} {if $atInvN == 1}{$hadrianLang.dashboard.unpaidInvoiceOne}{else}{$hadrianLang.dashboard.unpaidInvoiceMany}{/if}</span>
        {/if}
    </a>
    {/if}
    {if $atStatTkt}
    <a class="at-stat" href="{$WEB_ROOT}/supporttickets.php">
        <span class="at-stat-label">{$hadrianLang.dashboard.openTickets}</span>
        <span class="at-stat-value">{$atTktN}</span>
        {* "N awaiting your reply", never "N new": this is an exact COUNT of
           tickets staff have answered, not an unread count. *}
        {if $atTktWait > 0}<span class="at-stat-sub">{$atTktWait} {if $atTktWait == 1}{$hadrianLang.dashboard.attnTicketOne}{else}{$hadrianLang.dashboard.attnTicketMany}{/if}</span>{/if}
    </a>
    {/if}
</section>
{/if}
