{* Hostnodes - Client Home dashboard, "bento" variant.

   Where minimal lays every collection out as plain rows on one surface, bento
   gives each one its own tile: an eyebrow, a count and its rows, arranged
   two-up on the same six-column grid the admin builder drives.
   Above the grid sit a greeting with the account's real scale and an attention
   strip that pulls the few things needing action out of the many rows.

   Variables from WHMCS:
     $clientsdetails.firstname / .lastname / .companyname / .email / .phonenumber
                    .address1 / .city / .state / .postcode
     $clientsstats.productsnumactive / .numactivedomains / .numactivetickets
                   .numunpaidinvoices / .numoverdueinvoices
                   .unpaidinvoicesamount / .numexpiringdomains

   From the Hadrian ClientAreaPageHome hook ($dashboard):
     greeting        'morning'|'afternoon'|'evening'
     activeServices[] id, name, domain, status, nextDueDate
     domains[]        id, domain, status, statusLower, expirydate, nextduedate
     recentInvoices[] id, date, total, status, statusLower
     openTickets[]    tid, c, subject, status, date, lastreply
     announcements[]  id, title, date
     tldPricing[]     tld, price          (Register tile)
     countryName      string              (Profile tile)

   NOTE on empty states: each tile branches on its OWN row count with {if}, not
   on the global .when-full/.when-empty classes. Those are driven by one
   page-level body[data-data] flag, so using them per-tile would show an empty
   Domains card to a client who has services but no domains. The page-level flag
   is still emitted below, for the theme's global affordances.

   Variant options (admin: Hadrian > Pages > Dashboard), read as
   $hadrian.pages.clientareahome.options.* - NOT .config.*, which does not exist:
     bnt_attention     bool - the attention strip
     bnt_account       bool - the identity card beside the greeting
     bnt_visible_rows  int  - default items per tile (each tile may override)
     bnt_search_at     int  - row count at which Services/Domains grow a filter
     bnt_sections      the tile arrangement (see bento.php)
*}

{* ---------- options ---------- *}
{assign var=bnActs value=$hadrian.pages.clientareahome.options.bnt_attention|default:true}
{assign var=bnAcct value=$hadrian.pages.clientareahome.options.bnt_account|default:true}

{* Deliberately NOT |default: on the two integers. Zero is a meaningful stored
   value ("off" for the filter), and whether |default: treats 0 as missing
   depends on which implementation of the modifier is in play -- the compiled
   form tests null/'' and would keep the 0, an empty()-based one would replace
   it and make "off" unreachable. Testing isset() explicitly is correct either
   way. Same reasoning as minimal.tpl. *}
{assign var=bnRows value=4}
{if isset($hadrian.pages.clientareahome.options.bnt_visible_rows)
    && $hadrian.pages.clientareahome.options.bnt_visible_rows !== ''}
    {assign var=bnRows value=$hadrian.pages.clientareahome.options.bnt_visible_rows}
{/if}
{if $bnRows < 1}{assign var=bnRows value=4}{/if}

{assign var=bnSearchAt value=8}
{if isset($hadrian.pages.clientareahome.options.bnt_search_at)
    && $hadrian.pages.clientareahome.options.bnt_search_at !== ''}
    {assign var=bnSearchAt value=$hadrian.pages.clientareahome.options.bnt_search_at}
{/if}
{if !($bnSearchAt > 0)}{assign var=bnSearchAt value=0}{/if}

{* ---------- data ---------- *}
{assign var=bnServices value=$dashboard.activeServices|default:[]}
{assign var=bnDomains  value=$dashboard.domains|default:[]}
{assign var=bnInvoices value=$dashboard.recentInvoices|default:[]}
{assign var=bnTickets  value=$dashboard.openTickets|default:[]}
{assign var=bnNews     value=$dashboard.announcements|default:[]}

{assign var=nServices value=$bnServices|@count}
{assign var=nDomains  value=$bnDomains|@count}
{assign var=nInvoices value=$bnInvoices|@count}
{assign var=nTickets  value=$bnTickets|@count}
{assign var=nNews     value=$bnNews|@count}

{if $nServices > 0 || $nDomains > 0 || $nInvoices > 0 || $nTickets > 0 || $nNews > 0
    || $clientsstats.productsnumactive > 0 || $clientsstats.numactivedomains > 0
    || $clientsstats.numunpaidinvoices > 0 || $clientsstats.numactivetickets > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* ---------- attention chips ----------
   Every chip is an ACCOUNT TOTAL from $clientsstats, never a count taken over
   one of the $dashboard arrays. Those are capped at 8 rows by the hook and
   sliced in API order, so a suspended service can fall off the end entirely --
   a chip derived from one would quietly undercount. The three below are the
   same figures the default variant's notices already run on.

   No "services need action" chip for exactly that reason: WHMCS publishes no
   suspended-service total, and the only other source is the capped array. *}
{assign var=bnOverdue value=$clientsstats.numoverdueinvoices|default:0}
{assign var=bnUnpaid  value=$clientsstats.numunpaidinvoices|default:0}
{assign var=bnExpiring value=$clientsstats.numexpiringdomains|default:0}
{assign var=bnAttnCount value=0}
{if $bnOverdue > 0}
    {assign var=bnAttnCount value=($bnAttnCount+$bnOverdue)}
{elseif $bnUnpaid > 0}
    {assign var=bnAttnCount value=($bnAttnCount+$bnUnpaid)}
{/if}
{if $bnExpiring > 0}{assign var=bnAttnCount value=($bnAttnCount+$bnExpiring)}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareahome.css?v={$hadrian.version|default:'1.0'}">

{* Page-level signals. header.tpl owns data-layout / data-subnav / data-svc-layout,
   so only the one this page actually decides is set here. Bento never emits
   data-min-title: its titles are always inside the tile. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

{* ---------- head ----------
   Greeting, the account's real scale, and the identity card. The scale line is
   three count/label pairs rather than a sentence: a translated sentence with
   three numbers embedded in it cannot be assembled from fragments without
   getting the word order wrong in half the languages the theme ships to. *}
<div class="bn-head">
    <div class="bn-headline">
        <h1 class="bn-greeting">{if $dashboard.greeting == 'morning'}{$hadrianLang.dashboard.goodMorning}{elseif $dashboard.greeting == 'evening'}{$hadrianLang.dashboard.goodEvening}{else}{$hadrianLang.dashboard.goodAfternoon}{/if}{if $clientsdetails.firstname}, {$clientsdetails.firstname|escape}{/if}.</h1>
        <p class="bn-scale">
            <span class="bn-scale-i"><b>{$clientsstats.productsnumactive|default:0}</b> {$LANG.navservices|default:'Services'}</span>
            <span class="bn-dot">&middot;</span>
            <span class="bn-scale-i"><b>{$clientsstats.numactivedomains|default:0}</b> {$LANG.navdomains|default:'Domains'}</span>
            <span class="bn-dot">&middot;</span>
            <span class="bn-scale-i"><b>{$clientsstats.numactivetickets|default:0}</b> {$LANG.navtickets|default:'Support'}</span>
        </p>
    </div>
    {if $bnAcct}
        {assign var=bnFirst value=$clientsdetails.firstname|default:''}
        {assign var=bnLast value=$clientsdetails.lastname|default:''}
        {assign var=bnCo value=$clientsdetails.companyname|default:''}
        {assign var=bnFull value="`$bnFirst` `$bnLast`"|trim}
        {* Initials follow whichever name is the heading, so the mark and the
           label always agree. Recomputed here rather than reusing
           $user_initials: that is assigned inside whichever chrome partial the
           active layout happens to include, so it is not reliably in scope. *}
        {assign var=bnI1 value=$bnFirst|truncate:1:''|upper}
        {assign var=bnI2 value=$bnLast|truncate:1:''|upper}
        {if $bnCo}
            {assign var=bnMark value=$bnCo|truncate:2:''|upper}
        {else}
            {assign var=bnMark value=$bnI1|cat:$bnI2}
        {/if}
    <div class="bn-acct">
        <span class="bn-acct-av">{$bnMark|escape}</span>
        <span class="bn-acct-main">
            <span class="bn-acct-nm">{if $bnCo}{$bnCo|escape}{else}{$bnFull|escape}{/if}</span>
            <span class="bn-acct-links">
                <a href="{$WEB_ROOT}/clientarea.php?action=details">{$hadrianLang.dashboard.editProfile}</a>
                <span class="bn-dot">&middot;</span>
                <a href="{routePath('user-security')}">{$LANG.navsecuritysettings|default:'Security'}</a>
                <span class="bn-dot">&middot;</span>
                <a href="{routePath('account-paymentmethods')}">{$LANG.paymentMethods.title|default:'Payment Methods'}</a>
            </span>
        </span>
    </div>
    {/if}
</div>

{* ---------- attention strip ----------
   Dropped entirely when every chip would be zero, so a healthy account never
   sees an empty alarm bar. *}
{if $bnActs && $bnAttnCount > 0}
<div class="bn-attn" data-bn-attn>
    <span class="bn-attn-lead"><span class="n">{$bnAttnCount}</span>{$hadrianLang.dashboard.needsAttention}</span>
    {if $bnOverdue > 0}
    <a class="bn-chip red" href="{$WEB_ROOT}/clientarea.php?action=invoices">{$bnOverdue} {if $bnOverdue == 1}{$hadrianLang.dashboard.overdueInvoice}{else}{$hadrianLang.dashboard.overdueInvoices}{/if}{if $clientsstats.unpaidinvoicesamount} <span class="bn-dot">&middot;</span> {$clientsstats.unpaidinvoicesamount}{/if}</a>
    {elseif $bnUnpaid > 0}
    <a class="bn-chip orange" href="{$WEB_ROOT}/clientarea.php?action=invoices">{$bnUnpaid} {if $bnUnpaid == 1}{$hadrianLang.dashboard.unpaidInvoiceOne}{else}{$hadrianLang.dashboard.unpaidInvoiceMany}{/if}{if $clientsstats.unpaidinvoicesamount} <span class="bn-dot">&middot;</span> {$clientsstats.unpaidinvoicesamount}{/if}</a>
    {/if}
    {if $bnExpiring > 0}
    <a class="bn-chip orange" href="{$WEB_ROOT}/clientarea.php?action=domains">{$bnExpiring} {if $bnExpiring == 1}{$hadrianLang.dashboard.domainSingular}{else}{$hadrianLang.dashboard.domainPlural}{/if} {$hadrianLang.dashboard.expiringSoon}</a>
    {/if}
    <span class="bn-attn-sp"></span>
    <button type="button" class="bn-attn-x" data-bn-dismiss>{$hadrianLang.dashboard.dismiss}</button>
</div>
{/if}

{* ---------- tiles ----------
   $bnSecs is resolved in PHP (Hooks::resolveCurrentPage -> SectionLayout). An
   empty list means "no admin layout saved" and selects the built-in
   arrangement, so this is fail-safe: if the theme deploys ahead of the addon
   the read is null, |default:[] gives [], and the built-in pairing renders.

   The built-in arrangement is v17's: a wide tile beside a narrow one, three
   rows deep, then the identity tile across the full width. Both panels are in
   it from the start, which is why Hooks::dashboardMentions has a bento arm for
   the blank-layout case -- without it the Register tile would come up with no
   prices and the Profile tile with no country line. *}
{assign var=bnSecs value=$hadrian.pages.clientareahome.sections.bnt_sections|default:[]}

<div class="min-grid min-grid-custom bn-grid">
{if $bnSecs|@count > 0}
    {foreach $bnSecs as $s}
        {if $s.visible}
            {* The include path is a constant; only `sec` varies, and it is
               whitelisted here as well as in SectionLayout::parse. Never
               interpolate a stored value into a file path -- an unresolvable
               {include} drops the whole client area to the Six theme, and the
               poisoned compiled-template cache survives a git revert. *}
            {if $s.key == 'services' || $s.key == 'domains' || $s.key == 'invoices' || $s.key == 'tickets' || $s.key == 'announcements' || $s.key == 'domainreg' || $s.key == 'profile'}
                {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec=$s.key secSpan=$s.span secHideEmpty=$s.hideEmpty secPaint=$s.paint secFill=$s.fill secRowsIn=$s.rows}
            {/if}
        {/if}
    {/foreach}
{else}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='services' secSpan=4}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='domains' secSpan=2}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='invoices' secSpan=2}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='tickets' secSpan=4}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='announcements' secSpan=4}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='domainreg' secSpan=2}
    {include file="`$template`/core/pages/clientareahome/bento/cell.tpl" sec='profile' secSpan=6}
{/if}
</div>

{* The strip's dismiss and the in-tile filter. All markup above is
   server-rendered - this only binds behaviour, so the page is complete and
   readable with JS off.

   The filter is byte-identical to minimal.tpl's. Copied rather than extracted
   into a shared partial deliberately: minimal is live on installs today and
   adding bento must not require editing a file it renders. Worth folding into
   one includes/ partial the next time either changes.

   {literal} because Smarty would otherwise parse the JS braces as tags. *}
{literal}
<script>
(function () {
    // Attention strip. Dismissal is per browser session, not persisted to the
    // account: the underlying invoice or expiry has not gone anywhere, and
    // burying it for good would hide a bill.
    //
    // There is deliberately no Show more handler here. Every tile server-renders
    // exactly the rows it shows, so there is nothing to reveal -- the rest of
    // the collection lives behind the tile's View all link.
    document.addEventListener('click', function (e) {
        if (!e.target.closest) return;
        var x = e.target.closest('[data-bn-dismiss]');
        if (x) {
            var strip = x.closest('[data-bn-attn]');
            if (strip) strip.style.display = 'none';
            try { sessionStorage.setItem('hadrianBentoAttn', 'off'); } catch (err) {}
        }
    });

    try {
        if (sessionStorage.getItem('hadrianBentoAttn') === 'off') {
            document.querySelectorAll('[data-bn-attn]').forEach(function (s) { s.style.display = 'none'; });
        }
    } catch (err) {}

    // In-tile filter. Rendered server-side only on tiles showing enough rows
    // to need it. Every row in the tile is a candidate -- there are no hidden
    // ones, because the tile server-renders exactly what it shows.
    document.querySelectorAll('.min-list').forEach(function (list) {
        var search = list.querySelector('.min-search');
        if (!search) return;
        var input = search.querySelector('input');
        var clear = search.querySelector('.min-search-clear');
        var rows  = Array.prototype.slice.call(list.querySelectorAll('.min-row'));
        if (!input) return;

        function apply() {
            var q = input.value.trim().toLowerCase();
            var matches = 0;
            list.classList.toggle('searching', !!q);
            search.classList.toggle('has-q', !!q);
            rows.forEach(function (row) {
                var name = row.querySelector('.min-name');
                var hit = !q || (name && name.textContent.toLowerCase().indexOf(q) !== -1);
                row.classList.toggle('min-hidden', !!q && !hit);
                if (hit) matches++;
            });
            list.classList.toggle('no-results', !!q && matches === 0);
        }

        input.addEventListener('input', apply);
        if (clear) clear.addEventListener('click', function () {
            input.value = '';
            apply();
            input.focus();
        });
    });
})();
</script>
{/literal}
