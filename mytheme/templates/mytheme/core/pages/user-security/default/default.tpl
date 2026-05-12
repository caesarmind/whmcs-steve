{* Hostnodes — User Security (Apple-style).

   WHMCS 9 splits 'account-level' security (clientareasecurity) and
   'user-level' security (user-security). They surface the same 2FA /
   login-alerts / sessions controls — there's no UX reason to maintain
   two distinct designs. Forward to clientareasecurity's tpl so the
   page is identical regardless of which route WHMCS dispatches. *}
{include file="`$template`/core/pages/clientareasecurity/default/default.tpl"}
