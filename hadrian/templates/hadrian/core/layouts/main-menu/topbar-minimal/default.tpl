{* Topbar Minimal — example custom layout markup.

   The contract, demonstrated:
     1. Root carries class "only-topbar-minimal" (only-<dataLayout>): the
        generated gate (Hooks::buildLayoutGatesHead) hides it whenever another
        layout is active, which matters in ?preview=1 where several layouts'
        markup can share the DOM.
     2. Rendered by header.tpl's generic dispatch as a sibling BEFORE
        .ph-main-wrap. Opens nothing it doesn't close.
     3. Consumes the same admin-driven menu list the shipped sidebar renders
        ($mtSidebarItems, built by the Menu manager) — dropdown children are
        flattened out here for brevity; see includes/partials/sidebar.tpl for
        the full recursive treatment.
     4. Mobile: the shell's inner-topbar renders its hamburger for every
        non-top token; this bar simply hides below 900px (layout.css) and the
        drawer takes over. Nothing to wire.
     5. Branding comes from the same $hadrian.branding slots every shipped
        layout uses, with the same company-name fallback. *}
<nav class="tbm-bar only-topbar-minimal">
    <a class="tbm-brand" href="{$WEB_ROOT}/index.php">
        {if !empty($hadrian.branding.logo.light)}
            <img src="{$hadrian.branding.logo.light}"
                 {if !empty($hadrian.branding.logo.dark) && $hadrian.branding.logo.dark != $hadrian.branding.logo.light}data-logo-dark="{$hadrian.branding.logo.dark}"{/if}
                 alt="{$companyname|escape}">
        {else}
            <span class="tbm-brand-name">{$companyname|escape}</span>
        {/if}
    </a>
    {if isset($mtSidebarItems) && $mtSidebarItems}
        <div class="tbm-links">
            {foreach $mtSidebarItems as $item}
                {if $item.type == 'divider' || $item.type == 'header'}{continue}{/if}
                <a href="{$item.uri|escape}"{if $item.target} target="{$item.target|escape}"{/if}>{$item.label|escape}</a>
            {/foreach}
        </div>
    {/if}
</nav>
