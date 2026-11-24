{* The track slides left by half its own width and starts over, so the tags are
   printed twice: the second run takes the place of the first as it leaves.
   A short list is printed four times so the row is never narrower than the
   screen. Only the first run is read out. *}
{assign var=hbTags value=0}
{foreach $s.tagsLines as $tag}{assign var=hbTags value=$hbTags+1}{/foreach}
{if $hbTags > 0 || $s.title !== ''}
<section class="hp-feature-marquee">
    {if $s.title !== ''}<h2>{$s.title|escape}</h2>{/if}
    {if $hbTags > 0}
        {if $hbTags < 6}{assign var=hbRuns value=4}{else}{assign var=hbRuns value=2}{/if}
        <div class="hp-marq-track">
            {for $hbRun = 1 to $hbRuns}
                {foreach $s.tagsLines as $tag}
                    <span class="hp-marq-tag"{if $hbRun > 1} aria-hidden="true"{/if}><span class="dot"></span> {$tag|escape}</span>
                {/foreach}
            {/for}
        </div>
    {/if}
</section>
{/if}
