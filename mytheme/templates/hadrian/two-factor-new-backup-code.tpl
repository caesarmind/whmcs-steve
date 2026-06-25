{if isset($hadrian.pages['two-factor-new-backup-code'].fullPath) && $hadrian.pages['two-factor-new-backup-code'].fullPath && file_exists("templates/`$hadrian.pages['two-factor-new-backup-code'].fullPath`")}
	{include file="`$hadrian.pages['two-factor-new-backup-code'].fullPath`"}
{else}
	{include file="`$template`/core/pages/two-factor-new-backup-code/default/default.tpl"}
{/if}
