{* =========================================================================
   Company social accounts — rendered in the footer.
   ========================================================================= *}
{foreach $socialAccounts as $account}
    <li class="footer-social-item">
        <a class="footer-social-link" href="{$account->getUrl()}" target="_blank" rel="noopener">
            <i class="{$account->getFontAwesomeIcon()}"></i>
            <span class="sr-only">{$account->getName()}</span>
        </a>
    </li>
{/foreach}
