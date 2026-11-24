{* WHMCS 9 dynamic MarketConnect landing page.

   For MarketConnect services WHMCS launches without a hand-made template:
   the MarketConnect API sends the whole page ($pageData: branding colours,
   an ordered list of blocks, plan feature tables) and this loops the blocks,
   including store/dynamic/partial/<blockType>.tpl for each (header,
   product_preview, grid_of_cards, price_comparison, free_form, faq, video).
   Ported from stock twenty-one; Lagom 2.4 ships the stock files unchanged.

   Hadrian changes: text, background and panel colours follow Hadrian's
   tokens (so dark mode and the colour presets apply) while the partner's
   primary / secondary / accent colours stay for the brand accents; the font
   is the theme's; stock's store.css (Bootstrap-era helpers) isn't loaded;
   FontAwesome icons in the partials are inline SVG. *}
<link href="{assetPath ns='store/dynamic/assets' file='dynamic-store.css'}?v={$versionHash}" rel="stylesheet">

<div class="dynamic-landing-page"
     style="
             --primary-color: {$pageData->branding->primaryColor};
             --secondary-color: {$pageData->branding->secondaryColor};
             --accent-color: {$pageData->branding->accentColor};
             --text-color: var(--color-text-primary);
             --text-secondary: var(--color-text-secondary);
             --bg-color: var(--color-bg);
             --bg-light: var(--color-surface-secondary);
             --bg-dark: var(--color-surface-tertiary, var(--color-surface-secondary));
             font-family: inherit;
             ">
    {foreach $pageData->blocks->items as $brandingBlock}
        {$blockType = $brandingBlock->getBlockType()}
        {$blockLink = "$template/store/dynamic/partial/$blockType.tpl"}

        {include file=$blockLink
            config=$brandingBlock
            products=$products
            hasPlan=$blockHasPlan[$brandingBlock@iteration]
            elementIndex=$brandingBlock@iteration}
    {/foreach}
</div>
<script src="{assetPath ns='store/dynamic/assets' file='dynamic-store.js'}?v={$versionHash}"></script>
