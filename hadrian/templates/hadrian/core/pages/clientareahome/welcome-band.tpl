{* ---------------- Welcome band (shared) ----------------
   ONE band, included by every dashboard variant that wants it. Lifted out of
   atrium/block.tpl when bento adopted it, so the two cannot drift: a fix to the
   greeting, the buttons or the account menu lands in both places at once.

   The markup deliberately keeps its `at-` class names even outside atrium. The
   ~500 lines of CSS behind it (clientareahome.css:1384-1900, plus the
   --at-fill/--at-ink derivation) select on `.at-hero` and two BODY attributes
   and are not scoped to any variant, so reusing the classes is what makes this
   a markup move rather than a stylesheet port. Renaming them per variant would
   mean maintaining two copies of that CSS for no gain.

   THE CALLER MUST SUPPLY, in its own scope:
     $atHeroStyle    light|gradient|solid|soft|plain
     $atHeroWidth    boxed|edge      -- and ALSO emit body[data-at-hero-width],
                                        which is what the edge geometry keys off
     $atHeroActs     right|below|off
     $atHeroSize     full|slim
     $atHeroProfile  off|avatar
     $atInvN         unpaid invoice count, for the Pay balance pill

   Every one of those is read with a |default: here as well, so a caller that
   forgets one renders the shipped look rather than an empty attribute -- an
   empty data-at-style matches no CSS arm at all and the band loses its fill.

   Variants are mutually exclusive -- exactly one renders per request -- so the
   profile dropdown's ddId is safe to hardcode: there can never be two bands on
   one page competing for `profileDropdownBand`. *}
<section class="at-hero"
         data-at-style="{$atHeroStyle|default:'light'|escape}"
         data-at-width="{$atHeroWidth|default:'boxed'|escape}"
         data-at-acts="{$atHeroActs|default:'right'|escape}"
         data-at-profile="{$atHeroProfile|default:'off'|escape}"
         data-at-size="{$atHeroSize|default:'full'|escape}">
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
        {* .when-full / .when-empty are driven by body[data-data], which every
           variant that includes this band already emits. *}
        <p class="at-hero-sub">
            <span class="when-full">{$hadrianLang.dashboard.atriumSubFull}</span>
            <span class="when-empty">{$hadrianLang.dashboard.atriumSubEmpty}</span>
        </p>
    </div>
    {if ($atHeroActs|default:'right') != 'off'}
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
