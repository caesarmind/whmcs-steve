{* Network-issue banner - the WHMCS shared include, shown across the client
   area like stock Nexus (which includes it from header.tpl): WHMCS sets
   $openNetworkIssueCounts {open, scheduled} from Support > Network Issues.
   An open issue shows the warning banner; otherwise a scheduled one shows
   the info banner. Both link to the server status page. Reuses the
   email-verification banner's classes (core-theme.css .mt-verify-*). *}
{if isset($openNetworkIssueCounts) && ($openNetworkIssueCounts.open > 0 || $openNetworkIssueCounts.scheduled > 0)}
{assign var=hnNetOpen value=($openNetworkIssueCounts.open > 0)}
<div class="mt-verify-banner network-issue-alert" role="status"{if !$hnNetOpen} style="background:var(--color-blue-bg);color:var(--color-blue-text)"{/if}>
    <span class="mt-verify-ico">
        {if $hnNetOpen}
        <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        {else}
        <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        {/if}
    </span>
    <span class="mt-verify-text">{if $hnNetOpen}{lang key='networkIssuesAware'}{else}{lang key='networkIssuesScheduled'}{/if}</span>
    <a href="{$WEB_ROOT}/serverstatus.php" class="mt-verify-resend" style="display:inline-flex;align-items:center;text-decoration:none;{if !$hnNetOpen}background:var(--color-blue-text);{/if}">{lang key='learnmore'}</a>
</div>
{/if}
