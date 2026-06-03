{* Hostnodes - Domain pricing (Apple-style): TLD price table.

   WHMCS variables (cross-checked against Lagom domain-pricing.tpl):
     $pricing       - extension => { group('hot'|'new'|'sale'|''), categories[],
                      register[years=>price], transfer[years=>price], renew[years=>price],
                      grace_period{days,price}, redemption_period{days,price} }
                      (price values are pre-formatted strings, may contain sale HTML)
     $tldCategories - category => count
   Search + category filter are client-side. We show the first pricing tier per column.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasPricing value=false}
{if isset($pricing) && $pricing|@count > 0}{assign var=hasPricing value=true}{/if}

{assign var=dpDemo value=false}
{if !$hasPricing && $isPreview}
    {assign var=dpDemo value=true}
    {assign var=pricing value=[
        'com'=>['group'=>'','categories'=>['Popular'],'register'=>[1=>'$10.99'],'transfer'=>[1=>'$10.99'],'renew'=>[1=>'$12.99']],
        'io'=>['group'=>'hot','categories'=>['Tech'],'register'=>[1=>'$39.99'],'transfer'=>[1=>'$39.99'],'renew'=>[1=>'$44.99']],
        'dev'=>['group'=>'new','categories'=>['Tech'],'register'=>[1=>'$14.99'],'transfer'=>[1=>'$14.99'],'renew'=>[1=>'$16.99']],
        'store'=>['group'=>'sale','categories'=>['Business'],'register'=>[1=>'$4.99'],'transfer'=>[1=>'$49.99'],'renew'=>[1=>'$59.99']],
        'org'=>['group'=>'','categories'=>['Popular'],'register'=>[1=>'$11.99'],'transfer'=>[1=>'$11.99'],'renew'=>[1=>'$13.99']]
    ]}
    {assign var=tldCategories value=['Popular'=>2,'Tech'=>2,'Business'=>1]}
    {assign var=hasPricing value=true}
{/if}

{if $hasPricing}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/domain-pricing.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.navdomains}</p>
    <h1>{$LANG.domainpricing}</h1>
    <p class="page-subtitle">{$hadrianLang.domains.pricingIntro}</p>
</header>

{if $hasPricing}
<div class="when-full">
    <div class="dp-toolbar">
        <div class="dp-search">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="search" id="dpSearch" placeholder="{$hadrianLang.domains.searchExtensions}" autocomplete="off">
        </div>
        {if isset($tldCategories) && $tldCategories|@count > 0}
        <select class="dp-filter" id="dpFilter" aria-label="{$LANG.category}">
            <option value="All">{$LANG.all}</option>
            {foreach $tldCategories as $category => $count}
                <option value="{$category|escape}">{$category|escape} ({$count})</option>
            {/foreach}
        </select>
        {/if}
    </div>

    <div class="card" style="padding: 0; overflow: hidden;">
        <table class="dp-table">
            <thead>
                <tr>
                    <th>{$LANG.domaintld}</th>
                    <th>{$LANG.category}</th>
                    <th>{$LANG.pricing.register}</th>
                    <th>{$LANG.pricing.transfer}</th>
                    <th>{$LANG.pricing.renewal}</th>
                </tr>
            </thead>
            <tbody>
                {foreach $pricing as $extension => $data}
                    {assign var=catAttr value='|'}
                    {if isset($data.categories)}{foreach $data.categories as $cat}{assign var=catAttr value=$catAttr|cat:$cat|cat:'|'}{/foreach}{/if}
                    <tr data-tld=".{$extension|escape}" data-cats="{$catAttr|escape}">
                        <td>
                            <span class="tld-name"><span>.</span>{$extension|escape}</span>
                            {if isset($data.group) && $data.group}<span class="dp-group {$data.group|escape}">{$data.group|escape}</span>{/if}
                        </td>
                        <td class="dp-cat"><span class="dp-label">{$LANG.category}: </span>{if isset($data.categories.0)}{$data.categories.0|escape}{else}-{/if}</td>
                        <td><span class="dp-label">{$LANG.pricing.register}: </span>{if isset($data.register)}{foreach $data.register as $years => $price}{$price}{break}{foreachelse}-{/foreach}{else}-{/if}</td>
                        <td><span class="dp-label">{$LANG.pricing.transfer}: </span>{if isset($data.transfer)}{foreach $data.transfer as $years => $price}{$price}{break}{foreachelse}-{/foreach}{else}-{/if}</td>
                        <td><span class="dp-label">{$LANG.pricing.renewal}: </span>{if isset($data.renew)}{foreach $data.renew as $years => $price}{$price}{break}{foreachelse}-{/foreach}{else}-{/if}</td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</div>
{/if}

{if !$hasPricing}
<div class="when-empty">
    <div class="card">
        <div class="dp-empty">
            <div class="dp-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            </div>
            <p class="dp-empty-title">{$hadrianLang.domains.pricingEmptyTitle}</p>
            <p class="dp-empty-sub">{$hadrianLang.domains.pricingEmptySub}</p>
            <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="btn-primary">{$LANG.registerdomain}</a>
        </div>
    </div>
</div>
{/if}

{if $hasPricing}
<script>
{literal}
(function () {
    var rows = Array.prototype.slice.call(document.querySelectorAll('.dp-table tbody tr[data-tld]'));
    var search = document.getElementById('dpSearch');
    var filter = document.getElementById('dpFilter');
    function apply() {
        var q = (search && search.value || '').toLowerCase();
        var cat = (filter && filter.value) || 'All';
        rows.forEach(function (r) {
            var tld = (r.getAttribute('data-tld') || '').toLowerCase();
            var cats = r.getAttribute('data-cats') || '';
            var qok = !q || tld.indexOf(q) !== -1;
            var cok = cat === 'All' || cats.indexOf('|' + cat + '|') !== -1;
            r.hidden = !(qok && cok);
        });
    }
    if (search) { search.addEventListener('input', apply); }
    if (filter) { filter.addEventListener('change', apply); }
})();
{/literal}
</script>
{/if}
