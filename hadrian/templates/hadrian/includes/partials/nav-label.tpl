{*
    One menu label, styled the way the admin set it in the item drawer
    (Addons > Hadrian > Menu > item > Name): text transform, a badge, and
    "hide label". Shared by the sidebar, the top nav, the minimal top bar and
    the footers, so the five drawer fields mean the same thing everywhere.

    Params:
      item     one entry from TreeRenderer::buildFlatList (already validated)
      hasIcon  true where an icon is drawn beside the label. "Hide label" only
               hides it then: an item with neither icon nor text would be an
               empty, unclickable link. The label stays in the accessible name.

    The item's description and CSS class belong on the link itself, so the
    calling template prints those (title="..." and class).
*}
{strip}
{assign var=mtLabelHide value=($item.hide_label|default:false && $hasIcon|default:false)}
{assign var=mtLabelTt value=$item.text_transform|default:''}
{if $mtLabelHide || $mtLabelTt}
    <span class="mt-nav-label{if $mtLabelHide} sr-only{/if}{if $mtLabelTt} mt-tt-{$mtLabelTt|escape}{/if}">{$item.label|escape}</span>
{else}
    {$item.label|escape}
{/if}
{if $item.badge|default:''}
    <span class="mt-nav-badge">{$item.badge|escape}</span>
{/if}
{/strip}
