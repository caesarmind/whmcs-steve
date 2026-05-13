{if isset($myTheme.pages['store-threesixtymonitoring'].fullPath) && $myTheme.pages['store-threesixtymonitoring'].fullPath && file_exists("templates/`$myTheme.pages['store-threesixtymonitoring'].fullPath`")}
	{include file="`$myTheme.pages['store-threesixtymonitoring'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-threesixtymonitoring/default/default.tpl"}
{/if}
