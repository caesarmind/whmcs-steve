{* WHMCS routes /submitticket.php through this templatefile name. Forward to
   the shared supportticketsubmit/default/default.tpl which branches on
   $deptid / $step to render the right step. *}
{include file="`$template`/core/pages/supportticketsubmit/default/default.tpl"}
