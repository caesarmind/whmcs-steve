{* Main client area menu — uses WHMCS's primary navbar collection. *}
<nav class="main-menu" aria-label="Main">
    <ul class="menu-items">
        {foreach $primaryNavbar as $item}
            <li class="menu-item{if $item->getClass()} {$item->getClass()}{/if}{if $item->isCurrent()} is-active{/if}">
                <a href="{$item->getUri()}">
                    {if $item->hasIcon()}<i class="{$item->getIcon()}"></i>{/if}
                    {$item->getLabel()}
                    {if $item->hasBadge()}<span class="badge">{$item->getBadge()}</span>{/if}
                </a>
            </li>
        {/foreach}
    </ul>
</nav>
