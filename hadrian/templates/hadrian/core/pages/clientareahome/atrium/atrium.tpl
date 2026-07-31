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
     atr_section_titles  inside|outside - where a block's label sits
     atr_hero_style/_width/_actions - the welcome band's appearance
   Which summary figures appear is a per-BLOCK switch on the stats section
   (flag letters s/d/b/t), not a page option: it describes that block.
*}

{* ---------- options ----------
   A stored FALSE must not be re-defaulted to true. |default: fires on a value
   the modifier considers "missing", and which values those are depends on the
   Smarty build: an empty()-based smarty_modifier_default treats false as
   missing and hands back the default, so a toggle switched OFF comes back ON
   and the control looks broken. isset() is right under either implementation.
   Only default-TRUE booleans need this. *}
{assign var=atTitles value=$hadrian.pages.clientareahome.options.atr_section_titles|default:'inside'}
{assign var=atHeroStyle value=$hadrian.pages.clientareahome.options.atr_hero_style|default:'gradient'}
{assign var=atHeroWidth value=$hadrian.pages.clientareahome.options.atr_hero_width|default:'boxed'}
{assign var=atHeroActs value=$hadrian.pages.clientareahome.options.atr_hero_actions|default:'right'}
{assign var=atHeroProfile value=$hadrian.pages.clientareahome.options.atr_hero_profile|default:'off'}
{assign var=atHeroSize value=$hadrian.pages.clientareahome.options.atr_hero_size|default:'full'}

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
    b.setAttribute('data-at-title', '{$atTitles|escape:'javascript'}');
    // The edge band has to break out of .content-area's max-width, which means
    // a rule on an ANCESTOR of the band -- so the flag goes on the body rather
    // than only on the section.
    b.setAttribute('data-at-hero-width', '{$atHeroWidth|escape:'javascript'}');
})();
</script>

{* ---------- body ----------
   Width reads as a COLUMN here, not a size. The parser already returns the
   width TOKEN alongside the span (SectionLayout.php:217, which bento simply
   never passes), so the flat ordered list is bucketed into three containers
   with no change to the DSL:
       1/1  -> the full-width band above the split
       2/3  -> the main (wide) column
       1/3  -> the side (narrow) column
   Ordering, visibility, hide-when-empty, per-block rows and colour all behave
   exactly as bento's. *}
{assign var=atSecs value=$hadrian.pages.clientareahome.sections.atr_sections|default:[]}
{assign var=atDefRows value=4}

{if $atSecs|@count > 0}
    {* Band first: any 1/1 entries, in their saved order. *}
    {assign var=atBand value=0}
    {foreach $atSecs as $s}{if $s.visible && $s.width == '1/1'}{assign var=atBand value=($atBand+1)}{/if}{/foreach}
    {if $atBand > 0}
    <div class="at-band">
        {foreach $atSecs as $s}
            {if $s.visible && $s.width == '1/1'}
                {* The include path is a CONSTANT; only `sec` varies and it is
                   whitelisted here as well as in SectionLayout::parse. Never
                   interpolate a stored value into a path -- an unresolvable
                   {include} drops the whole client area to the Six theme, and
                   the poisoned compiled-template cache survives a git revert. *}
                {if $s.key == 'hero' || $s.key == 'stats' || $s.key == 'services' || $s.key == 'domains' || $s.key == 'invoices' || $s.key == 'tickets' || $s.key == 'announcements' || $s.key == 'unpaid' || $s.key == 'credit' || $s.key == 'actions' || $s.key == 'payments'}
                    {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec=$s.key secPaint=$s.paint secFill=$s.fill secCustom=$s.custom secHideEmpty=$s.hideEmpty secHideList=$s.hideList secCompact=$s.compact secFlags=$s.flags secRows=$s.rows|default:$atDefRows}
                {/if}
            {/if}
        {/foreach}
    </div>
    {/if}

    <div class="at-body">
        <div class="at-main">
        {foreach $atSecs as $s}
            {if $s.visible && ($s.width == '2/3' || $s.width == '1/2')}
                {if $s.key == 'hero' || $s.key == 'stats' || $s.key == 'services' || $s.key == 'domains' || $s.key == 'invoices' || $s.key == 'tickets' || $s.key == 'announcements' || $s.key == 'unpaid' || $s.key == 'credit' || $s.key == 'actions' || $s.key == 'payments'}
                    {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec=$s.key secPaint=$s.paint secFill=$s.fill secCustom=$s.custom secHideEmpty=$s.hideEmpty secHideList=$s.hideList secCompact=$s.compact secFlags=$s.flags secRows=$s.rows|default:$atDefRows}
                {/if}
            {/if}
        {/foreach}
        </div>
        <div class="at-side">
        {foreach $atSecs as $s}
            {if $s.visible && $s.width == '1/3'}
                {if $s.key == 'hero' || $s.key == 'stats' || $s.key == 'services' || $s.key == 'domains' || $s.key == 'invoices' || $s.key == 'tickets' || $s.key == 'announcements' || $s.key == 'unpaid' || $s.key == 'credit' || $s.key == 'actions' || $s.key == 'payments'}
                    {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec=$s.key secPaint=$s.paint secFill=$s.fill secCustom=$s.custom secHideEmpty=$s.hideEmpty secHideList=$s.hideList secCompact=$s.compact secFlags=$s.flags secRows=$s.rows|default:$atDefRows}
                {/if}
            {/if}
        {/foreach}
        </div>
    </div>
{else}
    {* Built-in arrangement, mirroring the v18 mockup: three collections down
       the wide side, the things you act on down the narrow one. Hand-packed
       rather than derived, so a blank or corrupt layout string still renders a
       complete dashboard. *}
    <div class="at-band">
        {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='hero'}
        {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='stats'}
    </div>
    <div class="at-body">
        <div class="at-main">
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='domains'  secRows=$atDefRows}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='services' secRows=$atDefRows}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='invoices' secRows=$atDefRows}
        </div>
        <div class="at-side">
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='announcements' secRows=2}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='unpaid'}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='credit'}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='tickets' secRows=3}
            {include file="`$template`/core/pages/clientareahome/atrium/block.tpl" sec='actions'}
        </div>
    </div>
{/if}
