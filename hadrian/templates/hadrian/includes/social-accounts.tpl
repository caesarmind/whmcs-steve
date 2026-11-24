{* Social account links - the WHMCS shared include ($socialAccounts, set in
   WHMCS under System Settings > General > Social), for code that includes
   "$template/includes/social-accounts.tpl" by name. Hadrian's footer shows
   the Branding page's socials instead. Stock renders FontAwesome icons,
   which Hadrian doesn't load, so each link shows the network's name taken
   from that icon class ("fab fa-facebook-f" -> "facebook"). *}
{if isset($socialAccounts) && $socialAccounts}
    {foreach $socialAccounts as $account}
        {assign var=hnSocialName value=$account->getFontAwesomeIcon()|regex_replace:'/^.*\bfa-([a-z0-9]+).*$/':'$1'}
        <li class="list-inline-item"><a href="{$account->getUrl()}" target="_blank" rel="noopener">{$hnSocialName|capitalize}</a></li>
    {/foreach}
{/if}
