{* =========================================================================
   Top-of-page banner shown when active or scheduled network issues exist.
   ========================================================================= *}
{if $openNetworkIssueCounts.open > 0}
    <div class="callout warning network-issue-alert">
        <i class="fas fa-exclamation-triangle"></i>
        {lang key='networkIssuesAware'}
        <a href="{$WEB_ROOT}/serverstatus.php" class="callout-link">
            {lang key='learnmore'} <i class="far fa-arrow-right"></i>
        </a>
    </div>
{elseif $openNetworkIssueCounts.scheduled > 0}
    <div class="callout info network-issue-alert">
        <i class="fas fa-info-circle"></i>
        {lang key='networkIssuesScheduled'}
        <a href="{$WEB_ROOT}/serverstatus.php" class="callout-link">
            {lang key='learnmore'} <i class="far fa-arrow-right"></i>
        </a>
    </div>
{/if}
