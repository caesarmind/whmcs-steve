{if isset($myTheme.pages['two-factor-new-backup-code'].fullPath) && $myTheme.pages['two-factor-new-backup-code'].fullPath && file_exists("templates/`$myTheme.pages['two-factor-new-backup-code'].fullPath`")}
	{include file="`$myTheme.pages['two-factor-new-backup-code'].fullPath`"}
{else}
	{include file="`$template`/core/pages/two-factor-new-backup-code/default/default.tpl"}
{/if}
