{* Forwards to the canonical user-password variant. The dispatcher in
   templates/mytheme/changepassword.tpl reads $myTheme.pages.changepassword
   so admin-set variant / SEO / options still apply. *}
{include file="`$template`/core/pages/user-password/default/default.tpl"}
