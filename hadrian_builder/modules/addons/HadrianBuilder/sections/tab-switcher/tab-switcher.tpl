{* The tabs are the distinct tab names of the cards, in the order they first
   appear. A card with no tab name is shown under every tab. With fewer than
   two names there is nothing to switch, so the cards print as one grid.
   The first tab is open in the markup; the script after the section does the
   switching, because the theme script has nothing for this block. *}
{strip}
{assign var=hbCount value=0}
{assign var=hbTabs value=[]}
{assign var=hbTabCount value=0}
{foreach $s.cards as $card}
    {if $card.title !== '' || $card.text !== ''}
        {assign var=hbCount value=$hbCount+1}
        {if $card.tab !== ''}
            {assign var=hbSeen value=false}
            {foreach $hbTabs as $hbTab}{if $hbTab === $card.tab}{assign var=hbSeen value=true}{break}{/if}{/foreach}
            {if !$hbSeen}{append var=hbTabs value=$card.tab}{assign var=hbTabCount value=$hbTabCount+1}{/if}
        {/if}
    {/if}
{/foreach}
{/strip}
{if $hbCount > 0 || $s.title !== ''}
<section class="hp-features-section hp-tab-switcher">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="feat-sub">{$s.subtitle|escape}</p>{/if}
    {if $hbTabCount > 1}
        <div class="hp-ft-tabs"{if $s.title !== '' && $s.subtitle === ''} style="margin-top: 32px;"{/if}>
            {foreach $hbTabs as $hbTab}
                <button type="button" class="hp-ft-tab{if $hbTab@first} active{/if}" aria-pressed="{if $hbTab@first}true{else}false{/if}">{$hbTab|escape}</button>
            {/foreach}
        </div>
        {foreach $hbTabs as $hbTab}
            <div data-hb-panel{if !$hbTab@first} hidden{/if}>
                <div class="hp-feature-cards">
                    {foreach $s.cards as $card}
                        {if ($card.title !== '' || $card.text !== '') && ($card.tab === $hbTab || $card.tab === '')}
                            <div class="hp-feature-card">
                                {if $card.iconSvg !== ''}<div class="feat-icon {$card.colour|escape}">{$card.iconSvg nofilter}</div>{/if}
                                {if $card.title !== ''}<h4>{$card.title|escape}</h4>{/if}
                                {if $card.text !== ''}<p>{$card.text|escape|nl2br}</p>{/if}
                            </div>
                        {/if}
                    {/foreach}
                </div>
            </div>
        {/foreach}
    {elseif $hbCount > 0}
        <div class="hp-feature-cards"{if $s.title !== '' && $s.subtitle === ''} style="margin-top: 38px;"{/if}>
            {foreach $s.cards as $card}
                {if $card.title !== '' || $card.text !== ''}
                    <div class="hp-feature-card">
                        {if $card.iconSvg !== ''}<div class="feat-icon {$card.colour|escape}">{$card.iconSvg nofilter}</div>{/if}
                        {if $card.title !== ''}<h4>{$card.title|escape}</h4>{/if}
                        {if $card.text !== ''}<p>{$card.text|escape|nl2br}</p>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{if $hbTabCount > 1}
<script>{literal}
(function () {
    var me = document.currentScript;
    var root = me ? me.previousElementSibling : null;
    if (!root) { return; }
    var tabs = root.querySelectorAll('.hp-ft-tab');
    var panels = root.querySelectorAll('[data-hb-panel]');
    Array.prototype.forEach.call(tabs, function (tab, at) {
        tab.addEventListener('click', function () {
            Array.prototype.forEach.call(tabs, function (other, i) {
                var on = i === at;
                other.classList.toggle('active', on);
                other.setAttribute('aria-pressed', on ? 'true' : 'false');
                if (panels[i]) { panels[i].hidden = !on; }
            });
        });
    });
})();
{/literal}</script>
{/if}
{/if}
