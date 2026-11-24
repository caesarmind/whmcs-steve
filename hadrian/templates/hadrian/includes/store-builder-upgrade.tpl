{* MarketConnect website-builder upgrade page, shared by store/sitebuilder/
   upgrade.tpl (Site Builder) and store/weebly/upgrade.tpl (Weebly). WHMCS
   shows it when a client's builder plan is too small for what they asked
   for; it offers the next plan for one of their builder services. Ported
   from stock twenty-one (the two stock files differ only in the names
   passed in here):
     langKey        store.<langKey>.upgrade.* strings
     logo           assets/img/marketconnect/<logo>/logo.png
     services       the client's builder services [{type, id, domain}]
     upRoute        the order route the form posts to
     switchRoute    where "switch user" sends the client after logout
   plus $product (the plan offered, or null), $promo, $loggedin,
   $loggedinuser. *}
<section class="hp-hero-split" style="padding: 60px 22px;">
    <div class="hp-split-text">
        <img src="{$WEB_ROOT}/assets/img/marketconnect/{$logo}/logo.png" alt="" style="max-height:48px;width:auto;margin-bottom:16px;">
        <h1>{lang key="store.`$langKey`.upgrade.required"}</h1>
        <p>{lang key="store.`$langKey`.upgrade.requiredDescription"}</p>
        <p>{if $loggedin}{lang key="store.`$langKey`.upgrade.recommended"}{else}{lang key="store.`$langKey`.upgrade.login"}{/if}</p>
    </div>
    <div class="hp-split-visual">
        <div class="card" style="width:100%;max-width:420px;padding:28px;">
            {if count($services) > 0}
                {if is_null($product)}
                    <h2 style="margin:0 0 8px;">{lang key="store.`$langKey`.upgrade.no"}</h2>
                    <p style="color:var(--color-text-secondary);">{lang key="store.`$langKey`.upgrade.noUpgrade"}</p>
                    <p><a href="submitticket.php">{lang key="store.`$langKey`.upgrade.submitTicket"}</a></p>
                {else}
                    <h2 style="margin:0 0 4px;">{$promo->getHeadline()}</h2>
                    <p style="margin:0 0 14px;color:var(--color-text-secondary);">{$promo->getTagline()}</p>
                    {if $promo->hasFeatures()}
                        <ul style="margin:0 0 18px;padding-left:18px;line-height:1.7;">
                            {foreach $promo->getFeatures() as $feature}<li>{$feature}</li>{/foreach}
                        </ul>
                    {/if}
                    <form method="post" action="{routePath($upRoute)}" style="display:flex;flex-direction:column;gap:10px;">
                        <select name="service" class="form-select"{if count($services) == 1} hidden{/if} aria-label="{lang key='domainname'}">
                            {foreach $services as $service}
                                <option value="{$service.type}-{$service.id}">{$service.domain}</option>
                            {/foreach}
                        </select>
                        <button type="submit" class="hp-buy-btn">{lang key="store.`$langKey`.upgrade.to" product=$product->name amount=$product->pricing()->first()->breakdownPrice()}</button>
                    </form>
                {/if}
            {else}
                <h2 style="margin:0 0 8px;">{lang key="store.`$langKey`.upgrade.noPlans"}</h2>
                <p style="color:var(--color-text-secondary);">{lang key="store.`$langKey`.upgrade.loggedInAs" email=$loggedinuser.email}</p>
                <p><a href="logout.php?redirect={$switchRoute}">{lang key="store.`$langKey`.upgrade.switchUser"}</a></p>
            {/if}
        </div>
    </div>
</section>
