{* Top utility nav — login/logout, language, currency. *}
<nav class="top-nav" aria-label="Utility">
    <ul class="nav-items">
        {foreach $secondaryNavbar as $item}
            <li class="nav-item{if $item->getClass()} {$item->getClass()}{/if}">
                <a href="{$item->getUri()}">
                    {if $item->hasIcon()}<i class="{$item->getIcon()}"></i>{/if}
                    {$item->getLabel()}
                </a>
            </li>
        {/foreach}
    </ul>
</nav>
