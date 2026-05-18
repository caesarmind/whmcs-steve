{*
 * mytheme_cart/sidebar-categories-selector.tpl
 *
 * Mobile / collapsed-viewport variant of the categories panel. Used
 * from sidebar-categories-collapsed.tpl which loops every $panel in
 * $secondarySidebar and includes this file once per panel.
 *
 * Contract preserved verbatim:
 *   - Outer .panel-heading.card-header + .panel-body.card-body hooks
 *     (kept so standard_cart's scripts.min.js + Bootstrap collapse
 *     plumbing continues to find the same nodes).
 *   - <select class="form-control"> with the selectChangeNavigate()
 *     onchange handler defined globally by scripts.min.js -- this is
 *     what actually navigates between cart-category URIs.
 *   - menuItemName / value / class="list-group-item" / "selected"
 *     attributes on each <option> are the legacy hooks WHMCS expects.
 *
 * Apple visual layer:
 *   - .card-subnav wrapper inherits the Apple card surface from
 *     style.min.css (rounded, hairline border, light shadow).
 *   - .form-control already restyled to the Apple input primitive.
 *   - .panel-heading and .panel-footer pick up the Apple typography
 *     resets without any new class hooks needed here.
 *}

{if $panel}
    <div class="card-subnav-heading panel-heading card-header">
        <h3 class="panel-title subnav-heading">
            {if $panel->hasIcon()}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" class="subnav-heading-ico"><path d="M21 16V8a2 2 0 00-1-1.73l-7-4a2 2 0 00-2 0l-7 4A2 2 0 003 8v8a2 2 0 001 1.73l7 4a2 2 0 002 0l7-4A2 2 0 0021 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>
            {/if}

            {$panel->getLabel()|escape}

            {if $panel->hasBadge()}
                <span class="badge subnav-badge">{$panel->getBadge()|escape}</span>
            {/if}
        </h3>
    </div>

    <div class="panel-body card-body card-subnav-body">
        <form role="form">
            <select class="form-control custom-select" onchange="selectChangeNavigate(this)">
                {assign var='hasCurrent' value=false}
                {foreach $panel->getChildren() as $child}
                    <option menuItemName="{$child->getName()|escape}" value="{$child->getUri()|escape}" class="list-group-item"{if $child->isCurrent()} selected="selected"{/if}>
                        {$child->getLabel()|escape}{if $child->hasBadge()} ({$child->getBadge()|escape}){/if}
                    </option>
                    {if !$hasCurrent && $child->isCurrent()}
                        {assign var='hasCurrent' value=true}
                    {/if}
                {/foreach}
                {if !$hasCurrent}
                    <option value="" class="list-group-item" selected="selected">- {lang key="cartchooseanothercategory"} -</option>
                {/if}
            </select>
        </form>
    </div>

    {if $panel->hasFooterHtml()}
        <div class="panel-footer card-footer card-subnav-footer">
            {$panel->getFooterHtml()}
        </div>
    {/if}
{/if}
