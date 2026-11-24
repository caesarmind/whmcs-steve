{assign var=hbCount value=0}
{foreach $s.items as $item}{if $item.value !== '' || $item.title !== '' || $item.text !== ''}{assign var=hbCount value=$hbCount+1}{/if}{/foreach}
{if $hbCount > 0 || $s.title !== ''}
<section class="hp-feature-bignum">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $s.subtitle !== ''}<p class="sub">{$s.subtitle|escape}</p>{/if}
    {if $hbCount > 0}
        <div class="hp-bignum-grid">
            {foreach $s.items as $item}
                {if $item.value !== '' || $item.title !== '' || $item.text !== ''}
                    <div class="hp-bignum-item">
                        {if $item.value !== ''}<div class="num">{$item.value|escape}</div>{/if}
                        {if $item.title !== ''}<h4>{$item.title|escape}</h4>{/if}
                        {if $item.text !== ''}<p>{$item.text|escape|nl2br}</p>{/if}
                    </div>
                {/if}
            {/foreach}
        </div>
    {/if}
</section>
{/if}
