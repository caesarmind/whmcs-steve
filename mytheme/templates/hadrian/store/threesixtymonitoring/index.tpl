{if isset($hadrian.pages['store-threesixtymonitoring'].fullPath) && $hadrian.pages['store-threesixtymonitoring'].fullPath && file_exists("templates/`$hadrian.pages['store-threesixtymonitoring'].fullPath`")}
	{include file="`$hadrian.pages['store-threesixtymonitoring'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-threesixtymonitoring/default/default.tpl"}
{/if}
